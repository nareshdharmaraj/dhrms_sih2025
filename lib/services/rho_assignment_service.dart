import 'dart:convert';
import 'package:http/http.dart' as http;
import 'location_service.dart';
import 'api_service.dart';
import '../utils/app_constants.dart';

/// Service for handling RHO assignment operations
/// Manages the assignment of hospitals to Regional Health Officers based on location
/// 
/// IMPORTANT: This service only handles ASSIGNMENT of hospitals to existing RHOs.
/// RHO creation is restricted to State Health Officers (SHOs) only and is handled
/// through the SHO portal, not through hospital registration.
class RHOAssignmentService {
  static String get _baseUrl => '${ApiService.baseUrl}/rho-assignment';

  /// Assign hospital to appropriate RHO based on location
  static Future<RHOAssignmentResponse> assignHospitalToRHO({
    required String hospitalId,
    required String stateName,
    required String districtName,
    String? subDistrictName,
    String? manualRHOId, // For dense districts where manual selection is needed
  }) async {
    try {
      // First, validate the location
      final locationValidation = await LocationService.validateLocation(
        stateName: stateName,
        districtName: districtName,
        subDistrictName: subDistrictName,
      );

      if (!locationValidation.isValid) {
        return RHOAssignmentResponse(
          success: false,
          message: locationValidation.errorMessage ?? 'Invalid location',
        );
      }

      // Get RHO assignment based on location (using DYNAMIC service)
      final rhoAssignment = await LocationService.getDynamicRHOAssignment(
        stateName: stateName,
        districtName: districtName,
        subDistrictName: subDistrictName,
      );

      String? finalRHOId;

      // Determine final RHO assignment
      if (manualRHOId != null && rhoAssignment.availableRHOs.contains(manualRHOId)) {
        // Use manual selection for dense districts
        finalRHOId = manualRHOId;
      } else if (rhoAssignment.hasAssignment) {
        // Use automatic assignment
        finalRHOId = rhoAssignment.assignedRHOId;
      } else if (rhoAssignment.requiresSubDistrict) {
        return RHOAssignmentResponse(
          success: false,
          message: 'Sub-district selection required for this location',
          requiresSubDistrict: true,
          availableRHOs: rhoAssignment.availableRHOs,
        );
      } else if (rhoAssignment.requiresManualSelection) {
        return RHOAssignmentResponse(
          success: false,
          message: 'Manual RHO selection required for this densely populated district',
          requiresManualSelection: true,
          availableRHOs: rhoAssignment.availableRHOs,
        );
      }

      if (finalRHOId == null) {
        return RHOAssignmentResponse(
          success: false,
          message: 'No RHO available for this location',
        );
      }

      // Get location codes for database storage
      final locationCodes = await LocationService.getLocationCodes(
        stateName: stateName,
        districtName: districtName,
      );

      // Create hospital location info
      final hospitalLocationInfo = HospitalLocationInfo(
        stateName: stateName,
        districtName: districtName,
        subDistrictName: subDistrictName,
        assignedRHOId: finalRHOId,
        formattedLocation: LocationService.getFormattedLocation(
          stateName: stateName,
          districtName: districtName,
          subDistrictName: subDistrictName,
        ),
        locationCodes: locationCodes,
      );

      // Send assignment to backend
      final response = await http.post(
        Uri.parse('$_baseUrl/assign'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'hospitalId': hospitalId,
          'rhoId': finalRHOId,
          'locationInfo': hospitalLocationInfo.toJson(),
          'assignmentType': manualRHOId != null ? 'manual' : 'automatic',
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return RHOAssignmentResponse(
          success: true,
          message: 'Hospital successfully assigned to RHO',
          assignedRHOId: finalRHOId,
          hospitalLocationInfo: hospitalLocationInfo,
          assignmentData: data,
        );
      } else {
        final errorData = json.decode(response.body);
        return RHOAssignmentResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to assign hospital to RHO',
        );
      }
    } catch (e) {
      return RHOAssignmentResponse(
        success: false,
        message: 'Error during RHO assignment: ${e.toString()}',
      );
    }
  }

