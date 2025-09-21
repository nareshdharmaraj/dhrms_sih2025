import '../services/api_client.dart';

/// Hospital-specific API service that uses the centralized ApiClient
class HospitalApiService {
  static final _client = ApiClient.instance;

  // Hospital Management
  static Future<List<Map<String, dynamic>>> getHospitalList() async {
    try {
      final response = await _client.get('/hospital/list');
      final data = _client.parseResponse(response);

      // Handle the correct response structure from backend
      // Backend returns: { success: true, count: X, data: [...] }
      if (data['success'] == true && data['data'] != null) {
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to load hospitals: $e');
    }
  }

  // Hospital Admin APIs
  static Future<Map<String, dynamic>> adminLogin(
    String hospitalId,
    String username,
    String password,
  ) async {
    try {
      final response = await _client.post(
        '/hospital-admin/login',
        body: {
          'hospitalId': hospitalId,
          'username': username,
          'password': password,
        },
      );
      return _client.parseResponse(response);
    } catch (e) {
      throw Exception('Admin login failed: $e');
    }
  }

  static Future<Map<String, dynamic>> getAdminDashboard() async {
    try {
      final response = await _client.get('/hospital/admin/dashboard');
      return _client.parseResponse(response);
    } catch (e) {
      throw Exception('Failed to load admin dashboard: $e');
    }
  }

  static Future<void> toggleDoctorStatus(String doctorId, bool isActive) async {
    try {
      final response = await _client.put(
        '/hospital/admin/doctor/$doctorId/status',
        body: {'isActive': isActive},
      );
      _client.parseResponse(response);
    } catch (e) {
      throw Exception('Failed to toggle doctor status: $e');
    }
  }

  static Future<void> toggleAssistantStatus(
    String assistantId,
    bool isActive,
  ) async {
    try {
      final response = await _client.put(
        '/hospital/admin/assistant/$assistantId/status',
        body: {'isActive': isActive},
      );
      _client.parseResponse(response);
    } catch (e) {
      throw Exception('Failed to toggle assistant status: $e');
    }
  }

  static Future<Map<String, dynamic>> createDoctor(
    Map<String, dynamic> doctorData,
  ) async {
    try {
      final response = await _client.post(
        '/hospital/admin/doctor',
        body: doctorData,
      );
      return _client.parseResponse(response);
    } catch (e) {
      throw Exception('Failed to create doctor: $e');
    }
  }

  static Future<Map<String, dynamic>> createAssistant(
    Map<String, dynamic> assistantData,
  ) async {
    try {
      final response = await _client.post(
        '/hospital/admin/assistant',
        body: assistantData,
      );
      return _client.parseResponse(response);
    } catch (e) {
      throw Exception('Failed to create assistant: $e');
    }
  }

  // Hospital Doctor APIs
  static Future<Map<String, dynamic>> doctorLogin(
    String hospitalId,
    String username,
    String password,
  ) async {
    try {
      final response = await _client.post(
        '/hospital-doctor/login',
        body: {
          'hospitalId': hospitalId,
          'username': username,
          'password': password,
        },
      );
      return _client.parseResponse(response);
    } catch (e) {
      throw Exception('Doctor login failed: $e');
    }
  }

  static Future<Map<String, dynamic>> getDoctorDashboard() async {
    try {
      final response = await _client.get('/hospital/doctor/dashboard');
      return _client.parseResponse(response);
    } catch (e) {
      throw Exception('Failed to load doctor dashboard: $e');
    }
  }

  static Future<void> updateAppointmentStatus(
    String appointmentId,
    String status,
  ) async {
    try {
      final response = await _client.put(
        '/hospital/doctor/appointment/$appointmentId/status',
        body: {'status': status},
      );
      _client.parseResponse(response);
    } catch (e) {
      throw Exception('Failed to update appointment status: $e');
    }
  }

  // Hospital Assistant APIs
  static Future<Map<String, dynamic>> assistantLogin(
    String hospitalId,
    String username,
    String password,
  ) async {
    try {
      final response = await _client.post(
        '/hospital-assistant/login',
        body: {
          'hospitalId': hospitalId,
          'username': username,
          'password': password,
        },
      );
      return _client.parseResponse(response);
    } catch (e) {
      throw Exception('Assistant login failed: $e');
    }
  }

  static Future<Map<String, dynamic>> getAssistantDashboard() async {
    try {
      final response = await _client.get('/hospital/assistant/dashboard');
      return _client.parseResponse(response);
    } catch (e) {
      throw Exception('Failed to load assistant dashboard: $e');
    }
  }

  static Future<void> updateTaskStatus(String taskId, String status) async {
    try {
      final response = await _client.put(
        '/hospital/assistant/task/$taskId/status',
        body: {'status': status},
      );
      _client.parseResponse(response);
    } catch (e) {
      throw Exception('Failed to update task status: $e');
    }
  }

  // Hospital Registration
  static Future<Map<String, dynamic>> registerHospital(
    Map<String, dynamic> hospitalData,
  ) async {
    try {
      final response = await _client.post(
        '/hospital/register',
        body: hospitalData,
      );
      return _client.parseResponse(response);
    } catch (e) {
      throw Exception('Hospital registration failed: $e');
    }
  }

  // Hospital Staff APIs (generic)
  static Future<List<Map<String, dynamic>>> getPatients() async {
    try {
      final response = await _client.get('/patients');
      final data = _client.parseResponse(response);
      return List<Map<String, dynamic>>.from(data['patients'] ?? data ?? []);
    } catch (e) {
      throw Exception('Failed to load patients: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getStaffAppointments(
    String staffId,
  ) async {
    try {
      final response = await _client.get('/appointments/staff/$staffId');
      final data = _client.parseResponse(response);
      return List<Map<String, dynamic>>.from(
        data['appointments'] ?? data ?? [],
      );
    } catch (e) {
      throw Exception('Failed to load appointments: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getStaffMedicalRecords(
    String staffId,
  ) async {
    try {
      final response = await _client.get('/medical-records/staff/$staffId');
      final data = _client.parseResponse(response);
      return List<Map<String, dynamic>>.from(data['records'] ?? data ?? []);
    } catch (e) {
      throw Exception('Failed to load medical records: $e');
    }
  }

  // Authentication
  static Future<void> logout() async {
    try {
      await ApiClient.clearAuthToken();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }
}
