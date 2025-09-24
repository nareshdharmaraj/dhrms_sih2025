import 'package:flutter/material.dart';
import 'dart:convert';
import 'digital_health_card_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert' as convert;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/web_image_picker.dart';
import '../utils/app_constants.dart';
import '../utils/network_helper.dart';
import '../utils/card_download_service.dart';
import '../data/indian_states_districts_data.dart';

class PatientRegistrationScreen extends StatefulWidget {
  const PatientRegistrationScreen({super.key});

  @override
  State<PatientRegistrationScreen> createState() =>
      _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState extends State<PatientRegistrationScreen>
    with SingleTickerProviderStateMixin {
  final _personalFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();
  final _emergencyFormKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  late TabController _tabController;

  // Form Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dobController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _emergencyRelationController = TextEditingController();

  // Form State
  String? _selectedGender;
  String? _selectedBloodGroup;
  String? _selectedHomeState;
  String? _selectedState;
  String? _selectedCity;
  String? _selectedRelationship;
  Uint8List? _selectedImageBytes;
  String? _base64Image;
  bool _isLoading = false;

  // States list for India
  final List<String> _states = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
    'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu',
    'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
    'Andaman and Nicobar Islands', 'Chandigarh', 'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi', 'Jammu and Kashmir', 'Ladakh', 'Lakshadweep', 'Puducherry'
  ];

