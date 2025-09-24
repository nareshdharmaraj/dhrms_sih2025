import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crypto/crypto.dart';

class PatientSettingsService {
  static const String _baseUrl = 'http://192.168.1.100:3000/api';
  static const String _keyPrefix = 'patient_settings_';

  // Singleton pattern
  static final PatientSettingsService _instance =
      PatientSettingsService._internal();
  factory PatientSettingsService() => _instance;
  PatientSettingsService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  late SharedPreferences _prefs;

  // Initialize service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ==================== PROFILE MANAGEMENT ====================

  /// Get patient profile from database
  Future<Map<String, dynamic>?> getPatientProfile(String patientId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/patients/$patientId/profile'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Cache profile locally
        await _prefs.setString('${_keyPrefix}profile', json.encode(data));
        return data;
      } else {
        // Return cached profile if API fails
        final cachedProfile = _prefs.getString('${_keyPrefix}profile');
        if (cachedProfile != null) {
          return json.decode(cachedProfile);
        }
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Error getting patient profile: $e');
      // Return cached profile on error
      final cachedProfile = _prefs.getString('${_keyPrefix}profile');
      if (cachedProfile != null) {
        return json.decode(cachedProfile);
      }
      return null;
    }
  }

  /// Update patient profile
  Future<bool> updatePatientProfile(
    String patientId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      // Validate required fields
      if (!_validateProfileData(profileData)) {
        throw Exception('Invalid profile data');
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/patients/$patientId/profile'),
        headers: await _getHeaders(),
        body: json.encode(profileData),
      );

      if (response.statusCode == 200) {
        // Update cached profile
        await _prefs.setString(
          '${_keyPrefix}profile',
          json.encode(profileData),
        );
        return true;
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Error updating patient profile: $e');
      return false;
    }
  }

  bool _validateProfileData(Map<String, dynamic> data) {
    final requiredFields = ['fullName', 'email', 'phone', 'dateOfBirth'];
    for (String field in requiredFields) {
      if (!data.containsKey(field) ||
          data[field] == null ||
          data[field].toString().isEmpty) {
        return false;
      }
    }

    // Validate email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(data['email'])) {
      return false;
    }

    // Validate phone number (Indian format)
    final phoneRegex = RegExp(r'^[+]?[91]?[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(
      data['phone'].toString().replaceAll(RegExp(r'[\s-]'), ''),
    )) {
      return false;
    }

    return true;
  }

  // ==================== PASSWORD MANAGEMENT ====================

  /// Change patient password
  Future<bool> changePassword(
    String patientId,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      // Validate password strength
      if (!_isPasswordStrong(newPassword)) {
        throw Exception('Password does not meet security requirements');
      }

      // Hash passwords
      final currentPasswordHash = _hashPassword(currentPassword);
      final newPasswordHash = _hashPassword(newPassword);

      final response = await http.post(
        Uri.parse('$_baseUrl/patients/$patientId/change-password'),
        headers: await _getHeaders(),
        body: json.encode({
          'currentPassword': currentPasswordHash,
          'newPassword': newPasswordHash,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      if (kDebugMode) print('Error changing password: $e');
      return false;
    }
  }

  bool _isPasswordStrong(String password) {
    // Password requirements: min 8 chars, at least 1 uppercase, 1 lowercase, 1 number, 1 special char
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode('${password}DHRMS_SALT_2024'); // Add salt
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ==================== PRIVACY SETTINGS ====================

  /// Get privacy settings
  Future<Map<String, bool>> getPrivacySettings(String patientId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/patients/$patientId/privacy-settings'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Map<String, bool> settings = Map<String, bool>.from(data);
        // Cache settings
        await _prefs.setString('${_keyPrefix}privacy', json.encode(settings));
        return settings;
      } else {
        throw Exception('Failed to load privacy settings');
      }
    } catch (e) {
      if (kDebugMode) print('Error getting privacy settings: $e');
      // Return cached settings or defaults
      final cached = _prefs.getString('${_keyPrefix}privacy');
      if (cached != null) {
        return Map<String, bool>.from(json.decode(cached));
      }
      return _getDefaultPrivacySettings();
    }
  }

  /// Update privacy settings
  Future<bool> updatePrivacySettings(
    String patientId,
    Map<String, bool> settings,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/patients/$patientId/privacy-settings'),
        headers: await _getHeaders(),
        body: json.encode(settings),
      );

      if (response.statusCode == 200) {
        // Cache settings
        await _prefs.setString('${_keyPrefix}privacy', json.encode(settings));
        return true;
      } else {
        throw Exception('Failed to update privacy settings');
      }
    } catch (e) {
      if (kDebugMode) print('Error updating privacy settings: $e');
      return false;
    }
  }

  Map<String, bool> _getDefaultPrivacySettings() {
    return {
      'shareDataWithDoctors': true,
      'shareDataWithResearchers': false,
      'allowMarketing': false,
      'shareLocationData': false,
      'shareHealthMetrics': true,
      'allowEmergencyAccess': true,
    };
  }

  // ==================== NOTIFICATION SETTINGS ====================

  /// Get notification settings
  Future<Map<String, bool>> getNotificationSettings(String patientId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/patients/$patientId/notification-settings'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Map<String, bool> settings = Map<String, bool>.from(data);
        // Cache settings
        await _prefs.setString(
          '${_keyPrefix}notifications',
          json.encode(settings),
        );
        return settings;
      } else {
        throw Exception('Failed to load notification settings');
      }
    } catch (e) {
      if (kDebugMode) print('Error getting notification settings: $e');
      // Return cached settings or defaults
      final cached = _prefs.getString('${_keyPrefix}notifications');
      if (cached != null) {
        return Map<String, bool>.from(json.decode(cached));
      }
      return _getDefaultNotificationSettings();
    }
  }

  /// Update notification settings
  Future<bool> updateNotificationSettings(
    String patientId,
    Map<String, bool> settings,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/patients/$patientId/notification-settings'),
        headers: await _getHeaders(),
        body: json.encode(settings),
      );

      if (response.statusCode == 200) {
        // Cache settings
        await _prefs.setString(
          '${_keyPrefix}notifications',
          json.encode(settings),
        );
        return true;
      } else {
        throw Exception('Failed to update notification settings');
      }
    } catch (e) {
      if (kDebugMode) print('Error updating notification settings: $e');
      return false;
    }
  }

  Map<String, bool> _getDefaultNotificationSettings() {
    return {
      'pushNotifications': true,
      'emailNotifications': true,
      'smsNotifications': false,
      'medicationReminders': true,
      'appointmentReminders': true,
      'healthTips': true,
      'emergencyAlerts': true,
      'marketingNotifications': false,
    };
  }

  // ==================== HEALTH REMINDERS ====================

  /// Get health reminders
  Future<List<Map<String, dynamic>>> getHealthReminders(
    String patientId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/patients/$patientId/health-reminders'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Map<String, dynamic>> reminders = List<Map<String, dynamic>>.from(
          data,
        );
        return reminders;
      } else {
        throw Exception('Failed to load health reminders');
      }
    } catch (e) {
      if (kDebugMode) print('Error getting health reminders: $e');
      return [];
    }
  }

  /// Add health reminder
  Future<bool> addHealthReminder(
    String patientId,
    Map<String, dynamic> reminder,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/patients/$patientId/health-reminders'),
        headers: await _getHeaders(),
        body: json.encode(reminder),
      );

      return response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) print('Error adding health reminder: $e');
      return false;
    }
  }

  /// Update health reminder
  Future<bool> updateHealthReminder(
    String patientId,
    String reminderId,
    Map<String, dynamic> reminder,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/patients/$patientId/health-reminders/$reminderId'),
        headers: await _getHeaders(),
        body: json.encode(reminder),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print('Error updating health reminder: $e');
      return false;
    }
  }

  /// Delete health reminder
  Future<bool> deleteHealthReminder(String patientId, String reminderId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/patients/$patientId/health-reminders/$reminderId'),
        headers: await _getHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print('Error deleting health reminder: $e');
      return false;
    }
  }

  // ==================== LANGUAGE & THEME ====================

  /// Get app preferences
  Future<Map<String, String>> getAppPreferences() async {
    return {
      'language': _prefs.getString('${_keyPrefix}language') ?? 'English',
      'theme': _prefs.getString('${_keyPrefix}theme') ?? 'System',
    };
  }

  /// Update language setting
  Future<bool> updateLanguage(String language) async {
    try {
      await _prefs.setString('${_keyPrefix}language', language);
      return true;
    } catch (e) {
      if (kDebugMode) print('Error updating language: $e');
      return false;
    }
  }

  /// Update theme setting
  Future<bool> updateTheme(String theme) async {
    try {
      await _prefs.setString('${_keyPrefix}theme', theme);
      return true;
    } catch (e) {
      if (kDebugMode) print('Error updating theme: $e');
      return false;
    }
  }

  /// Get supported languages
  List<Map<String, String>> getSupportedLanguages() {
    return [
      {'code': 'en', 'name': 'English', 'nativeName': 'English'},
      {'code': 'hi', 'name': 'Hindi', 'nativeName': 'हिन्दी'},
      {'code': 'ml', 'name': 'Malayalam', 'nativeName': 'മലയാളം'},
      {'code': 'ta', 'name': 'Tamil', 'nativeName': 'தமிழ்'},
      {'code': 'te', 'name': 'Telugu', 'nativeName': 'తెలుగు'},
      {'code': 'kn', 'name': 'Kannada', 'nativeName': 'ಕನ್ನಡ'},
      {'code': 'bn', 'name': 'Bengali', 'nativeName': 'বাংলা'},
      {'code': 'gu', 'name': 'Gujarati', 'nativeName': 'ગુજરાતી'},
      {'code': 'mr', 'name': 'Marathi', 'nativeName': 'मराठी'},
      {'code': 'pa', 'name': 'Punjabi', 'nativeName': 'ਪੰਜਾਬੀ'},
    ];
  }

  // ==================== BIOMETRIC AUTHENTICATION ====================

  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool hasHardware = await _localAuth.isDeviceSupported();
      return isAvailable && hasHardware;
    } catch (e) {
      if (kDebugMode) print('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      if (kDebugMode) print('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Enable biometric authentication
  Future<bool> enableBiometricAuth(String patientId) async {
    try {
      final bool isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to enable biometric login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        // Store biometric enablement in database
        final response = await http.post(
          Uri.parse('$_baseUrl/patients/$patientId/enable-biometric'),
          headers: await _getHeaders(),
          body: json.encode({'enabled': true}),
        );

        if (response.statusCode == 200) {
          await _prefs.setBool('${_keyPrefix}biometric_enabled', true);
          return true;
        }
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('Error enabling biometric auth: $e');
      return false;
    }
  }

  /// Disable biometric authentication
  Future<bool> disableBiometricAuth(String patientId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/patients/$patientId/disable-biometric'),
        headers: await _getHeaders(),
        body: json.encode({'enabled': false}),
      );

      if (response.statusCode == 200) {
        await _prefs.setBool('${_keyPrefix}biometric_enabled', false);
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('Error disabling biometric auth: $e');
      return false;
    }
  }

  /// Check if biometric is enabled for patient
  Future<bool> isBiometricEnabled() async {
    return _prefs.getBool('${_keyPrefix}biometric_enabled') ?? false;
  }

  /// Authenticate with biometrics
  Future<bool> authenticateWithBiometrics() async {
    try {
      final bool isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access the app',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return isAuthenticated;
    } catch (e) {
      if (kDebugMode) print('Error authenticating with biometrics: $e');
      return false;
    }
  }

  // ==================== LOCATION SERVICES ====================

  /// Check location permission status
  Future<LocationPermission> getLocationPermissionStatus() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      final isEnabled =
          permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;

      await _prefs.setBool('${_keyPrefix}location_enabled', isEnabled);
      return isEnabled;
    } catch (e) {
      if (kDebugMode) print('Error requesting location permission: $e');
      return false;
    }
  }

  /// Enable location services
  Future<bool> enableLocationServices(String patientId) async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) return false;

      // Store location enablement in database
      final response = await http.post(
        Uri.parse('$_baseUrl/patients/$patientId/location-settings'),
        headers: await _getHeaders(),
        body: json.encode({'enabled': true}),
      );

      if (response.statusCode == 200) {
        await _prefs.setBool('${_keyPrefix}location_enabled', true);
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('Error enabling location services: $e');
      return false;
    }
  }

  /// Disable location services
  Future<bool> disableLocationServices(String patientId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/patients/$patientId/location-settings'),
        headers: await _getHeaders(),
        body: json.encode({'enabled': false}),
      );

      if (response.statusCode == 200) {
        await _prefs.setBool('${_keyPrefix}location_enabled', false);
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('Error disabling location services: $e');
      return false;
    }
  }

  /// Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) return null;

      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      if (kDebugMode) print('Error getting current location: $e');
      return null;
    }
  }

  /// Check if location services are enabled
  Future<bool> isLocationEnabled() async {
    return _prefs.getBool('${_keyPrefix}location_enabled') ?? false;
  }

  // ==================== APP INFORMATION ====================

  /// Get app information
  Future<Map<String, String>> getAppInfo() async {
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      Map<String, String> info = {
        'appName': 'DHRMS',
        'packageName': 'com.dhrms.healthcare',
        'version': '1.0.0',
        'buildNumber': '1',
      };

      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        info.addAll({
          'platform': 'Android',
          'osVersion': androidInfo.version.release,
          'deviceModel': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
        });
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        info.addAll({
          'platform': 'iOS',
          'osVersion': iosInfo.systemVersion,
          'deviceModel': iosInfo.model,
          'manufacturer': 'Apple',
        });
      }

      return info;
    } catch (e) {
      if (kDebugMode) print('Error getting app info: $e');
      return {'appName': 'DHRMS', 'version': '1.0.0', 'platform': 'Unknown'};
    }
  }

  // ==================== HELP & SUPPORT ====================

  /// Get support contact information
  Map<String, String> getSupportInfo() {
    return {
      'teamName': 'App Maintenance Team',
      'contactPerson': 'Naresh',
      'phone': '+917200754566',
      'email': 'nareshd2006@gmail.com',
      'location': 'MKCE Karur',
      'supportHours': '9:00 AM - 6:00 PM (Mon-Fri)',
    };
  }

  /// Make a support call
  Future<bool> makeCall(String phoneNumber) async {
    try {
      final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
      return await launchUrl(launchUri);
    } catch (e) {
      if (kDebugMode) print('Error making call: $e');
      return false;
    }
  }

  /// Send support email
  Future<bool> sendSupportEmail(
    String email, {
    String? subject,
    String? body,
  }) async {
    try {
      final Uri launchUri = Uri(
        scheme: 'mailto',
        path: email,
        query: _encodeQueryParameters(<String, String>{
          'subject': subject ?? 'DHRMS Support Request',
          'body': body ?? 'Please describe your issue here...',
        }),
      );
      return await launchUrl(launchUri);
    } catch (e) {
      if (kDebugMode) print('Error sending email: $e');
      return false;
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (entry) =>
              '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}',
        )
        .join('&');
  }

  // ==================== PRIVACY POLICY & TERMS ====================

  /// Get privacy policy content
  String getPrivacyPolicy() {
    return '''
DIGITAL HEALTH RECORD MANAGEMENT SYSTEM
PRIVACY POLICY

Last Updated: September 21, 2025

1. INTRODUCTION
The Digital Health Record Management System (DHRMS) is committed to protecting your privacy and personal health information. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and services.

2. INFORMATION WE COLLECT
a) Personal Information:
   - Name, date of birth, gender, contact information
   - Government-issued identification numbers
   - Emergency contact details
   - Employment and residence information

b) Health Information:
   - Medical history and current conditions
   - Medications and treatments
   - Laboratory test results
   - Vital signs and health metrics
   - Doctor consultations and prescriptions

c) Technical Information:
   - Device information and identifiers
   - Location data (when permitted)
   - App usage analytics
   - Log files and crash reports

3. HOW WE USE YOUR INFORMATION
We use your information to:
   - Provide healthcare services and maintain health records
   - Facilitate communication with healthcare providers
   - Send health reminders and notifications
   - Improve our services and user experience
   - Comply with legal and regulatory requirements
   - Respond to emergencies and urgent health situations

4. INFORMATION SHARING
We may share your information with:
   - Authorized healthcare providers involved in your care
   - Government health authorities as required by law
   - Emergency services during health emergencies
   - Research institutions (anonymized data only)
   - Service providers under strict confidentiality agreements

5. DATA SECURITY
We implement robust security measures including:
   - End-to-end encryption for data transmission
   - Secure database storage with access controls
   - Regular security audits and updates
   - Biometric authentication options
   - Automatic logout and session management

6. YOUR RIGHTS
You have the right to:
   - Access and review your personal information
   - Request correction of inaccurate data
   - Withdraw consent for certain data uses
   - Request deletion of your data (subject to legal requirements)
   - Receive a copy of your data in portable format

7. DATA RETENTION
We retain your information as long as:
   - Your account remains active
   - Required for ongoing healthcare services
   - Mandated by applicable laws and regulations
   - Necessary for legitimate business purposes

8. CHILDREN'S PRIVACY
Our services are not directed to children under 13. We do not knowingly collect personal information from children under 13 without parental consent.

9. INTERNATIONAL TRANSFERS
Your data may be transferred to and processed in countries other than your residence. We ensure appropriate safeguards are in place for such transfers.

10. CHANGES TO THIS POLICY
We may update this Privacy Policy periodically. We will notify you of significant changes through the app or email.

11. CONTACT US
For questions about this Privacy Policy, contact:
App Maintenance Team
Naresh - +917200754566
Email: nareshd2006@gmail.com
Location: MKCE Karur

By using DHRMS, you acknowledge that you have read and understood this Privacy Policy.
''';
  }

  /// Get terms and conditions content
  String getTermsAndConditions() {
    return '''
DIGITAL HEALTH RECORD MANAGEMENT SYSTEM
TERMS AND CONDITIONS

Last Updated: September 21, 2025

1. ACCEPTANCE OF TERMS
By accessing and using the Digital Health Record Management System (DHRMS), you agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use our services.

2. DESCRIPTION OF SERVICE
DHRMS is a digital health platform designed to:
   - Maintain comprehensive health records for migrant workers
   - Facilitate healthcare access and coordination
   - Enable communication with healthcare providers
   - Provide health monitoring and reminder services
   - Support emergency medical situations

3. USER ELIGIBILITY
To use DHRMS, you must:
   - Be at least 13 years of age
   - Provide accurate and complete information
   - Have the legal right to enter into this agreement
   - Comply with all applicable laws and regulations

4. USER RESPONSIBILITIES
You agree to:
   - Provide accurate and up-to-date personal and health information
   - Maintain the confidentiality of your account credentials
   - Use the service for legitimate healthcare purposes only
   - Respect the privacy and rights of other users
   - Report any suspected security breaches immediately

5. PROHIBITED USES
You may not use DHRMS to:
   - Violate any laws or regulations
   - Impersonate another person or entity
   - Transmit false or misleading information
   - Interfere with the operation of the service
   - Attempt to gain unauthorized access to any part of the system

6. HEALTH INFORMATION DISCLAIMER
   - DHRMS is not a substitute for professional medical advice
   - Always consult healthcare professionals for medical decisions
   - The app provides information and tools but not medical diagnosis
   - Emergency situations require immediate contact with emergency services

7. DATA ACCURACY
While we strive to maintain accurate information:
   - You are responsible for verifying the accuracy of your data
   - We are not liable for decisions based on inaccurate information
   - Report any data discrepancies immediately

8. SERVICE AVAILABILITY
   - We aim to provide continuous service but cannot guarantee 100% uptime
   - Scheduled maintenance may temporarily interrupt service
   - We reserve the right to modify or discontinue features

9. INTELLECTUAL PROPERTY
   - DHRMS and its content are protected by intellectual property laws
   - You may not copy, modify, or distribute our proprietary content
   - Your health data remains your property

10. LIMITATION OF LIABILITY
To the maximum extent permitted by law:
   - We are not liable for indirect, incidental, or consequential damages
   - Our total liability is limited to the amount paid for services
   - We are not responsible for third-party actions or services

11. INDEMNIFICATION
You agree to indemnify and hold harmless DHRMS from any claims, damages, or expenses arising from your use of the service or violation of these terms.

12. PRIVACY
Your use of DHRMS is also governed by our Privacy Policy, which is incorporated into these terms by reference.

13. TERMINATION
   - You may terminate your account at any time
   - We may suspend or terminate accounts for violations of these terms
   - Certain provisions survive termination of the agreement

14. GOVERNING LAW
These terms are governed by the laws of India, specifically Kerala State regulations regarding healthcare data.

15. DISPUTE RESOLUTION
Any disputes will be resolved through:
   - Good faith negotiations
   - Mediation if negotiations fail
   - Arbitration in Kerala, India

16. MODIFICATIONS
We may modify these terms with notice to users. Continued use after modifications constitutes acceptance of new terms.

17. SEVERABILITY
If any provision of these terms is found invalid, the remaining provisions continue in full effect.

18. CONTACT INFORMATION
For questions about these Terms and Conditions:

App Maintenance Team
Contact Person: Naresh
Phone: +917200754566
Email: nareshd2006@gmail.com
Address: MKCE Karur, Tamil Nadu, India

EMERGENCY CONTACT
For medical emergencies, immediately contact:
   - Local Emergency Services: 108
   - Police: 100
   - Fire: 101

By using DHRMS, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.
''';
  }

  // ==================== HELPER METHODS ====================

  /// Get HTTP headers with authentication token
  Future<Map<String, String>> _getHeaders() async {
    final token = _prefs.getString('auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  /// Clear all cached settings
  Future<void> clearCache() async {
    final keys = _prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
    for (String key in keys) {
      await _prefs.remove(key);
    }
  }

  /// Export user data
  Future<Map<String, dynamic>> exportUserData(String patientId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/patients/$patientId/export-data'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to export user data');
      }
    } catch (e) {
      if (kDebugMode) print('Error exporting user data: $e');
      return {};
    }
  }

  /// Delete user account and all data
  Future<bool> deleteUserAccount(String patientId, String password) async {
    try {
      final passwordHash = _hashPassword(password);

      final response = await http.delete(
        Uri.parse('$_baseUrl/patients/$patientId/delete-account'),
        headers: await _getHeaders(),
        body: json.encode({'password': passwordHash}),
      );

      if (response.statusCode == 200) {
        await clearCache();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('Error deleting user account: $e');
      return false;
    }
  }
}
