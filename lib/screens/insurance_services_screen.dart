import 'package:flutter/material.dart';

class InsuranceServicesScreen extends StatefulWidget {
  final Map<String, dynamic>? patientData;

  const InsuranceServicesScreen({super.key, this.patientData});

  @override
  State<InsuranceServicesScreen> createState() => _InsuranceServicesScreenState();
}

class _InsuranceServicesScreenState extends State<InsuranceServicesScreen> {
  final List<Map<String, dynamic>> _insurancePlans = [];
  final List<Map<String, dynamic>> _claims = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insurance Services'),
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade50, Colors.white],
          ),
        ),
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              TabBar(
                labelColor: Colors.indigo.shade600,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.indigo.shade600,
                tabs: const [
                  Tab(text: 'My Plans', icon: Icon(Icons.card_membership)),
                  Tab(text: 'Claims', icon: Icon(Icons.receipt_long)),
                  Tab(text: 'Browse Plans', icon: Icon(Icons.search)),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildMyPlansTab(),
                    _buildClaimsTab(),
                    _buildBrowsePlansTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyPlansTab() {
    return _insurancePlans.isEmpty ? _buildMyPlansEmptyState() : _buildMyPlansList();
  }

  Widget _buildMyPlansEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 120,
            color: Colors.indigo.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'No Insurance Plans',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add your insurance plans to track coverage',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showAddInsuranceDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Insurance Plan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyPlansList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _insurancePlans.length,
      itemBuilder: (context, index) {
        final plan = _insurancePlans[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
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
                        color: Colors.indigo.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.shield,
                        color: Colors.indigo.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan['providerName'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            plan['planName'],
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: plan['isActive'] ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        plan['isActive'] ? 'Active' : 'Inactive',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard('Policy Number', plan['policyNumber']),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard('Group ID', plan['groupId'] ?? 'N/A'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard('Deductible', '\$${plan['deductible']}'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard('Co-pay', '\$${plan['copay']}'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showPlanDetails(plan),
                        icon: const Icon(Icons.info_outline, size: 16),
                        label: const Text('View Details'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.indigo.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showFileClaimDialog(plan),
                        icon: const Icon(Icons.add_circle, size: 16),
                        label: const Text('File Claim'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimsTab() {
    return _claims.isEmpty ? _buildClaimsEmptyState() : _buildClaimsList();
  }

  Widget _buildClaimsEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 120,
            color: Colors.indigo.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'No Claims Filed',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your insurance claims will appear here',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildClaimsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _claims.length,
      itemBuilder: (context, index) {
        final claim = _claims[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.receipt,
                      color: Colors.indigo.shade600,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Claim #${claim['claimNumber']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            claim['description'],
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text(claim['status']),
                      backgroundColor: _getClaimStatusColor(claim['status']),
                      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard('Amount', '\$${claim['amount']}'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard('Date Filed', claim['dateFiled']),
                    ),
                  ],
                ),
                if (claim['approvedAmount'] != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoCard('Approved Amount', '\$${claim['approvedAmount']}'),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getClaimStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Denied':
        return Colors.red;
      case 'Under Review':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildBrowsePlansTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Available Insurance Plans',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        _buildBrowsePlanCard(
          'HealthFirst Premium',
          'HealthFirst Insurance',
          '\$150/month',
          'Comprehensive coverage with low deductible',
          ['Emergency Care', 'Preventive Care', 'Prescription Drugs', 'Mental Health'],
          Colors.blue,
        ),
        _buildBrowsePlanCard(
          'MediCare Basic',
          'MediCare Solutions',
          '\$89/month',
          'Essential coverage for basic healthcare needs',
          ['Emergency Care', 'Primary Care', 'Basic Prescription'],
          Colors.green,
        ),
        _buildBrowsePlanCard(
          'WellCare Plus',
          'WellCare Health',
          '\$120/month',
          'Balanced coverage with good network access',
          ['Emergency Care', 'Specialist Care', 'Preventive Care', 'Dental'],
          Colors.purple,
        ),
        _buildBrowsePlanCard(
          'FamilyCare Gold',
          'FamilyCare Insurance',
          '\$200/month',
          'Premium family coverage with extensive benefits',
          ['All Services', 'Maternity Care', 'Pediatric Care', 'Vision & Dental'],
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildBrowsePlanCard(String planName, String provider, String price, String description, List<String> benefits, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
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
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.shield, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        planName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        provider,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Benefits:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: benefits.map((benefit) => Chip(
                label: Text(
                  benefit,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: color.withOpacity(0.1),
                labelStyle: TextStyle(color: color),
              )).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showPlanComparison(planName),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                    ),
                    child: const Text('Compare'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showEnrollDialog(planName, provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Enroll'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddInsuranceDialog() {
    final providerController = TextEditingController();
    final planController = TextEditingController();
    final policyController = TextEditingController();
    final groupController = TextEditingController();
    final deductibleController = TextEditingController();
    final copayController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Insurance Plan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: providerController,
                decoration: const InputDecoration(
                  labelText: 'Insurance Provider',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: planController,
                decoration: const InputDecoration(
                  labelText: 'Plan Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: policyController,
                decoration: const InputDecoration(
                  labelText: 'Policy Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: groupController,
                decoration: const InputDecoration(
                  labelText: 'Group ID (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: deductibleController,
                      decoration: const InputDecoration(
                        labelText: 'Deductible',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: copayController,
                      decoration: const InputDecoration(
                        labelText: 'Co-pay',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
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
              if (providerController.text.isNotEmpty && 
                  planController.text.isNotEmpty && 
                  policyController.text.isNotEmpty) {
                _addInsurancePlan(
                  providerController.text,
                  planController.text,
                  policyController.text,
                  groupController.text,
                  deductibleController.text,
                  copayController.text,
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addInsurancePlan(String provider, String plan, String policy, String group, String deductible, String copay) {
    setState(() {
      _insurancePlans.add({
        'providerName': provider,
        'planName': plan,
        'policyNumber': policy,
        'groupId': group.isEmpty ? null : group,
        'deductible': deductible.isEmpty ? '0' : deductible,
        'copay': copay.isEmpty ? '0' : copay,
        'isActive': true,
      });
    });
  }

  void _showPlanDetails(Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(plan['planName']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Provider: ${plan['providerName']}'),
            Text('Policy Number: ${plan['policyNumber']}'),
            if (plan['groupId'] != null) Text('Group ID: ${plan['groupId']}'),
            Text('Deductible: \$${plan['deductible']}'),
            Text('Co-pay: \$${plan['copay']}'),
            Text('Status: ${plan['isActive'] ? 'Active' : 'Inactive'}'),
          ],
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

  void _showFileClaimDialog(Map<String, dynamic> plan) {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File Insurance Claim'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Claim Amount',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (descriptionController.text.isNotEmpty && amountController.text.isNotEmpty) {
                _fileClaim(plan, descriptionController.text, amountController.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('File Claim'),
          ),
        ],
      ),
    );
  }

  void _fileClaim(Map<String, dynamic> plan, String description, String amount) {
    final claimNumber = 'CLM${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    final now = DateTime.now();
    
    setState(() {
      _claims.add({
        'claimNumber': claimNumber,
        'description': description,
        'amount': amount,
        'status': 'Pending',
        'dateFiled': '${now.day}/${now.month}/${now.year}',
        'planName': plan['planName'],
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Claim #$claimNumber filed successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showPlanComparison(String planName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Plan comparison for $planName coming soon'),
      ),
    );
  }

  void _showEnrollDialog(String planName, String provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enroll in $planName'),
        content: Text('Would you like to start the enrollment process for $planName from $provider?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Enrollment process started. You will be contacted soon.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Start Enrollment'),
          ),
        ],
      ),
    );
  }
}