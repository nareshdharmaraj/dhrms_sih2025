import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';

class AddBedScreen extends StatefulWidget {
  const AddBedScreen({Key? key}) : super(key: key);

  @override
  State<AddBedScreen> createState() => _AddBedScreenState();
}

class _AddBedScreenState extends State<AddBedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bedNumberController = TextEditingController();
  final _floorController = TextEditingController();
  final _departmentController = TextEditingController();
  final _equipmentController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedBedType = 'General';
  String _selectedStatus = 'Available';
  String _selectedWardType = 'General Ward';
  bool _hasOxygen = false;
  bool _hasMonitor = false;
  bool _hasVentilator = false;
  bool _isPrivate = false;
  bool _isLoading = false;

  final List<String> _bedTypes = [
    'General',
    'ICU',
    'Emergency',
    'Maternity',
    'Pediatric',
    'Cardiac',
    'Surgical',
    'Recovery'
  ];

  final List<String> _statuses = [
    'Available',
    'Occupied',
    'Maintenance',
    'Reserved',
    'Out of Service'
  ];

  final List<String> _wardTypes = [
    'General Ward',
    'Private Room',
    'Semi-Private',
    'ICU',
    'Emergency Ward',
    'Maternity Ward',
    'Pediatric Ward',
    'Surgical Ward'
  ];

  @override
  void dispose() {
    _bedNumberController.dispose();
    _floorController.dispose();
    _departmentController.dispose();
    _equipmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addBed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Prepare bed data for API call
      final bedData = {
        'bedNumber': _bedNumberController.text.trim(),
        'floor': int.tryParse(_floorController.text) ?? 1,
        'department': _departmentController.text.trim(),
        'bedType': _selectedBedType,
        'status': _selectedStatus,
        'wardType': _selectedWardType,
        'isPrivate': _isPrivate,
        'equipment': {
          'oxygen': _hasOxygen,
          'monitor': _hasMonitor,
          'ventilator': _hasVentilator,
          'additional': _equipmentController.text.trim(),
        },
        'notes': _notesController.text.trim(),
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Simulate API call - in real implementation, would call ApiService.addBed(bedData)
      await Future.delayed(Duration(seconds: 2));
      
      // Log the bed data for development purposes
      print('Bed data prepared: $bedData');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bed ${_bedNumberController.text} added successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add bed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Bed'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _bedNumberController,
                      decoration: InputDecoration(
                        labelText: 'Bed Number *',
                        hintText: 'e.g., A-101',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.bed),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Bed number is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _floorController,
                            decoration: InputDecoration(
                              labelText: 'Floor *',
                              hintText: 'e.g., 1, 2, 3',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.layers),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Floor is required';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Enter valid floor number';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _departmentController,
                            decoration: InputDecoration(
                              labelText: 'Department *',
                              hintText: 'e.g., Cardiology',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.business),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Department is required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bed Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedBedType,
                      decoration: InputDecoration(
                        labelText: 'Bed Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _bedTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedBedType = value!);
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedWardType,
                      decoration: InputDecoration(
                        labelText: 'Ward Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.domain),
                      ),
                      items: _wardTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedWardType = value!);
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.info_outline),
                      ),
                      items: _statuses.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedStatus = value!);
                      },
                    ),
                    SizedBox(height: 16),
                    SwitchListTile(
                      title: Text('Private Room'),
                      subtitle: Text('Additional charges may apply'),
                      value: _isPrivate,
                      onChanged: (value) {
                        setState(() => _isPrivate = value);
                      },
                      activeColor: AppColors.primaryBlue,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Equipment & Facilities',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    SizedBox(height: 16),
                    CheckboxListTile(
                      title: Text('Oxygen Supply'),
                      subtitle: Text('Built-in oxygen supply system'),
                      value: _hasOxygen,
                      onChanged: (value) {
                        setState(() => _hasOxygen = value ?? false);
                      },
                      activeColor: AppColors.primaryBlue,
                    ),
                    CheckboxListTile(
                      title: Text('Patient Monitor'),
                      subtitle: Text('Real-time vital signs monitoring'),
                      value: _hasMonitor,
                      onChanged: (value) {
                        setState(() => _hasMonitor = value ?? false);
                      },
                      activeColor: AppColors.primaryBlue,
                    ),
                    CheckboxListTile(
                      title: Text('Ventilator'),
                      subtitle: Text('Mechanical ventilation support'),
                      value: _hasVentilator,
                      onChanged: (value) {
                        setState(() => _hasVentilator = value ?? false);
                      },
                      activeColor: AppColors.primaryBlue,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _equipmentController,
                      decoration: InputDecoration(
                        labelText: 'Additional Equipment',
                        hintText: 'List any other equipment or facilities',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.medical_services),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Notes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Any special instructions or notes about this bed',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addBed,
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Adding Bed...'),
                            ],
                          )
                        : Text('Add Bed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
