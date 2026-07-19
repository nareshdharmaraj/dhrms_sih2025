class AppConstants {
  // App Information
  static const String appName = 'MyHealth';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Digital Health Record Management System for Migrant Workers';

  // User Roles
  static const String roleNormalUser = 'normal_user';
  static const String roleDoctor = 'doctor';
  static const String roleHospital = 'hospital';
  static const String roleRegionalOfficer = 'regional_officer';

  // Routes
  static const String routeRoleSelection = '/role-selection';
  static const String routeLogin = '/login';
  static const String routeUserDashboard = '/user-dashboard';
  static const String routeHospitalDashboard = '/hospital-dashboard';
  static const String routeRegionalDashboard = '/regional-dashboard';
  static const String routeProfile = '/profile';
  static const String routeHealthRecords = '/health-records';
  static const String routeVitalsMonitoring = '/vitals';
  static const String routeTelemedicine = '/telemedicine';
  static const String routeEmergencySOS = '/emergency';
  static const String routeProximityAlerts = '/proximity-alerts';
  static const String routeAIHealthBot = '/ai-health-bot';
  static const String routeGamification = '/gamification';
  static const String routeInsurance = '/insurance';
  static const String routeQRScanner = '/qr-scanner';
  static const String routeSettings = '/settings';

  // Storage Keys
  static const String keyUserRole = 'user_role';
  static const String keyUserId = 'user_id';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserProfile = 'user_profile';
  static const String keyHealthRecords = 'health_records';
  static const String keyVitalsData = 'vitals_data';
  static const String keyProximitySettings = 'proximity_settings';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyAccessibilitySettings = 'accessibility_settings';

  // Network
  static const String baseUrl = 'https://api.myhealth.gov.in'; // Placeholder
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;

  // Health Parameters
  static const Map<String, Map<String, double>> vitalRanges = {
    'heart_rate': {'min': 60.0, 'max': 100.0},
    'blood_pressure_systolic': {'min': 90.0, 'max': 140.0},
    'blood_pressure_diastolic': {'min': 60.0, 'max': 90.0},
    'oxygen_saturation': {'min': 95.0, 'max': 100.0},
    'body_temperature': {'min': 36.1, 'max': 37.2},
    'blood_sugar': {'min': 70.0, 'max': 140.0},
  };

  // Emergency Contacts
  static const String emergencyHotline = '108';
  static const String healthHelpline = '104';
  static const String ambulanceService = '102';

  // Proximity Alert Settings
  static const double proximityAlertDistance = 2.0; // meters
  static const Duration proximityCheckInterval = Duration(seconds: 30);

  // Gamification
  static const Map<String, int> healthPoints = {
    'checkup_completed': 100,
    'vaccination_taken': 150,
    'health_quiz_completed': 50,
    'vitals_logged': 25,
    'telemedicine_session': 75,
    'emergency_drill_completed': 80,
  };

  // Insurance Schemes
  static const List<String> insuranceSchemes = [
    'Ayushman Bharat',
    'Kerala State Health Insurance',
    'ESI Scheme',
    'Private Health Insurance',
  ];
}
