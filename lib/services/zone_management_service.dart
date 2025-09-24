import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../data/indian_states_districts_data.dart';

/// Service for managing RHO zone assignments in densely populated districts
/// This service helps SHOs create and manage zone-wise RHO assignments
/// showing available areas/sub-districts for each zone
class ZoneManagementService {
  static String get _baseUrl => '${ApiService.baseUrl}/zone-management';

  /// Get available areas/sub-districts for a densely populated district
  /// This shows SHOs what areas they can assign to RHO zones
  static Future<ZoneAvailableAreasResult> getAvailableAreasForDistrict({
    required String stateName,
    required String districtName,
  }) async {
    try {
      // Get static data first to show available sub-districts
      final districts = IndianStatesDistrictsData.getDistrictsForState(stateName);
      final district = districts.firstWhere(
        (d) => d.name == districtName,
        orElse: () => const DistrictData(name: '', code: '', subDistricts: []),
      );

      if (district.name.isEmpty) {
        return ZoneAvailableAreasResult(
          success: false,
          message: 'District not found',
        );
      }

      if (!district.isDenselyPopulated) {
        return ZoneAvailableAreasResult(
          success: false,
          message: 'District is not densely populated - zone assignment not required',
        );
      }

      // Get current zone assignments from backend
      final response = await http.get(
        Uri.parse('$_baseUrl/areas/$stateName/$districtName/available'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      List<ZoneAreaAssignment> existingAssignments = [];
      List<String> unassignedAreas = List<String>.from(district.subDistricts);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Check if backend is using sub-districts (preferred) or fallback areas
          final meta = data['meta'] as Map<String, dynamic>?;
          final usingSubdistricts = meta?['usingSubdistricts'] as bool? ?? false;
          
          if (usingSubdistricts) {
            // Backend has sub-districts - use them and filter by assignments
            final backendAreas = data['data'] as List;
            unassignedAreas = backendAreas
                .where((area) => area['isSubdistrict'] == true)
                .map<String>((area) => area['areaName'].toString())
                .toList();
          } else {
            // Backend has fallback areas - prefer our sub-districts if available
            if (district.subDistricts.isNotEmpty) {
              print('🔍 Using sub-districts from local data: ${district.subDistricts}');
              unassignedAreas = List<String>.from(district.subDistricts);
            } else {
              // No sub-districts available, use backend fallback areas
              unassignedAreas = List<String>.from(data['data'].map((area) => area['areaName']));
            }
          }
          
          // Get existing zones to show current assignments
          final zonesResponse = await http.get(
            Uri.parse('$_baseUrl/zones/$stateName/$districtName'),
            headers: {'Content-Type': 'application/json'},
          );
          
          if (zonesResponse.statusCode == 200) {
            final zonesData = json.decode(zonesResponse.body);
            if (zonesData['success'] == true) {
              existingAssignments = (zonesData['data']['zones'] as List)
                  .map((zone) => ZoneAreaAssignment.fromBackendZone(zone))
                  .toList();
            }
          }
        }
      }

      return ZoneAvailableAreasResult(
        success: true,
        districtName: districtName,
        stateName: stateName,
        allAreas: district.subDistricts,
        unassignedAreas: unassignedAreas,
        existingZoneAssignments: existingAssignments,
        isDenselyPopulated: district.isDenselyPopulated,
      );

    } catch (e) {
      return ZoneAvailableAreasResult(
        success: false,
        message: 'Error fetching available areas: ${e.toString()}',
      );
    }
  }

