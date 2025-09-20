import 'package:flutter/material.dart';
import 'package:dhrms/screens/advanced_sos_screen.dart';

void main() {
  runApp(TestSOSApp());
}

class TestSOSApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Emergency SOS',
      home: TestSOSScreen(),
    );
  }
}

class TestSOSScreen extends StatelessWidget {
  final Map<String, dynamic> testPatientData = {
    'fullName': 'Test Patient',
    'uhid': 'TEST123',
    'emergencyContact': {
      'name': 'Emergency Contact Person',
      'relationship': 'Family',
      'phone': '9876543210',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Emergency SOS'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Emergency Contact: ${testPatientData['emergencyContact']['phone']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdvancedSOSScreen(
                      patientData: testPatientData,
                    ),
                  ),
                );
              },
              child: Text('Test Emergency SOS Screen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}