import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class RealQRScannerScreen extends StatefulWidget {
  const RealQRScannerScreen({Key? key}) : super(key: key);

  @override
  State<RealQRScannerScreen> createState() => _RealQRScannerScreenState();
}

class _RealQRScannerScreenState extends State<RealQRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String result = '';
  bool isFlashOn = false;
  bool isScanning = true;
  
  // API Configuration
  static const String API_BASE_URL = 'http://localhost:5000/api/v1';
  String? authToken; // Should be obtained from secure storage

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Camera Permission Required'),
          content: const Text(
            'This app needs camera permission to scan QR codes. Please enable camera permission in settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Settings'),
            ),
          ],
        );
      },
    );
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (isScanning && scanData.code != null) {
        setState(() {
          result = scanData.code!;
          isScanning = false;
        });
        _processQRCode(scanData.code!);
      }
    });
  }

  Future<void> _processQRCode(String qrData) async {
    try {
      // Pause scanning while processing
      controller?.pauseCamera();
      
      // Show loading dialog
      _showLoadingDialog();
      
      // Process QR code with backend
      final response = await _scanQRCode(qrData);
      
      // Hide loading dialog
      Navigator.of(context).pop();
      
      if (response['success']) {
        _showQRResult(response['data']);
      } else {
        _showErrorDialog(response['message'] ?? 'Failed to process QR code');
      }
    } catch (e) {
      Navigator.of(context).pop(); // Hide loading dialog
      _showErrorDialog('Error processing QR code: $e');
    }
  }

  Future<Map<String, dynamic>> _scanQRCode(String qrData) async {
    try {
      // Extract QR code ID from the scanned data
      // In a real implementation, you'd parse the QR data properly
      final Map<String, dynamic> qrPayload = jsonDecode(qrData);
      final String qrCodeId = qrPayload['qrCodeId'] ?? '';
      
      final response = await http.post(
        Uri.parse('$API_BASE_URL/qr-codes/scan'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken', // Use stored auth token
        },
        body: jsonEncode({
          'qrCodeId': qrCodeId,
          'scannedData': qrData,
          'scannerInfo': {
            'deviceType': 'mobile',
            'platform': Platform.isAndroid ? 'android' : 'ios',
            'location': {
              'latitude': 0.0, // Get from location service
              'longitude': 0.0,
              'accuracy': 10.0,
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Unknown error',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to scan QR code: $e',
      };
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Processing QR Code...'),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showQRResult(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return QRResultSheet(
              data: data,
              scrollController: scrollController,
              onClose: () {
                Navigator.of(context).pop();
                _resumeScanning();
              },
            );
          },
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Scan Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resumeScanning();
              },
              child: const Text('Try Again'),
            ),
          ],
        );
      },
    );
  }

  void _resumeScanning() {
    setState(() {
      isScanning = true;
      result = '';
    });
    controller?.resumeCamera();
  }

  void _toggleFlash() {
    controller?.toggleFlash();
    setState(() {
      isFlashOn = !isFlashOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: isScanning ? Colors.green : Colors.red,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: 300,
                  ),
                ),
                // Scanning animation overlay
                if (isScanning)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 350), // Position below scan area
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Scanning for QR Code...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Camera controls overlay
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        heroTag: "flash",
                        onPressed: _toggleFlash,
                        backgroundColor: Colors.white.withOpacity(0.8),
                        child: Icon(
                          isFlashOn ? Icons.flash_on : Icons.flash_off,
                          color: Colors.black,
                        ),
                      ),
                      FloatingActionButton(
                        heroTag: "gallery",
                        onPressed: () {
                          // TODO: Implement image picker for QR from gallery
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Gallery QR scan not implemented yet')),
                          );
                        },
                        backgroundColor: Colors.white.withOpacity(0.8),
                        child: const Icon(Icons.photo_library, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Point your camera at a QR code',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'QR codes contain patient health information',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (result.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[600]),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'QR Code detected! Processing...',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

class QRResultSheet extends StatelessWidget {
  final Map<String, dynamic> data;
  final ScrollController scrollController;
  final VoidCallback onClose;

  const QRResultSheet({
    Key? key,
    required this.data,
    required this.scrollController,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final patientData = data['patientData'] ?? {};
    final scanInfo = data['scan'] ?? {};

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          // Header
          Row(
            children: [
              Icon(Icons.qr_code_scanner, color: Colors.blue[600], size: 28),
              const SizedBox(width: 12),
              const Text(
                'QR Code Scan Result',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Content
          Expanded(
            child: ListView(
              controller: scrollController,
              children: [
                // Patient Information
                if (patientData['name'] != null) ...[
                  _buildInfoCard(
                    'Patient Information',
                    Icons.person,
                    [
                      _buildInfoRow('Name', patientData['name']),
                      _buildInfoRow('Patient ID', patientData['patientId']),
                      if (patientData['age'] != null)
                        _buildInfoRow('Age', '${patientData['age']} years'),
                      if (patientData['gender'] != null)
                        _buildInfoRow('Gender', patientData['gender']),
                      if (patientData['bloodType'] != null)
                        _buildInfoRow('Blood Type', patientData['bloodType']),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Medical Information
                if (patientData['medicalInfo'] != null) ...[
                  _buildInfoCard(
                    'Medical Information',
                    Icons.medical_services,
                    [
                      if (patientData['medicalInfo']['allergies'] != null)
                        _buildInfoRow('Allergies', 
                          (patientData['medicalInfo']['allergies'] as List).join(', ')),
                      if (patientData['medicalInfo']['medications'] != null)
                        _buildInfoRow('Current Medications', 
                          (patientData['medicalInfo']['medications'] as List).join(', ')),
                      if (patientData['medicalInfo']['conditions'] != null)
                        _buildInfoRow('Medical Conditions', 
                          (patientData['medicalInfo']['conditions'] as List).join(', ')),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Emergency Contact
                if (patientData['emergencyContact'] != null) ...[
                  _buildInfoCard(
                    'Emergency Contact',
                    Icons.emergency,
                    [
                      _buildInfoRow('Name', patientData['emergencyContact']['name']),
                      _buildInfoRow('Relationship', patientData['emergencyContact']['relationship']),
                      _buildInfoRow('Phone', patientData['emergencyContact']['phone']),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Scan Information
                _buildInfoCard(
                  'Scan Information',
                  Icons.info,
                  [
                    _buildInfoRow('Scan ID', scanInfo['scanId'] ?? 'N/A'),
                    _buildInfoRow('Scanned At', 
                      scanInfo['scannedAt'] ?? DateTime.now().toString()),
                    _buildInfoRow('Data Types', 
                      (patientData['dataTypes'] as List?)?.join(', ') ?? 'N/A'),
                  ],
                ),
                
                const SizedBox(height: 100), // Bottom spacing
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}
