import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'DHRMS';
  static const String appFullName = 'Digital Health Record Management System';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Healthcare management for migrant workers in Kerala';
  
  // Colors
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color accentPurple = Color(0xFF9C27B0);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color successGreen = Color(0xFF4CAF50);
  
  // User Roles
  static const String rolePatient = 'patient';
  static const String roleDoctor = 'doctor';
  static const String roleAdmin = 'admin';
  static const String roleAssistant = 'assistant';
  static const String roleRegionalOfficer = 'regional_officer';
  
  // Routes
  static const String routeHome = '/';
  static const String routeRoleSelection = '/role-selection';
  static const String routePatientDashboard = '/patient';
  static const String routePatientProfile = '/patient/profile';
  static const String routePatientRecords = '/patient/records';
  static const String routePatientAppointments = '/patient/appointments';
  static const String routeHospitalDashboard = '/hospital';
  static const String routeRegionalDashboard = '/regional';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  
  // API Endpoints
  static const String baseUrl = 'http://localhost:3000/api';
  static const String authEndpoint = '/auth';
  static const String patientsEndpoint = '/patients';
  static const String hospitalEndpoint = '/hospital';
  static const String regionalEndpoint = '/regional';
  
  // Shared Preferences Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserData = 'user_data';
  static const String keyUserRole = 'user_role';
  static const String keyHealthId = 'health_id';
  static const String keyIsFirstLaunch = 'is_first_launch';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);
  
  // Responsive Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  
  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  
  // Health Records Types
  static const List<String> recordTypes = [
    'consultation',
    'diagnosis',
    'prescription',
    'lab_report',
    'vaccination',
    'surgery',
    'emergency',
    'checkup',
    'treatment'
  ];
  
  // Blood Groups
  static const List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];
  
  // Gender Options
  static const List<String> genderOptions = [
    'male', 'female', 'other'
  ];
  
  // File Upload Limits
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedFileTypes = [
    'pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'
  ];
  
  // Error Messages
  static const String errorNetworkConnection = 'No internet connection';
  static const String errorServerError = 'Server error occurred';
  static const String errorInvalidCredentials = 'Invalid credentials';
  static const String errorSessionExpired = 'Session expired, please login again';
  static const String errorUnauthorized = 'Unauthorized access';
  static const String errorNotFound = 'Resource not found';
  
  // Success Messages
  static const String successLogin = 'Login successful';
  static const String successRegistration = 'Registration successful';
  static const String successProfileUpdate = 'Profile updated successfully';
  static const String successRecordAdded = 'Health record added successfully';
  
  // Validation Patterns
  static final RegExp emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
  );
  static final RegExp phonePattern = RegExp(
    r'^[+]?[1-9][\d]{0,15}$'
  );
  static final RegExp healthIdPattern = RegExp(
    r'^[A-Z]{4}[0-9]{4}$'
  );
}
