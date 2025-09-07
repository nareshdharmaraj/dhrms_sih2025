import 'package:flutter/material.dart';
import 'patient_medical_history_screen.dart';

class PatientRegistrationScreen extends StatefulWidget {
  const PatientRegistrationScreen({super.key});

  @override
  State<PatientRegistrationScreen> createState() => _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState extends State<PatientRegistrationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // Patient search
  bool _isSearching = false;
  bool _patientFound = false;
  Map<String, dynamic>? _existingPatient;
  
  // Patient form data
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _dobController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  
  String _selectedGender = 'Male';
  String _selectedBloodGroup = 'O+';
  final List<String> _allergies = [];
  final List<String> _medicalHistory = [];
  final List<String> _currentMedications = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _aadhaarController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Patient Registration'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.blue[200],
          tabs: const [
            Tab(icon: Icon(Icons.search), text: 'Find Patient'),
            Tab(icon: Icon(Icons.person_add), text: 'New Patient'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSearchTab(),
          _buildRegistrationTab(),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search Existing Patient',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter patient unique ID (First name + Last 4 digits of Aadhaar)',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Patient Unique ID',
              hintText: 'e.g., John1234',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              if (value.length >= 6) {
                _searchPatient(value);
              } else {
                setState(() {
                  _patientFound = false;
                  _existingPatient = null;
                });
              }
            },
          ),
          const SizedBox(height: 24),
          if (_isSearching)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (_patientFound && _existingPatient != null)
            _buildPatientFoundCard()
          else if (_searchController.text.length >= 6)
            _buildPatientNotFoundCard(),
        ],
      ),
    );
  }

  Widget _buildPatientFoundCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.green[100],
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green[700],
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Patient Found!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Existing patient record available',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildPatientInfoRow('Name', '${_existingPatient!['firstName']} ${_existingPatient!['lastName']}'),
            _buildPatientInfoRow('Patient ID', _existingPatient!['patientId']),
            _buildPatientInfoRow('Phone', _existingPatient!['phone']),
            _buildPatientInfoRow('Last Visit', _existingPatient!['lastVisit']),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewPatientDetails(_existingPatient!),
                    icon: const Icon(Icons.visibility),
                    label: const Text('View Details'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewMedicalHistory(_existingPatient!),
                    icon: const Icon(Icons.medical_information),
                    label: const Text('History'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _proceedWithPatient(_existingPatient!),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Proceed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientNotFoundCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.orange[100],
                  child: Icon(
                    Icons.person_add,
                    color: Colors.orange[700],
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Patient Not Found',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'No existing record for this patient ID',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Patient ID: ${_searchController.text}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _tabController.animateTo(1);
                  _prePopulateFromSearch();
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Register New Patient'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationTab() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Patient Registration',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter complete patient information',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            
            // Basic Information
            _buildSectionHeader('Basic Information', Icons.person),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _firstNameController,
                    label: 'First Name',
                    icon: Icons.person,
                    required: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    icon: Icons.person_outline,
                    required: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _aadhaarController,
              label: 'Aadhaar Number',
              icon: Icons.credit_card,
              required: true,
              keyboardType: TextInputType.number,
              maxLength: 12,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildGenderDropdown(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _dobController,
                    label: 'Date of Birth',
                    icon: Icons.calendar_today,
                    required: true,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                  ),
                ),
              ],
            ),
            
            // Contact Information
            const SizedBox(height: 24),
            _buildSectionHeader('Contact Information', Icons.contact_phone),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone,
              required: true,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _addressController,
              label: 'Address',
              icon: Icons.location_on,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emergencyContactController,
              label: 'Emergency Contact',
              icon: Icons.emergency,
              keyboardType: TextInputType.phone,
            ),
            
            // Medical Information
            const SizedBox(height: 24),
            _buildSectionHeader('Medical Information', Icons.medical_information),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildBloodGroupDropdown(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _heightController,
                    label: 'Height (cm)',
                    icon: Icons.height,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _weightController,
                    label: 'Weight (kg)',
                    icon: Icons.monitor_weight,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildChipSection('Allergies', _allergies, Icons.warning),
            const SizedBox(height: 16),
            _buildChipSection('Medical History', _medicalHistory, Icons.history),
            const SizedBox(height: 16),
            _buildChipSection('Current Medications', _currentMedications, Icons.medication),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _registerPatient,
                icon: const Icon(Icons.save),
                label: const Text('Register Patient'),
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[700], size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    TextInputType? keyboardType,
    int? maxLines,
    int? maxLength,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label + (required ? ' *' : ''),
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
        counterText: '',
      ),
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      maxLength: maxLength,
      readOnly: readOnly,
      onTap: onTap,
      validator: required ? (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      } : null,
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: 'Gender *',
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: ['Male', 'Female', 'Other'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedGender = newValue;
          });
        }
      },
    );
  }

  Widget _buildBloodGroupDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedBloodGroup,
      decoration: InputDecoration(
        labelText: 'Blood Group',
        prefixIcon: const Icon(Icons.bloodtype),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedBloodGroup = newValue;
          });
        }
      },
    );
  }

  Widget _buildChipSection(String title, List<String> items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.add, color: Colors.blue[700]),
              onPressed: () => _addChipItem(title, items),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: items.map((item) => Chip(
            label: Text(item),
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: () {
              setState(() {
                items.remove(item);
              });
            },
            backgroundColor: Colors.blue[50],
            deleteIconColor: Colors.blue[700],
          )).toList(),
        ),
      ],
    );
  }

  Future<void> _searchPatient(String patientId) async {
    setState(() {
      _isSearching = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock patient data - in real app, this would come from API
    Map<String, dynamic>? patient = _getMockPatient(patientId);

    setState(() {
      _isSearching = false;
      _patientFound = patient != null;
      _existingPatient = patient;
    });
  }

  Map<String, dynamic>? _getMockPatient(String patientId) {
    // Mock data - replace with actual API call
    final mockPatients = {
      'john1234': {
        'patientId': 'PAT001',
        'firstName': 'John',
        'lastName': 'Doe',
        'phone': '+91 98765 43210',
        'email': 'john.doe@email.com',
        'lastVisit': '2024-01-15',
        'bloodGroup': 'O+',
        'age': 35,
      },
      'mary5678': {
        'patientId': 'PAT002',
        'firstName': 'Mary',
        'lastName': 'Smith',
        'phone': '+91 87654 32109',
        'email': 'mary.smith@email.com',
        'lastVisit': '2024-01-20',
        'bloodGroup': 'A+',
        'age': 28,
      },
    };

    return mockPatients[patientId.toLowerCase()];
  }

  void _prePopulateFromSearch() {
    String searchText = _searchController.text;
    if (searchText.length > 4) {
      // Extract name part (everything except last 4 digits)
      String namePart = searchText.substring(0, searchText.length - 4);
      _firstNameController.text = namePart;
      
      // Extract last 4 digits for Aadhaar
      String lastFourDigits = searchText.substring(searchText.length - 4);
      _aadhaarController.text = '********$lastFourDigits';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void _addChipItem(String category, List<String> items) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $category'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Enter $category',
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty && !items.contains(value)) {
              setState(() {
                items.add(value);
              });
            }
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _viewPatientDetails(Map<String, dynamic> patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailScreen(patient: patient),
      ),
    );
  }

  void _viewMedicalHistory(Map<String, dynamic> patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientMedicalHistoryScreen(patient: patient),
      ),
    );
  }

  void _proceedWithPatient(Map<String, dynamic> patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientTreatmentScreen(patient: patient),
      ),
    );
  }

  void _registerPatient() {
    if (_formKey.currentState!.validate()) {
      // Generate patient ID
      String patientId = 'PAT${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
      
      Map<String, dynamic> newPatient = {
        'patientId': patientId,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'aadhaar': _aadhaarController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'emergencyContact': _emergencyContactController.text,
        'dateOfBirth': _dobController.text,
        'gender': _selectedGender,
        'bloodGroup': _selectedBloodGroup,
        'height': _heightController.text,
        'weight': _weightController.text,
        'allergies': _allergies,
        'medicalHistory': _medicalHistory,
        'currentMedications': _currentMedications,
        'registrationDate': DateTime.now().toIso8601String(),
      };

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Patient registered successfully! ID: $patientId'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to patient details
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PatientDetailScreen(patient: newPatient),
        ),
      );
    }
  }
}

// Placeholder screens - to be implemented
class PatientDetailScreen extends StatelessWidget {
  final Map<String, dynamic> patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${patient['firstName']} ${patient['lastName']}'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Patient Detail Screen - To be implemented'),
      ),
    );
  }
}

class PatientTreatmentScreen extends StatelessWidget {
  final Map<String, dynamic> patient;

  const PatientTreatmentScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Treatment'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Patient Treatment Screen - To be implemented'),
      ),
    );
  }
}
