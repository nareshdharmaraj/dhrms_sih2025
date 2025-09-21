import 'package:flutter/material.dart';
import '../../models/regional_health_officer.dart';
import '../../utils/colors.dart';

class RegionalHealthOfficerDetailsScreen extends StatefulWidget {
  final RegionalHealthOfficer rho;

  const RegionalHealthOfficerDetailsScreen({super.key, required this.rho});

  @override
  _RegionalHealthOfficerDetailsScreenState createState() => _RegionalHealthOfficerDetailsScreenState();
}

class _RegionalHealthOfficerDetailsScreenState extends State<RegionalHealthOfficerDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<Map<String, dynamic>> _staffList = [];
  Map<String, dynamic> _statistics = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRHOData();
  }

  Future<void> _loadRHOData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API calls for RHO details
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _staffList = [
          {
            'id': 'DOC001',
            'name': 'Dr. John Smith',
            'role': 'Doctor',
            'specialization': 'Cardiology',
            'status': 'Active',
            'joinDate': '2024-01-15',
          },
          {
            'id': 'NUR001',
            'name': 'Sarah Johnson',
            'role': 'Nurse',
            'specialization': 'ICU',
            'status': 'Active',
            'joinDate': '2024-02-01',
          },
          {
            'id': 'LAB001',
            'name': 'Mike Wilson',
            'role': 'Lab Assistant',
            'specialization': 'Pathology',
            'status': 'Active',
            'joinDate': '2024-01-20',
          },
        ];
        
        _statistics = {
          'totalPatients': 1250,
          'activeStaff': _staffList.length,
          'monthlyConsultations': 485,
          'emergencyCases': 23,
          'bedOccupancy': 78,
          'regionCoverage': 85,
        };
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading RHO data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RHO Details - ${widget.rho.fullName}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Staff', icon: Icon(Icons.people)),
            Tab(text: 'Statistics', icon: Icon(Icons.analytics)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRHOData,
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingScreen() : _buildTabView(),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text('Loading RHO details...'),
        ],
      ),
    );
  }

  Widget _buildTabView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildStaffTab(),
        _buildStatisticsTab(),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRHOInfoCard(),
          const SizedBox(height: 20),
          _buildQuickStatsGrid(),
          const SizedBox(height: 20),
          _buildContactInfo(),
          const SizedBox(height: 20),
          _buildAssignmentDetails(),
        ],
      ),
    );
  }

  Widget _buildRHOInfoCard() {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    widget.rho.fullName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.rho.fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Regional Health Officer',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.rho.isActive ? AppColors.success : AppColors.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.rho.isActive ? 'Active' : 'Inactive',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsGrid() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard('Patients', '${_statistics['totalPatients']}', Icons.people, AppColors.primary),
        _buildStatCard('Staff', '${_statistics['activeStaff']}', Icons.group, AppColors.success),
        _buildStatCard('Consultations', '${_statistics['monthlyConsultations']}', Icons.medical_services, AppColors.info),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.email, 'Email', widget.rho.email),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone, 'Phone', widget.rho.phone),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.badge, 'RHO ID', widget.rho.officerId),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentDetails() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assignment Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_city, 'Assigned District', widget.rho.assignedDistrict),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, 'Assigned Region', widget.rho.assignedRegion),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_city, 'State', widget.rho.assignedState),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.confirmation_number, 'District Code', widget.rho.districtCode),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.group, 'Max Staff Limit', '${widget.rho.staffLimits['maxStaff'] ?? 'N/A'}'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_today, 'Join Date', _formatDate(widget.rho.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildStaffTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Staff Members (${_staffList.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to add staff screen
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Staff'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _staffList.length,
            itemBuilder: (context, index) {
              final staff = _staffList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(staff['status']),
                    child: Text(
                      staff['name'].substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(staff['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${staff['role']} - ${staff['specialization']}'),
                      Text('ID: ${staff['id']} | Joined: ${staff['joinDate']}'),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(staff['status']),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      staff['status'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    // TODO: Navigate to staff details
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildLargeStatCard('Emergency Cases', '${_statistics['emergencyCases']}', 'This Month', Icons.emergency, AppColors.error),
              _buildLargeStatCard('Bed Occupancy', '${_statistics['bedOccupancy']}%', 'Current', Icons.hotel, AppColors.warning),
              _buildLargeStatCard('Region Coverage', '${_statistics['regionCoverage']}%', 'Overall', Icons.map, AppColors.success),
              _buildLargeStatCard('Monthly Consults', '${_statistics['monthlyConsultations']}', 'This Month', Icons.medical_services, AppColors.info),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLargeStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'inactive':
        return AppColors.error;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
