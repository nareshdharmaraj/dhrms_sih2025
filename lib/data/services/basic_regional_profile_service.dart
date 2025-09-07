class BasicRegionalProfileService {
  static final BasicRegionalProfileService _instance = BasicRegionalProfileService._internal();
  factory BasicRegionalProfileService() => _instance;
  BasicRegionalProfileService._internal();

  Map<String, dynamic>? _currentProfile;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await Future.delayed(const Duration(milliseconds: 500));
    _loadMockProfile();
    _isInitialized = true;
  }

  // Get current profile
  Future<Map<String, dynamic>?> getCurrentProfile() async {
    await initialize();
    return _currentProfile;
  }

  // Get profile statistics
  Future<Map<String, dynamic>> getProfileStatistics() async {
    await initialize();
    
    return {
      'profile_completeness': 85,
      'total_qualifications': 2,
      'total_achievements': 1,
      'alerts_resolved': 23,
      'reports_generated': 12,
      'response_time': 2.5,
      'satisfaction_rating': 4.3,
      'years_of_experience': 15,
      'last_login': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    };
  }

  // Update profile field
  Future<void> updateProfileField(String field, dynamic value) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (_currentProfile != null) {
      _currentProfile![field] = value;
    }
  }

  // Load mock profile for development
  void _loadMockProfile() {
    _currentProfile = {
      'officerId': 'RO001',
      'employeeId': 'EMP2023001',
      'firstName': 'Rajesh',
      'lastName': 'Menon',
      'designation': 'Regional Health Officer',
      'department': 'Public Health Department',
      'email': 'rajesh.menon@kerala.gov.in',
      'phone': '+91-9876543210',
      'region': 'Ernakulam Region',
      'experience': 15,
      'joiningDate': '2020-04-01',
      'profilePicture': 'https://example.com/profiles/rajesh_menon.jpg',
    };
  }
}
