import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_constants.dart';

class HospitalStaffDashboard extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HospitalStaffDashboard({super.key, required this.userData});

  @override
  _HospitalStaffDashboardState createState() => _HospitalStaffDashboardState();
}

class _HospitalStaffDashboardState extends State<HospitalStaffDashboard> {
  List<dynamic> patients = [];
  List<dynamic> appointments = [];
  List<dynamic> medicalRecords = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadStaffData();
  }

  Future<void> loadStaffData() async {
    try {
      setState(() => isLoading = true);
      
      // Load patients from the hospital/department
      final patientsResponse = await http.get(
        Uri.parse('${AppConstants.baseUrl}/patients'),
        headers: {'Content-Type': 'application/json'},
      );

      // Load appointments for this staff member
      final appointmentsResponse = await http.get(
        Uri.parse('${AppConstants.baseUrl}/appointments/staff/${widget.userData['_id']}'),
        headers: {'Content-Type': 'application/json'},
      );

      // Load medical records for this staff member's patients
      final recordsResponse = await http.get(
        Uri.parse('${AppConstants.baseUrl}/medical-records/staff/${widget.userData['_id']}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (patientsResponse.statusCode == 200) {
        patients = json.decode(patientsResponse.body);
      }

      if (appointmentsResponse.statusCode == 200) {
        appointments = json.decode(appointmentsResponse.body);
      }

      if (recordsResponse.statusCode == 200) {
        medicalRecords = json.decode(recordsResponse.body);
      }

      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        error = 'Failed to load staff data: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Staff Dashboard'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: loadStaffData,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(error!, style: TextStyle(color: Colors.red)),
                      ElevatedButton(
                        onPressed: loadStaffData,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Staff Information Card
                      _buildStaffInfoCard(),
                      SizedBox(height: 20),
                      
                      // Quick Stats
                      _buildQuickStats(),
                      SizedBox(height: 20),
                      
                      // Today's Schedule
                      _buildTodaySchedule(),
                      SizedBox(height: 20),
                      
                      // Recent Patients
                      _buildRecentPatients(),
                      SizedBox(height: 20),
                      
                      // Department Overview
                      _buildDepartmentOverview(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStaffInfoCard() {
    String role = widget.userData['staffRole'] ?? 'Staff';
    String department = widget.userData['department'] ?? 'General';
    String hospital = widget.userData['hospitalName'] ?? 'Hospital';

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.green.shade100,
                  child: Icon(_getRoleIcon(role), size: 40, color: Colors.green.shade700),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userData['fullName'] ?? 'Unknown',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${role.toUpperCase()} - $department',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      Text(
                        hospital,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem('Experience', '${widget.userData['yearsOfExperience'] ?? 0} years'),
                _buildInfoItem('License', widget.userData['licenseNumber'] ?? 'N/A'),
                _buildInfoItem('ID', widget.userData['hospitalId'] ?? 'N/A'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'doctor':
        return Icons.medical_services;
      case 'nurse':
        return Icons.local_hospital;
      case 'admin':
        return Icons.admin_panel_settings;
      case 'pharmacist':
        return Icons.medication;
      case 'technician':
        return Icons.biotech;
      default:
        return Icons.person;
    }
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    int todayAppointments = appointments.where((apt) {
      DateTime aptDate = DateTime.parse(apt['appointmentDate']);
      DateTime today = DateTime.now();
      return aptDate.year == today.year && 
             aptDate.month == today.month && 
             aptDate.day == today.day;
    }).length;

    int totalPatients = patients.length;
    int recordsCreated = medicalRecords.length;

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Today\'s Appointments', todayAppointments.toString(), Icons.today, Colors.blue),
                _buildStatItem('Total Patients', totalPatients.toString(), Icons.people, Colors.green),
                _buildStatItem('Records Created', recordsCreated.toString(), Icons.assignment, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 30),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTodaySchedule() {
    DateTime today = DateTime.now();
    var todayAppointments = appointments.where((apt) {
      DateTime aptDate = DateTime.parse(apt['appointmentDate']);
      return aptDate.year == today.year && 
             aptDate.month == today.month && 
             aptDate.day == today.day;
    }).toList();

    todayAppointments.sort((a, b) => a['appointmentTime'].compareTo(b['appointmentTime']));

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Schedule',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${today.day}/${today.month}/${today.year}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 12),
            todayAppointments.isEmpty
                ? Container(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.free_cancellation, size: 48, color: Colors.grey[400]),
                          SizedBox(height: 8),
                          Text(
                            'No appointments scheduled for today',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: todayAppointments.map((appointment) {
                      return _buildScheduleItem(appointment);
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(Map<String, dynamic> appointment) {
    String status = appointment['status'] ?? 'scheduled';
    Color statusColor = _getStatusColor(status);
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: statusColor.withOpacity(0.05),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                appointment['appointmentTime'] ?? 'TBD',
                style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment['reason'] ?? 'Medical Appointment',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  'Patient: Loading...', // Would need to fetch patient name
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(
                      '${appointment['duration'] ?? 30} minutes',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.room, size: 14, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(
                      appointment['location']?['roomNumber'] ?? 'TBD',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'confirmed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'no_show':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  Widget _buildRecentPatients() {
    // Get patients from recent appointments/records
    var recentPatientIds = <String>{};
    for (var apt in appointments.take(5)) {
      if (apt['patientId'] != null) {
        recentPatientIds.add(apt['patientId']);
      }
    }
    for (var record in medicalRecords.take(5)) {
      if (record['patientId'] != null) {
        recentPatientIds.add(record['patientId']);
      }
    }

    var recentPatients = patients.where((patient) => 
      recentPatientIds.contains(patient['_id'])).take(5).toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Patients',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to full patients list
                  },
                  child: Text('View All'),
                ),
              ],
            ),
            SizedBox(height: 12),
            recentPatients.isEmpty
                ? Container(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'No recent patients',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                : Column(
                    children: recentPatients.map((patient) {
                      return _buildPatientItem(patient);
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientItem(Map<String, dynamic> patient) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              (patient['fullName'] ?? 'U')[0].toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient['fullName'] ?? 'Unknown Patient',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.bloodtype, size: 16, color: Colors.red),
                    SizedBox(width: 4),
                    Text(
                      patient['bloodGroup'] ?? 'Unknown',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(
                      patient['phone'] ?? 'No phone',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                if (patient['allergies'] != null && (patient['allergies'] as List).isNotEmpty) ...[
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.warning, size: 16, color: Colors.orange),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Allergies: ${(patient['allergies'] as List).join(', ')}',
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
            onPressed: () {
              // Navigate to patient details
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentOverview() {
    String department = widget.userData['department'] ?? 'General';
    String role = widget.userData['staffRole'] ?? 'staff';

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$department Department',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            
            // Working Hours
            _buildWorkingHours(),
            SizedBox(height: 16),
            
            // Permissions
            _buildPermissions(),
            SizedBox(height: 16),
            
            // Quick Actions
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkingHours() {
    var workingHours = widget.userData['workingHours'];
    if (workingHours == null) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.access_time, size: 20, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              'Working Hours',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Start Time: ${workingHours['startTime'] ?? 'N/A'}'),
                  ),
                  Expanded(
                    child: Text('End Time: ${workingHours['endTime'] ?? 'N/A'}'),
                  ),
                ],
              ),
              SizedBox(height: 8),
              if (workingHours['workingDays'] != null) ...[
                Text('Working Days: ${(workingHours['workingDays'] as List).join(', ')}'),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPermissions() {
    var permissions = widget.userData['permissions'] as List<dynamic>? ?? [];
    if (permissions.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.security, size: 20, color: Colors.green),
            SizedBox(width: 8),
            Text(
              'Access Permissions',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green),
            ),
          ],
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: permissions.map((permission) => Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Text(
              permission.toString().replaceAll('_', ' ').toUpperCase(),
              style: TextStyle(fontSize: 10, color: Colors.green.withOpacity(0.8)),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.purple),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionButton('New Record', Icons.add_box, Colors.blue, () {
              // Navigate to create medical record
            }),
            _buildActionButton('Schedule', Icons.calendar_today, Colors.green, () {
              // Navigate to schedule appointment
            }),
            _buildActionButton('Patients', Icons.people, Colors.orange, () {
              // Navigate to patients list
            }),
            _buildActionButton('Reports', Icons.bar_chart, Colors.purple, () {
              // Navigate to reports
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: IconButton(
            icon: Icon(icon, color: color),
            onPressed: onPressed,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color),
        ),
      ],
    );
  }
}
