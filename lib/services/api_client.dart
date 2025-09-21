import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/environment_config.dart';

/// Centralized API client that handles all HTTP requests with dynamic URL configuration
class ApiClient {
  static ApiClient? _instance;
  static ApiClient get instance => _instance ??= ApiClient._();

  ApiClient._();

  /// Get the current base URL from ConfigurationManager
  String get baseUrl => EnvironmentConfig.getApiBaseUrl();

  /// Default headers for all requests
  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Get authentication headers including token if available
  Future<Map<String, String>> _getAuthHeaders() async {
    final headers = Map<String, String>.from(_defaultHeaders);
    final token = await _getAuthToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Get stored authentication token
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Set authentication token
  static Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  /// Clear authentication token
  static Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  /// Generic GET request
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final requestHeaders = await _getAuthHeaders();
    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    print('🌐 GET: $url');

    try {
      final response = await http
          .get(url, headers: requestHeaders)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout after 30 seconds. Please check your connection.',
              );
            },
          );

      _logResponse('GET', url.toString(), response);
      return response;
    } catch (e) {
      print('❌ GET Error: $e');
      rethrow;
    }
  }

  /// Generic POST request
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final requestHeaders = await _getAuthHeaders();
    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    print('🌐 POST: $url');
    if (body != null) {
      print('📤 Body: ${jsonEncode(body)}');
    }

    try {
      final response = await http
          .post(
            url,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout after 30 seconds. Please check your connection.',
              );
            },
          );

      _logResponse('POST', url.toString(), response);
      return response;
    } catch (e) {
      print('❌ POST Error: $e');
      rethrow;
    }
  }

  /// Generic PUT request
  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final requestHeaders = await _getAuthHeaders();
    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    print('🌐 PUT: $url');

    try {
      final response = await http
          .put(
            url,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout after 30 seconds. Please check your connection.',
              );
            },
          );

      _logResponse('PUT', url.toString(), response);
      return response;
    } catch (e) {
      print('❌ PUT Error: $e');
      rethrow;
    }
  }

  /// Generic DELETE request
  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final requestHeaders = await _getAuthHeaders();
    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    print('🌐 DELETE: $url');

    try {
      final response = await http
          .delete(url, headers: requestHeaders)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout after 30 seconds. Please check your connection.',
              );
            },
          );

      _logResponse('DELETE', url.toString(), response);
      return response;
    } catch (e) {
      print('❌ DELETE Error: $e');
      rethrow;
    }
  }

  /// Health check endpoint
  Future<bool> healthCheck() async {
    try {
      final response = await get('/health');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Health check failed: $e');
      return false;
    }
  }

  /// Login request with proper error handling
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await post(
        '/roles/login',
        body: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Store the token if provided
        if (data['token'] != null) {
          await setAuthToken(data['token']);
        }

        return data;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }

  /// Generic response parsing with error handling
  Map<String, dynamic> parseResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
        errorData['message'] ??
            'Request failed with status ${response.statusCode}',
      );
    }
  }

  /// Log response for debugging
  void _logResponse(String method, String url, http.Response response) {
    final statusEmoji = response.statusCode < 300 ? '✅' : '❌';
    print('$statusEmoji $method ${response.statusCode}: ${url}');

    if (response.statusCode >= 400) {
      print('📥 Error Response: ${response.body}');
    }
  }

  /// Get current configuration info for debugging
  Map<String, dynamic> getConfigInfo() {
    return {
      'baseUrl': baseUrl,
      'currentMode': EnvironmentConfig.currentMode.displayName,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
