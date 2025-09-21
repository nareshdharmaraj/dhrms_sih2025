import 'package:flutter/material.dart';
import '../../services/regional_health_officer_service.dart';
import '../../utils/colors.dart';

class CreateRegionalHealthOfficerScreen extends StatefulWidget {
  const CreateRegionalHealthOfficerScreen({super.key});

  @override
  _CreateRegionalHealthOfficerScreenState createState() => _CreateRegionalHealthOfficerScreenState();
}

class _CreateRegionalHealthOfficerScreenState extends State<CreateRegionalHealthOfficerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _regionController = TextEditingController();
  
  String _selectedState = 'Andhra Pradesh';
  int _maxStaffLimit = 50;
  bool _isLoading = false;
  
  final List<String> _indianStates = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
    'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim',
    'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand',
    'West Bengal', 'Delhi', 'Jammu and Kashmir', 'Ladakh'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Regional Health Officer'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Personal Information'),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _fullNameController,
                label: 'Full Name',
                icon: Icons.person,
                validator: (value) => value?.isEmpty == true ? 'Full name is required' : null,
              ),
              
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Email is required';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) => value?.isEmpty == true ? 'Phone number is required' : null,
              ),
              
              const SizedBox(height: 16),
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock,
                obscureText: true,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Password is required';
                  if (value!.length < 8) return 'Password must be at least 8 characters';
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Assignment Details'),
              const SizedBox(height: 16),
              
              _buildDropdown(),
              
              const SizedBox(height: 16),
              _buildTextField(
                controller: _regionController,
                label: 'Assigned Region',
                icon: Icons.location_on,
                validator: (value) => value?.isEmpty == true ? 'Assigned region is required' : null,
              ),
              
              const SizedBox(height: 16),
              _buildStaffLimitSlider(),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createRHO,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Create Regional Health Officer', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedState,
      decoration: InputDecoration(
        labelText: 'Assigned State',
        prefixIcon: const Icon(Icons.location_city, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      items: _indianStates.map((state) => DropdownMenuItem(
        value: state,
        child: Text(state),
      )).toList(),
      onChanged: (value) {
        setState(() {
          _selectedState = value!;
        });
      },
    );
  }

  Widget _buildStaffLimitSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Maximum Staff Limit',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_maxStaffLimit',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: _maxStaffLimit.toDouble(),
          min: 10,
          max: 200,
          divisions: 19,
          activeColor: AppColors.primary,
          onChanged: (value) {
            setState(() {
              _maxStaffLimit = value.round();
            });
          },
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('10', style: TextStyle(color: AppColors.textSecondary)),
            Text('200', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  Future<void> _createRHO() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final rhoData = {
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text,
        'assignedRegion': _regionController.text.trim(),
        'assignedState': _selectedState,
        'parentSHO': 'current_sho_id', // This should come from the current SHO context
        'maxStaffLimit': _maxStaffLimit,
      };

      final result = await RegionalHealthOfficerService.createRHO(
        'auth_token', // This should come from auth service
        rhoData,
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Regional Health Officer created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to create RHO'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _regionController.dispose();
    super.dispose();
  }
}