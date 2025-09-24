import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_constants.dart';
import '../screens/hospital_doctor_consultation_screen.dart';

class EmbeddedDoctorAppointmentWidget extends StatefulWidget {
  final Map<String, dynamic> doctorData;

  const EmbeddedDoctorAppointmentWidget({super.key, required this.doctorData});

  @override
  _EmbeddedDoctorAppointmentWidgetState createState() =>
      _EmbeddedDoctorAppointmentWidgetState();
}

class _EmbeddedDoctorAppointmentWidgetState
    extends State<EmbeddedDoctorAppointmentWidget>
    with TickerProviderStateMixin {
  // Tab controller for the three tabs
  late TabController _tabController;

  // Data for each tab
  List<dynamic> requestsAppointments = [];
  List<dynamic> currentAppointments = [];
  List<dynamic> rejectedAppointments = [];

  // Loading states
  bool isLoadingRequests = true;
  bool isLoadingCurrent = true;
  bool isLoadingRejected = true;

  // Statistics
  Map<String, int> appointmentStats = {
    'pending': 0,
    'approved': 0,
    'rejected': 0,
    'completed': 0,
    'recentlyRejected': 0,
    'total': 0,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    // Load data for the current tab if not loaded
    if (_tabController.index == 0 && requestsAppointments.isEmpty) {
      _loadRequestsData();
    } else if (_tabController.index == 1 && currentAppointments.isEmpty) {
      _loadCurrentData();
    } else if (_tabController.index == 2 && rejectedAppointments.isEmpty) {
      _loadRejectedData();
    }
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadStatistics(),
      _loadRequestsData(),
      _loadCurrentData(),
      _loadRejectedData(),
    ]);
  }

  Future<void> _loadStatistics() async {
    try {
      final doctorId =
          widget.doctorData['doctorId'] ??
          widget.doctorData['id'] ??
          widget.doctorData['_id'] ??
          widget.doctorData['hospitalStaffId'];

      final response = await http.get(
        Uri.parse(
          '${AppConstants.baseUrl}/doctor-appointments/stats/$doctorId',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            appointmentStats = Map<String, int>.from(data['data']);
          });
        }
      }
    } catch (error) {
      print('❌ Error loading statistics: $error');
    }
  }

  Future<void> _loadRequestsData() async {
    try {
      setState(() => isLoadingRequests = true);

      final doctorId =
          widget.doctorData['doctorId'] ??
          widget.doctorData['id'] ??
          widget.doctorData['_id'] ??
          widget.doctorData['hospitalStaffId'];

      final response = await http.get(
        Uri.parse(
          '${AppConstants.baseUrl}/doctor-appointments/$doctorId/requests',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            requestsAppointments = data['data'] ?? [];
          });
        }
      }
    } catch (error) {
      print('❌ Error loading requests: $error');
      _showErrorSnackBar('Failed to load appointment requests');
    } finally {
      setState(() => isLoadingRequests = false);
    }
  }

  Future<void> _loadCurrentData() async {
    try {
      setState(() => isLoadingCurrent = true);

      final doctorId =
          widget.doctorData['doctorId'] ??
          widget.doctorData['id'] ??
          widget.doctorData['_id'] ??
          widget.doctorData['hospitalStaffId'];

      final response = await http.get(
        Uri.parse(
          '${AppConstants.baseUrl}/doctor-appointments/$doctorId/current',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            currentAppointments = data['data'] ?? [];
          });
        }
      }
    } catch (error) {
      print('❌ Error loading current appointments: $error');
      _showErrorSnackBar('Failed to load current appointments');
    } finally {
      setState(() => isLoadingCurrent = false);
    }
  }

  Future<void> _loadRejectedData() async {
    try {
      setState(() => isLoadingRejected = true);

      final doctorId =
          widget.doctorData['doctorId'] ??
          widget.doctorData['id'] ??
          widget.doctorData['_id'] ??
          widget.doctorData['hospitalStaffId'];

      final response = await http.get(
        Uri.parse(
          '${AppConstants.baseUrl}/doctor-appointments/$doctorId/rejected',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            rejectedAppointments = data['data'] ?? [];
          });
        }
      }
    } catch (error) {
      print('❌ Error loading rejected appointments: $error');
      _showErrorSnackBar('Failed to load rejected appointments');
    } finally {
      setState(() => isLoadingRejected = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Statistics Overview
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              // Title
              Text(
                'Dr. ${widget.doctorData['doctorName'] ?? widget.doctorData['name'] ?? 'Doctor'}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Appointment Management',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              SizedBox(height: 16),
              // Statistics Row
              Row(
                children: [
                  _buildStatCard(
                    'Total',
                    appointmentStats['total']!,
                    Colors.blue.shade300,
                  ),
                  _buildStatCard(
                    'Pending',
                    appointmentStats['pending']!,
                    Colors.orange.shade300,
                  ),
                  _buildStatCard(
                    'Approved',
                    appointmentStats['approved']!,
                    Colors.green.shade300,
                  ),
                  _buildStatCard(
                    'Completed',
                    appointmentStats['completed']!,
                    Colors.purple.shade300,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Tab Bar
        Container(
          color: Colors.blue.shade700,
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Requests'),
                    if (appointmentStats['pending']! > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${appointmentStats['pending']}',
                          style: TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
              Tab(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Current'),
                    if (appointmentStats['approved']! > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${appointmentStats['approved']}',
                          style: TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
              Tab(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Rejected'),
                    if (appointmentStats['recentlyRejected']! > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${appointmentStats['recentlyRejected']}',
                          style: TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRequestsTab(),
              _buildCurrentTab(),
              _buildRejectedTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsTab() {
    if (isLoadingRequests) {
      return Center(child: CircularProgressIndicator());
    }

    if (requestsAppointments.isEmpty) {
      return _buildEmptyState(
        'No Pending Requests',
        'All appointment requests have been processed.',
        Icons.inbox,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequestsData,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: requestsAppointments.length,
        itemBuilder: (context, index) {
          return _buildRequestCard(requestsAppointments[index]);
        },
      ),
    );
  }

  Widget _buildCurrentTab() {
    if (isLoadingCurrent) {
      return Center(child: CircularProgressIndicator());
    }

    if (currentAppointments.isEmpty) {
      return _buildEmptyState(
        'No Current Appointments',
        'No approved appointments scheduled.',
        Icons.event_available,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCurrentData,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: currentAppointments.length,
        itemBuilder: (context, index) {
          return _buildCurrentAppointmentCard(currentAppointments[index]);
        },
      ),
    );
  }

  Widget _buildRejectedTab() {
    if (isLoadingRejected) {
      return Center(child: CircularProgressIndicator());
    }

    if (rejectedAppointments.isEmpty) {
      return _buildEmptyState(
        'No Recent Rejections',
        'No recently rejected appointments available for re-acceptance.',
        Icons.cancel,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRejectedData,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: rejectedAppointments.length,
        itemBuilder: (context, index) {
          return _buildRejectedAppointmentCard(rejectedAppointments[index]);
        },
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> appointment) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: Colors.orange, width: 4)),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.orange.shade100,
                    child: Icon(Icons.person, color: Colors.orange),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment['patientName'] ?? 'Unknown Patient',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'UHID: ${appointment['patientUhid'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'NEW REQUEST',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              _buildAppointmentDetails(appointment),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _viewAppointmentDetails(appointment),
                      icon: Icon(Icons.visibility, size: 16),
                      label: Text('View'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveAppointment(appointment),
                      icon: Icon(Icons.check, size: 16),
                      label: Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rejectAppointment(appointment),
                      icon: Icon(Icons.close, size: 16),
                      label: Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentAppointmentCard(Map<String, dynamic> appointment) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: Colors.green, width: 4)),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: Icon(Icons.person, color: Colors.green),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment['patientName'] ?? 'Unknown Patient',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'UHID: ${appointment['patientUhid'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'CONFIRMED',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              _buildAppointmentDetails(appointment),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _viewAppointmentDetails(appointment),
                      icon: Icon(Icons.visibility, size: 16),
                      label: Text('View Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _attendPatient(appointment),
                      icon: Icon(Icons.medical_services, size: 16),
                      label: Text('Attend Patient'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRejectedAppointmentCard(Map<String, dynamic> appointment) {
    // Calculate time remaining for re-acceptance
    final updatedAt = DateTime.parse(appointment['updatedAt']);
    final oneDayLater = updatedAt.add(Duration(days: 1));
    final now = DateTime.now();
    final timeRemaining = oneDayLater.difference(now);
    final canReAccept = timeRemaining.inMinutes > 0;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: Colors.red, width: 4)),
          color: canReAccept ? null : Colors.grey.shade100,
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.red.shade100,
                    child: Icon(Icons.person, color: Colors.red),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment['patientName'] ?? 'Unknown Patient',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: canReAccept ? null : Colors.grey,
                          ),
                        ),
                        Text(
                          'UHID: ${appointment['patientUhid'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: canReAccept
                          ? Colors.red.shade100
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      canReAccept ? 'CAN RE-ACCEPT' : 'EXPIRED',
                      style: TextStyle(
                        fontSize: 10,
                        color: canReAccept
                            ? Colors.red.shade800
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              _buildAppointmentDetails(appointment),
              if (appointment['rejectionReason'] != null) ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Reason: ${appointment['rejectionReason']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (canReAccept) ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Time remaining: ${_formatTimeRemaining(timeRemaining)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _viewAppointmentDetails(appointment),
                      icon: Icon(Icons.visibility, size: 16),
                      label: Text('View Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  if (canReAccept) ...[
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _acceptRejectedAppointment(appointment),
                        icon: Icon(Icons.undo, size: 16),
                        label: Text('Re-Accept'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentDetails(Map<String, dynamic> appointment) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
            SizedBox(width: 8),
            Text(
              appointment['appointmentDate'] ?? 'No date',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            SizedBox(width: 16),
            Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
            SizedBox(width: 8),
            Text(
              appointment['appointmentTime'] ?? 'No time',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.medical_services, size: 16, color: Colors.grey.shade600),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                appointment['reason'] ?? 'No reason provided',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        if (appointment['consultationFee'] != null) ...[
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.currency_rupee, size: 16, color: Colors.grey.shade600),
              SizedBox(width: 8),
              Text(
                '₹${appointment['consultationFee']}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeRemaining(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  // Action Methods (simplified for embedded use)
  Future<void> _viewAppointmentDetails(Map<String, dynamic> appointment) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Appointment Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Patient: ${appointment['patientName']}'),
              Text('UHID: ${appointment['patientUhid']}'),
              Text('Date: ${appointment['appointmentDate']}'),
              Text('Time: ${appointment['appointmentTime']}'),
              Text('Reason: ${appointment['reason']}'),
              Text('Fee: ₹${appointment['consultationFee']}'),
              Text('Status: ${appointment['status']}'),
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

  Future<void> _approveAppointment(Map<String, dynamic> appointment) async {
    try {
      final response = await http.put(
        Uri.parse(
          '${AppConstants.baseUrl}/doctor-appointments/approve/${appointment['appointmentId']}',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          _showSuccessSnackBar('Appointment approved successfully');
          _loadAllData(); // Refresh all data
        } else {
          _showErrorSnackBar(
            data['message'] ?? 'Failed to approve appointment',
          );
        }
      } else {
        _showErrorSnackBar('Server error: ${response.statusCode}');
      }
    } catch (error) {
      _showErrorSnackBar('Network error: $error');
    }
  }

  Future<void> _rejectAppointment(Map<String, dynamic> appointment) async {
    final reason = await _showRejectReasonDialog();
    if (reason == null) return; // User cancelled

    try {
      final response = await http.put(
        Uri.parse(
          '${AppConstants.baseUrl}/doctor-appointments/reject/${appointment['appointmentId']}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'reason': reason}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          _showSuccessSnackBar('Appointment rejected');
          _loadAllData(); // Refresh all data
        } else {
          _showErrorSnackBar(data['message'] ?? 'Failed to reject appointment');
        }
      } else {
        _showErrorSnackBar('Server error: ${response.statusCode}');
      }
    } catch (error) {
      _showErrorSnackBar('Network error: $error');
    }
  }

  Future<String?> _showRejectReasonDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reject Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please provide a reason for rejection:'),
            SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter rejection reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Reject'),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptRejectedAppointment(
    Map<String, dynamic> appointment,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(
          '${AppConstants.baseUrl}/doctor-appointments/accept-rejected/${appointment['appointmentId']}',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          _showSuccessSnackBar('Appointment re-accepted successfully');
          _loadAllData(); // Refresh all data
        } else {
          _showErrorSnackBar(
            data['message'] ?? 'Failed to re-accept appointment',
          );
        }
      } else {
        final data = json.decode(response.body);
        _showErrorSnackBar(
          data['message'] ?? 'Server error: ${response.statusCode}',
        );
      }
    } catch (error) {
      _showErrorSnackBar('Network error: $error');
    }
  }

  void _attendPatient(Map<String, dynamic> appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HospitalDoctorConsultationScreen(
          appointmentData: appointment,
          doctorData: widget.doctorData,
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
