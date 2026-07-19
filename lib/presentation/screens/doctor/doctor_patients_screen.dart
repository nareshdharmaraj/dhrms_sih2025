import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';

class DoctorPatientsScreen extends StatefulWidget {
  final Map<String, dynamic> doctorData;

  const DoctorPatientsScreen({super.key, required this.doctorData});

  @override
  State<DoctorPatientsScreen> createState() => _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends State<DoctorPatientsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allPatients = [];
  List<Map<String, dynamic>> _filteredPatients = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPatients();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadPatients() {
    setState(() {
      _isLoading = true;
    });

    // Mock patient data
    _allPatients = [
      {
        'patientId': 'RAJESH2345',
        'name': 'Rajesh Kumar',
        'age': 35,
        'gender': 'Male',
        'phone': '+91 9876543210',
        'email': 'rajesh.kumar@email.com',
        'address': 'Kochi, Kerala',
        'bloodGroup': 'B+',
        'emergencyContact': 'Priya Kumar - +91 9876543211',
        'lastVisit': DateTime.now().subtract(const Duration(days: 3)),
        'nextAppointment': DateTime.now().add(const Duration(days: 7)),
        'status': 'Active',
        'medicalHistory': ['Hypertension', 'Diabetes Type 2'],
        'currentMedications': [
          'Metformin 500mg - Twice daily',
          'Amlodipine 5mg - Once daily',
        ],
        'vitals': {
          'bloodPressure': '120/80',
          'heartRate': 72,
          'temperature': 98.6,
          'weight': 75.5,
          'height': 170,
        },
        'allergies': ['Penicillin'],
        'insurance': 'Ayushman Bharat',
      },
      {
        'patientId': 'PRIYA6789',
        'name': 'Priya Nair',
        'age': 28,
        'gender': 'Female',
        'phone': '+91 8765432109',
        'email': 'priya.nair@email.com',
        'address': 'Ernakulam, Kerala',
        'bloodGroup': 'A+',
        'emergencyContact': 'Ravi Nair - +91 8765432108',
        'lastVisit': DateTime.now().subtract(const Duration(days: 1)),
        'nextAppointment': DateTime.now().add(const Duration(days: 14)),
        'status': 'Active',
        'medicalHistory': ['Asthma', 'Iron Deficiency Anemia'],
        'currentMedications': [
          'Salbutamol Inhaler - As needed',
          'Iron Tablets - Once daily',
        ],
        'vitals': {
          'bloodPressure': '110/70',
          'heartRate': 68,
          'temperature': 98.4,
          'weight': 58.0,
          'height': 162,
        },
        'allergies': ['Dust', 'Pollen'],
        'insurance': 'Private Insurance',
      },
      {
        'patientId': 'ARUN1234',
        'name': 'Arun Menon',
        'age': 42,
        'gender': 'Male',
        'phone': '+91 7654321098',
        'email': 'arun.menon@email.com',
        'address': 'Thrissur, Kerala',
        'bloodGroup': 'O+',
        'emergencyContact': 'Sita Menon - +91 7654321097',
        'lastVisit': DateTime.now().subtract(const Duration(hours: 4)),
        'nextAppointment': null,
        'status': 'New',
        'medicalHistory': [],
        'currentMedications': [],
        'vitals': {
          'bloodPressure': '130/85',
          'heartRate': 75,
          'temperature': 99.1,
          'weight': 82.0,
          'height': 175,
        },
        'allergies': [],
        'insurance': 'Ayushman Bharat',
      },
    ];

    _filteredPatients = _allPatients;

    setState(() {
      _isLoading = false;
    });
  }

