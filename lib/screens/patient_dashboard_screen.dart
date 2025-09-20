import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import '../utils/app_constants.dart';
import '../widgets/custom_button.dart';
import 'digital_health_card_screen.dart';
import 'wearables_screen_simple.dart';
import 'advanced_sos_screen.dart';
import 'settings_screen.dart';
import 'dart:ui';

class PatientDashboardScreen extends StatefulWidget {
  final String? uhid;
  final Map<String, dynamic>? patientData;

  const PatientDashboardScreen({super.key, this.uhid, this.patientData});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen>
    with TickerProviderStateMixin {
  // Store patient data from navigation arguments
  Map<String, dynamic>? _patientDataFromArgs;
  late AnimationController _sosController;
  late Animation<double> _sosScaleAnimation;
  late AnimationController _sosRippleController;
  late Animation<double> _sosRippleAnimation;

  // New animation controllers for enhanced interactivity
  late AnimationController _cardHoverController;
  late AnimationController _healthStatsController;
  late Animation<double> _healthStatsAnimation;
  late AnimationController _quickActionsController;

  // Track hover states for interactive cards
  bool _wearablesCardHovered = false;
  final Set<int> _hoveredStatCards = {};

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

  // Tab navigation state
  int _currentTabIndex = 0;
  final PageController _pageController = PageController();

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
    final uhid =
        widget.uhid ??
        combinedPatientData?['uhid'] ??
        combinedPatientData?['patientId'] ??
        combinedPatientData?['patient_id'] ??
        combinedPatientData?['unique_id'] ??
        combinedPatientData?['healthId'] ??
        combinedPatientData?['health_id'] ??
        combinedPatientData?['UHID']; // Try uppercase version

    print('UHID lookup - widget.uhid: ${widget.uhid}');
    print('UHID lookup - widget.patientData: ${widget.patientData}');
    print('Found UHID: $uhid');

    // Return the actual UHID or a fallback only if none found
    return uhid?.toString() ?? 'Not Available';
  }

