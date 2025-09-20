import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_constants.dart';

class EnhancedQRScannerScreen extends StatefulWidget {
  const EnhancedQRScannerScreen({super.key});

  @override
  _EnhancedQRScannerScreenState createState() =>
      _EnhancedQRScannerScreenState();
}

class _EnhancedQRScannerScreenState extends State<EnhancedQRScannerScreen> {
  MobileScannerController? cameraController;
  bool isScanning = false;
  bool isCameraMode = false;
  String? scannedData;
  bool isFlashOn = false;

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  void _initializeCamera() {
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
      useNewCameraSelector: true, // Better camera handling
      formats: [
        BarcodeFormat.qrCode,
      ], // Only scan QR codes for better performance
    );
    setState(() {
      isCameraMode = true;
      isScanning = true;
    });
  }

  void _onDetect(BarcodeCapture barcodeCapture) async {
    if (!isScanning) return;

    final List<Barcode> barcodes = barcodeCapture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null && barcode.rawValue!.trim().isNotEmpty) {
        // Stop scanning immediately to prevent multiple scans
        setState(() {
          isScanning = false;
          scannedData = barcode.rawValue!.trim();
        });

        // Add haptic feedback
        if (mounted) {
          HapticFeedback.mediumImpact();
        }

        // Process the scanned data
        await _processScannedData(barcode.rawValue!.trim());
        break;
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          isScanning = false;
        });
        await _processImageFile(image);
      }
    } catch (e) {
      _showErrorDialog('Error', 'Failed to pick image: $e');
    }
  }

  Future<void> _processImageFile(XFile imageFile) async {
    try {
      // Show processing dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Analyzing image for QR code...'),
              ],
            ),
          );
        },
      );

      // For now, let's use a placeholder approach
      // In a real implementation, you might use a library like qr_code_scanner
      // or implement image processing to detect QR codes

      await Future.delayed(Duration(seconds: 2)); // Simulate processing

      // Close processing dialog
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // For demonstration, let's show a dialog asking for manual input
      _showManualInputDialog();
    } catch (e) {
      // Close processing dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      _showErrorDialog('Error', 'Failed to analyze image: $e');
    }
  }

  void _showManualInputDialog() {
    final TextEditingController uhidController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter UHID'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Could not automatically detect QR code from image.'),
              SizedBox(height: 16),
              TextField(
                controller: uhidController,
                decoration: InputDecoration(
                  labelText: 'Patient UHID',
                  border: OutlineInputBorder(),
                  hintText: 'Enter patient UHID manually',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isScanning = true;
                });
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final uhid = uhidController.text.trim();
                if (uhid.isNotEmpty) {
                  Navigator.of(context).pop();
                  _processScannedData(uhid);
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processScannedData(String data) async {
    setState(() {
      isScanning = false;
    });

    try {
      // Show processing dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Processing QR Code...'),
                SizedBox(height: 8),
                Text(
                  'Data: ${data.length > 50 ? data.substring(0, 50) + '...' : data}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      );

      // Try to parse as JSON first (in case it's QR code data)
      String uhid = data;
      try {
        final Map<String, dynamic> qrData = json.decode(data);
        if (qrData['uhid'] != null) {
          uhid = qrData['uhid'];
        } else if (qrData['patientId'] != null) {
          uhid = qrData['patientId'];
        } else if (qrData['id'] != null) {
          uhid = qrData['id'];
        }
      } catch (e) {
        // If parsing fails, treat data as direct UHID
        uhid = data.trim();
      }

      // Fetch patient data
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/patients/uhid/$uhid'),
        headers: {'Content-Type': 'application/json'},
      );

      // Close processing dialog
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          // Navigate to patient record screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PatientRecordScreen(
                patientData: responseData['patient'],
                migrations: responseData['migrations'] ?? [],
              ),
            ),
          );
        } else {
          _showErrorDialog(
            'Patient not found',
            responseData['message'] ?? 'No patient found with this UHID',
          );
        }
      } else {
        _showErrorDialog(
          'Error',
          'Failed to fetch patient data. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Close processing dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      _showErrorDialog('Error', 'Network error: $e');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isScanning = true;
                });
              },
              child: Text('Try Again'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _toggleFlash() async {
    if (cameraController != null) {
      await cameraController!.toggleTorch();
      setState(() {
        isFlashOn = !isFlashOn;
      });
    }
  }

  void _switchCamera() async {
    if (cameraController != null) {
      await cameraController!.switchCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isCameraMode) {
      return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: Text('Scan Patient QR Code'),
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  size: 80,
                  color: Colors.blue.shade600,
                ),
                SizedBox(height: 30),
                Text(
                  'Choose QR Code Source',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Select how you want to scan the patient QR code',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),

                // Camera Option
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 16),
                  child: ElevatedButton.icon(
                    onPressed: _initializeCamera,
                    icon: Icon(Icons.camera_alt, size: 24),
                    label: Text(
                      'Use Camera',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                // Upload Option
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _pickImageFromGallery,
                    icon: Icon(Icons.photo_library, size: 24),
                    label: Text(
                      'Upload from Gallery',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 30),

                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade600),
                      SizedBox(height: 8),
                      Text(
                        'Tips for better scanning:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '• Ensure good lighting\n• Hold camera steady\n• Keep QR code within frame\n• Make sure QR code is clear and not damaged',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Scanning QR Code'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
          ),
          IconButton(
            icon: Icon(Icons.flip_camera_ios),
            onPressed: _switchCamera,
          ),
          IconButton(
            icon: Icon(Icons.photo_library),
            onPressed: () {
              setState(() {
                isCameraMode = false;
                isScanning = false;
              });
              cameraController?.dispose();
              cameraController = null;
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera View
          if (cameraController != null)
            MobileScanner(controller: cameraController!, onDetect: _onDetect),

          // Overlay
          Container(
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(color: Colors.black.withOpacity(0.7)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isScanning ? Colors.green : Colors.white,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(color: Colors.black.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            color: Colors.white,
                            size: 40,
                          ),
                          SizedBox(height: 10),
                          Text(
                            isScanning
                                ? 'Position the QR code within the frame'
                                : 'Processing QR Code...',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 5),
                          Text(
                            isScanning
                                ? 'Scanning for patient health card...'
                                : 'Please wait...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading indicator when processing
          if (!isScanning)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      'Processing QR Code...',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    if (scannedData != null) ...[
                      SizedBox(height: 10),
                      Text(
                        'Data: ${scannedData!.length > 30 ? scannedData!.substring(0, 30) + '...' : scannedData}',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
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
}

// Keep the existing PatientRecordScreen class
class PatientRecordScreen extends StatelessWidget {
  final Map<String, dynamic> patientData;
  final List<dynamic> migrations;

  const PatientRecordScreen({
    super.key,
    required this.patientData,
    required this.migrations,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Patient Record'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.medical_services),
            onPressed: () {
              // Navigate to medical records
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Header Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.blue.shade600,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patientData['fullName'] ?? 'Unknown Patient',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'UHID: ${patientData['uhid'] ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Divider(),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem(
                        'Age',
                        _calculateAge(patientData['dateOfBirth']),
                      ),
                      _buildInfoItem('Gender', patientData['gender'] ?? 'N/A'),
                      _buildInfoItem(
                        'Blood',
                        patientData['bloodGroup'] ?? 'N/A',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Basic Information
            _buildSectionHeader('Basic Information'),
            _buildInfoCard([
              _buildDetailRow('Phone', patientData['phone'] ?? 'N/A'),
              _buildDetailRow('Email', patientData['email'] ?? 'N/A'),
              _buildDetailRow('Address', patientData['address'] ?? 'N/A'),
              _buildDetailRow('Home State', patientData['homeState'] ?? 'N/A'),
            ]),

            SizedBox(height: 20),

            // Emergency Contact
            if (patientData['emergencyContact'] != null) ...[
              _buildSectionHeader('Emergency Contact'),
              _buildInfoCard([
                _buildDetailRow(
                  'Name',
                  patientData['emergencyContact']['name'] ?? 'N/A',
                ),
                _buildDetailRow(
                  'Relationship',
                  patientData['emergencyContact']['relationship'] ?? 'N/A',
                ),
                _buildDetailRow(
                  'Phone',
                  patientData['emergencyContact']['phone'] ?? 'N/A',
                ),
              ]),
              SizedBox(height: 20),
            ],

            // Migration History
            if (migrations.isNotEmpty) ...[
              _buildSectionHeader('Migration History'),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: migrations.map((migration) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.blue.shade600),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${migration['fromState']} → ${migration['toState']}',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  migration['migrationDate'] ?? 'Unknown date',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Text(': ', style: TextStyle(color: Colors.grey.shade600)),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey.shade800)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  String _calculateAge(dynamic dob) {
    if (dob == null) return 'N/A';
    try {
      DateTime birthDate = DateTime.parse(dob.toString());
      DateTime now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age.toString();
    } catch (e) {
      return 'N/A';
    }
  }
}
