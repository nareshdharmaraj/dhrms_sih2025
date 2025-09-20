import 'package:flutter/material.dart';
import 'enhanced_qr_scanner_screen.dart';

class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to the enhanced QR scanner
    return EnhancedQRScannerScreen();
  }
}