  String get patientBloodGroup {
    // Try all possible blood group field names with various formats
    final bloodGroup =
        combinedPatientData?['bloodGroup'] ??
        combinedPatientData?['blood_group'] ??
        combinedPatientData?['bloodType'] ??
        combinedPatientData?['blood_type'] ??
        healthData?['bloodGroup'] ??
        healthData?['blood_group'] ??
        healthData?['bloodType'] ??
        healthData?['blood_type'] ??
        // Try nested patient fields that might contain blood group
        (combinedPatientData?['patient'] is Map
            ? (combinedPatientData?['patient']['bloodGroup'] ??
                  combinedPatientData?['patient']['blood_group'] ??
                  combinedPatientData?['patient']['bloodType'])
            : null) ??
        // Try nested user fields that might contain blood group
        (combinedPatientData?['user'] is Map
            ? (combinedPatientData?['user']['bloodGroup'] ??
                  combinedPatientData?['user']['blood_group'] ??
                  combinedPatientData?['user']['bloodType'])
            : null);

    print('Blood group lookup - widget.patientData: ${widget.patientData}');
    print('Blood group lookup - _patientDataFromArgs: $_patientDataFromArgs');
    print('Blood group lookup - healthData: $healthData');
    print('Found blood group: $bloodGroup');

    // Format the blood group properly if it exists
    if (bloodGroup != null) {
      String formattedBloodGroup = bloodGroup.toString().trim().toUpperCase();

      // Normalize common blood group formats
      if (formattedBloodGroup.contains('+')) {
        // Already has a plus sign
      } else if (formattedBloodGroup.contains('POSITIVE') ||
          formattedBloodGroup.endsWith('POS')) {
        formattedBloodGroup = formattedBloodGroup
            .replaceAll('POSITIVE', '+')
            .replaceAll('POS', '+');
      }

      if (formattedBloodGroup.contains('-')) {
        // Already has a minus sign
      } else if (formattedBloodGroup.contains('NEGATIVE') ||
          formattedBloodGroup.endsWith('NEG')) {
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
    final dob =
        combinedPatientData?['dateOfBirth'] ??
        combinedPatientData?['date_of_birth'] ??
        combinedPatientData?['dob'] ??
        combinedPatientData?['DOB'] ??
        healthData?['dateOfBirth'] ??
        healthData?['date_of_birth'] ??
        healthData?['dob'] ??
        healthData?['DOB'] ??
        // Try nested patient fields that might contain DOB
        (combinedPatientData?['patient'] is Map
            ? (combinedPatientData?['patient']['dateOfBirth'] ??
                  combinedPatientData?['patient']['dob'] ??
                  combinedPatientData?['patient']['DOB'])
            : null) ??
        // Try nested user fields that might contain DOB
        (combinedPatientData?['user'] is Map
            ? (combinedPatientData?['user']['dateOfBirth'] ??
                  combinedPatientData?['user']['dob'] ??
                  combinedPatientData?['user']['DOB'])
            : null);

    print('DOB lookup - widget.patientData: ${widget.patientData}');
    print('DOB lookup - _patientDataFromArgs: $_patientDataFromArgs');
    print('DOB lookup - healthData: $healthData');
    print('Found DOB: $dob');

    return _calculateAge(dob);
  }

  String get patientHealthStatus =>
      healthData?['healthStatus'] ??
      combinedPatientData?['healthStatus'] ??
      'Unknown';

  // Get patient photo from various possible field names
  String? get patientPhoto {
    // Return cached value immediately if already computed
    if (_photoCache) {
      return _cachedPatientPhoto;
    }

    // Only perform lookup once
    print('Performing photo lookup (first time only)...');

    // Try all possible photo field names and formats
    final photo =
        combinedPatientData?['photo'] ??
        combinedPatientData?['profilePicture'] ??
        combinedPatientData?['profileImage'] ??
        combinedPatientData?['profile_picture'] ??
        combinedPatientData?['profile_image'] ??
        combinedPatientData?['avatar'] ??
        healthData?['photo'] ??
        healthData?['profilePicture'] ??
        healthData?['profileImage'] ??
        // Try nested patient fields that might contain photo
        (combinedPatientData?['patient'] is Map
            ? (combinedPatientData?['patient']['photo'] ??
                  combinedPatientData?['patient']['profilePicture'] ??
                  combinedPatientData?['patient']['profileImage'])
            : null) ??
        // Try nested user fields that might contain photo
        (combinedPatientData?['user'] is Map
            ? (combinedPatientData?['user']['photo'] ??
                  combinedPatientData?['user']['profilePicture'] ??
                  combinedPatientData?['user']['profileImage'])
            : null);

    // Cache the result immediately to prevent re-execution
    if (photo != null && photo.toString().trim().isNotEmpty) {
      _cachedPatientPhoto = photo.toString();
      print(
        'Photo found and cached (${_cachedPatientPhoto!.length} chars) - will persist until logout',
      );
    } else {
      _cachedPatientPhoto = null;
      print('No photo found - cached null result');
    }
    _photoCache = true;

    return _cachedPatientPhoto;
  }

  // Get actual health metrics from database
  int get totalMedicalRecords => medicalRecords.length;
  int get upcomingAppointments => appointments
      .where(
        (apt) => apt['status'] == 'scheduled' || apt['status'] == 'confirmed',
      )
      .length;
  int get activeConditions =>
      (combinedPatientData?['medicalHistory'] as List?)?.length ??
      (healthData?['conditions'] as List?)?.length ??
      0;

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
      print(
        'Photo decoded and cached (${bytes.length} bytes) - no more decoding needed',
      );

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
    final newPhoto =
        combinedPatientData?['photo'] ??
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
    print(
      'Enhanced Dashboard - Patient Data Keys: ${widget.patientData?.keys}',
    );

    // Initialize all animations immediately to prevent null errors
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
    _sosScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _sosController, curve: Curves.easeInOut));

