import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../utils/app_constants.dart';
import 'patient_register_screen.dart';

class PatientLoginScreen extends StatefulWidget {
  const PatientLoginScreen({super.key});

  @override
  State<PatientLoginScreen> createState() => _PatientLoginScreenState();
}

class _PatientLoginScreenState extends State<PatientLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF81C784), // Light green
              Color(0xFF4CAF50), // Patient green
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 80.0 : 24.0,
                vertical: 32.0,
              ),
              child: Column(
                children: [
                  _buildHeader(context, isTablet),
                  SizedBox(height: isTablet ? 60 : 40),
                  _buildLoginForm(context, isTablet),
                  SizedBox(height: isTablet ? 40 : 30),
                  _buildCreateAccountSection(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isTablet) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.person,
            size: isTablet ? 60 : 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Patient Login',
          style: TextStyle(
            fontSize: isTablet ? 32 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Access your health records',
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _emailController,
              labelText: 'Email or Health ID',
              hintText: 'Enter your email or UHI',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email or Health ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _passwordController,
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              isPasswordVisible: !_obscurePassword,
              onTogglePasswordVisibility: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Implement forgot password
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Forgot password feature coming soon!'),
                    ),
                  );
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: AppConstants.primaryGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Login',
              onPressed: _isLoading ? null : _handleLogin,
              isLoading: _isLoading,
              backgroundColor: AppConstants.successGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateAccountSection(BuildContext context) {
    return Column(
      children: [
        Text(
          'Don\'t have an account?',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PatientRegisterScreen(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Text(
              'Create Account',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Use the roles endpoint directly since that's what's working in backend logs
      var loginUrl = '${AppConstants.baseUrl}/roles/login';
      print('=== LOGIN URL DEBUG ===');
      print('Base URL: ${AppConstants.baseUrl}');
      print('Using working endpoint: $loginUrl');
      print('Request body: ${json.encode({
        'username': _emailController.text.trim(),
        'password': _passwordController.text,
      })}');
      print('=======================');
      
      // Make actual API call to backend using the working endpoint
      var response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _emailController.text.trim(),  // Use 'username' instead of 'usernameOrEmail'
          'password': _passwordController.text,
        }),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      print('Login API Response Code: ${response.statusCode}');
      print('Login API Response Body: ${response.body}');
      print('Raw response body type: ${response.body.runtimeType}');
      print('Response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        print('=== FLUTTER LOGIN DEBUG ===');
        print('Full Response Data: ${json.encode(responseData)}');
        print('Response Keys: ${responseData.keys.toList()}');
        print('Has patientData key: ${responseData.containsKey('patientData')}');
        print('PatientData value: ${responseData['patientData']}');
        print('PatientData type: ${responseData['patientData']?.runtimeType}');
        if (responseData['patientData'] != null) {
          print('PatientData keys: ${responseData['patientData'].keys.toList()}');
          print('UHID in patientData: ${responseData['patientData']['uhid']}');
          print('BloodGroup in patientData: ${responseData['patientData']['bloodGroup']}');
          print('DOB in patientData: ${responseData['patientData']['dateOfBirth']}');
        }
        print('==============================');
        
        if (responseData['success'] == true && responseData['userType'] == 'patient') {
          // Extract patient data from the API response
          final rawUserData = responseData['user'];
          final apiPatientData = responseData['patientData']; // Complete patient data from backend
          
          print('Raw API User Data: $rawUserData');
          print('API Patient Data: $apiPatientData');
          
          Map<String, dynamic> patientData = {};
          
          // Use the complete patient data from backend if available
          if (apiPatientData != null) {
            patientData = Map<String, dynamic>.from(apiPatientData);
            print('Using complete patient data from backend: $patientData');
          } else {
            // Fallback: Try to fetch patient data using a separate API call
            print('No patient data in login response, attempting to fetch separately...');
            final fetchedPatientData = await _fetchPatientDataById(rawUserData['id']);
            if (fetchedPatientData != null) {
              patientData = fetchedPatientData;
              print('Successfully fetched patient data separately: $patientData');
            } else {
              // Last resort - map basic user data but ensure ID is included for dashboard fallback
              patientData = _mapUserDataToPatientData(rawUserData);
              // Ensure the patient ID is always available for dashboard fetching
              patientData['id'] = rawUserData['id'];
              patientData['username'] = rawUserData['username'];
              print('Using basic user data with defaults: $patientData');
            }
          }

          setState(() {
            _isLoading = false;
          });

          print('Final Patient Data for Dashboard: $patientData');
          print('Navigating with arguments type: ${patientData.runtimeType}');
          print('Arguments keys: ${patientData.keys.toList()}');
          print('UHID value: ${patientData['uhid']}');
          print('Blood Group value: ${patientData['bloodGroup']}');
          print('Date of Birth value: ${patientData['dateOfBirth']}');

          // Navigate to dashboard with real patient data using named route
          Navigator.pushReplacementNamed(
            context,
            '/patient-dashboard',
            arguments: patientData,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful!'),
              backgroundColor: AppConstants.successGreen,
            ),
          );
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Login failed - not a patient account'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else if (response.statusCode == 401) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid credentials. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Login error: $e');
      setState(() {
        _isLoading = false;
      });
      
      // Fallback: Create sample patient data for testing
      final samplePatientData = {
        'uhid': 'UHID123456789',
        'fullName': 'John Doe',
        'email': _emailController.text.trim(),
        'bloodGroup': 'O+',
        'blood_group': 'O+', // Alternative field name
        'bloodType': 'O+', // Alternative field name
        'dateOfBirth': '1990-05-15',
        'date_of_birth': '1990-05-15', // Alternative field name
        'dob': '1990-05-15', // Alternative field name
        'phone': '+1234567890',
        'address': '123 Main St, City, State 12345',
        'healthStatus': 'Good',
        'gender': 'Male',
        'emergencyContacts': [
          {
            'name': 'Jane Doe',
            'relationship': 'Spouse',
            'phone': '+1234567891'
          },
          {
            'name': 'Dr. Smith',
            'relationship': 'Doctor',
            'phone': '+1234567892'
          }
        ]
      };
      
      print('Using fallback sample data: $samplePatientData');
      
      Navigator.pushReplacementNamed(
        context,
        '/patient-dashboard',
        arguments: samplePatientData,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login using sample data (Network error: $e)'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // Helper method to map user data to patient data format
  Map<String, dynamic> _mapUserDataToPatientData(Map<String, dynamic> userData) {
    return {
      // Identity fields
      'uhid': userData['uhid'] ?? userData['id'], // Use user ID as UHID fallback
      'fullName': userData['fullName'],
      'email': userData['email'],
      'phone': userData['phone'],
      
      // Set default values for missing fields
      'bloodGroup': 'Unknown',
      'blood_group': 'Unknown',
      'bloodType': 'Unknown',
      
      // Default date - will show as 'Unknown' age
      'dateOfBirth': null,
      'date_of_birth': null,
      'dob': null,
      
      // Other defaults
      'gender': 'Unknown',
      'address': '',
      'healthStatus': 'Unknown',
      
      // Empty emergency contacts
      'emergencyContacts': [],
      
      // Empty medical info
      'medicalHistory': [],
      'allergies': [],
      'currentMedications': [],
      
      // System fields
      'isActive': true,
      'registrationDate': DateTime.now().toIso8601String(),
    };
  }

  // Fetch complete patient data by patient ID
  Future<Map<String, dynamic>?> _fetchPatientDataById(String patientId) async {
    try {
      print('Attempting to fetch patient data for ID: $patientId');
      
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/roles/patients/$patientId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Patient fetch API Response Code: ${response.statusCode}');
      print('Patient fetch API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['patient'] != null) {
          final patientData = responseData['patient'];
          print('Successfully fetched complete patient data: $patientData');
          return Map<String, dynamic>.from(patientData);
        }
      }
      
      print('Failed to fetch patient data - API returned error');
      return null;
    } catch (e) {
      print('Error fetching patient data: $e');
      return null;
    }
  }
}
