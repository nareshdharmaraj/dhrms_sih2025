import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api/v1';
  static const Duration timeout = Duration(seconds: 30);

  static Map<String, String> getHeaders({String? userId, String? role}) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (userId != null) 'X-User-ID': userId,
    if (role != null) 'X-User-Role': role,
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
            headers: getHeaders(),
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
    // TEMPORARY: Return mock data for development
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    return {
      'success': true,
      'message': 'Login successful (mock)',
      'userId': 'mock_${role}_${DateTime.now().millisecondsSinceEpoch}',
      'user': {
        'id': 'mock_${role}_${DateTime.now().millisecondsSinceEpoch}',
        'name': _getMockUserName(role),
        'username': username,
        'email': _getMockEmail(role),
        'phone': '+91 9876543210',
        'role': role,
        if (role == 'hospital') ..._getHospitalMockData(),
        if (role == 'regionalOfficer') ..._getRegionalOfficerMockData(),
        if (role == 'normalUser') ..._getNormalUserMockData(),
      }
    };
    
    // Original implementation (commented out for now)
    /*
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: getHeaders(),
            body: json.encode({
              'username': username,
              'password': password,
              'role': role,
            }),
          )
          .timeout(timeout);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Network error during login: $e');
    }
    */
  }

  static String _getMockUserName(String role) {
    switch (role) {
      case 'hospital':
        return 'Dr. Sarah Wilson';
      case 'regionalOfficer':
        return 'Officer Rajesh Kumar';
      default:
        return 'John Doe';
    }
  }

  static String _getMockEmail(String role) {
    switch (role) {
      case 'hospital':
        return 'sarah.wilson@hospital.com';
      case 'regionalOfficer':
        return 'rajesh.kumar@health.kerala.gov.in';
      default:
        return 'john.doe@worker.com';
    }
  }

  static Map<String, dynamic> _getHospitalMockData() {
    return {
      'hospitalName': 'Kerala General Hospital',
      'department': 'Emergency Medicine',
      'specialization': 'Emergency Medicine',
      'licenseNumber': 'MED12345',
    };
  }

  static Map<String, dynamic> _getRegionalOfficerMockData() {
    return {
      'region': 'Kochi District',
      'designation': 'Regional Health Officer',
    };
  }

  static Map<String, dynamic> _getNormalUserMockData() {
    return {
      'aadhaarLast4': '1234',
      'uniqueHealthId': 'UHI123456789',
      'bloodGroup': 'O+',
      'address': 'Worker Colony, Kochi, Kerala',
    };
  }

  // Registration
  static Future<Map<String, dynamic>> register(
    String username,
    String password,
    String email,
    String role,
    String firstName,
    String lastName,
    String phone,
    Map<String, dynamic> additionalData,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: getHeaders(),
            body: json.encode({
              'username': username,
              'password': password,
              'email': email,
              'role': role,
              'firstName': firstName,
              'lastName': lastName,
              'phone': phone,
              ...additionalData,
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error during registration: $e');
    }
  }

  // Hospital APIs
  static Future<List<Map<String, dynamic>>> getHospitals() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/hospitals'), headers: getHeaders())
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
            headers: getHeaders(),
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
          .get(Uri.parse('$baseUrl/doctors'), headers: getHeaders())
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
          .get(Uri.parse('$baseUrl/doctors/$doctorId'), headers: getHeaders())
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
            headers: getHeaders(),
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
    // TEMPORARY: Return mock patient data for development
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    return [
      {
        'id': '1',
        'name': 'Ravi Kumar',
        'age': 35,
        'gender': 'Male',
        'phone': '+91 9876543210',
        'uniqueHealthId': 'UHI123456789',
        'bloodGroup': 'O+',
        'address': 'Worker Colony, Kochi, Kerala',
        'registrationDate': '2025-09-01T10:00:00Z',
        'status': 'Active',
        'lastVisit': '2025-09-06T14:30:00Z',
      },
      {
        'id': '2',
        'name': 'Priya Sharma',
        'age': 28,
        'gender': 'Female',
        'phone': '+91 9876543211',
        'uniqueHealthId': 'UHI123456790',
        'bloodGroup': 'A+',
        'address': 'Migrant Housing, Ernakulam, Kerala',
        'registrationDate': '2025-09-02T11:00:00Z',
        'status': 'Active',
        'lastVisit': '2025-09-05T16:45:00Z',
      },
      {
        'id': '3',
        'name': 'Amit Singh',
        'age': 42,
        'gender': 'Male',
        'phone': '+91 9876543212',
        'uniqueHealthId': 'UHI123456791',
        'bloodGroup': 'B+',
        'address': 'Construction Site, Kochi, Kerala',
        'registrationDate': '2025-08-28T09:15:00Z',
        'status': 'Active',
        'lastVisit': '2025-09-04T10:20:00Z',
      },
    ];
    
    // Original implementation (commented out for now)
    /*
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/patients'), headers: getHeaders())
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
    */
  }

  static Future<Map<String, dynamic>> getPatientById(String patientId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/patients/$patientId'),
            headers: getHeaders(),
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
            headers: getHeaders(),
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
            headers: getHeaders(),
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
          .get(Uri.parse('$baseUrl/prescriptions'), headers: getHeaders())
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
            headers: getHeaders(),
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
            headers: getHeaders(),
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
            headers: getHeaders(),
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
            headers: getHeaders(),
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

  // Health Records APIs
  static Future<List<Map<String, dynamic>>> getPatientHealthRecords(String patientId) async {
    try {
      // Mock data for development
      return await Future.delayed(Duration(milliseconds: 500), () => [
        {
          'id': 'hr_001',
          'patientId': patientId,
          'date': DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
          'type': 'Consultation',
          'provider': 'Dr. Sarah Wilson',
          'diagnosis': 'Hypertension',
          'treatment': 'Prescribed antihypertensive medication',
          'notes': 'Regular check-up, BP 140/90, patient responding well to medication',
          'vitalSigns': {
            'bloodPressure': '140/90',
            'heartRate': '72',
            'temperature': '98.6°F',
            'weight': '70kg'
          }
        },
        {
          'id': 'hr_002',
          'patientId': patientId,
          'date': DateTime.now().subtract(Duration(days: 15)).toIso8601String(),
          'type': 'Laboratory',
          'provider': 'City Hospital Lab',
          'diagnosis': 'Blood work results',
          'treatment': 'Continue current medication',
          'notes': 'Complete blood count and lipid panel within normal range',
          'labResults': {
            'hemoglobin': '14.5 g/dL',
            'whiteBloodCells': '7200/µL',
            'cholesterol': '180 mg/dL',
            'glucose': '95 mg/dL'
          }
        },
        {
          'id': 'hr_003',
          'patientId': patientId,
          'date': DateTime.now().subtract(Duration(days: 30)).toIso8601String(),
          'type': 'Vaccination',
          'provider': 'Community Health Center',
          'diagnosis': 'Preventive care',
          'treatment': 'Influenza vaccine administered',
          'notes': 'Annual flu vaccination, no adverse reactions',
          'vaccine': {
            'type': 'Influenza',
            'manufacturer': 'Pfizer',
            'lot': 'FL2024-001',
            'site': 'Left deltoid'
          }
        }
      ]);
    } catch (e) {
      throw Exception('Network error fetching health records: $e');
    }
  }

  // Appointments APIs
  static Future<List<Map<String, dynamic>>> getPatientAppointments(String patientId) async {
    try {
      // Mock data for development
      return await Future.delayed(Duration(milliseconds: 500), () => [
        {
          'id': 'apt_001',
          'patientId': patientId,
          'doctorId': 'doc_001',
          'doctorName': 'Dr. Michael Chen',
          'specialty': 'Cardiology',
          'date': DateTime.now().add(Duration(days: 3)).toIso8601String(),
          'time': '10:00 AM',
          'type': 'Follow-up',
          'status': 'Confirmed',
          'location': 'Room 201, Cardiology Wing',
          'reason': 'Blood pressure monitoring',
          'notes': 'Bring current medication list'
        },
        {
          'id': 'apt_002',
          'patientId': patientId,
          'doctorId': 'doc_002',
          'doctorName': 'Dr. Lisa Rodriguez',
          'specialty': 'General Medicine',
          'date': DateTime.now().add(Duration(days: 10)).toIso8601String(),
          'time': '2:30 PM',
          'type': 'Routine Checkup',
          'status': 'Scheduled',
          'location': 'Room 105, General Medicine',
          'reason': 'Annual physical examination',
          'notes': 'Fasting required for blood work'
        },
        {
          'id': 'apt_003',
          'patientId': patientId,
          'doctorId': 'doc_003',
          'doctorName': 'Dr. James Thompson',
          'specialty': 'Dermatology',
          'date': DateTime.now().subtract(Duration(days: 7)).toIso8601String(),
          'time': '11:15 AM',
          'type': 'Consultation',
          'status': 'Completed',
          'location': 'Room 304, Dermatology',
          'reason': 'Skin examination',
          'notes': 'Follow-up in 6 months if no changes'
        }
      ]);
    } catch (e) {
      throw Exception('Network error fetching appointments: $e');
    }
  }

  // Prescriptions APIs
  static Future<List<Map<String, dynamic>>> getPatientPrescriptions(String patientId) async {
    try {
      // Mock data for development
      return await Future.delayed(Duration(milliseconds: 500), () => [
        {
          'id': 'prx_001',
          'patientId': patientId,
          'doctorName': 'Dr. Michael Chen',
          'medication': 'Lisinopril',
          'dosage': '10mg',
          'frequency': 'Once daily',
          'duration': '30 days',
          'prescribedDate': DateTime.now().subtract(Duration(days: 10)).toIso8601String(),
          'expiryDate': DateTime.now().add(Duration(days: 20)).toIso8601String(),
          'status': 'Active',
          'instructions': 'Take with or without food. Monitor blood pressure regularly.',
          'refillsRemaining': 3,
          'totalRefills': 5,
          'pharmacy': 'City Pharmacy'
        },
        {
          'id': 'prx_002',
          'patientId': patientId,
          'doctorName': 'Dr. Lisa Rodriguez',
          'medication': 'Metformin',
          'dosage': '500mg',
          'frequency': 'Twice daily',
          'duration': '90 days',
          'prescribedDate': DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
          'expiryDate': DateTime.now().add(Duration(days: 85)).toIso8601String(),
          'status': 'Active',
          'instructions': 'Take with meals to reduce stomach upset.',
          'refillsRemaining': 2,
          'totalRefills': 3,
          'pharmacy': 'HealthMart Pharmacy'
        },
        {
          'id': 'prx_003',
          'patientId': patientId,
          'doctorName': 'Dr. Sarah Wilson',
          'medication': 'Ibuprofen',
          'dosage': '400mg',
          'frequency': 'As needed',
          'duration': '7 days',
          'prescribedDate': DateTime.now().subtract(Duration(days: 30)).toIso8601String(),
          'expiryDate': DateTime.now().subtract(Duration(days: 23)).toIso8601String(),
          'status': 'Expired',
          'instructions': 'Take with food. Do not exceed 3 doses per day.',
          'refillsRemaining': 0,
          'totalRefills': 0,
          'pharmacy': 'Community Pharmacy'
        }
      ]);
    } catch (e) {
      throw Exception('Network error fetching prescriptions: $e');
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
