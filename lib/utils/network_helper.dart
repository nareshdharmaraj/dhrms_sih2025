import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_constants.dart';

class NetworkHelper {
  /// Enhanced HTTP request with retry logic and longer timeouts for mobile networks
  static Future<http.Response> postWithRetry({
    required String endpoint,
    required Map<String, dynamic> body,
    int maxRetries = 3,
    int timeoutSeconds = 30,
  }) async {
    Exception lastException = Exception('Unknown error');
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print('=== HTTP Request Attempt $attempt/$maxRetries ===');
        print('Endpoint: $endpoint');
        print('Timeout: ${timeoutSeconds}s');
        
        final response = await http.post(
          Uri.parse(endpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        ).timeout(
          Duration(seconds: timeoutSeconds),
          onTimeout: () {
            throw Exception('Request timed out after $timeoutSeconds seconds (attempt $attempt/$maxRetries)');
          },
        );
        
        print('Response status: ${response.statusCode}');
        return response; // Success, return immediately
        
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        print('Attempt $attempt failed: $e');
        
        if (attempt < maxRetries) {
          // Wait before retrying (exponential backoff)
          int delaySeconds = attempt * 2; // 2s, 4s, 6s...
          print('Retrying in ${delaySeconds}s...');
          await Future.delayed(Duration(seconds: delaySeconds));
        }
      }
    }
    
    // All attempts failed
    throw lastException;
  }
  
  /// Enhanced GET request with retry logic
  static Future<http.Response> getWithRetry({
    required String endpoint,
    int maxRetries = 3,
    int timeoutSeconds = 30,
  }) async {
    Exception lastException = Exception('Unknown error');
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print('=== HTTP GET Attempt $attempt/$maxRetries ===');
        print('Endpoint: $endpoint');
        
        final response = await http.get(
          Uri.parse(endpoint),
          headers: {'Content-Type': 'application/json'},
        ).timeout(
          Duration(seconds: timeoutSeconds),
          onTimeout: () {
            throw Exception('Request timed out after $timeoutSeconds seconds (attempt $attempt/$maxRetries)');
          },
        );
        
        print('Response status: ${response.statusCode}');
        return response; // Success
        
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        print('Attempt $attempt failed: $e');
        
        if (attempt < maxRetries) {
          int delaySeconds = attempt * 2;
          print('Retrying in ${delaySeconds}s...');
          await Future.delayed(Duration(seconds: delaySeconds));
        }
      }
    }
    
    throw lastException;
  }
  
  /// Test network connectivity to backend
  static Future<bool> testConnectivity() async {
    try {
      final healthUrl = AppConstants.apiBaseUrl.replaceAll('/api', '');
      final response = await getWithRetry(
        endpoint: '$healthUrl/health',
        maxRetries: 2,
        timeoutSeconds: 15,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Connectivity test failed: $e');
      return false;
    }
  }
}