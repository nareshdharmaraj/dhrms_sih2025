import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/app_branding.dart';

class HospitalDoctorDashboardScreen extends StatefulWidget {
  @override
  _HospitalDoctorDashboardScreenState createState() => _HospitalDoctorDashboardScreenState();
}

class _HospitalDoctorDashboardScreenState extends State<HospitalDoctorDashboardScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool _isLoading = false;
  Map<String, dynamic>? _doctorData;
  List<dynamic> _patients = [];
  List<dynamic> _appointments = [];
  List<dynamic> _todayAppointments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDoctorData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadDoctorData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await ApiService.getAuthToken();
      
      // Load doctor dashboard data
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/hospital/doctor/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _doctorData = data['data'];
          _patients = data['data']['patients'] ?? [];
          _appointments = data['data']['appointments'] ?? [];
          _todayAppointments = data['data']['todayAppointments'] ?? [];
        });
      } else {
        _showError('Failed to load doctor data');
      }
    } catch (e) {
      _showError('Error loading doctor dashboard: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // App Branding Header
          AppBranding(
            backgroundColor: Colors.green[700],
            height: 100,
          ),
          
          // Content Area
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading Doctor Dashboard...',
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
                      _buildPatientsTab(),
                      _buildAppointmentsTab(),
                      _buildProfileTab(),
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
          indicatorColor: Colors.green[700],
          labelColor: Colors.green[700],
          unselectedLabelColor: Colors.grey[500],
          indicatorWeight: 3,
          tabs: [
            Tab(
              icon: Icon(Icons.dashboard),
              text: 'Dashboard',
            ),
            Tab(
              icon: Icon(Icons.people),
              text: 'Patients',
            ),
            Tab(
              icon: Icon(Icons.calendar_today),
              text: 'Appointments',
            ),
            Tab(
              icon: Icon(Icons.person),
              text: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    if (_doctorData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
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
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDoctorData,
              icon: Icon(Icons.refresh),
              label: Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    final doctor = _doctorData!['doctor'] ?? {};
    final hospital = _doctorData!['hospital'] ?? {};
    final stats = _doctorData!['stats'] ?? {};

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor Info & Quick Actions Row
          Row(
            children: [
              // Welcome Card
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[600]!, Colors.green[400]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, Dr.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        doctor['doctorName'] ?? 'Doctor',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        doctor['specialization'] ?? 'Specialist',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        hospital['hospitalName'] ?? 'Hospital',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
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
                      Colors.blue,
                      () => _loadDoctorData(),
                    ),
                    SizedBox(height: 12),
                    _buildQuickActionCard(
                      'Logout',
                      Icons.logout,
                      Colors.red,
                      () async {
                        await ApiService.clearAuthToken();
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Today's Overview
          Text(
            "Today's Overview",
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
                  'Today\'s Appointments',
                  '${_todayAppointments.length}',
                  Icons.calendar_today,
                  Colors.blue,
                  Colors.blue[50]!,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total Patients',
                  '${stats['totalPatients'] ?? 0}',
                  Icons.people,
                  Colors.purple,
                  Colors.purple[50]!,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Pending Appointments',
                  '${stats['pendingAppointments'] ?? 0}',
                  Icons.schedule,
                  Colors.orange,
                  Colors.orange[50]!,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Completed Today',
                  '${stats['completedToday'] ?? 0}',
                  Icons.check_circle,
                  Colors.green,
                  Colors.green[50]!,
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Today's Appointments
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
                    Icon(
                      Icons.today,
                      color: Colors.green[700],
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Today\'s Appointments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                if (_todayAppointments.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No appointments for today',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                else
                  ...(_todayAppointments.take(3).map((appointment) => 
                    _buildAppointmentCard(appointment)
                  ).toList()),
                if (_todayAppointments.length > 3)
                  TextButton(
                    onPressed: () {
                      _tabController?.animateTo(2); // Go to appointments tab
                    },
                    child: Text('View all appointments'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color, Color backgroundColor) {
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

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.green[100],
            child: Icon(Icons.person, color: Colors.green[700]),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment['patientName'] ?? 'Unknown Patient',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Time: ${appointment['appointmentTime'] ?? 'Not specified'}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (appointment['reason'] != null)
                  Text(
                    'Reason: ${appointment['reason']}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(appointment['status']),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              appointment['status'] ?? 'Pending',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'confirmed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _buildPatientsTab() {
    return Column(
      children: [
        // Header
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
                'My Patients',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Spacer(),
              IconButton(
                onPressed: _loadDoctorData,
                icon: Icon(Icons.refresh, color: Colors.green[700]),
              ),
            ],
          ),
        ),

        // Patients List
        Expanded(
          child: _patients.isEmpty
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
                        'No patients found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Patients will appear here when assigned',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _patients.length,
                  itemBuilder: (context, index) {
                    final patient = _patients[index];
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
                          backgroundColor: Colors.green[100],
                          child: Icon(Icons.person, color: Colors.green[700]),
                        ),
                        title: Text(
                          patient['patientName'] ?? 'Unknown Patient',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text('UHID: ${patient['uhid'] ?? 'N/A'}'),
                            Text('Age: ${patient['age'] ?? 'N/A'} | Gender: ${patient['gender'] ?? 'N/A'}'),
                            Text('Contact: ${patient['contactNumber'] ?? 'N/A'}'),
                            if (patient['lastVisit'] != null)
                              Text('Last Visit: ${patient['lastVisit']}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.medical_information, color: Colors.green[700]),
                          onPressed: () => _showPatientDetails(patient),
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

  Widget _buildAppointmentsTab() {
    return Column(
      children: [
        // Header
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
              Icon(Icons.calendar_today, color: Colors.green[700]),
              SizedBox(width: 8),
              Text(
                'Appointments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Spacer(),
              IconButton(
                onPressed: _loadDoctorData,
                icon: Icon(Icons.refresh, color: Colors.green[700]),
              ),
            ],
          ),
        ),

        // Appointments List
        Expanded(
          child: _appointments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No appointments found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Appointments will appear here when scheduled',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = _appointments[index];
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
                          backgroundColor: _getStatusColor(appointment['status']).withOpacity(0.2),
                          child: Icon(
                            Icons.calendar_today, 
                            color: _getStatusColor(appointment['status']),
                          ),
                        ),
                        title: Text(
                          appointment['patientName'] ?? 'Unknown Patient',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text('Date: ${appointment['appointmentDate'] ?? 'Not specified'}'),
                            Text('Time: ${appointment['appointmentTime'] ?? 'Not specified'}'),
                            if (appointment['reason'] != null)
                              Text('Reason: ${appointment['reason']}'),
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getStatusColor(appointment['status']).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                appointment['status'] ?? 'Pending',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(appointment['status']),
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility, size: 18),
                                  SizedBox(width: 8),
                                  Text('View Details'),
                                ],
                              ),
                            ),
                            if (appointment['status'] == 'pending')
                              PopupMenuItem(
                                value: 'confirm',
                                child: Row(
                                  children: [
                                    Icon(Icons.check, size: 18),
                                    SizedBox(width: 8),
                                    Text('Confirm'),
                                  ],
                                ),
                              ),
                            if (appointment['status'] != 'completed')
                              PopupMenuItem(
                                value: 'complete',
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, size: 18),
                                    SizedBox(width: 8),
                                    Text('Mark Complete'),
                                  ],
                                ),
                              ),
                          ],
                          onSelected: (value) {
                            if (value == 'view') {
                              _showAppointmentDetails(appointment);
                            } else if (value == 'confirm') {
                              _updateAppointmentStatus(appointment['_id'], 'confirmed');
                            } else if (value == 'complete') {
                              _updateAppointmentStatus(appointment['_id'], 'completed');
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

  Widget _buildProfileTab() {
    if (_doctorData == null) {
      return Center(child: CircularProgressIndicator());
    }

    final doctor = _doctorData!['doctor'] ?? {};
    final hospital = _doctorData!['hospital'] ?? {};

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[600]!, Colors.green[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.local_hospital,
                    size: 50,
                    color: Colors.green[700],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Dr. ${doctor['doctorName'] ?? 'Doctor'}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  doctor['specialization'] ?? 'Specialist',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    doctor['isActive'] ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Professional Information
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
                Text(
                  'Professional Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 16),
                _buildProfileRow('Doctor ID', doctor['doctorId']),
                _buildProfileRow('License Number', doctor['licenseNumber']),
                _buildProfileRow('Qualification', doctor['qualification']),
                _buildProfileRow('Experience', '${doctor['experienceYears'] ?? 0} years'),
                _buildProfileRow('Department', doctor['department']),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Contact Information
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
                Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 16),
                _buildProfileRow('Email', doctor['email']),
                _buildProfileRow('Phone', doctor['contactNumber']),
                _buildProfileRow('Username', doctor['username']),
              ],
            ),
          ),

          SizedBox(height: 16),

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
                Text(
                  'Hospital Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 16),
                _buildProfileRow('Hospital', hospital['hospitalName']),
                _buildProfileRow('Hospital ID', hospital['hospitalId']),
                _buildProfileRow('Type', hospital['hospitalType']),
                _buildProfileRow('Contact', hospital['contactNumber']),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await ApiService.clearAuthToken();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              icon: Icon(Icons.logout),
              label: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label + ':',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: TextStyle(
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPatientDetails(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Patient Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Name', patient['patientName']),
              _buildDetailRow('UHID', patient['uhid']),
              _buildDetailRow('Age', patient['age']),
              _buildDetailRow('Gender', patient['gender']),
              _buildDetailRow('Contact', patient['contactNumber']),
              _buildDetailRow('Email', patient['email']),
              _buildDetailRow('Address', patient['address']),
              _buildDetailRow('Blood Group', patient['bloodGroup']),
              _buildDetailRow('Emergency Contact', patient['emergencyContact']),
              if (patient['medicalHistory'] != null)
                _buildDetailRow('Medical History', patient['medicalHistory']),
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

  void _showAppointmentDetails(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Appointment Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Patient', appointment['patientName']),
              _buildDetailRow('Date', appointment['appointmentDate']),
              _buildDetailRow('Time', appointment['appointmentTime']),
              _buildDetailRow('Status', appointment['status']),
              _buildDetailRow('Reason', appointment['reason']),
              _buildDetailRow('Notes', appointment['notes']),
              _buildDetailRow('Type', appointment['appointmentType']),
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
              label + ':',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value?.toString() ?? 'N/A')),
        ],
      ),
    );
  }

  Future<void> _updateAppointmentStatus(String appointmentId, String status) async {
    try {
      final token = await ApiService.getAuthToken();
      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/hospital/doctor/appointment/$appointmentId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        _loadDoctorData(); // Refresh data
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment status updated successfully')),
        );
      } else {
        _showError('Failed to update appointment status');
      }
    } catch (e) {
      _showError('Error updating appointment status: $e');
    }
  }
}