import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';

class HospitalDoctorPrescriptionScreen extends StatefulWidget {
  final Map<String, dynamic> consultationData;

  const HospitalDoctorPrescriptionScreen({
    super.key,
    required this.consultationData,
  });

  @override
  State<HospitalDoctorPrescriptionScreen> createState() =>
      _HospitalDoctorPrescriptionScreenState();
}

class _HospitalDoctorPrescriptionScreenState
    extends State<HospitalDoctorPrescriptionScreen> {
  final _nextVisitController = TextEditingController();
  bool _isNextVisitMandatory = false;
  bool _isConfirmed = false;
  bool _isLoading = false;
  DateTime? _selectedNextVisitDate;

  // Disease selection variables
  List<Map<String, dynamic>> _selectedDiseases = [];
  String _diseaseType = 'not_communicable';
  int? _expectedRecoveryDays;

  @override
  void initState() {
    super.initState();
    // Initialize diseases from consultation data
    if (widget.consultationData['diseases'] != null) {
      _selectedDiseases = List<Map<String, dynamic>>.from(
        widget.consultationData['diseases'],
      );
    }
    // Initialize disease type and recovery days
    _diseaseType = widget.consultationData['diseaseType'] ?? 'not_communicable';
    _expectedRecoveryDays = widget.consultationData['expectedRecoveryDays'];
  }

  @override
  void dispose() {
    _nextVisitController.dispose();
    super.dispose();
  }

  Future<void> _selectNextVisitDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 7)),
      firstDate: DateTime.now().add(Duration(days: 1)),
      lastDate: DateTime.now().add(Duration(days: 365)),
      helpText: 'Select Next Visit Date',
      cancelText: 'Cancel',
      confirmText: 'OK',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedNextVisitDate = picked;
        _isNextVisitMandatory = true;
        _nextVisitController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _savePrescription() async {
    // Validate diseases selection
    final diseases = widget.consultationData['diseases'] ?? [];
    if (diseases.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one disease'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please confirm the prescription before saving'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate expected recovery days for communicable diseases
    if (_diseaseType == 'communicable' &&
        (_expectedRecoveryDays == null || _expectedRecoveryDays! <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter expected recovery days for communicable diseases',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final appointmentData = widget.consultationData['appointmentData'];
      final doctorData = widget.consultationData['doctorData'];

      final prescriptionData = {
        'appointmentId': appointmentData['_id'],
        'doctorId': doctorData['_id'],
        'patientId': appointmentData['patientId'],
        'hospitalId': doctorData['hospitalId'],
        'patientName': appointmentData['patientName'],
        'patientUHID': appointmentData['patientUhid'],
        'doctorName': doctorData['name'],
        'doctorIdentifier': doctorData['doctorId'],
        'hospitalName': doctorData['hospitalName'],
        'hospitalAddress':
            doctorData['hospitalAddress'] ??
            appointmentData['hospitalAddress'] ??
            doctorData['address'] ??
            'Address not available',
        'hospitalContact': {
          'phone': doctorData['hospitalPhone'] ?? '',
          'email': doctorData['hospitalEmail'] ?? '',
        },
        'appointmentNumber':
            appointmentData['appointmentId'] ??
            appointmentData['appointmentNumber'] ??
            'Not Available',
        'diseases': widget
            .consultationData['diseases'], // Using diseases from consultation
        'diseaseType':
            widget.consultationData['diseaseType'] ??
            'not_communicable', // From consultation
        'expectedRecoveryDays':
            widget.consultationData['expectedRecoveryDays'] ??
            (widget.consultationData['diseaseType'] == 'communicable'
                ? null
                : 0), // From consultation with default
        'medicines': widget.consultationData['medicines'],
        'nextVisitMandatory': _isNextVisitMandatory,
        'isConfirmed': true,
      };

      // Only include nextVisitDate if it's actually set
      if (_selectedNextVisitDate != null) {
        prescriptionData['nextVisitDate'] = _selectedNextVisitDate!
            .toIso8601String();
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      print(
        '🔑 Auth token: ${token.isEmpty ? "EMPTY" : "EXISTS (${token.length} chars)"}',
      );
      print('📋 Prescription data: ${json.encode(prescriptionData)}');
      print('🌐 API URL: ${AppConstants.baseUrl}/prescriptions');

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/prescriptions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(prescriptionData),
      );

      print('📡 Response Status Code: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 201) {
        print('✅ Prescription created successfully, updating appointment...');

        // Update appointment status to completed
        await http.patch(
          Uri.parse(
            '${AppConstants.baseUrl}/appointments/${appointmentData['_id']}/complete',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Prescription saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to doctor appointments page (pop back through consultation -> appointments)
        Navigator.of(context).pop(); // From prescription screen
        Navigator.of(
          context,
        ).pop(); // From consultation screen back to appointments
      } else {
        print('❌ Failed to save prescription. Status: ${response.statusCode}');
        print('❌ Error response: ${response.body}');
        throw Exception(
          'Failed to save prescription: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving prescription: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Prescription'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                      SizedBox(height: 20),
                      _buildNextVisitSection(),
                      SizedBox(height: 20),
                      _buildConfirmationSection(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildPrescriptionHeader() {
    final doctorData = widget.consultationData['doctorData'];

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
                doctorData['hospitalName'] ?? 'Hospital Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 4),
              Text(
                doctorData['hospitalAddress'] ?? 'Hospital Address',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                textAlign: TextAlign.right,
              ),
              if (doctorData['hospitalPhone'] != null) ...[
                Text(
                  'Ph: ${doctorData['hospitalPhone']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  textAlign: TextAlign.right,
                ),
              ],
              if (doctorData['hospitalEmail'] != null) ...[
                Text(
                  '${doctorData['hospitalEmail']}',
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
    final appointmentData = widget.consultationData['appointmentData'];
    final doctorData = widget.consultationData['doctorData'];

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
                    'Dr. ${doctorData['name'] ?? 'Unknown'}',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'ID: ${doctorData['doctorId'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            // Patient details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    appointmentData['patientName'] ?? 'Unknown Patient',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'UHID: ${appointmentData['patientUhid'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
            Text(
              '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} - ${TimeOfDay.now().format(context)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            Text(
              'Appointment No: ${appointmentData['appointmentId'] ?? appointmentData['appointmentNumber'] ?? 'Not Available'}',
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
          Row(
            children: [
              Text(
                'Disease Selection',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              Spacer(),
              Icon(
                Icons.medical_information,
                color: Colors.blue.shade700,
                size: 20,
              ),
            ],
          ),
          SizedBox(height: 12),

          // Display selected diseases from consultation
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.blue.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade600,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Diagnosed Diseases (${_selectedDiseases.length})',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
                if (_selectedDiseases.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: _selectedDiseases.map((disease) {
                      return Chip(
                        label: Text(
                          disease['name'],
                          style: TextStyle(fontSize: 11),
                        ),
                        backgroundColor: disease['isCustom']
                            ? Colors.orange.shade100
                            : Colors.blue.shade100,
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 12),

          // Display disease type (read-only)
          Row(
            children: [
              Text(
                'Disease Type:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade800,
                ),
              ),
              SizedBox(width: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _diseaseType == 'communicable'
                      ? Colors.orange.shade100
                      : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _diseaseType == 'communicable'
                        ? Colors.orange.shade300
                        : Colors.green.shade300,
                  ),
                ),
                child: Text(
                  _diseaseType == 'communicable'
                      ? 'Communicable'
                      : 'Non-Communicable',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _diseaseType == 'communicable'
                        ? Colors.orange.shade700
                        : Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),

          // Display recovery days if communicable (read-only)
          if (_diseaseType == 'communicable' &&
              _expectedRecoveryDays != null) ...[
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Expected Recovery:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blue.shade300),
                  ),
                  child: Text(
                    '$_expectedRecoveryDays days',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrescriptionBody() {
    final medicines =
        widget.consultationData['medicines'] as List<Map<String, dynamic>>;

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
    List<Map<String, dynamic>> medicines,
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

  Widget _buildMedicineEntry(int index, Map<String, dynamic> medicine) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 13, color: Colors.black),
            children: [
              TextSpan(
                text: '$index. ${medicine['name']}',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              if (medicine['power'] != null && medicine['power'].isNotEmpty)
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

  Widget _buildMedicineDetails(Map<String, dynamic> medicine) {
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
              '→ Timing: ${(medicine['timing'] as List).map((t) => t.toUpperCase()).join(', ')}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            Text(
              '→ Instruction: ${medicine['beforeAfterFood'].toUpperCase()} Food',
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
              '→ Timing: ${(medicine['timing'] as List).map((t) => t.toUpperCase()).join(', ')}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            Text(
              '→ Instruction: ${medicine['beforeAfterFood'].toUpperCase()} Food',
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
                medicine['dosageDetails'].isNotEmpty)
              Text(
                '→ Dosage: ${medicine['dosageDetails']}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            if (medicine['frequency'] != null &&
                medicine['frequency'].isNotEmpty)
              Text(
                '→ Frequency: ${medicine['frequency']}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            if (medicine['additionalNotes'] != null &&
                medicine['additionalNotes'].isNotEmpty)
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Next Visit',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _selectNextVisitDate,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 8),
                      Text(
                        _selectedNextVisitDate != null
                            ? '${_selectedNextVisitDate!.day}/${_selectedNextVisitDate!.month}/${_selectedNextVisitDate!.year}'
                            : 'Select next visit date',
                        style: TextStyle(
                          fontSize: 13,
                          color: _selectedNextVisitDate != null
                              ? Colors.black
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedNextVisitDate = null;
                  _isNextVisitMandatory = false;
                  _nextVisitController.clear();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isNextVisitMandatory
                    ? Colors.grey.shade300
                    : Colors.orange.shade600,
                foregroundColor: _isNextVisitMandatory
                    ? Colors.grey.shade600
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text('Not Mandatory'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfirmationSection() {
    return CheckboxListTile(
      value: _isConfirmed,
      onChanged: (value) {
        setState(() {
          _isConfirmed = value ?? false;
        });
      },
      title: Text(
        'I confirm this prescription is correct.',
        style: TextStyle(fontSize: 14),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isConfirmed && !_isLoading ? _savePrescription : null,
          icon: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(Icons.save, color: Colors.white),
          label: Text(
            _isLoading ? 'Saving...' : 'Save & Complete',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            disabledBackgroundColor: Colors.grey.shade300,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
