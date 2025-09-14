import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import '../utils/app_constants.dart';
import '../widgets/custom_button.dart';
import 'digital_health_card_screen.dart';
import 'wearables_screen_simple.dart';
import 'emergency_contacts_screen.dart';
import 'advanced_sos_screen.dart';
import 'dart:ui';

class PatientDashboardScreen extends StatefulWidget {
  final String? uhid;
  final Map<String, dynamic>? patientData;
  
  const PatientDashboardScreen({
    super.key, 
    this.uhid,
    this.patientData,
  });

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> 
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  // Store patient data from navigation arguments
  Map<String, dynamic>? _patientDataFromArgs;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _sosController;
  late Animation<double> _sosScaleAnimation;
  late AnimationController _sosRippleController;
  late Animation<double> _sosRippleAnimation;
  
  // New animation controllers for enhanced interactivity
  late AnimationController _cardHoverController;
  late AnimationController _healthStatsController;
  late Animation<double> _healthStatsAnimation;
  late AnimationController _quickActionsController;
  late Animation<Offset> _quickActionsAnimation;
  
  // Track hover states for interactive cards
  bool _emergencyCardHovered = false;
  bool _wearablesCardHovered = false;
  Set<int> _hoveredActionCards = {};
  Set<int> _hoveredStatCards = {};
  
  // Real data state variables
  List<dynamic> medicalRecords = [];
  List<dynamic> appointments = [];
  Map<String, dynamic>? healthData;
  List<String> healthTips = [];
  bool isLoading = true;
  String? error;
  
  // Cached photo to avoid repeated lookups during builds
  String? _cachedPatientPhoto;
  bool _photoCache = false;
  
  // Additional persistent storage for decoded photo bytes to avoid re-decoding
  Uint8List? _decodedPhotoBytes;
  
  // Get patient data considering both constructor props and route arguments
  Map<String, dynamic>? get combinedPatientData {
    // First try navigation arguments, then fall back to widget props
    return _patientDataFromArgs ?? widget.patientData;
  }
  
  String get patientName => combinedPatientData?['fullName'] ?? 'Patient User';
  String get patientUhid {
    // Debug: Print all available data fields
    if (combinedPatientData != null) {
      print('Debug - All available fields in combinedPatientData:');
      combinedPatientData!.forEach((key, value) {
        print('  $key: $value');
      });
    }
    
    // Try multiple possible UHID field names from database
    final uhid = widget.uhid ?? 
                 combinedPatientData?['uhid'] ?? 
                 combinedPatientData?['patientId'] ??
                 combinedPatientData?['patient_id'] ??
                 combinedPatientData?['unique_id'] ??
                 combinedPatientData?['healthId'] ??
                 combinedPatientData?['health_id'] ??
                 combinedPatientData?['UHID'];  // Try uppercase version
    
    print('UHID lookup - widget.uhid: ${widget.uhid}');
    print('UHID lookup - widget.patientData: ${widget.patientData}');
    print('Found UHID: $uhid');
    
    // Return the actual UHID or a fallback only if none found
    return uhid?.toString() ?? 'Not Available';
  }
  String get patientBloodGroup {
    // Try all possible blood group field names with various formats
    final bloodGroup = combinedPatientData?['bloodGroup'] ?? 
                      combinedPatientData?['blood_group'] ?? 
                      combinedPatientData?['bloodType'] ?? 
                      combinedPatientData?['blood_type'] ?? 
                      healthData?['bloodGroup'] ?? 
                      healthData?['blood_group'] ?? 
                      healthData?['bloodType'] ?? 
                      healthData?['blood_type'] ??
                      // Try nested patient fields that might contain blood group
                      (combinedPatientData?['patient'] is Map ? 
                         (combinedPatientData?['patient']['bloodGroup'] ?? 
                          combinedPatientData?['patient']['blood_group'] ?? 
                          combinedPatientData?['patient']['bloodType']) : null) ??
                      // Try nested user fields that might contain blood group
                      (combinedPatientData?['user'] is Map ? 
                         (combinedPatientData?['user']['bloodGroup'] ?? 
                          combinedPatientData?['user']['blood_group'] ?? 
                          combinedPatientData?['user']['bloodType']) : null);
    
    print('Blood group lookup - widget.patientData: ${widget.patientData}');
    print('Blood group lookup - _patientDataFromArgs: ${_patientDataFromArgs}');
    print('Blood group lookup - healthData: ${healthData}');
    print('Found blood group: $bloodGroup');
    
    // Format the blood group properly if it exists
    if (bloodGroup != null) {
      String formattedBloodGroup = bloodGroup.toString().trim().toUpperCase();
      
      // Normalize common blood group formats
      if (formattedBloodGroup.contains('+')) {
        // Already has a plus sign
      } else if (formattedBloodGroup.contains('POSITIVE') || formattedBloodGroup.endsWith('POS')) {
        formattedBloodGroup = formattedBloodGroup
          .replaceAll('POSITIVE', '+')
          .replaceAll('POS', '+');
      } 
      
      if (formattedBloodGroup.contains('-')) {
        // Already has a minus sign
      } else if (formattedBloodGroup.contains('NEGATIVE') || formattedBloodGroup.endsWith('NEG')) {
        formattedBloodGroup = formattedBloodGroup
          .replaceAll('NEGATIVE', '-')
          .replaceAll('NEG', '-');
      }
      
      // Clean up the string for display
      formattedBloodGroup = formattedBloodGroup
        .replaceAll(' ', '')
        .replaceAll('TYPE', '');
        
      return formattedBloodGroup;
    }
    
    return 'Not Available';
  }
  