  /// Create or update RHO zone assignment with specific areas
  static Future<ZoneAssignmentResponse> createRHOZoneAssignment({
    required String rhoId,
    required String rhoName,
    required String stateName,
    required String districtName,
    required List<String> assignedAreas,
    required String zoneName,
    String? zoneDescription,
    required String createdBySHOId,
    List<String>? subDistricts, // Add sub-districts parameter
  }) async {
    try {
      // Validate that all assigned areas exist in the district
      final districts = IndianStatesDistrictsData.getDistrictsForState(stateName);
      final district = districts.firstWhere(
        (d) => d.name == districtName,
        orElse: () => const DistrictData(name: '', code: '', subDistricts: []),
      );

      if (district.name.isEmpty) {
        return ZoneAssignmentResponse(
          success: false,
          message: 'District not found',
        );
      }

      // Check if all assigned areas are valid
      final invalidAreas = assignedAreas.where((area) => !district.subDistricts.contains(area)).toList();
      if (invalidAreas.isNotEmpty) {
        return ZoneAssignmentResponse(
          success: false,
          message: 'Invalid areas found: ${invalidAreas.join(', ')}',
        );
      }

      // Create the zone using backend API structure
      final requestBody = {
        'zoneName': zoneName,
        'state': stateName,
        'district': districtName,
        'areas': assignedAreas.map((areaName) => {
          'areaName': areaName,
          'areaCode': '${areaName.replaceAll(' ', '_').toUpperCase()}_001',
          'isDenselyPopulated': true,
        }).toList(),
        'zoneType': 'urban',
        'priority': 'medium',
        'metadata': {
          'description': zoneDescription ?? 'Zone created for $zoneName',
          'subDistricts': subDistricts ?? [], // Include sub-districts in metadata
          'basedOnSubDistricts': subDistricts?.isNotEmpty ?? false,
        },
        'createdBy': {
          'shoId': createdBySHOId,
          'shoName': 'SHO Name', // This should come from the SHO session
        },
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/zones'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final zone = data['data'];
          
          // Only assign RHO if provided (not empty)
          if (rhoId.isNotEmpty && rhoName.isNotEmpty) {
            await assignRHOToZone(
              zoneId: zone['zoneId'],
              rhoId: rhoId,
              rhoName: rhoName,
              assignedBy: createdBySHOId,
            );
          }
          
          return ZoneAssignmentResponse(
            success: true,
            message: rhoId.isEmpty ? 'Zone created successfully without RHO assignment' : 'Zone created and RHO assigned successfully',
            zoneAssignment: ZoneAreaAssignment.fromBackendZone(zone),
          );
        }
      }
      
      final errorData = json.decode(response.body);
      return ZoneAssignmentResponse(
        success: false,
        message: errorData['message'] ?? 'Failed to create zone',
      );

    } catch (e) {
      return ZoneAssignmentResponse(
        success: false,
        message: 'Error creating zone assignment: ${e.toString()}',
      );
    }
  }

  /// Assign RHO to an existing zone
  static Future<ZoneAssignmentResponse> assignRHOToZone({
    required String zoneId,
    required String rhoId,
    required String rhoName,
    required String assignedBy,
  }) async {
    try {
      final requestBody = {
        'rhoId': rhoId,
        'rhoName': rhoName,
        'assignedBy': assignedBy,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/zones/$zoneId/assign-rho'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ZoneAssignmentResponse(
          success: true,
          message: 'RHO assigned to zone successfully',
          zoneAssignment: ZoneAreaAssignment.fromBackendZone(data['data']),
        );
      } else {
        final errorData = json.decode(response.body);
        return ZoneAssignmentResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to assign RHO to zone',
        );
      }

    } catch (e) {
      return ZoneAssignmentResponse(
        success: false,
        message: 'Error assigning RHO to zone: ${e.toString()}',
      );
    }
  }

  /// Update existing RHO zone assignment
  static Future<ZoneAssignmentResponse> updateRHOZoneAssignment({
    required String zoneId,
    required List<String> newAssignedAreas,
    String? newZoneName,
    String? newZoneDescription,
    required String updatedBySHOId,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'areas': newAssignedAreas.map((areaName) => {
          'areaName': areaName,
          'areaCode': '${areaName.replaceAll(' ', '_').toUpperCase()}_001',
          'isDenselyPopulated': true,
        }).toList(),
      };

      if (newZoneName != null) requestBody['zoneName'] = newZoneName;
      if (newZoneDescription != null) {
        requestBody['metadata'] = {'description': newZoneDescription};
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/zones/$zoneId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ZoneAssignmentResponse(
          success: true,
          message: 'Zone updated successfully',
          zoneAssignment: ZoneAreaAssignment.fromBackendZone(data['data']),
        );
      } else {
        final errorData = json.decode(response.body);
        return ZoneAssignmentResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to update zone',
        );
      }

    } catch (e) {
      return ZoneAssignmentResponse(
        success: false,
        message: 'Error updating zone: ${e.toString()}',
      );
    }
  }

  /// Delete RHO zone assignment
  static Future<ZoneAssignmentResponse> deleteRHOZoneAssignment({
    required String zoneId,
    required String deletedBySHOId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/zones/$zoneId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return ZoneAssignmentResponse(
          success: true,
          message: 'Zone deleted successfully',
        );
      } else {
        final errorData = json.decode(response.body);
        return ZoneAssignmentResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to delete zone',
        );
      }

    } catch (e) {
      return ZoneAssignmentResponse(
        success: false,
        message: 'Error deleting zone: ${e.toString()}',
      );
    }
  }

  /// Get RHO assignment for a specific area during hospital registration
  /// This is used by the registration system to determine which RHO to assign
  static Future<AreaRHOAssignmentResult> getRHOForArea({
    required String stateName,
    required String districtName,
    required String areaName,
  }) async {
    try {
      // URL encode the area name to handle special characters like "/"
      final encodedAreaName = Uri.encodeComponent(areaName);
      final response = await http.get(
        Uri.parse('$_baseUrl/rho-assignment/$stateName/$districtName/$encodedAreaName'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return AreaRHOAssignmentResult(
            success: true,
            assignedRHOId: data['data']['assignedRHO']['rhoId'],
            assignedRHOName: data['data']['assignedRHO']['rhoName'],
            zoneName: data['data']['zone']['zoneName'],
            zoneDescription: data['data']['zone']['metadata']?['description'],
            assignmentId: data['data']['zone']['zoneId'],
          );
        } else {
          return AreaRHOAssignmentResult(
            success: false,
            message: data['message'] ?? 'No RHO assigned to this area',
          );
        }
      } else if (response.statusCode == 404) {
        return AreaRHOAssignmentResult(
          success: false,
          message: 'Area not found or not assigned to any RHO',
        );
      } else {
        return AreaRHOAssignmentResult(
          success: false,
          message: 'Error fetching RHO assignment',
        );
      }

    } catch (e) {
      return AreaRHOAssignmentResult(
        success: false,
        message: 'Error getting RHO for area: ${e.toString()}',
      );
    }
  }

  /// Get all zone assignments for a district (for SHO management view)
  static Future<List<ZoneAreaAssignment>> getDistrictZoneAssignments({
    required String stateName,
    required String districtName,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/zones/$stateName/$districtName'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data']['zones'] as List)
              .map((zone) => ZoneAreaAssignment.fromBackendZone(zone))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting district zone assignments: $e');
      return [];
    }
  }

  /// Get unassigned zones for RHO assignment during RHO creation
  static Future<List<ZoneAreaAssignment>> getUnassignedZonesForRHOCreation({
    required String stateName,
    required String districtName,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/zones/$stateName/$districtName/unassigned'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((zone) => ZoneAreaAssignment.fromBackendZone(zone))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting unassigned zones: $e');
      return [];
    }
  }
}

