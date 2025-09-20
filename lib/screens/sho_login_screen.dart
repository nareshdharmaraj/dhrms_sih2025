import 'package:flutter/material.dart';
import '../models/sho.dart';
import '../services/sho_service.dart';
import 'sho_dashboard_screen.dart';

class ShoLoginScreen extends StatefulWidget {
  const ShoLoginScreen({super.key});

  @override
  _ShoLoginScreenState createState() => _ShoLoginScreenState();
}

class _ShoLoginScreenState extends State<ShoLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔍 Starting SHO login request...');
      final result = await ShoService.shoLogin(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      print('🔍 SHO login result: $result');

      if (result['success']) {
        print('🔍 Login successful, creating SHO object...');
        print('🔍 SHO data type: ${result['sho'].runtimeType}');
        print('🔍 SHO data: ${result['sho']}');
        
        try {
          final sho = SHO.fromJson(result['sho']);
          print('🔍 SHO object created successfully: ${sho.fullName}');
          print('🔍 SHO ID: ${sho.id}');
          print('🔍 SHO assigned state: ${sho.assignedState}');
          
          // Store the auth token in the SHO service
          if (result['token'] != null) {
            print('🔍 Storing auth token for future requests');
            // Note: Token is already stored in ShoService.shoLogin method
          }
          
          // Navigate to SHO dashboard
          print('🔍 About to navigate to SHO dashboard...');
          
          try {
            await Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  print('🔍 Building ShoDashboardScreen...');
                  return ShoDashboardScreen(sho: sho);
                },
              ),
            );
            print('🔍 Navigation completed successfully');
          } catch (navError) {
            print('🔍 Navigation error: $navError');
            setState(() {
              _errorMessage = 'Navigation error: ${navError.toString()}';
            });
          }
        } catch (modelError) {
          print('🔍 Error creating SHO object: $modelError');
          setState(() {
            _errorMessage = 'Error processing user data: ${modelError.toString()}';
          });
        }
      } else {
        print('🔍 Login failed: ${result['message']}');
        setState(() {
          _errorMessage = result['message'] ?? 'Login failed';
        });
      }
    } catch (e) {
      print('🔍 SHO login error: $e');
      setState(() {
        _errorMessage = 'Network error. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF9800), // Orange
              Color(0xFFE65100), // Dark orange
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 120.0 : 24.0,
                  vertical: 16.0,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 32.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeader(context, isTablet),
                      SizedBox(height: constraints.maxHeight > 600 ? 40 : 20),
                      _buildLoginForm(context, isTablet),
                      SizedBox(height: constraints.maxHeight > 600 ? 20 : 10),
                      _buildFooter(context),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isTablet) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.account_balance,
            size: isTablet ? 60 : 48,
            color: Colors.white,
          ),
        ),
        SizedBox(height: isTablet ? 16 : 12),
        Text(
          'State Health Officer',
          style: TextStyle(
            fontSize: isTablet ? 28 : 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: isTablet ? 8 : 6),
        Text(
          'Login to State Health Management Portal',
          style: TextStyle(
            fontSize: isTablet ? 16 : 13,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context, bool isTablet) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 500 : double.infinity,
        ),
        child: Card(
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 32.0 : 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: isTablet ? 28 : 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  SizedBox(height: isTablet ? 24 : 16),
                  
                  // Username/Email field
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username or Email',
                      hintText: 'Enter your username or email',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFFF9800),
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: isTablet ? 16 : 12,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your username or email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: isTablet ? 16 : 12),
                  
                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFFF9800),
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: isTablet ? 16 : 12,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: isTablet ? 20 : 16),
                  
                  // Error message
                  if (_errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.red.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Login button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? 16.0 : 14.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: _isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Signing In...',
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: isTablet ? 20 : 16),
                  
                  // Information text
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade600,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your account is created by WHO Admin. Contact your administrator if you need assistance.',
                            style: TextStyle(
                              color: Colors.blue.shade600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            'State Health Officer Portal',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'DHRMS - Digital Health Record Management System',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 10,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}