  String get patientAge {
    // Try all possible date of birth field names and formats
    final dob = combinedPatientData?['dateOfBirth'] ?? 
               combinedPatientData?['date_of_birth'] ?? 
               combinedPatientData?['dob'] ?? 
               combinedPatientData?['DOB'] ?? 
               healthData?['dateOfBirth'] ?? 
               healthData?['date_of_birth'] ?? 
               healthData?['dob'] ?? 
               healthData?['DOB'] ??
               // Try nested patient fields that might contain DOB
               (combinedPatientData?['patient'] is Map ? 
                  (combinedPatientData?['patient']['dateOfBirth'] ?? 
                   combinedPatientData?['patient']['dob'] ?? 
                   combinedPatientData?['patient']['DOB']) : null) ??
               // Try nested user fields that might contain DOB
               (combinedPatientData?['user'] is Map ? 
                  (combinedPatientData?['user']['dateOfBirth'] ?? 
                   combinedPatientData?['user']['dob'] ?? 
                   combinedPatientData?['user']['DOB']) : null);
    
    print('DOB lookup - widget.patientData: ${widget.patientData}');
    print('DOB lookup - _patientDataFromArgs: ${_patientDataFromArgs}');
    print('DOB lookup - healthData: ${healthData}');
    print('Found DOB: $dob');
    
    return _calculateAge(dob);
  }
  String get patientHealthStatus => healthData?['healthStatus'] ?? combinedPatientData?['healthStatus'] ?? 'Unknown';
  
  // Get patient photo from various possible field names
  String? get patientPhoto {
    // Return cached value immediately if already computed
    if (_photoCache) {
      return _cachedPatientPhoto;
    }
    
    // Only perform lookup once
    print('Performing photo lookup (first time only)...');
    
    // Try all possible photo field names and formats
    final photo = combinedPatientData?['photo'] ?? 
                 combinedPatientData?['profilePicture'] ?? 
                 combinedPatientData?['profileImage'] ?? 
                 combinedPatientData?['profile_picture'] ?? 
                 combinedPatientData?['profile_image'] ?? 
                 combinedPatientData?['avatar'] ?? 
                 healthData?['photo'] ?? 
                 healthData?['profilePicture'] ?? 
                 healthData?['profileImage'] ?? 
                 // Try nested patient fields that might contain photo
                 (combinedPatientData?['patient'] is Map ? 
                    (combinedPatientData?['patient']['photo'] ?? 
                     combinedPatientData?['patient']['profilePicture'] ?? 
                     combinedPatientData?['patient']['profileImage']) : null) ??
                 // Try nested user fields that might contain photo
                 (combinedPatientData?['user'] is Map ? 
                    (combinedPatientData?['user']['photo'] ?? 
                     combinedPatientData?['user']['profilePicture'] ?? 
                     combinedPatientData?['user']['profileImage']) : null);
    
    // Cache the result immediately to prevent re-execution
    if (photo != null && photo.toString().trim().isNotEmpty) {
      _cachedPatientPhoto = photo.toString();
      print('Photo found and cached (${_cachedPatientPhoto!.length} chars) - will persist until logout');
    } else {
      _cachedPatientPhoto = null;
      print('No photo found - cached null result');
    }
    _photoCache = true;
    
    return _cachedPatientPhoto;
  }
  
  // Get actual health metrics from database
  int get totalMedicalRecords => medicalRecords.length;
  int get upcomingAppointments => appointments.where((apt) => 
    apt['status'] == 'scheduled' || apt['status'] == 'confirmed').length;
  int get activeConditions => (combinedPatientData?['medicalHistory'] as List?)?.length ?? 
                             (healthData?['conditions'] as List?)?.length ?? 0;

