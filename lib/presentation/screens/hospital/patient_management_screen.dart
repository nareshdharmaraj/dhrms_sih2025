import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';

class PatientManagementScreen extends StatefulWidget {
  const PatientManagementScreen({super.key});

  @override
  State<PatientManagementScreen> createState() =>
      _PatientManagementScreenState();
}

class _PatientManagementScreenState extends State<PatientManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All Patients';

  final List<String> _filterOptions = [
    'All Patients',
    'Admitted',
    'Outpatient',
    'Emergency',
    'Discharged',
    'Critical',
  ];

  // Mock patient data
  final List<Map<String, dynamic>> _patients = [
    {
      'id': 'P12345',
      'name': 'John Doe',
      'age': 45,
      'gender': 'Male',
      'phone': '+91 98765 43210',
      'email': 'john.doe@email.com',
      'address': '123 Main St, Kochi',
      'bloodGroup': 'O+',
      'status': 'Admitted',
      'admissionDate': '2024-01-15',
      'department': 'ICU',
      'bedNumber': 'ICU-001',
      'condition': 'Critical',
      'doctor': 'Dr. Sarah Joseph',
      'emergencyContact': 'Jane Doe (+91 87654 32109)',
      'allergies': ['Penicillin', 'Shellfish'],
      'medicalHistory': ['Diabetes', 'Hypertension'],
      'insurance': 'Apollo Health Insurance',
      'lastVisit': '2024-01-19',
      'nextAppointment': '2024-01-22',
      'vitals': {
        'bp': '140/90',
        'heartRate': '85 bpm',
        'temperature': '98.6°F',
        'oxygen': '95%',
      },
    },
    {
      'id': 'P67890',
      'name': 'Baby Sarah',
      'age': 2,
      'gender': 'Female',
      'phone': '+91 76543 21098',
      'email': 'mother.sarah@email.com',
      'address': '456 Oak Ave, Kochi',
      'bloodGroup': 'A+',
      'status': 'Admitted',
      'admissionDate': '2024-01-18',
      'department': 'Pediatrics',
      'bedNumber': 'PD-021',
      'condition': 'Stable',
      'doctor': 'Dr. Priya Nair',
      'emergencyContact': 'Mother (+91 76543 21098)',
      'allergies': [],
      'medicalHistory': ['Premature birth'],
      'insurance': 'Family Health Plan',
      'lastVisit': '2024-01-19',
      'nextAppointment': '2024-01-21',
      'vitals': {
        'bp': 'Normal',
        'heartRate': '120 bpm',
        'temperature': '99.1°F',
        'oxygen': '98%',
      },
    },
    {
      'id': 'P98765',
      'name': 'Amit Patel',
      'age': 52,
      'gender': 'Male',
      'phone': '+91 98765 43210',
      'email': 'amit.patel@email.com',
      'address': '789 Pine St, Kochi',
      'bloodGroup': 'B+',
      'status': 'Outpatient',
      'admissionDate': null,
      'department': 'Cardiology',
      'bedNumber': null,
      'condition': 'Stable',
      'doctor': 'Dr. Rajesh Kumar',
      'emergencyContact': 'Wife (+91 87654 32109)',
      'allergies': ['Aspirin'],
      'medicalHistory': ['Heart Disease', 'High Cholesterol'],
      'insurance': 'Star Health Insurance',
      'lastVisit': '2024-01-18',
      'nextAppointment': '2024-01-25',
      'vitals': {
        'bp': '130/85',
        'heartRate': '72 bpm',
        'temperature': '98.4°F',
        'oxygen': '97%',
      },
    },
    {
      'id': 'P54321',
      'name': 'Sunita Devi',
      'age': 38,
      'gender': 'Female',
      'phone': '+91 87654 32109',
      'email': 'sunita.devi@email.com',
      'address': '321 Elm St, Kochi',
      'bloodGroup': 'AB+',
      'status': 'Emergency',
      'admissionDate': '2024-01-20',
      'department': 'Emergency',
      'bedNumber': 'EM-008',
      'condition': 'Critical',
      'doctor': 'Dr. Emergency Team',
      'emergencyContact': 'Husband (+91 76543 21098)',
      'allergies': [],
      'medicalHistory': ['Asthma'],
      'insurance': 'Government Health Scheme',
      'lastVisit': '2024-01-20',
      'nextAppointment': 'TBD',
      'vitals': {
        'bp': '160/100',
        'heartRate': '110 bpm',
        'temperature': '102.3°F',
        'oxygen': '89%',
      },
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredPatients {
    return _patients.where((patient) {
      bool matchesFilter =
          _selectedFilter == 'All Patients' ||
          patient['status'] == _selectedFilter;
      bool matchesSearch =
          _searchController.text.isEmpty ||
          patient['name'].toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          patient['id'].toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: Text(
          'Patient Management',
          style: AppTextStyles.headline6.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.hospitalRole,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add, color: AppColors.white),
            onPressed: () => _showAddPatientDialog(),
          ),
          IconButton(
            icon: Icon(Icons.qr_code_scanner, color: AppColors.white),
            onPressed: () => _scanPatientQR(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'All Patients'),
            Tab(text: 'Admitted'),
            Tab(text: 'Critical Care'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            color: AppColors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search patients by name or ID...',
                    prefixIcon: Icon(Icons.search, color: AppColors.grey600),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMedium,
                      ),
                      borderSide: BorderSide(color: AppColors.grey300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMedium,
                      ),
                      borderSide: BorderSide(color: AppColors.hospitalRole),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedFilter,
                        decoration: InputDecoration(
                          labelText: 'Filter by Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMedium,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: _filterOptions.map((filter) {
                          return DropdownMenuItem(
                            value: filter,
                            child: Text(filter),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedFilter = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingMedium),
                    ElevatedButton.icon(
                      onPressed: () => _showAdvancedFilters(),
                      icon: Icon(Icons.filter_list, size: 16),
                      label: Text('Filters'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.hospitalRole,
                        foregroundColor: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Patient Count Summary
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: AppDimensions.paddingSmall,
            ),
            color: AppColors.white,
            child: Row(
              children: [
                Text(
                  'Found ${_filteredPatients.length} patients',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                _buildQuickStatChip(
                  'Critical',
                  _patients.where((p) => p['condition'] == 'Critical').length,
                  AppColors.error,
                ),
                const SizedBox(width: 8),
                _buildQuickStatChip(
                  'Admitted',
                  _patients.where((p) => p['status'] == 'Admitted').length,
                  AppColors.warning,
                ),
              ],
            ),
          ),
          // Patient List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPatientList(_filteredPatients),
                _buildPatientList(
                  _patients.where((p) => p['status'] == 'Admitted').toList(),
                ),
                _buildPatientList(
                  _patients.where((p) => p['condition'] == 'Critical').toList(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPatientDialog(),
        backgroundColor: AppColors.hospitalRole,
        child: Icon(Icons.person_add, color: AppColors.white),
      ),
    );
  }

  Widget _buildQuickStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $count',
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPatientList(List<Map<String, dynamic>> patients) {
    if (patients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppColors.grey400),
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              'No patients found',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.grey600),
            ),
          ],
        ),
      );
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

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    Color statusColor = _getStatusColor(patient['status']);
    Color conditionColor = _getConditionColor(patient['condition']);

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: InkWell(
        onTap: () => _showPatientDetails(patient),
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
                    backgroundColor: AppColors.hospitalRole.withOpacity(0.1),
                    child: Text(
                      patient['name'].toString().substring(0, 1).toUpperCase(),
                      style: AppTextStyles.headline5.copyWith(
                        color: AppColors.hospitalRole,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                patient['name'],
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.grey900,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                patient['status'],
                                style: AppTextStyles.caption.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'ID: ${patient['id']} • ${patient['age']}Y • ${patient['gender']}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                        if (patient['bedNumber'] != null)
                          Text(
                            'Bed: ${patient['bedNumber']} • ${patient['department']}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.grey600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingMedium),

              // Vital Signs Quick View
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusSmall,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildVitalChip('BP', patient['vitals']['bp']),
                    ),
                    Expanded(
                      child: _buildVitalChip(
                        'HR',
                        patient['vitals']['heartRate'],
                      ),
                    ),
                    Expanded(
                      child: _buildVitalChip(
                        'Temp',
                        patient['vitals']['temperature'],
                      ),
                    ),
                    Expanded(
                      child: _buildVitalChip('O2', patient['vitals']['oxygen']),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.paddingMedium),

              Row(
                children: [
                  Icon(
                    Icons.medical_services,
                    size: 16,
                    color: AppColors.grey600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    patient['doctor'],
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: conditionColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      patient['condition'],
                      style: AppTextStyles.caption.copyWith(
                        color: conditionColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.paddingMedium),

              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _updateVitals(patient),
                    icon: Icon(Icons.favorite, size: 16),
                    label: Text('Vitals'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.hospitalRole,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  OutlinedButton.icon(
                    onPressed: () => _showMedicationDialog(patient),
                    icon: Icon(Icons.medication, size: 16),
                    label: Text('Medication'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.hospitalRole,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _callPatient(patient),
                    icon: Icon(Icons.phone, color: AppColors.success),
                    iconSize: 20,
                  ),
                  IconButton(
                    onPressed: () => _morePatientActions(patient),
                    icon: Icon(Icons.more_vert, color: AppColors.grey600),
                    iconSize: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVitalChip(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.grey600,
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.grey900,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Admitted':
        return AppColors.warning;
      case 'Outpatient':
        return AppColors.info;
      case 'Emergency':
        return AppColors.error;
      case 'Discharged':
        return AppColors.success;
      case 'Critical':
        return AppColors.error;
      default:
        return AppColors.grey500;
    }
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'Critical':
        return AppColors.error;
      case 'Stable':
        return AppColors.success;
      case 'Moderate':
        return AppColors.warning;
      default:
        return AppColors.grey500;
    }
  }

  void _showPatientDetails(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          child: DefaultTabController(
            length: 4,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppColors.hospitalRole,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppDimensions.radiusMedium),
                      topRight: Radius.circular(AppDimensions.radiusMedium),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          patient['name'],
                          style: AppTextStyles.headline6.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: AppColors.white),
                      ),
                    ],
                  ),
                ),
                // Tabs
                TabBar(
                  labelColor: AppColors.hospitalRole,
                  unselectedLabelColor: AppColors.grey600,
                  indicatorColor: AppColors.hospitalRole,
                  tabs: const [
                    Tab(text: 'Info'),
                    Tab(text: 'Vitals'),
                    Tab(text: 'History'),
                    Tab(text: 'Treatment'),
                  ],
                ),
                // Tab Content
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildPatientInfoTab(patient),
                      _buildPatientVitalsTab(patient),
                      _buildPatientHistoryTab(patient),
                      _buildPatientTreatmentTab(patient),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPatientInfoTab(Map<String, dynamic> patient) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection('Basic Information', [
            _buildInfoRow('Patient ID', patient['id']),
            _buildInfoRow('Name', patient['name']),
            _buildInfoRow('Age', '${patient['age']} years'),
            _buildInfoRow('Gender', patient['gender']),
            _buildInfoRow('Blood Group', patient['bloodGroup']),
          ]),
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildInfoSection('Contact Information', [
            _buildInfoRow('Phone', patient['phone']),
            _buildInfoRow('Email', patient['email']),
            _buildInfoRow('Address', patient['address']),
            _buildInfoRow('Emergency Contact', patient['emergencyContact']),
          ]),
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildInfoSection('Medical Information', [
            _buildInfoRow('Status', patient['status']),
            _buildInfoRow('Condition', patient['condition']),
            _buildInfoRow('Doctor', patient['doctor']),
            if (patient['bedNumber'] != null)
              _buildInfoRow('Bed Number', patient['bedNumber']),
            _buildInfoRow('Department', patient['department']),
            _buildInfoRow('Insurance', patient['insurance']),
          ]),
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildInfoSection('Allergies', [
            Text(
              patient['allergies'].isEmpty
                  ? 'No known allergies'
                  : patient['allergies'].join(', '),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey700,
              ),
            ),
          ]),
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildInfoSection('Medical History', [
            Text(
              patient['medicalHistory'].isEmpty
                  ? 'No medical history'
                  : patient['medicalHistory'].join(', '),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey700,
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildPatientVitalsTab(Map<String, dynamic> patient) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Vitals',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          _buildVitalCard(
            'Blood Pressure',
            patient['vitals']['bp'],
            Icons.favorite,
            AppColors.error,
          ),
          _buildVitalCard(
            'Heart Rate',
            patient['vitals']['heartRate'],
            Icons.monitor_heart,
            AppColors.warning,
          ),
          _buildVitalCard(
            'Temperature',
            patient['vitals']['temperature'],
            Icons.thermostat,
            AppColors.info,
          ),
          _buildVitalCard(
            'Oxygen Saturation',
            patient['vitals']['oxygen'],
            Icons.air,
            AppColors.success,
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          ElevatedButton.icon(
            onPressed: () => _updateVitals(patient),
            icon: Icon(Icons.add),
            label: Text('Update Vitals'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.hospitalRole,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  Text(
                    value,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey900,
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

  Widget _buildPatientHistoryTab(Map<String, dynamic> patient) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Visits',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text('Feature coming soon...', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildPatientTreatmentTab(Map<String, dynamic> patient) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Treatment Plan',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text('Feature coming soon...', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.hospitalRole,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        ...children,
      ],
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
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.grey600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey900),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPatientDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Patient'),
        content: Text(
          'Add new patient functionality will be available in a future update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _scanPatientQR() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('QR Scanner opened')));
  }

  void _showAdvancedFilters() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Advanced Filters'),
        content: Text(
          'Advanced filtering options will be available in a future update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _updateVitals(Map<String, dynamic> patient) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vitals update for ${patient['name']}')),
    );
  }

  void _showMedicationDialog(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Medication Management'),
        content: Text(
          'Medication management for ${patient['name']} will be available in a future update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _callPatient(Map<String, dynamic> patient) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${patient['name']} at ${patient['phone']}'),
      ),
    );
  }

  void _morePatientActions(Map<String, dynamic> patient) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Patient'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Edit patient functionality coming soon'),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment),
              title: Text('View Records'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Patient records functionality coming soon'),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Share'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Share patient information')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
