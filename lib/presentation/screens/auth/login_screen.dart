import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../user/user_dashboard_screen.dart';
import '../hospital/hospital_dashboard_screen.dart';
import '../regional_officer/regional_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  final String userRole;

  const LoginScreen({super.key, required this.userRole});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _proceedWithRoleAccess();
    });
  }

  String _getRoleDisplayName() {
    switch (widget.userRole) {
      case AppConstants.roleNormalUser:
        return 'Migrant Worker';
      case AppConstants.roleHospital:
        return 'Hospital/Medical Staff';
      case AppConstants.roleRegionalOfficer:
        return 'Regional Health Officer';
      default:
        return 'User';
    }
  }

  Future<void> _proceedWithRoleAccess() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Validate role before proceeding
      if (widget.userRole.isEmpty) {
        throw Exception('Invalid user role');
      }
      
      final success = await authProvider.loginWithRoleOnly(widget.userRole);

      if (mounted && success) {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          _navigateToDashboard();
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to access dashboard. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Access failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToDashboard() {
    if (!mounted) return;
    
    Widget dashboard;
    switch (widget.userRole) {
      case AppConstants.roleNormalUser:
        dashboard = const UserDashboardScreen();
        break;
      case AppConstants.roleHospital:
        dashboard = const HospitalDashboardScreen();
        break;
      case AppConstants.roleRegionalOfficer:
        dashboard = const RegionalDashboardScreen();
        break;
      default:
        // Fallback for unknown roles
        print('Unknown role: ${widget.userRole}, defaulting to UserDashboard');
        dashboard = const UserDashboardScreen();
    }

    try {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => dashboard),
      );
    } catch (e) {
      print('Navigation error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigation failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_getRoleDisplayName())),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _proceedWithRoleAccess,
                child: const Text('Continue to Dashboard'),
              ),
      ),
    );
  }
}
