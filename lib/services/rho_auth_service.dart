import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/regional_health_officer.dart';
import 'api_service.dart';

class RHOAuthService {
  static String get _baseUrl => '${ApiService.baseUrl}/auth';
  
  /// Make authenticated request with RHO token
  static Future<Map<String, dynamic>> makeAuthenticatedRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found'
        };
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final uri = Uri.parse('${ApiService.baseUrl}$endpoint');
      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          return {
            'success': false,
            'message': 'Unsupported HTTP method: $method'
          };
      }

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}'
      };
    }
  }
  
  /// Authenticate RHO with credentials
  static Future<Map<String, dynamic>> login({
    required String officerIdOrEmail,
    required String password,
    String? state,
  }) async {
    try {
      print('🔐 RHO Login attempt for: $officerIdOrEmail');
      
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/rho/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'rhoId': officerIdOrEmail,
          'password': password,
          'state': state,
        }),
      );

      print('🔐 Login response status: ${response.statusCode}');
      print('🔐 Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final rhoData = data['rho'];  // Backend sends 'rho' not 'user'
          final token = data['token'];
          
          // Verify RHO data exists
          if (rhoData != null) {
            // Store authentication data
            await _storeAuthData(token, rhoData);
            
            // Create RHO object from rho data
            final rho = RegionalHealthOfficer.fromJson(rhoData);
            
            return {
              'success': true,
              'rho': rho,
              'token': token,
              'message': 'Login successful',
            };
          } else {
            return {
              'success': false,
              'message': 'Invalid response format from server',
            };
          }
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Login failed',
          };
        }
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Authentication failed',
        };
      }
    } catch (e) {
      print('❌ RHO Login error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
  
  /// Store authentication data locally
  static Future<void> _storeAuthData(String token, Map<String, dynamic> rhoData) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('auth_token', token);
    await prefs.setString('user_type', 'RHO');
    await prefs.setString('rho_data', json.encode(rhoData));
    await prefs.setString('officer_id', rhoData['rhoId'] ?? '');  // Backend sends 'rhoId'
    await prefs.setString('full_name', rhoData['fullName'] ?? '');
    await prefs.setString('email', rhoData['email'] ?? '');
    await prefs.setBool('is_logged_in', true);
  }
  
  /// Get stored RHO data
  static Future<RegionalHealthOfficer?> getStoredRHOData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rhoDataString = prefs.getString('rho_data');
      
      if (rhoDataString != null) {
        final rhoData = json.decode(rhoDataString);
        return RegionalHealthOfficer.fromJson(rhoData);
      }
      
      return null;
    } catch (e) {
      print('❌ Error retrieving stored RHO data: $e');
      return null;
    }
  }
  
  /// Check if user is logged in as RHO
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final userType = prefs.getString('user_type');
    final token = prefs.getString('auth_token');
    
    return isLoggedIn && userType == 'RHO' && token != null;
  }
  
  /// Get stored authentication token
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  /// Logout RHO and clear stored data
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Clear all RHO-related data
    await prefs.remove('auth_token');
    await prefs.remove('user_type');
    await prefs.remove('rho_data');
    await prefs.remove('officer_id');
    await prefs.remove('full_name');
    await prefs.remove('email');
    await prefs.setBool('is_logged_in', false);
  }
  
  /// Validate token with server
  static Future<bool> validateToken() async {
    try {
      final token = await getAuthToken();
      if (token == null) return false;
      
      final response = await http.get(
        Uri.parse('$_baseUrl/validate'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Token validation error: $e');
      return false;
    }
  }
  
  /// Refresh authentication token
  static Future<Map<String, dynamic>> refreshToken() async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No token to refresh',
        };
      }
      
      final response = await http.post(
        Uri.parse('$_baseUrl/refresh'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newToken = data['token'];
        
        // Update stored token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', newToken);
        
        return {
          'success': true,
          'token': newToken,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to refresh token',
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