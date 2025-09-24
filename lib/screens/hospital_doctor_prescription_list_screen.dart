import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';

class HospitalDoctorPrescriptionListScreen extends StatefulWidget {
  final Map<String, dynamic> doctorData;

  const HospitalDoctorPrescriptionListScreen({
    super.key,
    required this.doctorData,
  });

  @override
  State<HospitalDoctorPrescriptionListScreen> createState() =>
      _HospitalDoctorPrescriptionListScreenState();
}

class _HospitalDoctorPrescriptionListScreenState
    extends State<HospitalDoctorPrescriptionListScreen> {
  List<Map<String, dynamic>> _prescriptions = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  Future<void> _loadPrescriptions() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.get(
        Uri.parse(
          '${AppConstants.baseUrl}/prescriptions/doctor/${widget.doctorData['_id']}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _prescriptions = List<Map<String, dynamic>>.from(data['data']);
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = data['message'] ?? 'Failed to load prescriptions';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Server error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  void _viewPrescription(Map<String, dynamic> prescription) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrescriptionViewScreen(
          prescription: prescription,
          showPatientInfo: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Prescriptions'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading prescriptions...',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            SizedBox(height: 16),
            Text(
              'Error Loading Prescriptions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadPrescriptions,
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_prescriptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment, size: 64, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text(
              'No Prescriptions Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Prescriptions will appear here after you complete consultations',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPrescriptions,
      child: ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: _prescriptions.length,
        separatorBuilder: (context, index) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          final prescription = _prescriptions[index];
          return _buildPrescriptionCard(prescription);
        },
      ),
    );
  }

  Widget _buildPrescriptionCard(Map<String, dynamic> prescription) {
    final consultationDate = DateTime.tryParse(
      prescription['consultationDate'] ?? '',
    );
    final medicineCount = (prescription['medicines'] as List?)?.length ?? 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prescription['patientName'] ?? 'Unknown Patient',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'UHID: ${prescription['patientUHID'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'COMPLETED',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.medical_information,
                        size: 16,
                        color: Colors.blue.shade700,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          prescription['diseaseName'] ?? 'Unknown Disease',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.medication,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '$medicineCount medicine${medicineCount != 1 ? 's' : ''} prescribed',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  if (consultationDate != null) ...[
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${consultationDate.day}/${consultationDate.month}/${consultationDate.year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _viewPrescription(prescription),
                icon: Icon(Icons.visibility, size: 16),
                label: Text('View Prescription'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrescriptionViewScreen extends StatelessWidget {
  final Map<String, dynamic> prescription;
  final bool showPatientInfo;

  const PrescriptionViewScreen({
    super.key,
    required this.prescription,
    this.showPatientInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prescription'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement share/print functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Share/Print functionality coming soon'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            icon: Icon(Icons.share),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPrescriptionHeader(),
                _buildDivider(),
                _buildDoctorPatientDetails(),
                SizedBox(height: 20),
                _buildConsultationInfo(),
                SizedBox(height: 20),
                _buildPrescriptionBody(),
                if (prescription['nextVisitDate'] != null) ...[
                  SizedBox(height: 20),
                  _buildNextVisitSection(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrescriptionHeader() {
    return Row(
      children: [
        // Left side - App branding
        Expanded(
          flex: 1,
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    'MH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'My Health',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
        ),
        // Right side - Hospital info
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                prescription['hospitalName'] ?? 'Hospital Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 4),
              Text(
                prescription['hospitalAddress'] ?? 'Hospital Address',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                textAlign: TextAlign.right,
              ),
              if (prescription['hospitalContact']?['phone'] != null) ...[
                Text(
                  'Ph: ${prescription['hospitalContact']['phone']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  textAlign: TextAlign.right,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      height: 1,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildDoctorPatientDetails() {
    final consultationDate = DateTime.tryParse(
      prescription['consultationDate'] ?? '',
    );

    return Column(
      children: [
        Row(
          children: [
            // Doctor details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. ${prescription['doctorName'] ?? 'Unknown'}',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'ID: ${prescription['doctorId'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            // Patient details (only show if enabled)
            if (showPatientInfo)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      prescription['patientName'] ?? 'Unknown Patient',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'UHID: ${prescription['patientUHID'] ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: 12),
        // Date and appointment number
        Column(
          children: [
            if (consultationDate != null)
              Text(
                '${consultationDate.day}/${consultationDate.month}/${consultationDate.year}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            Text(
              'Appointment No: ${prescription['appointmentNumber'] ?? 'N/A'}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConsultationInfo() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consultation Details',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Disease: ${prescription['diseaseName']}',
            style: TextStyle(fontSize: 13),
          ),
          Text(
            'Type: ${prescription['diseaseType'] == 'communicable' ? 'Communicable' : 'Non-Communicable'}',
            style: TextStyle(fontSize: 13),
          ),
          if (prescription['expectedRecoveryDays'] != null)
            Text(
              'Expected Recovery: ${prescription['expectedRecoveryDays']} days',
              style: TextStyle(fontSize: 13),
            ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionBody() {
    final medicines = prescription['medicines'] as List<dynamic>? ?? [];

    // Group medicines by type
    final tablets = medicines.where((m) => m['type'] == 'tablet').toList();
    final tonics = medicines.where((m) => m['type'] == 'tonic').toList();
    final injections = medicines
        .where((m) => m['type'] == 'injection')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRESCRIPTION',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
        SizedBox(height: 16),

        if (tablets.isNotEmpty) ...[
          _buildMedicineSection('TABLETS', tablets, Icons.medical_services),
          SizedBox(height: 16),
        ],

        if (tonics.isNotEmpty) ...[
          _buildMedicineSection('TONICS', tonics, Icons.local_drink),
          SizedBox(height: 16),
        ],

        if (injections.isNotEmpty) ...[
          _buildMedicineSection('INJECTIONS', injections, Icons.vaccines),
        ],
      ],
    );
  }

  Widget _buildMedicineSection(
    String title,
    List<dynamic> medicines,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade700),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ...medicines.asMap().entries.map((entry) {
          final index = entry.key;
          final medicine = entry.value;
          return Padding(
            padding: EdgeInsets.only(left: 16, bottom: 8),
            child: _buildMedicineEntry(index + 1, medicine),
          );
        }),
      ],
    );
  }

  Widget _buildMedicineEntry(int index, dynamic medicine) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 13, color: Colors.black),
            children: [
              TextSpan(
                text: '$index. ${medicine['name'] ?? 'Unknown Medicine'}',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              if (medicine['power'] != null &&
                  medicine['power'].toString().isNotEmpty)
                TextSpan(text: ' (${medicine['power']})'),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 16, top: 4),
          child: _buildMedicineDetails(medicine),
        ),
      ],
    );
  }

  Widget _buildMedicineDetails(dynamic medicine) {
    switch (medicine['type']) {
      case 'tablet':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '→ Count per dose: ${medicine['countPerDose']} tablet(s)',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            Text(
              '→ Timing: ${(medicine['timing'] as List?)?.map((t) => t.toString().toUpperCase()).join(', ') ?? 'N/A'}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            Text(
              '→ Instruction: ${medicine['beforeAfterFood']?.toString().toUpperCase() ?? 'N/A'} Food',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            Text(
              '→ Duration: ${medicine['duration']} days',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            Text(
              '→ Total Count: ${medicine['totalCount']} tablets',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        );
      case 'tonic':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '→ Dosage: ${medicine['mlPerDose']} ml per dose',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            Text(
              '→ Timing: ${(medicine['timing'] as List?)?.map((t) => t.toString().toUpperCase()).join(', ') ?? 'N/A'}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            Text(
              '→ Instruction: ${medicine['beforeAfterFood']?.toString().toUpperCase() ?? 'N/A'} Food',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            Text(
              '→ Duration: ${medicine['duration']} days',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
        );
      case 'injection':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (medicine['dosageDetails'] != null &&
                medicine['dosageDetails'].toString().isNotEmpty)
              Text(
                '→ Dosage: ${medicine['dosageDetails']}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            if (medicine['frequency'] != null &&
                medicine['frequency'].toString().isNotEmpty)
              Text(
                '→ Frequency: ${medicine['frequency']}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            if (medicine['additionalNotes'] != null &&
                medicine['additionalNotes'].toString().isNotEmpty)
              Text(
                '→ Notes: ${medicine['additionalNotes']}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
          ],
        );
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildNextVisitSection() {
    final nextVisitDate = DateTime.tryParse(
      prescription['nextVisitDate'] ?? '',
    );

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade200),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 16, color: Colors.orange.shade700),
          SizedBox(width: 8),
          Text(
            'Next Visit: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
          ),
          Text(
            nextVisitDate != null
                ? '${nextVisitDate.day}/${nextVisitDate.month}/${nextVisitDate.year}'
                : 'Not Mandatory',
            style: TextStyle(fontSize: 14, color: Colors.orange.shade700),
          ),
        ],
      ),
    );
  }
}
