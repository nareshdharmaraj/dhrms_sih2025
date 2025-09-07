import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';

class DoctorsDetailsScreen extends StatefulWidget {
  const DoctorsDetailsScreen({Key? key}) : super(key: key);

  @override
  State<DoctorsDetailsScreen> createState() => _DoctorsDetailsScreenState();
}

class _DoctorsDetailsScreenState extends State<DoctorsDetailsScreen> {
  List<Map<String, dynamic>> _doctors = [];
  List<Map<String, dynamic>> _filteredDoctors = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedDepartment = 'All';
  String _selectedSpecialty = 'All';

  final List<String> _departments = [
    'All',
    'Cardiology',
    'Neurology',
    'Orthopedics',
    'Pediatrics',
    'General Medicine',
    'Emergency',
    'Surgery',
    'Radiology',
    'Pathology'
  ];

  final List<String> _specialties = [
    'All',
    'Interventional Cardiology',
    'Pediatric Cardiology',
    'Neurological Surgery',
    'Spine Surgery',
    'Joint Replacement',
    'General Surgery',
    'Cardiac Surgery',
    'Emergency Medicine',
    'General Practice'
  ];

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() => _isLoading = true);
    try {
      // Mock doctors data with comprehensive details
      await Future.delayed(Duration(seconds: 1));
      _doctors = [
        {
          'id': 'doc_001',
          'name': 'Dr. Michael Chen',
          'specialty': 'Interventional Cardiology',
          'department': 'Cardiology',
          'experience': '15 years',
          'qualification': 'MD, DM Cardiology',
          'phone': '+91 98765-43210',
          'email': 'michael.chen@hospital.com',
          'schedule': 'Mon-Fri: 9:00 AM - 5:00 PM',
          'rating': 4.8,
          'consultationFee': '₹1,500',
          'totalPatients': 1245,
          'availability': 'Available',
          'image': 'assets/images/doctors/doctor1.png',
          'languages': ['English', 'Hindi', 'Mandarin'],
          'achievements': [
            'Best Cardiologist Award 2023',
            'Published 50+ research papers',
            'International fellowship in USA'
          ],
          'nextAvailable': '2024-01-16 10:00 AM',
        },
        {
          'id': 'doc_002',
          'name': 'Dr. Sarah Wilson',
          'specialty': 'Pediatric Cardiology',
          'department': 'Cardiology',
          'experience': '12 years',
          'qualification': 'MD Pediatrics, DM Cardiology',
          'phone': '+91 98765-43211',
          'email': 'sarah.wilson@hospital.com',
          'schedule': 'Mon-Sat: 8:00 AM - 2:00 PM',
          'rating': 4.9,
          'consultationFee': '₹1,200',
          'totalPatients': 892,
          'availability': 'Busy',
          'image': 'assets/images/doctors/doctor2.png',
          'languages': ['English', 'Hindi'],
          'achievements': [
            'Pediatric Excellence Award 2023',
            'Research in Congenital Heart Disease',
            'Member of International Pediatric Association'
          ],
          'nextAvailable': '2024-01-17 2:00 PM',
        },
        {
          'id': 'doc_003',
          'name': 'Dr. Rajesh Kumar',
          'specialty': 'Neurological Surgery',
          'department': 'Neurology',
          'experience': '18 years',
          'qualification': 'MS Neurosurgery, MCh',
          'phone': '+91 98765-43212',
          'email': 'rajesh.kumar@hospital.com',
          'schedule': 'Mon-Fri: 6:00 AM - 12:00 PM',
          'rating': 4.7,
          'consultationFee': '₹2,000',
          'totalPatients': 756,
          'availability': 'Available',
          'image': 'assets/images/doctors/doctor3.png',
          'languages': ['English', 'Hindi', 'Telugu'],
          'achievements': [
            'Neurosurgery Excellence Award',
            'Pioneer in minimally invasive surgery',
            'International training in Germany'
          ],
          'nextAvailable': '2024-01-16 6:30 AM',
        },
        {
          'id': 'doc_004',
          'name': 'Dr. Lisa Rodriguez',
          'specialty': 'General Medicine',
          'department': 'General Medicine',
          'experience': '10 years',
          'qualification': 'MD Internal Medicine',
          'phone': '+91 98765-43213',
          'email': 'lisa.rodriguez@hospital.com',
          'schedule': 'Mon-Sat: 9:00 AM - 6:00 PM',
          'rating': 4.6,
          'consultationFee': '₹800',
          'totalPatients': 2156,
          'availability': 'Available',
          'image': 'assets/images/doctors/doctor4.png',
          'languages': ['English', 'Spanish', 'Hindi'],
          'achievements': [
            'Community Service Award',
            'Expert in preventive medicine',
            'Diabetes management specialist'
          ],
          'nextAvailable': '2024-01-16 9:30 AM',
        },
        {
          'id': 'doc_005',
          'name': 'Dr. James Thompson',
          'specialty': 'Spine Surgery',
          'department': 'Orthopedics',
          'experience': '14 years',
          'qualification': 'MS Orthopedics, Fellowship Spine',
          'phone': '+91 98765-43214',
          'email': 'james.thompson@hospital.com',
          'schedule': 'Tue-Sat: 7:00 AM - 1:00 PM',
          'rating': 4.8,
          'consultationFee': '₹1,800',
          'totalPatients': 654,
          'availability': 'On Leave',
          'image': 'assets/images/doctors/doctor5.png',
          'languages': ['English', 'Hindi'],
          'achievements': [
            'Spine Surgery Innovation Award',
            'Robotic surgery specialist',
            'Published in international journals'
          ],
          'nextAvailable': '2024-01-20 7:00 AM',
        },
      ];
      _filteredDoctors = List.from(_doctors);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load doctors: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterDoctors() {
    setState(() {
      _filteredDoctors = _doctors.where((doctor) {
        final matchesSearch = doctor['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
            doctor['specialty'].toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesDepartment = _selectedDepartment == 'All' || doctor['department'] == _selectedDepartment;
        final matchesSpecialty = _selectedSpecialty == 'All' || doctor['specialty'] == _selectedSpecialty;
        
        return matchesSearch && matchesDepartment && matchesSpecialty;
      }).toList();
    });
  }

  Color _getAvailabilityColor(String availability) {
    switch (availability) {
      case 'Available':
        return AppColors.success;
      case 'Busy':
        return AppColors.primaryOrange;
      case 'On Leave':
        return AppColors.primaryRed;
      default:
        return AppColors.grey500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctors Directory'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Navigate to add doctor screen
              _showAddDoctorDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredDoctors.isEmpty
                    ? _buildEmptyState()
                    : _buildDoctorsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: EdgeInsets.all(16),
      color: AppColors.grey100,
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search doctors by name or specialty...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
              _filterDoctors();
            },
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedDepartment,
                  decoration: InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: _departments.map((dept) {
                    return DropdownMenuItem(value: dept, child: Text(dept));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedDepartment = value!);
                    _filterDoctors();
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSpecialty,
                  decoration: InputDecoration(
                    labelText: 'Specialty',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: _specialties.map((specialty) {
                    return DropdownMenuItem(value: specialty, child: Text(specialty));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedSpecialty = value!);
                    _filterDoctors();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: AppColors.grey400),
          SizedBox(height: 16),
          Text(
            'No doctors found',
            style: TextStyle(fontSize: 18, color: AppColors.grey600),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(color: AppColors.grey500),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _filteredDoctors.length,
      itemBuilder: (context, index) {
        final doctor = _filteredDoctors[index];
        return _buildDoctorCard(doctor);
      },
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: InkWell(
        onTap: () => _showDoctorDetails(doctor),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                doctor['name'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getAvailabilityColor(doctor['availability']),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                doctor['availability'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          doctor['specialty'],
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${doctor['department']} • ${doctor['experience']}',
                          style: TextStyle(color: AppColors.grey600),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            SizedBox(width: 4),
                            Text(
                              '${doctor['rating']}',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            SizedBox(width: 16),
                            Icon(Icons.people, color: AppColors.grey500, size: 16),
                            SizedBox(width: 4),
                            Text(
                              '${doctor['totalPatients']} patients',
                              style: TextStyle(color: AppColors.grey600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _makeCall(doctor['phone']),
                      icon: Icon(Icons.phone, size: 18),
                      label: Text('Call'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _sendMessage(doctor['email']),
                      icon: Icon(Icons.message, size: 18),
                      label: Text('Message'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: doctor['availability'] == 'Available'
                          ? () => _bookAppointment(doctor)
                          : null,
                      icon: Icon(Icons.calendar_today, size: 18),
                      label: Text('Book'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
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

  void _showDoctorDetails(Map<String, dynamic> doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor['name'],
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            doctor['specialty'],
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            doctor['qualification'],
                            style: TextStyle(color: AppColors.grey600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                _buildDetailSection('Contact Information', [
                  _buildDetailRow(Icons.phone, 'Phone', doctor['phone']),
                  _buildDetailRow(Icons.email, 'Email', doctor['email']),
                  _buildDetailRow(Icons.schedule, 'Schedule', doctor['schedule']),
                ]),
                SizedBox(height: 16),
                _buildDetailSection('Professional Details', [
                  _buildDetailRow(Icons.work, 'Experience', doctor['experience']),
                  _buildDetailRow(Icons.business, 'Department', doctor['department']),
                  _buildDetailRow(Icons.star, 'Rating', '${doctor['rating']}/5.0'),
                  _buildDetailRow(Icons.attach_money, 'Consultation Fee', doctor['consultationFee']),
                ]),
                SizedBox(height: 16),
                _buildDetailSection('Languages', [
                  Row(
                    children: doctor['languages'].map<Widget>((lang) => Container(
                      margin: EdgeInsets.only(right: 8),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(lang),
                    )).toList(),
                  ),
                ]),
                SizedBox(height: 16),
                _buildDetailSection('Achievements', [
                  ...doctor['achievements'].map<Widget>((achievement) => Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        SizedBox(width: 8),
                        Expanded(child: Text(achievement)),
                      ],
                    ),
                  )).toList(),
                ]),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close'),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: doctor['availability'] == 'Available'
                            ? () {
                                Navigator.pop(context);
                                _bookAppointment(doctor);
                              }
                            : null,
                        child: Text('Book Appointment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
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

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.grey600),
          SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _makeCall(String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling $phone...')),
    );
  }

  void _sendMessage(String email) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening message to $email...')),
    );
  }

  void _bookAppointment(Map<String, dynamic> doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Book Appointment'),
        content: Text('Would you like to book an appointment with ${doctor['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Appointment booking initiated for ${doctor['name']}'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text('Book'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDoctorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Doctor'),
        content: Text('This will navigate to the Add Doctor form.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to add doctor screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Add Doctor feature coming soon!')),
              );
            },
            child: Text('Add'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
