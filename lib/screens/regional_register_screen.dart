import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../utils/app_constants.dart';
import 'regional_dashboard_screen.dart';

class RegionalRegisterScreen extends StatefulWidget {
  const RegionalRegisterScreen({super.key});

  @override
  State<RegionalRegisterScreen> createState() => _RegionalRegisterScreenState();
}

class _RegionalRegisterScreenState extends State<RegionalRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _officerIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _departmentController = TextEditingController();
  final _regionController = TextEditingController();
  
  bool _isLoading = false;
  String _selectedLevel = 'District Level';

  @override
  void dispose() {
    _fullNameController.dispose();
    _officerIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _departmentController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regional Officer Registration'),
        backgroundColor: AppConstants.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.lightPurple,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.largePadding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(AppConstants.largePadding),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppConstants.largeRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_balance,
                          size: 60,
                          color: AppConstants.primaryPurple,
                        ),
                        const SizedBox(height: AppConstants.mediumPadding),
                        Text(
                          'Regional Officer Registration',
                          style: TextStyle(
                            fontSize: AppConstants.headingFont,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryText,
                          ),
                        ),
                        const SizedBox(height: AppConstants.smallPadding),
                        Text(
                          'Register as a regional health officer',
                          style: TextStyle(
                            fontSize: AppConstants.mediumFont,
                            color: AppConstants.secondaryText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.largePadding),
                  
                  // Officer Information
                  _buildSectionTitle('Officer Information'),
                  const SizedBox(height: AppConstants.mediumPadding),
                  
                  CustomTextField(
                    controller: _fullNameController,
                    labelText: 'Full Name',
                    prefixIcon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.mediumPadding),
                  
                  CustomTextField(
                    controller: _officerIdController,
                    labelText: 'Officer ID',
                    prefixIcon: Icons.badge,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your officer ID';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.mediumPadding),
                  
                  CustomTextField(
                    controller: _departmentController,
                    labelText: 'Department',
                    prefixIcon: Icons.domain,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your department';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.mediumPadding),
                  
                  // Level Selection
                  Container(
                    padding: const EdgeInsets.all(AppConstants.mediumPadding),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
                      border: Border.all(color: AppConstants.lightGrey),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Officer Level',
                          style: TextStyle(
                            fontSize: AppConstants.mediumFont,
                            color: AppConstants.mediumGrey,
                          ),
                        ),
                        const SizedBox(height: AppConstants.smallPadding),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedLevel,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          items: AppConstants.regionalLevels.map((String level) {
                            return DropdownMenuItem<String>(
                              value: level,
                              child: Text(level),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedLevel = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.mediumPadding),
                  
                  CustomTextField(
                    controller: _regionController,
                    labelText: 'Region/District',
                    prefixIcon: Icons.location_on,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your region or district';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.largePadding),
                  
                  // Contact Information
                  _buildSectionTitle('Contact Information'),
                  const SizedBox(height: AppConstants.mediumPadding),
                  
                  CustomEmailField(controller: _emailController),
                  const SizedBox(height: AppConstants.mediumPadding),
                  
                  CustomPhoneField(controller: _phoneController),
                  const SizedBox(height: AppConstants.largePadding),
                  
                  // Security
                  _buildSectionTitle('Security'),
                  const SizedBox(height: AppConstants.mediumPadding),
                  
                  CustomPasswordField(
                    controller: _passwordController,
                    labelText: 'Password',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppConstants.mediumPadding),
                  
                  CustomPasswordField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm Password',
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.extraLargePadding),
                  
                  // Register Button
                  CustomButton(
                    text: _isLoading ? 'Creating Account...' : 'Create Account',
                    onPressed: _isLoading ? null : _handleRegister,
                    backgroundColor: AppConstants.primaryPurple,
                    isLoading: _isLoading,
                    elevation: 4,
                  ),
                  const SizedBox(height: AppConstants.mediumPadding),
                  
                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: AppConstants.secondaryText,
                          fontSize: AppConstants.mediumFont,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            color: AppConstants.primaryPurple,
                            fontSize: AppConstants.mediumFont,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: AppConstants.titleFont,
        fontWeight: FontWeight.bold,
        color: AppConstants.primaryText,
      ),
    );
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      // Show success message and navigate
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Regional officer account created successfully!'),
            backgroundColor: AppConstants.successGreen,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const RegionalDashboardScreen(),
          ),
        );
      }
    }
  }
}
