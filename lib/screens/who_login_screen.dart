import 'package:flutter/material.dart';
import '../models/who_admin.dart';
import '../services/who_service.dart';
import 'who_dashboard_screen.dart';

class WhoLoginScreen extends StatefulWidget {
  const WhoLoginScreen({super.key});

  @override
  _WhoLoginScreenState createState() => _WhoLoginScreenState();
}

class _WhoLoginScreenState extends State<WhoLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _adminIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _adminIdController.dispose();
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
      print('🔍 Starting WHO login request...');
      final result = await WhoService.whoLogin(
        adminId: _adminIdController.text.trim(),
        password: _passwordController.text,
      );

      print('🔍 WHO login result: $result');

      if (result['success']) {
        print('🔍 Login successful, creating WhoAdmin object...');
        print('🔍 Admin data type: ${result['admin'].runtimeType}');
        print('🔍 Admin data: ${result['admin']}');
        
        try {
          final whoAdmin = WhoAdmin.fromJson(result['admin']);
          print('🔍 WhoAdmin object created successfully: ${whoAdmin.fullName}');
          print('🔍 WhoAdmin ID: ${whoAdmin.id}');
          print('🔍 WhoAdmin adminId: ${whoAdmin.adminId}');
          
          // Store the auth token in the WHO service
          if (result['token'] != null) {
            print('🔍 Storing auth token for future requests');
            // Note: Token is already stored in WhoService.whoLogin method
          }
          
          // Navigate to WHO dashboard
          print('🔍 About to navigate to WHO dashboard...');
          
          try {
            await Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  print('🔍 Building WhoDashboardScreen...');
                  return WhoDashboardScreen(whoAdmin: whoAdmin);
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
          print('🔍 Error creating WhoAdmin object: $modelError');
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
      print('🔍 WHO login error: $e');
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
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeader(),
                SizedBox(height: 40),
                _buildLoginForm(),
                SizedBox(height: 30),
                _buildLoginButton(),
                if (_errorMessage != null) ...[
                  SizedBox(height: 20),
                  _buildErrorMessage(),
                ],
                SizedBox(height: 40),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                spreadRadius: 5,
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            Icons.admin_panel_settings,
            size: 60,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 24),
        Text(
          'WHO Admin Portal',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'World Health Organization\nAdministrative Access',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _adminIdController,
              decoration: InputDecoration(
                labelText: 'Admin ID',
                hintText: 'Enter your WHO Admin ID',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your Admin ID';
                }
                if (value.trim().length < 3) {
                  return 'Admin ID must be at least 3 characters';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
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
                filled: true,
                fillColor: Colors.grey.shade50,
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
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _login(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: Colors.blue.withOpacity(0.3),
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
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Signing In...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            : Text(
                'Sign In',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Secure Administrative Access',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security, size: 16, color: Colors.grey.shade500),
            SizedBox(width: 4),
            Text(
              'Protected by WHO Security Protocol',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Need Help?'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Contact WHO IT Support:'),
                    SizedBox(height: 8),
                    Text('• Email: admin-support@who.int'),
                    Text('• Phone: +41 22 791 2111'),
                    SizedBox(height: 12),
                    Text(
                      'For security reasons, passwords cannot be reset through this application.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Close'),
                  ),
                ],
              ),
            );
          },
          child: Text('Need Help?'),
        ),
      ],
    );
  }
}