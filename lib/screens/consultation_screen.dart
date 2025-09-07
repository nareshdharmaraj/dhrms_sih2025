import 'package:flutter/material.dart';

class ConsultationScreen extends StatefulWidget {
  final Map<String, dynamic> patient;
  final Map<String, dynamic> doctor;

  const ConsultationScreen({
    super.key,
    required this.patient,
    required this.doctor,
  });

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _symptomsController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();
  final _followUpController = TextEditingController();
  
  List<Map<String, dynamic>> _prescriptions = [];
  List<Map<String, dynamic>> _tests = [];
  Map<String, String> _vitals = {};
  
  final List<String> _commonSymptoms = [
    'Fever', 'Headache', 'Cough', 'Sore throat', 'Fatigue',
    'Nausea', 'Vomiting', 'Diarrhea', 'Abdominal pain', 'Chest pain',
    'Shortness of breath', 'Dizziness', 'Back pain', 'Joint pain'
  ];

  final List<String> _commonTests = [
    'Blood Test', 'Urine Test', 'X-Ray', 'ECG', 'MRI',
    'CT Scan', 'Ultrasound', 'Blood Sugar', 'Blood Pressure',
    'Lipid Profile', 'Liver Function Test', 'Kidney Function Test'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadPatientHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _symptomsController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();
    _followUpController.dispose();
    super.dispose();
  }