  /// Get RHO assignment preview without actually assigning
  static Future<RHOAssignmentPreview> previewRHOAssignment({
    required String stateName,
    required String districtName,
    String? subDistrictName,
  }) async {
    try {
      print('🔍 Previewing RHO assignment for: $stateName > $districtName > $subDistrictName');
      
      // Validate location
      final locationValidation = await LocationService.validateLocation(
        stateName: stateName,
        districtName: districtName,
        subDistrictName: subDistrictName,
      );

      if (!locationValidation.isValid) {
        print('❌ Location validation failed: ${locationValidation.errorMessage}');
        return RHOAssignmentPreview(
          isValid: false,
          errorMessage: locationValidation.errorMessage,
          requiresSubDistrict: locationValidation.requiresSubDistrict,
        );
      }

      // Get RHO assignment info from DYNAMIC service (database)
      final rhoAssignment = await LocationService.getDynamicRHOAssignment(
        stateName: stateName,
        districtName: districtName,
        subDistrictName: subDistrictName,
      );

      print('🔍 RHO Assignment Result received in previewRHOAssignment:');
      print('   assignedRHOId: ${rhoAssignment.assignedRHOId}');
      print('   availableRHOs: ${rhoAssignment.availableRHOs}');
      print('   assignedRHO: ${rhoAssignment.assignedRHO?.fullName}');

      // Check if there are available RHOs for this location
      if (rhoAssignment.availableRHOs.isEmpty) {
        print('⚠️ No RHOs available for $districtName, $stateName');
        return RHOAssignmentPreview(
          isValid: true,
          errorMessage: 'RHO not created or assigned for this location',
          assignedRHOId: null,
          availableRHOs: [],
          isDenselyPopulated: rhoAssignment.isDenselyPopulated,
          requiresSubDistrict: rhoAssignment.requiresSubDistrict,
          requiresManualSelection: false,
          formattedLocation: locationValidation.formattedLocation,
          isUnassigned: true,
        );
      }

      // If there's no specific pre-assignment but RHOs are available, use automatic assignment
      if (rhoAssignment.assignedRHOId == null || rhoAssignment.assignedRHOId!.isEmpty) {
        print('🔍 No pre-assigned RHO, but ${rhoAssignment.availableRHOs.length} RHOs available for automatic assignment');
        
        // If multiple RHOs available, show as requiring manual selection (but we'll handle automatically)
        if (rhoAssignment.availableRHOs.length > 1) {
          return RHOAssignmentPreview(
            isValid: true,
            assignedRHOId: null,
            availableRHOs: rhoAssignment.availableRHOs,
            isDenselyPopulated: rhoAssignment.isDenselyPopulated,
            requiresSubDistrict: rhoAssignment.requiresSubDistrict,
            requiresManualSelection: true,
            formattedLocation: locationValidation.formattedLocation,
            assignedRHO: rhoAssignment.assignedRHO,
          );
        } else {
          // Single RHO available - automatic assignment
          return RHOAssignmentPreview(
            isValid: true,
            assignedRHOId: rhoAssignment.availableRHOs.first,
            availableRHOs: rhoAssignment.availableRHOs,
            isDenselyPopulated: rhoAssignment.isDenselyPopulated,
            requiresSubDistrict: rhoAssignment.requiresSubDistrict,
            requiresManualSelection: false,
            formattedLocation: locationValidation.formattedLocation,
            assignedRHO: rhoAssignment.assignedRHO,
          );
        }
      }

      print('✅ Found RHO assignment: ${rhoAssignment.assignedRHOId}');
      return RHOAssignmentPreview(
        isValid: true,
        assignedRHOId: rhoAssignment.assignedRHOId,
        availableRHOs: rhoAssignment.availableRHOs,
        isDenselyPopulated: rhoAssignment.isDenselyPopulated,
        requiresSubDistrict: rhoAssignment.requiresSubDistrict,
        requiresManualSelection: rhoAssignment.requiresManualSelection,
        formattedLocation: locationValidation.formattedLocation,
        assignedRHO: rhoAssignment.assignedRHO,
      );
    } catch (e) {
      print('❌ Error previewing RHO assignment: $e');
      return RHOAssignmentPreview(
        isValid: false,
        errorMessage: 'Error previewing RHO assignment: ${e.toString()}',
      );
    }
  }

