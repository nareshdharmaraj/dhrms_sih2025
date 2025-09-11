import 'package:flutter/material.dart';
import 'screens/role_selection_screen.dart';
import 'screens/login_screen.dart';
import 'screens/patient_dashboard.dart';
import 'screens/hospital_staff_dashboard.dart';
import 'screens/regional_officer_dashboard.dart';
import 'screens/patient_registration_screen.dart';
import 'screens/digital_health_card_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/wearable_data_screen.dart';

void main() {
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
          final userData = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return PatientDashboard(userData: userData ?? {});
        },
        '/hospital-staff-dashboard': (context) {
          final userData = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return HospitalStaffDashboard(userData: userData ?? {});
        },
        '/regional-officer-dashboard': (context) {
          final userData = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return RegionalOfficerDashboard(userData: userData ?? {});
        },
        '/digital-card': (context) {
          final uhid = ModalRoute.of(context)?.settings.arguments as String?;
          return DigitalHealthCardScreen(uhid: uhid ?? '');
        },
        '/wearable-data': (context) {
          final userData = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return WearableDataScreen(userData: userData ?? {});
        },
      },
    );
  }
}
