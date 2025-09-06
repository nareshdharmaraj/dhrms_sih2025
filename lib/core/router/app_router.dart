import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/auth/role_selection_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/user/user_dashboard_screen.dart';
import '../../presentation/screens/hospital/hospital_dashboard_screen.dart';
import '../../presentation/screens/regional_officer/regional_dashboard_screen.dart';
import '../../presentation/screens/user/profile_screen.dart';
import '../../presentation/screens/user/user_health_records_screen.dart';
import '../../presentation/screens/user/vitals_monitoring_screen.dart';
import '../../presentation/screens/user/telemedicine_screen.dart';
import '../../presentation/screens/user/emergency_sos_screen.dart';
import '../../presentation/screens/user/proximity_alerts_screen.dart';
import '../../presentation/screens/user/ai_health_bot_screen.dart';
import '../../presentation/screens/user/gamification_screen.dart';
import '../../presentation/screens/user/insurance_screen.dart';
import '../../presentation/screens/user/qr_scanner_screen.dart';
import '../../presentation/screens/user/settings_screen.dart';
import '../constants/app_constants.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: AppConstants.routeRoleSelection,
    routes: [
      // Authentication Routes
      GoRoute(
        path: AppConstants.routeRoleSelection,
        name: 'role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: AppConstants.routeLogin,
        name: 'login',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? '';
          return LoginScreen(userRole: role);
        },
      ),

      // User Dashboard Routes
      GoRoute(
        path: AppConstants.routeUserDashboard,
        name: 'user-dashboard',
        builder: (context, state) => const UserDashboardScreen(),
      ),

      // Hospital Dashboard Routes
      GoRoute(
        path: AppConstants.routeHospitalDashboard,
        name: 'hospital-dashboard',
        builder: (context, state) => const HospitalDashboardScreen(),
      ),

      // Regional Officer Dashboard Routes
      GoRoute(
        path: AppConstants.routeRegionalDashboard,
        name: 'regional-dashboard',
        builder: (context, state) => const RegionalDashboardScreen(),
      ),

      // User Feature Routes
      GoRoute(
        path: AppConstants.routeProfile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppConstants.routeHealthRecords,
        name: 'health-records',
        builder: (context, state) => const UserHealthRecordsScreen(),
      ),
      GoRoute(
        path: AppConstants.routeVitalsMonitoring,
        name: 'vitals',
        builder: (context, state) => const VitalsMonitoringScreen(),
      ),
      GoRoute(
        path: AppConstants.routeTelemedicine,
        name: 'telemedicine',
        builder: (context, state) => const TelemedicineScreen(),
      ),
      GoRoute(
        path: AppConstants.routeEmergencySOS,
        name: 'emergency',
        builder: (context, state) => const EmergencySosScreen(),
      ),
      GoRoute(
        path: AppConstants.routeProximityAlerts,
        name: 'proximity-alerts',
        builder: (context, state) => const ProximityAlertsScreen(),
      ),
      GoRoute(
        path: AppConstants.routeAIHealthBot,
        name: 'ai-health-bot',
        builder: (context, state) => const AIHealthBotScreen(),
      ),
      GoRoute(
        path: AppConstants.routeGamification,
        name: 'gamification',
        builder: (context, state) => const GamificationScreen(),
      ),
      GoRoute(
        path: AppConstants.routeInsurance,
        name: 'insurance',
        builder: (context, state) => const InsuranceScreen(),
      ),
      GoRoute(
        path: AppConstants.routeQRScanner,
        name: 'qr-scanner',
        builder: (context, state) => const QrScannerScreen(),
      ),
      GoRoute(
        path: AppConstants.routeSettings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppConstants.routeRoleSelection),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );

  static GoRouter get router => _router;

  // Navigation helper methods
  static void goToRoleSelection(BuildContext context) {
    context.go(AppConstants.routeRoleSelection);
  }

  static void goToLogin(BuildContext context, String role) {
    context.go('${AppConstants.routeLogin}?role=$role');
  }

  static void goToDashboard(BuildContext context, String role) {
    switch (role) {
      case AppConstants.roleNormalUser:
        context.go(AppConstants.routeUserDashboard);
        break;
      case AppConstants.roleHospital:
        context.go(AppConstants.routeHospitalDashboard);
        break;
      case AppConstants.roleRegionalOfficer:
        context.go(AppConstants.routeRegionalDashboard);
        break;
      default:
        context.go(AppConstants.routeRoleSelection);
    }
  }

  static void goToProfile(BuildContext context) {
    context.go(AppConstants.routeProfile);
  }

  static void goToHealthRecords(BuildContext context) {
    context.go(AppConstants.routeHealthRecords);
  }

  static void goToVitalsMonitoring(BuildContext context) {
    context.go(AppConstants.routeVitalsMonitoring);
  }

  static void goToTelemedicine(BuildContext context) {
    context.go(AppConstants.routeTelemedicine);
  }

  static void goToEmergencySOS(BuildContext context) {
    context.go(AppConstants.routeEmergencySOS);
  }

  static void goToProximityAlerts(BuildContext context) {
    context.go(AppConstants.routeProximityAlerts);
  }

  static void goToAIHealthBot(BuildContext context) {
    context.go(AppConstants.routeAIHealthBot);
  }

  static void goToGamification(BuildContext context) {
    context.go(AppConstants.routeGamification);
  }

  static void goToInsurance(BuildContext context) {
    context.go(AppConstants.routeInsurance);
  }

  static void goToQRScanner(BuildContext context) {
    context.go(AppConstants.routeQRScanner);
  }

  static void goToSettings(BuildContext context) {
    context.go(AppConstants.routeSettings);
  }

  static void logout(BuildContext context) {
    context.go(AppConstants.routeRoleSelection);
  }
}
