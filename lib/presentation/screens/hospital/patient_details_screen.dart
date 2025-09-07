import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/services/api_service.dart';

class PatientDetailsScreen extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic>? patientData;

  const PatientDetailsScreen({
    super.key,
    required this.patientId,
    this.patientData,
  });

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? patient;
  List<Map<String, dynamic>> healthRecords = [];
  List<Map<String, dynamic>> appointments = [];
  List<Map<String, dynamic>> prescriptions = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadPatientData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Load patient details
      if (widget.patientData != null) {
        patient = widget.patientData;
      } else {
        patient = await ApiService.getPatientById(widget.patientId);
      }

      // Load related data
      await Future.wait([
        _loadHealthRecords(),
        _loadAppointments(),
        _loadPrescriptions(),
      ]);
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load patient data: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadHealthRecords() async {
    try {
      final records = await ApiService.getPatientHealthRecords(widget.patientId);
      setState(() {
        healthRecords = records;
      });
    } catch (e) {
      print('Error loading health records: $e');
    }
  }

  Future<void> _loadAppointments() async {
    try {
      final appts = await ApiService.getPatientAppointments(widget.patientId);
      setState(() {
        appointments = appts;
      });
    } catch (e) {
      print('Error loading appointments: $e');
    }
  }

  Future<void> _loadPrescriptions() async {
    try {
      final presc = await ApiService.getPatientPrescriptions(widget.patientId);
      setState(() {
        prescriptions = presc;
      });
    } catch (e) {
      print('Error loading prescriptions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(patient?['name'] ?? 'Patient Details'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editPatient(),
          ),
          IconButton(
            icon: const Icon(Icons.medical_services),
            onPressed: () => _addHealthRecord(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          indicatorColor: AppColors.white,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.person)),
            Tab(text: 'Records', icon: Icon(Icons.folder_shared)),
            Tab(text: 'Appointments', icon: Icon(Icons.calendar_today)),
            Tab(text: 'Prescriptions', icon: Icon(Icons.medical_services)),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? _buildErrorState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildHealthRecordsTab(),
                    _buildAppointmentsTab(),
                    _buildPrescriptionsTab(),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addHealthRecord(),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: AppDimensions.marginMedium),
          Text(
            errorMessage!,
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.marginLarge),
          ElevatedButton(
            onPressed: _loadPatientData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (patient == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient Header Card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                    child: Text(
                      patient!['name']?.substring(0, 2)?.toUpperCase() ?? 'PA',
                      style: AppTextStyles.headline3.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.marginMedium),
                  Text(
                    patient!['name'] ?? 'Unknown Patient',
                    style: AppTextStyles.headline4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.marginSmall),
                  Text(
                    'ID: ${patient!['uniqueHealthId'] ?? 'N/A'}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.marginLarge),

          // Basic Information
          _buildInfoSection('Basic Information', [
            _buildInfoRow('Age', '${patient!['age'] ?? 'N/A'} years'),
            _buildInfoRow('Gender', patient!['gender'] ?? 'N/A'),
            _buildInfoRow('Blood Group', patient!['bloodGroup'] ?? 'N/A'),
            _buildInfoRow('Phone', patient!['phone'] ?? 'N/A'),
          ]),

          // Health Information
          _buildInfoSection('Health Information', [
            _buildInfoRow('Health ID', patient!['uniqueHealthId'] ?? 'N/A'),
            _buildInfoRow('Registration Date', _formatDate(patient!['registrationDate'])),
            _buildInfoRow('Last Visit', _formatDate(patient!['lastVisit'])),
            _buildInfoRow('Status', patient!['status'] ?? 'N/A'),
          ]),

          // Address Information
          _buildInfoSection('Contact Information', [
            _buildInfoRow('Address', patient!['address'] ?? 'N/A'),
            _buildInfoRow('Emergency Contact', patient!['emergencyContact'] ?? 'N/A'),
            _buildInfoRow('Email', patient!['email'] ?? 'N/A'),
          ]),

          // Quick Stats
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginLarge),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.headline6.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: AppDimensions.marginMedium),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.marginSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.grey700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Statistics',
              style: AppTextStyles.headline6.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: AppDimensions.marginMedium),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Health Records',
                    '${healthRecords.length}',
                    Icons.folder_shared,
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: AppDimensions.marginMedium),
                Expanded(
                  child: _buildStatCard(
                    'Appointments',
                    '${appointments.length}',
                    Icons.calendar_today,
                    AppColors.warning,
                  ),
                ),
                const SizedBox(width: AppDimensions.marginMedium),
                Expanded(
                  child: _buildStatCard(
                    'Prescriptions',
                    '${prescriptions.length}',
                    Icons.medical_services,
                    AppColors.info,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: AppDimensions.marginSmall),
          Text(
            value,
            style: AppTextStyles.headline5.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.grey600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRecordsTab() {
    return RefreshIndicator(
      onRefresh: _loadHealthRecords,
      child: healthRecords.isEmpty
          ? _buildEmptyState('No health records found', Icons.folder_open)
          : ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              itemCount: healthRecords.length,
              itemBuilder: (context, index) {
                final record = healthRecords[index];
                return _buildHealthRecordCard(record);
              },
            ),
    );
  }

  Widget _buildHealthRecordCard(Map<String, dynamic> record) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.medical_services,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.marginSmall),
                Expanded(
                  child: Text(
                    record['type'] ?? 'Health Record',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _formatDate(record['date']),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginSmall),
            if (record['diagnosis'] != null)
              Text(
                'Diagnosis: ${record['diagnosis']}',
                style: AppTextStyles.bodyMedium,
              ),
            if (record['treatment'] != null)
              Text(
                'Treatment: ${record['treatment']}',
                style: AppTextStyles.bodyMedium,
              ),
            if (record['doctor'] != null)
              Text(
                'Doctor: ${record['doctor']}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            const SizedBox(height: AppDimensions.marginSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _viewHealthRecord(record),
                  child: const Text('View Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: appointments.isEmpty
          ? _buildEmptyState('No appointments found', Icons.calendar_today)
          : ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                return _buildAppointmentCard(appointment);
              },
            ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final status = appointment['status'] ?? 'scheduled';
    Color statusColor = AppColors.warning;
    if (status == 'completed') statusColor = AppColors.success;
    if (status == 'cancelled') statusColor = AppColors.error;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.marginSmall),
                Expanded(
                  child: Text(
                    _formatDate(appointment['date']),
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginSmall),
            if (appointment['doctor'] != null)
              Text(
                'Doctor: ${appointment['doctor']}',
                style: AppTextStyles.bodyMedium,
              ),
            if (appointment['department'] != null)
              Text(
                'Department: ${appointment['department']}',
                style: AppTextStyles.bodyMedium,
              ),
            if (appointment['reason'] != null)
              Text(
                'Reason: ${appointment['reason']}',
                style: AppTextStyles.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionsTab() {
    return RefreshIndicator(
      onRefresh: _loadPrescriptions,
      child: prescriptions.isEmpty
          ? _buildEmptyState('No prescriptions found', Icons.medical_services)
          : ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              itemCount: prescriptions.length,
              itemBuilder: (context, index) {
                final prescription = prescriptions[index];
                return _buildPrescriptionCard(prescription);
              },
            ),
    );
  }

  Widget _buildPrescriptionCard(Map<String, dynamic> prescription) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.medical_services,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.marginSmall),
                Expanded(
                  child: Text(
                    'Prescription #${prescription['id'] ?? 'N/A'}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _formatDate(prescription['date']),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginSmall),
            if (prescription['medications'] != null)
              ...((prescription['medications'] as List).map((med) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '• ${med['name']} - ${med['dosage']} (${med['frequency']})',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ))),
            if (prescription['doctor'] != null)
              Text(
                'Prescribed by: Dr. ${prescription['doctor']}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.grey400),
          const SizedBox(height: AppDimensions.marginMedium),
          Text(
            message,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _editPatient() {
    // Navigate to edit patient screen
    Navigator.pushNamed(
      context,
      '/edit-patient',
      arguments: {'patientId': widget.patientId, 'patientData': patient},
    );
  }

  void _addHealthRecord() {
    // Navigate to add health record screen
    Navigator.pushNamed(
      context,
      '/add-health-record',
      arguments: {'patientId': widget.patientId},
    );
  }

  void _viewHealthRecord(Map<String, dynamic> record) {
    // Navigate to health record details screen
    Navigator.pushNamed(
      context,
      '/health-record-details',
      arguments: {'record': record, 'patientId': widget.patientId},
    );
  }
}
