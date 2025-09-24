import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
  List<dynamic> appointments = [];
  List<dynamic> filteredAppointments = [];

  bool isLoading = true;
  String searchQuery = '';
  String statusFilter = 'All';
  DateTime? dateFilter;
  String sortBy = 'date'; // date, patient, status

  final TextEditingController _searchController = TextEditingController();

  // Statistics
  int totalAppointments = 0;
  int pendingCount = 0;
  int approvedCount = 0;
  int completedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dr. ${widget.doctorData['doctorName'] ?? 'Doctor'}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Appointment Management',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAppointments,
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Cards
          _buildStatisticsCards(),

          // Search and Filter Section
          _buildSearchAndFilters(),

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
                        return _buildEnhancedAppointmentCard(
                          filteredAppointments[index],
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Statistics Cards Widget
  Widget _buildStatisticsCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('Total', totalAppointments, Colors.blue),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard('Pending', pendingCount, Colors.orange),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard('Approved', approvedCount, Colors.green),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard('Completed', completedCount, Colors.purple),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Search and Filters Widget
  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by patient name, UHID, or reason...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
              _filterAppointments();
            },
          ),
          const SizedBox(height: 12),

          // Filter Row
          Row(
            children: [
              // Status Filter
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: statusFilter,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: ['All', 'pending', 'approved', 'rejected', 'completed']
                      .map(
                        (status) => DropdownMenuItem<String>(
                          value: status,
                          child: Text(
                            status == 'All'
                                ? 'All Status'
                                : status.toUpperCase(),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        statusFilter = newValue;
                      });
                      _filterAppointments();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Date Filter
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: _selectDateFilter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            dateFilter == null
                                ? 'Select Date'
                                : '${dateFilter!.day}/${dateFilter!.month}/${dateFilter!.year}',
                            style: TextStyle(
                              fontSize: 14,
                              color: dateFilter == null
                                  ? Colors.grey.shade600
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Clear Date Filter
              if (dateFilter != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      dateFilter = null;
                    });
                    _filterAppointments();
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red.shade700,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // Sort Options
          Row(
            children: [
              Text(
                'Sort by: ',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 8),
              _buildSortChip('Date', 'date'),
              const SizedBox(width: 8),
              _buildSortChip('Patient', 'patient'),
              const SizedBox(width: 8),
              _buildSortChip('Status', 'status'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    bool isSelected = sortBy == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          sortBy = value;
        });
        _filterAppointments();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade600 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Enhanced Appointment Card
  Widget _buildEnhancedAppointmentCard(Map<String, dynamic> appointment) {
    String status = appointment['status'] ?? 'pending';
    Color statusColor = _getStatusColor(status);
    IconData statusIcon = _getStatusIcon(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Patient Info and Status
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    _getInitials(appointment['patientName'] ?? 'Patient'),
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment['patientName'] ?? 'Unknown Patient',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'UHID: ${appointment['patientId'] ?? appointment['patientUhid'] ?? 'N/A'}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Appointment Details
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Date & Time',
                    '${appointment['appointmentDate']} at ${appointment['appointmentTime']}',
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.medical_services,
                    'Consultation Fee',
                    '₹${appointment['consultationFee'] ?? 'N/A'}',
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.note_alt,
                    'Reason',
                    appointment['reason'] ?? 'General consultation',
                  ),
                  if (appointment['patientAge'] != null ||
                      appointment['patientGender'] != null) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      Icons.person_outline,
                      'Patient Info',
                      '${appointment['patientGender'] ?? 'N/A'} • ${appointment['patientAge'] ?? 'N/A'} years',
                    ),
                  ],
                  if (appointment['patientPhone'] != null) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      Icons.phone,
                      'Contact',
                      appointment['patientPhone'],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons Based on Status
            if (status == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _showApprovalDialog(appointment, 'rejected'),
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _showApprovalDialog(appointment, 'approved'),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (status == 'approved') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showCompletionDialog(appointment),
                  icon: const Icon(Icons.done_all, size: 18),
                  label: const Text('Mark as Completed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ] else if (status == 'completed') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Consultation Completed',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (status == 'rejected') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel, color: Colors.red.shade600, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Appointment Rejected',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Appointment ID
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Appointment ID: ${appointment['appointmentId'] ?? 'N/A'}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        SizedBox(
          width: 90,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
      ],
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

  // Status Icon Helper
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'rejected':
        return Icons.cancel;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.help;
    }
  }

  // Approval Dialog
  void _showApprovalDialog(Map<String, dynamic> appointment, String newStatus) {
    String title = newStatus == 'approved'
        ? 'Approve Appointment'
        : 'Reject Appointment';
    String message = newStatus == 'approved'
        ? 'Are you sure you want to approve this appointment with ${appointment['patientName']}?'
        : 'Are you sure you want to reject this appointment with ${appointment['patientName']}?';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Patient: ${appointment['patientName']}'),
                  Text('Date: ${appointment['appointmentDate']}'),
                  Text('Time: ${appointment['appointmentTime']}'),
                  Text('Reason: ${appointment['reason']}'),
                ],
              ),
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
              _updateAppointmentStatus(appointment, newStatus);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == 'approved'
                  ? Colors.green
                  : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(newStatus == 'approved' ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }

  // Completion Dialog
  void _showCompletionDialog(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Completed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mark appointment with ${appointment['patientName']} as completed?',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Patient: ${appointment['patientName']}'),
                  Text('Date: ${appointment['appointmentDate']}'),
                  Text('Time: ${appointment['appointmentTime']}'),
                ],
              ),
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
              _updateAppointmentStatus(appointment, 'completed');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Mark Completed'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green.shade600;
      case 'pending':
        return Colors.orange.shade600;
      case 'rejected':
        return Colors.red.shade600;
      case 'completed':
        return Colors.blue.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  Future<void> _loadAppointments() async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final doctorId =
          widget.doctorData['_id'] ?? widget.doctorData['doctorId'];

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
        _calculateStatistics();
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

  void _calculateStatistics() {
    totalAppointments = appointments.length;
    pendingCount = appointments.where((a) => a['status'] == 'pending').length;
    approvedCount = appointments.where((a) => a['status'] == 'approved').length;
    completedCount = appointments
        .where((a) => a['status'] == 'completed')
        .length;
  }

  void _filterAppointments() {
    List<dynamic> filtered = appointments.where((appointment) {
      // Search filter
      bool matchesSearch =
          searchQuery.isEmpty ||
          appointment['patientName'].toString().toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          appointment['patientUhid'].toString().toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          appointment['reason'].toString().toLowerCase().contains(
            searchQuery.toLowerCase(),
          );

      // Status filter
      bool matchesStatus =
          statusFilter == 'All' || appointment['status'] == statusFilter;

      // Date filter
      bool matchesDate = dateFilter == null;
      if (dateFilter != null && appointment['appointmentDate'] != null) {
        try {
          DateTime appointmentDate = DateTime.parse(
            appointment['appointmentDate'],
          );
          matchesDate =
              appointmentDate.year == dateFilter!.year &&
              appointmentDate.month == dateFilter!.month &&
              appointmentDate.day == dateFilter!.day;
        } catch (e) {
          matchesDate = false;
        }
      }

      return matchesSearch && matchesStatus && matchesDate;
    }).toList();

    // Sort based on selected criteria
    filtered.sort((a, b) {
      switch (sortBy) {
        case 'date':
          DateTime dateA =
              DateTime.tryParse(a['appointmentDate'] ?? '') ?? DateTime.now();
          DateTime dateB =
              DateTime.tryParse(b['appointmentDate'] ?? '') ?? DateTime.now();
          return dateA.compareTo(dateB);
        case 'patient':
          return (a['patientName'] ?? '').toString().compareTo(
            (b['patientName'] ?? '').toString(),
          );
        case 'status':
          // Sort by status priority: pending, approved, completed, rejected
          Map<String, int> statusPriority = {
            'pending': 1,
            'approved': 2,
            'completed': 3,
            'rejected': 4,
          };
          int priorityA = statusPriority[a['status']] ?? 5;
          int priorityB = statusPriority[b['status']] ?? 5;
          return priorityA.compareTo(priorityB);
        default:
          DateTime dateA =
              DateTime.tryParse(a['appointmentDate'] ?? '') ?? DateTime.now();
          DateTime dateB =
              DateTime.tryParse(b['appointmentDate'] ?? '') ?? DateTime.now();
          return dateA.compareTo(dateB);
      }
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

  Future<void> _updateAppointmentStatus(
    Map<String, dynamic> appointment,
    String newStatus,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.put(
        Uri.parse(
          '${AppConstants.baseUrl}/appointments/${appointment['appointmentId']}/status',
        ),
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
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}
