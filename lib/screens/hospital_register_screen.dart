import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../utils/app_constants.dart';
import '../services/api_service.dart';
import 'hospital_dashboard_screen.dart';

class HospitalRegisterScreen extends StatefulWidget {
  const HospitalRegisterScreen({super.key});

  @override
  State<HospitalRegisterScreen> createState() => _HospitalRegisterScreenState();
}

class _HospitalRegisterScreenState extends State<HospitalRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hospitalNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  
  bool _isLoading = false;
  String _selectedStaffType = 'Doctor';
  String _selectedGender = 'Male';
  DateTime? _selectedDate;

  @override
  void dispose() {
    _hospitalNameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _licenseNumberController.dispose();
    _addressController.dispose();
    _aadhaarController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Staff Registration'),
        backgroundColor: AppConstants.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.lightBlue,
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
                          Icons.local_hospital,
                          size: 60,
                          color: AppConstants.primaryBlue,
                        ),
                        const SizedBox(height: AppConstants.mediumPadding),
                        Text(
                          'Hospital Staff Registration',
                          style: TextStyle(
                            fontSize: AppConstants.headingFont,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryText,
                          ),
                        ),
                        const SizedBox(height: AppConstants.smallPadding),
                        Text(
                          'Join as a healthcare provider',
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
                  
                  // Hospital Information
                  _buildSectionTitle('Hospital Information'),
                  const SizedBox(height: AppConstants.mediumPadding),
                  
                  CustomTextField(
                    controller: _hospitalNameController,
                    labelText: 'Hospital Name',
                    prefixIcon: Icons.local_hospital,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter hospital name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.mediumPadding),
                  
                  CustomTextField(
                    controller: _licenseNumberController,
                    labelText: 'Hospital License Number',
                    prefixIcon: Icons.verified,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter license number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.mediumPadding),
                  
                  CustomTextField(
                    controller: _addressController,
                    labelText: 'Hospital Address',
                    prefixIcon: Icons.location_on,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter hospital address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.largePadding),
                  
                  // Staff Information
                  _buildSectionTitle('Staff Information'),
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
                              return 'Please enter first name';
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
                              return 'Please enter last name';
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
                                activeColor: AppConstants.primaryBlue,
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
                                activeColor: AppConstants.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                  const SizedBox(height: AppConstants.mediumPadding),
                  
                  // Staff Type Selection
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
                          'Staff Type',
                          style: TextStyle(
                            fontSize: AppConstants.mediumFont,
                            color: AppConstants.mediumGrey,
                          ),
                        ),
                        const SizedBox(height: AppConstants.smallPadding),
                        DropdownButtonFormField<String>(
                          value: _selectedStaffType,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          items: AppConstants.hospitalStaffTypes.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedStaffType = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
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
                    backgroundColor: AppConstants.primaryBlue,
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
                            color: AppConstants.primaryBlue,
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
              primary: AppConstants.primaryBlue,
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

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      // Show success message and navigate
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Hospital staff account created successfully!'),
            backgroundColor: AppConstants.successGreen,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HospitalDashboardScreen(),
          ),
        );
      }
    }
  }
}
