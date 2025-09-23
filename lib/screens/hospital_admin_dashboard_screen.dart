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
  final _doctorNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _experienceYearsController = TextEditingController();
  final _consultationFeeController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;
  List<String> _selectedSpecializations = [];
  String? _selectedDepartment;
  String? _selectedAvailableTimings;
  
  bool _isLoading = false;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  
  final List<String> _specializationOptions = [
    'Cardiology',
    'Neurology', 
    'Pediatrics',
    'Orthopedics',
    'General Medicine',
    'Dermatology',
    'Psychiatry',
    'Gynecology',
    'Surgery',
    'Radiology'
  ];

  final Map<String, String> _departmentMapping = {
    'Cardiology': 'Cardiology Department',
    'Neurology': 'Neurology Department',
    'Pediatrics': 'Pediatrics Department',
    'Orthopedics': 'Orthopedics Department',
    'General Medicine': 'General Medicine Department',
    'Dermatology': 'Dermatology Department',
    'Psychiatry': 'Psychiatry Department',
    'Gynecology': 'Gynecology Department',
    'Surgery': 'Surgery Department',
    'Radiology': 'Radiology Department'
  };

  final List<String> _timingOptions = [
    '9:00 AM - 5:00 PM',
    '10:00 AM - 6:00 PM',
    '11:00 AM - 7:00 PM',
    '2:00 PM - 10:00 PM',
    '6:00 PM - 2:00 AM',
    '24/7 Emergency'
  ];

  @override
  void dispose() {
    _doctorNameController.dispose();
    _emailController.dispose();
    _contactNumberController.dispose();
    _qualificationController.dispose();
    _experienceYearsController.dispose();
    _consultationFeeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _generateDoctorId(String hospitalId, String doctorName) {
    // Generate Doctor ID = <HospitalID> + first 4 letters of Doctor Name (uppercase)
    final namePrefix = doctorName.replaceAll(' ', '').toUpperCase();
    final prefix = namePrefix.length >= 4 ? namePrefix.substring(0, 4) : namePrefix.padRight(4, 'X');
    return '$hospitalId$prefix';
  }

  Future<void> _addDoctor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get hospital ID from stored data (you may need to adjust this based on your auth system)
      final hospitalId = 'H001'; // This should come from your auth/storage system
      
      final doctorId = _generateDoctorId(hospitalId, _doctorNameController.text.trim());
      
      final doctorData = {
        'doctorId': doctorId,
        'username': doctorId, // Username = Doctor ID
        'password': _passwordController.text, // Store as plain text as requested
        'doctorName': _doctorNameController.text.trim(),
        'gender': _selectedGender,
        'dateOfBirth': _selectedDateOfBirth?.toIso8601String(),
        'specializations': _selectedSpecializations,
        'department': _selectedDepartment ?? _departmentMapping[_selectedSpecializations.first],
        'email': _emailController.text.trim(),
        'contactNumber': _contactNumberController.text.trim(),
        'qualification': _qualificationController.text.trim(),
        'experienceYears': int.tryParse(_experienceYearsController.text) ?? 0,
        'availableTimings': _selectedAvailableTimings,
        'consultationFee': int.tryParse(_consultationFeeController.text) ?? 0,
        'hospitalId': hospitalId,
      };

      await HospitalApiService.createDoctor(doctorData);
      
      // Show success popup with credentials
      _showSuccessDialog(doctorId, _passwordController.text);
      
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

  void _showSuccessDialog(String username, String password) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Doctor Created Successfully'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Doctor has been added successfully!', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Login Credentials:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Username: $username', style: TextStyle(fontFamily: 'monospace')),
                  Text('Password: $password', style: TextStyle(fontFamily: 'monospace')),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text('Please save these credentials securely.', 
                 style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.w500)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close success dialog
              Navigator.pop(context); // Close add doctor dialog
              widget.onDoctorAdded(); // Refresh the dashboard
            },
            child: Text('OK'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Doctor'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name field
                _buildFieldWithCriteria(
                  child: CustomTextField(
                    controller: _doctorNameController,
                    labelText: 'Name *',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter doctor name';
                      }
                      if (value.length < 3 || value.length > 50) {
                        return 'Name must be 3-50 characters';
                      }
                      return null;
                    },
                  ),
                  criteria: 'Min 3, max 50 characters',
                ),
                
                SizedBox(height: 16),
                
                // Gender dropdown
                _buildFieldWithCriteria(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: InputDecoration(
                      labelText: 'Gender *',
                      border: OutlineInputBorder(),
                    ),
                    items: _genderOptions.map((gender) {
                      return DropdownMenuItem(value: gender, child: Text(gender));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedGender = value),
                    validator: (value) => value == null ? 'Please select gender' : null,
                  ),
                  criteria: 'Required selection',
                ),
                
                SizedBox(height: 16),
                
                // Date of Birth
                _buildFieldWithCriteria(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime(1990),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now().subtract(Duration(days: 365 * 18)),
                      );
                      if (date != null) {
                        setState(() => _selectedDateOfBirth = date);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDateOfBirth == null
                                ? 'Date of Birth *'
                                : '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}',
                            style: TextStyle(
                              color: _selectedDateOfBirth == null ? Colors.grey[600] : Colors.black,
                            ),
                          ),
                          Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                  criteria: 'Must be valid past date (18+ years)',
                ),
                
                SizedBox(height: 16),
                
                // Specializations (multi-select)
                _buildFieldWithCriteria(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Specializations * (Max 5)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _specializationOptions.map((spec) {
                          final isSelected = _selectedSpecializations.contains(spec);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedSpecializations.remove(spec);
                                } else if (_selectedSpecializations.length < 5) {
                                  _selectedSpecializations.add(spec);
                                  // Auto-fill department
                                  if (_selectedDepartment == null) {
                                    _selectedDepartment = _departmentMapping[spec];
                                  }
                                }
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blue[100] : Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? Colors.blue : Colors.grey,
                                ),
                              ),
                              child: Text(
                                spec,
                                style: TextStyle(
                                  color: isSelected ? Colors.blue[800] : Colors.black,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (_selectedSpecializations.isEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text('Please select at least one specialization', 
                               style: TextStyle(color: Colors.red, fontSize: 12)),
                        ),
                    ],
                  ),
                  criteria: 'Select 1-5 specializations',
                ),
                
                SizedBox(height: 16),
                
                // Department (auto-filled)
                _buildFieldWithCriteria(
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Department',
                      border: OutlineInputBorder(),
                      fillColor: Colors.grey[100],
                      filled: true,
                    ),
                    controller: TextEditingController(text: _selectedDepartment ?? ''),
                  ),
                  criteria: 'Auto-filled based on specialization',
                ),
                
                SizedBox(height: 16),
                
                // Contact Number
                _buildFieldWithCriteria(
                  child: CustomTextField(
                    controller: _contactNumberController,
                    labelText: 'Contact Number *',
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter contact number';
                      }
                      if (value.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'Enter exactly 10 digits';
                      }
                      return null;
                    },
                  ),
                  criteria: 'Exactly 10 digits',
                ),
                
                SizedBox(height: 16),
                
                // Email
                _buildFieldWithCriteria(
                  child: CustomTextField(
                    controller: _emailController,
                    labelText: 'Email *',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Enter valid email format';
                      }
                      return null;
                    },
                  ),
                  criteria: 'Valid email format required',
                ),
                
                SizedBox(height: 16),
                
                // Qualification
                _buildFieldWithCriteria(
                  child: CustomTextField(
                    controller: _qualificationController,
                    labelText: 'Qualification *',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter qualification';
                      }
                      if (value.length < 2 || value.length > 30) {
                        return 'Qualification must be 2-30 characters';
                      }
                      return null;
                    },
                  ),
                  criteria: 'Min 2, max 30 characters',
                ),
                
                SizedBox(height: 16),
                
                // Experience
                _buildFieldWithCriteria(
                  child: CustomTextField(
                    controller: _experienceYearsController,
                    labelText: 'Experience (Years)',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final years = int.tryParse(value);
                        if (years == null || years < 0 || years > 50) {
                          return 'Experience must be 0-50 years';
                        }
                        // Check if experience is reasonable compared to age
                        if (_selectedDateOfBirth != null) {
                          final age = DateTime.now().year - _selectedDateOfBirth!.year;
                          if (years > (age - 22)) { // Assuming minimum 22 years to complete medical education
                            return 'Experience cannot exceed ${age - 22} years';
                          }
                        }
                      }
                      return null;
                    },
                  ),
                  criteria: 'Optional, max 50 years, should be less than age',
                ),
                
                SizedBox(height: 16),
                
                // Available Timings
                _buildFieldWithCriteria(
                  child: DropdownButtonFormField<String>(
                    value: _selectedAvailableTimings,
                    decoration: InputDecoration(
                      labelText: 'Available Timings',
                      border: OutlineInputBorder(),
                    ),
                    items: _timingOptions.map((timing) {
                      return DropdownMenuItem(value: timing, child: Text(timing));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedAvailableTimings = value),
                  ),
                  criteria: 'Select from available options',
                ),
                
                SizedBox(height: 16),
                
                // Consultation Fee
                _buildFieldWithCriteria(
                  child: CustomTextField(
                    controller: _consultationFeeController,
                    labelText: 'Consultation Fee (₹)',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final fee = int.tryParse(value);
                        if (fee == null || fee < 0 || value.length > 5) {
                          return 'Enter valid fee (max 5 digits)';
                        }
                      }
                      return null;
                    },
                  ),
                  criteria: 'Optional, max 5 digits',
                ),
                
                SizedBox(height: 16),
                
                // Password
                _buildFieldWithCriteria(
                  child: CustomTextField(
                    controller: _passwordController,
                    labelText: 'Password *',
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
                  criteria: 'Minimum 6 characters',
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _canSubmit() ? _addDoctor : null,
          child: _isLoading
              ? CircularProgressIndicator(strokeWidth: 2)
              : Text('Add Doctor'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldWithCriteria({required Widget child, required String criteria}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        child,
        SizedBox(height: 4),
        Text(
          criteria,
          style: TextStyle(
            fontSize: 12,
            color: Colors.blue[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  bool _canSubmit() {
    return _doctorNameController.text.trim().isNotEmpty &&
           _selectedGender != null &&
           _selectedDateOfBirth != null &&
           _selectedSpecializations.isNotEmpty &&
           _contactNumberController.text.trim().isNotEmpty &&
           _emailController.text.trim().isNotEmpty &&
           _qualificationController.text.trim().isNotEmpty &&
           _passwordController.text.trim().isNotEmpty;
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
