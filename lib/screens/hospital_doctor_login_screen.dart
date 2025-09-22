import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/hospital_api_service.dart';
import '../services/api_client.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class HospitalDoctorLoginScreen extends StatefulWidget {
  const HospitalDoctorLoginScreen({super.key});

  @override
  _HospitalDoctorLoginScreenState createState() =>
      _HospitalDoctorLoginScreenState();
}

class _HospitalDoctorLoginScreenState extends State<HospitalDoctorLoginScreen> {
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
      final data = await HospitalApiService.doctorLogin(
        _selectedHospital!['hospitalId'],
        _usernameController.text.trim(),
        _passwordController.text,
      );

      print('🔍 Login response data: $data');
      print('🔍 Doctor data: ${data['data']['doctor']}');

      // Store token and doctor data
      await ApiClient.setAuthToken(data['data']['token']);
      
      // Also store doctor data in SharedPreferences as backup
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('doctor_data', jsonEncode(data['data']['doctor']));

      // Navigate to doctor dashboard
      Navigator.pushReplacementNamed(
        context,
        '/hospital-staff-dashboard',
        arguments: data['data']['doctor'],
      );
    } catch (e) {
      _showErrorDialog('Login failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Login'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF64B5F6), Color(0xFF2196F3)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.local_hospital,
                          size: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Doctor Portal',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Login to access patient records',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Hospital Selection
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: _isLoadingHospitals
                          ? const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : DropdownButtonFormField<Map<String, dynamic>>(
                              value: _selectedHospital,
                              decoration: const InputDecoration(
                                labelText: 'Select Hospital',
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.business),
                              ),
                              items: _hospitals.map((hospital) {
                                return DropdownMenuItem<Map<String, dynamic>>(
                                  value: hospital,
                                  child: Text(
                                    hospital['name'] ?? 'Unknown Hospital',
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedHospital = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a hospital';
                                }
                                return null;
                              },
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Username Field
                  CustomTextField(
                    controller: _usernameController,
                    labelText: 'Username',
                    prefixIcon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Password Field
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

                  const SizedBox(height: 30),

                  // Login Button
                  CustomButton(
                    text: 'Login as Doctor',
                    onPressed: _isLoading ? null : _login,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: 20),

                  // Help Text
                  Center(
                    child: Text(
                      'Contact hospital admin for credentials',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
