import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_constants.dart';

class PatientAppointmentBookingScreen extends StatefulWidget {
  final Map<String, dynamic> patientData;

  const PatientAppointmentBookingScreen({super.key, required this.patientData});

  @override
  _PatientAppointmentBookingScreenState createState() =>
      _PatientAppointmentBookingScreenState();
}

class _PatientAppointmentBookingScreenState
    extends State<PatientAppointmentBookingScreen>
    with TickerProviderStateMixin {
  // Tab Controller
  late TabController _tabController;

  // New Booking Tab Data
  List<dynamic> hospitals = [];
  List<dynamic> doctors = [];
  List<dynamic> filteredDoctors = [];
  Map<String, dynamic>? selectedHospital;
  Map<String, dynamic>? selectedDoctor;
  String searchQuery = '';
  String selectedSpecialization = 'All';
  RangeValues feeRange = RangeValues(0, 5000);
  DateTime? selectedDate;
  String? selectedTime;
  String appointmentReason = '';

  // My Bookings Tab Data
  List<dynamic> myAppointments = [];
  List<dynamic> filteredMyAppointments = [];
  String appointmentStatusFilter = 'All';
  String myAppointmentsSearchQuery = '';

  // Loading States
  bool isLoadingHospitals = true;
  bool isLoadingDoctors = false;
  bool isBooking = false;
  bool isLoadingMyAppointments = true;

  // UI States
  bool isFilterExpanded = false;
  bool isDoctorFilterExpanded = false;
  bool isNotificationPanelOpen = false;

  // Controllers
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _myAppointmentsSearchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHospitals();
    _loadMyAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _reasonController.dispose();
    _myAppointmentsSearchController.dispose();
    super.dispose();
  }

  List<String> availableTimes = [
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '02:00 PM',
    '02:30 PM',
    '03:00 PM',
    '03:30 PM',
    '04:00 PM',
    '04:30 PM',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.medical_services, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Appointments',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Book & Manage',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2196F3), Color(0xFF1976D2), Color(0xFF0D47A1)],
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () {
                setState(() {
                  isNotificationPanelOpen = !isNotificationPanelOpen;
                });
              },
              icon: Stack(
                children: [
                  Icon(
                    isNotificationPanelOpen
                        ? Icons.notifications
                        : Icons.notifications_outlined,
                    size: 28,
                    color: isNotificationPanelOpen
                        ? Colors.blue.shade600
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: const Text(
                        '2',
                        style: TextStyle(color: Colors.white, fontSize: 8),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [_buildNewBookingTab(), _buildMyAppointmentsTab()],
          ),
          // Notification Panel Overlay
          if (isNotificationPanelOpen) ...[
            // Background overlay to close panel
            GestureDetector(
              onTap: () {
                setState(() {
                  isNotificationPanelOpen = false;
                });
              },
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
            _buildNotificationPanel(),
          ],
        ],
      ),
      bottomNavigationBar: Container(
        height: 60, // Reduced height
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 2,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 10, // Reduced font size
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 10,
          ),
          tabs: [
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 4,
              ), // Reduced padding
              child: const Tab(
                icon: Icon(
                  Icons.add_circle_outline,
                  size: 20,
                ), // Reduced icon size
                text: 'New Booking',
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: const Tab(
                icon: Icon(Icons.bookmark_outline, size: 20),
                text: 'My Appointments',
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: FloatingActionButton.extended(
          onPressed: () {
            // Quick emergency booking
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.emergency,
                          color: Colors.red,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Emergency Booking',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  content: const Text(
                    'For emergency appointments, please call our 24/7 helpline or visit the nearest emergency department.',
                    style: TextStyle(fontSize: 16),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Add emergency call functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Emergency services: 102 | Ambulance: 108',
                            ),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 4),
                          ),
                        );
                      },
                      icon: const Icon(Icons.phone, color: Colors.white),
                      label: const Text(
                        'Call Now',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          elevation: 8,
          icon: const Icon(Icons.emergency, size: 24),
          label: const Text(
            'Emergency',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // New Booking Tab
  Widget _buildNewBookingTab() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8FFFE), Color(0xFFFFFFFF)],
        ),
      ),
      child: Column(
        children: [
          // Compact Header with patient info
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 4), // Reduced margins
            padding: const EdgeInsets.all(12), // Reduced padding
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
              ),
              borderRadius: BorderRadius.circular(12), // Reduced border radius
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40, // Reduced size
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20, // Reduced icon size
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.patientData['name'] ?? 'Patient',
                        style: const TextStyle(
                          fontSize: 16, // Reduced font size
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'UHID: ${widget.patientData['uhid'] ?? 'N/A'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11, // Reduced font size
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6), // Reduced padding
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.medical_services,
                    color: Colors.white,
                    size: 18, // Reduced icon size
                  ),
                ),
              ],
            ),
          ),

          // Compact Progress Indicator
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ), // Reduced vertical margin
            child: Row(
              children: [
                _buildStepIndicator(
                  step: 1,
                  title: 'Hospital',
                  isActive: selectedHospital == null,
                  isCompleted: selectedHospital != null,
                ),
                Expanded(
                  child: Container(
                    height: 1.5, // Reduced height
                    color: selectedHospital != null
                        ? Colors.green
                        : Colors.grey.shade300,
                  ),
                ),
                _buildStepIndicator(
                  step: 2,
                  title: 'Doctor',
                  isActive: selectedHospital != null && selectedDoctor == null,
                  isCompleted: selectedDoctor != null,
                ),
                Expanded(
                  child: Container(
                    height: 1.5,
                    color: selectedDoctor != null
                        ? Colors.green
                        : Colors.grey.shade300,
                  ),
                ),
                _buildStepIndicator(
                  step: 3,
                  title: 'Book',
                  isActive: selectedDoctor != null,
                  isCompleted: false,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8), // Reduced spacing
          // Main content
          Expanded(
            child: selectedHospital == null
                ? _buildHospitalSelection()
                : selectedDoctor == null
                ? _buildDoctorSelection()
                : _buildAppointmentBooking(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator({
    required int step,
    required String title,
    required bool isActive,
    required bool isCompleted,
  }) {
    return Column(
      children: [
        Container(
          width: 24, // Reduced size
          height: 24,
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green
                : isActive
                ? const Color(0xFF2196F3)
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive || isCompleted
                ? [
                    BoxShadow(
                      color:
                          (isCompleted ? Colors.green : const Color(0xFF2196F3))
                              .withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            isCompleted
                ? Icons.check
                : step == 1
                ? Icons.looks_one_outlined
                : step == 2
                ? Icons.looks_two_outlined
                : Icons.looks_3_outlined,
            color: isActive || isCompleted
                ? Colors.white
                : Colors.grey.shade600,
            size: 14.0, // Reduced icon size
          ),
        ),
        const SizedBox(height: 2), // Reduced spacing
        Text(
          title,
          style: TextStyle(
            fontSize: 9, // Reduced font size
            fontWeight: FontWeight.w500,
            color: isActive || isCompleted
                ? const Color(0xFF2196F3)
                : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // My Appointments Tab
  Widget _buildMyAppointmentsTab() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8FFFE), Color(0xFFFFFFFF)],
        ),
      ),
      child: Column(
        children: [
          // Compact Stats Header
          Container(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 4), // Reduced margins
            padding: const EdgeInsets.all(12), // Reduced padding
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
              ),
              borderRadius: BorderRadius.circular(12), // Reduced border radius
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total',
                  myAppointments.length.toString(),
                  Icons.calendar_today,
                ),
                Container(
                  width: 1,
                  height: 24, // Reduced height
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildStatItem(
                  'Pending',
                  myAppointments
                      .where((apt) => apt['status'] == 'pending')
                      .length
                      .toString(),
                  Icons.schedule,
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildStatItem(
                  'Completed',
                  myAppointments
                      .where((apt) => apt['status'] == 'completed')
                      .length
                      .toString(),
                  Icons.check_circle,
                ),
              ],
            ),
          ),

          // Compact Search and Collapsible Filter Bar
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ), // Reduced margins
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Compact Search Bar with Filter Toggle
                Container(
                  padding: const EdgeInsets.all(12), // Reduced padding
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40, // Fixed compact height
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: TextField(
                            controller: _myAppointmentsSearchController,
                            decoration: InputDecoration(
                              hintText: 'Search appointments...',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey.shade500,
                                size: 20,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                myAppointmentsSearchQuery = value;
                              });
                              _filterMyAppointments();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Filter Toggle Button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isFilterExpanded = !isFilterExpanded;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isFilterExpanded
                                ? const Color(0xFF2196F3)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isFilterExpanded
                                  ? const Color(0xFF2196F3)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Icon(
                            isFilterExpanded ? Icons.filter_list : Icons.tune,
                            color: isFilterExpanded
                                ? Colors.white
                                : Colors.grey.shade600,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Collapsible Status Filter
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: isFilterExpanded
                      ? 60
                      : 0, // Compact height when expanded
                  child: isFilterExpanded
                      ? Container(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildCompactStatusChip(
                                  'All',
                                  Icons.list_alt,
                                  const Color(0xFF2196F3),
                                ),
                                _buildCompactStatusChip(
                                  'pending',
                                  Icons.schedule,
                                  const Color(0xFFFF9800),
                                ),
                                _buildCompactStatusChip(
                                  'approved',
                                  Icons.check_circle_outline,
                                  const Color(0xFF4CAF50),
                                ),
                                _buildCompactStatusChip(
                                  'rejected',
                                  Icons.cancel_outlined,
                                  const Color(0xFFF44336),
                                ),
                                _buildCompactStatusChip(
                                  'completed',
                                  Icons.done_all,
                                  const Color(0xFF9C27B0),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8), // Reduced spacing
          // Appointments List
          Expanded(
            child: isLoadingMyAppointments
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF2196F3),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading your appointments...',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : filteredMyAppointments.isEmpty
                ? _buildEmptyAppointmentsState()
                : _buildAppointmentsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4), // Reduced padding
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 16, // Reduced icon size
          ),
        ),
        const SizedBox(height: 4), // Reduced spacing
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16, // Reduced font size
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 10, // Reduced font size
          ),
        ),
      ],
    );
  }

  Widget _buildCompactStatusChip(String status, IconData icon, Color color) {
    final isSelected = appointmentStatusFilter == status;
    return Container(
      margin: const EdgeInsets.only(right: 6), // Reduced margin
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12, // Reduced icon size
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 3), // Reduced spacing
            Text(
              status == 'All'
                  ? status
                  : status.substring(0, 3).toUpperCase(), // Shortened text
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w600,
                fontSize: 10, // Reduced font size
              ),
            ),
          ],
        ),
        onSelected: (selected) {
          setState(() {
            appointmentStatusFilter = status;
          });
          _filterMyAppointments();
        },
        selectedColor: color,
        backgroundColor: color.withOpacity(0.1),
        elevation: isSelected ? 2 : 0,
        pressElevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Reduced border radius
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
    );
  }

  Widget _buildEmptyAppointmentsState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2196F3).withOpacity(0.1),
                    const Color(0xFF1976D2).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                size: 50,
                color: Color(0xFF2196F3),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Appointments Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start your healthcare journey by booking\nyour first appointment with our expert doctors',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2196F3).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  _tabController.animateTo(0);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Book Your First Appointment',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return RefreshIndicator(
      onRefresh: _loadMyAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ), // Reduced padding
        itemCount: filteredMyAppointments.length,
        itemBuilder: (context, index) {
          final appointment = filteredMyAppointments[index];
          return _buildAppointmentCard(appointment);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    Color statusColor = _getStatusColor(appointment['status']);
    IconData statusIcon = _getStatusIcon(appointment['status']);

    return Container(
      margin: const EdgeInsets.only(bottom: 8), // Reduced margin
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(12), // Reduced border radius
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: statusColor.withOpacity(0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12), // Reduced padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact Header with doctor info and status
            Row(
              children: [
                Container(
                  width: 32, // Reduced size
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF2196F3).withOpacity(0.8),
                        const Color(0xFF1976D2).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2196F3).withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_hospital,
                    color: Colors.white,
                    size: 16, // Reduced icon size
                  ),
                ),
                const SizedBox(width: 10), // Reduced spacing
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment['doctorName'] ?? 'Doctor',
                        style: const TextStyle(
                          fontSize: 14, // Reduced font size
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 2), // Reduced spacing
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 10, // Reduced icon size
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              appointment['hospitalName'] ?? 'Hospital',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11, // Reduced font size
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, // Reduced padding
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [statusColor, statusColor.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Reduced border radius
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.2),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 12,
                        color: Colors.white,
                      ), // Reduced icon size
                      const SizedBox(width: 3), // Reduced spacing
                      Text(
                        appointment['status']
                            .substring(0, 3)
                            .toUpperCase(), // Shortened text
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9, // Reduced font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8), // Reduced spacing
            // Compact Date and Time Section
            Container(
              padding: const EdgeInsets.all(8), // Reduced padding
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4), // Reduced padding
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.schedule,
                      size: 14, // Reduced icon size
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(width: 8), // Reduced spacing
                  Expanded(
                    child: Text(
                      '${appointment['appointmentDate']} at ${appointment['appointmentTime']}',
                      style: const TextStyle(
                        fontSize: 12, // Reduced font size
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8), // Reduced spacing
            // Compact Bottom Info Section
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(6), // Reduced padding
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ID',
                          style: TextStyle(
                            fontSize: 8, // Reduced font size
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          appointment['appointmentId']?.substring(0, 12) ??
                              'N/A', // Shortened ID
                          style: const TextStyle(
                            fontSize: 10, // Reduced font size
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Reduced spacing
                Container(
                  padding: const EdgeInsets.all(6), // Reduced padding
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withOpacity(0.2),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Fee',
                        style: TextStyle(
                          fontSize: 8, // Reduced font size
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '₹${appointment['consultationFee']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12, // Reduced font size
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (appointment['reason'] != null &&
                appointment['reason'].isNotEmpty) ...[
              const SizedBox(height: 6), // Reduced spacing
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(6), // Reduced padding
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.note_alt_outlined,
                      size: 12, // Reduced icon size
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 4), // Reduced spacing
                    Expanded(
                      child: Text(
                        appointment['reason'],
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 11, // Reduced font size
                          height: 1.2,
                        ),
                        maxLines: 2, // Limit lines
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
        return Icons.schedule;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.help;
    }
  }

  // Hospital Selection Widget
  Widget _buildHospitalSelection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Hospital',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a hospital to view available doctors',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),

        Expanded(
          child: isLoadingHospitals
              ? const Center(child: CircularProgressIndicator())
              : hospitals.isEmpty
              ? const Center(child: Text('No hospitals available'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: hospitals.length,
                  itemBuilder: (context, index) {
                    final hospital = hospitals[index];
                    return _buildHospitalCard(hospital);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHospitalCard(Map<String, dynamic> hospital) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            Icons.local_hospital,
            color: Colors.blue.shade700,
            size: 25,
          ),
        ),
        title: Text(
          hospital['hospitalName'] ?? 'Hospital',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              hospital['location']?['address'] ?? 'Address not available',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              hospital['contactInfo']?['phone'] ?? 'Phone not available',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          final hospitalId = hospital['hospitalId'] ?? hospital['_id'];
          print(
            '🏥 Hospital selected: ${hospital['hospitalName'] ?? hospital['name']}',
          );
          print('🆔 Hospital ID: $hospitalId');
          print('📊 Hospital data keys: ${hospital.keys.toList()}');

          setState(() {
            selectedHospital = hospital;
          });
          _loadDoctors(hospitalId);
        },
      ),
    );
  }

  // Doctor Selection Widget
  Widget _buildDoctorSelection() {
    return Column(
      children: [
        // Compact Header with selected hospital
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ), // Reduced padding
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              Container(
                width: 32, // Smaller back button
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(() {
                      selectedHospital = null;
                      doctors.clear();
                      filteredDoctors.clear();
                    });
                  },
                  icon: const Icon(Icons.arrow_back, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedHospital?['hospitalName'] ?? 'Hospital',
                      style: const TextStyle(
                        fontSize: 14, // Reduced font size
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      'Select a doctor',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ), // Reduced font size
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Compact Search and Collapsible Filter Section
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Compact Search Bar with Filter Toggle
              Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 36, // Very compact height
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search doctors...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey.shade500,
                              size: 18,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                            _filterDoctors();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Filter Toggle Button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isDoctorFilterExpanded = !isDoctorFilterExpanded;
                        });
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isDoctorFilterExpanded
                              ? const Color(0xFF2196F3)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDoctorFilterExpanded
                                ? const Color(0xFF2196F3)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Icon(
                          isDoctorFilterExpanded
                              ? Icons.filter_list
                              : Icons.tune,
                          color: isDoctorFilterExpanded
                              ? Colors.white
                              : Colors.grey.shade600,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Collapsible Filter Section - ONLY shows when expanded
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: isDoctorFilterExpanded ? null : 0,
                child: isDoctorFilterExpanded
                    ? Container(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Compact Specialization Filter
                            const Text(
                              'Specialization',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildCompactSpecializationChip('All'),
                                  _buildCompactSpecializationChip('Cardiology'),
                                  _buildCompactSpecializationChip(
                                    'Dermatology',
                                  ),
                                  _buildCompactSpecializationChip('Pediatrics'),
                                  _buildCompactSpecializationChip(
                                    'Orthopedics',
                                  ),
                                  _buildCompactSpecializationChip('Neurology'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Compact Fee Range Filter
                            Row(
                              children: [
                                const Text(
                                  'Fee: ',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '₹${feeRange.start.round()}-₹${feeRange.end.round()}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 30, // Very compact slider
                              child: RangeSlider(
                                values: feeRange,
                                min: 0,
                                max: 5000,
                                divisions: 50,
                                onChanged: (values) {
                                  setState(() {
                                    feeRange = values;
                                  });
                                  _filterDoctors();
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // Doctors List - Maximum space
        Expanded(
          child: isLoadingDoctors
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF2196F3),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading doctors...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : filteredDoctors.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_search, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No doctors found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      Text(
                        'Try adjusting your filters',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ), // Minimal padding
                  itemCount: filteredDoctors.length,
                  itemBuilder: (context, index) {
                    final doctor = filteredDoctors[index];
                    return _buildCompactDoctorCard(doctor);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCompactSpecializationChip(String specialization) {
    bool isSelected = selectedSpecialization == specialization;
    return Padding(
      padding: const EdgeInsets.only(right: 6), // Reduced padding
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedSpecialization = specialization;
          });
          _filterDoctors();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ), // Compact padding
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16), // Smaller radius
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2196F3)
                  : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Text(
            specialization,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontSize: 10, // Smaller font
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactDoctorCard(Map<String, dynamic> doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8), // Reduced margin
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10), // Smaller radius
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedDoctor = doctor;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(10), // Compact padding
          child: Row(
            children: [
              // Compact Avatar
              Container(
                width: 40, // Smaller avatar
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Center(
                  child: Text(
                    _getInitials(doctor['doctorName'] ?? 'Dr'),
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 14, // Smaller font
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Doctor Info - Compact Layout
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor Name
                    Text(
                      doctor['doctorName'] ?? 'Doctor',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14, // Smaller font
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Specialization
                    Text(
                      doctor['specialization'] ?? 'General',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w500,
                        fontSize: 11, // Smaller font
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Experience, Rating, and Fee in one row
                    Row(
                      children: [
                        // Experience
                        Text(
                          '${doctor['experience'] ?? 0}y',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Rating
                        Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.orange.shade400,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${doctor['rating'] ?? 4.5}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                        ),
                        const Spacer(),

                        // Fee
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            '₹${doctor['consultationFee'] ?? 500}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Selection indicator
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Appointment Booking Widget
  Widget _buildAppointmentBooking() {
    return Column(
      children: [
        // Compact Header with selected doctor
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ), // Reduced padding
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade50, Colors.green.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              Container(
                width: 32, // Smaller back button
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(() {
                      selectedDoctor = null;
                    });
                  },
                  icon: const Icon(Icons.arrow_back, size: 18),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 36, // Smaller avatar
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Center(
                  child: Text(
                    _getInitials(selectedDoctor?['doctorName'] ?? 'Dr'),
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 14, // Smaller font
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedDoctor?['doctorName'] ?? 'Doctor',
                      style: const TextStyle(
                        fontSize: 15, // Reduced font size
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Text(
                            '${selectedDoctor?['specialization']}',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            '₹${selectedDoctor?['consultationFee']}',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ), // Reduced padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Compact Date Selection Card
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Section Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.event,
                              size: 18,
                              color: Colors.blue.shade600,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Appointment Date',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Date Selector
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: InkWell(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now().add(
                                const Duration(days: 1),
                              ),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 30),
                              ),
                            );
                            if (picked != null) {
                              setState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(
                              12,
                            ), // Reduced padding
                            decoration: BoxDecoration(
                              color: selectedDate != null
                                  ? Colors.blue.shade50
                                  : Colors.grey.shade50,
                              border: Border.all(
                                color: selectedDate != null
                                    ? Colors.blue.shade200
                                    : Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: selectedDate != null
                                      ? Colors.blue.shade600
                                      : Colors.grey.shade600,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  selectedDate != null
                                      ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                      : 'Select appointment date',
                                  style: TextStyle(
                                    fontSize: 14, // Reduced font size
                                    color: selectedDate != null
                                        ? Colors.blue.shade700
                                        : Colors.grey.shade600,
                                    fontWeight: selectedDate != null
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.grey.shade600,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Compact Time Selection Card
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time Section Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 18,
                              color: Colors.orange.shade600,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Available Time Slots',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Time Slots
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Wrap(
                          spacing: 6, // Reduced spacing
                          runSpacing: 6,
                          children: availableTimes.map((time) {
                            bool isSelected = selectedTime == time;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedTime = time;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12, // Reduced padding
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.orange.shade600
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(
                                    16,
                                  ), // Smaller radius
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.orange.shade600
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  time,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12, // Smaller font
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Compact Reason for Visit Card
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Reason Section Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_note,
                              size: 18,
                              color: Colors.purple.shade600,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Reason for Visit',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Reason Text Field
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: TextField(
                          controller: _reasonController,
                          maxLines: 2, // Reduced lines
                          decoration: InputDecoration(
                            hintText: 'Describe your symptoms or reason...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.purple.shade300,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.all(
                              12,
                            ), // Reduced padding
                          ),
                          style: const TextStyle(fontSize: 13), // Smaller font
                          onChanged: (value) {
                            appointmentReason = value;
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Enhanced Book Appointment Button
                Container(
                  width: double.infinity,
                  height: 50, // Fixed height
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade600, Colors.green.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed:
                        selectedDate != null &&
                            selectedTime != null &&
                            !isBooking
                        ? _bookAppointment
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isBooking
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Booking...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.calendar_today, size: 18),
                              const SizedBox(width: 8),
                              const Text(
                                'Book Appointment',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 16), // Bottom padding
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    List<String> nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else {
      return name.length >= 2
          ? name.substring(0, 2).toUpperCase()
          : name.toUpperCase();
    }
  }

  // Notification Panel Widget
  Widget _buildNotificationPanel() {
    return Positioned(
      top: 0,
      right: 0,
      left: 0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.only(top: 8, left: 8, right: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Notification Panel Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications,
                      color: Colors.blue.shade600,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isNotificationPanelOpen = false;
                        });
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Notification Content
              Container(
                constraints: const BoxConstraints(
                  maxHeight: 300, // Limit height to prevent overflow
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Empty State
                      Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Icon(
                                Icons.notifications_off_outlined,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No Notifications',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'You\'ll receive notifications about appointments,\nreminders, and updates here.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      // Future: Add notification items here
                      // _buildNotificationItem(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Load Hospitals
  Future<void> _loadHospitals() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/hospitals'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          hospitals = data;
          isLoadingHospitals = false;
        });
      } else {
        throw Exception('Failed to load hospitals');
      }
    } catch (e) {
      print('Error loading hospitals: $e');
      setState(() => isLoadingHospitals = false);
    }
  }

  // Load Doctors for selected hospital
  Future<void> _loadDoctors(String hospitalId) async {
    setState(() {
      isLoadingDoctors = true;
      doctors.clear();
      filteredDoctors.clear();
    });

    try {
      final url = '${AppConstants.baseUrl}/doctors/hospital/$hospitalId';
      print('🏥 Loading doctors for hospital: $hospitalId');
      print('🌐 Full URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Doctors loaded: ${data.length} doctors found');

        setState(() {
          doctors = data;
          filteredDoctors = data;
          isLoadingDoctors = false;
        });
      } else {
        print('❌ Failed to load doctors - Status: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        throw Exception(
          'Failed to load doctors - Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('💥 Error loading doctors: $e');
      setState(() => isLoadingDoctors = false);
    }
  }

  // Filter doctors based on search and filters
  void _filterDoctors() {
    setState(() {
      filteredDoctors = doctors.where((doctor) {
        // Search filter
        bool matchesSearch =
            searchQuery.isEmpty ||
            doctor['doctorName'].toLowerCase().contains(
              searchQuery.toLowerCase(),
            ) ||
            doctor['specialization'].toLowerCase().contains(
              searchQuery.toLowerCase(),
            );

        // Specialization filter
        bool matchesSpecialization =
            selectedSpecialization == 'All' ||
            doctor['specialization'] == selectedSpecialization;

        // Fee range filter
        double fee = double.tryParse(doctor['consultationFee'].toString()) ?? 0;
        bool matchesFeeRange = fee >= feeRange.start && fee <= feeRange.end;

        return matchesSearch && matchesSpecialization && matchesFeeRange;
      }).toList();
    });
  }

  // Book appointment
  Future<void> _bookAppointment() async {
    setState(() => isBooking = true);

    try {
      // Validate required data before creating appointment
      final patientId = widget.patientData['uhid'] ?? widget.patientData['_id'];
      final patientName =
          widget.patientData['name'] ?? widget.patientData['fullName'];
      final doctorId = selectedDoctor!['doctorId'] ?? selectedDoctor!['_id'];
      final doctorName =
          selectedDoctor!['doctorName'] ?? selectedDoctor!['name'];
      final hospitalId =
          selectedHospital!['hospitalId'] ?? selectedHospital!['_id'];
      final hospitalName =
          selectedHospital!['hospitalName'] ?? selectedHospital!['name'];
      final consultationFee = selectedDoctor!['consultationFee'] ?? 500;

      // Validation checks
      if (patientId == null || patientId.toString().isEmpty) {
        throw Exception('Patient ID is missing');
      }
      if (patientName == null || patientName.toString().isEmpty) {
        throw Exception('Patient name is missing');
      }
      if (doctorId == null || doctorId.toString().isEmpty) {
        throw Exception('Doctor ID is missing');
      }
      if (doctorName == null || doctorName.toString().isEmpty) {
        throw Exception('Doctor name is missing');
      }
      if (hospitalId == null || hospitalId.toString().isEmpty) {
        throw Exception('Hospital ID is missing');
      }
      if (hospitalName == null || hospitalName.toString().isEmpty) {
        throw Exception('Hospital name is missing');
      }
      if (selectedTime == null || selectedTime!.isEmpty) {
        throw Exception('Appointment time is missing');
      }

      final appointmentData = {
        'patientId': patientId,
        'patientName': patientName,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'hospitalId': hospitalId,
        'hospitalName': hospitalName,
        'appointmentDate':
            '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
        'appointmentTime': selectedTime,
        'reason': appointmentReason.isEmpty
            ? 'General consultation'
            : appointmentReason,
        'consultationFee': consultationFee,
      };

      print('📅 Booking appointment with data: $appointmentData');
      print('🔗 API URL: ${AppConstants.baseUrl}/appointments');

      // Additional debugging
      print('🔍 Patient Data Available: ${widget.patientData.keys.toList()}');
      print('🔍 Selected Doctor Data: ${selectedDoctor?.keys.toList()}');
      print('🔍 Selected Hospital Data: ${selectedHospital?.keys.toList()}');
      print(
        '🔍 Full API URL: ${Uri.parse('${AppConstants.baseUrl}/appointments')}',
      );

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/appointments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(appointmentData),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 201) {
        print('✅ Appointment booking successful!');
        final responseData = json.decode(response.body);
        final appointmentId = responseData['appointmentId'];

        // Show success dialog
        _showBookingSuccessDialog(appointmentId);

        // Refresh appointments list
        _loadMyAppointments();

        // Reset form
        setState(() {
          selectedHospital = null;
          selectedDoctor = null;
          selectedDate = null;
          selectedTime = null;
          appointmentReason = '';
          _reasonController.clear();
        });
      } else {
        print(
          '❌ Appointment booking failed with status: ${response.statusCode}',
        );
        print('❌ Error response: ${response.body}');

        // Try to parse error response
        String errorMessage = 'Failed to book appointment';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (parseError) {
          errorMessage = 'Server error: ${response.statusCode}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );

        throw Exception(
          'Failed to book appointment - Status: ${response.statusCode} - $errorMessage',
        );
      }
    } catch (e) {
      print('❌ Exception in booking appointment: $e');

      // Only show snackbar if we haven't already shown one for HTTP errors
      if (!e.toString().contains('Failed to book appointment - Status:')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Network error: Please check your connection and try again.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() => isBooking = false);
    }
  }

  // Show booking success dialog
  void _showBookingSuccessDialog(String appointmentId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Appointment Booked Successfully!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your appointment has been booked successfully.'),
            const SizedBox(height: 8),
            Text(
              'Appointment ID: $appointmentId',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('Status: Pending (waiting for doctor approval)'),
            const SizedBox(height: 8),
            const Text(
              'You will be notified once the doctor approves your appointment.',
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _tabController.animateTo(1); // Switch to My Appointments tab
            },
            child: const Text('View My Appointments'),
          ),
        ],
      ),
    );
  }

  // Load patient's appointments
  Future<void> _loadMyAppointments() async {
    try {
      final patientId = widget.patientData['uhid'] ?? widget.patientData['_id'];
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/appointments/patient/$patientId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          myAppointments = data;
          filteredMyAppointments = data;
          isLoadingMyAppointments = false;
        });
      } else {
        throw Exception('Failed to load appointments');
      }
    } catch (e) {
      print('Error loading my appointments: $e');
      setState(() => isLoadingMyAppointments = false);
    }
  }

  // Filter my appointments by status and search query
  void _filterMyAppointments() {
    setState(() {
      filteredMyAppointments = myAppointments.where((appointment) {
        bool matchesStatus =
            appointmentStatusFilter == 'All' ||
            appointment['status'] == appointmentStatusFilter;
        bool matchesSearch =
            myAppointmentsSearchQuery.isEmpty ||
            appointment['doctorName'].toLowerCase().contains(
              myAppointmentsSearchQuery.toLowerCase(),
            ) ||
            appointment['hospitalName'].toLowerCase().contains(
              myAppointmentsSearchQuery.toLowerCase(),
            );
        return matchesStatus && matchesSearch;
      }).toList();
    });
  }
}
