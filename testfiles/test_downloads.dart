import 'package:flutter/material.dart';
import 'package:dhrms/utils/card_download_service.dart';

void main() {
  runApp(TestDownloadsApp());
}

class TestDownloadsApp extends StatelessWidget {
  const TestDownloadsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Test Downloads', home: TestDownloadsScreen());
  }
}

class TestDownloadsScreen extends StatelessWidget {
  final Map<String, dynamic> testCardData = {
    'patientName': 'Test Patient',
    'uhid': 'TEST123',
    'dateOfBirth': DateTime.now().subtract(Duration(days: 10000)),
    'gender': 'male',
    'bloodGroup': 'O+',
    'phone': '9876543210',
    'address': 'Test Address, Test City',
    'homeState': 'Test State',
    'emergencyContact': '9876543211',
    'emergencyContactName': 'Emergency Contact',
    'issueDate': DateTime.now(),
    'qrCodeData': 'TEST_QR_CODE_DATA_123',
  };

  const TestDownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Downloads')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                print('Testing PDF download...');
                try {
                  final result = await CardDownloadService.downloadCardAsPDF(
                    cardData: testCardData,
                    context: context,
                  );
                  print('PDF result: $result');
                } catch (e) {
                  print('PDF error: $e');
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('PDF Error: $e')));
                }
              },
              child: Text('Test PDF Download'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                print('Testing JSON download...');
                try {
                  final result = await CardDownloadService.downloadCardData(
                    cardData: testCardData,
                    patientName: 'Test Patient',
                    uhid: 'TEST123',
                    context: context,
                  );
                  print('JSON result: $result');
                } catch (e) {
                  print('JSON error: $e');
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('JSON Error: $e')));
                }
              },
              child: Text('Test JSON Download'),
            ),
          ],
        ),
      ),
    );
  }
}
