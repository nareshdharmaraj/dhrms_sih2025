import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/config/app_config.dart';
import 'screens/role_selection_screen.dart';
import 'screens/login_screen.dart';
import 'screens/patient_dashboard.dart';
import 'screens/hospital_staff_dashboard.dart';
import 'screens/regional_officer_dashboard.dart';
import 'screens/patient_registration_screen.dart';
import 'screens/digital_health_card_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/wearable_data_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");

    // Configure backend URLs from .env if available
    final localWeb = dotenv.env['API_URL_LOCAL_WEB'] ?? 'http://localhost:3000';
    final localMobile =
        dotenv.env['API_URL_LOCAL_MOBILE'] ?? 'http://10.0.2.2:3000';
    final cloud =
        dotenv.env['API_URL_CLOUD'] ?? 'https://your-app.onrender.com';

    print('🔧 Environment loaded:');
    print('   Local Web: $localWeb');
    print('   Local Mobile: $localMobile');
    print('   Cloud: $cloud');
    print('   Current Backend: ${AppConfig.environment}');
    print('   Base URL: ${AppConfig.baseUrl}');
  } catch (e) {
    print('⚠️ Could not load .env file: $e');
    print('🔧 Using default configuration');
  }

  runApp(const DHRMSApp());
}

class DHRMSApp extends StatelessWidget {
  const DHRMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DHRMS - Digital Health Record Management System',
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
        '/': (context) => const RoleSelectionScreen(),
        '/login': (context) => const LoginScreen(),
        '/patient-registration': (context) => PatientRegistrationScreen(),
        '/qr-scanner': (context) => QRScannerScreen(),
        '/patient-dashboard': (context) {
          final userData =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return PatientDashboard(userData: userData ?? {});
        },
        '/hospital-staff-dashboard': (context) {
          final userData =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return HospitalStaffDashboard(userData: userData ?? {});
        },
        '/regional-officer-dashboard': (context) {
          final userData =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return RegionalOfficerDashboard(userData: userData ?? {});
        },
        '/digital-card': (context) {
          final uhid = ModalRoute.of(context)?.settings.arguments as String?;
          return DigitalHealthCardScreen(uhid: uhid ?? '');
        },
        '/wearable-data': (context) {
          final userData =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return WearableDataScreen(userData: userData ?? {});
        },
      },
    );
  }
}
