import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_constants.dart';

class HospitalDoctorAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> doctorData;

  const HospitalDoctorAppointmentScreen({super.key, required this.doctorData});

  @override
  _HospitalDoctorAppointmentScreenState createState() =>
      _HospitalDoctorAppointmentScreenState();
}

class _HospitalDoctorAppointmentScreenState
    extends State<HospitalDoctorAppointmentScreen>
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

  // Filter variables
  String statusFilter = 'all';
  DateTime? dateFilter;

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
      final doctorId = widget.doctorData['doctorId'] ?? widget.doctorData['id'];

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

      final doctorId = widget.doctorData['doctorId'] ?? widget.doctorData['id'];

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

      final doctorId = widget.doctorData['doctorId'] ?? widget.doctorData['id'];

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

      final doctorId = widget.doctorData['doctorId'] ?? widget.doctorData['id'];

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

  // Filter methods
  void _filterAppointments() {
    // This method can be used to apply filters if needed
    // For now, it's a placeholder that can be expanded later
    setState(() {
      // Trigger rebuild to apply any filter changes
    });
  }

  Future<void> _selectDateFilter() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateFilter ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != dateFilter) {
      setState(() {
        dateFilter = picked;
        _filterAppointments();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // App Branding Header
          _buildAppBrandingHeader(),

          // Doctor Details Card
          _buildDoctorDetailsCard(),

          // Compact Statistics Overview
          _buildCompactStatistics(),

          // Main Content with Bottom Navigation
          Expanded(
            child: Column(
              children: [
                // Tab Content (Most of the screen space)
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

                // Bottom Tab Navigation
                _buildBottomTabNavigation(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // App Branding Header
  Widget _buildAppBrandingHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // App Logo
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.favorite,
                color: Colors.blue.shade700,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // App Name
            const Text(
              'My Health',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Spacer(),

            // Refresh Button
            IconButton(
              onPressed: _loadAllData,
              icon: const Icon(Icons.refresh, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Doctor Details Card
  Widget _buildDoctorDetailsCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Doctor Avatar
          Hero(
            tag: 'doctor_avatar',
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue.shade100,
              child: Icon(Icons.person, size: 30, color: Colors.blue.shade700),
            ),
          ),
          const SizedBox(width: 16),

          // Doctor Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr. ${widget.doctorData['doctorName'] ?? 'Doctor'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.doctorData['specialization'] ?? 'Specialist',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  'Appointment Management',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 12),

                // Filter Row
                Row(
                  children: [
                    // Status Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: statusFilter,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items:
                            [
                                  'All',
                                  'pending',
                                  'approved',
                                  'rejected',
                                  'completed',
                                ]
                                .map(
                                  (status) => DropdownMenuItem<String>(
                                    value: status,
                                    child: Text(
                                      status == 'All'
                                          ? 'All Status'
                                          : status.toUpperCase(),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            statusFilter = value!;
                            _filterAppointments();
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 12),

                    // Date Filter
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _selectDateFilter,
                        icon: Icon(Icons.calendar_today),
                        label: Text(
                          dateFilter == null
                              ? 'All Dates'
                              : '${dateFilter!.day}/${dateFilter!.month}',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),

                    // Clear Date Filter
                    if (dateFilter != null)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            dateFilter = null;
                            _filterAppointments();
                          });
                        },
                        icon: Icon(Icons.clear),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Status Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: Colors.green.shade600),
                const SizedBox(width: 4),
                Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Compact Statistics
  Widget _buildCompactStatistics() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildCompactStatCard(
            'Total',
            appointmentStats['total']!,
            Colors.blue.shade600,
            Icons.calendar_today,
          ),
          _buildCompactStatCard(
            'Pending',
            appointmentStats['pending']!,
            Colors.orange.shade600,
            Icons.schedule,
          ),
          _buildCompactStatCard(
            'Approved',
            appointmentStats['approved']!,
            Colors.green.shade600,
            Icons.check_circle,
          ),
          _buildCompactStatCard(
            'Completed',
            appointmentStats['completed']!,
            Colors.purple.shade600,
            Icons.done_all,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatCard(
    String label,
    int count,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom Tab Navigation
  Widget _buildBottomTabNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.blue.shade600,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: Colors.blue.shade700,
        unselectedLabelColor: Colors.grey.shade500,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        tabs: [
          Tab(
            height: 70,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Icon(Icons.inbox, size: 24),
                    if (appointmentStats['pending']! > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${appointmentStats['pending']}',
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Requests'),
              ],
            ),
          ),
          Tab(
            height: 70,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Icon(Icons.event_available, size: 24),
                    if (appointmentStats['approved']! > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${appointmentStats['approved']}',
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Current'),
              ],
            ),
          ),
          Tab(
            height: 70,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Icon(Icons.history, size: 24),
                    if (appointmentStats['recentlyRejected']! > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${appointmentStats['recentlyRejected']}',
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Rejected'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsTab() {
    if (isLoadingRequests) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
        ),
      );
    }

    if (requestsAppointments.isEmpty) {
      return _buildEmptyState(
        'No Pending Requests',
        'All appointment requests have been processed.',
        Icons.inbox,
        Colors.orange,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequestsData,
      color: Colors.orange,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          16,
          20,
          16,
          100,
        ), // Added bottom padding for tab bar
        physics: const BouncingScrollPhysics(),
        itemCount: requestsAppointments.length,
        itemBuilder: (context, index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 200 + (index * 50)),
            curve: Curves.easeOutBack,
            child: _buildRequestCard(requestsAppointments[index]),
          );
        },
      ),
    );
  }

  Widget _buildCurrentTab() {
    if (isLoadingCurrent) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      );
    }

    if (currentAppointments.isEmpty) {
      return _buildEmptyState(
        'No Current Appointments',
        'No approved appointments scheduled.',
        Icons.event_available,
        Colors.green,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCurrentData,
      color: Colors.green,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          16,
          20,
          16,
          100,
        ), // Added bottom padding for tab bar
        physics: const BouncingScrollPhysics(),
        itemCount: currentAppointments.length,
        itemBuilder: (context, index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 200 + (index * 50)),
            curve: Curves.easeOutBack,
            child: _buildCurrentAppointmentCard(currentAppointments[index]),
          );
        },
      ),
    );
  }

  Widget _buildRejectedTab() {
    if (isLoadingRejected) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
        ),
      );
    }

    if (rejectedAppointments.isEmpty) {
      return _buildEmptyState(
        'No Recent Rejections',
        'No recently rejected appointments available for re-acceptance.',
        Icons.history,
        Colors.grey,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRejectedData,
      color: Colors.orange,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          16,
          20,
          16,
          100,
        ), // Added bottom padding for tab bar
        physics: const BouncingScrollPhysics(),
        itemCount: rejectedAppointments.length,
        itemBuilder: (context, index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 200 + (index * 50)),
            curve: Curves.easeOutBack,
            child: _buildRejectedAppointmentCard(rejectedAppointments[index]),
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> appointment) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.orange.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(
              left: BorderSide(color: Colors.orange.shade600, width: 4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Hero(
                      tag: 'patient_${appointment['_id']}',
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.orange.shade100,
                        child: Icon(
                          Icons.person,
                          color: Colors.orange.shade700,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment['patientName'] ?? 'Unknown Patient',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.badge,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'UHID: ${appointment['patientUhid'] ?? 'N/A'}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade600,
                            Colors.orange.shade500,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'NEW REQUEST',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Appointment Details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: _buildAppointmentDetails(appointment),
                ),

                const SizedBox(height: 24),

                // Action Buttons - More Space and Better Design
                Column(
                  children: [
                    // First Row - View Button (Full Width)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () => _viewAppointmentDetails(appointment),
                        icon: const Icon(Icons.visibility, size: 20),
                        label: const Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Second Row - Approve and Reject
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () => _approveAppointment(appointment),
                              icon: const Icon(Icons.check_circle, size: 20),
                              label: const Text(
                                'Approve',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: () => _rejectAppointment(appointment),
                              icon: Icon(
                                Icons.cancel,
                                size: 20,
                                color: Colors.red.shade600,
                              ),
                              label: Text(
                                'Reject',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.red.shade600,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentAppointmentCard(Map<String, dynamic> appointment) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.green.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(
              left: BorderSide(color: Colors.green.shade600, width: 4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Hero(
                      tag: 'current_patient_${appointment['_id']}',
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.green.shade100,
                        child: Icon(
                          Icons.person,
                          color: Colors.green.shade700,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment['patientName'] ?? 'Unknown Patient',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.badge,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'UHID: ${appointment['patientUhid'] ?? 'N/A'}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade600,
                            Colors.green.shade500,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'CONFIRMED',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Appointment Details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: _buildAppointmentDetails(appointment),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Column(
                  children: [
                    // First Row - View Details (Full Width)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () => _viewAppointmentDetails(appointment),
                        icon: const Icon(Icons.visibility, size: 20),
                        label: const Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Second Row - Mark Complete
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () => _markAsCompleted(appointment),
                        icon: const Icon(Icons.done_all, size: 20),
                        label: const Text(
                          'Mark as Completed',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: canReAccept ? 4 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: canReAccept
                  ? [Colors.white, Colors.orange.shade50]
                  : [Colors.grey.shade100, Colors.grey.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(
              left: BorderSide(
                color: canReAccept
                    ? Colors.orange.shade600
                    : Colors.grey.shade400,
                width: 4,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Hero(
                      tag: 'rejected_patient_${appointment['_id']}',
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: canReAccept
                            ? Colors.orange.shade100
                            : Colors.grey.shade300,
                        child: Icon(
                          Icons.person,
                          color: canReAccept
                              ? Colors.orange.shade700
                              : Colors.grey.shade600,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment['patientName'] ?? 'Unknown Patient',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: canReAccept
                                  ? Colors.black87
                                  : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.badge,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'UHID: ${appointment['patientUhid'] ?? 'N/A'}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: canReAccept
                            ? LinearGradient(
                                colors: [
                                  Colors.orange.shade600,
                                  Colors.orange.shade500,
                                ],
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.grey.shade500,
                                  Colors.grey.shade400,
                                ],
                              ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: canReAccept
                            ? [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            canReAccept ? Icons.schedule : Icons.block,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            canReAccept ? 'CAN RE-ACCEPT' : 'EXPIRED',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Appointment Details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: _buildAppointmentDetails(appointment),
                ),

                // Rejection Reason
                if (appointment['rejectionReason'] != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Colors.red.shade600,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rejection Reason',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                appointment['rejectionReason'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Time Remaining
                if (canReAccept) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time_filled,
                          size: 20,
                          color: Colors.orange.shade600,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Time Remaining for Re-acceptance',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatTimeRemaining(timeRemaining),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Action Buttons
                Column(
                  children: [
                    // View Details Button (Full Width)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () => _viewAppointmentDetails(appointment),
                        icon: const Icon(Icons.visibility, size: 20),
                        label: const Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),

                    // Re-Accept Button (if eligible)
                    if (canReAccept) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _acceptRejectedAppointment(appointment),
                          icon: const Icon(Icons.undo, size: 20),
                          label: const Text(
                            'Re-Accept Appointment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
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
      ),
    );
  }

  Widget _buildAppointmentDetails(Map<String, dynamic> appointment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date and Time Row
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                Icons.calendar_today,
                'Date',
                appointment['appointmentDate'] ?? 'No date',
                Colors.blue.shade600,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDetailItem(
                Icons.access_time,
                'Time',
                appointment['appointmentTime'] ?? 'No time',
                Colors.green.shade600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Reason
        _buildDetailItem(
          Icons.medical_services,
          'Reason',
          appointment['reason'] ?? 'No reason provided',
          Colors.orange.shade600,
          isExpanded: true,
        ),

        // Consultation Fee (if available)
        if (appointment['consultationFee'] != null) ...[
          const SizedBox(height: 16),
          _buildDetailItem(
            Icons.currency_rupee,
            'Consultation Fee',
            '₹${appointment['consultationFee']}',
            Colors.purple.shade600,
          ),
        ],
      ],
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String label,
    String value,
    Color color, {
    bool isExpanded = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: isExpanded
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(
    String title,
    String subtitle,
    IconData icon, [
    MaterialColor? accentColor,
  ]) {
    final color = accentColor ?? Colors.grey;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: color.shade400),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: color.shade500,
                height: 1.4,
              ),
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

  // Action Methods
  Future<void> _viewAppointmentDetails(Map<String, dynamic> appointment) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildAppointmentDetailsModal(appointment),
    );
  }

  Widget _buildAppointmentDetailsModal(Map<String, dynamic> appointment) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Appointment Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        'Patient Name',
                        appointment['patientName'],
                      ),
                      _buildDetailRow(
                        'Patient UHID',
                        appointment['patientUhid'],
                      ),
                      _buildDetailRow('Gender', appointment['patientGender']),
                      _buildDetailRow(
                        'Age',
                        '${appointment['patientAge']} years',
                      ),
                      _buildDetailRow('State', appointment['patientState']),
                      _buildDetailRow(
                        'Appointment ID',
                        appointment['appointmentId'],
                      ),
                      _buildDetailRow('Date', appointment['appointmentDate']),
                      _buildDetailRow('Time', appointment['appointmentTime']),
                      _buildDetailRow('Reason', appointment['reason']),
                      _buildDetailRow(
                        'Consultation Fee',
                        '₹${appointment['consultationFee']}',
                      ),
                      _buildDetailRow(
                        'Status',
                        appointment['status'].toString().toUpperCase(),
                      ),
                      if (appointment['rejectionReason'] != null)
                        _buildDetailRow(
                          'Rejection Reason',
                          appointment['rejectionReason'],
                        ),
                      _buildDetailRow(
                        'Booked At',
                        _formatDateTime(appointment['bookedAt']),
                      ),
                      _buildDetailRow(
                        'Last Updated',
                        _formatDateTime(appointment['updatedAt']),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(child: Text(value ?? 'N/A', style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  Future<void> _approveAppointment(Map<String, dynamic> appointment) async {
    try {
      _showLoadingDialog('Approving appointment...');

      final response = await http.put(
        Uri.parse(
          '${AppConstants.baseUrl}/doctor-appointments/approve/${appointment['appointmentId']}',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      Navigator.pop(context); // Close loading dialog

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
      Navigator.pop(context); // Close loading dialog
      _showErrorSnackBar('Network error: $error');
    }
  }

  Future<void> _rejectAppointment(Map<String, dynamic> appointment) async {
    final reason = await _showRejectReasonDialog();
    if (reason == null) return; // User cancelled

    try {
      _showLoadingDialog('Rejecting appointment...');

      final response = await http.put(
        Uri.parse(
          '${AppConstants.baseUrl}/doctor-appointments/reject/${appointment['appointmentId']}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'reason': reason}),
      );

      Navigator.pop(context); // Close loading dialog

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
      Navigator.pop(context); // Close loading dialog
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
            child: Text('Reject'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptRejectedAppointment(
    Map<String, dynamic> appointment,
  ) async {
    try {
      _showLoadingDialog('Re-accepting appointment...');

      final response = await http.put(
        Uri.parse(
          '${AppConstants.baseUrl}/doctor-appointments/accept-rejected/${appointment['appointmentId']}',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      Navigator.pop(context); // Close loading dialog

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
      Navigator.pop(context); // Close loading dialog
      _showErrorSnackBar('Network error: $error');
    }
  }

  Future<void> _markAsCompleted(Map<String, dynamic> appointment) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mark as Complete'),
        content: Text(
          'Are you sure you want to mark this appointment as completed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Complete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      _showLoadingDialog('Marking appointment as completed...');

      // Use the existing appointment status update endpoint
      final response = await http.put(
        Uri.parse(
          '${AppConstants.baseUrl}/appointments/${appointment['appointmentId']}/status',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': 'completed'}),
      );

      Navigator.pop(context); // Close loading dialog

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          _showSuccessSnackBar('Appointment marked as completed');
          _loadAllData(); // Refresh all data
        } else {
          _showErrorSnackBar(
            data['message'] ?? 'Failed to update appointment status',
          );
        }
      } else {
        _showErrorSnackBar('Server error: ${response.statusCode}');
      }
    } catch (error) {
      Navigator.pop(context); // Close loading dialog
      _showErrorSnackBar('Network error: $error');
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
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
