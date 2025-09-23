import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/app_constants.dart';

class HospitalDoctorAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> doctorData;

  const HospitalDoctorAppointmentScreen({super.key, required this.doctorData});

  @override
  _HospitalDoctorAppointmentScreenState createState() => _HospitalDoctorAppointmentScreenState();
}

class _HospitalDoctorAppointmentScreenState extends State<HospitalDoctorAppointmentScreen> {
  List<dynamic> appointments = [];
  List<dynamic> filteredAppointments = [];
  
  bool isLoading = true;
  String searchQuery = '';
  String statusFilter = 'All';
  DateTime? dateFilter;
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAppointments();
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
              child: Column(
                children: [
                  Row(
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Health',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Appointment Management',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  
                  // Doctor Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Text(
                          _getInitials(widget.doctorData['doctorName'] ?? 'Doctor'),
                          style: TextStyle(
                            color: Colors.blue.shade700,
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
                              'Dr. ${widget.doctorData['doctorName'] ?? 'Unknown'}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              widget.doctorData['specialization'] ?? 'General',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
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
          
          // Search and Filter Section
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by patient name, UHID, or reason',
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
                      _filterAppointments();
                    });
                  },
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
                        items: ['All', 'pending', 'approved', 'rejected', 'completed']
                            .map((status) => DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(status == 'All' ? 'All Status' : status.toUpperCase()),
                                ))
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
          
          // Appointments List
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredAppointments.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadAppointments,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredAppointments.length,
                          itemBuilder: (context, index) {
                            return _buildAppointmentCard(filteredAppointments[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    String status = appointment['status'] ?? 'pending';
    Color statusColor = _getStatusColor(status);
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Info Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    _getInitials(appointment['patientName'] ?? 'Patient'),
                    style: TextStyle(
                      color: Colors.blue.shade700,
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
                        appointment['patientName'] ?? 'Unknown Patient',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'UHID: ${appointment['patientUhid'] ?? 'N/A'}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getStatusTextColor(status),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // Patient Details
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Gender & Age', '${appointment['patientGender'] ?? 'N/A'} • ${appointment['patientAge'] ?? 'N/A'} years'),
                  _buildInfoRow('Home State', appointment['patientState'] ?? 'N/A'),
                  _buildInfoRow('Date & Time', '${appointment['appointmentDate'] ?? 'N/A'} at ${appointment['appointmentTime'] ?? 'N/A'}'),
                  _buildInfoRow('Reason', appointment['reason'] ?? 'No reason provided'),
                  _buildInfoRow('Consultation Fee', '₹${appointment['consultationFee'] ?? 'N/A'}'),
                ],
              ),
            ),
            SizedBox(height: 12),
            
            // Action Buttons (only for pending appointments)
            if (status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateAppointmentStatus(appointment, 'rejected'),
                      icon: Icon(Icons.close, size: 18),
                      label: Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateAppointmentStatus(appointment, 'approved'),
                      icon: Icon(Icons.check, size: 18),
                      label: Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            
            // Mark as Completed (only for approved appointments)
            if (status == 'approved')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _updateAppointmentStatus(appointment, 'completed'),
                  icon: Icon(Icons.done_all, size: 18),
                  label: Text('Mark as Completed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            
            // Appointment ID (small text at bottom)
            SizedBox(height: 8),
            Text(
              'Appointment ID: ${appointment['appointmentId'] ?? 'N/A'}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No appointments found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Appointments will appear here when patients book with you',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
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

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green.shade800;
      case 'pending':
        return Colors.orange.shade800;
      case 'rejected':
        return Colors.red.shade800;
      case 'completed':
        return Colors.blue.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  Future<void> _loadAppointments() async {
    setState(() => isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final doctorId = widget.doctorData['_id'] ?? widget.doctorData['doctorId'];
      
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/appointments/doctor/$doctorId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          appointments = data;
          filteredAppointments = data;
          isLoading = false;
        });
        _filterAppointments();
      } else {
        throw Exception('Failed to load appointments');
      }
    } catch (e) {
      print('Error loading appointments: $e');
      setState(() => isLoading = false);
      _showErrorSnackBar('Failed to load appointments: $e');
    }
  }

  void _filterAppointments() {
    List<dynamic> filtered = appointments.where((appointment) {
      // Search filter
      bool matchesSearch = searchQuery.isEmpty ||
          appointment['patientName'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          appointment['patientUhid'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          appointment['reason'].toString().toLowerCase().contains(searchQuery.toLowerCase());

      // Status filter
      bool matchesStatus = statusFilter == 'All' ||
          appointment['status'] == statusFilter;

      // Date filter
      bool matchesDate = dateFilter == null;
      if (dateFilter != null && appointment['appointmentDate'] != null) {
        try {
          DateTime appointmentDate = DateTime.parse(appointment['appointmentDate']);
          matchesDate = appointmentDate.year == dateFilter!.year &&
                       appointmentDate.month == dateFilter!.month &&
                       appointmentDate.day == dateFilter!.day;
        } catch (e) {
          matchesDate = false;
        }
      }

      return matchesSearch && matchesStatus && matchesDate;
    }).toList();

    // Sort by date and time
    filtered.sort((a, b) {
      DateTime dateA = DateTime.tryParse(a['appointmentDate'] ?? '') ?? DateTime.now();
      DateTime dateB = DateTime.tryParse(b['appointmentDate'] ?? '') ?? DateTime.now();
      return dateA.compareTo(dateB);
    });

    setState(() {
      filteredAppointments = filtered;
    });
  }

  Future<void> _selectDateFilter() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 30)),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        dateFilter = picked;
        _filterAppointments();
      });
    }
  }

  Future<void> _updateAppointmentStatus(Map<String, dynamic> appointment, String newStatus) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/appointments/${appointment['appointmentId']}/status'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        // Update local data
        setState(() {
          appointment['status'] = newStatus;
          _filterAppointments();
        });
        
        String message = '';
        switch (newStatus) {
          case 'approved':
            message = 'Appointment approved successfully';
            break;
          case 'rejected':
            message = 'Appointment rejected successfully';
            break;
          case 'completed':
            message = 'Appointment marked as completed';
            break;
        }
        
        _showSuccessSnackBar(message);
      } else {
        throw Exception('Failed to update appointment status');
      }
    } catch (e) {
      print('Error updating appointment status: $e');
      _showErrorSnackBar('Failed to update appointment: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}