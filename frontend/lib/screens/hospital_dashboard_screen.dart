import 'package:flutter/material.dart';

class HospitalDashboardScreen extends StatefulWidget {
  final String role;
  
  const HospitalDashboardScreen({
    super.key,
    required this.role,
  });

  @override
  State<HospitalDashboardScreen> createState() => _HospitalDashboardScreenState();
}

class _HospitalDashboardScreenState extends State<HospitalDashboardScreen> {
  
  String get roleTitle {
    switch (widget.role) {
      case 'doctor':
        return 'Doctor Dashboard';
      case 'admin':
        return 'Hospital Admin Dashboard';
      case 'assistant':
        return 'Assistant Dashboard';
      default:
        return 'Hospital Dashboard';
    }
  }
  
  IconData get roleIcon {
    switch (widget.role) {
      case 'doctor':
        return Icons.medical_services;
      case 'admin':
        return Icons.admin_panel_settings;
      case 'assistant':
        return Icons.support_agent;
      default:
        return Icons.medical_services;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(roleTitle),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              roleIcon,
              size: 100,
              color: const Color(0xFF2196F3),
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome to $roleTitle',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _getRoleDescription(),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  String _getRoleDescription() {
    switch (widget.role) {
      case 'doctor':
        return 'Manage patient records and consultations';
      case 'admin':
        return 'Oversee hospital operations and staff';
      case 'assistant':
        return 'Support healthcare operations';
      default:
        return 'Hospital management portal';
    }
  }

  Widget _buildQuickActions() {
    List<Map<String, dynamic>> actions = [];
    
    switch (widget.role) {
      case 'doctor':
        actions = [
          {'title': 'Patient Records', 'icon': Icons.folder_shared, 'color': Colors.green},
          {'title': 'Appointments', 'icon': Icons.calendar_today, 'color': Colors.blue},
          {'title': 'Prescriptions', 'icon': Icons.receipt, 'color': Colors.orange},
        ];
        break;
      case 'admin':
        actions = [
          {'title': 'Staff Management', 'icon': Icons.people, 'color': Colors.purple},
          {'title': 'Reports', 'icon': Icons.analytics, 'color': Colors.green},
          {'title': 'Settings', 'icon': Icons.settings, 'color': Colors.grey},
        ];
        break;
      case 'assistant':
        actions = [
          {'title': 'Patient Check-in', 'icon': Icons.login, 'color': Colors.green},
          {'title': 'Appointments', 'icon': Icons.schedule, 'color': Colors.blue},
          {'title': 'Records', 'icon': Icons.description, 'color': Colors.orange},
        ];
        break;
    }

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: actions.map((action) {
        return Container(
          width: 120,
          height: 100,
          decoration: BoxDecoration(
            color: action['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: action['color'].withOpacity(0.3),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${action['title']} feature coming soon!'),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    action['icon'],
                    size: 32,
                    color: action['color'],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action['title'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: action['color'],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