    _sosRippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sosRippleController, curve: Curves.easeOut),
    );

    // Initialize new animations
    _healthStatsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _healthStatsController, curve: Curves.elasticOut),
    );

    // Start animations with staggered delays for better effect
    _sosController.repeat(reverse: true);
    _sosRippleController.repeat();
    _healthStatsController.forward();
    _quickActionsController.forward();

    // Retrieve route arguments if available
    Future.delayed(Duration.zero, () {
      final routeArgs =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
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
    _sosController.dispose();
    _sosRippleController.dispose();
    _cardHoverController.dispose();
    _healthStatsController.dispose();
    _quickActionsController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  String _calculateAge(dynamic dateOfBirth) {
    print('_calculateAge called with: $dateOfBirth');
    if (dateOfBirth == null) {
      print('Date of birth is null');
      return 'Unknown';
    }

    // Convert to string if it's not already
    String dobString = dateOfBirth is String
        ? dateOfBirth
        : dateOfBirth.toString();

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
              dob = DateTime(
                int.parse(parts[0]),
                int.parse(parts[1]),
                int.parse(parts[2]),
              );
            } catch (e2) {
              try {
                dob = DateTime(
                  int.parse(parts[2]),
                  int.parse(parts[1]),
                  int.parse(parts[0]),
                );
              } catch (e3) {
                throw FormatException(
                  'Could not parse date with dashes: $dobString',
                );
              }
            }
          } else {
            throw FormatException(
              'Invalid date format with dashes: $dobString',
            );
          }
        }
      }
      // Handle slash format (MM/DD/YYYY or DD/MM/YYYY)
      else if (dobString.contains('/')) {
        List<String> parts = dobString.split('/');
        if (parts.length == 3) {
          try {
            // Try MM/DD/YYYY first
            dob = DateTime(
              int.parse(parts[2]),
              int.parse(parts[0]),
              int.parse(parts[1]),
            );
          } catch (e) {
            try {
              // Try DD/MM/YYYY next
              dob = DateTime(
                int.parse(parts[2]),
                int.parse(parts[1]),
                int.parse(parts[0]),
              );
            } catch (e2) {
              throw FormatException(
                'Could not parse date with slashes: $dobString',
              );
            }
          }
        } else {
          throw FormatException('Invalid date format with slashes: $dobString');
        }
      }
      // Try timestamp (milliseconds since epoch)
      else if (dobString.length >= 10 &&
          dobString.length <= 13 &&
          int.tryParse(dobString) != null) {
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
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }

      // Validate reasonable age
      if (age < 0 || age > 120) {
        print(
          'Calculated unlikely age: $age from DOB: $dobString - might be incorrect format',
        );
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
      bool needsPatientProfile =
          (patientUhid == 'Not Available' ||
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
        final patientId =
            combinedPatientData?['id'] ?? widget.patientData?['id'];
        print(
          'Patient data is incomplete, trying to fetch complete profile...',
        );
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
          Uri.parse(
            '${AppConstants.baseUrl}/appointments/patient/$patientUhid',
          ),
          headers: {'Content-Type': 'application/json'},
        );

        // Load health data
        final healthResponse = await http.get(
          Uri.parse(
            '${AppConstants.baseUrl}/patients/$patientUhid/health-data',
          ),
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
            'Take regular health checkups',
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
          'Take regular health checkups',
        ];
      }

      setState(() {
        isLoading = false;
        error = null;
      });

      // Start animations after data is loaded
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
        if (responseData['success'] == true &&
            responseData['patient'] != null) {
          final fetchedPatientData = responseData['patient'];
          print(
            'Successfully fetched complete patient profile: $fetchedPatientData',
          );

          setState(() {
            // Update the patient data from arguments with the complete profile
            _patientDataFromArgs = {
              ..._patientDataFromArgs ?? {},
              ...fetchedPatientData,
            };
            // Smart photo cache update instead of clearing
            _updatePhotoCache();
          });

          // Force refresh photo after state update
          Future.delayed(Duration(milliseconds: 100), () {
            if (mounted) {
              _refreshPhoto();
            }
          });

          print(
            'Updated patient data - UHID: ${_patientDataFromArgs?['uhid']}',
          );
          print(
            'Updated patient data - Blood Group: ${_patientDataFromArgs?['bloodGroup']}',
          );
          print(
            'Updated patient data - DOB: ${_patientDataFromArgs?['dateOfBirth']}',
          );
          print(
            'Updated patient data - Photo: ${_patientDataFromArgs?['photo'] != null ? 'Photo available (${_patientDataFromArgs!['photo'].toString().length} chars)' : 'No photo'}',
          );
        }
      } else {
        print(
          'Failed to fetch patient profile - API returned ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching complete patient profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Fixed top branding bar
          _buildTopBrandingBar(),

          // Tab content
          Expanded(
            child: isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.teal,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading your health dashboard...',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
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
                : PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentTabIndex = index;
                      });
                    },
                    children: [
                      _buildHomeTab(),
                      _buildProfileTab(),
                      _buildHealthTab(),
                      _buildServicesTab(),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _currentTabIndex == 0 || _currentTabIndex == 3
          ? _buildEnhancedFloatingSOSButton()
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildTopBrandingBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade600],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'MyHealth',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _showLogoutDialog,
                icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                tooltip: 'Logout',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentTabIndex,
      onTap: (index) {
        setState(() {
          _currentTabIndex = index;
        });
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue.shade700,
      unselectedItemColor: Colors.grey.shade500,
      selectedFontSize: 12,
      unselectedFontSize: 10,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(
          icon: Icon(Icons.health_and_safety),
          label: 'Health',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.medical_services),
          label: 'Services',
        ),
      ],
    );
  }

  // Home Tab - Welcome message, profile, and quick actions
  Widget _buildHomeTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade50, Colors.white, Colors.teal.shade50],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section with Profile
            _buildWelcomeSection(),

            const SizedBox(height: 30),

            // Quick Actions Grid
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
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
              children: [
                _buildQuickActionButton(
                  icon: Icons.sos,
                  title: 'Emergency SOS',
                  color: Colors.red.shade600,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdvancedSOSScreen(),
                    ),
                  ),
                ),
                _buildQuickActionButton(
                  icon: Icons.local_hospital,
                  title: 'Nearby Hospitals',
                  color: Colors.blue.shade600,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nearby Hospitals feature coming soon'),
                      ),
                    );
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.warning,
                  title: 'Health Alerts',
                  color: Colors.orange.shade600,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Health Alerts feature coming soon'),
                      ),
                    );
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.qr_code_scanner,
                  title: 'QR Scanner',
                  color: Colors.green.shade600,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('QR Scanner feature coming soon'),
                      ),
                    );
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.card_membership,
                  title: 'Digital Card',
                  color: Colors.purple.shade600,
                  onTap: () {
                    if (patientUhid != 'Not Available') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DigitalHealthCardScreen(uhid: patientUhid),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please register first to get your digital health card',
                          ),
                        ),
                      );
                    }
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.medication,
                  title: 'Medications',
                  color: Colors.teal.shade600,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Medications feature coming soon'),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 100), // Space for floating button
          ],
        ),
      ),
    );
  }

  // Profile Tab - User information display
  Widget _buildProfileTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.purple.shade50, Colors.white]),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade600, Colors.purple.shade700],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.purple.shade100,
                      backgroundImage: _getPatientPhotoImageProvider(),
                      child: patientPhoto == null
                          ? Icon(
                              Icons.person,
                              size: 45,
                              color: Colors.purple.shade700,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patientName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            'UHID: $patientUhid',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Profile Information
            Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 15),

            _buildProfileInfoCard(
              'Blood Group',
              patientBloodGroup,
              Icons.bloodtype,
              Colors.red.shade600,
            ),
            _buildProfileInfoCard(
              'Age',
              '$patientAge years',
              Icons.cake,
              Colors.orange.shade600,
            ),
            _buildProfileInfoCard(
              'Health Status',
              patientHealthStatus,
              Icons.health_and_safety,
              Colors.green.shade600,
            ),

            const SizedBox(height: 20),

            // Emergency Contacts if available
            if ((combinedPatientData?['emergencyContact'] != null) ||
                (combinedPatientData?['emergencyContacts'] != null &&
                    (combinedPatientData!['emergencyContacts'] as List)
                        .isNotEmpty)) ...[
              Text(
                'Emergency Contacts',
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
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.red.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (combinedPatientData?['emergencyContact'] != null) ...[
                      _buildEmergencyContactItem(
                        combinedPatientData!['emergencyContact']['name'],
                        combinedPatientData!['emergencyContact']['relationship'],
                        combinedPatientData!['emergencyContact']['phone'],
                      ),
                    ],
                    if (combinedPatientData?['emergencyContacts'] != null) ...[
                      ...(combinedPatientData!['emergencyContacts'] as List)
                          .map(
                            (contact) => _buildEmergencyContactItem(
                              contact['name'],
                              contact['relationship'],
                              contact['phone'],
                            ),
                          )
                          ,
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 30),

            // Settings Section
            Text(
              'App Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 15),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade600,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Settings',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Manage your app preferences and account settings',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.blue.shade600,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Health Tab - Health stats, wearables, insights
  Widget _buildHealthTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green.shade50, Colors.white]),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health Stats Section
            _buildEnhancedHealthStatsSection(),

            const SizedBox(height: 25),

            // Wearables Section
            _buildEnhancedWearablesSection(),

            const SizedBox(height: 25),

            // Recent Activity
            _buildEnhancedRecentActivitySection(),

            const SizedBox(height: 25),

            // Health Insights
            _buildEnhancedHealthInsightsSection(),
          ],
        ),
      ),
    );
  }

  // Services Tab - All medical services
  Widget _buildServicesTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.teal.shade50, Colors.white]),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Healthcare Services',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 20),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.9,
              children: [
                _buildServiceCard(
                  icon: Icons.sos,
                  title: 'Emergency SOS',
                  subtitle: 'Immediate help',
                  color: Colors.red.shade600,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdvancedSOSScreen(),
                    ),
                  ),
                ),
                _buildServiceCard(
                  icon: Icons.local_hospital,
                  title: 'Hospital',
                  subtitle: 'Find nearby hospitals',
                  color: Colors.blue.shade600,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Hospital services coming soon'),
                      ),
                    );
                  },
                ),
                _buildServiceCard(
                  icon: Icons.video_call,
                  title: 'Telemedicine',
                  subtitle: 'Video consultations',
                  color: Colors.green.shade600,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Telemedicine feature coming soon'),
                      ),
                    );
                  },
                ),
                _buildServiceCard(
                  icon: Icons.monitor_heart,
                  title: 'Vitals Monitor',
                  subtitle: 'Track vital signs',
                  color: Colors.purple.shade600,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vitals Monitor feature coming soon'),
                      ),
                    );
                  },
                ),
                _buildServiceCard(
                  icon: Icons.smart_toy,
                  title: 'AI HealthBot',
                  subtitle: 'Health assistant',
                  color: Colors.orange.shade600,
                  onTap: () {
                    Navigator.of(context).pushNamed('/ai-health-chatbot');
                  },
                ),
                _buildServiceCard(
                  icon: Icons.shield,
                  title: 'Insurance Services',
                  subtitle: 'Manage policies',
                  color: Colors.teal.shade600,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Insurance Services feature coming soon'),
                      ),
                    );
                  },
                ),
                _buildServiceCard(
                  icon: Icons.warning,
                  title: 'Proximity Alerts',
                  subtitle: 'Health warnings',
                  color: Colors.amber.shade600,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Proximity Alerts feature coming soon'),
                      ),
                    );
                  },
                ),
                _buildServiceCard(
                  icon: Icons.games,
                  title: 'Health Gamification',
                  subtitle: 'Wellness rewards',
                  color: Colors.pink.shade600,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Health Gamification feature coming soon',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 100), // Space for floating button
          ],
        ),
      ),
    );
  }

  // Helper method to build welcome section for home tab
  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade700],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
              ],
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue.shade100,
              backgroundImage: _getPatientPhotoImageProvider(),
              child: patientPhoto == null
                  ? Icon(Icons.person, size: 35, color: Colors.blue.shade700)
                  : null,
            ),
          ),
          const SizedBox(width: 20),
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
                const SizedBox(height: 4),
                Text(
                  patientName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.health_and_safety,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Health: $patientHealthStatus',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build quick action buttons for home tab
  Widget _buildQuickActionButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build profile information cards
  Widget _buildProfileInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build emergency contact items
  Widget _buildEmergencyContactItem(
    String name,
    String relationship,
    String phone,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.contact_emergency, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
                Text(
                  '$relationship • $phone',
                  style: TextStyle(fontSize: 12, color: Colors.red.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Calling $name...')));
            },
            icon: Icon(Icons.call, color: Colors.red.shade600, size: 20),
          ),
        ],
      ),
    );
  }

  // Helper method to build service cards for services tab
  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
                      ((0.3 * (1 - _sosRippleAnimation.value)) / (i + 1)).clamp(
                        0.0,
                        1.0,
                      ),
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
                      color: Colors.red.withOpacity(
                        0.5 + (_sosScaleAnimation.value - 1.0) * 3,
                      ),
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
                        border: Border.all(color: Colors.white, width: 3),
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
                                fontSize:
                                    11 + (_sosScaleAnimation.value - 1.0) * 3,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
            colors: [Colors.white, color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(
                _hoveredStatCards.contains(index) ? 0.2 : 0.1,
              ),
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
        transform: Matrix4.identity()
          ..scale(_wearablesCardHovered ? 1.01 : 1.0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.blue.shade50, Colors.white]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(
                _wearablesCardHovered ? 0.15 : 0.1,
              ),
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
                        builder: (context) =>
                            WearablesScreen(patientId: patientUhid),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text(
                    'View All',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
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
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 6,
                      ),
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
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 6,
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
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        Text(time, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
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
                    child: const Icon(
                      Icons.tips_and_updates,
                      color: Colors.white,
                      size: 20,
                    ),
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
                ...healthTips
                    .map(
                      (tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          '• $tip',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.teal.shade700,
                            height: 1.5,
                          ),
                        ),
                      ),
                    )
                    ,
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
