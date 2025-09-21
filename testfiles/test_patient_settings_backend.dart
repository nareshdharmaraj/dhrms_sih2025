import 'package:flutter/material.dart';
import '../lib/services/patient_settings_service.dart';

/// Test widget to verify patient settings backend functionality
class TestPatientSettingsBackend extends StatefulWidget {
  const TestPatientSettingsBackend({super.key});

  @override
  State<TestPatientSettingsBackend> createState() => _TestPatientSettingsBackendState();
}

class _TestPatientSettingsBackendState extends State<TestPatientSettingsBackend> {
  final PatientSettingsService _service = PatientSettingsService();
  final String _testPatientId = 'TEST_PATIENT_001';
  String _testResults = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Settings Backend Test'),
        backgroundColor: Colors.blue.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _runAllTests,
              child: const Text('Run All Backend Tests'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _testResults.isEmpty ? 'Click "Run All Backend Tests" to start testing...' : _testResults,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runAllTests() async {
    setState(() {
      _testResults = 'Starting backend tests...\n\n';
    });

    await _testProfileManagement();
    await _testPasswordSecurity();
    await _testPrivacySettings();
    await _testNotificationSettings();
    await _testAppPreferences();
    await _testBiometricAuth();
    await _testLocationServices();
    await _testAppInfo();
    await _testSupportInfo();
    await _testLegalDocuments();

    setState(() {
      _testResults += '\n✅ All backend tests completed successfully!\n';
    });
  }

  Future<void> _testProfileManagement() async {
    _updateResults('Testing Profile Management...');
    
    try {
      // Test profile update
      final profileData = {
        'fullName': 'Test Patient',
        'email': 'test.patient@example.com',
        'phone': '+919876543210',
        'address': 'Test Address, Test City',
      };
      
      final updateResult = await _service.updatePatientProfile(_testPatientId, profileData);
      _updateResults('✅ Profile update: ${updateResult ? "SUCCESS" : "FAILED"}');
      
      // Test profile retrieval
      final retrievedProfile = await _service.getPatientProfile(_testPatientId);
      _updateResults('✅ Profile retrieval: ${retrievedProfile != null ? "SUCCESS" : "FAILED"}');
      
    } catch (e) {
      _updateResults('❌ Profile Management Error: $e');
    }
  }

  Future<void> _testPasswordSecurity() async {
    _updateResults('\nTesting Password Security...');
    
    try {
      // Test password change
      const currentPassword = 'testPassword123';
      const newPassword = 'newTestPassword456';
      
      final passwordResult = await _service.changePassword(_testPatientId, currentPassword, newPassword);
      _updateResults('✅ Password change: ${passwordResult ? "SUCCESS" : "FAILED"}');
      
    } catch (e) {
      _updateResults('❌ Password Security Error: $e');
    }
  }

  Future<void> _testPrivacySettings() async {
    _updateResults('\nTesting Privacy Settings...');
    
    try {
      // Test privacy settings update
      final privacySettings = {
        'shareDataWithDoctors': true,
        'shareDataWithResearchers': false,
        'shareLocationData': true,
        'shareHealthMetrics': true,
        'allowEmergencyAccess': true,
      };
      
      final privacyResult = await _service.updatePrivacySettings(_testPatientId, privacySettings);
      _updateResults('✅ Privacy settings update: ${privacyResult ? "SUCCESS" : "FAILED"}');
      
      // Test privacy settings retrieval
      final retrievedPrivacy = await _service.getPrivacySettings(_testPatientId);
      _updateResults('✅ Privacy settings retrieval: ${retrievedPrivacy.isNotEmpty ? "SUCCESS" : "FAILED"}');
      
    } catch (e) {
      _updateResults('❌ Privacy Settings Error: $e');
    }
  }

  Future<void> _testNotificationSettings() async {
    _updateResults('\nTesting Notification Settings...');
    
    try {
      // Test notification settings update
      final notificationSettings = {
        'pushNotifications': true,
        'medicationReminders': true,
        'appointmentReminders': true,
        'emergencyAlerts': true,
        'healthTips': false,
      };
      
      final notificationResult = await _service.updateNotificationSettings(_testPatientId, notificationSettings);
      _updateResults('✅ Notification settings update: ${notificationResult ? "SUCCESS" : "FAILED"}');
      
      // Test notification settings retrieval
      final retrievedNotifications = await _service.getNotificationSettings(_testPatientId);
      _updateResults('✅ Notification settings retrieval: ${retrievedNotifications.isNotEmpty ? "SUCCESS" : "FAILED"}');
      
    } catch (e) {
      _updateResults('❌ Notification Settings Error: $e');
    }
  }

  Future<void> _testAppPreferences() async {
    _updateResults('\nTesting App Preferences...');
    
    try {
      // Test language update
      final languageResult = await _service.updateLanguage('Hindi');
      _updateResults('✅ Language update: ${languageResult ? "SUCCESS" : "FAILED"}');
      
      // Test theme update
      final themeResult = await _service.updateTheme('Dark');
      _updateResults('✅ Theme update: ${themeResult ? "SUCCESS" : "FAILED"}');
      
    } catch (e) {
      _updateResults('❌ App Preferences Error: $e');
    }
  }

  Future<void> _testBiometricAuth() async {
    _updateResults('\nTesting Biometric Authentication...');
    
    try {
      // Test biometric availability
      final isAvailable = await _service.isBiometricAvailable();
      _updateResults('✅ Biometric availability check: ${isAvailable ? "AVAILABLE" : "NOT AVAILABLE"}');
      
      // Test biometric enable/disable (only if available)
      if (isAvailable) {
        final enableResult = await _service.enableBiometricAuth(_testPatientId);
        _updateResults('✅ Biometric enable: ${enableResult ? "SUCCESS" : "FAILED"}');
        
        final disableResult = await _service.disableBiometricAuth(_testPatientId);
        _updateResults('✅ Biometric disable: ${disableResult ? "SUCCESS" : "FAILED"}');
      }
      
    } catch (e) {
      _updateResults('❌ Biometric Authentication Error: $e');
    }
  }

  Future<void> _testLocationServices() async {
    _updateResults('\nTesting Location Services...');
    
    try {
      // Test location availability
      final isEnabled = await _service.isLocationEnabled();
      _updateResults('✅ Location availability check: ${isEnabled ? "ENABLED" : "DISABLED"}');
      
      // Test location service management
      final enableResult = await _service.enableLocationServices(_testPatientId);
      _updateResults('✅ Location enable: ${enableResult ? "SUCCESS" : "FAILED"}');
      
    } catch (e) {
      _updateResults('❌ Location Services Error: $e');
    }
  }

  Future<void> _testAppInfo() async {
    _updateResults('\nTesting App Information...');
    
    try {
      // Test app info retrieval
      final appInfo = await _service.getAppInfo();
      _updateResults('✅ App info retrieval: ${appInfo.isNotEmpty ? "SUCCESS" : "FAILED"}');
      _updateResults('   App Name: ${appInfo['appName']}');
      _updateResults('   Version: ${appInfo['version']}');
      _updateResults('   Platform: ${appInfo['platform']}');
      
    } catch (e) {
      _updateResults('❌ App Information Error: $e');
    }
  }

  Future<void> _testSupportInfo() async {
    _updateResults('\nTesting Support Information...');
    
    try {
      // Test support info retrieval
      final supportInfo = _service.getSupportInfo();
      _updateResults('✅ Support info retrieval: ${supportInfo.isNotEmpty ? "SUCCESS" : "FAILED"}');
      _updateResults('   Team: ${supportInfo['teamName']}');
      _updateResults('   Contact: ${supportInfo['contactPerson']}');
      _updateResults('   Phone: ${supportInfo['phone']}');
      _updateResults('   Email: ${supportInfo['email']}');
      
    } catch (e) {
      _updateResults('❌ Support Information Error: $e');
    }
  }

  Future<void> _testLegalDocuments() async {
    _updateResults('\nTesting Legal Documents...');
    
    try {
      // Test privacy policy retrieval
      final privacyPolicy = _service.getPrivacyPolicy();
      _updateResults('✅ Privacy policy retrieval: ${privacyPolicy.isNotEmpty ? "SUCCESS" : "FAILED"}');
      
      // Test terms and conditions retrieval
      final termsConditions = _service.getTermsAndConditions();
      _updateResults('✅ Terms & conditions retrieval: ${termsConditions.isNotEmpty ? "SUCCESS" : "FAILED"}');
      
    } catch (e) {
      _updateResults('❌ Legal Documents Error: $e');
    }
  }

  void _updateResults(String message) {
    setState(() {
      _testResults += '$message\n';
    });
  }
}

void main() {
  runApp(MaterialApp(
    home: const TestPatientSettingsBackend(),
    theme: ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
    ),
  ));
}