  // Cities map for major states
  final Map<String, List<String>> _citiesByState = {
    'Andhra Pradesh': ['Visakhapatnam', 'Vijayawada', 'Guntur', 'Nellore', 'Kurnool', 'Rajahmundry', 'Tirupati', 'Kadapa'],
    'Karnataka': ['Bengaluru', 'Mysuru', 'Hubballi', 'Mangaluru', 'Belagavi', 'Gulbarga', 'Davanagere', 'Ballari'],
    'Kerala': ['Kochi', 'Thiruvananthapuram', 'Kozhikode', 'Thrissur', 'Kollam', 'Palakkad', 'Alappuzha', 'Kannur'],
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai', 'Tiruchirappalli', 'Salem', 'Tirunelveli', 'Erode', 'Vellore'],
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Thane', 'Navi Mumbai', 'Aurangabad', 'Solapur', 'Amravati'],
    'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Bhavnagar', 'Jamnagar', 'Gandhinagar', 'Anand'],
    'Rajasthan': ['Jaipur', 'Jodhpur', 'Udaipur', 'Kota', 'Bikaner', 'Ajmer', 'Bhilwara', 'Alwar'],
    'Uttar Pradesh': ['Lucknow', 'Kanpur', 'Ghaziabad', 'Agra', 'Varanasi', 'Meerut', 'Allahabad', 'Bareilly'],
    'West Bengal': ['Kolkata', 'Howrah', 'Durgapur', 'Asansol', 'Siliguri', 'Malda', 'Bardhaman', 'Kharagpur'],
    'Delhi': ['New Delhi', 'Central Delhi', 'North Delhi', 'South Delhi', 'East Delhi', 'West Delhi', 'North East Delhi'],
    'Punjab': ['Chandigarh', 'Ludhiana', 'Amritsar', 'Jalandhar', 'Patiala', 'Bathinda', 'Mohali', 'Firozpur'],
    'Haryana': ['Faridabad', 'Gurgaon', 'Panipat', 'Ambala', 'Yamunanagar', 'Rohtak', 'Hisar', 'Karnal'],
    'Bihar': ['Patna', 'Gaya', 'Bhagalpur', 'Muzaffarpur', 'Purnia', 'Darbhanga', 'Bihar Sharif', 'Arrah'],
    'Odisha': ['Bhubaneswar', 'Cuttack', 'Rourkela', 'Brahmapur', 'Sambalpur', 'Puri', 'Balasore', 'Baripada'],
    'Jharkhand': ['Ranchi', 'Jamshedpur', 'Dhanbad', 'Bokaro', 'Deoghar', 'Phusro', 'Hazaribagh', 'Giridih'],
    'Assam': ['Guwahati', 'Silchar', 'Dibrugarh', 'Jorhat', 'Bongaigaon', 'Tinsukia', 'Tezpur', 'Nagaon'],
    'Chhattisgarh': ['Raipur', 'Bhilai', 'Bilaspur', 'Korba', 'Durg', 'Rajnandgaon', 'Jagdalpur', 'Raigarh'],
    'Goa': ['Panaji', 'Vasco da Gama', 'Margao', 'Mapusa', 'Ponda', 'Bicholim', 'Curchorem', 'Sanquelim'],
    'Himachal Pradesh': ['Shimla', 'Dharamshala', 'Solan', 'Mandi', 'Palampur', 'Baddi', 'Nahan', 'Una'],
    'Telangana': ['Hyderabad', 'Warangal', 'Nizamabad', 'Khammam', 'Karimnagar', 'Ramagundam', 'Mahabubnagar', 'Nalgonda'],
    'Madhya Pradesh': ['Bhopal', 'Indore', 'Gwalior', 'Jabalpur', 'Ujjain', 'Sagar', 'Dewas', 'Satna'],
    'Manipur': ['Imphal', 'Thoubal', 'Bishnupur', 'Churachandpur', 'Kakching', 'Ukhrul', 'Senapati', 'Tamenglong'],
    'Meghalaya': ['Shillong', 'Tura', 'Cherrapunji', 'Jowai', 'Baghmara', 'Nongpoh', 'Resubelpara', 'Williamnagar'],
  };

  // Relationship options for emergency contact
  final List<String> _relationships = [
    'Father', 'Mother', 'Spouse', 'Son', 'Daughter', 'Brother', 'Sister',
    'Uncle', 'Aunt', 'Grandfather', 'Grandmother', 'Cousin', 'Friend',
    'Guardian', 'Other'
  ];

  List<String> get _availableCities {
    if (_selectedState != null && _citiesByState.containsKey(_selectedState)) {
      return _citiesByState[_selectedState]!;
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  // Dropdowns data
  final List<String> _genders = ['male', 'female', 'other'];
  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
  // Get states from centralized data
  List<String> get _indianStates => IndianStatesDistrictsData.stateNames;

  @override
  void dispose() {
    // Dispose controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _aadhaarController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _emergencyRelationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      Uint8List? imageBytes;
      
      if (kIsWeb) {
        // Use web-specific image picker
        imageBytes = await WebImagePicker.pickImage();
      } else {
        // Use standard image picker for mobile
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 80,
        );

        if (image != null) {
          imageBytes = await image.readAsBytes();
        }
      }

      if (imageBytes != null) {
        final String base64String = convert.base64Encode(imageBytes);

        setState(() {
          _selectedImageBytes = imageBytes;
          _base64Image = base64String;
        });
      }
    } catch (e) {
      _showErrorDialog('Error picking image: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        Duration(days: 6570),
      ), // 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  String? _validateAadhaar(String? value) {
    if (value == null || value.isEmpty) {
      return 'Aadhaar number is required';
    }
    if (value.length != 12) {
      return 'Aadhaar number must be 12 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Aadhaar number must contain only digits';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length != 10) {
      return 'Phone number must be 10 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Phone number must contain only digits';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    // Email is optional
    if (value == null || value.isEmpty) {
      return null;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  bool _validatePersonalInfo() {
    bool isValid = true;
    List<String> missingFields = [];
    
    // Check form validation
    if (!(_personalFormKey.currentState?.validate() ?? false)) {
      isValid = false;
    }
    
    // Check specific required fields
    if (_firstNameController.text.trim().isEmpty) {
      missingFields.add('First Name');
      isValid = false;
    }
    if (_lastNameController.text.trim().isEmpty) {
      missingFields.add('Last Name');
      isValid = false;
    }
    if (_aadhaarController.text.trim().isEmpty || _aadhaarController.text.length != 12) {
      missingFields.add('Valid Aadhaar Number (12 digits)');
      isValid = false;
    }
    if (_phoneController.text.trim().isEmpty || _phoneController.text.length != 10) {
      missingFields.add('Valid Phone Number (10 digits)');
      isValid = false;
    }
    if (_passwordController.text.trim().isEmpty || _passwordController.text.length < 6) {
      missingFields.add('Password (min 6 characters)');
      isValid = false;
    }
    if (_confirmPasswordController.text.trim().isEmpty || _confirmPasswordController.text != _passwordController.text) {
      missingFields.add('Matching Password Confirmation');
      isValid = false;
    }
    if (_dobController.text.trim().isEmpty) {
      missingFields.add('Date of Birth');
      isValid = false;
    }
    if (_selectedGender == null) {
      missingFields.add('Gender');
      isValid = false;
    }
    if (_selectedBloodGroup == null) {
      missingFields.add('Blood Group');
      isValid = false;
    }
    
    if (!isValid && missingFields.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill: ${missingFields.join(', ')}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
    
    return isValid;
  }

  bool _validateAddressInfo() {
    bool isValid = true;
    List<String> missingFields = [];
    
    // Check form validation
    if (!(_addressFormKey.currentState?.validate() ?? false)) {
      isValid = false;
    }
    
    // Check specific required fields
    if (_streetController.text.trim().isEmpty) {
      missingFields.add('Address');
      isValid = false;
    }
    if (_selectedCity == null) {
      missingFields.add('City');
      isValid = false;
    }
    if (_selectedState == null) {
      missingFields.add('State');
      isValid = false;
    }
    if (_zipCodeController.text.trim().isEmpty) {
      missingFields.add('Pincode');
      isValid = false;
    }
    
    if (!isValid && missingFields.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill: ${missingFields.join(', ')}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
    
    return isValid;
  }


  bool _validateAllForms() {
    // Final validation - check all forms are complete without showing individual error messages
    
    // Validate personal form fields directly
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _aadhaarController.text.trim().isEmpty ||
        _aadhaarController.text.length != 12 ||
        _phoneController.text.trim().isEmpty ||
        _phoneController.text.length != 10 ||
        _passwordController.text.trim().isEmpty ||
        _passwordController.text.length < 6 ||
        _confirmPasswordController.text.trim().isEmpty ||
        _confirmPasswordController.text != _passwordController.text ||
        _dobController.text.trim().isEmpty ||
        _selectedGender == null ||
        _selectedBloodGroup == null) {
      
      _tabController.animateTo(0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please complete all personal information fields'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return false;
    }
    
    // Validate address form fields directly
    if (_streetController.text.trim().isEmpty ||
        _selectedCity == null ||
        _selectedState == null ||
        _zipCodeController.text.trim().isEmpty) {
      
      _tabController.animateTo(1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please complete all address information fields'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return false;
    }
    
    // Validate emergency contact fields directly
    if (_emergencyNameController.text.trim().isEmpty ||
        _emergencyPhoneController.text.trim().isEmpty ||
        _emergencyPhoneController.text.length != 10 ||
        _selectedRelationship == null) {
      
      _tabController.animateTo(2);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please complete all emergency contact information'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return false;
    }
    
    // All validation passed
    return true;
  }

  Future<void> _registerPatient() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Debug: Show which API endpoint is being used
      print('=== DEBUG: Registration API Endpoint ===');
      print('Using API base URL: ${AppConstants.apiBaseUrl}');
      print('Full registration URL: ${AppConstants.apiBaseUrl}/auth/register/patient');
      print('=======================================');
      
      // Convert date format
      List<String> dateParts = _dobController.text.split('/');
      String formattedDate =
          "${dateParts[2]}-${dateParts[1].padLeft(2, '0')}-${dateParts[0].padLeft(2, '0')}";

      final requestData = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'aadhaarNumber': _aadhaarController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        'password': _passwordController.text.trim(),
        'dateOfBirth': formattedDate,
        'gender': _selectedGender,
        'bloodGroup': _selectedBloodGroup,
        'address': {
          'street': _streetController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          'zipCode': _zipCodeController.text.trim(),
          'country': 'India',
        },
        'emergencyContact': {
          'name': _emergencyNameController.text.trim(),
          'phone': _emergencyPhoneController.text.trim(),
          'relationship': _emergencyRelationController.text.trim(),
        },
        'homeState': _selectedHomeState,
        'photo': _base64Image,
        'medicalHistory': [],
        'allergies': [],
        'currentMedications': [],
      };

      print('=== DEBUG: Registration Request Data ===');
      print('Request data keys: ${requestData.keys.toList()}');
      print('=======================================');

      // Use enhanced network helper with retry logic
      final response = await NetworkHelper.postWithRetry(
        endpoint: '${AppConstants.apiBaseUrl}/auth/register/patient',
        body: requestData,
        maxRetries: 3,
        timeoutSeconds: 30,
      );

      final responseData = json.decode(response.body);
      
      print('=== DEBUG: Registration Response ===');
      print('Status code: ${response.statusCode}');
      print('Response: $responseData');
      print('===================================');

      if (response.statusCode == 201 && responseData['success']) {
        // Registration successful
        final uhid = responseData['patient']?['uhid'] ?? responseData['uhid'];
        if (uhid != null) {
          // Show success dialog with download option
          _showSuccessDialogWithDownload(responseData['patient'], uhid);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration succeeded but UHID not found!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        _showErrorDialog(responseData['message'] ?? 'Registration failed');
      }
    } catch (e) {
      print('=== DEBUG: Registration Error ===');
      print('Error: $e');
      print('API URL was: ${AppConstants.apiBaseUrl}/auth/register/patient');
      print('===============================');
      
      _showErrorDialog('Network error: $e\nAPI: ${AppConstants.apiBaseUrl}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialogWithDownload(Map<String, dynamic> patientData, String uhid) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registration Successful!',
                      style: TextStyle(fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Digital Card Generated!',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your UHID and username have been generated:'),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'UHID: ${patientData['uhid']}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Username: ${patientData['username']}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Name: ${patientData['fullName']}'),
                      Text('Phone: ${patientData['phone']}'),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                
                // Card Generation Success Message
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.credit_card, color: Colors.green.shade700, size: 18),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '🎉 Digital Health Card Generated Successfully!',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.amber.shade700, size: 18),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Save your username and password for future login. Your digital health card is ready!',
                          style: TextStyle(
                            color: Colors.amber.shade700,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Column(
              children: [
                // Primary action buttons row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Navigate to digital health card screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DigitalHealthCardScreen(uhid: uhid),
                            ),
                          );
                        },
                        icon: Icon(Icons.credit_card, size: 16),
                        label: Flexible(
                          child: Text(
                            'View Card',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // Share card info quickly
                          await CardDownloadService.shareCard(
                            patientName: patientData['fullName'] ?? 'Unknown',
                            uhid: patientData['uhid'] ?? 'N/A',
                            bloodGroup: 'Not specified', // We don't have this in the response
                            emergencyContact: 'Set in profile',
                            issueDate: DateTime.now().toString().split(' ')[0],
                            context: context,
                          );
                        },
                        icon: Icon(Icons.share, size: 16),
                        label: Flexible(
                          child: Text(
                            'Share Info',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                // Secondary action row
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop(); // Go back to previous screen
                        },
                        child: Text('Close'),
                      ),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Navigate to card for download options
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DigitalHealthCardScreen(uhid: uhid),
                            ),
                          ).then((_) {
                            // Auto-show download options after card loads
                            Future.delayed(Duration(milliseconds: 500), () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('💡 Tip: Tap "Download" button to save your card!'),
                                  backgroundColor: Colors.blue.shade600,
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            });
                          });
                        },
                        icon: Icon(Icons.download, size: 16),
                        label: Flexible(
                          child: Text(
                            'Download',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Registration Failed',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
              Colors.teal.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Enhanced Header
              Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.indigo.shade800,
                      Colors.indigo.shade700,
                      Colors.green.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.health_and_safety,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Patient Registration',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 2),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Digital Health Record Management System',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Enhanced Tab Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        labelColor: Colors.blue.shade700,
                        unselectedLabelColor: Colors.white,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: [
                          Tab(
                            child: Container(
                              constraints: BoxConstraints(maxWidth: 100),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.person, size: 14),
                                  SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      'Personal',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Tab(
                            child: Container(
                              constraints: BoxConstraints(maxWidth: 100),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.location_on, size: 14),
                                  SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      'Address',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Tab(
                            child: Container(
                              constraints: BoxConstraints(maxWidth: 100),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.emergency, size: 14),
                                  SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      'Emergency',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPersonalInfoTab(),
                    _buildAddressInfoTab(),
                    _buildEmergencyInfoTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Form(
        key: _personalFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.blue.shade600,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Fill in your personal details',
                    style: TextStyle(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: 25),

            // Photo Upload Section
            _buildSectionCard(
              'Profile Photo',
              Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(60),
                        color: Colors.grey.shade100,
                      ),
                      child: _selectedImageBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(58),
                              child: Image.memory(
                                _selectedImageBytes!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  size: 30,
                                  color: Colors.grey.shade500,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Tap to upload',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Optional',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Personal Information
            _buildSectionCard(
              'Personal Information',
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: _buildTextField(
                          'First Name',
                          _firstNameController,
                          Icons.person,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: _buildTextField(
                          'Last Name',
                          _lastNameController,
                          Icons.person,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  _buildTextField(
                    'Aadhaar Number',
                    _aadhaarController,
                    Icons.credit_card,
                    keyboardType: TextInputType.number,
                    validator: _validateAadhaar,
                  ),
                  SizedBox(height: 15),
                  _buildTextField(
                    'Phone Number',
                    _phoneController,
                    Icons.phone,
                    keyboardType: TextInputType.number,
                    validator: _validatePhone,
                  ),
                  SizedBox(height: 15),
                  _buildTextField(
                    'Email (Optional)',
                    _emailController,
                    Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  SizedBox(height: 15),
                  _buildTextField(
                    'Password',
                    _passwordController,
                    Icons.lock,
                    obscureText: true,
                    validator: _validatePassword,
                  ),
                  SizedBox(height: 15),
                  _buildTextField(
                    'Confirm Password',
                    _confirmPasswordController,
                    Icons.lock_outline,
                    obscureText: true,
                    validator: _validateConfirmPassword,
                  ),
                  SizedBox(height: 15),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: _buildTextField(
                        'Date of Birth',
                        _dobController,
                        Icons.calendar_today,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: _buildDropdown(
                          'Gender',
                          _selectedGender,
                          _genders,
                          (value) => setState(() => _selectedGender = value),
                          Icons.person_outline,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: _buildDropdown(
                          'Blood Group',
                          _selectedBloodGroup,
                          _bloodGroups,
                          (value) =>
                              setState(() => _selectedBloodGroup = value),
                          Icons.bloodtype,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),
            // Continue Button
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                onPressed: () {
                  if (_validatePersonalInfo()) {
                    _tabController.animateTo(1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Personal info completed! ✓'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'Continue to Address Info',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressInfoTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Form(
        key: _addressFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.location_on,
                  size: 50,
                  color: Colors.blue.shade600,
                ),
                SizedBox(height: 10),
                Text(
                  'Address Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5),
                Text(
                  'Enter your residential address details',
                  style: TextStyle(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          SizedBox(height: 25),

          // Address Information
          _buildSectionCard(
            'Current Address',
            Column(
              children: [
                _buildTextField(
                  'Street Address',
                  _streetController,
                  Icons.home,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildDropdown(
                        'State',
                        _selectedState,
                        _states,
                        (value) {
                          setState(() {
                            _selectedState = value;
                            _selectedCity = null; // Reset city when state changes
                            _stateController.text = value ?? '';
                          });
                        },
                        Icons.map,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: _buildDropdown(
                        'City',
                        _selectedCity,
                        _availableCities,
                        (value) {
                          setState(() {
                            _selectedCity = value;
                            _cityController.text = value ?? '';
                          });
                        },
                        Icons.location_city,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildTextField(
                        'ZIP Code',
                        _zipCodeController,
                        Icons.pin_drop,
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: _buildDropdown(
                        'Home State',
                        _selectedHomeState,
                        _indianStates,
                        (value) =>
                            setState(() => _selectedHomeState = value),
                        Icons.map_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 30),
          // Navigation Buttons
          Row(
            children: [
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () {
                    _tabController.animateTo(0);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, size: 18),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Previous',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () {
                    if (_validateAddressInfo()) {
                      _tabController.animateTo(2);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Address info completed! ✓'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'Continue',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
      ),
    );
  }

  Widget _buildEmergencyInfoTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Form(
        key: _emergencyFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.emergency,
                  size: 50,
                  color: Colors.red.shade600,
                ),
                SizedBox(height: 10),
                Text(
                  'Emergency Contact',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5),
                Text(
                  'Add emergency contact information',
                  style: TextStyle(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          SizedBox(height: 25),

          // Emergency Contact
          _buildSectionCard(
            'Emergency Contact Details',
            Column(
              children: [
                _buildTextField(
                  'Emergency Contact Name',
                  _emergencyNameController,
                  Icons.person,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildTextField(
                        'Emergency Phone',
                        _emergencyPhoneController,
                        Icons.phone,
                        keyboardType: TextInputType.number,
                        validator: _validatePhone,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: _buildDropdown(
                        'Relationship',
                        _selectedRelationship,
                        _relationships,
                        (value) {
                          setState(() {
                            _selectedRelationship = value;
                            _emergencyRelationController.text = value ?? '';
                          });
                        },
                        Icons.family_restroom,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 30),

          // Register Button
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              onPressed: _isLoading ? null : () {
                print('=== DEBUG: Generate Card Button Clicked ===');
                print('First Name: ${_firstNameController.text}');
                print('Last Name: ${_lastNameController.text}');
                print('Aadhaar: ${_aadhaarController.text}');
                print('Phone: ${_phoneController.text}');
                print('Password: ${_passwordController.text}');
                print('DOB: ${_dobController.text}');
                print('Gender: $_selectedGender');
                print('Blood Group: $_selectedBloodGroup');
                print('Street: ${_streetController.text}');
                print('City: ${_cityController.text}');
                print('State: ${_stateController.text}');
                print('Zip: ${_zipCodeController.text}');
                print('Emergency Name: ${_emergencyNameController.text}');
                print('Emergency Phone: ${_emergencyPhoneController.text}');
                print('Emergency Relation: ${_emergencyRelationController.text}');
                print('Selected Relationship: $_selectedRelationship');
                print('Available Relationships: $_relationships');
                print('=== Starting Validation ===');
                
                if (_validateAllForms()) {
                  print('=== Validation Passed! Starting Registration ===');
                  _registerPatient();
                } else {
                  print('=== Validation Failed ===');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: _isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Creating Digital Health Card...',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_add, size: 22),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Generate Digital Health Card',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          SizedBox(height: 15),
          
          // Back Button
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              onPressed: () {
                _tabController.animateTo(1);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back, size: 18),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Back to Address Info',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),
        ],
      ),
      ),
    );
  }

  Widget _buildSectionCard(String title, Widget child) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width - 40,
      ),
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.blue.shade600, size: 18),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    void Function(String?) onChanged,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        onChanged: onChanged,
        validator: (value) => value == null ? 'Required' : null,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: EdgeInsets.all(6),
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue.shade600, size: 16),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(maxWidth: 200),
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
