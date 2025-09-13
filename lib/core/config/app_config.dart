import 'package:flutter/foundation.dart';

class AppConfig {
  // Toggle between local and cloud backend
  static bool useCloud =
      kReleaseMode; // Automatically use cloud in release mode

  // Backend URLs
  static const String _localUrl = kIsWeb
      ? 'http://localhost:3000' // For web development
      : 'http://10.0.2.2:3000'; // For Android emulator

  static const String _cloudUrl =
      'https://your-app.onrender.com'; // Replace with your Render URL

  // Get the current base URL
  static String get baseUrl => useCloud ? _cloudUrl : _localUrl;

  // API endpoints
  static String get apiUrl => '$baseUrl/api';

  // Common endpoints
  static String get healthCheck => '$baseUrl/health';
  static String get testEndpoint => '$baseUrl/api/test';
  static String get patientsRegister => '$baseUrl/api/patients/register';
  static String get patientsLogin => '$baseUrl/api/patients/login';
  static String get wearableDevices => '$baseUrl/api/wearables';

  // Environment info
  static String get environment => useCloud ? 'Cloud' : 'Local';

  // Toggle method for runtime switching
  static void toggleBackend() {
    useCloud = !useCloud;
    print('🔄 Backend switched to: ${environment}');
    print('🌐 Base URL: ${baseUrl}');
  }

  // Set backend explicitly
  static void setBackend({required bool cloud}) {
    useCloud = cloud;
    print('⚙️ Backend set to: ${environment}');
    print('🌐 Base URL: ${baseUrl}');
  }
}
