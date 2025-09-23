import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/regional_health_officer.dart';
import 'api_service.dart';

class RegionalHealthOfficerService {
  static String get _baseUrl => '${ApiService.baseUrl}/rho';

  // Get district assignment info with area options
  static Future<Map<String, dynamic>> getDistrictAssignmentInfo(
      String authToken, String district) async {
    try {
      print('🔍 Fetching assignment info for district: $district');
      final response = await http.get(
        Uri.parse('$_baseUrl/districts/$district/assignment-info'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      print('🔍 Assignment info response status: ${response.statusCode}');
      print('🔍 Assignment info response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Backend returns flat structure, not wrapped in 'data' field
        // The response structure is: { success, district, state, type, requiresAreaSelection, availableAreas, ... }
        return {
          'success': true,
          'data': data,  // Pass the entire response as data
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to fetch district assignment info',
        };
      }
    } catch (e) {
      print('❌ Assignment info error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get area coverage details for a specific area
  static Future<Map<String, dynamic>> getAreaCoverageDetails(
      String authToken, String district, String areaName) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/districts/$district/areas/$areaName'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to fetch area coverage details',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get available districts for RHO assignment
  static Future<Map<String, dynamic>> getAvailableDistricts(String authToken) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/districts'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Check if data field exists
        if (!data.containsKey('data')) {
          return {
            'success': false,
            'message': 'Invalid districts response format: missing data field',
          };
        }
        
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to fetch districts',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get mock RHO data for creation
  static Future<Map<String, dynamic>> getMockRHOData(String authToken) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/mock-data'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to fetch mock data',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Create Regional Health Officer
  static Future<Map<String, dynamic>> createRHO(
      String authToken, Map<String, dynamic> rhoData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/create'), // Updated endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode(rhoData),
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to create Regional Health Officer',
          'errors': errorData['errors'] ?? [],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Create RHO from mock data
  static Future<Map<String, dynamic>> createRHOFromMockData(
      String authToken, int mockRHOIndex) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/create-from-mock'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({'mockRHOIndex': mockRHOIndex}),
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to create RHO from mock data',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get all RHOs for a SHO
  static Future<Map<String, dynamic>> getRHOs(String authToken) async {
    try {
      print('🔍 Fetching RHOs from backend...');
      final response = await http.get(
        Uri.parse('$_baseUrl/'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      print('🔍 RHO fetch response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🔍 Raw response data keys: ${data.keys.toList()}');
        print('🔍 RHOs count in response: ${data['rhos']?.length ?? 0}');
        
        // The backend returns 'rhos' field, not 'data'
        if (!data.containsKey('rhos') || data['rhos'] == null || data['rhos'] is! List) {
          return {
            'success': false,
            'message': 'Invalid response format: missing or invalid rhos data',
          };
        }
        
        final List<RegionalHealthOfficer> rhos = (data['rhos'] as List)
            .map((rho) {
              print('🔍 Parsing RHO: ${rho['officerId']} - ${rho['fullName']}');
              return RegionalHealthOfficer.fromJson(rho);
            })
            .toList();

        print('🔍 Successfully parsed ${rhos.length} RHOs');
        return {
          'success': true,
          'data': rhos, // Frontend expects 'data' field
          'statistics': data['statistics'],
          'pagination': data['pagination'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to fetch Regional Health Officers',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get RHO by ID
  static Future<Map<String, dynamic>> getRHOById(
      String authToken, String rhoId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$rhoId'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rho = RegionalHealthOfficer.fromJson(data['data']);

        return {
          'success': true,
          'data': rho,
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Regional Health Officer not found',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Update RHO
  static Future<Map<String, dynamic>> updateRHO(
      String authToken, String rhoId, Map<String, dynamic> updateData) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$rhoId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rho = RegionalHealthOfficer.fromJson(data['data']);

        return {
          'success': true,
          'data': rho,
          'message': 'Regional Health Officer updated successfully',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to update Regional Health Officer',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Delete RHO
  static Future<Map<String, dynamic>> deleteRHO(
      String authToken, String rhoId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$rhoId'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Regional Health Officer deleted successfully',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to delete Regional Health Officer',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Toggle RHO status (activate/deactivate)
  static Future<Map<String, dynamic>> toggleRHOStatus(
      String authToken, String rhoId) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/$rhoId/toggle-status'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rho = RegionalHealthOfficer.fromJson(data['data']);

        return {
          'success': true,
          'data': rho,
          'message': data['message'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to toggle status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Reset RHO password
  static Future<Map<String, dynamic>> resetRHOPassword(
      String authToken, String rhoId, String newPassword) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/$rhoId/reset-password'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Password reset successfully',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to reset password',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get RHO statistics (for RHO self-access)
  static Future<Map<String, dynamic>> getRHOStatistics(String authToken) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/my/statistics'),  // Changed to self-access endpoint
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,  // The response structure is different for self-access
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to fetch statistics',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}