import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/hospital_api_service.dart';
import '../services/api_client.dart';
import '../services/location_service.dart';
import '../services/rho_assignment_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'hospital_admin_dashboard_screen.dart';

/// Hospital Registration Screen
/// 
/// This screen handles hospital registration and assignment to existing RHOs
/// based on hierarchical location selection (State -> District -> Sub-district).
/// 
/// IMPORTANT: This screen only ASSIGNS hospitals to existing RHOs.
/// RHO creation is restricted to State Health Officers (SHOs) only.
class HospitalRegistrationScreen extends StatefulWidget {
  const HospitalRegistrationScreen({super.key});

  @override
  _HospitalRegistrationScreenState createState() =>
      _HospitalRegistrationScreenState();
}

class _HospitalRegistrationScreenState
    extends State<HospitalRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  // Hospital details controllers
  final _hospitalNameController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _licenseIdController = TextEditingController();
  final _totalBedsController = TextEditingController();
  final _establishedYearController = TextEditingController();
  final _websiteController = TextEditingController();

  // Admin details controllers
  final _adminUsernameController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  final _adminNameController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _adminPhoneController = TextEditingController();

  // Location selection variables
  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedSubDistrict;
  List<String> _availableStates = [];
  List<String> _availableDistricts = [];
  List<String> _availableSubDistricts = [];
  bool _isLoadingDistricts = false;
  bool _isLoadingSubDistricts = false;
  bool _requiresSubDistrict = false;

  // RHO assignment variables
  String? _assignedRHOId;
  RHOAssignmentPreview? _rhoPreview;
  bool _isLoadingRHOPreview = false;

  String _selectedHospitalType = 'Private';
  final List<String> _selectedSpecialties = [];
  bool _emergencyServices = false;
  bool _ambulanceServices = false;
  bool _isLoading = false;

  final List<String> _hospitalTypes = [
    'Government',
    'Private',
    'Semi-Government',
    'Trust',
    'Corporate',
  ];

  final List<String> _availableSpecialties = [
    'General Medicine',
    'Cardiology',
    'Neurology',
    'Orthopedics',
    'Pediatrics',
    'Gynecology',
    'Dermatology',
    'Psychiatry',
    'Surgery',
    'Anesthesiology',
    'Emergency Medicine',
    'Radiology',
    'Pathology',
    'Ophthalmology',
    'ENT',
    'Urology',
    'Nephrology',
    'Pulmonology',
    'Gastroenterology',
    'Endocrinology',
    'Oncology',
    'Rheumatology',
    'Plastic Surgery',
    'Neurosurgery',
    'Cardiac Surgery',
  ];

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  /// Load available states on initialization
  Future<void> _loadStates() async {
    try {
      final states = await LocationService.getStates();
      if (mounted) {
        setState(() {
          _availableStates = states;
          
          // Clear selected state if it's not in the loaded list
          if (_selectedState != null && !states.contains(_selectedState)) {
            _selectedState = null;
            _selectedDistrict = null;
            _selectedSubDistrict = null;
            _availableDistricts = [];
            _availableSubDistricts = [];
            _requiresSubDistrict = false;
            _rhoPreview = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to load states: $e');
      }
    }
  }

  /// Load districts when state is selected
  Future<void> _loadDistricts(String stateName) async {
    // Only avoid duplicate calls if we're already loading districts for the same state
    if (_isLoadingDistricts && _selectedState == stateName) {
      print('🔍 Already loading districts for $stateName, skipping duplicate call');
      return;
    }

    print('🔍 Loading districts for state: $stateName');

    setState(() {
      _isLoadingDistricts = true;
      _selectedDistrict = null;
      _selectedSubDistrict = null;
      _availableDistricts = [];
      _availableSubDistricts = [];
      _requiresSubDistrict = false;
      _rhoPreview = null;
    });

    try {
      final districts = await LocationService.getDistricts(stateName);
      print('✅ Loaded ${districts.length} districts for $stateName: ${districts.take(5).toList()}');
      print('🔍 All districts for $stateName: $districts');
      
      if (mounted) {
        setState(() {
          _availableDistricts = districts;
          _isLoadingDistricts = false;
          
          // Clear selected district if it's not in the new list
          if (_selectedDistrict != null && !districts.contains(_selectedDistrict)) {
            _selectedDistrict = null;
          }
        });
        print('✅ State updated with ${_availableDistricts.length} districts');
        print('🔍 Debug state: _selectedState=$_selectedState, _availableDistricts.isEmpty=${_availableDistricts.isEmpty}');
        print('🔍 Dropdown enabled: ${_selectedState != null && _availableDistricts.isNotEmpty}');
        print('🔍 Districts after setState: $_availableDistricts');
      }
    } catch (e) {
      print('❌ Error loading districts for $stateName: $e');
      if (mounted) {
        setState(() {
          _isLoadingDistricts = false;
        });
        _showErrorDialog('Failed to load districts: $e');
      }
    }
  }

  /// Load sub-districts when district is selected
  Future<void> _loadSubDistricts(String stateName, String districtName) async {
    print('🔍 Loading sub-districts for: $stateName > $districtName');
    
    setState(() {
      _isLoadingSubDistricts = true;
      _selectedSubDistrict = null;
      _availableSubDistricts = [];
      _rhoPreview = null;
    });

    try {
      final subDistricts = await LocationService.getSubDistricts(stateName, districtName);
      final requiresSubDistrict = await LocationService.requiresSubDistrictSelection(stateName, districtName);
      
      print('✅ Sub-districts loaded: ${subDistricts.length}, requires selection: $requiresSubDistrict');
      
      if (mounted) {
        setState(() {
          _availableSubDistricts = subDistricts;
          _requiresSubDistrict = requiresSubDistrict;
          _isLoadingSubDistricts = false;
          
          // Clear selected sub-district if it's not in the new list
          if (_selectedSubDistrict != null && !subDistricts.contains(_selectedSubDistrict)) {
            _selectedSubDistrict = null;
          }
        });

        // If sub-district is not required, automatically preview RHO assignment
        if (!requiresSubDistrict) {
          print('🔍 Auto-previewing RHO assignment (no sub-district required)');
          _previewRHOAssignment();
        } else {
          print('⏳ Waiting for sub-district selection...');
        }
      }
    } catch (e) {
      print('❌ Error loading sub-districts for $stateName > $districtName: $e');
      if (mounted) {
        setState(() {
          _isLoadingSubDistricts = false;
        });
        _showErrorDialog('Failed to load sub-districts: $e');
      }
    }
  }

  /// Preview RHO assignment for the selected location
  Future<void> _previewRHOAssignment() async {
    if (_selectedState == null || _selectedDistrict == null) return;
    if (_requiresSubDistrict && _selectedSubDistrict == null) return;

    setState(() {
      _isLoadingRHOPreview = true;
    });

    try {
      final preview = await RHOAssignmentService.previewRHOAssignment(
        stateName: _selectedState!,
        districtName: _selectedDistrict!,
        subDistrictName: _selectedSubDistrict,
      );

      if (mounted) {
        setState(() {
          _rhoPreview = preview;
          _isLoadingRHOPreview = false;
          
          // Set assigned RHO ID for automatic assignment
          print('🔍 RHO Preview Processing:');
          print('   hasAssignment: ${preview.hasAssignment}');
          print('   assignedRHOId: ${preview.assignedRHOId}');
          print('   availableRHOs: ${preview.availableRHOs}');
          print('   requiresManualSelection: ${preview.requiresManualSelection}');
          
          if (preview.hasAssignment) {
            // Use the assignedRHOId from preview (works for both pre-assigned and automatic assignment)
            _assignedRHOId = preview.assignedRHOId;
            print('✅ Set _assignedRHOId from preview: $_assignedRHOId');
            
            // If we also have the RHO object, we can get additional details
            if (preview.assignedRHO != null) {
              print('✅ RHO object available: ${preview.assignedRHO!.fullName}');
            }
          } else if (preview.requiresManualSelection && preview.availableRHOs.isNotEmpty) {
            // For districts with multiple RHOs, use the first available one for automatic assignment
            _assignedRHOId = preview.availableRHOs.first;
            print('✅ Set _assignedRHOId from multiple options: $_assignedRHOId');
          } else if (preview.availableRHOs.isNotEmpty) {
            // Fallback: if there are available RHOs but no assignment, use the first one
            _assignedRHOId = preview.availableRHOs.first;
            print('✅ Using fallback RHO assignment: $_assignedRHOId');
          } else {
            // Clear the assignment if no RHOs are available
            _assignedRHOId = null;
            print('❌ No RHOs available, cleared _assignedRHOId');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRHOPreview = false;
        });
        _showErrorDialog('Failed to preview RHO assignment: $e');
      }
    }
  }





  /// Build RHO assignment preview card
  Widget _buildRHOAssignmentCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'RHO Assignment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            
            if (_isLoadingRHOPreview) ...[
              Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
            ] else if (_rhoPreview == null) ...[
              Text(
                'Complete location selection to see RHO assignment',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ] else if (_rhoPreview!.isUnassigned) ...[
              Text(
                'RHO not created or assigned',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Please contact your State Health Officer (SHO) to assign an RHO for this location',
                style: TextStyle(color: Colors.grey[600]),
              ),
              if (_rhoPreview!.formattedLocation != null)
                Text(
                  'Location: ${_rhoPreview!.formattedLocation}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
            ] else if (_rhoPreview!.hasAssignment) ...[
              Text(
                _rhoPreview!.displayMessage,
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_rhoPreview!.assignedRHO != null) ...[
                SizedBox(height: 4),
                Text(
                  'Email: ${_rhoPreview!.assignedRHO.email}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  'Phone: ${_rhoPreview!.assignedRHO.phone}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
              if (_rhoPreview!.formattedLocation != null)
                Text(
                  'Location: ${_rhoPreview!.formattedLocation}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
            ] else if (_rhoPreview!.requiresManualSelection) ...[
              Text(
                'RHO Assignment Available',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Multiple RHOs serve this district. System will assign the most suitable RHO automatically.',
                style: TextStyle(color: Colors.grey[600]),
              ),
              if (_rhoPreview!.formattedLocation != null) ...[
                SizedBox(height: 4),
                Text(
                  'Location: ${_rhoPreview!.formattedLocation}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ] else if (_rhoPreview!.requiresSubDistrict) ...[
              Text(
                'Sub-district selection required',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else ...[
              Text(
                'No RHO available for this location',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }



  @override
  void dispose() {
    _hospitalNameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _registrationNumberController.dispose();
    _licenseIdController.dispose();
    _totalBedsController.dispose();
    _establishedYearController.dispose();
    _websiteController.dispose();
    _adminUsernameController.dispose();
    _adminPasswordController.dispose();
    _adminNameController.dispose();
    _adminEmailController.dispose();
    _adminPhoneController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _registerHospital() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate location selection
    if (_selectedState == null || _selectedDistrict == null) {
      _showErrorDialog('Please complete the location selection');
      return;
    }

    if (_requiresSubDistrict && _selectedSubDistrict == null) {
      _showErrorDialog('Please select a sub-district for this location');
      return;
    }

    // Validate RHO assignment - simplified without manual selection
    if (_rhoPreview == null) {
      _showErrorDialog('RHO assignment information not available. Please complete location selection.');
      return;
    }
    
    print('🔍 Registration validation - RHO Preview state:');
    print('   isUnassigned: ${_rhoPreview!.isUnassigned}');
    print('   requiresSubDistrict: ${_rhoPreview!.requiresSubDistrict}');
    print('   hasAssignment: ${_rhoPreview!.hasAssignment}');
    print('   assignedRHOId: ${_rhoPreview!.assignedRHOId}');
    print('   _assignedRHOId variable: $_assignedRHOId');
    
    if (_rhoPreview!.isUnassigned) {
      _showErrorDialog('No RHO has been assigned for this location. Please contact your State Health Officer (SHO) to assign an RHO before registering hospitals in this area.');
      return;
    }
    
    if (_rhoPreview!.requiresSubDistrict) {
      _showErrorDialog('Please complete the location selection by selecting a sub-district.');
      return;
    }
    
    // Ensure we have a valid RHO assignment ID
    if (_assignedRHOId == null || _assignedRHOId!.isEmpty) {
      _showErrorDialog('RHO assignment ID is missing. Please re-select your location to refresh RHO assignment.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final hospitalData = {
        'hospitalName': _hospitalNameController.text.trim(),
        'address': {
          'street': _streetController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _selectedState,
          'district': _selectedDistrict,
          'subDistrict': _selectedSubDistrict,
          'pincode': _pincodeController.text.trim(),
        },
        'contactNumber': _contactNumberController.text.trim(),
        'email': _emailController.text.trim(),
        'registrationNumber': _registrationNumberController.text.trim(),
        'licenseId': _licenseIdController.text.trim(),
        'hospitalType': _selectedHospitalType,
        'specialties': _selectedSpecialties,
        'totalBeds': int.tryParse(_totalBedsController.text) ?? 0,
        'emergencyServices': _emergencyServices,
        'ambulanceServices': _ambulanceServices,
        'website': _websiteController.text.trim().isNotEmpty
            ? _websiteController.text.trim()
            : null,
        'establishedYear': int.tryParse(_establishedYearController.text),
        'adminDetails': {
          'username': _adminUsernameController.text.trim(),
          'password': _adminPasswordController.text,
          'adminName': _adminNameController.text.trim(),
          'adminEmail': _adminEmailController.text.trim(),
          'adminPhone': _adminPhoneController.text.trim(),
        },
        'rhoAssignment': {
          'assignedRHOId': _assignedRHOId,
          'assignmentType': 'automatic',
        },
      };

      print('🔍 Hospital registration data being submitted:');
      print('📍 Address: ${hospitalData['address']}');
      print('🏥 Hospital: ${hospitalData['hospitalName']}');
      print('👨‍⚕️ RHO Assignment: ${hospitalData['rhoAssignment']}');

      final data = await HospitalApiService.registerHospital(hospitalData);

      // Store token and admin data
      await ApiClient.setAuthToken(data['data']['token']);

      // Assign hospital to RHO
      final hospitalId = data['data']['hospital']['hospitalId'];
      if (hospitalId != null) {
        final rhoAssignmentResult = await RHOAssignmentService.assignHospitalToRHO(
          hospitalId: hospitalId,
          stateName: _selectedState!,
          districtName: _selectedDistrict!,
          subDistrictName: _selectedSubDistrict,
        );

        if (!rhoAssignmentResult.success) {
          print('Warning: RHO assignment failed: ${rhoAssignmentResult.message}');
          // Continue with success dialog even if RHO assignment fails
          // This can be handled later in the admin dashboard
        }
      }

      // Show success dialog
      _showSuccessDialog(data['data']);
    } catch (e) {
      _showErrorDialog('Registration error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Hospital Registered Successfully!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your hospital has been registered successfully.'),
            SizedBox(height: 16),
            Text(
              'Hospital ID: ${data['hospital']['hospitalId']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Admin ID: ${data['admin']['adminId']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Please save these IDs for future reference.',
              style: TextStyle(color: Colors.orange[700]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HospitalAdminDashboardScreen(),
                ),
              );
            },
            child: Text('Continue to Dashboard'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Registration Failed'),
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

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildHospitalDetailsPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hospital Information',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),

          CustomTextField(
            controller: _hospitalNameController,
            labelText: 'Hospital Name',
            prefixIcon: Icons.local_hospital,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter hospital name';
              }
              if (value.length < 2) {
                return 'Hospital name must be at least 2 characters';
              }
              return null;
            },
          ),

          SizedBox(height: 16),

          CustomTextField(
            controller: _streetController,
            labelText: 'Street Address',
            prefixIcon: Icons.location_on,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter street address';
              }
              return null;
            },
          ),

          SizedBox(height: 16),

          // State Selection
          DropdownButtonFormField<String>(
            value: _selectedState,
            decoration: InputDecoration(
              labelText: 'State *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.map),
              suffixIcon: _availableStates.isEmpty 
                  ? SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2)
                    ) 
                  : null,
            ),
            items: _availableStates.isEmpty 
              ? <DropdownMenuItem<String>>[]
              : _availableStates.map((state) {
                  return DropdownMenuItem<String>(
                    value: state,
                    child: Text(state),
                  );
                }).toList(),
            onChanged: _availableStates.isNotEmpty ? (value) {
              if (value != null) {
                print('🔍 State selected: $value');
                print('🔍 Previous state: $_selectedState');
                setState(() {
                  _selectedState = value;
                  _selectedDistrict = null; // Reset district when state changes
                  _selectedSubDistrict = null; // Reset sub-district when state changes
                  _availableDistricts = []; // Clear districts
                  _availableSubDistricts = []; // Clear sub-districts
                  _requiresSubDistrict = false;
                });
                print('🔍 State updated in setState, now calling _loadDistricts($value)');
                _loadDistricts(value);
              }
            } : null,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a state';
              }
              return null;
            },
          ),

          // DEBUG: Show current state information
          if (kDebugMode) 
            Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DEBUG INFO:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text('Selected State: $_selectedState', style: TextStyle(fontSize: 11)),
                  Text('Available Districts: ${_availableDistricts.length}', style: TextStyle(fontSize: 11)),
                  Text('Loading Districts: $_isLoadingDistricts', style: TextStyle(fontSize: 11)),
                  Text('Districts: ${_availableDistricts.take(3).toList()}${_availableDistricts.length > 3 ? '...' : ''}', style: TextStyle(fontSize: 11)),
                  Text('Dropdown Enabled: ${_selectedState != null && _availableDistricts.isNotEmpty && !_isLoadingDistricts}', style: TextStyle(fontSize: 11)),
                ],
              ),
            ),

          SizedBox(height: 16),

          // District Selection
          DropdownButtonFormField<String>(
            value: _selectedDistrict,
            decoration: InputDecoration(
              labelText: 'District *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_city),
              suffixIcon: _isLoadingDistricts 
                  ? SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2)
                    ) 
                  : null,
              helperText: _availableDistricts.isEmpty && _selectedState != null 
                  ? 'Loading districts...' 
                  : _availableDistricts.isEmpty 
                    ? 'Please select a state first'
                    : '${_availableDistricts.length} districts available',
            ),
            items: _availableDistricts.isEmpty 
              ? <DropdownMenuItem<String>>[]
              : _availableDistricts.map((district) {
                  return DropdownMenuItem<String>(
                    value: district,
                    child: Text(district),
                  );
                }).toList(),
            onChanged: (_selectedState != null && _availableDistricts.isNotEmpty && !_isLoadingDistricts) ? (value) {
              if (value != null) {
                print('🔍 District selected: $value');
                setState(() {
                  _selectedDistrict = value;
                  _selectedSubDistrict = null; // Reset sub-district when district changes
                  _availableSubDistricts = []; // Clear sub-districts
                  _requiresSubDistrict = false;
                });
                _loadSubDistricts(_selectedState!, value);
                
                // Trigger RHO assignment preview immediately for the selected district
                print('🔍 Triggering RHO assignment preview for district: $value');
                _previewRHOAssignment();
              }
            } : null,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a district';
              }
              return null;
            },
          ),

          SizedBox(height: 16),

          // City and Pincode (always shown)
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _cityController,
                  labelText: 'City/Town *',
                  prefixIcon: Icons.location_city,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter city/town';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  controller: _pincodeController,
                  labelText: 'Pincode *',
                  prefixIcon: Icons.pin_drop,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter pincode';
                    }
                    if (value.length != 6) {
                      return 'Pincode must be 6 digits';
                    }
                    if (!RegExp(r'^\d+$').hasMatch(value)) {
                      return 'Pincode must contain only numbers';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Sub-District Selection (conditional - for RHO assignment only)
          if (_requiresSubDistrict) ...[
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      SizedBox(width: 8),
                      Text(
                        'Additional Location Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This district has multiple administrative areas. Please select the specific sub-district for RHO assignment:',
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedSubDistrict,
                    decoration: InputDecoration(
                      labelText: 'Sub-District (Administrative Area) *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.account_tree),
                      suffixIcon: _isLoadingSubDistricts 
                          ? SizedBox(
                              width: 20, 
                              height: 20, 
                              child: CircularProgressIndicator(strokeWidth: 2)
                            ) 
                          : null,
                    ),
                    items: _availableSubDistricts.isEmpty 
                      ? <DropdownMenuItem<String>>[]
                      : _availableSubDistricts.map((subDistrict) {
                          return DropdownMenuItem<String>(
                            value: subDistrict,
                            child: Text(subDistrict),
                          );
                        }).toList(),
                    onChanged: _selectedDistrict == null ? null : (value) {
                      setState(() {
                        _selectedSubDistrict = value;
                      });
                      if (value != null) {
                        _previewRHOAssignment();
                      }
                    },
                    validator: (value) {
                      if (_requiresSubDistrict && (value == null || value.isEmpty)) {
                        return 'Please select a sub-district';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],

          SizedBox(height: 16),

          // RHO Assignment Information
          _buildRHOAssignmentCard(),

          SizedBox(height: 16),

          CustomTextField(
            controller: _contactNumberController,
            labelText: 'Contact Number',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter contact number';
              }
              if (!RegExp(r'^\d+$').hasMatch(value)) {
                return 'Contact number must contain only numbers';
              }
              if (value.length != 10) {
                return 'Contact number must be 10 digits';
              }
              return null;
            },
          ),

          SizedBox(height: 16),

          CustomTextField(
            controller: _emailController,
            labelText: 'Email',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalDetailsPage2() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hospital Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),

          CustomTextField(
            controller: _registrationNumberController,
            labelText: 'Registration Number',
            prefixIcon: Icons.assignment,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter registration number';
              }
              return null;
            },
          ),

          SizedBox(height: 16),

          CustomTextField(
            controller: _licenseIdController,
            labelText: 'License ID',
            prefixIcon: Icons.verified,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter license ID';
              }
              return null;
            },
          ),

          SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedHospitalType,
            decoration: InputDecoration(
              labelText: 'Hospital Type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.business),
            ),
            items: _hospitalTypes.isEmpty 
              ? <DropdownMenuItem<String>>[]
              : _hospitalTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedHospitalType = value!;
              });
            },
          ),

          SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _totalBedsController,
                  labelText: 'Total Beds',
                  prefixIcon: Icons.hotel,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final beds = int.tryParse(value);
                      if (beds == null || beds <= 0) {
                        return 'Please enter a valid number';
                      }
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  controller: _establishedYearController,
                  labelText: 'Established Year',
                  prefixIcon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final year = int.tryParse(value);
                      if (year == null ||
                          year < 1800 ||
                          year > DateTime.now().year) {
                        return 'Please enter a valid year';
                      }
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          CustomTextField(
            controller: _websiteController,
            labelText: 'Website (Optional)',
            prefixIcon: Icons.web,
            keyboardType: TextInputType.url,
          ),

          SizedBox(height: 24),

          Text(
            'Services Available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),

          SizedBox(height: 16),

          CheckboxListTile(
            title: Text('Emergency Services'),
            value: _emergencyServices,
            onChanged: (value) {
              setState(() {
                _emergencyServices = value!;
              });
            },
          ),

          CheckboxListTile(
            title: Text('Ambulance Services'),
            value: _ambulanceServices,
            onChanged: (value) {
              setState(() {
                _ambulanceServices = value!;
              });
            },
          ),

          SizedBox(height: 24),

          Text(
            'Specialties',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Select the medical specialties available at your hospital',
            style: TextStyle(color: Colors.grey[600]),
          ),

          SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableSpecialties.map((specialty) {
              final isSelected = _selectedSpecialties.contains(specialty);
              return FilterChip(
                label: Text(specialty),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSpecialties.add(specialty);
                    } else {
                      _selectedSpecialties.remove(specialty);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminDetailsPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin Account Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Create an admin account to manage your hospital',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 24),

          CustomTextField(
            controller: _adminNameController,
            labelText: 'Admin Full Name (letters and spaces only)',
            prefixIcon: Icons.person,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter admin name';
              }
              if (value.length < 2) {
                return 'Name must be at least 2 characters';
              }
              if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                return 'Admin name can only contain letters and spaces';
              }
              return null;
            },
          ),

          SizedBox(height: 16),

          CustomTextField(
            controller: _adminUsernameController,
            labelText: 'Username',
            prefixIcon: Icons.account_circle,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter username';
              }
              if (value.length < 3) {
                return 'Username must be at least 3 characters';
              }
              if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                return 'Username can only contain letters, numbers, and underscores';
              }
              return null;
            },
          ),

          SizedBox(height: 16),

          CustomTextField(
            controller: _adminPasswordController,
            labelText: 'Password',
            prefixIcon: Icons.lock,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),

          SizedBox(height: 16),

          CustomTextField(
            controller: _adminEmailController,
            labelText: 'Admin Email',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter admin email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),

          SizedBox(height: 16),

          CustomTextField(
            controller: _adminPhoneController,
            labelText: 'Admin Phone',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter admin phone number';
              }
              if (!RegExp(r'^\d+$').hasMatch(value)) {
                return 'Phone number must contain only numbers';
              }
              if (value.length != 10) {
                return 'Phone number must be 10 digits';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hospital Registration'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  for (int i = 0; i < 3; i++)
                    Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: i <= _currentPage
                              ? Colors.blue[700]
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildHospitalDetailsPage(),
                  _buildHospitalDetailsPage2(),
                  _buildAdminDetailsPage(),
                ],
              ),
            ),

            // Navigation buttons
            Container(
              padding: EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        child: Text('Previous'),
                      ),
                    ),

                  if (_currentPage > 0) SizedBox(width: 16),

                  Expanded(
                    child: _currentPage < 2
                        ? ElevatedButton(
                            onPressed: _nextPage,
                            child: Text('Next'),
                          )
                        : CustomButton(
                            text: 'Register Hospital',
                            onPressed: _isLoading ? null : _registerHospital,
                            isLoading: _isLoading,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
