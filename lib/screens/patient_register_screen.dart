import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../utils/app_constants.dart';
import '../services/api_service.dart';
import 'patient_dashboard_screen.dart';

class PatientRegisterScreen extends StatefulWidget {
  const PatientRegisterScreen({super.key});

  @override
  State<PatientRegisterScreen> createState() => _PatientRegisterScreenState();
}

class _PatientRegisterScreenState extends State<PatientRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _addressController = TextEditingController();
  final _aadhaarController = TextEditingController();
  
  bool _isLoading = false;
  String _selectedGender = 'Male';
  DateTime? _selectedDate;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dateOfBirthController.dispose();
    _addressController.dispose();
    _aadhaarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Registration'),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.lightGreen,
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
                          Icons.personal_injury,
                          size: 60,
                          color: AppConstants.primaryGreen,
                        ),
                        const SizedBox(height: AppConstants.mediumPadding),
                        Text(
                          'Create Patient Account',
                          style: TextStyle(
                            fontSize: AppConstants.headingFont,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryText,
                          ),
                        ),
                        const SizedBox(height: AppConstants.smallPadding),
                        Text(
                          'Join the Digital Health Record Management System',
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
                  
                  // Personal Information
                  _buildSectionTitle('Personal Information'),
                  const SizedBox(height: AppConstants.mediumPadding),
                  
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _firstNameController,
                          labelText: 'First Name',
                          prefixIcon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your first name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: AppConstants.mediumPadding),
                      Expanded(
                        child: CustomTextField(
                          controller: _lastNameController,
                          labelText: 'Last Name',
                          prefixIcon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your last name';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.mediumPadding),
                  
                  CustomTextField(
                    controller: _dateOfBirthController,
                    labelText: 'Date of Birth',
                    prefixIcon: Icons.calendar_today,
                    onTap: () => _selectDateOfBirth(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your date of birth';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.mediumPadding),
                  
                  // Gender Selection
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
                          'Gender',
                          style: TextStyle(
                            fontSize: AppConstants.mediumFont,
                            color: AppConstants.mediumGrey,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Male'),
                                value: 'Male',
                                groupValue: _selectedGender,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedGender = value!;
                                  });
                                },
                                activeColor: AppConstants.primaryGreen,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Female'),
                                value: 'Female',
                                groupValue: _selectedGender,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedGender = value!;
                                  });
                                },
                                activeColor: AppConstants.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.mediumPadding),
                  
                  // Aadhaar Information
                  _buildSectionTitle('Identity Information'),
                  const SizedBox(height: AppConstants.mediumPadding),
                  
                  CustomTextField(
                    controller: _aadhaarController,
                    labelText: 'Aadhaar Number',
                    prefixIcon: Icons.credit_card,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Aadhaar number';
                      }
                      if (value.length != 12 || !RegExp(r'^\d{12}$').hasMatch(value)) {
                        return 'Aadhaar number must be exactly 12 digits';
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
                  const SizedBox(height: AppConstants.mediumPadding),
                  
                  CustomTextField(
                    controller: _addressController,
                    labelText: 'Address',
                    prefixIcon: Icons.location_on,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your address';
                      }
                      return null;
                    },
                  ),
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
                    backgroundColor: AppConstants.primaryGreen,
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
                            color: AppConstants.primaryGreen,
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

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppConstants.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateOfBirthController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Call the API to register patient
        final result = await ApiService.registerPatient(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phone: _phoneController.text.trim(),
          aadhaarNumber: _aadhaarController.text.trim(),
          dateOfBirth: _selectedDate?.toIso8601String() ?? '',
          gender: _selectedGender,
          address: {
            'street': _addressController.text.trim(),
            'city': 'Default City', // You can add separate fields for these
            'state': 'Default State',
            'zipCode': '000000',
            'country': 'India',
          },
        );

        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true && result['data']['success'] == true) {
          // Registration successful - show UHI to user
          final uhiId = result['data']['data']['uhi'];
          final fullName = result['data']['data']['fullName'];
          
          if (mounted) {
            // Show success dialog with UHI
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppConstants.successGreen,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      const Text('Registration Successful!'),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, $fullName!',
                        style: TextStyle(
                          fontSize: AppConstants.titleFont,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppConstants.lightGreen,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppConstants.primaryGreen),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Universal Health Identity (UHI):',
                              style: TextStyle(
                                fontSize: AppConstants.mediumFont,
                                fontWeight: FontWeight.w600,
                                color: AppConstants.primaryText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              uhiId,
                              style: TextStyle(
                                fontSize: AppConstants.titleFont,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.primaryGreen,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Please save this UHI ID safely. You will need it for accessing healthcare services.',
                              style: TextStyle(
                                fontSize: AppConstants.smallFont,
                                color: AppConstants.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    CustomButton(
                      text: 'Continue to Dashboard',
                      backgroundColor: AppConstants.primaryGreen,
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PatientDashboardScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          }
        } else {
          // Registration failed
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['data']['message'] ?? 'Registration failed'),
                backgroundColor: AppConstants.errorRed,
              ),
            );
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration failed: $e'),
              backgroundColor: AppConstants.errorRed,
            ),
          );
        }
      }
    }
  }
}
