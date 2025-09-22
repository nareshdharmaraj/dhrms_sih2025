import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/app_constants.dart';

class HospitalStaffDashboard extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HospitalStaffDashboard({super.key, required this.userData});

  @override
  _HospitalStaffDashboardState createState() => _HospitalStaffDashboardState();
}

class _HospitalStaffDashboardState extends State<HospitalStaffDashboard>
    with SingleTickerProviderStateMixin {
  List<dynamic> patients = [];
  List<dynamic> appointments = [];
  List<dynamic> medicalRecords = [];
  bool isLoading = true;
  String? error;
  Map<String, dynamic> userData = {};

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize userData with widget data
    userData = Map<String, dynamic>.from(widget.userData);

    print('🔄 HospitalStaffDashboard initState');
    print('📋 UserData received: ${widget.userData}');

    // If userData is empty, try to load from SharedPreferences
    if (widget.userData.isEmpty) {
      print('⚠️ UserData is empty, trying to load from SharedPreferences');
      _loadUserDataFromPrefs();
    } else {
      loadStaffData();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserDataFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final doctorDataString = prefs.getString('doctor_data');

      if (doctorDataString != null) {
        final doctorData = json.decode(doctorDataString);
        print('🔄 Loaded doctor data from SharedPreferences: $doctorData');

        // Update the userData to use this data
        userData = Map<String, dynamic>.from(doctorData);
        loadStaffData();
      } else {
        print('❌ No doctor data found in SharedPreferences');
        setState(() {
          error = 'No user data available. Please login again.';
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading user data from SharedPreferences: $e');
      setState(() {
        error = 'Failed to load user data. Please login again.';
        isLoading = false;
      });
    }
  }

  Future<void> loadStaffData() async {
    try {
      setState(() => isLoading = true);

      // Use userData if available, otherwise fall back to widget.userData
      final currentUserData = userData.isNotEmpty ? userData : widget.userData;
      print('🔍 Loading staff data for user: $currentUserData');

      // Safely get the staff ID
      final staffId =
          currentUserData['_id'] ??
          currentUserData['doctorId'] ??
          currentUserData['assistantId'];
      print('📋 Using staff ID: $staffId');

      if (staffId == null) {
        throw Exception('No valid staff ID found in user data');
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // Load patients from the hospital/department
      try {
        final patientsResponse = await http.get(
          Uri.parse('${AppConstants.baseUrl}/patients'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        );

        print('👥 Patients response status: ${patientsResponse.statusCode}');

        if (patientsResponse.statusCode == 200) {
          final patientsData = json.decode(patientsResponse.body);
          if (patientsData is List) {
            patients = patientsData;
          } else {
            print(
              '⚠️ Patients response is not a list: ${patientsData.runtimeType}',
            );
            patients = [];
          }
        } else {
          print('❌ Failed to load patients: ${patientsResponse.body}');
          patients = [];
        }
      } catch (e) {
        print('❌ Error loading patients: $e');
        patients = [];
      }

      // Load appointments for this staff member
      try {
        final appointmentsResponse = await http.get(
          Uri.parse('${AppConstants.baseUrl}/appointments/staff/$staffId'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        );

        print(
          '📅 Appointments response status: ${appointmentsResponse.statusCode}',
        );

        if (appointmentsResponse.statusCode == 200) {
          final appointmentsData = json.decode(appointmentsResponse.body);
          if (appointmentsData is List) {
            appointments = appointmentsData;
          } else {
            print(
              '⚠️ Appointments response is not a list: ${appointmentsData.runtimeType}',
            );
            appointments = [];
          }
        } else {
          print('❌ Failed to load appointments: ${appointmentsResponse.body}');
          appointments = [];
        }
      } catch (e) {
        print('❌ Error loading appointments: $e');
        appointments = [];
      }

      // Load medical records for this staff member's patients
      try {
        final recordsResponse = await http.get(
          Uri.parse('${AppConstants.baseUrl}/medical-records/staff/$staffId'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        );

        print(
          '🏥 Medical records response status: ${recordsResponse.statusCode}',
        );

        if (recordsResponse.statusCode == 200) {
          final recordsData = json.decode(recordsResponse.body);
          if (recordsData is List) {
            medicalRecords = recordsData;
          } else {
            print(
              '⚠️ Medical records response is not a list: ${recordsData.runtimeType}',
            );
            medicalRecords = [];
          }
        } else {
          print('❌ Failed to load medical records: ${recordsResponse.body}');
          medicalRecords = [];
        }
      } catch (e) {
        print('❌ Error loading medical records: $e');
        medicalRecords = [];
      }

      setState(() => isLoading = false);
      print('✅ Staff data loading completed');
    } catch (e) {
      print('💥 Critical error loading staff data: $e');
      setState(() {
        error = 'Failed to load staff data: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // App Header with Branding
          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade700, Colors.blue.shade500],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // App Branding
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.health_and_safety,
                          color: Colors.blue.shade700,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'My Health',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.logout, color: Colors.white),
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/login'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Doctor Profile Section
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white,
                        child: Text(
                          _getInitials(
                            userData['doctorName'] ??
                                userData['name'] ??
                                'Doctor',
                          ),
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData['doctorName'] ??
                                  userData['name'] ??
                                  'Doctor',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${userData['specialization'] ?? 'General'} • ${userData['designation'] ?? 'Doctor'}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              userData['hospitalName'] ?? 'Hospital',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
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
          ),

          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
                Tab(icon: Icon(Icons.calendar_today), text: 'Appointments'),
                Tab(icon: Icon(Icons.medical_services), text: 'Patients'),
              ],
              labelColor: Colors.blue.shade700,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue.shade700,
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(),
                _buildAppointmentsTab(),
                _buildPatientsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    List<String> names = name.split(' ');
    String initials = '';
    for (int i = 0; i < names.length && i < 2; i++) {
      if (names[i].isNotEmpty) {
        initials += names[i][0].toUpperCase();
      }
    }
    return initials;
  }

  Widget _buildDashboardTab() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(error!, style: TextStyle(color: Colors.red)),
            ElevatedButton(onPressed: loadStaffData, child: Text('Retry')),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickStats(),
          SizedBox(height: 20),
          _buildTodaySchedule(),
          SizedBox(height: 20),
          _buildRecentPatients(),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appointments (Current & Next Week)',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          SizedBox(height: 16),
          _buildAppointmentsList(),
        ],
      ),
    );
  }

  Widget _buildPatientsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Patients',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          SizedBox(height: 16),
          _buildPatientsList(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Today\'s Appointments',
                    appointments.length.toString(),
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total Patients',
                    patients.length.toString(),
                    Icons.people,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Medical Records',
                    medicalRecords.length.toString(),
                    Icons.medical_services,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySchedule() {
    final today = DateTime.now();
    final todayAppointments = appointments.where((apt) {
      try {
        final aptDate = DateTime.parse(apt['appointmentDate'] ?? '');
        return aptDate.year == today.year &&
            aptDate.month == today.month &&
            aptDate.day == today.day;
      } catch (e) {
        return false;
      }
    }).toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Schedule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            SizedBox(height: 16),
            if (todayAppointments.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No appointments for today',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...todayAppointments
                  .take(3)
                  .map((apt) => _buildAppointmentItem(apt)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPatients() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Patients',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            SizedBox(height: 16),
            if (patients.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No patients found',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...patients.take(3).map((patient) => _buildPatientItem(patient)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    final now = DateTime.now();
    final oneWeekLater = now.add(Duration(days: 7));

    final filteredAppointments = appointments.where((apt) {
      try {
        final aptDate = DateTime.parse(apt['appointmentDate'] ?? '');
        return aptDate.isAfter(now.subtract(Duration(days: 1))) &&
            aptDate.isBefore(oneWeekLater);
      } catch (e) {
        return false;
      }
    }).toList();

    if (filteredAppointments.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.calendar_today, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No upcoming appointments',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: filteredAppointments.length,
      itemBuilder: (context, index) {
        return _buildAppointmentCard(filteredAppointments[index]);
      },
    );
  }

  Widget _buildPatientsList() {
    if (patients.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.people, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No patients found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: patients.length,
      itemBuilder: (context, index) {
        return _buildPatientCard(patients[index]);
      },
    );
  }

  Widget _buildAppointmentItem(Map<String, dynamic> appointment) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: Icon(Icons.person, color: Colors.blue.shade700),
      ),
      title: Text(appointment['patientName'] ?? 'Unknown Patient'),
      subtitle: Text(
        '${appointment['appointmentTime'] ?? 'No time'} - ${appointment['reason'] ?? 'No reason'}',
      ),
      trailing: Chip(
        label: Text(
          appointment['status'] ?? 'pending',
          style: TextStyle(fontSize: 10),
        ),
        backgroundColor: _getStatusColor(appointment['status'] ?? 'pending'),
      ),
    );
  }

  Widget _buildPatientItem(Map<String, dynamic> patient) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.green.shade100,
        child: Text(
          _getInitials(patient['name'] ?? 'Unknown'),
          style: TextStyle(color: Colors.green.shade700),
        ),
      ),
      title: Text(patient['name'] ?? 'Unknown Patient'),
      subtitle: Text('UHID: ${patient['uhid'] ?? 'N/A'}'),
      trailing: Text(
        '${patient['age'] ?? 'N/A'} yrs',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(Icons.person, color: Colors.blue.shade700),
        ),
        title: Text(appointment['patientName'] ?? 'Unknown Patient'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${appointment['appointmentDate'] ?? 'No date'}'),
            Text('Time: ${appointment['appointmentTime'] ?? 'No time'}'),
            Text('Reason: ${appointment['reason'] ?? 'No reason'}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Chip(
              label: Text(
                appointment['status'] ?? 'pending',
                style: TextStyle(fontSize: 10),
              ),
              backgroundColor: _getStatusColor(
                appointment['status'] ?? 'pending',
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Text(
            _getInitials(patient['name'] ?? 'Unknown'),
            style: TextStyle(color: Colors.green.shade700),
          ),
        ),
        title: Text(patient['name'] ?? 'Unknown Patient'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('UHID: ${patient['uhid'] ?? 'N/A'}'),
            Text(
              'Age: ${patient['age'] ?? 'N/A'} • Gender: ${patient['gender'] ?? 'N/A'}',
            ),
            Text('State: ${patient['state'] ?? 'N/A'}'),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'confirmed':
        return Colors.green.shade100;
      case 'pending':
        return Colors.orange.shade100;
      case 'rejected':
        return Colors.red.shade100;
      case 'completed':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
}
