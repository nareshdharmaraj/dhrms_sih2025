import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';
import '../../../screens/patient_registration_screen.dart';

class BedManagementScreen extends StatefulWidget {
  const BedManagementScreen({super.key});

  @override
  State<BedManagementScreen> createState() => _BedManagementScreenState();
}

class _BedManagementScreenState extends State<BedManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDepartment = 'All Departments';
  String _selectedStatus = 'All Status';

  final List<String> _departments = [
    'All Departments',
    'General Medicine',
    'ICU',
    'Emergency',
    'Pediatrics',
    'Cardiology',
    'Orthopedics',
    'Surgery',
    'Maternity',
  ];

  final List<String> _statusTypes = [
    'All Status',
    'Available',
    'Occupied',
    'Under Maintenance',
    'Reserved',
  ];

  // Mock data for beds
  final List<Map<String, dynamic>> _beds = [
    {
      'id': 'ICU-001',
      'department': 'ICU',
      'type': 'ICU Bed',
      'status': 'Occupied',
      'patient': 'John Doe',
      'patientId': 'P12345',
      'admissionDate': '2024-01-15',
      'estimatedDischarge': '2024-01-20',
      'condition': 'Critical',
      'floor': '3rd Floor',
      'room': 'ICU-A-001',
      'price': '₹5,000/day',
    },
    {
      'id': 'GM-015',
      'department': 'General Medicine',
      'type': 'General Bed',
      'status': 'Available',
      'patient': null,
      'patientId': null,
      'admissionDate': null,
      'estimatedDischarge': null,
      'condition': null,
      'floor': '2nd Floor',
      'room': 'GM-B-015',
      'price': '₹1,500/day',
    },
    {
      'id': 'EM-008',
      'department': 'Emergency',
      'type': 'Emergency Bed',
      'status': 'Reserved',
      'patient': 'Emergency Hold',
      'patientId': null,
      'admissionDate': null,
      'estimatedDischarge': null,
      'condition': null,
      'floor': '1st Floor',
      'room': 'EM-001',
      'price': '₹2,500/day',
    },
    {
      'id': 'PD-021',
      'department': 'Pediatrics',
      'type': 'Pediatric Bed',
      'status': 'Occupied',
      'patient': 'Baby Sarah',
      'patientId': 'P67890',
      'admissionDate': '2024-01-18',
      'estimatedDischarge': '2024-01-22',
      'condition': 'Stable',
      'floor': '2nd Floor',
      'room': 'PD-C-021',
      'price': '₹2,000/day',
    },
    {
      'id': 'CR-005',
      'department': 'Cardiology',
      'type': 'Cardiac Bed',
      'status': 'Under Maintenance',
      'patient': null,
      'patientId': null,
      'admissionDate': null,
      'estimatedDischarge': null,
      'condition': null,
      'floor': '4th Floor',
      'room': 'CR-A-005',
      'price': '₹4,000/day',
    },
    {
      'id': 'GM-032',
      'department': 'General Medicine',
      'type': 'General Bed',
      'status': 'Available',
      'patient': null,
      'patientId': null,
      'admissionDate': null,
      'estimatedDischarge': null,
      'condition': null,
      'floor': '2nd Floor',
      'room': 'GM-B-032',
      'price': '₹1,500/day',
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
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredBeds {
    return _beds.where((bed) {
      bool matchesDepartment =
          _selectedDepartment == 'All Departments' ||
          bed['department'] == _selectedDepartment;
      bool matchesStatus =
          _selectedStatus == 'All Status' || bed['status'] == _selectedStatus;
      return matchesDepartment && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: Text(
          'Bed Management',
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
            icon: Icon(Icons.add, color: AppColors.white),
            onPressed: () => _showAddBedDialog(),
          ),
          IconButton(
            icon: Icon(Icons.analytics, color: AppColors.white),
            onPressed: () => _showBedAnalytics(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'All Beds'),
            Tab(text: 'Booking Queue'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBedsTab(),
          _buildBookingQueueTab(),
          _buildAnalyticsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBookBedDialog(),
        backgroundColor: AppColors.hospitalRole,
        child: Icon(Icons.bed, color: AppColors.white),
      ),
    );
  }

  Widget _buildBedsTab() {
    return Column(
      children: [
        // Filters
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          color: AppColors.white,
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedDepartment,
                  decoration: InputDecoration(
                    labelText: 'Department',
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
                  items: _departments.map((department) {
                    return DropdownMenuItem(
                      value: department,
                      child: Text(department),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDepartment = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
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
                  items: _statusTypes.map((status) {
                    return DropdownMenuItem(value: status, child: Text(status));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        // Bed Statistics Summary
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          color: AppColors.white,
          child: Row(
            children: [
              _buildStatChip(
                'Total',
                _filteredBeds.length.toString(),
                AppColors.primaryBlue,
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              _buildStatChip(
                'Available',
                _filteredBeds
                    .where((b) => b['status'] == 'Available')
                    .length
                    .toString(),
                AppColors.success,
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              _buildStatChip(
                'Occupied',
                _filteredBeds
                    .where((b) => b['status'] == 'Occupied')
                    .length
                    .toString(),
                AppColors.warning,
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              _buildStatChip(
                'Reserved',
                _filteredBeds
                    .where((b) => b['status'] == 'Reserved')
                    .length
                    .toString(),
                AppColors.info,
              ),
            ],
          ),
        ),
        // Beds List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            itemCount: _filteredBeds.length,
            itemBuilder: (context, index) {
              final bed = _filteredBeds[index];
              return _buildBedCard(bed);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Text(
              count,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBedCard(Map<String, dynamic> bed) {
    Color statusColor = _getStatusColor(bed['status']);

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: InkWell(
        onTap: () => _showBedDetails(bed),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getBedIcon(bed['status']),
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              bed['id'],
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.grey900,
                              ),
                            ),
                            const Spacer(),
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
                                bed['status'],
                                style: AppTextStyles.caption.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${bed['department']} • ${bed['type']}',
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
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: AppColors.grey600),
                  const SizedBox(width: 4),
                  Text(
                    '${bed['floor']} • ${bed['room']}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    bed['price'],
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.hospitalRole,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (bed['patient'] != null) ...[
                const SizedBox(height: AppDimensions.paddingSmall),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 16, color: AppColors.grey600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${bed['patient']} (${bed['patientId'] ?? 'N/A'})',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (bed['condition'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: bed['condition'] == 'Critical'
                                ? AppColors.error.withOpacity(0.1)
                                : AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            bed['condition'],
                            style: AppTextStyles.caption.copyWith(
                              color: bed['condition'] == 'Critical'
                                  ? AppColors.error
                                  : AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingQueueTab() {
    // Mock booking queue data
    final bookingQueue = [
      {
        'id': 'BQ001',
        'patientName': 'Amit Patel',
        'patientId': 'P98765',
        'requestTime': '2024-01-20 14:30',
        'department': 'Cardiology',
        'priority': 'High',
        'estimatedWait': '2 hours',
        'contactNumber': '+91 98765 43210',
        'reason': 'Cardiac monitoring required',
        'status': 'Waiting',
      },
      {
        'id': 'BQ002',
        'patientName': 'Sunita Devi',
        'patientId': 'P54321',
        'requestTime': '2024-01-20 15:45',
        'department': 'General Medicine',
        'priority': 'Medium',
        'estimatedWait': '4 hours',
        'contactNumber': '+91 87654 32109',
        'reason': 'General admission',
        'status': 'Waiting',
      },
      {
        'id': 'BQ003',
        'patientName': 'Rohan Singh',
        'patientId': 'P11111',
        'requestTime': '2024-01-20 16:20',
        'department': 'Emergency',
        'priority': 'Critical',
        'estimatedWait': 'Immediate',
        'contactNumber': '+91 76543 21098',
        'reason': 'Emergency admission - accident case',
        'status': 'Processing',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemCount: bookingQueue.length,
      itemBuilder: (context, index) {
        final booking = bookingQueue[index];
        return _buildBookingQueueCard(booking);
      },
    );
  }

  Widget _buildBookingQueueCard(Map<String, dynamic> booking) {
    Color priorityColor = booking['priority'] == 'Critical'
        ? AppColors.error
        : booking['priority'] == 'High'
        ? AppColors.warning
        : AppColors.info;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking['priority'],
                    style: AppTextStyles.caption.copyWith(
                      color: priorityColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  booking['id'],
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Text(
              booking['patientName'],
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.grey900,
              ),
            ),
            Text(
              'ID: ${booking['patientId']} • ${booking['department']}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Text(
              booking['reason'],
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: AppColors.grey600),
                const SizedBox(width: 4),
                Text(
                  'Est. Wait: ${booking['estimatedWait']}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _processBedBooking(booking),
                  icon: Icon(Icons.bed, size: 16),
                  label: Text('Assign Bed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.hospitalRole,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
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

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bed Occupancy Analytics',
            style: AppTextStyles.headline6.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),

          // Overall Occupancy Rate
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Occupancy Rate',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  LinearProgressIndicator(
                    value: 0.75,
                    backgroundColor: AppColors.grey300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.hospitalRole,
                    ),
                    minHeight: 8,
                  ),
                  const SizedBox(height: AppDimensions.paddingSmall),
                  Text(
                    '75% (180/240 beds)',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.paddingLarge),

          // Department-wise Occupancy
          Text(
            'Department-wise Occupancy',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),

          ..._departments.where((dept) => dept != 'All Departments').map((
            dept,
          ) {
            final random = dept.hashCode % 100;
            final occupancy = (random / 100).clamp(0.0, 1.0);
            return Card(
              margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          dept,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(occupancy * 100).round()}%',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: occupancy > 0.8
                                ? AppColors.error
                                : occupancy > 0.6
                                ? AppColors.warning
                                : AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),
                    LinearProgressIndicator(
                      value: occupancy,
                      backgroundColor: AppColors.grey300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        occupancy > 0.8
                            ? AppColors.error
                            : occupancy > 0.6
                            ? AppColors.warning
                            : AppColors.success,
                      ),
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return AppColors.success;
      case 'Occupied':
        return AppColors.warning;
      case 'Reserved':
        return AppColors.info;
      case 'Under Maintenance':
        return AppColors.error;
      default:
        return AppColors.grey500;
    }
  }

  IconData _getBedIcon(String status) {
    switch (status) {
      case 'Available':
        return Icons.bed;
      case 'Occupied':
        return Icons.airline_seat_flat;
      case 'Reserved':
        return Icons.event_seat;
      case 'Under Maintenance':
        return Icons.build;
      default:
        return Icons.bed;
    }
  }

  void _showBedDetails(Map<String, dynamic> bed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bed Details: ${bed['id']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Department', bed['department']),
              _buildDetailRow('Type', bed['type']),
              _buildDetailRow('Status', bed['status']),
              _buildDetailRow('Floor', bed['floor']),
              _buildDetailRow('Room', bed['room']),
              _buildDetailRow('Price', bed['price']),
              if (bed['patient'] != null) ...[
                const Divider(),
                Text(
                  'Patient Information',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Patient', bed['patient']),
                _buildDetailRow('Patient ID', bed['patientId'] ?? 'N/A'),
                _buildDetailRow(
                  'Admission Date',
                  bed['admissionDate'] ?? 'N/A',
                ),
                _buildDetailRow(
                  'Est. Discharge',
                  bed['estimatedDischarge'] ?? 'N/A',
                ),
                _buildDetailRow('Condition', bed['condition'] ?? 'N/A'),
              ],
            ],
          ),
        ),
        actions: [
          if (bed['status'] == 'Available')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showBookBedDialog(bedId: bed['id']);
              },
              child: Text('Book Bed'),
            ),
          if (bed['status'] == 'Occupied')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showDischargeDialog(bed);
              },
              child: Text('Discharge'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
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

  void _showAddBedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Bed'),
        content: Text(
          'Add new bed functionality will be available in a future update.',
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

  void _showBedAnalytics() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Detailed analytics view opened')));
  }

  void _showBookBedDialog({String? bedId}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(bedId != null ? 'Book Bed $bedId' : 'Book Bed'),
        content: Text(
          'Bed booking functionality will be available in a future update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Bed booking confirmed')));
            },
            child: Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }

  void _showDischargeDialog(Map<String, dynamic> bed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Discharge Patient'),
        content: Text(
          'Confirm discharge for ${bed['patient']} from bed ${bed['id']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Patient discharged successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: Text('Confirm Discharge'),
          ),
        ],
      ),
    );
  }

  void _processBedBooking(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assign Bed'),
        content: Text('Assign bed for ${booking['patientName']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Bed assigned to ${booking['patientName']}'),
                ),
              );
            },
            child: Text('Assign'),
          ),
        ],
      ),
    );
  }
}