  void _filterPatients(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPatients = _allPatients;
      } else {
        _filteredPatients = _allPatients.where((patient) {
          return patient['name'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              patient['patientId'].toString().toLowerCase().contains(
                query.toLowerCase(),
              );
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('My Patients'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddPatientDialog(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
          indicatorColor: AppColors.white,
          tabs: const [
            Tab(text: 'All Patients'),
            Tab(text: 'Today'),
            Tab(text: 'Search'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            color: AppColors.white,
            child: TextField(
              controller: _searchController,
              onChanged: _filterPatients,
              decoration: InputDecoration(
                hintText: 'Search patients by name or ID...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                  vertical: AppDimensions.paddingSmall,
                ),
              ),
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPatientsList(_filteredPatients),
                _buildTodayPatients(),
                _buildPatientsList(_filteredPatients),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientsList(List<Map<String, dynamic>> patients) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (patients.isEmpty) {
      return const Center(child: Text('No patients found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemCount: patients.length,
      itemBuilder: (context, index) {
        final patient = patients[index];
        return _buildPatientCard(patient);
      },
    );
  }

  Widget _buildTodayPatients() {
    final todayPatients = _allPatients.where((patient) {
      final lastVisit = patient['lastVisit'] as DateTime?;
      final nextAppointment = patient['nextAppointment'] as DateTime?;
      final today = DateTime.now();

      if (lastVisit != null) {
        final isToday =
            lastVisit.year == today.year &&
            lastVisit.month == today.month &&
            lastVisit.day == today.day;
        if (isToday) return true;
      }

      if (nextAppointment != null) {
        final isToday =
            nextAppointment.year == today.year &&
            nextAppointment.month == today.month &&
            nextAppointment.day == today.day;
        if (isToday) return true;
      }

      return false;
    }).toList();

    return _buildPatientsList(todayPatients);
  }

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: InkWell(
        onTap: () => _viewPatientDetails(patient),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: _getStatusColor(
                      patient['status'],
                    ).withValues(alpha: 0.1),
                    child: Text(
                      patient['name'].toString().substring(0, 2).toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(patient['status']),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.marginMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient['name'].toString(),
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ID: ${patient['patientId']} • ${patient['age']} years • ${patient['gender']}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        patient['status'],
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      patient['status'].toString(),
                      style: TextStyle(
                        color: _getStatusColor(patient['status']),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.marginMedium),

              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.phone,
                      patient['phone'].toString(),
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.bloodtype,
                      patient['bloodGroup'].toString(),
                    ),
                  ),
                ],
              ),

              if (patient['nextAppointment'] != null) ...[
                const SizedBox(height: AppDimensions.marginSmall),
                _buildInfoItem(
                  Icons.schedule,
                  'Next: ${_formatDate(patient['nextAppointment'])}',
                ),
              ],

              const SizedBox(height: AppDimensions.marginMedium),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _viewMedicalHistory(patient),
                      icon: const Icon(Icons.history),
                      label: const Text('History'),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.marginMedium),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _addPrescription(patient),
                      icon: const Icon(Icons.add),
                      label: const Text('Prescribe'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.white,
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

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grey600),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'new':
        return AppColors.info;
      case 'critical':
        return AppColors.error;
      default:
        return AppColors.grey500;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _viewPatientDetails(Map<String, dynamic> patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailScreen(
          patient: patient,
          doctorData: widget.doctorData,
        ),
      ),
    );
  }

  void _viewMedicalHistory(Map<String, dynamic> patient) {
    _viewPatientDetails(patient);
  }

  void _addPrescription(Map<String, dynamic> patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPrescriptionScreen(
          patient: patient,
          doctorData: widget.doctorData,
        ),
      ),
    );
  }

  void _showAddPatientDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            NewPatientRegistrationScreen(doctorData: widget.doctorData),
      ),
    );
  }
}

// Patient Detail Screen
class PatientDetailScreen extends StatefulWidget {
  final Map<String, dynamic> patient;
  final Map<String, dynamic> doctorData;

