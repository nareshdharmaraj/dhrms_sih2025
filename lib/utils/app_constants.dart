import 'package:flutter/material.dart';
import 'environment_config.dart';

class AppConstants {
  // Brand Colors
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFFE8F5E8);
  
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color secondaryBlue = Color(0xFF64B5F6);
  static const Color lightBlue = Color(0xFFE3F2FD);
  
  static const Color primaryPurple = Color(0xFF7B1FA2);
  static const Color secondaryPurple = Color(0xFFBA68C8);
  static const Color lightPurple = Color(0xFFF3E5F5);
  
  // Neutral Colors
  static const Color darkGrey = Color(0xFF333333);
  static const Color mediumGrey = Color(0xFF666666);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color backgroundGrey = Color(0xFFF5F5F5);
  
  // Status Colors
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color infoBlue = Color(0xFF2196F3);
  
  // Text Colors
  static const Color primaryText = Color(0xFF212121);
  static const Color secondaryText = Color(0xFF757575);
  static const Color hintText = Color(0xFF9E9E9E);
  
  // App Routes
  static const String roleSelectionRoute = '/';
  static const String patientLoginRoute = '/patient-login';
  static const String hospitalLoginRoute = '/hospital-login';
  static const String regionalLoginRoute = '/regional-login';
  
  static const String patientDashboardRoute = '/patient-dashboard';
  static const String hospitalDashboardRoute = '/hospital-dashboard';
  static const String regionalDashboardRoute = '/regional-dashboard';
  
  static const String patientRegisterRoute = '/patient-register';
  static const String hospitalRegisterRoute = '/hospital-register';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 1000);
  
  // Spacing and Sizing
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;
  
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double extraLargeRadius = 24.0;
  
  // Font Sizes
  static const double smallFont = 12.0;
  static const double mediumFont = 14.0;
  static const double largeFont = 16.0;
  static const double titleFont = 18.0;
  static const double headingFont = 24.0;
  static const double displayFont = 32.0;
  
  // Validation Patterns
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^[+]?[0-9]{10,15}$';
  static const String passwordPattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{6,}$';
  
  // Health Record Types
  static const List<String> recordTypes = [
    'General Checkup',
    'Blood Test',
    'X-Ray',
    'MRI Scan',
    'CT Scan',
    'Prescription',
    'Vaccination',
    'Surgery',
    'Emergency',
    'Consultation',
  ];
  
  // User Roles
  static const String patientRole = 'patient';
  static const String hospitalStaffRole = 'hospital_staff';
  static const String regionalOfficerRole = 'regional_officer';
  
  // Hospital Staff Types
  static const List<String> hospitalStaffTypes = [
    'Doctor',
    'Nurse',
    'Lab Technician',
    'Radiologist',
    'Pharmacist',
    'Administrator',
    'Receptionist',
  ];
  
  // Regional Officer Levels
  static const List<String> regionalLevels = [
    'District Level',
    'State Level',
    'National Level',
  ];
  
  // API Endpoints (for backend integration)
  // Dynamic base URL that adapts to the platform using environment configuration
  static String get baseUrl {
    // Use the new environment-based configuration
    return EnvironmentConfig.getApiBaseUrl();
  }
  
  // Alternative base URL for physical devices (maintained for compatibility)
  static const String physicalDeviceBaseUrl = 'http://10.123.62.47:3000/api';
  
  // Getter for API base URL (main access point)
  static String get apiBaseUrl => baseUrl;
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String profileEndpoint = '/user/profile';
  static const String recordsEndpoint = '/records';
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userRoleKey = 'user_role';
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
  
  // Error Messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'Please check your internet connection.';
  static const String invalidCredentialsMessage = 'Invalid username or password.';
  static const String accountNotFoundMessage = 'Account not found. Please register first.';
  static const String emailAlreadyExistsMessage = 'Email already exists. Please use a different email.';
  
  // Success Messages
  static const String loginSuccessMessage = 'Login successful!';
  static const String registrationSuccessMessage = 'Registration successful!';
  static const String profileUpdateSuccessMessage = 'Profile updated successfully!';
  static const String recordSavedSuccessMessage = 'Record saved successfully!';
}
