import 'package:flutter/material.dart';

class ProximityAlertsScreen extends StatefulWidget {
  final Map<String, dynamic>? patientData;

  const ProximityAlertsScreen({super.key, this.patientData});

  @override
  State<ProximityAlertsScreen> createState() => _ProximityAlertsScreenState();
}

class _ProximityAlertsScreenState extends State<ProximityAlertsScreen> {
  final List<Map<String, dynamic>> _alerts = [];
  bool _isLocationEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proximity Alerts'),
        backgroundColor: Colors.cyan.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isLocationEnabled ? Icons.location_on : Icons.location_off,
            ),
            onPressed: _toggleLocationService,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.cyan.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            _buildLocationStatus(),
            Expanded(
              child: _alerts.isEmpty ? _buildEmptyState() : _buildAlertsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _isLocationEnabled
          ? FloatingActionButton.extended(
              onPressed: _showCreateAlertDialog,
              backgroundColor: Colors.cyan.shade600,
              icon: const Icon(Icons.add_location, color: Colors.white),
              label: const Text(
                'Add Alert',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildLocationStatus() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isLocationEnabled ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isLocationEnabled
              ? Colors.green.shade200
              : Colors.red.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isLocationEnabled ? Icons.location_on : Icons.location_off,
            color: _isLocationEnabled
                ? Colors.green.shade600
                : Colors.red.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isLocationEnabled
                      ? 'Location Services Enabled'
                      : 'Location Services Disabled',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isLocationEnabled
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
                Text(
                  _isLocationEnabled
                      ? 'You will receive alerts when near important locations'
                      : 'Enable location to receive proximity alerts',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isLocationEnabled
                        ? Colors.green.shade600
                        : Colors.red.shade600,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _toggleLocationService,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isLocationEnabled
                  ? Colors.red.shade600
                  : Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text(_isLocationEnabled ? 'Disable' : 'Enable'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_searching_outlined,
            size: 120,
            color: Colors.cyan.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            _isLocationEnabled ? 'No Proximity Alerts' : 'Location Disabled',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isLocationEnabled
                ? 'Create alerts for important locations'
                : 'Enable location services to use proximity alerts',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (_isLocationEnabled)
            ElevatedButton.icon(
              onPressed: _showCreateAlertDialog,
              icon: const Icon(Icons.add_location),
              label: const Text('Create Your First Alert'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          if (!_isLocationEnabled)
            ElevatedButton.icon(
              onPressed: _toggleLocationService,
              icon: const Icon(Icons.location_on),
              label: const Text('Enable Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAlertsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _alerts.length,
      itemBuilder: (context, index) {
        final alert = _alerts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getAlertTypeColor(
                          alert['type'],
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getAlertTypeIcon(alert['type']),
                        color: _getAlertTypeColor(alert['type']),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            alert['address'],
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: alert['isEnabled'],
                      onChanged: (value) => _toggleAlert(index, value),
                      thumbColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.cyan.shade600;
                          }
                          return Colors.grey.shade400;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Chip(
                      label: Text(alert['type']),
                      backgroundColor: _getAlertTypeColor(
                        alert['type'],
                      ).withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: _getAlertTypeColor(alert['type']),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text('${alert['radius']}m radius'),
                      backgroundColor: Colors.grey.shade100,
                      labelStyle: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      alert['isEnabled'] ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: alert['isEnabled'] ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (alert['message'] != null &&
                    alert['message'].isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Alert Message: ${alert['message']}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editAlert(index),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.cyan.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _deleteAlert(index),
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getAlertTypeColor(String type) {
    switch (type) {
      case 'Hospital':
        return Colors.red;
      case 'Pharmacy':
        return Colors.green;
      case 'Clinic':
        return Colors.blue;
      case 'Emergency':
        return Colors.orange;
      case 'Home':
        return Colors.purple;
      case 'Work':
        return Colors.indigo;
      default:
        return Colors.cyan;
    }
  }

  IconData _getAlertTypeIcon(String type) {
    switch (type) {
      case 'Hospital':
        return Icons.local_hospital;
      case 'Pharmacy':
        return Icons.local_pharmacy;
      case 'Clinic':
        return Icons.medical_services;
      case 'Emergency':
        return Icons.emergency;
      case 'Home':
        return Icons.home;
      case 'Work':
        return Icons.work;
      default:
        return Icons.location_on;
    }
  }

  void _toggleLocationService() {
    setState(() {
      _isLocationEnabled = !_isLocationEnabled;
      if (!_isLocationEnabled) {
        // Disable all alerts when location is turned off
        for (var alert in _alerts) {
          alert['isEnabled'] = false;
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isLocationEnabled
              ? 'Location services enabled'
              : 'Location services disabled',
        ),
        backgroundColor: _isLocationEnabled ? Colors.green : Colors.red,
      ),
    );
  }

  void _toggleAlert(int index, bool value) {
    setState(() {
      _alerts[index]['isEnabled'] = value;
    });
  }

  void _showCreateAlertDialog() {
    _showAlertDialog();
  }

  void _editAlert(int index) {
    final alert = _alerts[index];
    _showAlertDialog(isEdit: true, index: index, initialData: alert);
  }

  void _showAlertDialog({
    bool isEdit = false,
    int? index,
    Map<String, dynamic>? initialData,
  }) {
    final nameController = TextEditingController(
      text: initialData?['name'] ?? '',
    );
    final addressController = TextEditingController(
      text: initialData?['address'] ?? '',
    );
    final messageController = TextEditingController(
      text: initialData?['message'] ?? '',
    );
    String selectedType = initialData?['type'] ?? 'Hospital';
    double selectedRadius = (initialData?['radius'] ?? 500).toDouble();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Proximity Alert' : 'Create Proximity Alert'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Location Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Location Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Hospital',
                      child: Text('Hospital'),
                    ),
                    DropdownMenuItem(
                      value: 'Pharmacy',
                      child: Text('Pharmacy'),
                    ),
                    DropdownMenuItem(value: 'Clinic', child: Text('Clinic')),
                    DropdownMenuItem(
                      value: 'Emergency',
                      child: Text('Emergency Center'),
                    ),
                    DropdownMenuItem(value: 'Home', child: Text('Home')),
                    DropdownMenuItem(value: 'Work', child: Text('Work')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Alert Radius: ${selectedRadius.round()}m'),
                    Slider(
                      value: selectedRadius,
                      min: 100,
                      max: 2000,
                      divisions: 19,
                      label: '${selectedRadius.round()}m',
                      onChanged: (value) {
                        setState(() {
                          selectedRadius = value;
                        });
                      },
                      activeColor: Colors.cyan.shade600,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Custom Alert Message (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  addressController.text.isNotEmpty) {
                if (isEdit && index != null) {
                  _updateAlert(
                    index,
                    nameController.text,
                    addressController.text,
                    selectedType,
                    selectedRadius.round(),
                    messageController.text,
                  );
                } else {
                  _addAlert(
                    nameController.text,
                    addressController.text,
                    selectedType,
                    selectedRadius.round(),
                    messageController.text,
                  );
                }
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text(isEdit ? 'Update' : 'Create'),
          ),
        ],
      ),
    );
  }

  void _addAlert(
    String name,
    String address,
    String type,
    int radius,
    String message,
  ) {
    setState(() {
      _alerts.add({
        'name': name,
        'address': address,
        'type': type,
        'radius': radius,
        'message': message,
        'isEnabled': true,
        'createdDate': DateTime.now().toString().split(' ')[0],
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Proximity alert created for $name'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _updateAlert(
    int index,
    String name,
    String address,
    String type,
    int radius,
    String message,
  ) {
    setState(() {
      _alerts[index] = {
        ..._alerts[index],
        'name': name,
        'address': address,
        'type': type,
        'radius': radius,
        'message': message,
      };
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Proximity alert updated for $name'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _deleteAlert(int index) {
    final alertName = _alerts[index]['name'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alert'),
        content: Text(
          'Are you sure you want to delete the proximity alert for "$alertName"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _alerts.removeAt(index);
              });
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Proximity alert for "$alertName" deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
