import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';

class InsuranceScreen extends StatefulWidget {
  const InsuranceScreen({super.key});

  @override
  State<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends State<InsuranceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<InsurancePolicy> _policies = [
    InsurancePolicy(
      id: '1',
      provider: 'HealthGuard Pro',
      policyNumber: 'HG-2024-001234',
      type: 'Comprehensive Health',
      premium: 2500.00,
      coverage: 500000.00,
      deductible: 5000.00,
      status: 'Active',
      expiryDate: DateTime(2025, 12, 31),
      renewalDate: DateTime(2024, 12, 31),
      isActive: true,
    ),
    InsurancePolicy(
      id: '2',
      provider: 'FamilyCare Insurance',
      policyNumber: 'FC-2023-987654',
      type: 'Family Health Plan',
      premium: 4200.00,
      coverage: 1000000.00,
      deductible: 7500.00,
      status: 'Pending Renewal',
      expiryDate: DateTime(2024, 10, 15),
      renewalDate: DateTime(2024, 10, 15),
      isActive: false,
    ),
  ];

  final List<Claim> _claims = [
    Claim(
      id: '1',
      claimNumber: 'CLM-2024-001',
      provider: 'City General Hospital',
      amount: 15000.00,
      approvedAmount: 12000.00,
      status: 'Approved',
      dateSubmitted: DateTime(2024, 8, 15),
      dateProcessed: DateTime(2024, 8, 22),
      description: 'Emergency surgery - appendectomy',
      policyId: '1',
    ),
    Claim(
      id: '2',
      claimNumber: 'CLM-2024-002',
      provider: 'MediCare Clinic',
      amount: 5000.00,
      approvedAmount: 0.00,
      status: 'Under Review',
      dateSubmitted: DateTime(2024, 8, 28),
      dateProcessed: null,
      description: 'Routine check-up and blood tests',
      policyId: '1',
    ),
    Claim(
      id: '3',
      claimNumber: 'CLM-2024-003',
      provider: 'Dental Care Center',
      amount: 8000.00,
      approvedAmount: 6000.00,
      status: 'Partially Approved',
      dateSubmitted: DateTime(2024, 8, 10),
      dateProcessed: DateTime(2024, 8, 18),
      description: 'Dental implant procedure',
      policyId: '1',
    ),
  ];

  final List<Document> _documents = [
    Document(
      id: '1',
      name: 'Policy Certificate - HealthGuard Pro',
      type: 'Policy Certificate',
      uploadDate: DateTime(2024, 1, 15),
      size: '2.4 MB',
    ),
    Document(
      id: '2',
      name: 'Medical Report - Aug 2024',
      type: 'Medical Report',
      uploadDate: DateTime(2024, 8, 20),
      size: '1.8 MB',
    ),
    Document(
      id: '3',
      name: 'Hospital Bill - City General',
      type: 'Bill/Invoice',
      uploadDate: DateTime(2024, 8, 15),
      size: '856 KB',
    ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insurance'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddPolicyDialog(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Policies'),
            Tab(text: 'Claims'),
            Tab(text: 'Documents'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPoliciesTab(),
          _buildClaimsTab(),
          _buildDocumentsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewClaimDialog(),
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPoliciesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInsuranceSummary(),
          const SizedBox(height: 20),
          Text(
            'Your Policies',
            style: AppTextStyles.headline6.copyWith(
              color: AppColors.grey800,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._policies.map((policy) => _buildPolicyCard(policy)),
        ],
      ),
    );
  }

