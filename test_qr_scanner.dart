import 'package:flutter/material.dart';
import 'package:dhrms/screens/enhanced_qr_scanner_screen.dart';

void main() {
  runApp(TestQRScannerApp());
}

class TestQRScannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Test QR Scanner', home: TestQRScannerScreen());
  }
}

class TestQRScannerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test QR Scanner')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner, size: 80, color: Colors.blue),
            SizedBox(height: 30),
            Text(
              'Enhanced QR Scanner Test',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'This test opens the enhanced QR scanner with options for:\n• Camera scanning\n• Image upload from gallery\n• Manual UHID input fallback',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EnhancedQRScannerScreen(),
                  ),
                );
              },
              icon: Icon(Icons.qr_code),
              label: Text('Open QR Scanner'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
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
