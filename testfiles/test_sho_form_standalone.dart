import 'package:flutter/material.dart';

class TestSHOFormApp extends StatelessWidget {
  const TestSHOFormApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test SHO Form',
      home: TestSHOForm(),
    );
  }
}

class TestSHOForm extends StatefulWidget {
  const TestSHOForm({super.key});

  @override
  _TestSHOFormState createState() => _TestSHOFormState();
}

class _TestSHOFormState extends State<TestSHOForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedState = 'Andhra Pradesh';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test SHO Form'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create State Health Officer',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  hintText: 'Enter full name',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Full name is required';
                  }
                  return null;
                },
                onChanged: (value) {
                  print('✏️ Full Name: "$value" (length: ${value.length})');
                },
              ),
              SizedBox(height: 16),
              
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  hintText: 'Enter email address',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                onChanged: (value) {
                  print('📧 Email: "$value" (length: ${value.length})');
                },
              ),
              SizedBox(height: 16),
              
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  hintText: 'Enter phone number',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  if (value.trim().length < 10) {
                    return 'Phone number must be at least 10 digits';
                  }
                  return null;
                },
                onChanged: (value) {
                  print('📱 Phone: "$value" (length: ${value.length})');
                },
              ),
              SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedState,
                decoration: InputDecoration(
                  labelText: 'Assigned State',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'Andhra Pradesh',
                  'Tamil Nadu', 
                  'Karnataka',
                  'Kerala',
                  'Maharashtra'
                ].map((state) {
                  return DropdownMenuItem(
                    value: state,
                    child: Text(state),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedState = value!;
                  });
                  print('🏛️ State: "$value"');
                },
              ),
              SizedBox(height: 16),
              
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  hintText: 'Enter password (min 8 characters)',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Password is required';
                  }
                  if (value.trim().length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
                onChanged: (value) {
                  print('🔒 Password: ${value.isEmpty ? 'EMPTY' : '[HIDDEN - ${value.length} chars]'}');
                },
              ),
              SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _testSubmit,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                ),
                child: Text(
                  'Test Submit (No API Call)',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              
              SizedBox(height: 16),
              
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Form Data Preview:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Full Name: "${_fullNameController.text}"'),
                    Text('Email: "${_emailController.text}"'),
                    Text('Phone: "${_phoneController.text}"'),
                    Text('State: "$_selectedState"'),
                    Text('Password: ${_passwordController.text.isEmpty ? 'EMPTY' : '[${_passwordController.text.length} chars]'}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _testSubmit() {
    print('\n🧪 =================== TEST FORM SUBMISSION ===================');
    print('📝 Full Name: "${_fullNameController.text}" (isEmpty: ${_fullNameController.text.isEmpty})');
    print('📧 Email: "${_emailController.text}" (isEmpty: ${_emailController.text.isEmpty})');
    print('📱 Phone: "${_phoneController.text}" (isEmpty: ${_phoneController.text.isEmpty})');
    print('🔒 Password: "${_passwordController.text}" (isEmpty: ${_passwordController.text.isEmpty})');
    print('🏛️ State: "$_selectedState"');
    print('✅ Form Valid: ${_formKey.currentState?.validate()}');
    print('================================================================\n');

    if (_formKey.currentState!.validate()) {
      // Simulate the API call structure
      final requestBody = {
        'officerId': 'SHO_AP_001',
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'assignedState': _selectedState,
        'password': _passwordController.text.trim(),
      };
      
      print('📤 Simulated Request Body: $requestBody');
      
      bool hasEmptyFields = requestBody['fullName']!.isEmpty ||
                           requestBody['email']!.isEmpty ||
                           requestBody['phone']!.isEmpty ||
                           requestBody['password']!.isEmpty;
      
      if (hasEmptyFields) {
        print('❌ ERROR: Empty fields detected in request body!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Form has empty fields!'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        print('✅ SUCCESS: All fields have data!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Form data captured successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      print('❌ Form validation failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Please fix form errors'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

void main() {
  runApp(TestSHOFormApp());
}