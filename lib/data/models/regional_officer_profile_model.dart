class RegionalOfficerProfile {
  final String officerId;
  final String employeeId;
  final PersonalInfo personalInfo;
  final ProfessionalInfo professionalInfo;
  final ContactInfo contactInfo;
  final JurisdictionInfo jurisdiction;
  final List<Qualification> qualifications;
  final List<Achievement> achievements;
  final SystemPreferences preferences;
  final SecuritySettings security;
  final ActivityLog activityLog;
  final PerformanceMetrics performance;

  RegionalOfficerProfile({
    required this.officerId,
    required this.employeeId,
    required this.personalInfo,
    required this.professionalInfo,
    required this.contactInfo,
    required this.jurisdiction,
    required this.qualifications,
    required this.achievements,
    required this.preferences,
    required this.security,
    required this.activityLog,
    required this.performance,
  });

  factory RegionalOfficerProfile.fromJson(Map<String, dynamic> json) {
    return RegionalOfficerProfile(
      officerId: json['officerId'],
      employeeId: json['employeeId'],
      personalInfo: PersonalInfo.fromJson(json['personalInfo']),
      professionalInfo: ProfessionalInfo.fromJson(json['professionalInfo']),
      contactInfo: ContactInfo.fromJson(json['contactInfo']),
      jurisdiction: JurisdictionInfo.fromJson(json['jurisdiction']),
      qualifications: (json['qualifications'] as List)
          .map((item) => Qualification.fromJson(item))
          .toList(),
      achievements: (json['achievements'] as List)
          .map((item) => Achievement.fromJson(item))
          .toList(),
      preferences: SystemPreferences.fromJson(json['preferences']),
      security: SecuritySettings.fromJson(json['security']),
      activityLog: ActivityLog.fromJson(json['activityLog']),
      performance: PerformanceMetrics.fromJson(json['performance']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'officerId': officerId,
      'employeeId': employeeId,
      'personalInfo': personalInfo.toJson(),
      'professionalInfo': professionalInfo.toJson(),
      'contactInfo': contactInfo.toJson(),
      'jurisdiction': jurisdiction.toJson(),
      'qualifications': qualifications.map((item) => item.toJson()).toList(),
      'achievements': achievements.map((item) => item.toJson()).toList(),
      'preferences': preferences.toJson(),
      'security': security.toJson(),
      'activityLog': activityLog.toJson(),
      'performance': performance.toJson(),
    };
  }

  RegionalOfficerProfile copyWith({
    String? officerId,
    String? employeeId,
    PersonalInfo? personalInfo,
    ProfessionalInfo? professionalInfo,
    ContactInfo? contactInfo,
    JurisdictionInfo? jurisdiction,
    List<Qualification>? qualifications,
    List<Achievement>? achievements,
    SystemPreferences? preferences,
    SecuritySettings? security,
    ActivityLog? activityLog,
    PerformanceMetrics? performance,
  }) {
    return RegionalOfficerProfile(
      officerId: officerId ?? this.officerId,
      employeeId: employeeId ?? this.employeeId,
      personalInfo: personalInfo ?? this.personalInfo,
      professionalInfo: professionalInfo ?? this.professionalInfo,
      contactInfo: contactInfo ?? this.contactInfo,
      jurisdiction: jurisdiction ?? this.jurisdiction,
      qualifications: qualifications ?? this.qualifications,
      achievements: achievements ?? this.achievements,
      preferences: preferences ?? this.preferences,
      security: security ?? this.security,
      activityLog: activityLog ?? this.activityLog,
      performance: performance ?? this.performance,
    );
  }
}

class PersonalInfo {
  final String firstName;
  final String lastName;
  final String? middleName;
  final DateTime dateOfBirth;
  final String gender;
  final String nationality;
  final Address address;
  final EmergencyContact emergencyContact;
  final String? profilePhotoUrl;

  PersonalInfo({
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.dateOfBirth,
    required this.gender,
    required this.nationality,
    required this.address,
    required this.emergencyContact,
    this.profilePhotoUrl,
  });

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      firstName: json['firstName'],
      lastName: json['lastName'],
      middleName: json['middleName'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: json['gender'],
      nationality: json['nationality'],
      address: Address.fromJson(json['address']),
      emergencyContact: EmergencyContact.fromJson(json['emergencyContact']),
      profilePhotoUrl: json['profilePhotoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'nationality': nationality,
      'address': address.toJson(),
      'emergencyContact': emergencyContact.toJson(),
      'profilePhotoUrl': profilePhotoUrl,
    };
  }

  String get fullName {
    final middle = middleName != null ? ' $middleName ' : ' ';
    return '$firstName$middle$lastName';
  }

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }
}