  /// Get RHO information for display
  static Future<RHOInfo?> getRHOInfo(String rhoId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/rho-info/$rhoId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RHOInfo.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching RHO info: $e');
      return null;
    }
  }

  /// Get multiple RHO information for selection UI
  static Future<List<RHOInfo>> getMultipleRHOInfo(List<String> rhoIds) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/rhos-info'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'rhoIds': rhoIds}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['rhos'] as List)
            .map((rho) => RHOInfo.fromJson(rho))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching multiple RHO info: $e');
      return [];
    }
  }

  /// Get RHO information for a specific location (for hospital registration)
  static Future<List<RHOInfo>> getRHOsForLocation({
    required String stateName,
    required String districtName,
  }) async {
    try {
      print('🔍 Fetching RHOs for hospital registration: $stateName, $districtName');
      
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/rho/public?state=${Uri.encodeComponent(stateName)}&district=${Uri.encodeComponent(districtName)}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['rhos'] != null) {
          final List<RHOInfo> rhos = (data['rhos'] as List)
              .map((rho) => RHOInfo(
                rhoId: rho['officerId'] ?? '',
                fullName: rho['fullName'] ?? 'Unknown RHO',
                email: '', // Not available in public endpoint
                phone: '', // Not available in public endpoint
                assignedDistrict: rho['assignedDistrict'] ?? districtName,
                assignedState: rho['assignedState'] ?? stateName,
                regionName: rho['assignedRegion'] ?? '',
                workload: 0, // Not available in public endpoint
                isActive: true,
              ))
              .toList();

          print('✅ Found ${rhos.length} RHOs for $districtName, $stateName');
          return rhos;
        }
      }
      
      print('❌ Failed to fetch RHOs for location: ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ Error fetching RHOs for location: $e');
      return [];
    }
  }

  /// Check if a hospital is already assigned to an RHO
  static Future<HospitalRHOStatus?> getHospitalRHOStatus(String hospitalId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/hospital-status/$hospitalId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return HospitalRHOStatus.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error checking hospital RHO status: $e');
      return null;
    }
  }

  /// Update hospital's RHO assignment
  static Future<RHOAssignmentResponse> updateHospitalRHOAssignment({
    required String hospitalId,
    required String newRHOId,
    required String reason,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/update-assignment'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'hospitalId': hospitalId,
          'newRHOId': newRHOId,
          'reason': reason,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RHOAssignmentResponse(
          success: true,
          message: 'Hospital RHO assignment updated successfully',
          assignedRHOId: newRHOId,
          assignmentData: data,
        );
      } else {
        final errorData = json.decode(response.body);
        return RHOAssignmentResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to update RHO assignment',
        );
      }
    } catch (e) {
      return RHOAssignmentResponse(
        success: false,
        message: 'Error updating RHO assignment: ${e.toString()}',
      );
    }
  }
}

/// Response class for RHO assignment operations
class RHOAssignmentResponse {
  final bool success;
  final String message;
  final String? assignedRHOId;
  final HospitalLocationInfo? hospitalLocationInfo;
  final List<String> availableRHOs;
  final bool requiresSubDistrict;
  final bool requiresManualSelection;
  final Map<String, dynamic>? assignmentData;

