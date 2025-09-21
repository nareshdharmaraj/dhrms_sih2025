import 'package:flutter/material.dart';
import '../services/hospital_api_service.dart';
import '../services/api_client.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'hospital_admin_dashboard_screen.dart';

class HospitalRegistrationScreen extends StatefulWidget {
  const HospitalRegistrationScreen({super.key});

  @override
  _HospitalRegistrationScreenState createState() =>
      _HospitalRegistrationScreenState();
}

class _HospitalRegistrationScreenState
    extends State<HospitalRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  // Hospital details controllers
  final _hospitalNameController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _licenseIdController = TextEditingController();
  final _totalBedsController = TextEditingController();
  final _establishedYearController = TextEditingController();
  final _websiteController = TextEditingController();

  // Admin details controllers
  final _adminUsernameController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  final _adminNameController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _adminPhoneController = TextEditingController();

  String _selectedState = 'Maharashtra';
  String _selectedHospitalType = 'Private';
  final List<String> _selectedSpecialties = [];
  bool _emergencyServices = false;
  bool _ambulanceServices = false;
  bool _isLoading = false;

  final List<String> _states = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
  ];

  final List<String> _hospitalTypes = [
    'Government',
    'Private',
    'Semi-Government',
    'Trust',
    'Corporate',
  ];

  final List<String> _availableSpecialties = [
    'General Medicine',
    'Cardiology',
    'Neurology',
    'Orthopedics',
    'Pediatrics',
    'Gynecology',
    'Dermatology',
    'Psychiatry',
    'Surgery',
    'Anesthesiology',
    'Emergency Medicine',
    'Radiology',
    'Pathology',
    'Ophthalmology',
    'ENT',
    'Urology',
    'Nephrology',
    'Pulmonology',
    'Gastroenterology',
    'Endocrinology',
    'Oncology',
    'Rheumatology',
    'Plastic Surgery',
    'Neurosurgery',
    'Cardiac Surgery',
  ];

  @override
  void dispose() {
    _hospitalNameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _pincodeController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _registrationNumberController.dispose();
    _licenseIdController.dispose();
    _totalBedsController.dispose();
    _establishedYearController.dispose();
    _websiteController.dispose();
    _adminUsernameController.dispose();
    _adminPasswordController.dispose();
    _adminNameController.dispose();
    _adminEmailController.dispose();
    _adminPhoneController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _registerHospital() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final hospitalData = {
        'hospitalName': _hospitalNameController.text.trim(),
        'address': {
          'street': _streetController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _selectedState,
          'district': _districtController.text.trim(),
          'pincode': _pincodeController.text.trim(),
        },
        'contactNumber': _contactNumberController.text.trim(),
        'email': _emailController.text.trim(),
        'registrationNumber': _registrationNumberController.text.trim(),
        'licenseId': _licenseIdController.text.trim(),
        'hospitalType': _selectedHospitalType,
        'specialties': _selectedSpecialties,
        'totalBeds': int.tryParse(_totalBedsController.text) ?? 0,
        'emergencyServices': _emergencyServices,
        'ambulanceServices': _ambulanceServices,
        'website': _websiteController.text.trim().isNotEmpty
            ? _websiteController.text.trim()
            : null,
        'establishedYear': int.tryParse(_establishedYearController.text),
        'adminDetails': {
          'username': _adminUsernameController.text.trim(),
          'password': _adminPasswordController.text,
          'adminName': _adminNameController.text.trim(),
          'adminEmail': _adminEmailController.text.trim(),
          'adminPhone': _adminPhoneController.text.trim(),
        },
      };

      final data = await HospitalApiService.registerHospital(hospitalData);

      // Store token and admin data
      await ApiClient.setAuthToken(data['data']['token']);

      // Show success dialog
      _showSuccessDialog(data['data']);
    } catch (e) {
      _showErrorDialog('Registration error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Hospital Registered Successfully!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your hospital has been registered successfully.'),
            SizedBox(height: 16),
            Text(
              'Hospital ID: ${data['hospital']['hospitalId']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Admin ID: ${data['admin']['adminId']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Please save these IDs for future reference.',
              style: TextStyle(color: Colors.orange[700]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HospitalAdminDashboardScreen(),
                ),
              );
            },
            child: Text('Continue to Dashboard'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Registration Failed'),
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

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildHospitalDetailsPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hospital Information',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),

          CustomTextField(
            controller: _hospitalNameController,
            labelText: 'Hospital Name',
            prefixIcon: Icons.local_hospital,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter hospital name';
              }
              if (value.length < 2) {
                return 'Hospital name must be at least 2 characters';
              }
              return null;
            },
          ),

          SizedBox(height: 16),

          CustomTextField(
            controller: _streetController,
            labelText: 'Street Address',
            prefixIcon: Icons.location_on,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter street address';
              }
              return null;
            },
          ),

          SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _cityController,
                  labelText: 'City',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter city';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  controller: _districtController,
                  labelText: 'District',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter district';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedState,
                  decoration: InputDecoration(
                    labelText: 'State',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.map),
                  ),
                  items: _states.map((state) {
                    return DropdownMenuItem(value: state, child: Text(state));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedState = value!;
                    });
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  controller: _pincodeController,
                  labelText: 'Pincode',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter pincode';
                    }
                    if (value.length != 6) {
                      return 'Pincode must be 6 digits';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          CustomTextField(
            controller: _contactNumberController,
            labelText: 'Contact Number',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter contact number';
              }
              if (value.length != 10) {
                return 'Contact number must be 10 digits';
              }
              return null;
            },
          ),

          SizedBox(height: 16),

          CustomTextField(
            controller: _emailController,
            labelText: 'Email',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalDetailsPage2() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hospital Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),

          CustomTextField(
            controller: _registrationNumberController,
            labelText: 'Registration Number',
            prefixIcon: Icons.assignment,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter registration number';
              }
              return null;
            },
          ),

          SizedBox(height: 16),

          CustomTextField(
            controller: _licenseIdController,
            labelText: 'License ID',
            prefixIcon: Icons.verified,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter license ID';
              }
              return null;
            },
          ),

          SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedHospitalType,
            decoration: InputDecoration(
              labelText: 'Hospital Type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.business),
            ),
            items: _hospitalTypes.map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedHospitalType = value!;
              });
            },
          ),

          SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _totalBedsController,
                  labelText: 'Total Beds',
                  prefixIcon: Icons.hotel,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final beds = int.tryParse(value);
                      if (beds == null || beds <= 0) {
                        return 'Please enter a valid number';
                      }
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  controller: _establishedYearController,
                  labelText: 'Established Year',
                  prefixIcon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final year = int.tryParse(value);
                      if (year == null ||
                          year < 1800 ||
                          year > DateTime.now().year) {
                        return 'Please enter a valid year';
                      }
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          CustomTextField(
            controller: _websiteController,
            labelText: 'Website (Optional)',
            prefixIcon: Icons.web,
            keyboardType: TextInputType.url,
          ),

          SizedBox(height: 24),

          Text(
            'Services Available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),

          SizedBox(height: 16),

          CheckboxListTile(
            title: Text('Emergency Services'),
            value: _emergencyServices,
            onChanged: (value) {
              setState(() {
                _emergencyServices = value!;
              });
            },
          ),

          CheckboxListTile(
            title: Text('Ambulance Services'),
            value: _ambulanceServices,
            onChanged: (value) {
              setState(() {
                _ambulanceServices = value!;
              });
            },
          ),

          SizedBox(height: 24),

          Text(
            'Specialties',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Select the medical specialties available at your hospital',
            style: TextStyle(color: Colors.grey[600]),
          ),

          SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableSpecialties.map((specialty) {
              final isSelected = _selectedSpecialties.contains(specialty);
              return FilterChip(
                label: Text(specialty),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSpecialties.add(specialty);
                    } else {
                      _selectedSpecialties.remove(specialty);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminDetailsPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin Account Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Create an admin account to manage your hospital',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 24),

          CustomTextField(
            controller: _adminNameController,
            labelText: 'Admin Full Name',
            prefixIcon: Icons.person,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter admin name';
              }
              if (value.length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),

          SizedBox(height: 16),

          CustomTextField(
            controller: _adminUsernameController,
            labelText: 'Username',
            prefixIcon: Icons.account_circle,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter username';
              }
              if (value.length < 3) {
                return 'Username must be at least 3 characters';
              }
              if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                return 'Username can only contain letters, numbers, and underscores';
              }
              return null;
            },
          ),

          SizedBox(height: 16),

          CustomTextField(
            controller: _adminPasswordController,
            labelText: 'Password',
            prefixIcon: Icons.lock,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),

          SizedBox(height: 16),

          CustomTextField(
            controller: _adminEmailController,
            labelText: 'Admin Email',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter admin email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),

          SizedBox(height: 16),

          CustomTextField(
            controller: _adminPhoneController,
            labelText: 'Admin Phone',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter admin phone number';
              }
              if (value.length != 10) {
                return 'Phone number must be 10 digits';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hospital Registration'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  for (int i = 0; i < 3; i++)
                    Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: i <= _currentPage
                              ? Colors.blue[700]
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildHospitalDetailsPage(),
                  _buildHospitalDetailsPage2(),
                  _buildAdminDetailsPage(),
                ],
              ),
            ),

            // Navigation buttons
            Container(
              padding: EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        child: Text('Previous'),
                      ),
                    ),

                  if (_currentPage > 0) SizedBox(width: 16),

                  Expanded(
                    child: _currentPage < 2
                        ? ElevatedButton(
                            onPressed: _nextPage,
                            child: Text('Next'),
                          )
                        : CustomButton(
                            text: 'Register Hospital',
                            onPressed: _isLoading ? null : _registerHospital,
                            isLoading: _isLoading,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
