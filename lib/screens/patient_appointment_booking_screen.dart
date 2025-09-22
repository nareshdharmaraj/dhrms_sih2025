import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_constants.dart';
import '../widgets/custom_button.dart';

class PatientAppointmentBookingScreen extends StatefulWidget {
  final Map<String, dynamic> patientData;

  const PatientAppointmentBookingScreen({super.key, required this.patientData});

  @override
  _PatientAppointmentBookingScreenState createState() =>
      _PatientAppointmentBookingScreenState();
}

class _PatientAppointmentBookingScreenState
    extends State<PatientAppointmentBookingScreen> {
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

  bool isLoadingHospitals = true;
  bool isLoadingDoctors = false;
  bool isBooking = false;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

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
  void initState() {
    super.initState();
    _loadHospitals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // App Header
          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade500],
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
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
                ],
              ),
            ),
          ),

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

  Widget _buildHospitalSelection() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Hospital',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Choose a hospital to book your appointment',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          SizedBox(height: 20),

          if (isLoadingHospitals)
            Center(child: CircularProgressIndicator())
          else if (hospitals.isEmpty)
            _buildEmptyState('No hospitals available', Icons.local_hospital)
          else
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: hospitals.length,
              itemBuilder: (context, index) {
                return _buildHospitalCard(hospitals[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDoctorSelection() {
    return Column(
      children: [
        // Header with back button
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
                      value: selectedSpecialization,
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
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(Icons.local_hospital, color: Colors.blue.shade700),
        ),
        title: Text(
          hospital['name'] ?? 'Unknown Hospital',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hospital['address'] ?? 'No address'),
            Text(hospital['contactNumber'] ?? 'No contact'),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _selectHospital(hospital),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.green.shade100,
                  child: Text(
                    _getInitials(doctor['doctorName'] ?? 'Doctor'),
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
                        'Dr. ${doctor['doctorName'] ?? 'Unknown'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        doctor['specialization'] ?? 'General',
                        style: TextStyle(color: Colors.blue.shade600),
                      ),
                      Text(
                        '${doctor['designation'] ?? 'Doctor'} • ${doctor['experienceYears'] ?? 0} years exp',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${doctor['consultationFee'] ?? 500}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Consultation',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),

            // Available Times Preview
            if (doctor['availableTimings'] != null)
              Wrap(
                spacing: 4,
                children: (doctor['availableTimings'] as List).take(3).map((
                  time,
                ) {
                  return Chip(
                    label: Text(
                      time.toString(),
                      style: TextStyle(fontSize: 10),
                    ),
                    backgroundColor: Colors.blue.shade50,
                  );
                }).toList(),
              ),

            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _selectDoctor(doctor),
                child: Text('Select Doctor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                ),
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

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        Container(
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
              child: Text(time, style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected
                    ? Colors.blue.shade600
                    : Colors.grey.shade200,
                foregroundColor: isSelected ? Colors.white : Colors.black87,
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
            Text(message, style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
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

  Future<void> _loadHospitals() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/hospital/list'),
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

  Future<void> _loadDoctors(String hospitalId) async {
    setState(() => isLoadingDoctors = true);

    try {
      final response = await http.get(
        Uri.parse(
          '${AppConstants.baseUrl}/appointments/hospitals/$hospitalId/doctors',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          doctors = data;
          filteredDoctors = data;
          isLoadingDoctors = false;
        });
        _filterDoctors();
      } else {
        throw Exception('Failed to load doctors');
      }
    } catch (e) {
      print('Error loading doctors: $e');
      setState(() => isLoadingDoctors = false);
    }
  }

  void _selectHospital(Map<String, dynamic> hospital) {
    setState(() {
      selectedHospital = hospital;
    });
    _loadDoctors(hospital['hospitalId'] ?? hospital['_id']);
  }

  void _selectDoctor(Map<String, dynamic> doctor) {
    setState(() {
      selectedDoctor = doctor;
    });
  }

  void _filterDoctors() {
    List<dynamic> filtered = doctors.where((doctor) {
      // Search filter
      bool matchesSearch =
          searchQuery.isEmpty ||
          doctor['doctorName'].toString().toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          doctor['specialization'].toString().toLowerCase().contains(
            searchQuery.toLowerCase(),
          );

      // Specialization filter
      bool matchesSpecialization =
          selectedSpecialization == 'All' ||
          doctor['specialization'] == selectedSpecialization;

      // Fee range filter
      int fee = int.tryParse(doctor['consultationFee'].toString()) ?? 0;
      bool matchesFee = fee >= feeRange.start && fee <= feeRange.end;

      return matchesSearch && matchesSpecialization && matchesFee;
    }).toList();

    setState(() {
      filteredDoctors = filtered;
    });
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
        title: Text('Filter by Consultation Fee'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Fee Range: ₹${feeRange.start.round()} - ₹${feeRange.end.round()}',
              ),
              RangeSlider(
                values: feeRange,
                min: 0,
                max: 5000,
                divisions: 50,
                onChanged: (values) => setDialogState(() => feeRange = values),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _filterDoctors();
              Navigator.pop(context);
            },
            child: Text('Apply'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _bookAppointment() async {
    if (selectedDate == null || selectedTime == null) {
      _showErrorDialog('Please select both date and time');
      return;
    }

    setState(() => isBooking = true);

    try {
      // Generate appointment ID
      final appointmentId = 'APT${DateTime.now().millisecondsSinceEpoch}';

      final appointmentData = {
        'appointmentId': appointmentId,
        'patientId': widget.patientData['_id'],
        'patientName': widget.patientData['name'],
        'patientUhid': widget.patientData['uhid'],
        'patientGender': widget.patientData['gender'],
        'patientAge': widget.patientData['age'],
        'patientState': widget.patientData['state'],
        'doctorId': selectedDoctor!['_id'],
        'doctorName': selectedDoctor!['doctorName'],
        'hospitalId':
            selectedHospital!['hospitalId'] ?? selectedHospital!['_id'],
        'hospitalName': selectedHospital!['name'],
        'appointmentDate': selectedDate!.toIso8601String().split('T')[0],
        'appointmentTime': selectedTime,
        'reason': appointmentReason,
        'consultationFee': selectedDoctor!['consultationFee'],
        'status': 'pending',
        'bookedAt': DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/appointments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(appointmentData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSuccessDialog(appointmentId);
      } else {
        throw Exception('Failed to book appointment');
      }
    } catch (e) {
      _showErrorDialog('Failed to book appointment: $e');
    } finally {
      setState(() => isBooking = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String appointmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Appointment Booked Successfully!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your appointment has been booked successfully.'),
            SizedBox(height: 8),
            Text(
              'Appointment ID: $appointmentId',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Status: Pending (waiting for doctor approval)'),
            SizedBox(height: 8),
            Text(
              'You will be notified once the doctor approves your appointment.',
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to patient dashboard
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