  const RHOAssignmentResponse({
    required this.success,
    required this.message,
    this.assignedRHOId,
    this.hospitalLocationInfo,
    this.availableRHOs = const [],
    this.requiresSubDistrict = false,
    this.requiresManualSelection = false,
    this.assignmentData,
  });
}

/// Preview class for RHO assignment (before actual assignment)
class RHOAssignmentPreview {
  final bool isValid;
  final String? errorMessage;
  final String? assignedRHOId;
  final List<String> availableRHOs;
  final bool isDenselyPopulated;
  final bool requiresSubDistrict;
  final bool requiresManualSelection;
  final String? formattedLocation;
  final bool isUnassigned;
  final dynamic assignedRHO; // RegionalHealthOfficer object

  const RHOAssignmentPreview({
    required this.isValid,
    this.errorMessage,
    this.assignedRHOId,
    this.availableRHOs = const [],
    this.isDenselyPopulated = false,
    this.requiresSubDistrict = false,
    this.requiresManualSelection = false,
    this.formattedLocation,
    this.isUnassigned = false,
    this.assignedRHO,
  });

  bool get hasAssignment => assignedRHOId != null && assignedRHOId!.isNotEmpty;
  bool get hasMultipleOptions => availableRHOs.length > 1;
  bool get canProceed => isValid && !isUnassigned && !requiresSubDistrict && !requiresManualSelection;
  
  String get displayMessage {
    if (!isValid) return errorMessage ?? 'Invalid location';
    if (isUnassigned) return 'RHO not created or assigned';
    if (hasAssignment && assignedRHO != null) {
      return 'Assigned to: ${assignedRHO.fullName} (${assignedRHO.officerId})';
    }
    if (requiresSubDistrict) return 'Sub-district selection required';
    if (requiresManualSelection) return 'Multiple RHOs available - manual selection required';
    return 'Ready for assignment';
  }
}

/// RHO information for display in UI
class RHOInfo {
  final String rhoId;
  final String fullName;
  final String email;
  final String phone;
  final String assignedDistrict;
  final String assignedState;
  final String regionName;
  final int workload; // Number of hospitals assigned
  final bool isActive;

  const RHOInfo({
    required this.rhoId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.assignedDistrict,
    required this.assignedState,
    required this.regionName,
    required this.workload,
    required this.isActive,
  });

  factory RHOInfo.fromJson(Map<String, dynamic> json) {
    return RHOInfo(
      rhoId: json['rhoId'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      assignedDistrict: json['assignedDistrict'] ?? '',
      assignedState: json['assignedState'] ?? '',
      regionName: json['regionName'] ?? '',
      workload: json['workload'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

  String get displayName => '$fullName ($rhoId)';
  String get workloadText => '$workload hospitals';
  String get statusText => isActive ? 'Active' : 'Inactive';
}

/// Hospital's current RHO assignment status
class HospitalRHOStatus {
  final String hospitalId;
  final bool isAssigned;
  final String? assignedRHOId;
  final String? assignedRHOName;
  final DateTime? assignmentDate;
  final String? assignmentType; // 'automatic' or 'manual'

  const HospitalRHOStatus({
    required this.hospitalId,
    required this.isAssigned,
    this.assignedRHOId,
    this.assignedRHOName,
    this.assignmentDate,
    this.assignmentType,
  });

  factory HospitalRHOStatus.fromJson(Map<String, dynamic> json) {
    return HospitalRHOStatus(
      hospitalId: json['hospitalId'] ?? '',
      isAssigned: json['isAssigned'] ?? false,
      assignedRHOId: json['assignedRHOId'],
      assignedRHOName: json['assignedRHOName'],
      assignmentDate: json['assignmentDate'] != null 
          ? DateTime.parse(json['assignmentDate']) 
          : null,
      assignmentType: json['assignmentType'],
    );
  }

  String get statusText => isAssigned ? 'Assigned' : 'Unassigned';
}