class ApiConstants {
  // Base URL for the API
  static const String baseUrl = 'http://localhost:3001/api/v1';
  
  // Authentication endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  
  // Patient endpoints
  static const String patients = '/patients';
  static const String patientProfile = '/patients/profile';
  static const String patientHealthRecords = '/patients/health-records';
  
  // Doctor endpoints
  static const String doctors = '/doctors';
  static const String doctorProfile = '/doctors/profile';
  static const String doctorAppointments = '/doctors/appointments';
  
  // Hospital endpoints
  static const String hospitals = '/hospitals';
  static const String hospitalProfile = '/hospitals/profile';
  static const String hospitalBeds = '/hospitals/beds';
  
  // Health endpoints
  static const String healthRecords = '/health/records';
  static const String vitals = '/health/vitals';
  static const String medications = '/health/medications';
  
  // AI Health Bot endpoints
  static const String aiChat = '/ai/chat';
  static const String aiSessions = '/ai/sessions';
  static const String aiRecommendations = '/ai/recommendations';
  static const String aiHealthAnalysis = '/ai/health-analysis';
  static const String aiFeedback = '/ai/feedback';
  
  // Insurance endpoints
  static const String insurancePolicies = '/insurance/policies';
  static const String insuranceClaims = '/insurance/claims';
  static const String insurancePreAuth = '/insurance/pre-authorization';
  static const String insuranceEligibility = '/insurance/eligibility';
  static const String insuranceNetworkHospitals = '/insurance/network-hospitals';
  
  // Gamification endpoints
  static const String gamificationProfile = '/gamification/profile';
  static const String gamificationChallenges = '/gamification/challenges';
  static const String gamificationProgress = '/gamification/progress';
  static const String gamificationGoals = '/gamification/goals';
  static const String gamificationLeaderboard = '/gamification/leaderboard';
  static const String gamificationBadges = '/gamification/badges';
  
  // Emergency endpoints
  static const String emergency = '/emergency';
  static const String emergencyContacts = '/emergency/contacts';
  static const String emergencyAlert = '/emergency/alert';
  
  // Telemedicine endpoints
  static const String telemedicine = '/telemedicine';
  static const String telemedicineAppointments = '/telemedicine/appointments';
  static const String telemedicineRooms = '/telemedicine/rooms';
  
  // QR Code endpoints
  static const String qrCodes = '/qr-codes';
  static const String qrGenerate = '/qr-codes/generate';
  static const String qrScan = '/qr-codes/scan';
  
  // Smartwatch endpoints
  static const String smartwatch = '/smartwatch';
  static const String smartwatchPair = '/smartwatch/pair';
  static const String smartwatchSync = '/smartwatch/sync';
  
  // Analytics endpoints
  static const String analytics = '/analytics';
  static const String analyticsHealth = '/analytics/health';
  static const String analyticsDashboard = '/analytics/dashboard';
  
  // Appointment endpoints
  static const String appointments = '/appointments';
  static const String appointmentBook = '/appointments/book';
  static const String appointmentCancel = '/appointments/cancel';
  
  // Prescription endpoints
  static const String prescriptions = '/prescriptions';
  static const String prescriptionCreate = '/prescriptions/create';
  static const String prescriptionUpdate = '/prescriptions/update';
  
  // Request timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds
  
  // Content types
  static const String contentTypeJson = 'application/json';
  static const String contentTypeFormData = 'multipart/form-data';
  
  // HTTP Status Codes
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusInternalServerError = 500;
}