  // Helper method to safely get patient photo image provider
  ImageProvider? _getPatientPhotoImageProvider() {
    // Return cached decoded bytes immediately if available
    if (_decodedPhotoBytes != null) {
      return MemoryImage(_decodedPhotoBytes!);
    }
    
    final photoData = patientPhoto; // This will use cached value
    if (photoData == null || photoData.isEmpty) {
      return null;
    }
    
    try {
      print('Decoding photo data once (${photoData.length} chars)...');
      // Try to decode the base64 string
      final bytes = base64Decode(photoData);
      
      // Cache the decoded bytes permanently for this session
      _decodedPhotoBytes = bytes;
      print('Photo decoded and cached (${bytes.length} bytes) - no more decoding needed');
      
      return MemoryImage(bytes);
    } catch (e) {
      print('Error decoding patient photo: $e');
      // If it's not base64, might be a URL or invalid data
      return null;
    }
  }

  // Clear photo cache when patient data changes
  void _clearPhotoCache() {
    _photoCache = false;
    _cachedPatientPhoto = null;
    _decodedPhotoBytes = null;
  }

  // Smart photo cache update - only clear if we have new photo data or need to force refresh
  void _updatePhotoCache() {
    // Check if we have new photo data in the updated patient data
    final newPhoto = combinedPatientData?['photo'] ?? 
                    combinedPatientData?['profilePicture'] ?? 
                    combinedPatientData?['profileImage'];
    
    if (newPhoto != null && newPhoto.toString().trim().isNotEmpty) {
      // We have new photo data, update the cache
      print('New photo data detected - updating cache');
      _clearPhotoCache();
    } else if (_cachedPatientPhoto == null && !_photoCache) {
      // No cached photo and no new photo, allow cache refresh
      print('No existing cache - allowing photo lookup');
      _clearPhotoCache();
    }
    // Otherwise keep existing cached photo silently
  }

  // Force refresh photo cache
  void _refreshPhoto() {
    _clearPhotoCache();
    // Trigger getter to reload photo
    final photo = patientPhoto;
    if (photo != null) {
      print('Photo refreshed successfully');
    }
  }

