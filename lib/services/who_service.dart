import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/who_admin.dart';
import '../utils/environment_config.dart';

class WhoService {
  static String? _authToken;
  
  static Future<String> getApiBaseUrl() async {
    return EnvironmentConfig.getApiBaseUrl();
  }

  static void setAuthToken(String token) {
    _authToken = token;
    print('🔍 WHO Service - Auth token set: ${token.substring(0, 20)}...');
  }

  static String? getAuthToken() {
    return _authToken;
  }

  static Map<String, String> _getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
  }

  // WHO Authentication
  static Future<Map<String, dynamic>> whoLogin({
    required String adminId,
    required String password,
  }) async {
    try {
      final apiBaseUrl = await getApiBaseUrl();
      print('🔍 WHO Service - API Base URL: $apiBaseUrl');
      
      final requestBody = {
        'adminId': adminId,
        'password': password,
      };
      print('🔍 WHO Service - Request body: $requestBody');
      
      final response = await http.post(
        Uri.parse('$apiBaseUrl/who/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('🔍 WHO Service - Response status: ${response.statusCode}');
      print('🔍 WHO Service - Response body: ${response.body}');

      final data = json.decode(response.body);
      print('🔍 WHO Service - Parsed data: $data');
      
      if (response.statusCode == 200 && data['success']) {
        // Store the auth token for future requests
        if (data['token'] != null) {
          setAuthToken(data['token']);
        }
        
        final result = {
          'success': true,
          'admin': data['admin'], // Return raw admin data
          'token': data['token'],
          'message': data['message'] ?? 'Login successful',
        };
        print('🔍 WHO Service - Returning success result: $result');
        return result;
      } else {
        final result = {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
        print('🔍 WHO Service - Returning failure result: $result');
        return result;
      }
    } catch (e) {
      print('WHO Login error: $e');
      final result = {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
      print('🔍 WHO Service - Returning error result: $result');
      return result;
    }
  }

  // Get WHO Dashboard Statistics
  static Future<Map<String, dynamic>> getDashboardStatistics() async {
    try {
      final apiBaseUrl = await getApiBaseUrl();
      print('🔍 WHO Service - Getting dashboard stats from: $apiBaseUrl/who/dashboard/stats');
      print('🔍 WHO Service - Auth token available: ${_authToken != null}');
      
      final response = await http.get(
        Uri.parse('$apiBaseUrl/who/dashboard/stats'),
        headers: _getAuthHeaders(),
      );

      print('🔍 WHO Service - Dashboard response status: ${response.statusCode}');
      print('🔍 WHO Service - Dashboard response body: ${response.body}');

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'statistics': data['statistics'] ?? {},
          'stateStats': (data['stateStats'] as List? ?? [])
              .map((stat) => StateStatistics.fromJson(stat))
              .toList(),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch statistics',
        };
      }
    } catch (e) {
      print('Dashboard statistics error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get All States Statistics
  static Future<Map<String, dynamic>> getAllStatesStatistics() async {
    try {
      final apiBaseUrl = await getApiBaseUrl();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/who/states-statistics'),
        headers: _getAuthHeaders(),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'stateStats': (data['stateStats'] as List)
              .map((stat) => StateStatistics.fromJson(stat))
              .toList(),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch state statistics',
        };
      }
    } catch (e) {
      print('State statistics error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get All Hospitals Overview
  static Future<Map<String, dynamic>> getAllHospitals({String? state}) async {
    try {
      final apiBaseUrl = await getApiBaseUrl();
      final uri = state != null 
          ? Uri.parse('$apiBaseUrl/who/hospitals?state=$state')
          : Uri.parse('$apiBaseUrl/who/hospitals');
          
      final response = await http.get(
        uri,
        headers: _getAuthHeaders(),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'hospitals': (data['hospitals'] as List)
              .map((hospital) => HospitalOverview.fromJson(hospital))
              .toList(),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch hospitals',
        };
      }
    } catch (e) {
      print('Hospitals fetch error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Regional Officer Management
  static Future<Map<String, dynamic>> getAllRegionalOfficers({String? state}) async {
    try {
      final apiBaseUrl = await getApiBaseUrl();
      final uri = state != null 
          ? Uri.parse('$apiBaseUrl/who/regional-officers?state=$state')
          : Uri.parse('$apiBaseUrl/who/regional-officers');
          
      final response = await http.get(
        uri,
        headers: _getAuthHeaders(),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'officers': data['officers'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch regional officers',
        };
      }
    } catch (e) {
      print('Regional officers fetch error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Add Regional Officer
  static Future<Map<String, dynamic>> addRegionalOfficer({
    required String officerId,
    required String fullName,
    required String email,
    required String phone,
    required String state,
    required String designation,
    required String password,
  }) async {
    try {
      final apiBaseUrl = await getApiBaseUrl();
      final response = await http.post(
        Uri.parse('$apiBaseUrl/who/regional-officers'),
        headers: _getAuthHeaders(),
        body: json.encode({
          'officerId': officerId,
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'state': state,
          'designation': designation,
          'password': password,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 201 && data['success']) {
        return {
          'success': true,
          'officer': data['officer'],
          'message': data['message'] ?? 'Regional officer added successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to add regional officer',
        };
      }
    } catch (e) {
      print('Add regional officer error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Update Regional Officer
  static Future<Map<String, dynamic>> updateRegionalOfficer({
    required String officerId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final apiBaseUrl = await getApiBaseUrl();
      final response = await http.put(
        Uri.parse('$apiBaseUrl/who/regional-officers/$officerId'),
        headers: _getAuthHeaders(),
        body: json.encode(updates),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'officer': data['officer'],
          'message': data['message'] ?? 'Regional officer updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update regional officer',
        };
      }
    } catch (e) {
      print('Update regional officer error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Deactivate Regional Officer
  static Future<Map<String, dynamic>> deactivateRegionalOfficer(String officerId) async {
    try {
      final apiBaseUrl = await getApiBaseUrl();
      final response = await http.patch(
        Uri.parse('$apiBaseUrl/who/regional-officers/$officerId/deactivate'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'message': data['message'] ?? 'Regional officer deactivated successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to deactivate regional officer',
        };
      }
    } catch (e) {
      print('Deactivate regional officer error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Export Data
  static Future<Map<String, dynamic>> exportStateData({
    required String state,
    required String format, // 'csv', 'pdf', 'excel'
  }) async {
    try {
      final apiBaseUrl = await getApiBaseUrl();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/who/export/$state?format=$format'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'downloadUrl': data['downloadUrl'],
          'fileName': data['fileName'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to export data',
        };
      }
    } catch (e) {
      print('Export data error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get Hospital Details
  static Future<Map<String, dynamic>> getHospitalDetails(String hospitalId) async {
    try {
      final apiBaseUrl = await getApiBaseUrl();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/who/hospitals/$hospitalId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'hospital': data['hospital'],
          'statistics': data['statistics'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch hospital details',
        };
      }
    } catch (e) {
      print('Hospital details error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}