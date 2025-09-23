import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'screens/splash_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/login_screen.dart';
import 'screens/patient_dashboard_screen.dart';
import 'screens/hospital_staff_dashboard.dart';
import 'screens/regional_officer_dashboard.dart';
import 'screens/patient_registration_screen.dart';
import 'screens/digital_health_card_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/wearable_data_screen.dart';
import 'screens/ai_health_chatbot_screen.dart';
import 'screens/who_login_screen.dart';
import 'screens/sho_login_screen.dart';
import 'screens/hospital_registration_screen.dart';
import 'screens/hospital_admin_login_screen.dart';
import 'screens/hospital_admin_dashboard_screen.dart';
import 'screens/hospital_role_selection_screen.dart';
import 'screens/hospital_doctor_login_screen.dart';
import 'screens/hospital_doctor_dashboard_screen.dart';
import 'screens/hospital_assistant_login_screen.dart';
import 'utils/environment_config.dart';
import 'widgets/configuration_switcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the configuration system
  await EnvironmentConfig.initialize();

  runApp(const DHRMSApp());
}

class DHRMSApp extends StatelessWidget {
  const DHRMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Health - Digital Health Record Management System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // Healthcare green
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(
          nextScreen: _wrapWithConfigSwitcher(const RoleSelectionScreen()),
        ),
        '/role-selection': (context) =>
            _wrapWithConfigSwitcher(const RoleSelectionScreen()),
        '/login': (context) => _wrapWithConfigSwitcher(const LoginScreen()),
        '/who-login': (context) =>
            _wrapWithConfigSwitcher(const WhoLoginScreen()),
        '/sho-login': (context) =>
            _wrapWithConfigSwitcher(const ShoLoginScreen()),
        '/patient-registration': (context) =>
            _wrapWithConfigSwitcher(PatientRegistrationScreen()),
        '/qr-scanner': (context) => _wrapWithConfigSwitcher(QRScannerScreen()),
        '/patient-dashboard': (context) {
          final userData =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          // Extract UHID from patient data - prioritize actual UHID field over database IDs
          final uhid =
              userData?['uhid'] ??
              userData?['UHID'] ??
              userData?['patientId'] ??
              userData?['patient_id'];
          return _wrapWithConfigSwitcher(
            PatientDashboardScreen(
              uhid: uhid?.toString(),
              patientData: userData,
            ),
          );
        },
        '/hospital-staff-dashboard': (context) {
          final userData =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          print('🛣️ Route userData: $userData');
          print('🛣️ Route userData type: ${userData.runtimeType}');

          // Check if user is a doctor to show the new dashboard
          final isDoctorLogin =
              userData != null &&
              (userData.containsKey('doctorId') ||
                  userData.containsKey('doctorName') ||
                  userData.containsKey('specialization') ||
                  userData['staffRole'] == 'Doctor' ||
                  userData['designation'] == 'Doctor');

          if (isDoctorLogin) {
            print('🏥 Routing to new doctor dashboard');
            return _wrapWithConfigSwitcher(
              HospitalDoctorDashboardScreen(doctorData: userData),
            );
          } else {
            print('🏥 Routing to generic staff dashboard');
            return _wrapWithConfigSwitcher(
              HospitalStaffDashboard(userData: userData ?? {}),
            );
          }
        },
        '/regional-officer-dashboard': (context) {
          final userData =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return _wrapWithConfigSwitcher(
            RegionalOfficerDashboard(userData: userData ?? {}),
          );
        },
        '/digital-card': (context) {
          final uhid = ModalRoute.of(context)?.settings.arguments as String?;
          return _wrapWithConfigSwitcher(
            DigitalHealthCardScreen(uhid: uhid ?? ''),
          );
        },
        '/wearable-data': (context) {
          final userData =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return _wrapWithConfigSwitcher(
            WearableDataScreen(userData: userData ?? {}),
          );
        },
        '/ai-health-chatbot': (context) =>
            _wrapWithConfigSwitcher(const AIHealthChatBotScreen()),
        '/hospital-registration': (context) =>
            _wrapWithConfigSwitcher(HospitalRegistrationScreen()),
        '/hospital-admin-login': (context) =>
            _wrapWithConfigSwitcher(HospitalAdminLoginScreen()),
        '/hospital-admin-dashboard': (context) =>
            _wrapWithConfigSwitcher(HospitalAdminDashboardScreen()),
        '/hospital-role-selection': (context) =>
            _wrapWithConfigSwitcher(const HospitalRoleSelectionScreen()),
        '/hospital-doctor-login': (context) =>
            _wrapWithConfigSwitcher(HospitalDoctorLoginScreen()),
        '/hospital-assistant-login': (context) =>
            _wrapWithConfigSwitcher(HospitalAssistantLoginScreen()),
      },
    );
  }

  /// Wrap screens with configuration switcher in debug mode only
  Widget _wrapWithConfigSwitcher(Widget child) {
    if (kDebugMode) {
      return ConfigurationSwitcher(child: child);
    }
    return child;
  }
}
