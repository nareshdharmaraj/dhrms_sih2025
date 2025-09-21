import '../utils/environment_config.dart';

class ApiConstants {
  // Use dynamic base URL from EnvironmentConfig instead of hardcoded localhost
  static String get baseUrl => EnvironmentConfig.getApiBaseUrl();

  // Hospital Management Endpoints
  static const String hospitalList = '/hospital/list';
  static const String hospitalSearch = '/hospital/search';
  static const String hospitalRegister = '/hospital/register';
  static const String hospitalAdminLogin = '/hospital-admin/login';
  static const String hospitalAdminDashboard = '/hospital-admin/dashboard';
  static const String hospitalDoctorLogin = '/hospital-doctor/login';
  static const String hospitalAssistantLogin = '/hospital-assistant/login';

  // Common Headers
  static const Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json',
  };

  static Map<String, String> authHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}

class AppConstants {
  static const String appName = 'DHRMS';
  static const String hospitalSystem = 'Hospital Management System';

  // Colors
  static const int primaryColorValue = 0xFF2196F3;
  static const int secondaryColorValue = 0xFF03DAC6;

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String hospitalDataKey = 'hospital_data';
}

class ValidationConstants {
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
}

class Constants {
  // Use dynamic base URL from EnvironmentConfig instead of hardcoded localhost
  static String get baseUrl => EnvironmentConfig.getApiBaseUrl();
}
