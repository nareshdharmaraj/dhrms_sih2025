import 'package:flutter/material.dart';

class HealthAlertsScreen extends StatefulWidget {
  final Map<String, dynamic>? patientData;

  const HealthAlertsScreen({super.key, this.patientData});

  @override
  State<HealthAlertsScreen> createState() => _HealthAlertsScreenState();
}

class _HealthAlertsScreenState extends State<HealthAlertsScreen> {
  final List<Map<String, dynamic>> _alerts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Alerts'),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade50, Colors.white],
          ),
        ),
        child: _alerts.isEmpty ? _buildEmptyState() : _buildAlertsList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateAlertDialog,
        backgroundColor: Colors.orange.shade600,
        icon: const Icon(Icons.add_alert, color: Colors.white),
        label: const Text('Add Alert', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 120,
            color: Colors.orange.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'No Health Alerts',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Stay on top of your health with personalized alerts',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showCreateAlertDialog,
            icon: const Icon(Icons.add_alert),
            label: const Text('Create Your First Alert'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getAlertColor(alert['type']),
              child: Icon(
                _getAlertIcon(alert['type']),
                color: Colors.white,
              ),
            ),
            title: Text(
              alert['title'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert['description']),
                const SizedBox(height: 4),
                Text(
                  'Scheduled: ${alert['time']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteAlert(index);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getAlertColor(String type) {
    switch (type) {
      case 'medication':
        return Colors.teal;
      case 'appointment':
        return Colors.blue;
      case 'exercise':
        return Colors.green;
      case 'vital':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'medication':
        return Icons.medication;
      case 'appointment':
        return Icons.calendar_today;
      case 'exercise':
        return Icons.fitness_center;
      case 'vital':
        return Icons.favorite;
      default:
        return Icons.notification_important;
    }
  }

  void _showCreateAlertDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedType = 'general';
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Health Alert'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Alert Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Alert Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'general', child: Text('General')),
                  DropdownMenuItem(value: 'medication', child: Text('Medication')),
                  DropdownMenuItem(value: 'appointment', child: Text('Appointment')),
                  DropdownMenuItem(value: 'exercise', child: Text('Exercise')),
                  DropdownMenuItem(value: 'vital', child: Text('Vital Check')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Alert Time'),
                subtitle: Text(selectedTime.format(context)),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    setState(() {
                      selectedTime = time;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                _addAlert(
                  titleController.text,
                  descriptionController.text,
                  selectedType,
                  selectedTime,
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _addAlert(String title, String description, String type, TimeOfDay time) {
    setState(() {
      _alerts.add({
        'title': title,
        'description': description,
        'type': type,
        'time': time.format(context),
      });
    });
  }

  void _deleteAlert(int index) {
    setState(() {
      _alerts.removeAt(index);
    });
  }
}