class ProfessionalInfo {
  final String designation;
  final String department;
  final DateTime joiningDate;
  final String employmentType;
  final String reportingManager;
  final String workLocation;
  final double salary;
  final List<String> responsibilities;
  final List<String> specializations;
  final int yearsOfExperience;
  final String currentGrade;

  ProfessionalInfo({
    required this.designation,
    required this.department,
    required this.joiningDate,
    required this.employmentType,
    required this.reportingManager,
    required this.workLocation,
    required this.salary,
    required this.responsibilities,
    required this.specializations,
    required this.yearsOfExperience,
    required this.currentGrade,
  });

  factory ProfessionalInfo.fromJson(Map<String, dynamic> json) {
    return ProfessionalInfo(
      designation: json['designation'],
      department: json['department'],
      joiningDate: DateTime.parse(json['joiningDate']),
      employmentType: json['employmentType'],
      reportingManager: json['reportingManager'],
      workLocation: json['workLocation'],
      salary: json['salary'].toDouble(),
      responsibilities: List<String>.from(json['responsibilities']),
      specializations: List<String>.from(json['specializations']),
      yearsOfExperience: json['yearsOfExperience'],
      currentGrade: json['currentGrade'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'designation': designation,
      'department': department,
      'joiningDate': joiningDate.toIso8601String(),
      'employmentType': employmentType,
      'reportingManager': reportingManager,
      'workLocation': workLocation,
      'salary': salary,
      'responsibilities': responsibilities,
      'specializations': specializations,
      'yearsOfExperience': yearsOfExperience,
      'currentGrade': currentGrade,
    };
  }

  Duration get tenure => DateTime.now().difference(joiningDate);
  
  String get tenureText {
    final years = tenure.inDays ~/ 365;
    final months = (tenure.inDays % 365) ~/ 30;
    
    if (years > 0) {
      return months > 0 ? '$years years, $months months' : '$years years';
    } else {
      return '$months months';
    }
  }
}

class ContactInfo {
  final String primaryEmail;
  final String? secondaryEmail;
  final String primaryPhone;
  final String? secondaryPhone;
  final String? officePhone;
  final String? faxNumber;

  ContactInfo({
    required this.primaryEmail,
    this.secondaryEmail,
    required this.primaryPhone,
    this.secondaryPhone,
    this.officePhone,
    this.faxNumber,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      primaryEmail: json['primaryEmail'],
      secondaryEmail: json['secondaryEmail'],
      primaryPhone: json['primaryPhone'],
      secondaryPhone: json['secondaryPhone'],
      officePhone: json['officePhone'],
      faxNumber: json['faxNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primaryEmail': primaryEmail,
      'secondaryEmail': secondaryEmail,
      'primaryPhone': primaryPhone,
      'secondaryPhone': secondaryPhone,
      'officePhone': officePhone,
      'faxNumber': faxNumber,
    };
  }
}

class Address {
  final String street;
  final String city;
  final String state;
  final String pincode;
  final String country;
  final double? latitude;
  final double? longitude;

  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
    this.latitude,
    this.longitude,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      country: json['country'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'pincode': pincode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  String get fullAddress => '$street, $city, $state - $pincode, $country';
}

class EmergencyContact {
  final String name;
  final String relationship;
  final String phoneNumber;
  final String? email;
  final Address? address;

  EmergencyContact({
    required this.name,
    required this.relationship,
    required this.phoneNumber,
    this.email,
    this.address,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'],
      relationship: json['relationship'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relationship': relationship,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address?.toJson(),
    };
  }
}

class JurisdictionInfo {
  final String regionId;
  final String regionName;
  final List<String> districts;
  final List<String> coveredHospitals;
  final int populationCovered;
  final double areaKmSquare;
  final DateTime assignedDate;
  final List<String> authorizedActions;

  JurisdictionInfo({
    required this.regionId,
    required this.regionName,
    required this.districts,
    required this.coveredHospitals,
    required this.populationCovered,
    required this.areaKmSquare,
    required this.assignedDate,
    required this.authorizedActions,
  });

