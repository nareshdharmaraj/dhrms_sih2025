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
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => setState(() => selectedHospital = null),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Doctor',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    Text(
                      selectedHospital!['name'],
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Search and Filter Section
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search doctors by name or specialization',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                    _filterDoctors();
                  });
                },
              ),
              SizedBox(height: 12),
              
              // Filters Row
              Row(
                children: [
                  // Specialization Filter
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedSpecialization,
                      decoration: InputDecoration(
                        labelText: 'Specialization',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: _getSpecializations().map((spec) {
                        return DropdownMenuItem<String>(
                          value: spec,
                          child: Text(spec),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSpecialization = value!;
                          _filterDoctors();
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  
                  // Fee Range Filter
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showFeeFilterDialog,
                      icon: Icon(Icons.tune),
                      label: Text('Fee Range'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        
        // Doctors List
        Expanded(
          child: isLoadingDoctors
              ? Center(child: CircularProgressIndicator())
              : filteredDoctors.isEmpty
                  ? _buildEmptyState('No doctors found', Icons.person_search)
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredDoctors.length,
                      itemBuilder: (context, index) {
                        return _buildDoctorCard(filteredDoctors[index]);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildAppointmentBooking() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with back button
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => setState(() => selectedDoctor = null),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Book Appointment',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    Text(
                      'Dr. ${selectedDoctor!['doctorName']}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          
          // Doctor Summary Card
          _buildSelectedDoctorSummary(),
          SizedBox(height: 20),
          
          // Date Selection
          _buildDateSelection(),
          SizedBox(height: 20),
          
          // Time Selection
          _buildTimeSelection(),
          SizedBox(height: 20),
          
          // Reason for Visit
          _buildReasonInput(),
          SizedBox(height: 30),
          
          // Book Button
          CustomButton(
            text: isBooking ? 'Booking...' : 'Book Appointment',
            onPressed: isBooking ? null : _bookAppointment,
            isLoading: isBooking,
          ),
        ],
      ),
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
            
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _selectDoctor(doctor),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                ),
                child: Text('Select Doctor'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDoctorSummary() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.green.shade100,
              child: Text(
                _getInitials(selectedDoctor!['doctorName'] ?? 'Doctor'),
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. ${selectedDoctor!['doctorName'] ?? 'Unknown'}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    selectedDoctor!['specialization'] ?? 'General',
                    style: TextStyle(color: Colors.blue.shade600),
                  ),
                  Text(
                    selectedHospital!['name'],
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              '₹${selectedDoctor!['consultationFee'] ?? 500}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Appointment Booking Widget
  Widget _buildAppointmentBooking() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _selectDate,
            icon: Icon(Icons.calendar_today),
            label: Text(
              selectedDate == null 
                  ? 'Choose Date' 
                  : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.centerLeft,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Time',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: availableTimes.length,
          itemBuilder: (context, index) {
            String time = availableTimes[index];
            bool isSelected = selectedTime == time;
            
            return ElevatedButton(
              onPressed: () => setState(() => selectedTime = time),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Colors.blue.shade600 : Colors.grey.shade200,
                foregroundColor: isSelected ? Colors.white : Colors.black87,
              ),
              child: Text(
                time,
                style: TextStyle(fontSize: 12),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReasonInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reason for Visit',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _reasonController,
          decoration: InputDecoration(
            hintText: 'Describe your symptoms or reason for visit',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          maxLines: 3,
          onChanged: (value) => appointmentReason = value,
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
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

  // Missing helper functions
  Widget _buildHospitalSelection() {
    return Column(
      children: [
        Expanded(
          child: isLoadingHospitals
              ? const Center(child: CircularProgressIndicator())
              : hospitals.isEmpty
                  ? _buildEmptyState('No hospitals found', Icons.local_hospital)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: hospitals.length,
                      itemBuilder: (context, index) {
                        return _buildHospitalCard(hospitals[index]);
                      },
                    ),
        ),
      ],
    );
  }

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
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _myAppointmentsSearchController,
                  decoration: InputDecoration(
                    hintText: 'Search appointments...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  onChanged: (value) {
                    setState(() {
                      myAppointmentsSearchQuery = value;
                    });
                    _filterMyAppointments();
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: appointmentStatusFilter,
                  decoration: InputDecoration(
                    labelText: 'Filter by Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: ['All', 'Pending', 'Confirmed', 'Cancelled', 'Completed']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      appointmentStatusFilter = value!;
                    });
                    _filterMyAppointments();
                  },
                ),
              ],
            ),
          ),
          // Appointments List
          Expanded(
            child: isLoadingMyAppointments
                ? const Center(child: CircularProgressIndicator())
                : filteredMyAppointments.isEmpty
                    ? _buildEmptyState('No appointments found', Icons.event_busy)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredMyAppointments.length,
                        itemBuilder: (context, index) {
                          return _buildAppointmentCard(filteredMyAppointments[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
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
            color: _getStatusColor(appointment['status']).withOpacity(0.2),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            Icons.medical_services,
            color: _getStatusColor(appointment['status']),
            size: 25,
          ),
        ),
        title: Text(
          'Dr. ${appointment['doctorName'] ?? 'Unknown'}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(appointment['hospitalName'] ?? 'Hospital'),
            const SizedBox(height: 4),
            Text('${appointment['appointmentDate']} at ${appointment['appointmentTime']}'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(appointment['status']),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                appointment['status'] ?? 'Unknown',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Handle appointment details
        },
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildCompactSpecializationChip(String specialization) {
    bool isSelected = selectedSpecialization == specialization;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          specialization,
          style: TextStyle(
            fontSize: 11,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedSpecialization = specialization;
          });
          _filterDoctors();
        },
        backgroundColor: Colors.grey.shade100,
        selectedColor: const Color(0xFF2196F3),
        checkmarkColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _selectDoctor(Map<String, dynamic> doctor) {
    setState(() {
      selectedDoctor = doctor;
    });
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.blue.shade100,
          child: Text(
            _getInitials(doctor['doctorName'] ?? 'Dr'),
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          'Dr. ${doctor['doctorName'] ?? 'Unknown'}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              doctor['specialization'] ?? 'General',
              style: TextStyle(color: Colors.blue.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              '₹${doctor['consultationFee'] ?? 500}',
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _selectDoctor(doctor),
      ),
    );
  }

  List<String> _getSpecializations() {
    Set<String> specializations = {'All'};
    for (var doctor in doctors) {
      if (doctor['specialization'] != null) {
        specializations.add(doctor['specialization']);
      }
    }
    return specializations.toList();
  }

  void _showFeeFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fee Range Filter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('₹${feeRange.start.round()} - ₹${feeRange.end.round()}'),
            RangeSlider(
              values: feeRange,
              min: 0,
              max: 5000,
              divisions: 50,
              onChanged: (values) {
                setState(() {
                  feeRange = values;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _filterDoctors();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
