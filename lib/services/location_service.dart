import '../data/indian_states_districts_data.dart';
import 'dynamic_rho_service.dart';
import 'zone_management_service.dart';

/// Service for handling location-based operations
/// Provides API for state, district, and sub-district data with RHO assignment logic
/// 
/// MIGRATION PLAN:
/// - getDynamicRHOAssignment(): New method using backend RHO data (recommended)
/// - getRHOAssignment(): Legacy method using hardcoded data (fallback)
/// 
/// Frontend components should migrate to getDynamicRHOAssignment() to get real
/// RHO assignments from SHO-created records instead of hardcoded mappings.
class LocationService {
  
  /// Get all available states
  static Future<List<String>> getStates() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 100));
    return IndianStatesDistrictsData.stateNames;
  }

  /// Get districts for a specific state
  static Future<List<String>> getDistricts(String stateName) async {
    print('🔍 LocationService.getDistricts called with stateName: "$stateName"');
    
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 150));
    
    final districts = IndianStatesDistrictsData.getDistrictNamesForState(stateName);
    print('🔍 IndianStatesDistrictsData.getDistrictNamesForState("$stateName") returned: $districts');
    print('🔍 Districts count: ${districts.length}');
    
    return districts;
  }

  /// Get sub-districts for a specific district
  static Future<List<String>> getSubDistricts(String stateName, String districtName) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 150));
    return IndianStatesDistrictsData.getSubDistrictsForDistrict(stateName, districtName);
  }

  /// Check if a district requires sub-district selection (densely populated)
  static Future<bool> requiresSubDistrictSelection(String stateName, String districtName) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return IndianStatesDistrictsData.isDistrictDenselyPopulated(stateName, districtName);
  }

  /// Get RHO assignment for a location (using dynamic backend data)
  static Future<RHOAssignmentResult> getDynamicRHOAssignment({
    required String stateName,
    required String districtName,
    String? subDistrictName,
  }) async {
    try {
      final isDenseDistrict = IndianStatesDistrictsData.isDistrictDenselyPopulated(stateName, districtName);
      
      // For densely populated districts, use zone-based assignment
      if (isDenseDistrict && subDistrictName != null && subDistrictName.isNotEmpty) {
        // Import zone management service
        final zoneAssignment = await ZoneManagementService.getRHOForArea(
          stateName: stateName,
          districtName: districtName,
          areaName: subDistrictName,
        );
        
        if (zoneAssignment.success && zoneAssignment.hasAssignment) {
          // Get RHO details from dynamic service
          final assignedRHO = await DynamicRHOService.getRHOById(zoneAssignment.assignedRHOId!);
          
          return RHOAssignmentResult(
            assignedRHOId: zoneAssignment.assignedRHOId,
            availableRHOs: [zoneAssignment.assignedRHOId!],
            isDenselyPopulated: true,
            requiresSubDistrict: false,
            assignedRHO: assignedRHO,
            zoneInfo: ZoneAssignmentInfo(
              zoneName: zoneAssignment.zoneName,
              zoneDescription: zoneAssignment.zoneDescription,
              assignmentId: zoneAssignment.assignmentId,
            ),
          );
        }
      }
      
      // For non-dense districts or when zone assignment is not available,
      // fall back to regular dynamic RHO assignment
      final assignedRHO = await DynamicRHOService.getAssignedRHOForLocation(
        stateName: stateName,
        districtName: districtName,
        subDistrictName: subDistrictName,
      );
      
      // Get all available RHOs for this location
      final availableRHOs = await DynamicRHOService.getRHOsForLocation(
        stateName: stateName,
        districtName: districtName,
        subDistrictName: subDistrictName,
      );
      
      print('🔍 LocationService.getDynamicRHOAssignment results:');
      print('   assignedRHO: ${assignedRHO?.id} (${assignedRHO?.fullName})');
      print('   availableRHOs count: ${availableRHOs.length}');
      
      // Debug each RHO object
      for (int i = 0; i < availableRHOs.length; i++) {
        final rho = availableRHOs[i];
        print('   RHO [$i]: id="${rho.id}", name="${rho.fullName}", officerId="${rho.officerId}"');
      }
      
      final rhoIds = availableRHOs
          .map((rho) => rho.id.isNotEmpty ? rho.id : rho.officerId)  // Use officerId as fallback if id is empty
          .where((id) => id.isNotEmpty)  // Filter out completely empty identifiers
          .toList();
      print('   Final RHO IDs list: $rhoIds');
      
      if (rhoIds.isEmpty && availableRHOs.isNotEmpty) {
        print('⚠️ Critical: Found ${availableRHOs.length} RHOs but no valid identifiers available');
      }
      
      // Use the same fallback logic for assignedRHOId
      final assignedRHOIdValue = assignedRHO != null 
          ? (assignedRHO.id.isNotEmpty ? assignedRHO.id : assignedRHO.officerId)
          : null;
          
      return RHOAssignmentResult(
        assignedRHOId: assignedRHOIdValue,
        availableRHOs: rhoIds,
        isDenselyPopulated: isDenseDistrict,
        requiresSubDistrict: isDenseDistrict && subDistrictName == null,
        assignedRHO: assignedRHO,
      );
    } catch (e) {
      print('❌ Error in getDynamicRHOAssignment, falling back to static data: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      
      // Fallback to static data if dynamic service fails
      final fallbackResult = await getRHOAssignment(
        stateName: stateName,
        districtName: districtName,
        subDistrictName: subDistrictName,
      );
      
      print('🔄 Fallback result: assignedRHOId=${fallbackResult.assignedRHOId}, availableRHOs=${fallbackResult.availableRHOs}');
      return fallbackResult;
    }
  }

  /// Get RHO assignment for a location
  static Future<RHOAssignmentResult> getRHOAssignment({
    required String stateName,
    required String districtName,
    String? subDistrictName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final rhoId = IndianStatesDistrictsData.getRHOForLocation(
      stateName: stateName,
      districtName: districtName,
      subDistrictName: subDistrictName,
    );

    final availableRHOs = IndianStatesDistrictsData.getAvailableRHOsForDistrict(stateName, districtName);
    final isDenseDistrict = IndianStatesDistrictsData.isDistrictDenselyPopulated(stateName, districtName);

    return RHOAssignmentResult(
      assignedRHOId: rhoId,
      availableRHOs: availableRHOs,
      isDenselyPopulated: isDenseDistrict,
      requiresSubDistrict: isDenseDistrict && subDistrictName == null,
      assignedRHO: null, // Will be populated by DynamicRHOService
    );
  }

  /// Get all RHOs available for a district (for manual selection in dense districts)
  static Future<List<String>> getAvailableRHOs(String stateName, String districtName) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return IndianStatesDistrictsData.getAvailableRHOsForDistrict(stateName, districtName);
  }

  /// Search states with autocomplete
  static Future<List<String>> searchStates(String query) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return IndianStatesDistrictsData.searchStates(query);
  }

  /// Search districts with autocomplete
  static Future<List<String>> searchDistricts(String stateName, String query) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return IndianStatesDistrictsData.searchDistricts(stateName, query);
  }

  /// Search sub-districts with autocomplete
  static Future<List<String>> searchSubDistricts(String stateName, String districtName, String query) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return IndianStatesDistrictsData.searchSubDistricts(stateName, districtName, query);
  }

  /// Validate if a location combination is valid
  static Future<LocationValidationResult> validateLocation({
    required String stateName,
    required String districtName,
    String? subDistrictName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Check if state exists
    if (!IndianStatesDistrictsData.stateNames.contains(stateName)) {
      return LocationValidationResult(
        isValid: false,
        errorMessage: 'Invalid state: $stateName',
      );
    }

    // Check if district exists in the state
    final districts = IndianStatesDistrictsData.getDistrictNamesForState(stateName);
    if (!districts.contains(districtName)) {
      return LocationValidationResult(
        isValid: false,
        errorMessage: 'Invalid district: $districtName in $stateName',
      );
    }

    // Check if sub-district is required and provided
    final isDenseDistrict = IndianStatesDistrictsData.isDistrictDenselyPopulated(stateName, districtName);
    if (isDenseDistrict && (subDistrictName == null || subDistrictName.isEmpty)) {
      return LocationValidationResult(
        isValid: false,
        errorMessage: 'Sub-district selection required for $districtName',
        requiresSubDistrict: true,
      );
    }

    // Check if sub-district exists (if provided)
    if (subDistrictName != null && subDistrictName.isNotEmpty) {
      final subDistricts = IndianStatesDistrictsData.getSubDistrictsForDistrict(stateName, districtName);
      if (!subDistricts.contains(subDistrictName)) {
        return LocationValidationResult(
          isValid: false,
          errorMessage: 'Invalid sub-district: $subDistrictName in $districtName',
        );
      }
    }

    return LocationValidationResult(
      isValid: true,
      formattedLocation: IndianStatesDistrictsData.getFormattedLocation(
        stateName: stateName,
        districtName: districtName,
        subDistrictName: subDistrictName,
      ),
    );
  }

  /// Get formatted address string
  static String getFormattedLocation({
    required String stateName,
    required String districtName,
    String? subDistrictName,
  }) {
    return IndianStatesDistrictsData.getFormattedLocation(
      stateName: stateName,
      districtName: districtName,
      subDistrictName: subDistrictName,
    );
  }

  /// Get location codes for database storage
  static Future<LocationCodes> getLocationCodes({
    required String stateName,
    required String districtName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    
    final stateCode = IndianStatesDistrictsData.getStateCode(stateName);
    final districtCode = IndianStatesDistrictsData.getDistrictCode(stateName, districtName);

    return LocationCodes(
      stateCode: stateCode ?? '',
      districtCode: districtCode ?? '',
    );
  }
}

/// Result class for RHO assignment operations
class RHOAssignmentResult {
  final String? assignedRHOId;
  final List<String> availableRHOs;
  final bool isDenselyPopulated;
  final bool requiresSubDistrict;
  final dynamic assignedRHO; // Actual RHO object (can be RegionalHealthOfficer or null)
  final ZoneAssignmentInfo? zoneInfo; // Zone information for dense districts

  const RHOAssignmentResult({
    this.assignedRHOId,
    required this.availableRHOs,
    required this.isDenselyPopulated,
    required this.requiresSubDistrict,
    this.assignedRHO,
    this.zoneInfo,
  });

  bool get hasAssignment => assignedRHOId != null && assignedRHOId!.isNotEmpty;
  bool get hasMultipleRHOs => availableRHOs.length > 1;
  bool get needsManualSelection => isDenselyPopulated && hasMultipleRHOs && !hasAssignment;
  bool get requiresManualSelection => isDenselyPopulated && hasMultipleRHOs && !hasAssignment;
  bool get hasZoneAssignment => zoneInfo != null;
}

/// Zone assignment information for densely populated districts
class ZoneAssignmentInfo {
  final String? zoneName;
  final String? zoneDescription;
  final String? assignmentId;

  const ZoneAssignmentInfo({
    this.zoneName,
    this.zoneDescription,
    this.assignmentId,
  });

  String get displayName => zoneName ?? 'Unknown Zone';
  String get displayDescription => zoneDescription ?? 'No description available';
}

/// Result class for location validation
class LocationValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? formattedLocation;
  final bool requiresSubDistrict;

  const LocationValidationResult({
    required this.isValid,
    this.errorMessage,
    this.formattedLocation,
    this.requiresSubDistrict = false,
  });
}

