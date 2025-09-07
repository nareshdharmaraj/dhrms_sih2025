import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';
import 'doctor_dashboard_screen.dart';

class DoctorLoginScreen extends StatefulWidget {
  final List<Map<String, dynamic>> hospitalDoctors;

  const DoctorLoginScreen({super.key, required this.hospitalDoctors});

  @override
  State<DoctorLoginScreen> createState() => _DoctorLoginScreenState();
}

class _DoctorLoginScreenState extends State<DoctorLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _doctorIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _doctorIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    final doctorId = _doctorIdController.text.trim();
    final password = _passwordController.text.trim();

    // Find doctor by ID
    final doctor = widget.hospitalDoctors.firstWhere(
      (doc) => doc['doctorId'] == doctorId,
      orElse: () => {},
    );

    if (doctor.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Doctor ID not found. Please check your credentials.');
      return;
    }

    // Mock password validation (in real app, this would be done on backend)
    final expectedPassword =
        'doc${doctorId.toLowerCase()}'; // Simple mock password

    if (password != expectedPassword && password != 'password123') {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Invalid password. Please try again.');
      return;
    }

    setState(() {
      _isLoading = false;
    });

    // Navigate to doctor dashboard
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorDashboardScreen(doctorData: doctor),
      ),
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Doctor Login'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.marginLarge),

              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.local_hospital,
                        size: 40,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),
                    Text(
                      'Doctor Portal',
                      style: AppTextStyles.headline4.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.marginSmall),
                    Text(
                      'Sign in to access your patients and prescriptions',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.grey600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.marginExtraLarge),

              // Login Form
              Card(
                elevation: AppDimensions.elevationMedium,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusLarge,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Login Credentials',
                          style: AppTextStyles.headline6.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.marginLarge),

                        // Doctor ID Field
                        TextFormField(
                          controller: _doctorIdController,
                          decoration: InputDecoration(
                            labelText: 'Doctor ID',
                            hintText: 'Enter your doctor ID',
                            prefixIcon: const Icon(Icons.badge),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMedium,
                              ),
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your doctor ID';
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
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMedium,
                              ),
                            ),
                          ),
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _login(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: AppDimensions.marginLarge),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMedium,
                                ),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: AppColors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Login to Doctor Dashboard',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.marginLarge),

              // Demo Credentials
              Card(
                color: AppColors.info.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.info,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Demo Credentials',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.info,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.marginSmall),
                      Text(
                        'Use any doctor ID from the hospital\'s doctor list with password: "password123"',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey700,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.marginSmall),
                      ...widget.hospitalDoctors
                          .take(3)
                          .map(
                            (doctor) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '• ${doctor['doctorId']} - ${doctor['name']}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.grey600,
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.marginLarge),

              // Available Doctors List
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Doctors',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.marginMedium),

                      ...widget.hospitalDoctors.map(
                        (doctor) => ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primaryBlue.withValues(
                              alpha: 0.1,
                            ),
                            child: Text(
                              doctor['name']
                                  .toString()
                                  .substring(0, 2)
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          title: Text(
                            doctor['name'].toString(),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${doctor['doctorId']} • ${doctor['specialization']}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.grey600,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.login, size: 20),
                            onPressed: () {
                              _doctorIdController.text = doctor['doctorId']
                                  .toString();
                            },
                          ),
                        ),
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
  }
}
