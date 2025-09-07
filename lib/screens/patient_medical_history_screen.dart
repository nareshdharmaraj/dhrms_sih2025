import 'package:flutter/material.dart';

class PatientMedicalHistoryScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const PatientMedicalHistoryScreen({
    super.key,
    required this.patient,
  });

  @override
  State<PatientMedicalHistoryScreen> createState() => _PatientMedicalHistoryScreenState();
}

class _PatientMedicalHistoryScreenState extends State<PatientMedicalHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _consultations = [];
  List<Map<String, dynamic>> _prescriptions = [];
  List<Map<String, dynamic>> _testResults = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadMedicalHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadMedicalHistory() {
    // Mock data for demonstration
    _consultations = [
      {
        'id': 'CON001',
        'date': '2024-01-15',
        'time': '10:30 AM',
        'doctor': 'Dr. Sarah Wilson',
        'specialization': 'General Medicine',
        'symptoms': 'Fever, headache, body ache',
        'diagnosis': 'Viral fever',
        'notes': 'Patient showing signs of viral infection. Advised rest and medication.',
        'followUp': 'Follow up in 3 days if symptoms persist',
      },
      {
        'id': 'CON002',
        'date': '2024-01-10',
        'time': '2:15 PM',
        'doctor': 'Dr. Michael Brown',
        'specialization': 'Cardiology',
        'symptoms': 'Chest pain, shortness of breath',
        'diagnosis': 'Mild hypertension',
        'notes': 'Blood pressure slightly elevated. ECG normal.',
        'followUp': 'Regular monitoring required',
      },
    ];

    _prescriptions = [
      {
        'id': 'PRE001',
        'consultationId': 'CON001',
        'date': '2024-01-15',
        'doctor': 'Dr. Sarah Wilson',
        'medications': [
          {
            'name': 'Paracetamol',
            'dosage': '500mg',
            'frequency': 'Twice daily',
            'duration': '5 days',
            'instructions': 'Take after meals',
          },
          {
            'name': 'Vitamin C',
            'dosage': '500mg',
            'frequency': 'Once daily',
            'duration': '7 days',
            'instructions': 'Take with water',
          },
        ],
      },
      {
        'id': 'PRE002',
        'consultationId': 'CON002',
        'date': '2024-01-10',
        'doctor': 'Dr. Michael Brown',
        'medications': [
          {
            'name': 'Amlodipine',
            'dosage': '5mg',
            'frequency': 'Once daily',
            'duration': '30 days',
            'instructions': 'Take in the morning',
          },
        ],
      },
    ];

    _testResults = [
      {
        'id': 'TEST001',
        'consultationId': 'CON002',
        'date': '2024-01-10',
        'testName': 'Blood Pressure',
        'result': '140/90 mmHg',
        'status': 'Abnormal',
        'normalRange': '120/80 mmHg',
        'notes': 'Slightly elevated blood pressure',
      },
      {
        'id': 'TEST002',
        'consultationId': 'CON002',
        'date': '2024-01-10',
        'testName': 'ECG',
        'result': 'Normal sinus rhythm',
        'status': 'Normal',
        'normalRange': 'Normal sinus rhythm',
        'notes': 'Heart rhythm is normal',
      },
      {
        'id': 'TEST003',
        'consultationId': 'CON001',
        'date': '2024-01-15',
        'testName': 'Complete Blood Count',
        'result': 'WBC: 8500/μL',
        'status': 'Normal',
        'normalRange': '4000-11000/μL',
        'notes': 'All parameters within normal limits',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Medical History'),
            Text(
              widget.patient['name'],
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printMedicalHistory,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareMedicalHistory,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.blue[200],
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Overview'),
            Tab(icon: Icon(Icons.medical_information), text: 'Consultations'),
            Tab(icon: Icon(Icons.medication), text: 'Prescriptions'),
            Tab(icon: Icon(Icons.science), text: 'Test Results'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildConsultationsTab(),
          _buildPrescriptionsTab(),
          _buildTestResultsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
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
                        radius: 30,
                        backgroundColor: Colors.blue[100],
                        child: Text(
                          widget.patient['name'].split(' ').map((n) => n[0]).join(),
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.patient['name'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Patient ID: ${widget.patient['patientId']}'),
                            Text('${widget.patient['age']} years • ${widget.patient['gender']}'),
                            Text('Phone: ${widget.patient['phone']}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (widget.patient['allergies'] != null && 
                      (widget.patient['allergies'] as List).isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Known Allergies',
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  (widget.patient['allergies'] as List).join(', '),
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                              ],
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

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Visits',
                  _consultations.length.toString(),
                  Icons.medical_information,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Active Prescriptions',
                  _prescriptions.length.toString(),
                  Icons.medication,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Test Results',
                  _testResults.length.toString(),
                  Icons.science,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Last Visit',
                  _consultations.isNotEmpty ? _consultations.first['date'] : 'N/A',
                  Icons.schedule,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Recent Activity
          const Text(
            'Recent Activity',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          ..._consultations.take(3).map((consultation) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Icon(Icons.medical_information, color: Colors.blue[700]),
              ),
              title: Text('Consultation - ${consultation['doctor']}'),
              subtitle: Text('${consultation['date']} • ${consultation['diagnosis']}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to consultation details
              },
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultationsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _consultations.length,
      itemBuilder: (context, index) {
        return _buildConsultationCard(_consultations[index]);
      },
    );
  }

  Widget _buildConsultationCard(Map<String, dynamic> consultation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.medical_information, color: Colors.blue[700]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        consultation['doctor'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(consultation['specialization']),
                      Text('${consultation['date']} at ${consultation['time']}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Symptoms', consultation['symptoms']),
            _buildDetailRow('Diagnosis', consultation['diagnosis']),
            _buildDetailRow('Notes', consultation['notes']),
            if (consultation['followUp'].isNotEmpty)
              _buildDetailRow('Follow-up', consultation['followUp']),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _prescriptions.length,
      itemBuilder: (context, index) {
        return _buildPrescriptionCard(_prescriptions[index]);
      },
    );
  }

  Widget _buildPrescriptionCard(Map<String, dynamic> prescription) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.medication, color: Colors.green[700]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prescription['doctor'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Date: ${prescription['date']}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Medications:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...(prescription['medications'] as List).map((med) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    med['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${med['dosage']} - ${med['frequency']} for ${med['duration']}'),
                  if (med['instructions'].isNotEmpty)
                    Text(
                      'Instructions: ${med['instructions']}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResultsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _testResults.length,
      itemBuilder: (context, index) {
        return _buildTestResultCard(_testResults[index]);
      },
    );
  }

  Widget _buildTestResultCard(Map<String, dynamic> testResult) {
    Color statusColor = testResult['status'] == 'Normal' ? Colors.green : Colors.orange;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.science, color: Colors.orange[700]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        testResult['testName'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Date: ${testResult['date']}'),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    testResult['status'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Result', testResult['result']),
            _buildDetailRow('Normal Range', testResult['normalRange']),
            if (testResult['notes'].isNotEmpty)
              _buildDetailRow('Notes', testResult['notes']),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

  void _printMedicalHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Printing medical history...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _shareMedicalHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing medical history...'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
