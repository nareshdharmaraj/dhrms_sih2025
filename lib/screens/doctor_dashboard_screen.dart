import 'package:flutter/material.dart';
import 'consultation_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const DoctorDashboardScreen({super.key, required this.doctor});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _todayPatients = [];
  List<Map<String, dynamic>> _allPatients = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadPatients();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadPatients() {
    // Mock patient data
    _allPatients = [
      {
        'patientId': 'PAT001',
        'name': 'John Doe',
        'age': 35,
        'gender': 'Male',
        'phone': '+91 98765 43210',
        'lastVisit': '2024-01-20',
        'nextAppointment': '2024-01-25 10:00 AM',
        'condition': 'Hypertension',
        'bloodPressure': '140/90',
        'pulse': '78',
        'temperature': '98.6°F',
        'weight': '75 kg',
        'height': '175 cm',
        'allergies': ['Penicillin'],
        'currentMedications': ['Amlodipine 5mg', 'Metformin 500mg'],
        'medicalHistory': ['Diabetes Type 2', 'Hypertension'],
        'recentTests': ['Blood Sugar', 'ECG'],
        'treatmentCount': 12,
        'isScheduledToday': true,
      },
      {
        'patientId': 'PAT002',
        'name': 'Mary Smith',
        'age': 28,
        'gender': 'Female',
        'phone': '+91 87654 32109',
        'lastVisit': '2024-01-18',
        'nextAppointment': '2024-01-25 2:00 PM',
        'condition': 'Migraine',
        'bloodPressure': '120/80',
        'pulse': '72',
        'temperature': '98.4°F',
        'weight': '62 kg',
        'height': '165 cm',
        'allergies': ['None'],
        'currentMedications': ['Sumatriptan 50mg'],
        'medicalHistory': ['Chronic Migraine'],
        'recentTests': ['MRI Brain'],
        'treatmentCount': 8,
        'isScheduledToday': true,
      },
      {
        'patientId': 'PAT003',
        'name': 'Raj Kumar',
        'age': 45,
        'gender': 'Male',
        'phone': '+91 76543 21098',
        'lastVisit': '2024-01-15',
        'nextAppointment': '2024-01-26 11:00 AM',
        'condition': 'Arthritis',
        'bloodPressure': '130/85',
        'pulse': '80',
        'temperature': '98.2°F',
        'weight': '80 kg',
        'height': '170 cm',
        'allergies': ['Aspirin'],
        'currentMedications': ['Ibuprofen 400mg', 'Calcium tablets'],
        'medicalHistory': ['Osteoarthritis', 'Vitamin D deficiency'],
        'recentTests': ['X-ray Knee', 'Vitamin D levels'],
        'treatmentCount': 15,
        'isScheduledToday': false,
      },
    ];

    _todayPatients = _allPatients.where((p) => p['isScheduledToday']).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dr. ${widget.doctor['name'].split(' ').last}'),
            Text(
              widget.doctor['specialization'],
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.blue[200],
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.today), text: 'Today\'s Patients'),
            Tab(icon: Icon(Icons.people), text: 'All Patients'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          _buildTodayPatientsTab(),
          _buildAllPatientsTab(),
          _buildAnalyticsTab(),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[700]!, Colors.blue[500]!],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, Dr. ${widget.doctor['name'].split(' ').last}!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You have ${_todayPatients.length} patients scheduled for today',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Patients',
                  widget.doctor['patientsCount'].toString(),
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Today\'s Schedule',
                  _todayPatients.length.toString(),
                  Icons.today,
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
                  'Consultation Fee',
                  '₹${widget.doctor['consultationFee']}',
                  Icons.currency_rupee,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Experience',
                  widget.doctor['experience'],
                  Icons.work,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildQuickActionCard(
                'Add Prescription',
                Icons.receipt_long,
                Colors.blue,
                () => _addPrescription(),
              ),
              _buildQuickActionCard(
                'Patient Search',
                Icons.search,
                Colors.green,
                () => _searchPatient(),
              ),
              _buildQuickActionCard(
                'Medical Records',
                Icons.folder_shared,
                Colors.orange,
                () => _viewMedicalRecords(),
              ),
              _buildQuickActionCard(
                'Schedule',
                Icons.schedule,
                Colors.purple,
                () => _viewSchedule(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Today's Appointments Preview
          const Text(
            'Today\'s Appointments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ..._todayPatients.take(3).map((patient) => _buildPatientPreviewCard(patient)).toList(),
          if (_todayPatients.length > 3)
            TextButton(
              onPressed: () => _tabController.animateTo(1),
              child: const Text('View all appointments'),
            ),
        ],
      ),
    );
  }

  Widget _buildTodayPatientsTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Icon(Icons.today, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'Today\'s Appointments (${_todayPatients.length})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _todayPatients.length,
            itemBuilder: (context, index) {
              return _buildPatientCard(_todayPatients[index], showAppointmentTime: true);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAllPatientsTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search patients...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) {
              // Implement search functionality
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _allPatients.length,
            itemBuilder: (context, index) {
              return _buildPatientCard(_allPatients[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Practice Analytics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          
          // Analytics Cards
          _buildAnalyticsCard(
            'Patients Treated This Month',
            '45',
            Icons.people,
            Colors.blue,
            '+12% from last month',
          ),
          const SizedBox(height: 12),
          _buildAnalyticsCard(
            'Average Consultation Time',
            '25 mins',
            Icons.access_time,
            Colors.green,
            'Optimal range',
          ),
          const SizedBox(height: 12),
          _buildAnalyticsCard(
            'Most Common Condition',
            'Hypertension',
            Icons.favorite,
            Colors.red,
            '35% of patients',
          ),
          const SizedBox(height: 12),
          _buildAnalyticsCard(
            'Patient Satisfaction',
            '4.8/5',
            Icons.star,
            Colors.orange,
            'Based on feedback',
          ),
          const SizedBox(height: 20),

          // Recent Treatments Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Treatment Distribution',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTreatmentDistribution(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, MaterialColor color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color[50]!, color[100]!],
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color[700], size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, MaterialColor color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color[700], size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientPreviewCard(Map<String, dynamic> patient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(
            patient['name'].split(' ').map((n) => n[0]).join(),
            style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(patient['name']),
        subtitle: Text('${patient['age']} years • ${patient['condition']}'),
        trailing: Text(
          patient['nextAppointment'].split(' ')[1],
          style: TextStyle(
            color: Colors.blue[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () => _viewPatientDetails(patient),
      ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient, {bool showAppointmentTime = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _viewPatientDetails(patient),
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
                      patient['name'].split(' ').map((n) => n[0]).join(),
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${patient['age']} years • ${patient['gender']}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Text(
                          'ID: ${patient['patientId']}',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (showAppointmentTime)
                    Column(
                      children: [
                        Icon(Icons.access_time, color: Colors.blue[700], size: 16),
                        Text(
                          patient['nextAppointment'].split(' ')[1],
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildPatientInfoChip('Condition', patient['condition'], Colors.red),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPatientInfoChip('Treatments', '${patient['treatmentCount']}', Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _viewMedicalHistory(patient),
                      icon: const Icon(Icons.history, size: 16),
                      label: const Text('History'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _startConsultation(patient),
                      icon: const Icon(Icons.medical_services, size: 16),
                      label: const Text('Consult'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientInfoChip(String label, String value, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: color[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, MaterialColor color, String subtitle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color[700], size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentDistribution() {
    final treatments = [
      {'name': 'Hypertension', 'count': 15, 'color': Colors.red},
      {'name': 'Diabetes', 'count': 12, 'color': Colors.blue},
      {'name': 'Arthritis', 'count': 8, 'color': Colors.green},
      {'name': 'Migraine', 'count': 6, 'color': Colors.orange},
      {'name': 'Others', 'count': 4, 'color': Colors.purple},
    ];

    return Column(
      children: treatments.map((treatment) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: treatment['color'] as Color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(treatment['name'] as String),
              ),
              Text(
                '${treatment['count']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Action methods
  void _addPrescription() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrescriptionScreen(doctor: widget.doctor),
      ),
    );
  }

  void _searchPatient() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Patient Search'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter patient ID or name',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            Navigator.pop(context);
            // Implement search logic
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _viewMedicalRecords() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicalRecordsScreen(doctor: widget.doctor),
      ),
    );
  }

  void _viewSchedule() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Weekly Schedule'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: (widget.doctor['schedule'] as Map<String, String>).entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(entry.value),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _viewPatientDetails(Map<String, dynamic> patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailsScreen(
          patient: patient,
          doctor: widget.doctor,
        ),
      ),
    );
  }

  void _viewMedicalHistory(Map<String, dynamic> patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientMedicalHistoryScreen(
          patient: patient,
          doctor: widget.doctor,
        ),
      ),
    );
  }

  void _startConsultation(Map<String, dynamic> patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConsultationScreen(
          patient: patient,
          doctor: widget.doctor,
        ),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Return to hospital dashboard
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// Placeholder screens - to be implemented
class PrescriptionScreen extends StatelessWidget {
  final Map<String, dynamic> doctor;

  const PrescriptionScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Prescription'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Prescription Screen - To be implemented'),
      ),
    );
  }
}

class MedicalRecordsScreen extends StatelessWidget {
  final Map<String, dynamic> doctor;

  const MedicalRecordsScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Records'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Medical Records Screen - To be implemented'),
      ),
    );
  }
}

class PatientDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> patient;
  final Map<String, dynamic> doctor;

  const PatientDetailsScreen({
    super.key,
    required this.patient,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(patient['name']),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Patient Details Screen - To be implemented'),
      ),
    );
  }
}

class PatientMedicalHistoryScreen extends StatelessWidget {
  final Map<String, dynamic> patient;
  final Map<String, dynamic> doctor;

  const PatientMedicalHistoryScreen({
    super.key,
    required this.patient,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${patient['name']} - Medical History'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Patient Medical History - To be implemented'),
      ),
    );
  }
}


