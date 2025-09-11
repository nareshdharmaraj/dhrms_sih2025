import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool isScanning = true;
  String? scannedData;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture barcodeCapture) async {
    if (!isScanning) return;
    
    final List<Barcode> barcodes = barcodeCapture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          isScanning = false;
          scannedData = barcode.rawValue;
        });
        
        // Process the scanned UHID
        await _processScannedUHID(barcode.rawValue!);
        break;
      }
    }
  }

  Future<void> _processScannedUHID(String data) async {
    try {
      // Try to parse as JSON first (in case it's QR code data)
      String uhid = data;
      try {
        final Map<String, dynamic> qrData = json.decode(data);
        if (qrData['uhid'] != null) {
          uhid = qrData['uhid'];
        }
      } catch (e) {
        // If parsing fails, treat data as direct UHID
        uhid = data;
      }

      // Fetch patient data
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/patients/uhid/$uhid'),
        headers: {'Content-Type': 'application/json'},
      );

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
          _showErrorDialog('Patient not found', responseData['message']);
        }
      } else {
        _showErrorDialog('Error', 'Failed to fetch patient data');
      }
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Scan Patient QR Code'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: Icon(Icons.flip_camera_ios),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera View
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          
          // Overlay
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
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
                        child: Container(
                          color: Colors.black.withOpacity(0.7),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: Colors.black.withOpacity(0.7),
                        ),
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
                            'Position the QR code within the frame',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Scanning for patient health card...',
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
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    if (scannedData != null) ...[
                      SizedBox(height: 10),
                      Text(
                        'UHID: $scannedData',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
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
}

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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade600, Colors.teal.shade400],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Patient Photo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white, width: 3),
                      color: Colors.white,
                    ),
                    child: patientData['photo'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              base64Decode(patientData['photo']),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey.shade500,
                          ),
                  ),
                  SizedBox(width: 20),
                  // Patient Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patientData['fullName'] ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'UHID: ${patientData['uhid']}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.bloodtype, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Blood: ${patientData['bloodGroup'] ?? 'Unknown'}',
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            SizedBox(width: 15),
                            Icon(Icons.phone, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              patientData['phone'] ?? 'N/A',
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // Basic Information
            _buildInfoCard(
              'Basic Information',
              Icons.person_outline,
              [
                _buildInfoRow('Gender', patientData['gender']?.toString().toUpperCase() ?? 'N/A'),
                _buildInfoRow('Date of Birth', _formatDate(patientData['dateOfBirth'])),
                _buildInfoRow('Email', patientData['email'] ?? 'Not provided'),
                _buildInfoRow('Aadhaar', '**** **** ${patientData['aadhaarNumber']?.substring(8) ?? 'N/A'}'),
              ],
            ),
            
            SizedBox(height: 20),
            
            // Address Information
            if (patientData['address'] != null)
              _buildInfoCard(
                'Address',
                Icons.location_on_outlined,
                [
                  _buildInfoRow('Street', patientData['address']['street'] ?? 'N/A'),
                  _buildInfoRow('City', patientData['address']['city'] ?? 'N/A'),
                  _buildInfoRow('State', patientData['address']['state'] ?? 'N/A'),
                  _buildInfoRow('ZIP Code', patientData['address']['zipCode'] ?? 'N/A'),
                ],
              ),
            
            SizedBox(height: 20),
            
            // Emergency Contact
            if (patientData['emergencyContact'] != null)
              _buildInfoCard(
                'Emergency Contact',
                Icons.emergency,
                [
                  _buildInfoRow('Name', patientData['emergencyContact']['name'] ?? 'N/A'),
                  _buildInfoRow('Relationship', patientData['emergencyContact']['relationship'] ?? 'N/A'),
                  _buildInfoRow('Phone', patientData['emergencyContact']['phone'] ?? 'N/A'),
                ],
              ),
            
            SizedBox(height: 20),
            
            // Migration Status
            if (patientData['isMigrant'] == true)
              _buildMigrationCard(),
            
            SizedBox(height: 20),
            
            // Medical Information
            _buildMedicalInfoCard(),
            
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue.shade600, size: 24),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMigrationCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.orange.shade100],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.travel_explore, color: Colors.orange.shade600, size: 24),
              SizedBox(width: 10),
              Text(
                'Migrant Worker Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          if (patientData['migrantDetails'] != null) ...[
            _buildInfoRow('Current State', patientData['migrantDetails']['currentState'] ?? 'N/A'),
            _buildInfoRow('Current City', patientData['migrantDetails']['currentCity'] ?? 'N/A'),
            _buildInfoRow('Registered Hospital', patientData['migrantDetails']['registeredHospital'] ?? 'N/A'),
            _buildInfoRow('Home State', patientData['homeState'] ?? 'N/A'),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicalInfoCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medical_services, color: Colors.green.shade600, size: 24),
              SizedBox(width: 10),
              Text(
                'Medical Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          
          // Allergies
          if (patientData['allergies'] != null && patientData['allergies'].isNotEmpty) ...[
            Text(
              'Allergies',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.red.shade600,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: (patientData['allergies'] as List).map((allergy) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    allergy.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade700,
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 15),
          ],
          
          // Current Medications
          if (patientData['currentMedications'] != null && patientData['currentMedications'].isNotEmpty) ...[
            Text(
              'Current Medications',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade600,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            Column(
              children: (patientData['currentMedications'] as List).map((med) {
                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.medication, color: Colors.blue.shade600, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${med['name']} - ${med['dosage']} (${med['frequency']})',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
          
          // Medical History
          if (patientData['medicalHistory'] != null && patientData['medicalHistory'].isNotEmpty) ...[
            SizedBox(height: 15),
            Text(
              'Medical History',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.purple.shade600,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            Column(
              children: (patientData['medicalHistory'] as List).map((history) {
                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.purple.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        history['condition']?.toString() ?? 'Unknown condition',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple.shade700,
                        ),
                      ),
                      if (history['diagnosedDate'] != null) ...[
                        SizedBox(height: 4),
                        Text(
                          'Diagnosed: ${_formatDate(history['diagnosedDate'])}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.purple.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
