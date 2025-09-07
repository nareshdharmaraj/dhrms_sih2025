import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_styles.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
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

  Color _getRoleColor() {
    switch (widget.userRole) {
      case AppConstants.roleNormalUser:
        return AppColors.userRole;
      case AppConstants.roleHospital:
        return AppColors.hospitalRole;
      case AppConstants.roleRegionalOfficer:
        return AppColors.regionalOfficerRole;
      default:
        return AppColors.primaryBlue;
    }
  }

  IconData _getRoleIcon() {
    switch (widget.userRole) {
      case AppConstants.roleNormalUser:
        return Icons.person;
      case AppConstants.roleHospital:
        return Icons.local_hospital;
      case AppConstants.roleRegionalOfficer:
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        username,
        password,
        widget.userRole,
      );

      if (success) {
        // Login successful
        _navigateToDashboard();
      } else {
        // Login failed
        _showErrorDialog(
          'Invalid credentials. Please check your username and password.',
        );
      }
    } catch (e) {
      _showErrorDialog('Login failed: ${e.toString()}');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _navigateToDashboard() {
    Widget dashboardScreen;

    switch (widget.userRole) {
      case AppConstants.roleNormalUser:
        dashboardScreen = const UserDashboardScreen();
        break;
      case AppConstants.roleHospital:
        dashboardScreen = const HospitalDashboardScreen();
        break;
      case AppConstants.roleRegionalOfficer:
        dashboardScreen = const RegionalDashboardScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => dashboardScreen),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDemoCredentials() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_getRoleDisplayName()} Login'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please enter your registered credentials to access the system.',
            ),
            SizedBox(height: 12),
            Text(
              'If you don\'t have an account, please contact your administrator.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = _getRoleColor();

    return Scaffold(
      backgroundColor: roleColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppColors.white),
            onPressed: _showDemoCredentials,
            tooltip: 'Show demo credentials',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Role Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(_getRoleIcon(), size: 40, color: roleColor),
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),

                    // Role Title
                    Text(
                      _getRoleDisplayName(),
                      style: AppTextStyles.headline4.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.marginSmall),

                    Text(
                      'Please sign in to continue',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Login Form
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppDimensions.radiusLarge * 2),
                    topRight: Radius.circular(AppDimensions.radiusLarge * 2),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppDimensions.marginLarge),

                      // Username Field
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          hintText: 'Enter your username',
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: roleColor,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMedium,
                            ),
                            borderSide: BorderSide(color: roleColor, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.marginMedium),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: roleColor,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: roleColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMedium,
                            ),
                            borderSide: BorderSide(color: roleColor, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.marginLarge),

                      // Login Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: roleColor,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.paddingMedium,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMedium,
                            ),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Sign In',
                                style: AppTextStyles.buttonLarge.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                      ),
                      const SizedBox(height: AppDimensions.marginMedium),

                      // Demo Credentials Button
                      TextButton(
                        onPressed: _showDemoCredentials,
                        child: Text(
                          'Show Demo Credentials',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: roleColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Footer
                      Text(
                        'MyHealth - Digital Health Record Management System',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
