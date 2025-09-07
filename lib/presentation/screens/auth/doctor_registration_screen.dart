import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_styles.dart';

class DoctorRegistrationScreen extends StatefulWidget {
  const DoctorRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<DoctorRegistrationScreen> createState() => _DoctorRegistrationScreenState();
}

class _DoctorRegistrationScreenState extends State<DoctorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _doctorNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _experienceController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _hospitalNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _consultationFeeController = TextEditingController();

  String _selectedSpecialty = 'General Medicine';
  String _selectedDepartment = 'General Medicine';
  String _selectedGender = 'Male';
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  final List<String> _specialties = [
    'General Medicine',
    'Cardiology',
    'Neurology',
    'Orthopedics',
    'Pediatrics',
    'Gynecology',
    'Dermatology',
    'Psychiatry',
    'Radiology',
    'Pathology',
    'Anesthesiology',
    'Emergency Medicine',
    'Surgery',
    'Oncology',
    'Endocrinology',
    'Gastroenterology',
    'Pulmonology',
    'Nephrology',
    'Ophthalmology',
    'ENT'
  ];

  final List<String> _departments = [
    'General Medicine',
    'Cardiology',
    'Neurology',
    'Orthopedics',
    'Pediatrics',
    'Gynecology',
    'Emergency',
    'Surgery',
    'ICU',
    'OPD',
    'Radiology',
    'Pathology',
    'Pharmacy'
  ];

  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _doctorNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _licenseNumberController.dispose();
    _experienceController.dispose();
    _qualificationController.dispose();
    _hospitalNameController.dispose();
    _addressController.dispose();
    _consultationFeeController.dispose();
    super.dispose();
  }

  Future<void> _submitDoctorRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Generate request ID
      String requestId = 'DR${DateTime.now().millisecondsSinceEpoch}';

      // Prepare doctor registration data
      final doctorRequestData = {
        'requestId': requestId,
        'doctorName': _doctorNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text.trim(),
        'licenseNumber': _licenseNumberController.text.trim(),
        'experience': _experienceController.text.trim(),
        'qualification': _qualificationController.text.trim(),
        'specialty': _selectedSpecialty,
        'department': _selectedDepartment,
        'gender': _selectedGender,
        'hospitalName': _hospitalNameController.text.trim(),
        'address': _addressController.text.trim(),
        'consultationFee': _consultationFeeController.text.trim(),
        'status': 'Pending',
        'submittedAt': DateTime.now().toIso8601String(),
        'role': 'doctor',
      };

      // Mock API call - in real implementation, this would call the backend
      // await ApiService.submitDoctorRegistrationRequest(doctorRequestData);
      await Future.delayed(Duration(seconds: 2));
      
      // Log the request data for development purposes
      print('Doctor registration request: $doctorRequestData');
      
      // Show success dialog
      _showSuccessDialog(requestId);

    } catch (e) {
      _showErrorDialog('Registration request failed: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(String requestId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 8),
            Text('Request Submitted'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your doctor registration request has been submitted successfully.'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primaryBlue),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Request ID:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          requestId,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: requestId));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Request ID copied to clipboard')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Your request will be reviewed by the Hospital Administrator. You will be notified once approved.',
              style: TextStyle(color: AppColors.grey600),
            ),
            SizedBox(height: 8),
            Text(
              'Status: Pending Hospital Approval',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryOrange,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to role selection
            },
            child: Text('Back to Login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: AppColors.primaryRed),
            SizedBox(width: 8),
            Text('Registration Failed'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Registration'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Personal Information Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _doctorNameController,
                      decoration: InputDecoration(
                        labelText: 'Doctor Full Name *',
                        hintText: 'Dr. Full Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Doctor name is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email Address *',
                              hintText: 'doctor@hospital.com',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email is required';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'Phone Number *',
                              hintText: '10-digit number',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.phone),
                            ),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Phone is required';
                              }
                              if (value.trim().length != 10) {
                                return 'Must be 10 digits';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.people),
                      ),
                      items: _genders.map((gender) {
                        return DropdownMenuItem(value: gender, child: Text(gender));
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedGender = value!);
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        hintText: 'Complete address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Professional Information Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Professional Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _licenseNumberController,
                      decoration: InputDecoration(
                        labelText: 'Medical License Number *',
                        hintText: 'Enter license number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.verified),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'License number is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _qualificationController,
                      decoration: InputDecoration(
                        labelText: 'Qualification *',
                        hintText: 'MBBS, MD, etc.',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.school),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Qualification is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedSpecialty,
                            decoration: InputDecoration(
                              labelText: 'Specialty',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.medical_services),
                            ),
                            items: _specialties.map((specialty) {
                              return DropdownMenuItem(value: specialty, child: Text(specialty));
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedSpecialty = value!);
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedDepartment,
                            decoration: InputDecoration(
                              labelText: 'Department',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.business),
                            ),
                            items: _departments.map((dept) {
                              return DropdownMenuItem(value: dept, child: Text(dept));
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedDepartment = value!);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _experienceController,
                            decoration: InputDecoration(
                              labelText: 'Experience (Years)',
                              hintText: 'Years of experience',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.timeline),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _consultationFeeController,
                            decoration: InputDecoration(
                              labelText: 'Consultation Fee (₹)',
                              hintText: 'Fee amount',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.currency_rupee),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _hospitalNameController,
                      decoration: InputDecoration(
                        labelText: 'Hospital Name *',
                        hintText: 'Hospital where you want to work',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_hospital),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Hospital name is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Account Security Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Security',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password *',
                              hintText: 'Create password',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                                onPressed: () {
                                  setState(() => _passwordVisible = !_passwordVisible);
                                },
                              ),
                            ),
                            obscureText: !_passwordVisible,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Password is required';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password *',
                              hintText: 'Re-enter password',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_confirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                                onPressed: () {
                                  setState(() => _confirmPasswordVisible = !_confirmPasswordVisible);
                                },
                              ),
                            ),
                            obscureText: !_confirmPasswordVisible,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please confirm password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitDoctorRequest,
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Submitting...'),
                            ],
                          )
                        : Text('Submit Request'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
