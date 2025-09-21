import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/hospital_api_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'hospital_registration_screen.dart';
import 'hospital_admin_dashboard_screen.dart';

class HospitalAdminLoginScreen extends StatefulWidget {
  const HospitalAdminLoginScreen({super.key});

  @override
  _HospitalAdminLoginScreenState createState() =>
      _HospitalAdminLoginScreenState();
}

class _HospitalAdminLoginScreenState extends State<HospitalAdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  List<Map<String, dynamic>> _hospitals = [];
  Map<String, dynamic>? _selectedHospital;
  bool _isLoading = false;
  bool _isLoadingHospitals = false;

  @override
  void initState() {
    super.initState();
    _loadHospitals();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadHospitals() async {
    setState(() {
      _isLoadingHospitals = true;
    });

    try {
      final hospitals = await HospitalApiService.getHospitalList();
      setState(() {
        _hospitals = hospitals;
      });
    } catch (e) {
      _showErrorDialog('Failed to load hospitals: $e');
    } finally {
      setState(() {
        _isLoadingHospitals = false;
      });
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate() || _selectedHospital == null) {
      _showErrorDialog('Please fill all fields and select a hospital');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final data = await HospitalApiService.adminLogin(
        _selectedHospital!['hospitalId'],
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (data['success']) {
        // Store token and admin data
        await ApiService.setAuthToken(data['data']['token']);
        await _storeAdminData(data['data']['admin']);

        // Navigate to admin dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HospitalAdminDashboardScreen(),
          ),
        );
      } else {
        _showErrorDialog(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      _showErrorDialog('Login error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _storeAdminData(Map<String, dynamic> adminData) async {
    // Store admin data locally for future use
    // You can use SharedPreferences or another storage solution
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
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

  Widget _buildHospitalSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Hospital',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),

        // Hospital dropdown
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _isLoadingHospitals
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<Map<String, dynamic>>(
                    isExpanded: true,
                    hint: Text('Choose a hospital'),
                    value: _selectedHospital,
                    items: _hospitals.map((hospital) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: hospital,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              hospital['name'],
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '${hospital['location']['city']}, ${hospital['location']['state']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedHospital = value;
                      });
                    },
                  ),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40),

                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.local_hospital,
                          size: 60,
                          color: Colors.blue[700],
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Hospital Admin Login',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Manage your hospital staff and operations',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40),

                // Hospital selector
                _buildHospitalSelector(),

                SizedBox(height: 24),

                // Username field
                CustomTextField(
                  controller: _usernameController,
                  labelText: 'Username',
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    if (value.length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20),

                // Password field
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  prefixIcon: Icons.lock,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 32),

                // Login button
                CustomButton(
                  text: 'Login',
                  onPressed: _isLoading ? null : _login,
                  isLoading: _isLoading,
                ),

                SizedBox(height: 24),

                // Register new hospital link
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Don\'t see your hospital?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HospitalRegistrationScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Register New Hospital',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