  const PatientDetailScreen({
    super.key,
    required this.patient,
    required this.doctorData,
  });

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: Text(widget.patient['name'].toString()),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        actions: [IconButton(icon: const Icon(Icons.edit), onPressed: () {})],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
          indicatorColor: AppColors.white,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'History'),
            Tab(text: 'Prescriptions'),
            Tab(text: 'Vitals'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildHistoryTab(),
          _buildPrescriptionsTab(),
          _buildVitalsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addPrescription(),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primaryBlue.withValues(
                          alpha: 0.1,
                        ),
                        child: Text(
                          widget.patient['name']
                              .toString()
                              .substring(0, 2)
                              .toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.marginMedium),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.patient['name'].toString(),
                              style: AppTextStyles.headline6.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Patient ID: ${widget.patient['patientId']}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.grey600,
                              ),
                            ),
                            Text(
                              '${widget.patient['age']} years • ${widget.patient['gender']}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.marginLarge),

                  // Contact Information
                  _buildDetailRow('Phone', widget.patient['phone'].toString()),
                  _buildDetailRow('Email', widget.patient['email'].toString()),
                  _buildDetailRow(
                    'Address',
                    widget.patient['address'].toString(),
                  ),
                  _buildDetailRow(
                    'Blood Group',
                    widget.patient['bloodGroup'].toString(),
                  ),
                  _buildDetailRow(
                    'Emergency Contact',
                    widget.patient['emergencyContact'].toString(),
                  ),
                  _buildDetailRow(
                    'Insurance',
                    widget.patient['insurance'].toString(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.marginMedium),

          // Medical Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Medical Summary',
                    style: AppTextStyles.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.marginMedium),

                  if ((widget.patient['medicalHistory'] as List)
                      .isNotEmpty) ...[
                    Text(
                      'Medical History:',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    ...(widget.patient['medicalHistory'] as List).map(
                      (history) => Padding(
                        padding: const EdgeInsets.only(left: 16, top: 4),
                        child: Text('• $history'),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),
                  ],

                  if ((widget.patient['allergies'] as List).isNotEmpty) ...[
                    Text(
                      'Allergies:',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                    ...(widget.patient['allergies'] as List).map(
                      (allergy) => Padding(
                        padding: const EdgeInsets.only(left: 16, top: 4),
                        child: Text(
                          '• $allergy',
                          style: const TextStyle(color: AppColors.error),
                        ),
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

  Widget _buildHistoryTab() {
    return const Center(child: Text('Medical History will be shown here'));
  }

  Widget _buildPrescriptionsTab() {
    return const Center(child: Text('Prescriptions will be shown here'));
  }

  Widget _buildVitalsTab() {
    final vitals = widget.patient['vitals'] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Vitals',
                    style: AppTextStyles.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.marginMedium),

                  _buildVitalItem(
                    'Blood Pressure',
                    '${vitals['bloodPressure']} mmHg',
                    Icons.monitor_heart,
                  ),
                  _buildVitalItem(
                    'Heart Rate',
                    '${vitals['heartRate']} bpm',
                    Icons.favorite,
                  ),
                  _buildVitalItem(
                    'Temperature',
                    '${vitals['temperature']}°F',
                    Icons.thermostat,
                  ),
                  _buildVitalItem(
                    'Weight',
                    '${vitals['weight']} kg',
                    Icons.monitor_weight,
                  ),
                  _buildVitalItem(
                    'Height',
                    '${vitals['height']} cm',
                    Icons.height,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.marginSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildVitalItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 24),
          const SizedBox(width: AppDimensions.marginMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addPrescription() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPrescriptionScreen(
          patient: widget.patient,
          doctorData: widget.doctorData,
        ),
      ),
    );
  }
}

// Placeholder screens that will be implemented
class AddPrescriptionScreen extends StatelessWidget {
  final Map<String, dynamic> patient;
  final Map<String, dynamic> doctorData;

  const AddPrescriptionScreen({
    super.key,
    required this.patient,
    required this.doctorData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Prescription'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
      ),
      body: const Center(
        child: Text('Add Prescription Screen - To be implemented'),
      ),
    );
  }
}

class NewPatientRegistrationScreen extends StatelessWidget {
  final Map<String, dynamic> doctorData;

  const NewPatientRegistrationScreen({super.key, required this.doctorData});

  @override
  Widget build(BuildContext context) {
    // Navigate immediately to the comprehensive registration screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const _ComprehensivePatientRegistrationScreen(),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register New Patient'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ComprehensivePatientRegistrationScreen extends StatefulWidget {
  const _ComprehensivePatientRegistrationScreen();

  @override
  State<_ComprehensivePatientRegistrationScreen> createState() =>
      _ComprehensivePatientRegistrationScreenState();
}

class _ComprehensivePatientRegistrationScreenState
    extends State<_ComprehensivePatientRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyNameController = TextEditingController();

  String _selectedGender = 'Male';
  bool _isLoading = false;

  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _emergencyNameController.dispose();
    super.dispose();
  }

  String _generatePatientId(String firstName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final last4Digits = timestamp.substring(timestamp.length - 4);
    return '${firstName.toUpperCase()}$last4Digits';
  }

  Future<void> _registerPatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    final patientId = _generatePatientId(_firstNameController.text);

    setState(() {
      _isLoading = false;
    });

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Registration Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Patient has been registered successfully!'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Patient ID:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(
                    patientId,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please save this Patient ID for future reference.',
              style: TextStyle(fontSize: 12, color: AppColors.grey600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to patients screen
              Navigator.of(context).pop(); // Go back to doctor dashboard
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Register New Patient'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Card
                Card(
                  color: AppColors.info.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Creating new patient record for doctor prescriptions and medical records.',
                            style: TextStyle(
                              color: AppColors.info,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.marginLarge),

                // Personal Information
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.marginLarge),

                        // First Name
                        TextFormField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText: 'First Name *',
                            hintText: 'Enter first name',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter first name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: AppDimensions.marginMedium),

                        // Last Name
                        TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: 'Last Name *',
                            hintText: 'Enter last name',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter last name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: AppDimensions.marginMedium),

                        // Age and Gender Row
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _ageController,
                                decoration: InputDecoration(
                                  labelText: 'Age *',
                                  hintText: 'Enter age',
                                  prefixIcon: const Icon(Icons.cake),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter age';
                                  }
                                  final age = int.tryParse(value);
                                  if (age == null || age < 1 || age > 120) {
                                    return 'Enter valid age';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: AppDimensions.marginMedium),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedGender,
                                decoration: InputDecoration(
                                  labelText: 'Gender *',
                                  prefixIcon: const Icon(Icons.wc),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                items: _genders.map((gender) {
                                  return DropdownMenuItem(
                                    value: gender,
                                    child: Text(gender),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedGender = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppDimensions.marginMedium),

                        // Phone Number
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number *',
                            hintText: 'Enter phone number',
                            prefixIcon: const Icon(Icons.phone),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter phone number';
                            }
                            if (value.length < 10) {
                              return 'Enter valid phone number';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.marginExtraLarge),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registerPatient,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Register Patient',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: AppDimensions.marginLarge),

                // Note
                Card(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'A unique Patient ID will be generated in the format: FIRSTNAME + 4 random digits. Please save this ID for future reference.',
                            style: TextStyle(
                              color: AppColors.grey700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