/// Location codes for database storage
class LocationCodes {
  final String stateCode;
  final String districtCode;

  const LocationCodes({
    required this.stateCode,
    required this.districtCode,
  });

  Map<String, String> toJson() {
    return {
      'stateCode': stateCode,
      'districtCode': districtCode,
    };
  }
}

/// Hospital location information with RHO assignment
class HospitalLocationInfo {
  final String stateName;
  final String districtName;
  final String? subDistrictName;
  final String assignedRHOId;
  final String formattedLocation;
  final LocationCodes locationCodes;

  const HospitalLocationInfo({
    required this.stateName,
    required this.districtName,
    this.subDistrictName,
    required this.assignedRHOId,
    required this.formattedLocation,
    required this.locationCodes,
  });

  Map<String, dynamic> toJson() {
    return {
      'stateName': stateName,
      'districtName': districtName,
      'subDistrictName': subDistrictName,
      'assignedRHOId': assignedRHOId,
      'formattedLocation': formattedLocation,
      'locationCodes': locationCodes.toJson(),
    };
  }

  factory HospitalLocationInfo.fromJson(Map<String, dynamic> json) {
    return HospitalLocationInfo(
      stateName: json['stateName'] ?? '',
      districtName: json['districtName'] ?? '',
      subDistrictName: json['subDistrictName'],
      assignedRHOId: json['assignedRHOId'] ?? '',
      formattedLocation: json['formattedLocation'] ?? '',
      locationCodes: LocationCodes(
        stateCode: json['locationCodes']?['stateCode'] ?? '',
        districtCode: json['locationCodes']?['districtCode'] ?? '',
      ),
    );
  }
}