  factory JurisdictionInfo.fromJson(Map<String, dynamic> json) {
    return JurisdictionInfo(
      regionId: json['regionId'],
      regionName: json['regionName'],
      districts: List<String>.from(json['districts']),
      coveredHospitals: List<String>.from(json['coveredHospitals']),
      populationCovered: json['populationCovered'],
      areaKmSquare: json['areaKmSquare'].toDouble(),
      assignedDate: DateTime.parse(json['assignedDate']),
      authorizedActions: List<String>.from(json['authorizedActions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'regionId': regionId,
      'regionName': regionName,
      'districts': districts,
      'coveredHospitals': coveredHospitals,
      'populationCovered': populationCovered,
      'areaKmSquare': areaKmSquare,
      'assignedDate': assignedDate.toIso8601String(),
      'authorizedActions': authorizedActions,
    };
  }
}

class Qualification {
  final String degree;
  final String institution;
  final String fieldOfStudy;
  final DateTime completionDate;
  final String grade;
  final String? certificateUrl;

  Qualification({
    required this.degree,
    required this.institution,
    required this.fieldOfStudy,
    required this.completionDate,
    required this.grade,
    this.certificateUrl,
  });

  factory Qualification.fromJson(Map<String, dynamic> json) {
    return Qualification(
      degree: json['degree'],
      institution: json['institution'],
      fieldOfStudy: json['fieldOfStudy'],
      completionDate: DateTime.parse(json['completionDate']),
      grade: json['grade'],
      certificateUrl: json['certificateUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'degree': degree,
      'institution': institution,
      'fieldOfStudy': fieldOfStudy,
      'completionDate': completionDate.toIso8601String(),
      'grade': grade,
      'certificateUrl': certificateUrl,
    };
  }
}

class Achievement {
  final String title;
  final String description;
  final DateTime achievedDate;
  final String awardedBy;
  final String category;
  final String? certificateUrl;

  Achievement({
    required this.title,
    required this.description,
    required this.achievedDate,
    required this.awardedBy,
    required this.category,
    this.certificateUrl,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      title: json['title'],
      description: json['description'],
      achievedDate: DateTime.parse(json['achievedDate']),
      awardedBy: json['awardedBy'],
      category: json['category'],
      certificateUrl: json['certificateUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'achievedDate': achievedDate.toIso8601String(),
      'awardedBy': awardedBy,
      'category': category,
      'certificateUrl': certificateUrl,
    };
  }
}

class SystemPreferences {
  final String language;
  final String theme;
  final bool notificationsEnabled;
  final List<String> notificationTypes;
  final String dateFormat;
  final String timeFormat;
  final String timezone;
  final bool twoFactorEnabled;
  final Map<String, bool> dashboardWidgets;

  SystemPreferences({
    required this.language,
    required this.theme,
    required this.notificationsEnabled,
    required this.notificationTypes,
    required this.dateFormat,
    required this.timeFormat,
    required this.timezone,
    required this.twoFactorEnabled,
    required this.dashboardWidgets,
  });

  factory SystemPreferences.fromJson(Map<String, dynamic> json) {
    return SystemPreferences(
      language: json['language'],
      theme: json['theme'],
      notificationsEnabled: json['notificationsEnabled'],
      notificationTypes: List<String>.from(json['notificationTypes']),
      dateFormat: json['dateFormat'],
      timeFormat: json['timeFormat'],
      timezone: json['timezone'],
      twoFactorEnabled: json['twoFactorEnabled'],
      dashboardWidgets: Map<String, bool>.from(json['dashboardWidgets']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'theme': theme,
      'notificationsEnabled': notificationsEnabled,
      'notificationTypes': notificationTypes,
      'dateFormat': dateFormat,
      'timeFormat': timeFormat,
      'timezone': timezone,
      'twoFactorEnabled': twoFactorEnabled,
      'dashboardWidgets': dashboardWidgets,
    };
  }
}

class SecuritySettings {
  final DateTime lastPasswordChange;
  final bool accountLocked;
  final DateTime? lockoutUntil;
  final int failedLoginAttempts;
  final List<LoginSession> activeSessions;
  final List<SecurityEvent> recentSecurityEvents;

  SecuritySettings({
    required this.lastPasswordChange,
    required this.accountLocked,
    this.lockoutUntil,
    required this.failedLoginAttempts,
    required this.activeSessions,
    required this.recentSecurityEvents,
  });

  factory SecuritySettings.fromJson(Map<String, dynamic> json) {
    return SecuritySettings(
      lastPasswordChange: DateTime.parse(json['lastPasswordChange']),
      accountLocked: json['accountLocked'],
      lockoutUntil: json['lockoutUntil'] != null 
          ? DateTime.parse(json['lockoutUntil']) 
          : null,
      failedLoginAttempts: json['failedLoginAttempts'],
      activeSessions: (json['activeSessions'] as List)
          .map((item) => LoginSession.fromJson(item))
          .toList(),
      recentSecurityEvents: (json['recentSecurityEvents'] as List)
          .map((item) => SecurityEvent.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastPasswordChange': lastPasswordChange.toIso8601String(),
      'accountLocked': accountLocked,
      'lockoutUntil': lockoutUntil?.toIso8601String(),
      'failedLoginAttempts': failedLoginAttempts,
      'activeSessions': activeSessions.map((item) => item.toJson()).toList(),
      'recentSecurityEvents': recentSecurityEvents.map((item) => item.toJson()).toList(),
    };
  }
}

class LoginSession {
  final String sessionId;
  final DateTime loginTime;
  final DateTime lastActivity;
  final String ipAddress;
  final String deviceInfo;
  final String location;
  final bool isCurrentSession;

  LoginSession({
    required this.sessionId,
    required this.loginTime,
    required this.lastActivity,
    required this.ipAddress,
    required this.deviceInfo,
    required this.location,
    required this.isCurrentSession,
  });

  factory LoginSession.fromJson(Map<String, dynamic> json) {
    return LoginSession(
      sessionId: json['sessionId'],
      loginTime: DateTime.parse(json['loginTime']),
      lastActivity: DateTime.parse(json['lastActivity']),
      ipAddress: json['ipAddress'],
      deviceInfo: json['deviceInfo'],
      location: json['location'],
      isCurrentSession: json['isCurrentSession'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'loginTime': loginTime.toIso8601String(),
      'lastActivity': lastActivity.toIso8601String(),
      'ipAddress': ipAddress,
      'deviceInfo': deviceInfo,
      'location': location,
      'isCurrentSession': isCurrentSession,
    };
  }
}

class SecurityEvent {
  final String eventType;
  final DateTime timestamp;
  final String description;
  final String ipAddress;
  final String deviceInfo;
  final String riskLevel;

  SecurityEvent({
    required this.eventType,
    required this.timestamp,
    required this.description,
    required this.ipAddress,
    required this.deviceInfo,
    required this.riskLevel,
  });

  factory SecurityEvent.fromJson(Map<String, dynamic> json) {
    return SecurityEvent(
      eventType: json['eventType'],
      timestamp: DateTime.parse(json['timestamp']),
      description: json['description'],
      ipAddress: json['ipAddress'],
      deviceInfo: json['deviceInfo'],
      riskLevel: json['riskLevel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventType': eventType,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'ipAddress': ipAddress,
      'deviceInfo': deviceInfo,
      'riskLevel': riskLevel,
    };
  }
}

class ActivityLog {
  final DateTime lastLogin;
  final DateTime lastActivity;
  final int totalLogins;
  final List<RecentActivity> recentActivities;

  ActivityLog({
    required this.lastLogin,
    required this.lastActivity,
    required this.totalLogins,
    required this.recentActivities,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      lastLogin: DateTime.parse(json['lastLogin']),
      lastActivity: DateTime.parse(json['lastActivity']),
      totalLogins: json['totalLogins'],
      recentActivities: (json['recentActivities'] as List)
          .map((item) => RecentActivity.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastLogin': lastLogin.toIso8601String(),
      'lastActivity': lastActivity.toIso8601String(),
      'totalLogins': totalLogins,
      'recentActivities': recentActivities.map((item) => item.toJson()).toList(),
    };
  }
}

class RecentActivity {
  final String action;
  final DateTime timestamp;
  final String description;
  final String module;

  RecentActivity({
    required this.action,
    required this.timestamp,
    required this.description,
    required this.module,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      action: json['action'],
      timestamp: DateTime.parse(json['timestamp']),
      description: json['description'],
      module: json['module'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'module': module,
    };
  }
}

class PerformanceMetrics {
  final int approvalProcessed;
  final int alertsResolved;
  final int reportsGenerated;
  final double responseTime;
  final double satisfactionRating;
  final List<PerformanceGoal> goals;

  PerformanceMetrics({
    required this.approvalProcessed,
    required this.alertsResolved,
    required this.reportsGenerated,
    required this.responseTime,
    required this.satisfactionRating,
    required this.goals,
  });

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      approvalProcessed: json['approvalProcessed'],
      alertsResolved: json['alertsResolved'],
      reportsGenerated: json['reportsGenerated'],
      responseTime: json['responseTime'].toDouble(),
      satisfactionRating: json['satisfactionRating'].toDouble(),
      goals: (json['goals'] as List)
          .map((item) => PerformanceGoal.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'approvalProcessed': approvalProcessed,
      'alertsResolved': alertsResolved,
      'reportsGenerated': reportsGenerated,
      'responseTime': responseTime,
      'satisfactionRating': satisfactionRating,
      'goals': goals.map((item) => item.toJson()).toList(),
    };
  }
}

class PerformanceGoal {
  final String goalId;
  final String title;
  final String description;
  final int targetValue;
  final int currentValue;
  final DateTime deadline;
  final String status;

  PerformanceGoal({
    required this.goalId,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.currentValue,
    required this.deadline,
    required this.status,
  });

  factory PerformanceGoal.fromJson(Map<String, dynamic> json) {
    return PerformanceGoal(
      goalId: json['goalId'],
      title: json['title'],
      description: json['description'],
      targetValue: json['targetValue'],
      currentValue: json['currentValue'],
      deadline: DateTime.parse(json['deadline']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goalId': goalId,
      'title': title,
      'description': description,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'deadline': deadline.toIso8601String(),
      'status': status,
    };
  }

  double get progressPercentage => (currentValue / targetValue * 100).clamp(0, 100);
}
