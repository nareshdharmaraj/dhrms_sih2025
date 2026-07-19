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

  // Get profile statistics
  Future<Map<String, dynamic>> getProfileStatistics() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (_currentProfile == null) return {};
    
    final profile = _currentProfile!;
    
    return {
      'profile_completeness': 85,
      'total_qualifications': profile.qualifications.length,
      'total_achievements': profile.achievements.length,
      'alerts_resolved': profile.performance.alertsResolved,
      'reports_generated': profile.performance.reportsGenerated,
      'response_time': profile.performance.responseTime,
      'satisfaction_rating': profile.performance.satisfactionRating,
    };
  }

  // Export profile data
  Future<Map<String, dynamic>> exportProfileData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_currentProfile == null) throw Exception('No profile found');
    
    return _currentProfile!.toJson();
  }

  // Add listener for profile updates
  void addListener(Function(RegionalOfficerProfile) listener) {
    _listeners.add(listener);
  }

  // Remove listener
  void removeListener(Function(RegionalOfficerProfile) listener) {
    _listeners.remove(listener);
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
          pincode: '682001',
          country: 'India',
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
        employmentType: 'Permanent',
        reportingManager: 'Dr. Lakshmi Krishnan',
        workLocation: 'Ernakulam District Collectorate',
        salary: 75000.0,
        responsibilities: [
          'Health surveillance and monitoring',
          'Disease outbreak investigation',
          'Public health program implementation',
        ],
        specializations: ['Public Health', 'Epidemiology'],
        yearsOfExperience: 15,
        currentGrade: 'Grade A',
      ),
      contactInfo: ContactInfo(
        primaryEmail: 'rajesh.menon@kerala.gov.in',
        secondaryEmail: 'rajesh.menon@gmail.com',
        primaryPhone: '+91-9876543210',
        secondaryPhone: '+91-0484-2345678',
        officePhone: '+91-0484-2391234',
      ),
      jurisdiction: JurisdictionInfo(
        regionId: 'ERN001',
        regionName: 'Ernakulam Region',
        districts: ['Ernakulam', 'Thrissur', 'Kottayam'],
        coveredHospitals: ['Ernakulam Medical College', 'Kalamassery Hospital'],
        populationCovered: 3500000,
        areaKmSquare: 5000.0,
        assignedDate: DateTime(2020, 4, 1),
        authorizedActions: [
          'Health surveillance and monitoring',
          'Disease outbreak investigation',
          'Public health program implementation',
        ],
      ),
      qualifications: [
        Qualification(
          degree: 'MBBS',
          institution: 'Government Medical College, Thrissur',
          fieldOfStudy: 'Medicine',
          completionDate: DateTime(2008, 5, 1),
          grade: 'First Class',
          certificateUrl: 'https://example.com/certificates/mbbs.pdf',
        ),
        Qualification(
          degree: 'MPH',
          institution: 'SCTIMST, Trivandrum',
          fieldOfStudy: 'Public Health',
          completionDate: DateTime(2015, 7, 1),
          grade: 'Distinction',
          certificateUrl: 'https://example.com/certificates/mph.pdf',
        ),
      ],
      achievements: [
        Achievement(
          title: 'Best Health Officer 2022',
          description: 'Awarded for outstanding performance in health surveillance',
          achievedDate: DateTime(2022, 12, 15),
          awardedBy: 'Kerala State Health Department',
          category: 'Excellence Award',
          certificateUrl: 'https://example.com/certificates/award2022.pdf',
        ),
      ],
      preferences: SystemPreferences(
        language: 'English',
        theme: 'light',
        notificationsEnabled: true,
        notificationTypes: ['email', 'sms', 'push'],
        dateFormat: 'dd/MM/yyyy',
        timeFormat: '24h',
        timezone: 'Asia/Kolkata',
        twoFactorEnabled: true,
        dashboardWidgets: {
          'analytics': true,
          'alerts': true,
          'profile': true,
        },
      ),
      security: SecuritySettings(
        lastPasswordChange: DateTime.now().subtract(const Duration(days: 45)),
        accountLocked: false,
        failedLoginAttempts: 0,
        activeSessions: [
          LoginSession(
            sessionId: 'session_001',
            loginTime: DateTime.now().subtract(const Duration(hours: 2)),
            lastActivity: DateTime.now().subtract(const Duration(minutes: 15)),
            ipAddress: '192.168.1.100',
            deviceInfo: 'Mobile App',
            location: 'Kochi, Kerala',
            isCurrentSession: true,
          ),
        ],
        recentSecurityEvents: [],
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
    ];
    
    return List.generate(10, (index) {
      final random = Random();
      return RecentActivity(
        action: activities[random.nextInt(activities.length)],
        timestamp: DateTime.now().subtract(Duration(
          days: random.nextInt(7),
          hours: random.nextInt(24),
        )),
        description: 'Activity details',
        module: 'Regional Dashboard',
      );
    });
  }
}
