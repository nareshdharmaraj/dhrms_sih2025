import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TelemedicineScreen extends StatefulWidget {
  final Map<String, dynamic>? patientData;

  const TelemedicineScreen({super.key, this.patientData});

  @override
  State<TelemedicineScreen> createState() => _TelemedicineScreenState();
}

class _TelemedicineScreenState extends State<TelemedicineScreen> {
  final List<Map<String, dynamic>> _doctors = [];
  final List<Map<String, dynamic>> _appointments = [];
  String _selectedSpecialty = 'All';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
    _loadAppointments();
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _isLoading = true;
    });

    try {
      const baseUrl = 'https://dhrms-sih2025.onrender.com/api';
      final response = await http.get(
        Uri.parse('$baseUrl/telemedicine/doctors'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _doctors.clear();
          _doctors.addAll(List<Map<String, dynamic>>.from(data['doctors'] ?? []));
        });
      } else {
        print('Failed to load doctors: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading doctors: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAppointments() async {
    try {
      const baseUrl = 'https://dhrms-sih2025.onrender.com/api';
      final response = await http.get(
        Uri.parse('$baseUrl/telemedicine/appointments'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _appointments.clear();
          _appointments.addAll(List<Map<String, dynamic>>.from(data['appointments'] ?? []));
        });
      } else {
        print('Failed to load appointments: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading appointments: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Telemedicine'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
          ),
        ),
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                labelColor: Colors.green.shade600,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.green.shade600,
                tabs: const [
                  Tab(text: 'Find Doctors', icon: Icon(Icons.search)),
                  Tab(
                    text: 'My Appointments',
                    icon: Icon(Icons.calendar_today),
                  ),
                ],
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _loadDoctors();
                    await _loadAppointments();
                  },
                  child: TabBarView(
                    children: [_buildDoctorsTab(), _buildAppointmentsTab()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorsTab() {
    return Column(
      children: [
        _buildSpecialtyFilter(),
        Expanded(
          child: _doctors.isEmpty
              ? _buildDoctorsEmptyState()
              : _buildDoctorsList(),
        ),
      ],
    );
  }

  Widget _buildSpecialtyFilter() {
    final specialties = [
      'All',
      'General',
      'Cardiology',
      'Dermatology',
      'Psychiatry',
      'Pediatrics',
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: specialties.length,
        itemBuilder: (context, index) {
          final specialty = specialties[index];
          final isSelected = _selectedSpecialty == specialty;

          return Padding(
            padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            child: FilterChip(
              label: Text(specialty),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedSpecialty = selected ? specialty : 'All';
                });
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.green.shade100,
              checkmarkColor: Colors.green.shade600,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDoctorsEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isLoading)
            const CircularProgressIndicator()
          else ...[
            Icon(
              Icons.video_call_outlined,
              size: 120,
              color: Colors.green.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'No Doctors Available',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Pull down to refresh and check for available doctors',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDoctorsList() {
    final filteredDoctors = _selectedSpecialty == 'All'
        ? _doctors
        : _doctors.where((d) => d['specialty'] == _selectedSpecialty).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredDoctors.length,
      itemBuilder: (context, index) {
        final doctor = filteredDoctors[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.green.shade100,
                      child: Text(
                        doctor['name'].split(' ').map((n) => n[0]).join(''),
                        style: TextStyle(
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dr. ${doctor['name']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            doctor['specialty'],
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                doctor['rating'].toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${doctor['reviews']} reviews)',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: doctor['isAvailable']
                            ? Colors.green
                            : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        doctor['isAvailable'] ? 'Available' : 'Busy',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Experience: ${doctor['experience']} years',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Text(
                  'Consultation Fee: \$${doctor['fee']}',
                  style: TextStyle(
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showDoctorProfile(doctor),
                        icon: const Icon(Icons.person, size: 16),
                        label: const Text('View Profile'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: doctor['isAvailable']
                            ? () => _bookAppointment(doctor)
                            : null,
                        icon: const Icon(Icons.video_call, size: 16),
                        label: const Text('Book Call'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppointmentsTab() {
    return _appointments.isEmpty
        ? _buildAppointmentsEmptyState()
        : _buildAppointmentsList();
  }

  Widget _buildAppointmentsEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 120,
            color: Colors.green.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'No Appointments',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your telemedicine appointments will appear here',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _appointments.length,
      itemBuilder: (context, index) {
        final appointment = _appointments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      child: Text(
                        appointment['doctorName']
                            .split(' ')
                            .map((n) => n[0])
                            .join(''),
                        style: TextStyle(
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dr. ${appointment['doctorName']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            appointment['specialty'],
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text(appointment['status']),
                      backgroundColor: _getStatusColor(appointment['status']),
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(appointment['date']),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(appointment['time']),
                  ],
                ),
                if (appointment['notes'] != null &&
                    appointment['notes'].isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Notes: ${appointment['notes']}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (appointment['status'] == 'Scheduled') ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _joinCall(appointment),
                          icon: const Icon(Icons.video_call, size: 16),
                          label: const Text('Join Call'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _cancelAppointment(index),
                        icon: const Icon(Icons.cancel, size: 16),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Scheduled':
        return Colors.green;
      case 'Completed':
        return Colors.blue;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showDoctorProfile(Map<String, dynamic> doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Dr. ${doctor['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Specialty: ${doctor['specialty']}'),
            Text('Experience: ${doctor['experience']} years'),
            Text(
              'Rating: ${doctor['rating']}/5.0 (${doctor['reviews']} reviews)',
            ),
            Text('Consultation Fee: \$${doctor['fee']}'),
            const SizedBox(height: 8),
            Text('Languages: ${doctor['languages'].join(', ')}'),
            if (doctor['education'] != null) ...[
              const SizedBox(height: 8),
              Text('Education: ${doctor['education']}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (doctor['isAvailable'])
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _bookAppointment(doctor);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Book Appointment'),
            ),
        ],
      ),
    );
  }

  void _bookAppointment(Map<String, dynamic> doctor) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Book Appointment with Dr. ${doctor['name']}'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date'),
                subtitle: Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null) {
                    setState(() {
                      selectedDate = date;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Time'),
                subtitle: Text(selectedTime.format(context)),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    setState(() {
                      selectedTime = time;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _addAppointment(
                doctor,
                selectedDate,
                selectedTime,
                notesController.text,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Book'),
          ),
        ],
      ),
    );
  }

  void _addAppointment(
    Map<String, dynamic> doctor,
    DateTime date,
    TimeOfDay time,
    String notes,
  ) {
    setState(() {
      _appointments.add({
        'doctorName': doctor['name'],
        'specialty': doctor['specialty'],
        'date': '${date.day}/${date.month}/${date.year}',
        'time': time.format(context),
        'status': 'Scheduled',
        'notes': notes,
        'fee': doctor['fee'],
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Appointment booked with Dr. ${doctor['name']}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _joinCall(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Video Call'),
        content: Text(
          'Starting video call with Dr. ${appointment['doctorName']}...',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Join Call'),
          ),
        ],
      ),
    );
  }

  void _cancelAppointment(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text(
          'Are you sure you want to cancel this appointment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _appointments[index]['status'] = 'Cancelled';
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
