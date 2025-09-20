import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/environment_config.dart';
import 'who_service.dart';

class SHOService {
  // Use WHO Service's auth token instead of maintaining separate token
  static Future<String> getApiBaseUrl() async {
    return await EnvironmentConfig.getApiBaseUrl();
  }

  static Map<String, String> _getAuthHeaders() {
    final token = WhoService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get all SHOs
  static Future<Map<String, dynamic>> getAllSHOs({
    String? state,
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final apiBaseUrl = await getApiBaseUrl();
      final token = WhoService.getAuthToken();
      
      print('🔍 SHO Service - API Base URL: $apiBaseUrl');
      print('🔍 SHO Service - Auth token available: ${token != null}');
      if (token != null) {
        print('🔍 SHO Service - Token preview: ${token.substring(0, 20)}...');
      }
      
      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (state != null) queryParams['state'] = state;
      if (status != null) queryParams['status'] = status;
      
      final uri = Uri.parse('$apiBaseUrl/sho').replace(queryParameters: queryParams);
      print('🔍 SHO Service - Request URI: $uri');
      
      final response = await http.get(uri, headers: _getAuthHeaders());
      print('🔍 SHO Service - Response status: ${response.statusCode}');
      print('🔍 SHO Service - Response body: ${response.body}');
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'shos': data['shos'] ?? [],
          'pagination': data['pagination'] ?? {},
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch SHOs',
        };
      }
    } catch (e) {
      print('Get all SHOs error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get SHO statistics
  static Future<Map<String, dynamic>> getSHOStatistics() async {
    try {
      final apiBaseUrl = await getApiBaseUrl();
      final token = WhoService.getAuthToken();
      
      print('🔍 SHO Service - Statistics API Base URL: $apiBaseUrl');
      print('🔍 SHO Service - Statistics Auth token available: ${token != null}');
      
      final response = await http.get(
        Uri.parse('$apiBaseUrl/sho/statistics'),
        headers: _getAuthHeaders(),
      );

      print('🔍 SHO Service - Statistics Response status: ${response.statusCode}');
      print('🔍 SHO Service - Statistics Response body: ${response.body}');

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'statistics': data['statistics'] ?? {},
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch SHO statistics',
        };
      }
    } catch (e) {
      print('Get SHO statistics error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Create new SHO
  static Future<Map<String, dynamic>> createSHO({
    required String officerId,
    required String fullName,
    required String email,
    required String phone,
    required String assignedState,
    required String password,
    Map<String, dynamic>? permissions,
  }) async {
    try {
      final apiBaseUrl = await getApiBaseUrl();
      
      final requestBody = {
        'officerId': officerId,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'assignedState': assignedState,
        'password': password,
        if (permissions != null) 'permissions': permissions,
      };
      
      print('🚀 SHO Service - Creating SHO with request body:');
      print('API URL: $apiBaseUrl/sho');
      print('Request Body: $requestBody');
      print('Headers: ${_getAuthHeaders()}');
      
      final response = await http.post(
        Uri.parse('$apiBaseUrl/sho'),
        headers: _getAuthHeaders(),
        body: json.encode(requestBody),
      );

      print('🚀 SHO Service - Response Status: ${response.statusCode}');
      print('🚀 SHO Service - Response Body: ${response.body}');

      final data = json.decode(response.body);
      
      if (response.statusCode == 201 && data['success']) {
        return {
          'success': true,
          'sho': data['sho'],
          'message': data['message'] ?? 'SHO created successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create SHO',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      print('Create SHO error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Update SHO
  static Future<Map<String, dynamic>> updateSHO({
    required String shoId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final apiBaseUrl = await getApiBaseUrl();
      final response = await http.put(
        Uri.parse('$apiBaseUrl/sho/$shoId'),
        headers: _getAuthHeaders(),
        body: json.encode(updates),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'sho': data['sho'],
          'message': data['message'] ?? 'SHO updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update SHO',
        };
      }
    } catch (e) {
      print('Update SHO error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Deactivate SHO
  static Future<Map<String, dynamic>> deactivateSHO(String shoId) async {
    try {
      final apiBaseUrl = await getApiBaseUrl();
      final url = '$apiBaseUrl/sho/$shoId/deactivate';
      
      print('🔴 Deactivating SHO:');
      print('  URL: $url');
      print('  SHO ID: $shoId');
      
      final response = await http.patch(
        Uri.parse(url),
        headers: _getAuthHeaders(),
      );

      print('  Response Status: ${response.statusCode}');
      print('  Response Body: ${response.body}');

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        print('  ✅ Deactivation successful');
        return {
          'success': true,
          'message': data['message'] ?? 'SHO deactivated successfully',
        };
      } else {
        print('  ❌ Deactivation failed: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to deactivate SHO',
        };
      }
    } catch (e) {
      print('Deactivate SHO error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Activate SHO
  static Future<Map<String, dynamic>> activateSHO(String shoId) async {
    try {
      final apiBaseUrl = await getApiBaseUrl();
      final url = '$apiBaseUrl/sho/$shoId/activate';
      
      print('🟢 Activating SHO:');
      print('  URL: $url');
      print('  SHO ID: $shoId');
      
      final response = await http.patch(
        Uri.parse(url),
        headers: _getAuthHeaders(),
      );

      print('  Response Status: ${response.statusCode}');
      print('  Response Body: ${response.body}');

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        print('  ✅ Activation successful');
        return {
          'success': true,
          'message': data['message'] ?? 'SHO activated successfully',
        };
      } else {
        print('  ❌ Activation failed: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to activate SHO',
        };
      }
    } catch (e) {
      print('Activate SHO error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Change SHO password
  static Future<Map<String, dynamic>> changeSHOPassword({
    required String shoId,
    required String newPassword,
  }) async {
    try {
      final apiBaseUrl = await getApiBaseUrl();
      final response = await http.patch(
        Uri.parse('$apiBaseUrl/sho/$shoId/change-password'),
        headers: _getAuthHeaders(),
        body: json.encode({'newPassword': newPassword}),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'message': data['message'] ?? 'Password changed successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to change password',
        };
      }
    } catch (e) {
      print('Change SHO password error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Update SHO Status (activate/deactivate)
  static Future<Map<String, dynamic>> updateSHOStatus(String shoId, bool isActive) async {
    try {
      print('🔄 SHO Service - Updating SHO status:');
      print('  SHO ID: $shoId');
      print('  New Status: ${isActive ? 'ACTIVE' : 'INACTIVE'}');
      
      Map<String, dynamic> result;
      if (isActive) {
        print('  Calling activateSHO...');
        result = await activateSHO(shoId);
      } else {
        print('  Calling deactivateSHO...');
        result = await deactivateSHO(shoId);
      }
      
      print('  Result: ${result['success'] ? 'SUCCESS' : 'FAILED'}');
      if (!result['success']) {
        print('  Error: ${result['message']}');
      }
      
      return result;
    } catch (e) {
      print('Update SHO status error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Reset Password (accepts custom password or generates random one)
  static Future<Map<String, dynamic>> resetPassword(String shoId, {String? customPassword}) async {
    try {
      final apiBaseUrl = await getApiBaseUrl();
      
      // Prepare request body
      Map<String, dynamic> requestBody = {};
      if (customPassword != null && customPassword.isNotEmpty) {
        requestBody['newPassword'] = customPassword;
      }
      
      print('🔄 Resetting SHO password:');
      print('  SHO ID: $shoId');
      print('  Custom password provided: ${customPassword != null && customPassword.isNotEmpty}');
      
      final headers = _getAuthHeaders();
      
      final response = await http.patch(
        Uri.parse('$apiBaseUrl/sho/$shoId/reset-password'),
        headers: headers,
        body: requestBody.isNotEmpty ? json.encode(requestBody) : null,
      );

      print('  Response Status: ${response.statusCode}');
      
      if (response.body.isNotEmpty) {
        final data = json.decode(response.body);
        print('  Response Success: ${data['success']}');
        
        if (response.statusCode == 200 && data['success']) {
          return {
            'success': true,
            'data': data['data'],
            'message': data['message'] ?? 'Password reset successfully',
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to reset password',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server returned empty response',
        };
      }
    } catch (e) {
      print('Reset password error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}

// Separate class for SHO authentication (independent from WHO admin management)
class ShoService {
  static String? _authToken;
  
  static Future<String> getApiBaseUrl() async {
    return await EnvironmentConfig.getApiBaseUrl();
  }

  static void setAuthToken(String token) {
    _authToken = token;
    print('🔍 SHO Auth Service - Auth token set: ${token.substring(0, 20)}...');
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

  // SHO Authentication
  static Future<Map<String, dynamic>> shoLogin({
    required String username,
    required String password,
  }) async {
    try {
      final apiBaseUrl = await getApiBaseUrl();
      print('🔍 SHO Auth Service - API Base URL: $apiBaseUrl');
      
      final requestBody = {
        'username': username,
        'password': password,
      };
      print('🔍 SHO Auth Service - Request body: $requestBody');
      
      final response = await http.post(
        Uri.parse('$apiBaseUrl/sho-auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('🔍 SHO Auth Service - Response status: ${response.statusCode}');
      print('🔍 SHO Auth Service - Response body: ${response.body}');

      final data = json.decode(response.body);
      print('🔍 SHO Auth Service - Parsed data: $data');
      
      if (response.statusCode == 200 && data['success']) {
        // Store the auth token for future requests
        if (data['token'] != null) {
          setAuthToken(data['token']);
        }
        
        final result = {
          'success': true,
          'sho': data['sho'], // Return raw SHO data
          'token': data['token'],
          'message': data['message'] ?? 'Login successful',
        };
        print('🔍 SHO Auth Service - Returning success result: $result');
        return result;
      } else {
        final result = {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
        print('🔍 SHO Auth Service - Returning failure result: $result');
        return result;
      }
    } catch (e) {
      print('SHO Login error: $e');
      final result = {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
      print('🔍 SHO Auth Service - Returning error result: $result');
      return result;
    }
  }

  // Get SHO Dashboard Data
  static Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final apiBaseUrl = await getApiBaseUrl();
      print('🔍 SHO Auth Service - Getting dashboard data from: $apiBaseUrl/sho-auth/dashboard');
      print('🔍 SHO Auth Service - Auth token available: ${_authToken != null}');
      
      final response = await http.get(
        Uri.parse('$apiBaseUrl/sho-auth/dashboard'),
        headers: _getAuthHeaders(),
      );

      print('🔍 SHO Auth Service - Dashboard response status: ${response.statusCode}');
      print('🔍 SHO Auth Service - Dashboard response body: ${response.body}');

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to load dashboard data',
        };
      }
    } catch (e) {
      print('SHO Dashboard error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Logout
  static Future<Map<String, dynamic>> logout() async {
    try {
      final apiBaseUrl = await getApiBaseUrl();
      
      final response = await http.post(
        Uri.parse('$apiBaseUrl/sho-auth/logout'),
        headers: _getAuthHeaders(),
      );

      print('🔍 SHO Auth Service - Logout response status: ${response.statusCode}');
      
      // Clear the auth token regardless of response
      _authToken = null;
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'message': data['message'] ?? 'Logout successful',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Logout failed',
        };
      }
    } catch (e) {
      print('SHO Logout error: $e');
      // Clear token even on error
      _authToken = null;
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Clear auth token (for local logout)
  static void clearAuthToken() {
    _authToken = null;
    print('🔍 SHO Auth Service - Auth token cleared');
  }
}