/// Result class for available areas in a district
class ZoneAvailableAreasResult {
  final bool success;
  final String? message;
  final String districtName;
  final String stateName;
  final List<String> allAreas;
  final List<String> unassignedAreas;
  final List<ZoneAreaAssignment> existingZoneAssignments;
  final bool isDenselyPopulated;

  const ZoneAvailableAreasResult({
    required this.success,
    this.message,
    this.districtName = '',
    this.stateName = '',
    this.allAreas = const [],
    this.unassignedAreas = const [],
    this.existingZoneAssignments = const [],
    this.isDenselyPopulated = false,
  });

  int get totalAreas => allAreas.length;
  int get assignedAreasCount => totalAreas - unassignedAreas.length;
  int get zonesCount => existingZoneAssignments.length;
  bool get hasUnassignedAreas => unassignedAreas.isNotEmpty;
  double get coveragePercentage => totalAreas > 0 ? (assignedAreasCount / totalAreas) * 100 : 0;
}

/// Zone area assignment data class
class ZoneAreaAssignment {
  final String id;
  final String rhoId;
  final String rhoName;
  final String stateName;
  final String districtName;
  final List<String> assignedAreas;
  final String zoneName;
  final String? zoneDescription;
  final String createdBySHOId;
  final DateTime createdAt;
  final String? updatedBySHOId;
  final DateTime? updatedAt;
  final List<String>? subDistricts; // Add sub-districts field

