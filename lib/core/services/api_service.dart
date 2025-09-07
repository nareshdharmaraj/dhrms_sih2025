import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api/v1';
  static const Duration timeout = Duration(seconds: 30);

  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Instance method for authentication
  Future<Map<String, dynamic>> authenticate(
    String username,
    String password,
    String role,
  ) async {
    return await login(username, password, role);
  }

  // Health check
  static Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await http
          .get(
            Uri.parse('http://localhost:5000/health'),
            headers: defaultHeaders,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Health check failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error during health check: $e');
    }
  }

  // Authentication
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
    String role,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: defaultHeaders,
            body: json.encode({
              'username': username,
              'password': password,
              'role': role,
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error during login: $e');
    }
  }

  // Hospital APIs
  static Future<List<Map<String, dynamic>>> getHospitals() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/hospitals'), headers: defaultHeaders)
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['hospitals'] ?? []);
      } else {
        throw Exception('Failed to fetch hospitals: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error fetching hospitals: $e');
    }
  }

  static Future<Map<String, dynamic>> getHospitalById(String hospitalId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/hospitals/$hospitalId'),
            headers: defaultHeaders,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch hospital: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error fetching hospital: $e');
    }
  }

  // Doctor APIs
  static Future<List<Map<String, dynamic>>> getDoctors() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/doctors'), headers: defaultHeaders)
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['doctors'] ?? []);
      } else {
        throw Exception('Failed to fetch doctors: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error fetching doctors: $e');
    }
  }

  static Future<Map<String, dynamic>> getDoctorById(String doctorId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/doctors/$doctorId'), headers: defaultHeaders)
          .timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch doctor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error fetching doctor: $e');
    }
  }

  static Future<Map<String, dynamic>> createDoctor(
    Map<String, dynamic> doctorData,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/doctors'),
            headers: defaultHeaders,
            body: json.encode(doctorData),
          )
          .timeout(timeout);

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create doctor: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error creating doctor: $e');
    }
  }

  // Patient APIs
  static Future<List<Map<String, dynamic>>> getPatients() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/patients'), headers: defaultHeaders)
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['patients'] ?? []);
      } else {
        throw Exception('Failed to fetch patients: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error fetching patients: $e');
    }
  }

  static Future<Map<String, dynamic>> getPatientById(String patientId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/patients/$patientId'),
            headers: defaultHeaders,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch patient: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error fetching patient: $e');
    }
  }

  static Future<Map<String, dynamic>> createPatient(
    Map<String, dynamic> patientData,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/patients'),
            headers: defaultHeaders,
            body: json.encode(patientData),
          )
          .timeout(timeout);

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create patient: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error creating patient: $e');
    }
  }

  static Future<Map<String, dynamic>> updatePatient(
    String patientId,
    Map<String, dynamic> patientData,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/patients/$patientId'),
            headers: defaultHeaders,
            body: json.encode(patientData),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update patient: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error updating patient: $e');
    }
  }

  // Prescription APIs
  static Future<List<Map<String, dynamic>>> getPrescriptions() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/prescriptions'), headers: defaultHeaders)
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['prescriptions'] ?? []);
      } else {
        throw Exception(
          'Failed to fetch prescriptions: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Network error fetching prescriptions: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getPrescriptionsByPatient(
    String patientId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/prescriptions/patient/$patientId'),
            headers: defaultHeaders,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['prescriptions'] ?? []);
      } else {
        throw Exception(
          'Failed to fetch prescriptions: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Network error fetching prescriptions: $e');
    }
  }

  static Future<Map<String, dynamic>> createPrescription(
    Map<String, dynamic> prescriptionData,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/prescriptions'),
            headers: defaultHeaders,
            body: json.encode(prescriptionData),
          )
          .timeout(timeout);

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create prescription: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error creating prescription: $e');
    }
  }

  // Search and filter APIs
  static Future<List<Map<String, dynamic>>> searchPatients(String query) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/patients/search?q=$query'),
            headers: defaultHeaders,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['patients'] ?? []);
      } else {
        throw Exception('Failed to search patients: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error searching patients: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> searchDoctors(String query) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/doctors/search?q=$query'),
            headers: defaultHeaders,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['doctors'] ?? []);
      } else {
        throw Exception('Failed to search doctors: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error searching doctors: $e');
    }
  }

  // Error handling helper
  static String getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return 'An unexpected error occurred';
  }
}
