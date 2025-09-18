import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_constants.dart';

class ApiService {
  // Use dynamic base URL from AppConstants
  static String get baseUrl => AppConstants.apiBaseUrl;
  
  // Universal login method - works for all roles (Patient, Hospital Staff, Regional Officer)
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/roles/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(
        Duration(seconds: 30), // Increased timeout for mobile networks
        onTimeout: () {
          throw Exception('Login request timed out after 30 seconds. Please check your internet connection.');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 401) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  // Get all patients
  static Future<Map<String, dynamic>> getAllPatients() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/roles/patients'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  // Get all hospital staff
  static Future<Map<String, dynamic>> getAllHospitalStaff() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/roles/hospital-staff'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  // Get all regional officers
  static Future<Map<String, dynamic>> getAllRegionalOfficers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/roles/regional-officers'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  // Search user by username
  static Future<Map<String, dynamic>> searchUser(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/roles/search/$username'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 404) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  // Get database statistics
  static Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/roles/stats'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  // Register Patient with UHI generation
  static Future<Map<String, dynamic>> registerPatient({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String aadhaarNumber,
    required String dateOfBirth,
    required String gender,
    required Map<String, String> address,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/patient'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'phone': phone,
          'aadhaarNumber': aadhaarNumber,
          'dateOfBirth': dateOfBirth,
          'gender': gender.toLowerCase(),
          'address': address,
        }),
      );

      return {
        'success': response.statusCode == 201,
        'statusCode': response.statusCode,
        'data': jsonDecode(response.body),
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'data': {
          'message': 'Network error: $e',
        },
      };
    }
  }

  // Register Hospital Staff with UHI generation
  static Future<Map<String, dynamic>> registerHospitalStaff({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String aadhaarNumber,
    required String dateOfBirth,
    required String gender,
    required String staffRole,
    required String department,
    required String hospitalName,
    required Map<String, String> hospitalAddress,
    String? specialization,
    String? licenseNumber,
    int? yearsOfExperience,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/hospital-staff'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'phone': phone,
          'aadhaarNumber': aadhaarNumber,
          'dateOfBirth': dateOfBirth,
          'gender': gender.toLowerCase(),
          'staffRole': staffRole,
          'department': department,
          'hospitalName': hospitalName,
          'hospitalAddress': hospitalAddress,
          if (specialization != null) 'specialization': specialization,
          if (licenseNumber != null) 'licenseNumber': licenseNumber,
          if (yearsOfExperience != null) 'yearsOfExperience': yearsOfExperience,
        }),
      );

      return {
        'success': response.statusCode == 201,
        'statusCode': response.statusCode,
        'data': jsonDecode(response.body),
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'data': {
          'message': 'Network error: $e',
        },
      };
    }
  }

  // Register Regional Officer with UHI generation
  static Future<Map<String, dynamic>> registerRegionalOfficer({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String aadhaarNumber,
    required String dateOfBirth,
    required String gender,
    required String officerRank,
    required String employeeId,
    required String department,
    Map<String, dynamic>? jurisdiction,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/regional-officer'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'phone': phone,
          'aadhaarNumber': aadhaarNumber,
          'dateOfBirth': dateOfBirth,
          'gender': gender.toLowerCase(),
          'officerRank': officerRank,
          'employeeId': employeeId,
          'department': department,
          if (jurisdiction != null) 'jurisdiction': jurisdiction,
        }),
      );

      return {
        'success': response.statusCode == 201,
        'statusCode': response.statusCode,
        'data': jsonDecode(response.body),
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'data': {
          'message': 'Network error: $e',
        },
      };
    }
  }
}
