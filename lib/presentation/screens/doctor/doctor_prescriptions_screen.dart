import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';

class DoctorPrescriptionsScreen extends StatefulWidget {
  final Map<String, dynamic> doctorData;

  const DoctorPrescriptionsScreen({super.key, required this.doctorData});

  @override
  State<DoctorPrescriptionsScreen> createState() =>
      _DoctorPrescriptionsScreenState();
}

class _DoctorPrescriptionsScreenState extends State<DoctorPrescriptionsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allPrescriptions = [];
  List<Map<String, dynamic>> _filteredPrescriptions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPrescriptions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadPrescriptions() {
    setState(() {
      _isLoading = true;
    });

    // Mock prescription data
    _allPrescriptions = [
      {
        'prescriptionId': 'PRX001',
        'patientId': 'RAJESH2345',
        'patientName': 'Rajesh Kumar',
        'dateIssued': DateTime.now().subtract(const Duration(hours: 2)),
        'diagnosis': 'Hypertension',
        'symptoms': 'High blood pressure, headache, dizziness',
        'medications': [
          {
            'name': 'Amlodipine',
            'dosage': '5mg',
            'frequency': 'Once daily',
            'duration': '30 days',
            'instructions': 'Take with food',
          },
          {
            'name': 'Metoprolol',
            'dosage': '50mg',
            'frequency': 'Twice daily',
            'duration': '30 days',
            'instructions': 'Take before meals',
          },
        ],
        'status': 'Active',
        'followUpDate': DateTime.now().add(const Duration(days: 30)),
        'notes': 'Monitor blood pressure daily. Return if symptoms worsen.',
        'labTests': ['Complete Blood Count', 'Lipid Profile'],
      },
      {
        'prescriptionId': 'PRX002',
        'patientId': 'PRIYA6789',
        'patientName': 'Priya Nair',
        'dateIssued': DateTime.now().subtract(const Duration(days: 1)),
        'diagnosis': 'Asthma Exacerbation',
        'symptoms': 'Shortness of breath, wheezing, chest tightness',
        'medications': [
          {
            'name': 'Salbutamol Inhaler',
            'dosage': '100mcg',
            'frequency': 'As needed',
            'duration': '30 days',
            'instructions': 'Use during breathing difficulty',
          },
          {
            'name': 'Prednisolone',
            'dosage': '10mg',
            'frequency': 'Once daily',
            'duration': '7 days',
            'instructions': 'Take with food, gradually reduce dose',
          },
        ],
        'status': 'Active',
        'followUpDate': DateTime.now().add(const Duration(days: 7)),
        'notes': 'Monitor peak flow readings. Avoid known triggers.',
        'labTests': [],
      },
      {
        'prescriptionId': 'PRX003',
        'patientId': 'ARUN1234',
        'patientName': 'Arun Menon',
        'dateIssued': DateTime.now().subtract(const Duration(days: 7)),
        'diagnosis': 'Upper Respiratory Infection',
        'symptoms': 'Fever, sore throat, nasal congestion',
        'medications': [
          {
            'name': 'Paracetamol',
            'dosage': '500mg',
            'frequency': 'Three times daily',
            'duration': '5 days',
            'instructions': 'Take after meals',
          },
          {
            'name': 'Cetirizine',
            'dosage': '10mg',
            'frequency': 'Once daily',
            'duration': '7 days',
            'instructions': 'Take at bedtime',
          },
        ],
        'status': 'Completed',
        'followUpDate': null,
        'notes': 'Patient recovered well. No further medication needed.',
        'labTests': [],
      },
    ];

    _filteredPrescriptions = _allPrescriptions;

    setState(() {
      _isLoading = false;
    });
  }

  void _filterPrescriptions(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPrescriptions = _allPrescriptions;
      } else {
        _filteredPrescriptions = _allPrescriptions.where((prescription) {
          return prescription['patientName'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              prescription['prescriptionId'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              prescription['diagnosis'].toString().toLowerCase().contains(
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
        title: const Text('Prescriptions'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreatePrescriptionDialog(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
          indicatorColor: AppColors.white,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'Recent'),
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
              onChanged: _filterPrescriptions,
              decoration: InputDecoration(
                hintText: 'Search prescriptions...',
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
                _buildPrescriptionsList(_filteredPrescriptions),
                _buildActivePrescriptions(),
                _buildRecentPrescriptions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionsList(List<Map<String, dynamic>> prescriptions) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (prescriptions.isEmpty) {
      return const Center(child: Text('No prescriptions found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemCount: prescriptions.length,
      itemBuilder: (context, index) {
        final prescription = prescriptions[index];
        return _buildPrescriptionCard(prescription);
      },
    );
  }

  Widget _buildActivePrescriptions() {
    final activePrescriptions = _allPrescriptions
        .where((prescription) => prescription['status'] == 'Active')
        .toList();
    return _buildPrescriptionsList(activePrescriptions);
  }

  Widget _buildRecentPrescriptions() {
    final recentPrescriptions = _allPrescriptions.where((prescription) {
      final dateIssued = prescription['dateIssued'] as DateTime;
      final daysSince = DateTime.now().difference(dateIssued).inDays;
      return daysSince <= 7;
    }).toList();
    return _buildPrescriptionsList(recentPrescriptions);
  }

  Widget _buildPrescriptionCard(Map<String, dynamic> prescription) {
    final dateIssued = prescription['dateIssued'] as DateTime;
    final medications =
        prescription['medications'] as List<Map<String, dynamic>>;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: InkWell(
        onTap: () => _viewPrescriptionDetails(prescription),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.marginMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prescription['patientName'].toString(),
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ID: ${prescription['prescriptionId']}',
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
                        prescription['status'],
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      prescription['status'].toString(),
                      style: TextStyle(
                        color: _getStatusColor(prescription['status']),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.marginMedium),

              // Diagnosis
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diagnosis',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prescription['diagnosis'].toString(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.marginMedium),

              // Medications
              Text(
                'Medications (${medications.length})',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimensions.marginSmall),

              ...medications
                  .take(2)
                  .map(
                    (medication) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.medication,
                            size: 16,
                            color: AppColors.grey600,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${medication['name']} ${medication['dosage']} - ${medication['frequency']}',
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

              if (medications.length > 2)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '... and ${medications.length - 2} more',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              const SizedBox(height: AppDimensions.marginMedium),

              // Footer
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.grey600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Issued: ${_formatDate(dateIssued)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  const Spacer(),
                  if (prescription['followUpDate'] != null) ...[
                    Icon(Icons.schedule, size: 16, color: AppColors.grey600),
                    const SizedBox(width: 4),
                    Text(
                      'Follow-up: ${_formatDate(prescription['followUpDate'])}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: AppDimensions.marginMedium),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _editPrescription(prescription),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.marginMedium),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _viewPrescriptionDetails(prescription),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('View'),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'completed':
        return AppColors.info;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.grey500;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _viewPrescriptionDetails(Map<String, dynamic> prescription) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrescriptionDetailScreen(
          prescription: prescription,
          doctorData: widget.doctorData,
        ),
      ),
    );
  }

  void _editPrescription(Map<String, dynamic> prescription) {
    // Navigate to edit prescription screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit prescription feature coming soon')),
    );
  }

  void _showCreatePrescriptionDialog() {
    // Navigate to create prescription screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create prescription feature coming soon')),
    );
  }
}

// Prescription Detail Screen
class PrescriptionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> prescription;
  final Map<String, dynamic> doctorData;

  const PrescriptionDetailScreen({
    super.key,
    required this.prescription,
    required this.doctorData,
  });

  @override
  Widget build(BuildContext context) {
    final medications =
        prescription['medications'] as List<Map<String, dynamic>>;
    final labTests = prescription['labTests'] as List<dynamic>;

    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: Text('Prescription ${prescription['prescriptionId']}'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          IconButton(icon: const Icon(Icons.print), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.receipt_long,
                            color: AppColors.primaryBlue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.marginMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prescription['patientName'].toString(),
                                style: AppTextStyles.headline6.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Patient ID: ${prescription['patientId']}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.grey600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              prescription['status'],
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            prescription['status'].toString(),
                            style: TextStyle(
                              color: _getStatusColor(prescription['status']),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.marginLarge),

                    _buildDetailRow(
                      'Prescription ID',
                      prescription['prescriptionId'].toString(),
                    ),
                    _buildDetailRow(
                      'Date Issued',
                      _formatDate(prescription['dateIssued']),
                    ),
                    _buildDetailRow('Doctor', doctorData['name'] ?? 'Unknown'),
                    if (prescription['followUpDate'] != null)
                      _buildDetailRow(
                        'Follow-up Date',
                        _formatDate(prescription['followUpDate']),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.marginMedium),

            // Diagnosis Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diagnosis & Symptoms',
                      style: AppTextStyles.headline6.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primaryBlue.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Diagnosis',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            prescription['diagnosis'].toString(),
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.marginMedium),

                    Text(
                      'Symptoms',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.marginSmall),
                    Text(
                      prescription['symptoms'].toString(),
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.marginMedium),

            // Medications Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prescribed Medications',
                      style: AppTextStyles.headline6.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),

                    ...medications.map(
                      (medication) => _buildMedicationItem(medication),
                    ),
                  ],
                ),
              ),
            ),

            if (labTests.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.marginMedium),

              // Lab Tests Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recommended Lab Tests',
                        style: AppTextStyles.headline6.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.marginMedium),

                      ...labTests.map(
                        (test) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.science,
                                size: 16,
                                color: AppColors.grey600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                test.toString(),
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (prescription['notes']?.toString().isNotEmpty == true) ...[
              const SizedBox(height: AppDimensions.marginMedium),

              // Notes Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Doctor\'s Notes',
                        style: AppTextStyles.headline6.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.marginMedium),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          prescription['notes'].toString(),
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppDimensions.marginLarge),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editPrescription(context),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: AppDimensions.marginMedium),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _printPrescription(context),
                    icon: const Icon(Icons.print),
                    label: const Text('Print'),
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
                color: AppColors.grey600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationItem(Map<String, dynamic> medication) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.medication,
                  color: AppColors.primaryGreen,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  medication['name'].toString(),
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildMedicationDetail(
                  'Dosage',
                  medication['dosage'].toString(),
                ),
              ),
              Expanded(
                child: _buildMedicationDetail(
                  'Frequency',
                  medication['frequency'].toString(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _buildMedicationDetail(
                  'Duration',
                  medication['duration'].toString(),
                ),
              ),
              Expanded(child: Container()),
            ],
          ),

          if (medication['instructions']?.toString().isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructions',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    medication['instructions'].toString(),
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicationDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.grey600,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.bodyMedium),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'completed':
        return AppColors.info;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.grey500;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _editPrescription(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit prescription feature coming soon')),
    );
  }

  void _printPrescription(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Print prescription feature coming soon')),
    );
  }
}
