import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'app_constants.dart';

class ConnectionTestService {
  
  /// Test basic connectivity to the backend server
  static Future<Map<String, dynamic>> testConnection() async {
    final baseUrl = AppConstants.apiBaseUrl;
    // Remove /api from base URL for health check since health endpoint is at root
    final healthUrl = baseUrl.replaceAll('/api', '');
    
    print('=== CONNECTION TEST ===');
    print('Testing connection to: $healthUrl/health');
    print('Platform: ${Platform.operatingSystem}');
    print('Is Web: $kIsWeb');
    print('=======================');
    
    try {
      // Test basic connectivity with enhanced timeout and retry
      final response = await http.get(
        Uri.parse('$healthUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 30)); // Increased timeout for mobile networks
      
      print('Connection test response: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Backend connection successful! 🎉',
          'endpoint': '$healthUrl/health',
          'statusCode': response.statusCode,
          'response': response.body,
          'latency': 'Connected within 30 seconds',
        };
      } else {
        return {
          'success': false,
          'message': 'Backend responded with status ${response.statusCode}',
          'endpoint': '$healthUrl/health',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('Connection test error: $e');
      
      String errorMessage = 'Connection failed: $e';
      String troubleshooting = '';
      
      // Provide specific guidance based on error type
      if (e.toString().contains('Connection refused')) {
        errorMessage = '❌ Backend server not running or not accessible';
        troubleshooting = '1. Check if backend server is running\n2. Run: npm start in backend folder';
      } else if (e.toString().contains('No route to host')) {
        errorMessage = '❌ Network unreachable - IP address issue';
        troubleshooting = '1. Verify IP address in debug_config.dart\n2. Check if phone and computer are on same WiFi';
      } else if (e.toString().contains('TimeoutException') || e.toString().contains('timed out')) {
        errorMessage = '❌ Connection timeout - Network/Firewall issue';
        troubleshooting = '1. Run setup_firewall.bat as Administrator\n2. Check WiFi router AP Isolation settings\n3. Try accessing http://10.123.62.47:3000/health from phone browser';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = '❌ Network socket error - Connectivity issue';
        troubleshooting = '1. Check Windows Firewall settings\n2. Verify same WiFi network\n3. Try alternative IP address';
      }
      
      return {
        'success': false,
        'message': errorMessage,
        'endpoint': '$healthUrl/health',
        'error': e.toString(),
        'troubleshooting': troubleshooting,
      };
    }
  }
  
  /// Test login endpoint specifically
  static Future<Map<String, dynamic>> testLoginEndpoint() async {
    final baseUrl = AppConstants.apiBaseUrl;
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/roles/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': 'test',
          'password': 'test',
        }),
      ).timeout(Duration(seconds: 10));
      
      return {
        'success': true,
        'message': 'Login endpoint reachable (expected auth failure)',
        'endpoint': '$baseUrl/roles/login',
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Login endpoint unreachable: $e',
        'endpoint': '$baseUrl/roles/login',
        'error': e.toString(),
      };
    }
  }
  
  /// Test registration endpoint specifically
  static Future<Map<String, dynamic>> testRegistrationEndpoint() async {
    final baseUrl = AppConstants.apiBaseUrl;
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/patient'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': 'Test',
          'lastName': 'User',
          'email': 'test@test.com',
          'password': 'test123',
          'phone': '1234567890',
        }),
      ).timeout(Duration(seconds: 10));
      
      return {
        'success': true,
        'message': 'Registration endpoint reachable (expected validation error)',
        'endpoint': '$baseUrl/auth/register/patient',
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration endpoint unreachable: $e',
        'endpoint': '$baseUrl/auth/register/patient',
        'error': e.toString(),
      };
    }
  }
  
  /// Run all connection tests
  static Future<Map<String, dynamic>> runAllTests() async {
    final results = <String, dynamic>{};
    
    print('Running comprehensive connection tests...');
    
    results['basic'] = await testConnection();
    results['login'] = await testLoginEndpoint();
    results['registration'] = await testRegistrationEndpoint();
    
    final allSuccessful = results.values.every((test) => test['success'] == true);
    
    results['overall'] = {
      'success': allSuccessful,
      'message': allSuccessful 
        ? 'All endpoints reachable' 
        : 'Some endpoints unreachable',
    };
    
    return results;
  }
}