  Widget _buildInsuranceSummary() {
    final totalCoverage = _policies
        .where((p) => p.isActive)
        .fold(0.0, (sum, policy) => sum + policy.coverage);
    final totalPremium = _policies
        .where((p) => p.isActive)
        .fold(0.0, (sum, policy) => sum + policy.premium);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Insurance Summary',
            style: AppTextStyles.headline6.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Coverage',
                  '\$${totalCoverage.toStringAsFixed(0)}',
                  Icons.shield,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Annual Premium',
                  '\$${totalPremium.toStringAsFixed(0)}',
                  Icons.payment,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Active Policies',
                  '${_policies.where((p) => p.isActive).length}',
                  Icons.policy,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Claims This Year',
                  '${_claims.length}',
                  Icons.description,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.headline6.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPolicyCard(InsurancePolicy policy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: policy.isActive ? AppColors.primaryGreen : AppColors.grey300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    policy.provider,
                    style: AppTextStyles.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: policy.isActive
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    policy.status,
                    style: AppTextStyles.caption.copyWith(
                      color: policy.isActive
                          ? AppColors.success
                          : AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              policy.type,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
            ),
            Text(
              'Policy #${policy.policyNumber}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPolicyDetail(
                    'Coverage',
                    '\$${policy.coverage.toStringAsFixed(0)}',
                  ),
                ),
                Expanded(
                  child: _buildPolicyDetail(
                    'Premium',
                    '\$${policy.premium.toStringAsFixed(0)}/year',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPolicyDetail(
                    'Deductible',
                    '\$${policy.deductible.toStringAsFixed(0)}',
                  ),
                ),
                Expanded(
                  child: _buildPolicyDetail(
                    'Expires',
                    _formatDate(policy.expiryDate),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showPolicyDetails(policy),
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: policy.isActive
                        ? () => _renewPolicy(policy)
                        : () => _activatePolicy(policy),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: policy.isActive
                          ? AppColors.primaryBlue
                          : AppColors.primaryGreen,
                    ),
                    child: Text(policy.isActive ? 'Renew' : 'Activate'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildClaimsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Claims',
            style: AppTextStyles.headline6.copyWith(
              color: AppColors.grey800,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._claims.map((claim) => _buildClaimCard(claim)),
        ],
      ),
    );
  }

  Widget _buildClaimCard(Claim claim) {
    Color statusColor;
    switch (claim.status) {
      case 'Approved':
        statusColor = AppColors.success;
        break;
      case 'Under Review':
        statusColor = AppColors.warning;
        break;
      case 'Partially Approved':
        statusColor = AppColors.primaryBlue;
        break;
      case 'Denied':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.grey500;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  claim.claimNumber,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    claim.status,
                    style: AppTextStyles.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              claim.description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Provider: ${claim.provider}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildClaimDetail(
                    'Claimed Amount',
                    '\$${claim.amount.toStringAsFixed(2)}',
                  ),
                ),
                if (claim.approvedAmount > 0)
                  Expanded(
                    child: _buildClaimDetail(
                      'Approved Amount',
                      '\$${claim.approvedAmount.toStringAsFixed(2)}',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildClaimDetail(
                    'Date Submitted',
                    _formatDate(claim.dateSubmitted),
                  ),
                ),
                if (claim.dateProcessed != null)
                  Expanded(
                    child: _buildClaimDetail(
                      'Date Processed',
                      _formatDate(claim.dateProcessed!),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showClaimDetails(claim),
                child: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClaimDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildDocumentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Documents',
                style: AppTextStyles.headline6.copyWith(
                  color: AppColors.grey800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _uploadDocument(),
                icon: const Icon(Icons.upload),
                label: const Text('Upload'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._documents.map((document) => _buildDocumentCard(document)),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(Document document) {
    IconData iconData;
    Color iconColor;

    switch (document.type) {
      case 'Policy Certificate':
        iconData = Icons.policy;
        iconColor = AppColors.primaryGreen;
        break;
      case 'Medical Report':
        iconData = Icons.medical_information;
        iconColor = AppColors.primaryBlue;
        break;
      case 'Bill/Invoice':
        iconData = Icons.receipt;
        iconColor = AppColors.primaryOrange;
        break;
      default:
        iconData = Icons.description;
        iconColor = AppColors.grey600;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey300),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(iconData, color: iconColor),
        ),
        title: Text(
          document.name,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              document.type,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
            ),
            Text(
              'Uploaded: ${_formatDate(document.uploadDate)} • ${document.size}',
              style: AppTextStyles.caption.copyWith(color: AppColors.grey500),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('View'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'download',
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('Download'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) =>
              _handleDocumentAction(document, value.toString()),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Policy'),
        content: const Text(
          'This will redirect you to add a new insurance policy.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Redirecting to add policy...')),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showNewClaimDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit New Claim'),
        content: const Text('This will open the claim submission form.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening claim form...')),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showPolicyDetails(InsurancePolicy policy) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(policy.provider),
        content: Text('Policy details for ${policy.policyNumber}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _renewPolicy(InsurancePolicy policy) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Renewing policy ${policy.policyNumber}...')),
    );
  }

  void _activatePolicy(InsurancePolicy policy) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Activating policy ${policy.policyNumber}...')),
    );
  }

  void _showClaimDetails(Claim claim) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(claim.claimNumber),
        content: Text('Claim details for ${claim.description}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _uploadDocument() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Opening document upload...')));
  }

  void _handleDocumentAction(Document document, String action) {
    switch (action) {
      case 'view':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Viewing ${document.name}...')));
        break;
      case 'download':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloading ${document.name}...')),
        );
        break;
      case 'delete':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Deleting ${document.name}...')));
        break;
    }
  }
}

class InsurancePolicy {
  final String id;
  final String provider;
  final String policyNumber;
  final String type;
  final double premium;
  final double coverage;
  final double deductible;
  final String status;
  final DateTime expiryDate;
  final DateTime renewalDate;
  final bool isActive;

  InsurancePolicy({
    required this.id,
    required this.provider,
    required this.policyNumber,
    required this.type,
    required this.premium,
    required this.coverage,
    required this.deductible,
    required this.status,
    required this.expiryDate,
    required this.renewalDate,
    required this.isActive,
  });
}

class Claim {
  final String id;
  final String claimNumber;
  final String provider;
  final double amount;
  final double approvedAmount;
  final String status;
  final DateTime dateSubmitted;
  final DateTime? dateProcessed;
  final String description;
  final String policyId;

  Claim({
    required this.id,
    required this.claimNumber,
    required this.provider,
    required this.amount,
    required this.approvedAmount,
    required this.status,
    required this.dateSubmitted,
    this.dateProcessed,
    required this.description,
    required this.policyId,
  });
}

class Document {
  final String id;
  final String name;
  final String type;
  final DateTime uploadDate;
  final String size;

  Document({
    required this.id,
    required this.name,
    required this.type,
    required this.uploadDate,
    required this.size,
  });
}
