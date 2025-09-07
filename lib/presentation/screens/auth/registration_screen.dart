import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Additional fields controllers
  final _specializationController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _hospitalTypeController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  String _selectedRole = AppConstants.roleNormalUser;
  String _selectedGender = 'male';
  String _selectedBloodGroup = 'O+';
  DateTime? _selectedDateOfBirth;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _specializations = [
    'General Medicine',
    'Cardiology',
    'Neurology',
    'Orthopedics',
    'Pediatrics',
    'Gynecology',
    'Dermatology',
    'Psychiatry',
    'Radiology',
    'Pathology'
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    _qualificationController.dispose();
    _hospitalTypeController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _aadhaarController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Widget _buildRoleSpecificFields() {
    switch (_selectedRole) {
      case AppConstants.roleDoctor:
        return Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'Professional Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _specializationController.text.isEmpty ? _specializations[0] : _specializationController.text,
              decoration: const InputDecoration(
                labelText: 'Specialization',
                prefixIcon: Icon(Icons.medical_services),
                border: OutlineInputBorder(),
              ),
              items: _specializations.map((specialization) {
                return DropdownMenuItem(
                  value: specialization,
                  child: Text(specialization),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _specializationController.text = value ?? _specializations[0];
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a specialization';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _qualificationController,
              decoration: const InputDecoration(
                labelText: 'Qualification',
                prefixIcon: Icon(Icons.school),
                border: OutlineInputBorder(),
                hintText: 'e.g., MBBS, MD, MS',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your qualification';
                }
                return null;
              },
            ),
          ],
        );

      case AppConstants.roleHospital:
        return Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'Hospital Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _hospitalTypeController.text.isEmpty ? 'private' : _hospitalTypeController.text,
              decoration: const InputDecoration(
                labelText: 'Hospital Type',
                prefixIcon: Icon(Icons.local_hospital),
                border: OutlineInputBorder(),
              ),
              items: ['private', 'government', 'trust', 'corporate'].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _hospitalTypeController.text = value ?? 'private';
                });
              },
            ),
          ],
        );

      case AppConstants.roleNormalUser:
      default:
        return Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _aadhaarController,
              decoration: const InputDecoration(
                labelText: 'Aadhaar Number',
                prefixIcon: Icon(Icons.credit_card),
                border: OutlineInputBorder(),
                hintText: 'Enter 12-digit Aadhaar number',
              ),
              keyboardType: TextInputType.number,
              maxLength: 12,
              validator: (value) {
                if (value == null || value.length != 12) {
                  return 'Please enter a valid 12-digit Aadhaar number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedBloodGroup,
              decoration: const InputDecoration(
                labelText: 'Blood Group',
                prefixIcon: Icon(Icons.bloodtype),
                border: OutlineInputBorder(),
              ),
              items: _bloodGroups.map((bloodGroup) {
                return DropdownMenuItem(
                  value: bloodGroup,
                  child: Text(bloodGroup),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBloodGroup = value ?? 'O+';
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emergencyContactController,
              decoration: const InputDecoration(
                labelText: 'Emergency Contact Number',
                prefixIcon: Icon(Icons.emergency),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.length != 10) {
                  return 'Please enter a valid 10-digit phone number';
                }
                return null;
              },
            ),
          ],
        );
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your date of birth'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Prepare additional data based on role
    Map<String, dynamic> additionalData = {
      'gender': _selectedGender,
      'dateOfBirth': _selectedDateOfBirth!.toIso8601String(),
      'address': {
        'street': _addressController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'pincode': _pincodeController.text,
      },
    };

    switch (_selectedRole) {
      case AppConstants.roleDoctor:
        additionalData.addAll({
          'specialization': _specializationController.text,
          'qualification': _qualificationController.text,
          'experience': 0,
        });
        break;
      case AppConstants.roleHospital:
        additionalData.addAll({
          'hospitalType': _hospitalTypeController.text,
        });
        break;
      case AppConstants.roleNormalUser:
        additionalData.addAll({
          'aadhaarNumber': _aadhaarController.text,
          'bloodGroup': _selectedBloodGroup,
          'emergencyContact': {
            'name': 'Emergency Contact',
            'relationship': 'Family',
            'phone': _emergencyContactController.text,
          },
        });
        break;
    }

    final success = await authProvider.register(
      _usernameController.text.trim(),
      _passwordController.text,
      _emailController.text.trim(),
      _selectedRole,
      _firstNameController.text.trim(),
      _lastNameController.text.trim(),
      _phoneController.text.trim(),
      additionalData,
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Welcome!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue[700]!,
                  Colors.blue[50]!,
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Icon(
                      Icons.person_add,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Join DHRMS',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your account to get started',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Role Selection
                            Text(
                              'Select Your Role',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedRole,
                              decoration: const InputDecoration(
                                labelText: 'I am a...',
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: AppConstants.roleNormalUser,
                                  child: const Text('Patient'),
                                ),
                                DropdownMenuItem(
                                  value: AppConstants.roleDoctor,
                                  child: const Text('Doctor'),
                                ),
                                DropdownMenuItem(
                                  value: AppConstants.roleHospital,
                                  child: const Text('Hospital Admin'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedRole = value ?? AppConstants.roleNormalUser;
                                });
                              },
                            ),

                            const SizedBox(height: 24),
                            Text(
                              'Basic Information',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Username
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                prefixIcon: Icon(Icons.account_circle),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a username';
                                }
                                if (value.length < 3) {
                                  return 'Username must be at least 3 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Email
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // First Name
                            TextFormField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'First Name',
                                prefixIcon: Icon(Icons.person_outline),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your first name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Last Name
                            TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Last Name',
                                prefixIcon: Icon(Icons.person_outline),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your last name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Phone
                            TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: Icon(Icons.phone),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.length != 10) {
                                  return 'Please enter a valid 10-digit phone number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Gender
                            DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: const InputDecoration(
                                labelText: 'Gender',
                                prefixIcon: Icon(Icons.wc),
                                border: OutlineInputBorder(),
                              ),
                              items: ['male', 'female', 'other'].map((gender) {
                                return DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender.toUpperCase()),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value ?? 'male';
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            // Date of Birth
                            InkWell(
                              onTap: _selectDateOfBirth,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date of Birth',
                                  prefixIcon: Icon(Icons.calendar_today),
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  _selectedDateOfBirth != null
                                      ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                                      : 'Select Date of Birth',
                                  style: TextStyle(
                                    color: _selectedDateOfBirth != null ? Colors.black : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Address Fields
                            TextFormField(
                              controller: _addressController,
                              decoration: const InputDecoration(
                                labelText: 'Address',
                                prefixIcon: Icon(Icons.location_on),
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _cityController,
                                    decoration: const InputDecoration(
                                      labelText: 'City',
                                      prefixIcon: Icon(Icons.location_city),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _stateController,
                                    decoration: const InputDecoration(
                                      labelText: 'State',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _pincodeController,
                              decoration: const InputDecoration(
                                labelText: 'Pincode',
                                prefixIcon: Icon(Icons.location_on),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                            ),

                            // Role-specific fields
                            _buildRoleSpecificFields(),

                            const SizedBox(height: 24),
                            Text(
                              'Security',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Password
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              obscureText: !_isPasswordVisible,
                              validator: (value) {
                                if (value == null || value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Confirm Password
                            TextFormField(
                              controller: _confirmPasswordController,
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                    });
                                  },
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              obscureText: !_isConfirmPasswordVisible,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),

                            // Register Button
                            ElevatedButton(
                              onPressed: authProvider.isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Create Account',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 16),

                            // Login Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Already have an account? '),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'Sign In',
                                    style: TextStyle(
                                      color: Colors.blue[700],
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
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
