import 'package:flutter/material.dart';
import 'emergency_contacts_screen.dart';
import 'advanced_sos_screen.dart';

class EmergencyHelper {
  static void showEmergencyContacts(BuildContext context, {Map<String, dynamic>? patientData}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EmergencyContactsScreen(patientData: patientData)),
    );
  }

  static void showAdvancedSOS(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdvancedSOSScreen()),
    );
  }

  static void makeEmergencyCall(BuildContext context, String number, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling $name at $number...'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Cancel',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  static const List<EmergencyService> emergencyServices = [
    EmergencyService(
      name: 'Ambulance Service',
      number: '108',
      icon: Icons.local_hospital,
      color: Colors.red,
    ),
    EmergencyService(
      name: 'Police Emergency',
      number: '100',
      icon: Icons.local_police,
      color: Colors.blue,
    ),
    EmergencyService(
      name: 'Fire Department',
      number: '101',
      icon: Icons.local_fire_department,
      color: Colors.orange,
    ),
    EmergencyService(
      name: 'Health Helpline',
      number: '104',
      icon: Icons.health_and_safety,
      color: Colors.green,
    ),
  ];
}

class EmergencyService {
  final String name;
  final String number;
  final IconData icon;
  final Color color;

  const EmergencyService({
    required this.name,
    required this.number,
    required this.icon,
    required this.color,
  });
}