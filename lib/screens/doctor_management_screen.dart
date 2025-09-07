import 'package:flutter/material.dart';

class DoctorManagementScreen extends StatefulWidget {
  const DoctorManagementScreen({super.key});

  @override
  State<DoctorManagementScreen> createState() => _DoctorManagementScreenState();
}

class _DoctorManagementScreenState extends State<DoctorManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _doctors = [];
  List<Map<String, dynamic>> _filteredDoctors = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDoctors();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadDoctors() {
    // Mock doctor data
    _doctors = [
      {
        'doctorId': 'DOC001',
        'name': 'Dr. Rajesh Kumar',
        'specialization': 'Cardiology',
        'experience': '15 years',
        'qualification': 'MBBS, MD (Cardiology)',
        'phone': '+91 98765 43210',
        'email': 'rajesh.kumar@hospital.com',
        'department': 'Cardiology',
        'patientsCount': 245,
        'consultationFee': 800,
        'isActive': true,
        'joinDate': '2020-01-15',
        'schedule': {
          'monday': '9:00 AM - 5:00 PM',
          'tuesday': '9:00 AM - 5:00 PM',
          'wednesday': '9:00 AM - 1:00 PM',
          'thursday': '9:00 AM - 5:00 PM',
          'friday': '9:00 AM - 5:00 PM',
          'saturday': '9:00 AM - 1:00 PM',
          'sunday': 'Off',
        }
      },
      {
        'doctorId': 'DOC002',
        'name': 'Dr. Priya Sharma',
        'specialization': 'Pediatrics',
        'experience': '12 years',
        'qualification': 'MBBS, MD (Pediatrics)',
        'phone': '+91 87654 32109',
        'email': 'priya.sharma@hospital.com',
        'department': 'Pediatrics',
        'patientsCount': 189,
        'consultationFee': 600,
        'isActive': true,
        'joinDate': '2021-03-20',
        'schedule': {
          'monday': '10:00 AM - 6:00 PM',
          'tuesday': '10:00 AM - 6:00 PM',
          'wednesday': '10:00 AM - 6:00 PM',
          'thursday': '10:00 AM - 2:00 PM',
          'friday': '10:00 AM - 6:00 PM',
          'saturday': '10:00 AM - 2:00 PM',
          'sunday': 'Off',
        }
      },
      {
        'doctorId': 'DOC003',
        'name': 'Dr. Amit Patel',
        'specialization': 'Orthopedics',
        'experience': '8 years',
        'qualification': 'MBBS, MS (Orthopedics)',
        'phone': '+91 76543 21098',
        'email': 'amit.patel@hospital.com',
        'department': 'Orthopedics',
        'patientsCount': 156,
        'consultationFee': 700,
        'isActive': true,
        'joinDate': '2022-06-10',
        'schedule': {
          'monday': '8:00 AM - 4:00 PM',
          'tuesday': '8:00 AM - 4:00 PM',
          'wednesday': '8:00 AM - 4:00 PM',
          'thursday': '8:00 AM - 4:00 PM',
          'friday': '8:00 AM - 4:00 PM',
          'saturday': 'Emergency Only',
          'sunday': 'Off',
        }
      },
    ];
    _filteredDoctors = _doctors;
  }

  void _filterDoctors(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDoctors = _doctors;
      } else {
        _filteredDoctors = _doctors.where((doctor) {
          return doctor['name'].toLowerCase().contains(query.toLowerCase()) ||
                 doctor['specialization'].toLowerCase().contains(query.toLowerCase()) ||
                 doctor['doctorId'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Doctor Management'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.blue[200],
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'All Doctors'),
            Tab(icon: Icon(Icons.person_add), text: 'Add Doctor'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDoctorsListTab(),
          _buildAddDoctorTab(),
        ],
      ),
    );
  }

  Widget _buildDoctorsListTab() {
    return Column(
      children: [
        // Search and Stats
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search doctors...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onChanged: _filterDoctors,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Doctors',
                      _doctors.length.toString(),
                      Icons.people,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Active',
                      _doctors.where((d) => d['isActive']).length.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Departments',
                      _doctors.map((d) => d['department']).toSet().length.toString(),
                      Icons.business,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Doctors List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredDoctors.length,
            itemBuilder: (context, index) {
              final doctor = _filteredDoctors[index];
              return _buildDoctorCard(doctor);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: color[700], size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color[700],
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDoctorDetails(doctor),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      doctor['name'].split(' ').map((n) => n[0]).take(2).join(),
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          doctor['specialization'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'ID: ${doctor['doctorId']}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: doctor['isActive'] ? Colors.green[100] : Colors.red[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          doctor['isActive'] ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: doctor['isActive'] ? Colors.green[700] : Colors.red[700],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      PopupMenuButton<String>(
                        onSelected: (value) => _handleDoctorAction(value, doctor),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'login',
                            child: Row(
                              children: [
                                Icon(Icons.login, size: 20),
                                SizedBox(width: 8),
                                Text('Doctor Login'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'schedule',
                            child: Row(
                              children: [
                                Icon(Icons.schedule, size: 20),
                                SizedBox(width: 8),
                                Text('Schedule'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: doctor['isActive'] ? 'deactivate' : 'activate',
                            child: Row(
                              children: [
                                Icon(
                                  doctor['isActive'] ? Icons.pause : Icons.play_arrow,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(doctor['isActive'] ? 'Deactivate' : 'Activate'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.work, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${doctor['experience']} experience',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${doctor['patientsCount']} patients',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    '₹${doctor['consultationFee']}',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _viewDoctorProfile(doctor),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('View Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _doctorLogin(doctor),
                      icon: const Icon(Icons.login, size: 16),
                      label: const Text('Login as Doctor'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue[700],
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

  Widget _buildAddDoctorTab() {
    return const AddDoctorForm();
  }

  void _handleDoctorAction(String action, Map<String, dynamic> doctor) {
    switch (action) {
      case 'edit':
        _editDoctor(doctor);
        break;
      case 'login':
        _doctorLogin(doctor);
        break;
      case 'schedule':
        _manageSchedule(doctor);
        break;
      case 'activate':
      case 'deactivate':
        _toggleDoctorStatus(doctor);
        break;
    }
  }

  void _showDoctorDetails(Map<String, dynamic> doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorDetailScreen(doctor: doctor),
      ),
    );
  }

  void _viewDoctorProfile(Map<String, dynamic> doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorProfileScreen(doctor: doctor),
      ),
    );
  }

  void _doctorLogin(Map<String, dynamic> doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorDashboardScreen(doctor: doctor),
      ),
    );
  }

  void _editDoctor(Map<String, dynamic> doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDoctorScreen(doctor: doctor),
      ),
    );
  }

  void _manageSchedule(Map<String, dynamic> doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${doctor['name']} - Schedule'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: (doctor['schedule'] as Map<String, String>).entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(entry.value),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to schedule management screen
            },
            child: const Text('Edit Schedule'),
          ),
        ],
      ),
    );
  }

  void _toggleDoctorStatus(Map<String, dynamic> doctor) {
    setState(() {
      doctor['isActive'] = !doctor['isActive'];
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${doctor['name']} has been ${doctor['isActive'] ? 'activated' : 'deactivated'}',
        ),
        backgroundColor: doctor['isActive'] ? Colors.green : Colors.orange,
      ),
    );
  }
}

class AddDoctorForm extends StatefulWidget {
  const AddDoctorForm({super.key});

  @override
  State<AddDoctorForm> createState() => _AddDoctorFormState();
}

class _AddDoctorFormState extends State<AddDoctorForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _feeController = TextEditingController();
  
  String _selectedSpecialization = 'General Medicine';
  String _selectedDepartment = 'General Medicine';

  final List<String> _specializations = [
    'General Medicine',
    'Cardiology',
    'Neurology',
    'Orthopedics',
    'Pediatrics',
    'Dermatology',
    'Gynecology',
    'Psychiatry',
    'Radiology',
    'Anesthesiology',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Doctor',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter doctor information to add to the hospital',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person,
              required: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email,
              required: true,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone,
              required: true,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              value: _selectedSpecialization,
              label: 'Specialization',
              icon: Icons.medical_services,
              items: _specializations,
              onChanged: (value) {
                setState(() {
                  _selectedSpecialization = value!;
                  _selectedDepartment = value;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _qualificationController,
              label: 'Qualification',
              icon: Icons.school,
              required: true,
              hintText: 'e.g., MBBS, MD',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _experienceController,
                    label: 'Experience (Years)',
                    icon: Icons.work,
                    required: true,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _feeController,
                    label: 'Consultation Fee (₹)',
                    icon: Icons.currency_rupee,
                    required: true,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addDoctor,
                icon: const Icon(Icons.person_add),
                label: const Text('Add Doctor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    TextInputType? keyboardType,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label + (required ? ' *' : ''),
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      validator: required ? (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      } : null,
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: '$label *',
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  void _addDoctor() {
    if (_formKey.currentState!.validate()) {
      // Generate doctor ID
      String doctorId = 'DOC${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
      
      Map<String, dynamic> newDoctor = {
        'doctorId': doctorId,
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'specialization': _selectedSpecialization,
        'department': _selectedDepartment,
        'qualification': _qualificationController.text,
        'experience': '${_experienceController.text} years',
        'consultationFee': int.parse(_feeController.text),
        'patientsCount': 0,
        'isActive': true,
        'joinDate': DateTime.now().toIso8601String().split('T')[0],
        'schedule': {
          'monday': '9:00 AM - 5:00 PM',
          'tuesday': '9:00 AM - 5:00 PM',
          'wednesday': '9:00 AM - 5:00 PM',
          'thursday': '9:00 AM - 5:00 PM',
          'friday': '9:00 AM - 5:00 PM',
          'saturday': '9:00 AM - 1:00 PM',
          'sunday': 'Off',
        }
      };

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Doctor added successfully! ID: $doctorId'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _qualificationController.clear();
      _experienceController.clear();
      _feeController.clear();

      // Navigate to doctor profile
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DoctorProfileScreen(doctor: newDoctor),
        ),
      );
    }
  }
}

// Placeholder screens - to be implemented in next steps
class DoctorDetailScreen extends StatelessWidget {
  final Map<String, dynamic> doctor;

  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(doctor['name']),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Doctor Detail Screen - To be implemented'),
      ),
    );
  }
}

class DoctorProfileScreen extends StatelessWidget {
  final Map<String, dynamic> doctor;

  const DoctorProfileScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${doctor['name']} - Profile'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Doctor Profile Screen - To be implemented'),
      ),
    );
  }
}

class DoctorDashboardScreen extends StatelessWidget {
  final Map<String, dynamic> doctor;

  const DoctorDashboardScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dr. Dashboard - ${doctor['name']}'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Doctor Dashboard - To be implemented'),
      ),
    );
  }
}

class EditDoctorScreen extends StatelessWidget {
  final Map<String, dynamic> doctor;

  const EditDoctorScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit - ${doctor['name']}'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Edit Doctor Screen - To be implemented'),
      ),
    );
  }
}
