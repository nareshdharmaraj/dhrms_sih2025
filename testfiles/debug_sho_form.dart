import 'package:flutter/material.dart';

class DebugSHOForm extends StatefulWidget {
  const DebugSHOForm({super.key});

  @override
  _DebugSHOFormState createState() => _DebugSHOFormState();
}

class _DebugSHOFormState extends State<DebugSHOForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedState = 'Andhra Pradesh';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Debug SHO Form')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
                onChanged: (value) => print('Full Name changed: $value'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
                onChanged: (value) => print('Email changed: $value'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
                onChanged: (value) => print('Phone changed: $value'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
                onChanged: (value) => print('Password changed: ${value.isNotEmpty ? '[HIDDEN]' : 'EMPTY'}'),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedState,
                decoration: InputDecoration(labelText: 'State'),
                items: ['Andhra Pradesh', 'Tamil Nadu', 'Karnataka'].map((state) {
                  return DropdownMenuItem(value: state, child: Text(state));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedState = value!;
                  });
                  print('State changed: $value');
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _debugSubmit,
                child: Text('Debug Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _debugSubmit() {
    print('\n=== DEBUG FORM SUBMISSION ===');
    print('Form valid: ${_formKey.currentState?.validate()}');
    print('Full Name: "${_fullNameController.text}"');
    print('Email: "${_emailController.text}"');
    print('Phone: "${_phoneController.text}"');
    print('Password: "${_passwordController.text}"');
    print('State: "$_selectedState"');
    print('Full Name isEmpty: ${_fullNameController.text.isEmpty}');
    print('Email isEmpty: ${_emailController.text.isEmpty}');
    print('Phone isEmpty: ${_phoneController.text.isEmpty}');
    print('Password isEmpty: ${_passwordController.text.isEmpty}');
    print('================================\n');
    
    if (_formKey.currentState?.validate() == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Form is valid and data captured correctly')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Form validation failed')),
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