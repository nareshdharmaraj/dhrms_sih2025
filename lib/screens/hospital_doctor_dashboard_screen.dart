import 'package:flutter/material.dart';
import '../services/hospital_api_service.dart';
import '../widgets/embedded_doctor_appointment_widget.dart';

class HospitalDoctorDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> doctorData;

  const HospitalDoctorDashboardScreen({super.key, required this.doctorData});

  @override
  _HospitalDoctorDashboardScreenState createState() =>
      _HospitalDoctorDashboardScreenState();
}

class _HospitalDoctorDashboardScreenState
    extends State<HospitalDoctorDashboardScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _currentIndex = 0;

  bool _isLoading = false;
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _patients = [];
  Map<String, dynamic> _dashboardStats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get doctor's staff ID from doctorData
      final String doctorId =
          widget.doctorData['_id'] ??
          widget.doctorData['id'] ??
          widget.doctorData['doctorId'] ??
          '';

      print('🔍 Doctor data keys: ${widget.doctorData.keys.toList()}');
      print('🔍 Extracted doctor ID: $doctorId');

      if (doctorId.isNotEmpty) {
        // Load appointments for this doctor
        final appointments = await HospitalApiService.getDoctorAppointments(
          doctorId,
        );

        // Extract unique patients from appointments (more secure than loading all patients)
        final patients = _extractPatientsFromAppointments(appointments);

        setState(() {
          _appointments = appointments;
          _patients = patients;
          _dashboardStats = _calculateStats(appointments);
        });
      }
    } catch (e) {
      _showError('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _calculateStats(
    List<Map<String, dynamic>> appointments,
  ) {
    final total = appointments.length;
    final today = DateTime.now();
    final todayStr =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    final todayAppointments = appointments.where((apt) {
      final aptDate = apt['appointmentDate']?.toString() ?? '';
      return aptDate.startsWith(todayStr);
    }).length;

    final scheduled = appointments
        .where((apt) => apt['status'] == 'scheduled')
        .length;
    final completed = appointments
        .where((apt) => apt['status'] == 'completed')
        .length;
    final cancelled = appointments
        .where((apt) => apt['status'] == 'cancelled')
        .length;

    return {
      'total': total,
      'today': todayAppointments,
      'scheduled': scheduled,
      'completed': completed,
      'cancelled': cancelled,
    };
  }

  List<Map<String, dynamic>> _extractPatientsFromAppointments(
    List<Map<String, dynamic>> appointments,
  ) {
    final Map<String, Map<String, dynamic>> uniquePatients = {};

    for (final appointment in appointments) {
      final patientData = appointment['patientId'];
      if (patientData != null && patientData is Map<String, dynamic>) {
        final patientId =
            patientData['_id']?.toString() ??
            patientData['id']?.toString() ??
            '';
        if (patientId.isNotEmpty && !uniquePatients.containsKey(patientId)) {
          uniquePatients[patientId] = Map<String, dynamic>.from(patientData);
        }
      } else {
        // If patient data is not populated, create a basic patient record from appointment data
        final appointmentPatientId = appointment['patientId']?.toString() ?? '';
        final patientName = appointment['patientName']?.toString() ?? '';

        if (appointmentPatientId.isNotEmpty && patientName.isNotEmpty) {
          if (!uniquePatients.containsKey(appointmentPatientId)) {
            uniquePatients[appointmentPatientId] = {
              '_id': appointmentPatientId,
              'fullName': patientName,
              'name': patientName,
              'phone': '',
              'bloodGroup': '',
            };
          }
        }
      }
    }

    return uniquePatients.values.toList();
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Compact Header
          _buildCompactHeader(),

          // Main Content
          Expanded(
            child: _isLoading
                ? _buildLoadingWidget()
                : IndexedStack(
                    index: _currentIndex,
                    children: [
                      _buildDashboardTab(),
                      _buildAppointmentsTab(),
                      _buildPatientsTab(),
                    ],
                  ),
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildCompactHeader() {
    final doctor = widget.doctorData;
    final doctorName =
        doctor['fullName'] ??
        doctor['doctorName'] ??
        doctor['name'] ??
        'Doctor';
    final specialization =
        doctor['specialization'] ??
        doctor['department'] ??
        'Medical Professional';
    final hospital = doctor['hospitalName'] ?? 'Hospital';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Doctor Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              SizedBox(width: 12),

              // Doctor Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. $doctorName',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      specialization,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      hospital,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              Row(
                children: [
                  IconButton(
                    onPressed: _loadInitialData,
                    icon: Icon(Icons.refresh, color: Colors.white),
                    iconSize: 20,
                  ),
                  IconButton(
                    onPressed: () => _showLogoutDialog(),
                    icon: Icon(Icons.logout, color: Colors.white),
                    iconSize: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey[500],
        backgroundColor: Colors.white,
        elevation: 0,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Patients',
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
          ),
          SizedBox(height: 16),
          Text(
            'Loading Doctor Dashboard...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics Cards
          _buildStatsGrid(),

          SizedBox(height: 20),

          // Quick Actions
          _buildQuickActions(),

          SizedBox(height: 20),

          // Today's Appointments Preview
          _buildTodayAppointmentsPreview(),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          'Total Appointments',
          _dashboardStats['total']?.toString() ?? '0',
          Icons.calendar_today,
          Colors.blue,
        ),
        _buildStatCard(
          'Today\'s Appointments',
          _dashboardStats['today']?.toString() ?? '0',
          Icons.today,
          Colors.green,
        ),
        _buildStatCard(
          'Scheduled',
          _dashboardStats['scheduled']?.toString() ?? '0',
          Icons.schedule,
          Colors.orange,
        ),
        _buildStatCard(
          'Completed',
          _dashboardStats['completed']?.toString() ?? '0',
          Icons.check_circle,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
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
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'View All Appointments',
                Icons.calendar_view_day,
                Colors.blue,
                () => setState(() => _currentIndex = 1),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Patient Records',
                Icons.medical_information,
                Colors.green,
                () => setState(() => _currentIndex = 2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
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
            Icon(icon, color: color, size: 28),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayAppointmentsPreview() {
    final today = DateTime.now();
    final todayStr =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    final todayAppointments = _appointments
        .where((apt) {
          final aptDate = apt['appointmentDate']?.toString() ?? '';
          return aptDate.startsWith(todayStr);
        })
        .take(3)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Appointments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            if (todayAppointments.isNotEmpty)
              TextButton(
                onPressed: () => setState(() => _currentIndex = 1),
                child: Text('View All'),
              ),
          ],
        ),
        SizedBox(height: 12),

        if (todayAppointments.isEmpty)
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey[400], size: 48),
                  SizedBox(height: 8),
                  Text(
                    'No appointments today',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            ),
          )
        else
          ...todayAppointments.map(
            (appointment) => _buildAppointmentPreviewCard(appointment),
          ),
      ],
    );
  }

  Widget _buildAppointmentPreviewCard(Map<String, dynamic> appointment) {
    final patientData = appointment['patientId'] is Map
        ? appointment['patientId'] as Map<String, dynamic>
        : <String, dynamic>{};

    final patientName =
        patientData['fullName'] ?? patientData['name'] ?? 'Unknown Patient';

    final time = appointment['appointmentTime'] ?? 'Time not set';
    final reason = appointment['reason'] ?? 'No reason specified';
    final status = appointment['status'] ?? 'scheduled';

    Color statusColor = _getStatusColor(status);

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  reason,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.blue[700],
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    // Return the new embedded appointment widget
    return EmbeddedDoctorAppointmentWidget(doctorData: widget.doctorData);
  }

  Widget _buildEmptyAppointments() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No Appointments Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your appointments will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadInitialData,
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

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final patientData = appointment['patientId'] is Map
        ? appointment['patientId'] as Map<String, dynamic>
        : <String, dynamic>{};

    // Handle patient data - use appointment fields if patient data is not populated
    final patientName =
        patientData['fullName'] ??
        patientData['name'] ??
        appointment['patientName'] ??
        'Unknown Patient';
    final patientPhone = patientData['phone'] ?? '';
    final bloodGroup = patientData['bloodGroup'] ?? '';

    final appointmentDate = appointment['appointmentDate'] ?? '';
    final time = appointment['appointmentTime'] ?? 'Time not set';
    final reason = appointment['reason'] ?? 'No reason specified';
    final notes = appointment['notes'] ?? '';
    final status = appointment['status'] ?? 'scheduled';
    final type = appointment['type'] ?? 'consultation';
    final priority = appointment['priority'] ?? 'normal';
    final duration = appointment['duration'] ?? 30;

    // Location info
    final location = appointment['location'] is Map
        ? appointment['location'] as Map<String, dynamic>
        : <String, dynamic>{};
    final hospitalName = location['hospitalName'] ?? '';
    final department = location['department'] ?? '';
    final roomNumber = location['roomNumber'] ?? '';

    Color statusColor = _getStatusColor(status);
    Color priorityColor = _getPriorityColor(priority);

    // Format date
    String formattedDate = '';
    try {
      if (appointmentDate.isNotEmpty) {
        final date = DateTime.parse(appointmentDate);
        formattedDate = "${date.day}/${date.month}/${date.year}";
      }
    } catch (e) {
      formattedDate = appointmentDate;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Patient Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue[100],
                  child: Icon(Icons.person, color: Colors.blue[700]),
                ),
                SizedBox(width: 12),

                // Patient Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              patientName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (bloodGroup.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                bloodGroup,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (patientPhone.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            patientPhone,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Status and Priority
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (priority != 'normal')
                      Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: priorityColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            priority.toUpperCase(),
                            style: TextStyle(
                              color: priorityColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: Colors.grey[200]),

          // Appointment Details
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date, Time, Duration
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    SizedBox(width: 6),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                    SizedBox(width: 6),
                    Text(
                      '$time (${duration}min)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8),

                // Type and Reason
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.medical_information,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${type.toUpperCase()} - $reason',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                          if (notes.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                'Notes: $notes',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Location (if available)
                if (hospitalName.isNotEmpty ||
                    department.isNotEmpty ||
                    roomNumber.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            [
                              hospitalName,
                              department,
                              roomNumber,
                            ].where((s) => s.isNotEmpty).join(' • '),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Action Buttons
          if (status == 'scheduled' || status == 'confirmed')
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _updateAppointmentStatus(
                        appointment['_id'],
                        'completed',
                      ),
                      icon: Icon(Icons.check, size: 16),
                      label: Text('Mark Complete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green[700],
                        side: BorderSide(color: Colors.green[700]!),
                        padding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _updateAppointmentStatus(
                        appointment['_id'],
                        'cancelled',
                      ),
                      icon: Icon(Icons.cancel, size: 16),
                      label: Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[700],
                        side: BorderSide(color: Colors.red[700]!),
                        padding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPatientsTab() {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'My Patients (${_patients.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              IconButton(
                onPressed: _loadInitialData,
                icon: Icon(Icons.refresh, color: Colors.blue[700]),
              ),
            ],
          ),
        ),

        Expanded(
          child: _patients.isEmpty
              ? _buildEmptyPatients()
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _patients.length,
                  itemBuilder: (context, index) {
                    return _buildPatientCard(_patients[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyPatients() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No Patients Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Patient records will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    final name = patient['fullName'] ?? patient['name'] ?? 'Unknown Patient';
    final phone = patient['phone'] ?? '';
    final email = patient['email'] ?? '';
    final bloodGroup = patient['bloodGroup'] ?? '';
    final age = patient['age']?.toString() ?? '';
    final gender = patient['gender'] ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Patient Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.green[100],
            child: Icon(Icons.person, color: Colors.green[700], size: 32),
          ),
          SizedBox(width: 16),

          // Patient Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (bloodGroup.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          bloodGroup,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4),

                if (age.isNotEmpty || gender.isNotEmpty)
                  Text(
                    [
                      age.isNotEmpty ? '${age}y' : '',
                      gender,
                    ].where((s) => s.isNotEmpty).join(' • '),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),

                if (phone.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      phone,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),

                if (email.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      email,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),

          // Action Button
          IconButton(
            onPressed: () {
              // TODO: Navigate to patient details
              _showPatientDetails(patient);
            },
            icon: Icon(Icons.arrow_forward_ios),
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.blue;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.purple;
      case 'cancelled':
        return Colors.red;
      case 'no_show':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'normal':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateAppointmentStatus(
    String appointmentId,
    String newStatus,
  ) async {
    try {
      await HospitalApiService.updateDoctorAppointmentStatus(
        appointmentId,
        newStatus,
      );
      _showSuccess('Appointment status updated successfully');
      // Reload appointments
      _loadInitialData();
    } catch (e) {
      _showError('Failed to update appointment status: $e');
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showPatientDetails(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Patient Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${patient['fullName'] ?? 'N/A'}'),
            Text('Phone: ${patient['phone'] ?? 'N/A'}'),
            Text('Email: ${patient['email'] ?? 'N/A'}'),
            Text('Blood Group: ${patient['bloodGroup'] ?? 'N/A'}'),
            Text('Age: ${patient['age']?.toString() ?? 'N/A'}'),
            Text('Gender: ${patient['gender'] ?? 'N/A'}'),
          ],
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate back to login
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
