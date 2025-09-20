import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/regional_health_officer.dart';
import 'api_service.dart';

class RegionalHealthOfficerService {
  static String get _baseUrl => '${ApiService.baseUrl}/api/regional-health-officers';

  // Create Regional Health Officer
  static Future<Map<String, dynamic>> createRHO(
      String authToken, Map<String, dynamic> rhoData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/create'),
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
      final response = await http.get(
        Uri.parse('$_baseUrl/list'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<RegionalHealthOfficer> rhos = (data['data'] as List)
            .map((rho) => RegionalHealthOfficer.fromJson(rho))
            .toList();

        return {
          'success': true,
          'data': rhos,
          'statistics': data['statistics'],
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
      String authToken, String rhoId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$rhoId/reset-password'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'],
          'temporaryPassword': data['temporaryPassword'],
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

  // Get RHO statistics
  static Future<Map<String, dynamic>> getRHOStatistics(String authToken) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/statistics'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final statistics = RHOStatistics.fromJson(data['data']);

        return {
          'success': true,
          'data': statistics,
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

  // Regional Staff Management

  // Create regional staff
  static Future<Map<String, dynamic>> createRegionalStaff(
      String authToken, String rhoId, Map<String, dynamic> staffData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$rhoId/staff/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode(staffData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final staff = RegionalStaff.fromJson(data['data']);

        return {
          'success': true,
          'data': staff,
          'message': 'Regional staff created successfully',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to create regional staff',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get staff for an RHO
  static Future<Map<String, dynamic>> getRegionalStaff(
      String authToken, String rhoId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$rhoId/staff'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<RegionalStaff> staff = (data['data'] as List)
            .map((staffMember) => RegionalStaff.fromJson(staffMember))
            .toList();

        return {
          'success': true,
          'data': staff,
          'summary': data['summary'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to fetch regional staff',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Update regional staff
  static Future<Map<String, dynamic>> updateRegionalStaff(
      String authToken, String rhoId, String staffId, Map<String, dynamic> updateData) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$rhoId/staff/$staffId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final staff = RegionalStaff.fromJson(data['data']);

        return {
          'success': true,
          'data': staff,
          'message': 'Regional staff updated successfully',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to update regional staff',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Delete regional staff
  static Future<Map<String, dynamic>> deleteRegionalStaff(
      String authToken, String rhoId, String staffId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$rhoId/staff/$staffId'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Regional staff deleted successfully',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to delete regional staff',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Validate staff limits before creation
  static Future<Map<String, dynamic>> validateStaffLimits(
      String authToken, String rhoId, String staffType) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$rhoId/staff/validate/$staffType'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'canAdd': data['canAdd'],
          'currentCount': data['currentCount'],
          'maxLimit': data['maxLimit'],
          'message': data['message'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Validation failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get regional data overview (placeholder for future implementation)
  static Future<Map<String, dynamic>> getRegionalDataOverview(
      String authToken, String rhoId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$rhoId/data-overview'),
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
          'message': errorData['message'] ?? 'Failed to fetch regional data',
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