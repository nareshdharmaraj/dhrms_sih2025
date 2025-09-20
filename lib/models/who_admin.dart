class WhoAdmin {
  final String id;
  final String adminId;
  final String fullName;
  final String email;
  final String phone;
  final String designation;
  final String region; // Global, Asia-Pacific, etc.
  final List<String> managedStates;
  final Map<String, dynamic> permissions;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;

  WhoAdmin({
    required this.id,
    required this.adminId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.designation,
    required this.region,
    required this.managedStates,
    required this.permissions,
    required this.createdAt,
    this.lastLogin,
    this.isActive = true,
  });

  factory WhoAdmin.fromJson(Map<String, dynamic> json) {
    return WhoAdmin(
      id: json['_id'] ?? json['id'] ?? '',
      adminId: json['adminId'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      designation: json['designation'] ?? '',
      region: json['region'] ?? '',
      managedStates: List<String>.from(json['managedStates'] ?? []),
      permissions: Map<String, dynamic>.from(json['permissions'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'adminId': adminId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'designation': designation,
      'region': region,
      'managedStates': managedStates,
      'permissions': permissions,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'isActive': isActive,
    };
  }

  bool hasPermission(String permission) {
    return permissions[permission] == true;
  }

  bool canManageState(String state) {
    return managedStates.contains(state) || managedStates.contains('ALL');
  }
}

class StateStatistics {
  final String state;
  final int totalHospitals;
  final int activeHospitals;
  final int totalPatients;
  final int totalRegionalOfficers;
  final int totalStaff;
  final Map<String, int> patientsByBloodGroup;
  final Map<String, int> hospitalsByType;
  final Map<String, int> monthlyRegistrations;
  final double averagePatientAge;
  final Map<String, int> genderDistribution;
  final DateTime lastUpdated;

  StateStatistics({
    required this.state,
    required this.totalHospitals,
    required this.activeHospitals,
    required this.totalPatients,
    required this.totalRegionalOfficers,
    required this.totalStaff,
    required this.patientsByBloodGroup,
    required this.hospitalsByType,
    required this.monthlyRegistrations,
    required this.averagePatientAge,
    required this.genderDistribution,
    required this.lastUpdated,
  });

  factory StateStatistics.fromJson(Map<String, dynamic> json) {
    return StateStatistics(
      state: json['state'] ?? '',
      totalHospitals: json['totalHospitals'] ?? 0,
      activeHospitals: json['activeHospitals'] ?? 0,
      totalPatients: json['totalPatients'] ?? 0,
      totalRegionalOfficers: json['totalRegionalOfficers'] ?? 0,
      totalStaff: json['totalStaff'] ?? 0,
      patientsByBloodGroup: Map<String, int>.from(json['patientsByBloodGroup'] ?? {}),
      hospitalsByType: Map<String, int>.from(json['hospitalsByType'] ?? {}),
      monthlyRegistrations: Map<String, int>.from(json['monthlyRegistrations'] ?? {}),
      averagePatientAge: (json['averagePatientAge'] ?? 0).toDouble(),
      genderDistribution: Map<String, int>.from(json['genderDistribution'] ?? {}),
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'state': state,
      'totalHospitals': totalHospitals,
      'activeHospitals': activeHospitals,
      'totalPatients': totalPatients,
      'totalRegionalOfficers': totalRegionalOfficers,
      'totalStaff': totalStaff,
      'patientsByBloodGroup': patientsByBloodGroup,
      'hospitalsByType': hospitalsByType,
      'monthlyRegistrations': monthlyRegistrations,
      'averagePatientAge': averagePatientAge,
      'genderDistribution': genderDistribution,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

class HospitalOverview {
  final String id;
  final String hospitalId;
  final String name;
  final String state;
  final String city;
  final String type;
  final int totalStaff;
  final int totalPatients;
  final bool isActive;
  final double rating;
  final Map<String, int> departmentCounts;
  final DateTime lastActivity;

  HospitalOverview({
    required this.id,
    required this.hospitalId,
    required this.name,
    required this.state,
    required this.city,
    required this.type,
    required this.totalStaff,
    required this.totalPatients,
    required this.isActive,
    required this.rating,
    required this.departmentCounts,
    required this.lastActivity,
  });

  factory HospitalOverview.fromJson(Map<String, dynamic> json) {
    return HospitalOverview(
      id: json['_id'] ?? json['id'] ?? '',
      hospitalId: json['hospitalId'] ?? '',
      name: json['name'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      type: json['type'] ?? '',
      totalStaff: json['totalStaff'] ?? 0,
      totalPatients: json['totalPatients'] ?? 0,
      isActive: json['isActive'] ?? true,
      rating: (json['rating'] ?? 0).toDouble(),
      departmentCounts: Map<String, int>.from(json['departmentCounts'] ?? {}),
      lastActivity: DateTime.parse(json['lastActivity'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'hospitalId': hospitalId,
      'name': name,
      'state': state,
      'city': city,
      'type': type,
      'totalStaff': totalStaff,
      'totalPatients': totalPatients,
      'isActive': isActive,
      'rating': rating,
      'departmentCounts': departmentCounts,
      'lastActivity': lastActivity.toIso8601String(),
    };
  }
}