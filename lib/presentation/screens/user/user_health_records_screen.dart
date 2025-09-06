import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';
import '../../widgets/common_widgets.dart';
import '../../../data/models/simple_health_record_model.dart';

class UserHealthRecordsScreen extends StatefulWidget {
  const UserHealthRecordsScreen({super.key});

  @override
  State<UserHealthRecordsScreen> createState() =>
      _UserHealthRecordsScreenState();
}

class _UserHealthRecordsScreenState extends State<UserHealthRecordsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Mock data for demonstration
  final List<SimpleHealthRecord> _allRecords = [
    SimpleHealthRecord(
      id: '1',
      userId: 'user1',
      recordType: 'Lab Test',
      title: 'Complete Blood Count',
      date: DateTime.now().subtract(const Duration(days: 2)),
      description:
          'Routine blood work showing all parameters within normal range',
      attachments: ['blood_test_report.pdf'],
      createdBy: 'Dr. Priya Sharma',
      tags: ['blood', 'routine', 'normal'],
    ),
    SimpleHealthRecord(
      id: '2',
      userId: 'user1',
      recordType: 'Prescription',
      title: 'Hypertension Medication',
      date: DateTime.now().subtract(const Duration(days: 7)),
      description: 'Prescribed medication for blood pressure management',
      attachments: ['prescription_01.jpg'],
      createdBy: 'Dr. Raj Kumar',
      tags: ['blood pressure', 'medication'],
    ),
    SimpleHealthRecord(
      id: '3',
      userId: 'user1',
      recordType: 'Vaccination',
      title: 'COVID-19 Booster',
      date: DateTime.now().subtract(const Duration(days: 30)),
      description: 'Third dose of COVID-19 vaccine administered',
      attachments: ['vaccine_certificate.pdf'],
      createdBy: 'Community Health Center',
      tags: ['covid', 'vaccination', 'booster'],
    ),
    SimpleHealthRecord(
      id: '4',
      userId: 'user1',
      recordType: 'Scan',
      title: 'Chest X-Ray',
      date: DateTime.now().subtract(const Duration(days: 45)),
      description: 'Chest X-ray showing clear lungs, no abnormalities detected',
      attachments: ['chest_xray.png'],
      createdBy: 'Radiology Department',
      tags: ['chest', 'xray', 'clear'],
    ),
  ];

  List<SimpleHealthRecord> _filteredRecords = [];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _filteredRecords = _allRecords;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _filterRecords(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'All') {
        _filteredRecords = _allRecords;
      } else {
        _filteredRecords = _allRecords
            .where((record) => record.recordType == category)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Records'),
        backgroundColor: AppColors.userPrimary,
        foregroundColor: AppColors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'My Records'),
            Tab(text: 'QR Code'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddRecordDialog(),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Loading health records...',
        child: TabBarView(
          controller: _tabController,
          children: [_buildRecordsTab(), _buildQRTab()],
        ),
      ),
    );
  }

  Widget _buildRecordsTab() {
    return Column(
      children: [
        _buildCategoryFilter(),
        Expanded(
          child: _filteredRecords.isEmpty
              ? EmptyState(
                  title: 'No Records Found',
                  subtitle: 'Add your first health record to get started',
                  icon: Icons.medical_information_outlined,
                  buttonText: 'Add Record',
                  onButtonPressed: () => _showAddRecordDialog(),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  itemCount: _filteredRecords.length,
                  itemBuilder: (context, index) {
                    return _buildRecordCard(_filteredRecords[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      'All',
      'Lab Test',
      'Prescription',
      'Vaccination',
      'Scan',
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == _selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: AppDimensions.marginSmall),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => _filterRecords(category),
              backgroundColor: AppColors.grey100,
              selectedColor: AppColors.userPrimary.withOpacity(0.2),
              checkmarkColor: AppColors.userPrimary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecordCard(SimpleHealthRecord record) {
    return AppCard(
      onTap: () => _showRecordDetails(record),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _getRecordIcon(record.recordType),
              const SizedBox(width: AppDimensions.marginSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      style: AppTextStyles.subtitle1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      record.createdBy,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              StatusIndicator(
                status: record.recordType,
                color: _getRecordColor(record.recordType),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.marginSmall),
          Text(
            record.description,
            style: AppTextStyles.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.marginSmall),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: AppColors.grey500),
              const SizedBox(width: 4),
              Text(
                _formatDate(record.date),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey500,
                ),
              ),
              const Spacer(),
              if (record.attachments.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.attach_file, size: 16, color: AppColors.grey500),
                    const SizedBox(width: 4),
                    Text(
                      '${record.attachments.length} file${record.attachments.length > 1 ? 's' : ''}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQRTab() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppCard(
            child: Column(
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey300),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusLarge,
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code,
                          size: 100,
                          color: AppColors.grey400,
                        ),
                        SizedBox(height: AppDimensions.marginSmall),
                        Text(
                          'QR Code will appear here',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.marginLarge),
                Text(
                  'Quick Access QR Code',
                  style: AppTextStyles.headline6.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.marginSmall),
                Text(
                  'Share this QR code with healthcare providers for quick access to your essential health information.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.marginLarge),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Share QR',
                        icon: Icons.share,
                        onPressed: () => _shareQRCode(),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.marginMedium),
                    Expanded(
                      child: AppButton(
                        text: 'Download',
                        icon: Icons.download,
                        isOutlined: true,
                        onPressed: () => _downloadQRCode(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getRecordIcon(String recordType) {
    IconData icon;
    Color color;

    switch (recordType) {
      case 'Lab Test':
        icon = Icons.science;
        color = AppColors.info;
        break;
      case 'Prescription':
        icon = Icons.medication;
        color = AppColors.success;
        break;
      case 'Vaccination':
        icon = Icons.vaccines;
        color = AppColors.warning;
        break;
      case 'Scan':
        icon = Icons.medical_information;
        color = AppColors.error;
        break;
      default:
        icon = Icons.description;
        color = AppColors.grey500;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Color _getRecordColor(String recordType) {
    switch (recordType) {
      case 'Lab Test':
        return AppColors.info;
      case 'Prescription':
        return AppColors.success;
      case 'Vaccination':
        return AppColors.warning;
      case 'Scan':
        return AppColors.error;
      default:
        return AppColors.grey500;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      final months = (difference / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
  }

  void _showRecordDetails(SimpleHealthRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildRecordDetailsSheet(record),
    );
  }

  Widget _buildRecordDetailsSheet(SimpleHealthRecord record) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(
              vertical: AppDimensions.marginMedium,
            ),
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _getRecordIcon(record.recordType),
                      const SizedBox(width: AppDimensions.marginMedium),
                      Expanded(
                        child: Text(
                          record.title,
                          style: AppTextStyles.headline6.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.marginMedium),
                  Text(
                    'Provider: ${record.createdBy}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  Text(
                    'Date: ${_formatDate(record.date)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.marginLarge),
                  Text(
                    'Description',
                    style: AppTextStyles.subtitle1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.marginSmall),
                  Text(record.description, style: AppTextStyles.bodyMedium),
                  if (record.attachments.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.marginLarge),
                    Text(
                      'Attachments',
                      style: AppTextStyles.subtitle1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.marginSmall),
                    ...record.attachments.map(
                      (attachment) => _buildAttachmentTile(attachment),
                    ),
                  ],
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Share Record',
                          icon: Icons.share,
                          onPressed: () => _shareRecord(record),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.marginMedium),
                      Expanded(
                        child: AppButton(
                          text: 'Edit',
                          icon: Icons.edit,
                          isOutlined: true,
                          onPressed: () => _editRecord(record),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentTile(String filename) {
    return ListTile(
      leading: const Icon(Icons.attach_file),
      title: Text(filename),
      trailing: IconButton(
        icon: const Icon(Icons.download),
        onPressed: () => _downloadAttachment(filename),
      ),
      onTap: () => _viewAttachment(filename),
    );
  }

  void _showSearchDialog() {
    // TODO: Implement search functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Search functionality coming soon')),
    );
  }

  void _showAddRecordDialog() {
    // TODO: Implement add record functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add record functionality coming soon')),
    );
  }

  void _shareQRCode() {
    // TODO: Implement QR code sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR code sharing coming soon')),
    );
  }

  void _downloadQRCode() {
    // TODO: Implement QR code download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR code download coming soon')),
    );
  }

  void _shareRecord(SimpleHealthRecord record) {
    // TODO: Implement record sharing
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Record sharing coming soon')));
  }

  void _editRecord(SimpleHealthRecord record) {
    // TODO: Implement record editing
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Record editing coming soon')));
  }

  void _downloadAttachment(String filename) {
    // TODO: Implement attachment download
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Downloading $filename...')));
  }

  void _viewAttachment(String filename) {
    // TODO: Implement attachment viewer
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Opening $filename...')));
  }
}