  @override
  void initState() {
    super.initState();
    
    // Debug: Print UHID information
    print('=== DASHBOARD INITIALIZATION ===');
    print('Enhanced Dashboard - Received UHID: ${widget.uhid}');
    print('Enhanced Dashboard - Patient Data: ${widget.patientData}');
    print('Enhanced Dashboard - Patient Data Keys: ${widget.patientData?.keys}');
    
    // Initialize all animations immediately to prevent null errors
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _sosController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _sosRippleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Initialize new animation controllers
    _cardHoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _healthStatsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _quickActionsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Initialize all animation values
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));
    
    _sosScaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _sosController, curve: Curves.easeInOut),
    );
    
    _sosRippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sosRippleController, curve: Curves.easeOut),
    );
    
    // Initialize new animations
    _healthStatsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _healthStatsController, curve: Curves.elasticOut),
    );
    
    _quickActionsAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _quickActionsController, curve: Curves.easeOutCubic));
    
    // Start animations with staggered delays for better effect
    _fadeController.forward();
    _slideController.forward();
    _sosController.repeat(reverse: true);
    _sosRippleController.repeat();
    _healthStatsController.forward();
    _quickActionsController.forward();
    
    // Retrieve route arguments if available
    Future.delayed(Duration.zero, () {
      final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (routeArgs != null) {
        print('Route arguments received: $routeArgs');
        print('Route arguments keys: ${routeArgs.keys.toList()}');
        
        // Update state with route arguments
        setState(() {
          // Store the route arguments in a class variable so we can use them
          _patientDataFromArgs = routeArgs;
          // Smart photo cache update instead of clearing
          _updatePhotoCache();
        });
      }
    });
    
    // Test the getters immediately (once only)
    print('Enhanced Dashboard - Computed UHID: $patientUhid');
    print('Enhanced Dashboard - Computed Name: $patientName');
    print('Enhanced Dashboard - Computed Blood Group: $patientBloodGroup');
    print('Enhanced Dashboard - Computed Age: $patientAge');
    // Get photo status without excessive logging
    final photoStatus = patientPhoto != null ? 'Available' : 'Not Available';
    print('Enhanced Dashboard - Photo Status: $photoStatus');
    print('=== END DASHBOARD DEBUG ===');
    
    // Load real patient data
    _loadPatientData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _sosController.dispose();
    _sosRippleController.dispose();
    _cardHoverController.dispose();
    _healthStatsController.dispose();
    _quickActionsController.dispose();
    super.dispose();
  }

  String _calculateAge(dynamic dateOfBirth) {
    print('_calculateAge called with: $dateOfBirth');
    if (dateOfBirth == null) {
      print('Date of birth is null');
      return 'Unknown';
    }
    
    // Convert to string if it's not already
    String dobString = dateOfBirth is String ? dateOfBirth : dateOfBirth.toString();
    
    if (dobString.isEmpty) {
      print('Date of birth is empty');
      return 'Unknown';
    }
    
    try {
      // Handle different date formats
      DateTime dob;
      
      // Handle ISO format (YYYY-MM-DD)
      if (dobString.contains('-')) {
        try {
          dob = DateTime.parse(dobString);
        } catch (e) {
          // Try alternate format if standard parse fails
          List<String> parts = dobString.split('-');
          if (parts.length == 3) {
            // Try different arrangements (YYYY-MM-DD, DD-MM-YYYY, etc.)
            try {
              dob = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
            } catch (e2) {
              try {
                dob = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
              } catch (e3) {
                throw FormatException('Could not parse date with dashes: $dobString');
              }
            }
          } else {
            throw FormatException('Invalid date format with dashes: $dobString');
          }
        }
      } 
      // Handle slash format (MM/DD/YYYY or DD/MM/YYYY)
      else if (dobString.contains('/')) {
        List<String> parts = dobString.split('/');
        if (parts.length == 3) {
          try {
            // Try MM/DD/YYYY first
            dob = DateTime(int.parse(parts[2]), int.parse(parts[0]), int.parse(parts[1]));
          } catch (e) {
            try {
              // Try DD/MM/YYYY next
              dob = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
            } catch (e2) {
              throw FormatException('Could not parse date with slashes: $dobString');
            }
          }
        } else {
          throw FormatException('Invalid date format with slashes: $dobString');
        }
      } 
      // Try timestamp (milliseconds since epoch)
      else if (dobString.length >= 10 && dobString.length <= 13 && int.tryParse(dobString) != null) {
        int timestamp = int.parse(dobString);
        // If it's in seconds (10 digits), convert to milliseconds
        if (dobString.length == 10) {
          timestamp *= 1000;
        }
        dob = DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      // Standard ISO format as fallback
      else {
        dob = DateTime.parse(dobString);
      }
      
      // Calculate age
      DateTime now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      
      // Validate reasonable age
      if (age < 0 || age > 120) {
        print('Calculated unlikely age: $age from DOB: $dobString - might be incorrect format');
        return 'Unknown';
      }
      
      print('Calculated age: $age from DOB: $dobString');
      return age.toString();
    } catch (e) {
      print('Error calculating age: $e');
      return 'Unknown';
    }
  }

  Future<void> _loadPatientData() async {
    try {
      setState(() => isLoading = true);
      
      // Check if we need to fetch complete patient data
      bool needsPatientProfile = (patientUhid == 'Not Available' || 
                                 patientBloodGroup == 'Not Available' || 
                                 patientAge == 'Unknown');
      
      print('=== DASHBOARD PATIENT DATA DEBUG ===');
      print('Loading patient data - needs profile: $needsPatientProfile');
      print('Current UHID: $patientUhid');
      print('Current Blood Group: $patientBloodGroup');
      print('Current Age: $patientAge');
      print('Combined patient data: $combinedPatientData');
      print('Widget patient data: ${widget.patientData}');
      print('======================================');
      
      // Try to fetch complete patient profile data if needed
      if (needsPatientProfile) {
        final patientId = combinedPatientData?['id'] ?? widget.patientData?['id'];
        print('Patient data is incomplete, trying to fetch complete profile...');
        print('Patient ID for fetch: $patientId');
        
        if (patientId != null) {
          await _fetchCompletePatientProfile(patientId);
          
          // Re-check after fetching
          print('After fetching - UHID: $patientUhid');
          print('After fetching - Blood Group: $patientBloodGroup');
          print('After fetching - Age: $patientAge');
        } else {
          print('No patient ID available for fetching complete profile');
        }
      }
      
      // Only proceed with API calls if we have a valid UHID
      if (patientUhid != 'Not Available') {
        print('Loading additional patient data for UHID: $patientUhid');
        print('API Base URL: ${AppConstants.baseUrl}');
        
        // Load medical records
        final recordsResponse = await http.get(
          Uri.parse('${AppConstants.baseUrl}/medical-records/$patientUhid'),
          headers: {'Content-Type': 'application/json'},
        );

        // Load appointments
        final appointmentsResponse = await http.get(
          Uri.parse('${AppConstants.baseUrl}/appointments/patient/$patientUhid'),
          headers: {'Content-Type': 'application/json'},
        );

        // Load health data
        final healthResponse = await http.get(
          Uri.parse('${AppConstants.baseUrl}/patients/$patientUhid/health-data'),
          headers: {'Content-Type': 'application/json'},
        );

        // Load health tips (personalized or general)
        final tipsResponse = await http.get(
          Uri.parse('${AppConstants.baseUrl}/health-tips/$patientUhid'),
          headers: {'Content-Type': 'application/json'},
        );

        print('API Response Codes:');
        print('Medical Records: ${recordsResponse.statusCode}');
        print('Appointments: ${appointmentsResponse.statusCode}');
        print('Health Data: ${healthResponse.statusCode}');
        print('Health Tips: ${tipsResponse.statusCode}');

        if (recordsResponse.statusCode == 200) {
          medicalRecords = json.decode(recordsResponse.body);
          print('Loaded ${medicalRecords.length} medical records');
        }

        if (appointmentsResponse.statusCode == 200) {
          appointments = json.decode(appointmentsResponse.body);
          print('Loaded ${appointments.length} appointments');
        }

        if (healthResponse.statusCode == 200) {
          healthData = json.decode(healthResponse.body);
          print('Loaded health data: ${healthData?.keys}');
        }

        if (tipsResponse.statusCode == 200) {
          final tipsData = json.decode(tipsResponse.body);
          if (tipsData is List) {
            healthTips = List<String>.from(tipsData);
          } else if (tipsData is Map && tipsData.containsKey('tips')) {
            healthTips = List<String>.from(tipsData['tips']);
          }
          print('Loaded ${healthTips.length} health tips');
        } else {
          // Fallback to default health tips if API fails
          healthTips = [
            'Drink at least 8 glasses of water daily',
            'Exercise for 30 minutes daily',
            'Get 7-8 hours of sleep',
            'Eat balanced meals with vegetables',
            'Take regular health checkups'
          ];
          print('Using default health tips (${healthTips.length} tips)');
        }
      } else {
        print('Skipping API calls - no valid UHID available');
        // Set default health tips when no UHID
        healthTips = [
          'Drink at least 8 glasses of water daily',
          'Exercise for 30 minutes daily',
          'Get 7-8 hours of sleep',
          'Eat balanced meals with vegetables',
          'Take regular health checkups'
        ];
      }

      setState(() {
        isLoading = false;
        error = null;
      });
      
      // Start animations after data is loaded
      _fadeController.forward();
      _slideController.forward();
      _sosController.repeat(reverse: true);
      _sosRippleController.repeat();
      
      // Delayed animations for sections
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _healthStatsController.forward();
      });
      
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _quickActionsController.forward();
      });
      
    } catch (e) {
      setState(() {
        error = 'Failed to load patient data: $e';
        isLoading = false;
      });
    }
  }

  // Fetch complete patient profile data when missing from login
  Future<void> _fetchCompletePatientProfile(String patientId) async {
    try {
      print('Fetching complete patient profile for ID: $patientId');
      
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/roles/patients/$patientId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Patient profile API Response Code: ${response.statusCode}');
      print('Patient profile API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['patient'] != null) {
          final fetchedPatientData = responseData['patient'];
          print('Successfully fetched complete patient profile: $fetchedPatientData');
          
          setState(() {
            // Update the patient data from arguments with the complete profile
            _patientDataFromArgs = {..._patientDataFromArgs ?? {}, ...fetchedPatientData};
            // Smart photo cache update instead of clearing
            _updatePhotoCache();
          });
          
          // Force refresh photo after state update
          Future.delayed(Duration(milliseconds: 100), () {
            if (mounted) {
              _refreshPhoto();
            }
          });
          
          print('Updated patient data - UHID: ${_patientDataFromArgs?['uhid']}');
          print('Updated patient data - Blood Group: ${_patientDataFromArgs?['bloodGroup']}');
          print('Updated patient data - DOB: ${_patientDataFromArgs?['dateOfBirth']}');
          print('Updated patient data - Photo: ${_patientDataFromArgs?['photo'] != null ? 'Photo available (${_patientDataFromArgs!['photo'].toString().length} chars)' : 'No photo'}');
        }
      } else {
        print('Failed to fetch patient profile - API returned ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching complete patient profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.white,
              Colors.teal.shade50,
              Colors.purple.shade50,
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: isLoading 
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading your health dashboard...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load dashboard',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadPatientData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              // Debug: Print animation value to check for invalid values
              final fadeValue = _fadeAnimation.value.clamp(0.0, 1.0);
              if (_fadeAnimation.value < 0.0 || _fadeAnimation.value > 1.0) {
                print('Invalid fade animation value: ${_fadeAnimation.value}, clamped to: $fadeValue');
              }
              
              return Opacity(
                opacity: fadeValue,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Enhanced Modern App Bar with improved glassmorphism
                      _buildEnhancedModernAppBar(),
                      
                      // Dashboard Content with better spacing
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Enhanced Emergency SOS Section
                              _buildEnhancedEmergencySection(),
                              
                              const SizedBox(height: 25),
                              
                              // Enhanced Health Stats Cards with animations
                              _buildEnhancedHealthStatsSection(),
                              
                              const SizedBox(height: 25),
                              
                              // Enhanced Wearables Section
                              _buildEnhancedWearablesSection(),
                              
                              const SizedBox(height: 25),
                              
                              // Enhanced Quick Actions with better interactions
                              _buildEnhancedQuickActionsSection(),
                              
                              const SizedBox(height: 25),
                              
                              // Enhanced Recent Activity with modern cards
                              _buildEnhancedRecentActivitySection(),
                              
                              const SizedBox(height: 25),
                              
                              // Enhanced Health Insights with interactive elements
                              _buildEnhancedHealthInsightsSection(),
                              
                              const SizedBox(height: 100), // Extra space for floating button
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: _buildEnhancedFloatingSOSButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEnhancedModernAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade800,
                Colors.blue.shade700,
                Colors.indigo.shade600,
                Colors.purple.shade500,
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(35),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade800.withOpacity(0.9),
                      Colors.blue.shade700.withOpacity(0.8),
                      Colors.indigo.shade600.withOpacity(0.9),
                      Colors.purple.shade500.withOpacity(0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            // Enhanced Animated Profile Avatar
                            AnimatedBuilder(
                              animation: _sosScaleAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _sosScaleAnimation.value * 0.1 + 0.9,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white,
                                          Colors.blue.shade50,
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 15,
                                          spreadRadius: 3,
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      key: ValueKey(patientPhoto?.hashCode ?? 'no_photo'),
                                      radius: 35,
                                      backgroundColor: Colors.blue.shade100,
                                      backgroundImage: _getPatientPhotoImageProvider(),
                                      child: patientPhoto == null 
                                        ? Icon(
                                            Icons.person,
                                            size: 40,
                                            color: Colors.blue.shade700,
                                          )
                                        : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back,',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    patientName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: patientUhid != 'Not Available'
                                          ? [
                                              Colors.green.withOpacity(0.3),
                                              Colors.green.withOpacity(0.2),
                                            ]
                                          : [
                                              Colors.orange.withOpacity(0.3),
                                              Colors.orange.withOpacity(0.2),
                                            ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: patientUhid != 'Not Available'
                                          ? Colors.green.withOpacity(0.5)
                                          : Colors.orange.withOpacity(0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          patientUhid != 'Not Available' 
                                            ? Icons.verified_user 
                                            : Icons.warning,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            'UHID: $patientUhid',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Enhanced logout button with glow effect
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.2),
                                    Colors.white.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _showLogoutDialog,
                                  borderRadius: BorderRadius.circular(15),
                                  child: const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Icon(
                                      Icons.logout,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Enhanced health status indicator with pulse animation
                        AnimatedBuilder(
                          animation: _sosRippleAnimation,
                          builder: (context, child) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green.withOpacity((0.3 + _sosRippleAnimation.value * 0.1).clamp(0.0, 1.0)),
                                    Colors.green.withOpacity((0.2 + _sosRippleAnimation.value * 0.05).clamp(0.0, 1.0)),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.4),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.health_and_safety,
                                    color: Colors.green.shade100,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Health Status: ${patientHealthStatus}',
                                    style: TextStyle(
                                      color: Colors.green.shade100,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedEmergencySection() {
    return MouseRegion(
      onEnter: (_) => setState(() => _emergencyCardHovered = true),
      onExit: (_) => setState(() => _emergencyCardHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_emergencyCardHovered ? 1.02 : 1.0),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red.shade50,
              Colors.orange.shade50,
              Colors.pink.shade50,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.red.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(_emergencyCardHovered ? 0.2 : 0.1),
              blurRadius: _emergencyCardHovered ? 15 : 10,
              spreadRadius: _emergencyCardHovered ? 3 : 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.shade600, Colors.red.shade700],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.emergency, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'Emergency Services',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Show emergency contact summary if available
            if ((widget.patientData?['emergencyContact'] != null) ||
                (widget.patientData?['emergencyContacts'] != null && 
                 (widget.patientData!['emergencyContacts'] as List).isNotEmpty)) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Contacts:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Show single emergency contact from registration
                    if (widget.patientData?['emergencyContact'] != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          '• ${widget.patientData!['emergencyContact']['name']} (${widget.patientData!['emergencyContact']['relationship']}) - ${widget.patientData!['emergencyContact']['phone']}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                    // Show multiple emergency contacts array
                    if (widget.patientData?['emergencyContacts'] != null && 
                        (widget.patientData!['emergencyContacts'] as List).isNotEmpty) ...[
                      ...(widget.patientData!['emergencyContacts'] as List).take(2).map((contact) => 
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '• ${contact['name']} (${contact['relationship']}) - ${contact['phone']}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ).toList(),
                    ],
                    // Calculate total contacts for "more..." text
                    if (_getTotalEmergencyContactsCount() > 2)
                      Text(
                        '+${_getTotalEmergencyContactsCount() - 2} more...',
                        style: TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          color: Colors.red.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              'Quick access to emergency services and your emergency contacts.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _showEmergencyContacts,
                      icon: const Icon(Icons.contacts_outlined, size: 16),
                      label: const Text(
                        'Emergency Contacts',
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: OutlinedButton.icon(
                      onPressed: _callAmbulance,
                      icon: const Icon(Icons.local_hospital, size: 16),
                      label: const Text(
                        'Call Ambulance',
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade600,
                        side: BorderSide(color: Colors.red.shade600, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
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

  Widget _buildEnhancedFloatingSOSButton() {
    return AnimatedBuilder(
      animation: Listenable.merge([_sosScaleAnimation, _sosRippleAnimation]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Enhanced outer ripple effect with multiple rings
            for (int i = 0; i < 3; i++)
              Container(
                width: 80 + (_sosRippleAnimation.value * 40) + (i * 15),
                height: 80 + (_sosRippleAnimation.value * 40) + (i * 15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.red.withOpacity(
                      ((0.3 * (1 - _sosRippleAnimation.value)) / (i + 1)).clamp(0.0, 1.0),
                    ),
                    width: 2,
                  ),
                ),
              ),
            // Main enhanced SOS button
            Transform.scale(
              scale: _sosScaleAnimation.value,
              child: Container(
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.red.shade300,
                      Colors.red.shade600,
                      Colors.red.shade800,
                      Colors.red.shade900,
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5 + (_sosScaleAnimation.value - 1.0) * 3),
                      blurRadius: 20 + (_sosScaleAnimation.value - 1.0) * 40,
                      spreadRadius: 5 + (_sosScaleAnimation.value - 1.0) * 15,
                    ),
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(42.5),
                    onTap: _handleSOSPress,
                    onLongPress: _handleSOSLongPress,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sos,
                              color: Colors.white,
                              size: 30 + (_sosScaleAnimation.value - 1.0) * 10,
                            ),
                            Text(
                              'SOS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11 + (_sosScaleAnimation.value - 1.0) * 3,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEnhancedHealthStatsSection() {
    return AnimatedBuilder(
      animation: _healthStatsAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _healthStatsAnimation.value)),
          child: Opacity(
            opacity: _healthStatsAnimation.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health Overview',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                // Data source indicator
                Container(
                  margin: const EdgeInsets.only(top: 4, bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLoading 
                      ? Colors.orange.shade100 
                      : (healthData != null 
                          ? Colors.green.shade100 
                          : Colors.blue.shade100),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isLoading 
                        ? Colors.orange.shade300 
                        : (healthData != null 
                            ? Colors.green.shade300 
                            : Colors.blue.shade300),
                    ),
                  ),
                  child: Text(
                    isLoading 
                      ? 'Loading data...' 
                      : (healthData != null 
                          ? 'API Data + Patient Data' 
                          : 'Patient Data Only'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isLoading 
                        ? Colors.orange.shade700 
                        : (healthData != null 
                            ? Colors.green.shade700 
                            : Colors.blue.shade700),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildEnhancedStatCard(
                        icon: Icons.bloodtype,
                        title: 'Blood Type',
                        value: patientBloodGroup,
                        color: Colors.red.shade600,
                        index: 0,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildEnhancedStatCard(
                        icon: Icons.cake,
                        title: 'Age',
                        value: '$patientAge years',
                        color: Colors.orange.shade600,
                        index: 1,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildEnhancedStatCard(
                        icon: Icons.health_and_safety,
                        title: 'Status',
                        value: patientHealthStatus,
                        color: Colors.green.shade600,
                        index: 2,
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

  Widget _buildEnhancedStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required int index,
  }) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredStatCards.add(index)),
      onExit: (_) => setState(() => _hoveredStatCards.remove(index)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..scale(_hoveredStatCards.contains(index) ? 1.05 : 1.0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(_hoveredStatCards.contains(index) ? 0.2 : 0.1),
              spreadRadius: _hoveredStatCards.contains(index) ? 2 : 1,
              blurRadius: _hoveredStatCards.contains(index) ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.1), color.withOpacity(0.2)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedWearablesSection() {
    return MouseRegion(
      onEnter: (_) => setState(() => _wearablesCardHovered = true),
      onExit: (_) => setState(() => _wearablesCardHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_wearablesCardHovered ? 1.01 : 1.0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(_wearablesCardHovered ? 0.15 : 0.1),
              blurRadius: _wearablesCardHovered ? 15 : 10,
              spreadRadius: _wearablesCardHovered ? 3 : 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.watch, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Wearable Devices',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WearablesScreen(patientId: patientUhid),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text('View All', style: TextStyle(fontSize: 12, color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Monitor your health with connected devices',
              style: TextStyle(color: Colors.blue.shade700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.bluetooth_searching, size: 14),
                    label: const Text(
                      'Connect Device', 
                      style: TextStyle(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade600,
                      side: BorderSide(color: Colors.blue.shade600),
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.analytics, size: 14),
                    label: const Text(
                      'View Analytics', 
                      style: TextStyle(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade600,
                      side: BorderSide(color: Colors.blue.shade600),
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
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

  Widget _buildEnhancedQuickActionsSection() {
    return SlideTransition(
      position: _quickActionsAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 15),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              _buildEnhancedActionCard(
                icon: Icons.health_and_safety,
                title: 'Digital Card',
                subtitle: 'View health card',
                color: Colors.blue.shade600,
                index: 0,
                onTap: () {
                  // Check if we have a valid UHID (not the fallback)
                  if (patientUhid != 'Not Available') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DigitalHealthCardScreen(uhid: patientUhid),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please register first to get your digital health card')),
                    );
                  }
                },
              ),
              _buildEnhancedActionCard(
                icon: Icons.medical_information,
                title: 'Health Records',
                subtitle: 'View medical history',
                color: Colors.green.shade600,
                index: 1,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Health Records feature coming soon')),
                  );
                },
              ),
              _buildEnhancedActionCard(
                icon: Icons.calendar_today,
                title: 'Appointments',
                subtitle: 'Book & manage',
                color: Colors.orange.shade600,
                index: 2,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Appointments feature coming soon')),
                  );
                },
              ),
              _buildEnhancedActionCard(
                icon: Icons.medication,
                title: 'Medications',
                subtitle: 'Track medicines',
                color: Colors.purple.shade600,
                index: 3,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Medications feature coming soon')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required int index,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredActionCards.add(index)),
      onExit: (_) => setState(() => _hoveredActionCards.remove(index)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..scale(_hoveredActionCards.contains(index) ? 1.02 : 1.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(_hoveredActionCards.contains(index) ? 0.15 : 0.1),
              blurRadius: _hoveredActionCards.contains(index) ? 12 : 8,
              spreadRadius: _hoveredActionCards.contains(index) ? 2 : 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 32, color: color),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildActivityItem(
                icon: Icons.person_add,
                title: 'Account Created',
                subtitle: 'Welcome to DHRMS',
                time: 'Today',
                color: Colors.green.shade600,
              ),
              // Show digital health card info only if UHID is available
              if (patientUhid != 'Not Available') ...[
                const Divider(height: 20),
                _buildActivityItem(
                  icon: Icons.card_membership,
                  title: 'Digital Health Card Generated',
                  subtitle: 'UHID: $patientUhid',
                  time: 'Today',
                  color: Colors.blue.shade600,
                ),
              ],
              const Divider(height: 20),
              _buildActivityItem(
                icon: Icons.security,
                title: 'Profile Secured',
                subtitle: 'Your data is protected',
                time: 'Today',
                color: Colors.orange.shade600,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedHealthInsightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Insights',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade50, Colors.blue.shade50],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.teal.shade200),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade600,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.tips_and_updates, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Health Tips',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (healthTips.isNotEmpty) ...[
                ...healthTips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    '• $tip',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.teal.shade700,
                      height: 1.5,
                    ),
                  ),
                )).toList(),
              ] else ...[
                Text(
                  'No health tips available at the moment.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.teal.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // Emergency SOS Methods
  void _handleSOSPress() {
    HapticFeedback.mediumImpact();
    
    // Add a visual feedback by briefly changing the animation
    _sosController.stop();
    _sosRippleController.stop();
    _sosController.forward().then((_) {
      _sosController.repeat(reverse: true);
      _sosRippleController.repeat();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 8),
            Text('Hold SOS button for emergency'),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleSOSLongPress() {
    HapticFeedback.heavyImpact();
    
    // Stop the animation during navigation
    _sosController.stop();
    _sosRippleController.stop();
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdvancedSOSScreen()),
    ).then((_) {
      // Restart animation when returning
      if (mounted) {
        _sosController.repeat(reverse: true);
        _sosRippleController.repeat();
      }
    });
  }

  void _showEmergencyContacts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EmergencyContactsScreen(patientData: combinedPatientData)),
    );
  }

  int _getTotalEmergencyContactsCount() {
    int count = 0;
    if (widget.patientData?['emergencyContact'] != null) {
      count++;
    }
    if (widget.patientData?['emergencyContacts'] != null) {
      count += (widget.patientData!['emergencyContacts'] as List).length;
    }
    return count;
  }

  void _makeEmergencyCall(String number) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling $number...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _callAmbulance() {
    _makeEmergencyCall('108');
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            CustomButton(
              text: 'Logout',
              backgroundColor: AppConstants.errorRed,
              onPressed: () {
                // Clear photo cache on logout
                _clearPhotoCache();
                print('Photo cache cleared on logout');
                
                Navigator.pop(context); // Close dialog
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