  const ZoneAreaAssignment({
    required this.id,
    required this.rhoId,
    required this.rhoName,
    required this.stateName,
    required this.districtName,
    required this.assignedAreas,
    required this.zoneName,
    this.zoneDescription,
    required this.createdBySHOId,
    required this.createdAt,
    this.updatedBySHOId,
    this.updatedAt,
    this.subDistricts, // Add sub-districts parameter
  });

  factory ZoneAreaAssignment.fromJson(Map<String, dynamic> json) {
    return ZoneAreaAssignment(
      id: json['id'] ?? '',
      rhoId: json['rhoId'] ?? '',
      rhoName: json['rhoName'] ?? '',
      stateName: json['stateName'] ?? '',
      districtName: json['districtName'] ?? '',
      assignedAreas: List<String>.from(json['assignedAreas'] ?? []),
      zoneName: json['zoneName'] ?? '',
      zoneDescription: json['zoneDescription'],
      createdBySHOId: json['createdBySHOId'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedBySHOId: json['updatedBySHOId'],
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      subDistricts: json['metadata']?['subDistricts'] != null 
          ? List<String>.from(json['metadata']['subDistricts']) 
          : null, // Extract sub-districts from metadata
    );
  }

  factory ZoneAreaAssignment.fromBackendZone(Map<String, dynamic> zone) {
    return ZoneAreaAssignment(
      id: zone['zoneId'] ?? '',
      rhoId: zone['assignedRHO']?['rhoId'] ?? '',
      rhoName: zone['assignedRHO']?['rhoName'] ?? '',
      stateName: zone['state'] ?? '',
      districtName: zone['district'] ?? '',
      assignedAreas: (zone['areas'] as List?)?.map((area) => area['areaName'] as String).toList() ?? [],
      zoneName: zone['zoneName'] ?? '',
      zoneDescription: zone['metadata']?['description'],
      createdBySHOId: zone['createdBy']?['shoId'] ?? '',
      createdAt: zone['createdAt'] != null ? DateTime.parse(zone['createdAt']) : DateTime.now(),
      updatedBySHOId: zone['updatedBy']?['shoId'],
      updatedAt: zone['updatedAt'] != null ? DateTime.parse(zone['updatedAt']) : null,
      subDistricts: zone['metadata']?['subDistricts'] != null 
          ? List<String>.from(zone['metadata']['subDistricts']) 
          : null, // Extract sub-districts from metadata
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rhoId': rhoId,
      'rhoName': rhoName,
      'stateName': stateName,
      'districtName': districtName,
      'assignedAreas': assignedAreas,
      'zoneName': zoneName,
      'zoneDescription': zoneDescription,
      'createdBySHOId': createdBySHOId,
      'createdAt': createdAt.toIso8601String(),
      'updatedBySHOId': updatedBySHOId,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  int get areasCount => assignedAreas.length;
  String get formattedAreas => assignedAreas.join(', ');
  String get displayName => '$zoneName ($areasCount areas)';
}

/// Response class for zone assignment operations
class ZoneAssignmentResponse {
  final bool success;
  final String message;
  final ZoneAreaAssignment? zoneAssignment;
  final List<String> conflictingAreas;

  const ZoneAssignmentResponse({
    required this.success,
    required this.message,
    this.zoneAssignment,
    this.conflictingAreas = const [],
  });

  bool get hasConflicts => conflictingAreas.isNotEmpty;
}

/// Result class for area-specific RHO assignment
class AreaRHOAssignmentResult {
  final bool success;
  final String? message;
  final String? assignedRHOId;
  final String? assignedRHOName;
  final String? zoneName;
  final String? zoneDescription;
  final String? assignmentId;

  const AreaRHOAssignmentResult({
    required this.success,
    this.message,
    this.assignedRHOId,
    this.assignedRHOName,
    this.zoneName,
    this.zoneDescription,
    this.assignmentId,
  });

  bool get hasAssignment => assignedRHOId != null && assignedRHOId!.isNotEmpty;
  
  String get displayText {
    if (!success) return message ?? 'No assignment found';
    if (!hasAssignment) return 'No RHO assigned to this area';
    return 'Assigned to: $assignedRHOName (Zone: $zoneName)';
  }
}