  void _loadPatientHistory() {
    // Load patient's vital signs
    _vitals = {
      'bloodPressure': widget.patient['bloodPressure'] ?? '',
      'pulse': widget.patient['pulse'] ?? '',
      'temperature': widget.patient['temperature'] ?? '',
      'weight': widget.patient['weight'] ?? '',
      'height': widget.patient['height'] ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Consultation - ${widget.patient['name']}'),
            Text(
              'Dr. ${widget.doctor['name']}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveConsultation,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.blue[200],
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.medical_information), text: 'Symptoms'),
            Tab(icon: Icon(Icons.medication), text: 'Prescription'),
            Tab(icon: Icon(Icons.science), text: 'Tests'),
            Tab(icon: Icon(Icons.assignment), text: 'Summary'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSymptomsTab(),
          _buildPrescriptionTab(),
          _buildTestsTab(),
          _buildSummaryTab(),
        ],
      ),
    );
  }

  Widget _buildSymptomsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.blue[100],
                        child: Text(
                          widget.patient['name'].split(' ').map((n) => n[0]).join(),
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.patient['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('${widget.patient['age']} years • ${widget.patient['gender']}'),
                            Text('Patient ID: ${widget.patient['patientId']}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (widget.patient['allergies'] != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red[700], size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Allergies: ${(widget.patient['allergies'] as List).join(', ')}',
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Current Vitals
          const Text(
            'Current Vitals',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildVitalsSection(),
          const SizedBox(height: 20),

          // Symptoms Section
          const Text(
            'Symptoms',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          // Common Symptoms Chips
          const Text('Common Symptoms:', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _commonSymptoms.map((symptom) => FilterChip(
              label: Text(symptom),
              selected: _symptomsController.text.contains(symptom),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    if (_symptomsController.text.isNotEmpty) {
                      _symptomsController.text += ', $symptom';
                    } else {
                      _symptomsController.text = symptom;
                    }
                  } else {
                    _symptomsController.text = _symptomsController.text
                        .replaceAll(RegExp('$symptom,?\\s*'), '');
                  }
                });
              },
            )).toList(),
          ),
          const SizedBox(height: 16),

          // Custom Symptoms Input
          TextField(
            controller: _symptomsController,
            decoration: const InputDecoration(
              labelText: 'Detailed Symptoms',
              hintText: 'Describe patient symptoms in detail...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.sick),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 16),

          // Diagnosis
          TextField(
            controller: _diagnosisController,
            decoration: const InputDecoration(
              labelText: 'Preliminary Diagnosis',
              hintText: 'Enter your diagnosis...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.medical_information),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          // Clinical Notes
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Clinical Notes',
              hintText: 'Additional observations and notes...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note_add),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildVitalField('Blood Pressure', 'bloodPressure', 'mmHg'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVitalField('Pulse', 'pulse', 'bpm'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildVitalField('Temperature', 'temperature', '°F'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVitalField('Weight', 'weight', 'kg'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalField(String label, String key, String unit) {
    return TextFormField(
      initialValue: _vitals[key],
      decoration: InputDecoration(
        labelText: '$label ($unit)',
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: (value) {
        setState(() {
          _vitals[key] = value;
        });
      },
    );
  }

  Widget _buildPrescriptionTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Icon(Icons.medication, color: Colors.blue[700]),
              const SizedBox(width: 8),
              const Text(
                'Prescription',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _addMedication,
                icon: const Icon(Icons.add),
                label: const Text('Add Medicine'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _prescriptions.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.medication, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No medications prescribed yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      Text(
                        'Tap "Add Medicine" to start prescribing',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _prescriptions.length,
                  itemBuilder: (context, index) {
                    return _buildMedicationCard(_prescriptions[index], index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> medication, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    medication['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _editMedication(index),
                  icon: const Icon(Icons.edit, size: 20),
                ),
                IconButton(
                  onPressed: () => _removeMedication(index),
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Dosage: ${medication['dosage']}'),
            Text('Frequency: ${medication['frequency']}'),
            Text('Duration: ${medication['duration']}'),
            if (medication['instructions'].isNotEmpty)
              Text('Instructions: ${medication['instructions']}'),
          ],
        ),
      ),
    );
  }

  Widget _buildTestsTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Icon(Icons.science, color: Colors.blue[700]),
              const SizedBox(width: 8),
              const Text(
                'Lab Tests & Investigations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _addTest,
                icon: const Icon(Icons.add),
                label: const Text('Add Test'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _tests.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.science, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No tests ordered yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      Text(
                        'Tap "Add Test" to order investigations',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tests.length,
                  itemBuilder: (context, index) {
                    return _buildTestCard(_tests[index], index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTestCard(Map<String, dynamic> test, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    test['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTestPriorityColor(test['priority']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    test['priority'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _removeTest(index),
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                ),
              ],
            ),
            if (test['notes'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Notes: ${test['notes']}'),
              ),
          ],
        ),
      ),
    );
  }

  Color _getTestPriorityColor(String priority) {
    switch (priority) {
      case 'Urgent':
        return Colors.red;
      case 'High':
        return Colors.orange;
      case 'Normal':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Consultation Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Consultation Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryItem('Patient', widget.patient['name']),
                  _buildSummaryItem('Doctor', widget.doctor['name']),
                  _buildSummaryItem('Date', DateTime.now().toString().split(' ')[0]),
                  _buildSummaryItem('Time', TimeOfDay.now().format(context)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Vitals Summary
          if (_vitals.values.any((v) => v.isNotEmpty))
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vital Signs',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ..._vitals.entries
                        .where((entry) => entry.value.isNotEmpty)
                        .map((entry) => _buildSummaryItem(
                              _formatVitalName(entry.key),
                              entry.value,
                            )),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Symptoms & Diagnosis
          if (_symptomsController.text.isNotEmpty || _diagnosisController.text.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Clinical Assessment',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (_symptomsController.text.isNotEmpty)
                      _buildSummaryItem('Symptoms', _symptomsController.text),
                    if (_diagnosisController.text.isNotEmpty)
                      _buildSummaryItem('Diagnosis', _diagnosisController.text),
                    if (_notesController.text.isNotEmpty)
                      _buildSummaryItem('Clinical Notes', _notesController.text),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Prescriptions Summary
          if (_prescriptions.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Prescription',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ..._prescriptions.map((med) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            '• ${med['name']} - ${med['dosage']} - ${med['frequency']}',
                          ),
                        )),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Tests Summary
          if (_tests.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lab Tests Ordered',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ..._tests.map((test) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text('• ${test['name']} (${test['priority']})'),
                        )),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Follow-up
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Follow-up Instructions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _followUpController,
                    decoration: const InputDecoration(
                      hintText: 'Enter follow-up instructions...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saveConsultation,
                  icon: const Icon(Icons.save),
                  label: const Text('Save & Complete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatVitalName(String key) {
    switch (key) {
      case 'bloodPressure':
        return 'Blood Pressure';
      case 'pulse':
        return 'Pulse';
      case 'temperature':
        return 'Temperature';
      case 'weight':
        return 'Weight';
      case 'height':
        return 'Height';
      default:
        return key;
    }
  }

  void _addMedication() {
    showDialog(
      context: context,
      builder: (context) => _MedicationDialog(
        onAdd: (medication) {
          setState(() {
            _prescriptions.add(medication);
          });
        },
      ),
    );
  }

  void _editMedication(int index) {
    showDialog(
      context: context,
      builder: (context) => _MedicationDialog(
        medication: _prescriptions[index],
        onAdd: (medication) {
          setState(() {
            _prescriptions[index] = medication;
          });
        },
      ),
    );
  }

  void _removeMedication(int index) {
    setState(() {
      _prescriptions.removeAt(index);
    });
  }

  void _addTest() {
    showDialog(
      context: context,
      builder: (context) => _TestDialog(
        commonTests: _commonTests,
        onAdd: (test) {
          setState(() {
            _tests.add(test);
          });
        },
      ),
    );
  }

  void _removeTest(int index) {
    setState(() {
      _tests.removeAt(index);
    });
  }

  void _saveConsultation() {
    // Update doctor's patient count
    widget.doctor['patientsCount'] = (widget.doctor['patientsCount'] as int) + 1;
    
    // Create consultation record
    final consultation = {
      'id': 'CON${DateTime.now().millisecondsSinceEpoch}',
      'patientId': widget.patient['patientId'],
      'patientName': widget.patient['name'],
      'doctorId': widget.doctor['doctorId'],
      'doctorName': widget.doctor['name'],
      'date': DateTime.now().toString().split(' ')[0],
      'time': TimeOfDay.now().format(context),
      'symptoms': _symptomsController.text,
      'diagnosis': _diagnosisController.text,
      'notes': _notesController.text,
      'vitals': _vitals,
      'prescriptions': _prescriptions,
      'tests': _tests,
      'followUp': _followUpController.text,
    };

    // TODO: Save consultation to database
    print('Consultation saved: ${consultation['id']}');

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Consultation saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back to doctor dashboard
    Navigator.pop(context);
  }
}

class _MedicationDialog extends StatefulWidget {
  final Map<String, dynamic>? medication;
  final Function(Map<String, dynamic>) onAdd;

  const _MedicationDialog({
    this.medication,
    required this.onAdd,
  });

  @override
  State<_MedicationDialog> createState() => _MedicationDialogState();
}

class _MedicationDialogState extends State<_MedicationDialog> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _durationController = TextEditingController();
  final _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _nameController.text = widget.medication!['name'];
      _dosageController.text = widget.medication!['dosage'];
      _frequencyController.text = widget.medication!['frequency'];
      _durationController.text = widget.medication!['duration'];
      _instructionsController.text = widget.medication!['instructions'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _durationController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.medication == null ? 'Add Medication' : 'Edit Medication'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Medicine Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dosageController,
              decoration: const InputDecoration(
                labelText: 'Dosage (e.g., 500mg)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _frequencyController,
              decoration: const InputDecoration(
                labelText: 'Frequency (e.g., Twice daily)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (e.g., 7 days)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Special Instructions',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty &&
                _dosageController.text.isNotEmpty &&
                _frequencyController.text.isNotEmpty &&
                _durationController.text.isNotEmpty) {
              widget.onAdd({
                'name': _nameController.text,
                'dosage': _dosageController.text,
                'frequency': _frequencyController.text,
                'duration': _durationController.text,
                'instructions': _instructionsController.text,
              });
              Navigator.pop(context);
            }
          },
          child: Text(widget.medication == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}

class _TestDialog extends StatefulWidget {
  final List<String> commonTests;
  final Function(Map<String, dynamic>) onAdd;

  const _TestDialog({
    required this.commonTests,
    required this.onAdd,
  });

  @override
  State<_TestDialog> createState() => _TestDialogState();
}

class _TestDialogState extends State<_TestDialog> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedPriority = 'Normal';

  final List<String> _priorities = ['Normal', 'High', 'Urgent'];

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Test'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Common Tests:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: widget.commonTests.map((test) => ActionChip(
                label: Text(test),
                onPressed: () {
                  _nameController.text = test;
                },
              )).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Test Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: _priorities.map((String priority) {
                return DropdownMenuItem<String>(
                  value: priority,
                  child: Text(priority),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedPriority = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              widget.onAdd({
                'name': _nameController.text,
                'priority': _selectedPriority,
                'notes': _notesController.text,
              });
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
