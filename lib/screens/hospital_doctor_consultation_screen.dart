import 'package:flutter/material.dart';
import 'hospital_doctor_prescription_screen.dart';
import '../widgets/disease_selection_modal.dart';

class HospitalDoctorConsultationScreen extends StatefulWidget {
  final Map<String, dynamic> appointmentData;
  final Map<String, dynamic> doctorData;

  const HospitalDoctorConsultationScreen({
    super.key,
    required this.appointmentData,
    required this.doctorData,
  });

  @override
  State<HospitalDoctorConsultationScreen> createState() =>
      _HospitalDoctorConsultationScreenState();
}

class _HospitalDoctorConsultationScreenState
    extends State<HospitalDoctorConsultationScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> _medicines = [];

  // Disease selection variables
  List<Map<String, dynamic>> _selectedDiseases = [];
  String _diseaseType = 'not_communicable';
  int? _expectedRecoveryDays;

  @override
  void dispose() {
    super.dispose();
  }

  void _addMedicine() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMedicineSelector(),
    );
  }

  Widget _buildMedicineSelector() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Medicine Type',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  _buildMedicineTypeButton(
                    'Tablet',
                    Icons.medical_services,
                    Colors.blue,
                  ),
                  SizedBox(height: 12),
                  _buildMedicineTypeButton(
                    'Tonic',
                    Icons.local_drink,
                    Colors.green,
                  ),
                  SizedBox(height: 12),
                  _buildMedicineTypeButton(
                    'Injection',
                    Icons.vaccines,
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineTypeButton(String type, IconData icon, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          _showMedicineForm(type.toLowerCase());
        },
        icon: Icon(icon, color: Colors.white),
        label: Text(type, style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showMedicineForm(String medicineType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicineEntryScreen(
          medicineType: medicineType,
          onMedicineAdded: (medicine) {
            setState(() {
              _medicines.add(medicine);
            });
          },
        ),
      ),
    );
  }

  void _removeMedicine(int index) {
    setState(() {
      _medicines.removeAt(index);
    });
  }

  Future<void> _showDiseaseSelection() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DiseaseSelectionModal(
        initialSelectedDiseases: _selectedDiseases,
        onDiseasesSelected: (result) {
          setState(() {
            _selectedDiseases = List<Map<String, dynamic>>.from(
              result['diseases'] ?? [],
            );
            _diseaseType = result['diseaseType'] ?? 'not_communicable';
            _expectedRecoveryDays = result['expectedRecoveryDays'];
          });
        },
      ),
    );
  }

  void _proceedToPrescription() {
    if (_formKey.currentState!.validate()) {
      if (_medicines.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please add at least one medicine'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedDiseases.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select at least one disease'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final consultationData = {
        'appointmentData': widget.appointmentData,
        'doctorData': widget.doctorData,
        'diseases': _selectedDiseases,
        'diseaseType': _diseaseType,
        'expectedRecoveryDays':
            _expectedRecoveryDays ??
            (_diseaseType == 'communicable' ? null : 0),
        'medicines': _medicines,
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HospitalDoctorPrescriptionScreen(
            consultationData: consultationData,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Consultation'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPatientInfoCard(),
                    SizedBox(height: 20),
                    _buildDiseaseInfoSection(),
                    SizedBox(height: 20),
                    _buildMedicinesSection(),
                  ],
                ),
              ),
            ),
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, color: Colors.blue.shade600, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.appointmentData['patientName'] ?? 'Unknown Patient',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.badge, color: Colors.blue.shade600, size: 20),
                SizedBox(width: 8),
                Text(
                  'UHID: ${widget.appointmentData['patientUhid'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.blue.shade600, size: 20),
                SizedBox(width: 8),
                Text(
                  'Appointment: ${widget.appointmentData['appointmentDate'] ?? 'N/A'} ${widget.appointmentData['appointmentTime'] ?? ''}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.confirmation_number,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Appointment Number: ${widget.appointmentData['appointmentId'] ?? widget.appointmentData['appointmentNumber'] ?? 'Not Available'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseInfoSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Disease Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showDiseaseSelection,
                  icon: Icon(Icons.add),
                  label: Text('Select Diseases'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_selectedDiseases.isEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'No diseases selected. Tap "Select Diseases" to add conditions.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Diseases:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _selectedDiseases.map((disease) {
                      return Chip(
                        label: Text(disease['name']),
                        backgroundColor: disease['isCustom'] == true
                            ? Colors.orange.shade100
                            : Colors.blue.shade100,
                        deleteIcon: Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() {
                            _selectedDiseases.remove(disease);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicinesSection() {
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
                  child: Text(
                    'Prescription Medicines',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addMedicine,
                  icon: Icon(Icons.add, size: 16),
                  label: Text('Add Medicine'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_medicines.isEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.medication,
                      size: 48,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No medicines added yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap "Add Medicine" to start prescription',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _medicines.length,
                separatorBuilder: (context, index) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final medicine = _medicines[index];
                  return _buildMedicineCard(medicine, index);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineCard(Map<String, dynamic> medicine, int index) {
    Color typeColor;
    IconData typeIcon;

    switch (medicine['type']) {
      case 'tablet':
        typeColor = Colors.blue;
        typeIcon = Icons.medical_services;
        break;
      case 'tonic':
        typeColor = Colors.green;
        typeIcon = Icons.local_drink;
        break;
      case 'injection':
        typeColor = Colors.orange;
        typeIcon = Icons.vaccines;
        break;
      default:
        typeColor = Colors.grey;
        typeIcon = Icons.medication;
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.1),
        border: Border.all(color: typeColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(typeIcon, color: typeColor, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine['name'] ?? 'Unknown Medicine',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: typeColor,
                  ),
                ),
                if (medicine['power'] != null && medicine['power'].isNotEmpty)
                  Text(
                    'Power: ${medicine['power']}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                _buildMedicineDetails(medicine),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeMedicine(index),
            icon: Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineDetails(Map<String, dynamic> medicine) {
    switch (medicine['type']) {
      case 'tablet':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${medicine['countPerDose']} tablet(s) per dose',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            Text(
              'Timing: ${(medicine['timing'] as List).join(', ')}',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            Text(
              '${medicine['beforeAfterFood']} food • ${medicine['duration']} days',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            Text(
              'Total: ${medicine['totalCount']} tablets',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      case 'tonic':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${medicine['mlPerDose']} ml per dose',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            Text(
              'Timing: ${(medicine['timing'] as List).join(', ')}',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            Text(
              '${medicine['beforeAfterFood']} food • ${medicine['duration']} days',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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
                'Dosage: ${medicine['dosageDetails']}',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            if (medicine['frequency'] != null &&
                medicine['frequency'].isNotEmpty)
              Text(
                'Frequency: ${medicine['frequency']}',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            if (medicine['additionalNotes'] != null &&
                medicine['additionalNotes'].isNotEmpty)
              Text(
                'Notes: ${medicine['additionalNotes']}',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
          ],
        );
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildBottomActionBar() {
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
          onPressed: _medicines.isEmpty ? null : _proceedToPrescription,
          icon: Icon(Icons.assignment, color: Colors.white),
          label: Text(
            'Generate Prescription',
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

class MedicineEntryScreen extends StatefulWidget {
  final String medicineType;
  final Function(Map<String, dynamic>) onMedicineAdded;

  const MedicineEntryScreen({
    super.key,
    required this.medicineType,
    required this.onMedicineAdded,
  });

  @override
  State<MedicineEntryScreen> createState() => _MedicineEntryScreenState();
}

class _MedicineEntryScreenState extends State<MedicineEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _powerController = TextEditingController();
  final _countPerDoseController = TextEditingController();
  final _durationController = TextEditingController();
  final _mlPerDoseController = TextEditingController();
  final _dosageDetailsController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _additionalNotesController = TextEditingController();

  final List<String> _selectedTiming = [];
  String _beforeAfterFood = 'after';
  int _totalCount = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _powerController.dispose();
    _countPerDoseController.dispose();
    _durationController.dispose();
    _mlPerDoseController.dispose();
    _dosageDetailsController.dispose();
    _frequencyController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  void _calculateTotalCount() {
    if (widget.medicineType == 'tablet') {
      final countPerDose = int.tryParse(_countPerDoseController.text) ?? 0;
      final duration = int.tryParse(_durationController.text) ?? 0;
      setState(() {
        _totalCount = countPerDose * _selectedTiming.length * duration;
      });
    }
  }

  void _saveMedicine() {
    if (_formKey.currentState!.validate()) {
      final medicine = <String, dynamic>{
        'type': widget.medicineType,
        'name': _nameController.text.trim(),
      };

      switch (widget.medicineType) {
        case 'tablet':
          if (_selectedTiming.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please select at least one timing'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          medicine.addAll({
            'power': _powerController.text.trim(),
            'countPerDose': int.parse(_countPerDoseController.text),
            'timing': _selectedTiming,
            'beforeAfterFood': _beforeAfterFood,
            'duration': int.parse(_durationController.text),
            'totalCount': _totalCount,
          });
          break;
        case 'tonic':
          if (_selectedTiming.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please select at least one timing'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          medicine.addAll({
            'mlPerDose': int.parse(_mlPerDoseController.text),
            'timing': _selectedTiming,
            'beforeAfterFood': _beforeAfterFood,
            'duration': int.parse(_durationController.text),
          });
          break;
        case 'injection':
          medicine.addAll({
            'dosageDetails': _dosageDetailsController.text.trim(),
            'frequency': _frequencyController.text.trim(),
            'additionalNotes': _additionalNotesController.text.trim(),
          });
          break;
      }

      widget.onMedicineAdded(medicine);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add ${widget.medicineType.toUpperCase()}'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: _buildMedicineForm(),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: '${widget.medicineType.toUpperCase()} Name *',
            hintText: 'Enter medicine name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter medicine name';
            }
            return null;
          },
        ),
        SizedBox(height: 16),

        if (widget.medicineType == 'tablet') ..._buildTabletForm(),
        if (widget.medicineType == 'tonic') ..._buildTonicForm(),
        if (widget.medicineType == 'injection') ..._buildInjectionForm(),
      ],
    );
  }

  List<Widget> _buildTabletForm() {
    return [
      TextFormField(
        controller: _powerController,
        decoration: InputDecoration(
          labelText: 'Power/Strength (Optional)',
          hintText: 'e.g., 500mg, 10mg',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _countPerDoseController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Count per Dose *',
          hintText: 'Number of tablets per dose',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter count per dose';
          }
          if (int.tryParse(value) == null || int.parse(value) < 1) {
            return 'Please enter a valid number';
          }
          return null;
        },
        onChanged: (value) => _calculateTotalCount(),
      ),
      SizedBox(height: 16),
      _buildTimingSelector(),
      SizedBox(height: 16),
      _buildFoodSelector(),
      SizedBox(height: 16),
      TextFormField(
        controller: _durationController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Duration (Days) *',
          hintText: 'Number of days',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter duration';
          }
          if (int.tryParse(value) == null || int.parse(value) < 1) {
            return 'Please enter a valid number of days';
          }
          return null;
        },
        onChanged: (value) => _calculateTotalCount(),
      ),
      if (_totalCount > 0) ...[
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border.all(color: Colors.blue.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.calculate, color: Colors.blue.shade700),
              SizedBox(width: 12),
              Text(
                'Total Tablets Required: $_totalCount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    ];
  }

  List<Widget> _buildTonicForm() {
    return [
      TextFormField(
        controller: _mlPerDoseController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'ML per Dose *',
          hintText: 'Milliliters per dose',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter ML per dose';
          }
          if (int.tryParse(value) == null || int.parse(value) < 1) {
            return 'Please enter a valid amount';
          }
          return null;
        },
      ),
      SizedBox(height: 16),
      _buildTimingSelector(),
      SizedBox(height: 16),
      _buildFoodSelector(),
      SizedBox(height: 16),
      TextFormField(
        controller: _durationController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Duration (Days) *',
          hintText: 'Number of days',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter duration';
          }
          if (int.tryParse(value) == null || int.parse(value) < 1) {
            return 'Please enter a valid number of days';
          }
          return null;
        },
      ),
    ];
  }

  List<Widget> _buildInjectionForm() {
    return [
      TextFormField(
        controller: _dosageDetailsController,
        decoration: InputDecoration(
          labelText: 'Dosage Details',
          hintText: 'Enter dosage information',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _frequencyController,
        decoration: InputDecoration(
          labelText: 'Frequency',
          hintText: 'How often to administer',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _additionalNotesController,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: 'Additional Notes',
          hintText: 'Any special instructions',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ];
  }

  Widget _buildTimingSelector() {
    final timings = ['morning', 'afternoon', 'evening', 'night'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'When to Take *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: timings.map((timing) {
            final isSelected = _selectedTiming.contains(timing);
            return FilterChip(
              label: Text(timing.toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTiming.add(timing);
                  } else {
                    _selectedTiming.remove(timing);
                  }
                  _calculateTotalCount();
                });
              },
              selectedColor: Colors.blue.shade100,
              checkmarkColor: Colors.blue.shade700,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Food Instruction',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: Text('Before Food'),
                value: 'before',
                groupValue: _beforeAfterFood,
                onChanged: (value) {
                  setState(() {
                    _beforeAfterFood = value!;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: Text('After Food'),
                value: 'after',
                groupValue: _beforeAfterFood,
                onChanged: (value) {
                  setState(() {
                    _beforeAfterFood = value!;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _saveMedicine,
          icon: Icon(Icons.save, color: Colors.white),
          label: Text(
            'Add Medicine',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
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
