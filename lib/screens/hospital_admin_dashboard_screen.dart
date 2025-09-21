import 'package:flutter/material.dart';
import '../services/hospital_api_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/app_branding.dart';

class HospitalAdminDashboardScreen extends StatefulWidget {
  const HospitalAdminDashboardScreen({super.key});

  @override
  _HospitalAdminDashboardScreenState createState() =>
      _HospitalAdminDashboardScreenState();
}

class _HospitalAdminDashboardScreenState
    extends State<HospitalAdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool _isLoading = false;
  Map<String, dynamic>? _dashboardData;
  List<dynamic> _doctors = [];
  List<dynamic> _assistants = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await HospitalApiService.getAdminDashboard();
      setState(() {
        _dashboardData = data['data'];
        _doctors = data['data']['doctors'] ?? [];
        _assistants = data['data']['assistants'] ?? [];
      });
    } catch (e) {
      _showError('Error loading dashboard: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // App Branding Header
          AppBranding(backgroundColor: Colors.blue[700], height: 100),

          // Content Area
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue[700]!,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading Dashboard...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDashboardTab(),
                      _buildDoctorsTab(),
                      _buildAssistantsTab(),
                    ],
                  ),
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue[700],
          labelColor: Colors.blue[700],
          unselectedLabelColor: Colors.grey[500],
          indicatorWeight: 3,
          tabs: [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.local_hospital), text: 'Doctors'),
            Tab(icon: Icon(Icons.people), text: 'Assistants'),
          ],
        ),
      ),

      // Floating Action Button for Quick Actions
      floatingActionButton: (_tabController?.index ?? 0) == 0
          ? null
          : FloatingActionButton(
              onPressed: () {
                if ((_tabController?.index ?? 0) == 1) {
                  _showAddDoctorDialog();
                } else if ((_tabController?.index ?? 0) == 2) {
                  _showAddAssistantDialog();
                }
              },
              backgroundColor: Colors.blue[700],
              child: Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  Widget _buildDashboardTab() {
    if (_dashboardData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No data available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please refresh to load dashboard data',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDashboardData,
              icon: Icon(Icons.refresh),
              label: Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    final hospital = _dashboardData!['hospital'] ?? {};
    final admin = _dashboardData!['admin'] ?? {};
    final stats = _dashboardData!['stats'] ?? {};

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Admin Info & Quick Actions Row
          Row(
            children: [
              // Welcome Card
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[600]!, Colors.blue[400]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        admin['adminName'] ?? 'Admin',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        hospital['hospitalName'] ?? 'Hospital',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 16),

              // Quick Actions
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildQuickActionCard(
                      'Refresh',
                      Icons.refresh,
                      Colors.green,
                      () => _loadDashboardData(),
                    ),
                    SizedBox(height: 12),
                    _buildQuickActionCard(
                      'Logout',
                      Icons.logout,
                      Colors.red,
                      () async {
                        await HospitalApiService.logout();
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Stats Cards
          Text(
            'Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Doctors',
                  '${stats['totalDoctors'] ?? 0}',
                  Icons.local_hospital,
                  Colors.blue,
                  Colors.blue[50]!,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total Assistants',
                  '${stats['totalAssistants'] ?? 0}',
                  Icons.people,
                  Colors.green,
                  Colors.green[50]!,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Active Doctors',
                  '${stats['activeDoctors'] ?? 0}',
                  Icons.verified_user,
                  Colors.orange,
                  Colors.orange[50]!,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Active Assistants',
                  '${stats['activeAssistants'] ?? 0}',
                  Icons.check_circle,
                  Colors.purple,
                  Colors.purple[50]!,
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Hospital Information
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.business, color: Colors.blue[700], size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Hospital Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildInfoRow('Hospital ID', hospital['hospitalId'] ?? 'N/A'),
                _buildInfoRow('Type', hospital['hospitalType'] ?? 'N/A'),
                _buildInfoRow('Contact', hospital['contactNumber'] ?? 'N/A'),
                _buildInfoRow('Email', hospital['email'] ?? 'N/A'),
                _buildInfoRow(
                  'Total Beds',
                  '${hospital['totalBeds'] ?? 'N/A'}',
                ),
                if (hospital['emergencyServices'] == true)
                  _buildInfoRow(
                    'Emergency Services',
                    'Available',
                    Colors.green,
                  ),
                if (hospital['ambulanceServices'] == true)
                  _buildInfoRow(
                    'Ambulance Services',
                    'Available',
                    Colors.green,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    Color backgroundColor,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.grey[800],
                fontWeight: valueColor != null
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsTab() {
    return Column(
      children: [
        // Header with Add Button
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.local_hospital, color: Colors.blue[700]),
              SizedBox(width: 8),
              Text(
                'Doctors Management',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Spacer(),
              ElevatedButton.icon(
                onPressed: _showAddDoctorDialog,
                icon: Icon(Icons.add, size: 18),
                label: Text('Add Doctor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Doctors List
        Expanded(
          child: _doctors.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_hospital_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No doctors found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add your first doctor to get started',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = _doctors[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: doctor['isActive']
                              ? Colors.green
                              : Colors.grey,
                          child: Icon(
                            Icons.local_hospital,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          doctor['doctorName'] ?? 'Unknown',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text('ID: ${doctor['doctorId'] ?? 'N/A'}'),
                            Text(
                              'Specialization: ${doctor['specialization'] ?? 'N/A'}',
                            ),
                            Text(
                              'Contact: ${doctor['contactNumber'] ?? 'N/A'}',
                            ),
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: doctor['isActive']
                                    ? Colors.green[100]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                doctor['isActive'] ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: doctor['isActive']
                                      ? Colors.green[700]
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'toggle_status',
                              child: Row(
                                children: [
                                  Icon(
                                    doctor['isActive']
                                        ? Icons.block
                                        : Icons.check_circle,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    doctor['isActive']
                                        ? 'Deactivate'
                                        : 'Activate',
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'view_details',
                              child: Row(
                                children: [
                                  Icon(Icons.info, size: 18),
                                  SizedBox(width: 8),
                                  Text('View Details'),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'toggle_status') {
                              _toggleDoctorStatus(
                                doctor['_id'],
                                !doctor['isActive'],
                              );
                            } else if (value == 'view_details') {
                              _showDoctorDetails(doctor);
                            }
                          },
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAssistantsTab() {
    return Column(
      children: [
        // Header with Add Button
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.people, color: Colors.green[700]),
              SizedBox(width: 8),
              Text(
                'Assistants Management',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Spacer(),
              ElevatedButton.icon(
                onPressed: _showAddAssistantDialog,
                icon: Icon(Icons.add, size: 18),
                label: Text('Add Assistant'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Assistants List
        Expanded(
          child: _assistants.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No assistants found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add your first assistant to get started',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _assistants.length,
                  itemBuilder: (context, index) {
                    final assistant = _assistants[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: assistant['isActive']
                              ? Colors.green
                              : Colors.grey,
                          child: Icon(Icons.people, color: Colors.white),
                        ),
                        title: Text(
                          assistant['assistantName'] ?? 'Unknown',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text('ID: ${assistant['assistantId'] ?? 'N/A'}'),
                            Text(
                              'Department: ${assistant['department'] ?? 'N/A'}',
                            ),
                            Text(
                              'Contact: ${assistant['contactNumber'] ?? 'N/A'}',
                            ),
                            if (assistant['assignedDoctor'] != null)
                              Text(
                                'Assigned to: ${assistant['assignedDoctor']['doctorName'] ?? 'N/A'}',
                              ),
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: assistant['isActive']
                                    ? Colors.green[100]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                assistant['isActive'] ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: assistant['isActive']
                                      ? Colors.green[700]
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'toggle_status',
                              child: Row(
                                children: [
                                  Icon(
                                    assistant['isActive']
                                        ? Icons.block
                                        : Icons.check_circle,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    assistant['isActive']
                                        ? 'Deactivate'
                                        : 'Activate',
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'view_details',
                              child: Row(
                                children: [
                                  Icon(Icons.info, size: 18),
                                  SizedBox(width: 8),
                                  Text('View Details'),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'toggle_status') {
                              _toggleAssistantStatus(
                                assistant['_id'],
                                !assistant['isActive'],
                              );
                            } else if (value == 'view_details') {
                              _showAssistantDetails(assistant);
                            }
                          },
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAddDoctorDialog() {
    showDialog(
      context: context,
      builder: (context) => AddDoctorDialog(
        onDoctorAdded: () {
          _loadDashboardData(); // Refresh data
        },
      ),
    );
  }

  void _showAddAssistantDialog() {
    showDialog(
      context: context,
      builder: (context) => AddAssistantDialog(
        doctors: _doctors,
        onAssistantAdded: () {
          _loadDashboardData(); // Refresh data
        },
      ),
    );
  }

  void _showDoctorDetails(Map<String, dynamic> doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Doctor Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Name', doctor['doctorName']),
              _buildDetailRow('ID', doctor['doctorId']),
              _buildDetailRow('Username', doctor['username']),
              _buildDetailRow('Email', doctor['email']),
              _buildDetailRow('Contact', doctor['contactNumber']),
              _buildDetailRow('Specialization', doctor['specialization']),
              _buildDetailRow('License Number', doctor['licenseNumber']),
              _buildDetailRow('Qualification', doctor['qualification']),
              _buildDetailRow(
                'Experience',
                '${doctor['experienceYears'] ?? 0} years',
              ),
              _buildDetailRow(
                'Status',
                doctor['isActive'] ? 'Active' : 'Inactive',
              ),
              _buildDetailRow('Created', doctor['createdAt'] ?? 'N/A'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAssistantDetails(Map<String, dynamic> assistant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assistant Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Name', assistant['assistantName']),
              _buildDetailRow('ID', assistant['assistantId']),
              _buildDetailRow('Username', assistant['username']),
              _buildDetailRow('Email', assistant['email']),
              _buildDetailRow('Contact', assistant['contactNumber']),
              _buildDetailRow('Department', assistant['department']),
              _buildDetailRow('Qualification', assistant['qualification']),
              _buildDetailRow(
                'Experience',
                '${assistant['experienceYears'] ?? 0} years',
              ),
              if (assistant['assignedDoctor'] != null)
                _buildDetailRow(
                  'Assigned Doctor',
                  assistant['assignedDoctor']['doctorName'],
                ),
              _buildDetailRow(
                'Status',
                assistant['isActive'] ? 'Active' : 'Inactive',
              ),
              _buildDetailRow('Created', assistant['createdAt'] ?? 'N/A'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value?.toString() ?? 'N/A')),
        ],
      ),
    );
  }

  Future<void> _toggleDoctorStatus(String doctorId, bool newStatus) async {
    try {
      await HospitalApiService.toggleDoctorStatus(doctorId, newStatus);
      _loadDashboardData(); // Refresh data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Doctor status updated successfully')),
      );
    } catch (e) {
      _showError('Error updating doctor status: $e');
    }
  }

  Future<void> _toggleAssistantStatus(
    String assistantId,
    bool newStatus,
  ) async {
    try {
      await HospitalApiService.toggleAssistantStatus(assistantId, newStatus);
      _loadDashboardData(); // Refresh data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Assistant status updated successfully')),
      );
    } catch (e) {
      _showError('Error updating assistant status: $e');
    }
  }
}

class AddDoctorDialog extends StatefulWidget {
  final VoidCallback onDoctorAdded;

  const AddDoctorDialog({super.key, required this.onDoctorAdded});

  @override
  _AddDoctorDialogState createState() => _AddDoctorDialogState();
}

class _AddDoctorDialogState extends State<AddDoctorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _doctorNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _specializationController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _experienceYearsController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _doctorNameController.dispose();
    _emailController.dispose();
    _contactNumberController.dispose();
    _specializationController.dispose();
    _licenseNumberController.dispose();
    _qualificationController.dispose();
    _experienceYearsController.dispose();
    super.dispose();
  }

  Future<void> _addDoctor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final doctorData = {
        'username': _usernameController.text.trim(),
        'password': _passwordController.text,
        'doctorName': _doctorNameController.text.trim(),
        'email': _emailController.text.trim(),
        'contactNumber': _contactNumberController.text.trim(),
        'specialization': _specializationController.text.trim(),
        'licenseNumber': _licenseNumberController.text.trim(),
        'qualification': _qualificationController.text.trim(),
        'experienceYears': int.tryParse(_experienceYearsController.text) ?? 0,
      };

      await HospitalApiService.createDoctor(doctorData);
      Navigator.pop(context);
      widget.onDoctorAdded();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Doctor added successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding doctor: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Doctor'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _doctorNameController,
                labelText: 'Doctor Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter doctor name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _usernameController,
                labelText: 'Username',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                labelText: 'Password',
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _contactNumberController,
                labelText: 'Contact Number',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _specializationController,
                labelText: 'Specialization',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter specialization';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _licenseNumberController,
                labelText: 'License Number',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter license number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _qualificationController,
                labelText: 'Qualification',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter qualification';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _experienceYearsController,
                labelText: 'Experience (Years)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final years = int.tryParse(value);
                    if (years == null || years < 0) {
                      return 'Please enter a valid number';
                    }
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addDoctor,
          child: _isLoading
              ? CircularProgressIndicator(strokeWidth: 2)
              : Text('Add Doctor'),
        ),
      ],
    );
  }
}

class AddAssistantDialog extends StatefulWidget {
  final List<dynamic> doctors;
  final VoidCallback onAssistantAdded;

  const AddAssistantDialog({
    super.key,
    required this.doctors,
    required this.onAssistantAdded,
  });

  @override
  _AddAssistantDialogState createState() => _AddAssistantDialogState();
}

class _AddAssistantDialogState extends State<AddAssistantDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _assistantNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _departmentController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _experienceYearsController = TextEditingController();
  String? _selectedDoctorId;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _assistantNameController.dispose();
    _emailController.dispose();
    _contactNumberController.dispose();
    _departmentController.dispose();
    _qualificationController.dispose();
    _experienceYearsController.dispose();
    super.dispose();
  }

  Future<void> _addAssistant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final assistantData = {
        'username': _usernameController.text.trim(),
        'password': _passwordController.text,
        'assistantName': _assistantNameController.text.trim(),
        'email': _emailController.text.trim(),
        'contactNumber': _contactNumberController.text.trim(),
        'department': _departmentController.text.trim(),
        'qualification': _qualificationController.text.trim(),
        'experienceYears': int.tryParse(_experienceYearsController.text) ?? 0,
        if (_selectedDoctorId != null) 'assignedDoctor': _selectedDoctorId,
      };

      await HospitalApiService.createAssistant(assistantData);
      Navigator.pop(context);
      widget.onAssistantAdded();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Assistant added successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding assistant: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Assistant'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _assistantNameController,
                labelText: 'Assistant Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter assistant name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _usernameController,
                labelText: 'Username',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                labelText: 'Password',
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _contactNumberController,
                labelText: 'Contact Number',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _departmentController,
                labelText: 'Department',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter department';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _qualificationController,
                labelText: 'Qualification',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter qualification';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _experienceYearsController,
                labelText: 'Experience (Years)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final years = int.tryParse(value);
                    if (years == null || years < 0) {
                      return 'Please enter a valid number';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDoctorId,
                decoration: InputDecoration(
                  labelText: 'Assign to Doctor (Optional)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text('No Assignment'),
                  ),
                  ...widget.doctors.map((doctor) {
                    return DropdownMenuItem<String>(
                      value: doctor['_id'],
                      child: Text(
                        '${doctor['doctorName']} - ${doctor['specialization']}',
                      ),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDoctorId = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addAssistant,
          child: _isLoading
              ? CircularProgressIndicator(strokeWidth: 2)
              : Text('Add Assistant'),
        ),
      ],
    );
  }
}
