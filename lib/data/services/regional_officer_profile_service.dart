import 'dart:math';
import '../models/regional_officer_profile_model.dart';

class RegionalOfficerProfileService {
  static final RegionalOfficerProfileService _instance = RegionalOfficerProfileService._internal();
  factory RegionalOfficerProfileService() => _instance;
  RegionalOfficerProfileService._internal();

  RegionalOfficerProfile? _currentProfile;
  final List<Function(RegionalOfficerProfile)> _listeners = [];
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await Future.delayed(const Duration(milliseconds: 500));
    _loadMockProfile();
    _isInitialized = true;
  }

  // Get current profile
  Future<RegionalOfficerProfile?> getCurrentProfile() async {
    await initialize();
    return _currentProfile;
  }

  // Update personal information
  Future<RegionalOfficerProfile> updatePersonalInfo(PersonalInfo personalInfo) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_currentProfile == null) throw Exception('No profile found');
    
    _currentProfile = _currentProfile!.copyWith(personalInfo: personalInfo);
    _notifyListeners(_currentProfile!);
    return _currentProfile!;
  }

  // Update professional information
  Future<RegionalOfficerProfile> updateProfessionalInfo(ProfessionalInfo professionalInfo) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_currentProfile == null) throw Exception('No profile found');
    
    _currentProfile = _currentProfile!.copyWith(professionalInfo: professionalInfo);
    _notifyListeners(_currentProfile!);
    return _currentProfile!;
  }

  // Update contact information
  Future<RegionalOfficerProfile> updateContactInfo(ContactInfo contactInfo) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (_currentProfile == null) throw Exception('No profile found');
    
    _currentProfile = _currentProfile!.copyWith(contactInfo: contactInfo);
    _notifyListeners(_currentProfile!);
    return _currentProfile!;
  }

  // Update system preferences
  Future<RegionalOfficerProfile> updateSystemPreferences(SystemPreferences preferences) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (_currentProfile == null) throw Exception('No profile found');
    
    _currentProfile = _currentProfile!.copyWith(preferences: preferences);
    _notifyListeners(_currentProfile!);
    return _currentProfile!;
  }

  // Update security settings
  Future<RegionalOfficerProfile> updateSecuritySettings(SecuritySettings security) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (_currentProfile == null) throw Exception('No profile found');
    
    _currentProfile = _currentProfile!.copyWith(security: security);
    _notifyListeners(_currentProfile!);
    return _currentProfile!;
  }

  // Upload profile picture
  Future<String> uploadProfilePicture(String imagePath) async {
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate image upload
    final imageUrl = 'https://example.com/profiles/${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    if (_currentProfile != null) {
      final updatedPersonalInfo = PersonalInfo(
        firstName: _currentProfile!.personalInfo.firstName,
        lastName: _currentProfile!.personalInfo.lastName,
        middleName: _currentProfile!.personalInfo.middleName,
        dateOfBirth: _currentProfile!.personalInfo.dateOfBirth,
        gender: _currentProfile!.personalInfo.gender,
        nationality: _currentProfile!.personalInfo.nationality,
        address: _currentProfile!.personalInfo.address,
        emergencyContact: _currentProfile!.personalInfo.emergencyContact,
        profilePhotoUrl: imageUrl,
      );
      
      _currentProfile = _currentProfile!.copyWith(personalInfo: updatedPersonalInfo);
      _notifyListeners(_currentProfile!);
    }
    
    return imageUrl;
  }

  // Get performance metrics
  Future<PerformanceMetrics> getPerformanceMetrics() async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (_currentProfile == null) throw Exception('No profile found');
    
    return _currentProfile!.performance;
  }

  // Add qualification
  Future<void> addQualification(Qualification qualification) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (_currentProfile == null) return;
    
    final updatedQualifications = [..._currentProfile!.qualifications, qualification];
    _currentProfile = _currentProfile!.copyWith(qualifications: updatedQualifications);
    _notifyListeners(_currentProfile!);
  }

  // Remove qualification
  Future<void> removeQualification(String qualificationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (_currentProfile == null) return;
    
    final updatedQualifications = _currentProfile!.qualifications
        .where((q) => q.qualificationId != qualificationId)
        .toList();
    
    _currentProfile = _currentProfile!.copyWith(qualifications: updatedQualifications);
    _notifyListeners(_currentProfile!);
  }

  // Add achievement
  Future<void> addAchievement(Achievement achievement) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (_currentProfile == null) return;
    
    final updatedAchievements = [..._currentProfile!.achievements, achievement];
    _currentProfile = _currentProfile!.copyWith(achievements: updatedAchievements);
    _notifyListeners(_currentProfile!);
  }

  // Get activity logs
  Future<List<RecentActivity>> getRecentActivities({int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (_currentProfile == null) return [];
    
    final activities = _currentProfile!.activityLog.recentActivities;
    return activities.take(limit).toList();
  }

  // Export profile data
  Future<Map<String, dynamic>> exportProfileData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_currentProfile == null) throw Exception('No profile found');
    
    return _currentProfile!.toJson();
  }

  // Validate profile completeness
  Map<String, bool> validateProfileCompleteness() {
    if (_currentProfile == null) {
      return {
        'personal_info': false,
        'professional_info': false,
        'contact_info': false,
        'qualifications': false,
        'overall_complete': false,
      };
    }
    
    final profile = _currentProfile!;
    
    final personalComplete = profile.personalInfo.firstName.isNotEmpty &&
        profile.personalInfo.lastName.isNotEmpty;
    
    final professionalComplete = profile.professionalInfo.designation.isNotEmpty &&
        profile.professionalInfo.department.isNotEmpty;
    
    final contactComplete = profile.contactInfo.primaryPhone.isNotEmpty &&
        profile.contactInfo.workEmail.isNotEmpty;
    
    final qualificationsComplete = profile.qualifications.isNotEmpty;
    
    return {
      'personal_info': personalComplete,
      'professional_info': professionalComplete,
      'contact_info': contactComplete,
      'qualifications': qualificationsComplete,
      'overall_complete': personalComplete && professionalComplete && contactComplete,
    };
  }

  // Get profile statistics
  Future<Map<String, dynamic>> getProfileStatistics() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (_currentProfile == null) return {};
    
    final profile = _currentProfile!;
    final completeness = validateProfileCompleteness();
    
    return {
      'profile_completeness': completeness['overall_complete'] ? 100 : 75,
      'total_qualifications': profile.qualifications.length,
      'total_achievements': profile.achievements.length,
      'alerts_resolved': profile.performance.alertsResolved,
      'reports_generated': profile.performance.reportsGenerated,
      'response_time': profile.performance.responseTime,
      'satisfaction_rating': profile.performance.satisfactionRating,
    };
  }

  // Add listener for profile updates
  void addListener(Function(RegionalOfficerProfile) listener) {
    _listeners.add(listener);
  }

  // Remove listener
  void removeListener(Function(RegionalOfficerProfile) listener) {
    _listeners.remove(listener);
  }

  // Notify all listeners
  void _notifyListeners(RegionalOfficerProfile profile) {
    for (final listener in _listeners) {
      listener(profile);
    }
  }

  // Load mock profile for development
  void _loadMockProfile() {
    _currentProfile = RegionalOfficerProfile(
      officerId: 'RO001',
      employeeId: 'EMP2023001',
      personalInfo: PersonalInfo(
        firstName: 'Rajesh',
        lastName: 'Menon',
        middleName: 'Kumar',
        dateOfBirth: DateTime(1985, 6, 15),
        gender: 'Male',
        nationality: 'Indian',
        address: Address(
          street: '123 MG Road',
          city: 'Kochi',
          state: 'Kerala',
          country: 'India',
          postalCode: '682001',
        ),
        emergencyContact: EmergencyContact(
          name: 'Priya Menon',
          relationship: 'Wife',
          phoneNumber: '+91-9876543210',
        ),
        profilePhotoUrl: 'https://example.com/profiles/rajesh_menon.jpg',
      ),
      professionalInfo: ProfessionalInfo(
        designation: 'Regional Health Officer',
        department: 'Public Health Department',
        joiningDate: DateTime(2020, 4, 1),
        experience: '3 years',
        specialization: 'Public Health & Epidemiology',
        supervisorName: 'Dr. Lakshmi Krishnan',
        supervisorContact: '+91-0484-2391234',
      ),
      contactInfo: ContactInfo(
        primaryPhone: '+91-9876543210',
        secondaryPhone: '+91-0484-2345678',
        personalEmail: 'rajesh.menon@gmail.com',
        workEmail: 'rajesh.menon@kerala.gov.in',
        linkedinProfile: 'linkedin.com/in/rajeshmenon',
        emergencyContactNumber: '+91-9123456789',
      ),
      jurisdiction: JurisdictionInfo(
        regionId: 'ERN001',
        regionName: 'Ernakulam Region',
        districts: ['Ernakulam', 'Thrissur', 'Kottayam'],
        population: 3500000,
        area: 5000.0,
        hospitalCount: 45,
        healthCenterCount: 120,
        responsibilities: [
          'Health surveillance and monitoring',
          'Disease outbreak investigation',
          'Public health program implementation',
        ],
      ),
      qualifications: [
        Qualification(
          qualificationId: 'Q001',
          degree: 'MBBS',
          institution: 'Government Medical College, Thrissur',
          year: 2008,
          grade: 'First Class',
          certificateUrl: 'https://example.com/certificates/mbbs.pdf',
        ),
        Qualification(
          qualificationId: 'Q002',
          degree: 'MPH',
          institution: 'SCTIMST, Trivandrum',
          year: 2015,
          grade: 'Distinction',
          certificateUrl: 'https://example.com/certificates/mph.pdf',
        ),
      ],
      achievements: [
        Achievement(
          achievementId: 'A001',
          title: 'Best Health Officer 2022',
          description: 'Awarded for outstanding performance in health surveillance',
          dateReceived: DateTime(2022, 12, 15),
          issuedBy: 'Kerala State Health Department',
          certificateUrl: 'https://example.com/certificates/award2022.pdf',
        ),
      ],
      preferences: SystemPreferences(
        language: 'English',
        theme: 'light',
        dateFormat: 'dd/MM/yyyy',
        timeFormat: '24h',
        notificationSettings: {
          'email_alerts': true,
          'sms_alerts': true,
          'push_notifications': true,
        },
        dashboardLayout: {
          'analytics': '1',
          'alerts': '2',
          'profile': '3',
        },
      ),
      security: SecuritySettings(
        twoFactorEnabled: true,
        biometricEnabled: true,
        sessionTimeout: '30',
        allowedIpAddresses: ['192.168.1.0/24'],
        lastPasswordChange: DateTime.now().subtract(const Duration(days: 45)),
        loginHistory: [
          '2024-01-15 10:30:00',
          '2024-01-14 09:15:00',
          '2024-01-13 11:45:00',
        ],
      ),
      activityLog: ActivityLog(
        lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
        lastActivity: DateTime.now().subtract(const Duration(minutes: 15)),
        totalLogins: 156,
        recentActivities: _generateMockRecentActivities(),
      ),
      performance: PerformanceMetrics(
        approvalProcessed: 89,
        alertsResolved: 23,
        reportsGenerated: 12,
        responseTime: 2.5,
        satisfactionRating: 4.3,
        goals: [
          PerformanceGoal(
            goalId: 'G001',
            title: 'Monthly Alert Resolution',
            description: 'Resolve 30 alerts per month',
            targetValue: 30,
            currentValue: 23,
            deadline: DateTime.now().add(const Duration(days: 10)),
            status: 'In Progress',
          ),
        ],
      ),
    );
  }

  List<RecentActivity> _generateMockRecentActivities() {
    final activities = [
      'Login to system',
      'Viewed analytics dashboard',
      'Acknowledged critical alert',
      'Generated monthly report',
      'Updated profile information',
      'Attended virtual training',
      'Coordinated with hospital staff',
      'Reviewed disease surveillance data',
      'Responded to emergency alert',
      'Updated security settings',
    ];
    
    return List.generate(20, (index) {
      final random = Random();
      return RecentActivity(
        action: activities[random.nextInt(activities.length)],
        timestamp: DateTime.now().subtract(Duration(
          days: random.nextInt(30),
          hours: random.nextInt(24),
          minutes: random.nextInt(60),
        )),
        description: 'Detailed information about the activity performed',
        module: 'Regional Dashboard',
      );
    });
  }

  // Change password (simplified)
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (currentPassword != 'oldPassword123') {
      throw Exception('Current password is incorrect');
    }
    
    if (newPassword.length < 8) {
      throw Exception('New password must be at least 8 characters');
    }
    
    return true;
  }

  // Backup and restore (simplified)
  Future<String> backupProfile() async {
    await Future.delayed(const Duration(seconds: 1));
    return 'backup_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> restoreProfile(String backupId) async {
    await Future.delayed(const Duration(seconds: 2));
    // Restore implementation would go here
  }
}
