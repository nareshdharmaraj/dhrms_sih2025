class RegionalHealthOfficer {
  final String id;
  final String officerId;
  final String fullName;
  final String email;
  final String phone;
  final String assignedState;
  final String assignedRegion;
  final String regionCode;
  final String parentSHO;
  final Map<String, dynamic> permissions;
  final Map<String, dynamic> staffLimits;
  final Map<String, dynamic> coverage;
  final Map<String, dynamic> statistics;
  final Map<String, dynamic> officeAddress;
  final String? officePhone;
  final Map<String, dynamic>? emergencyContact;
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;

  RegionalHealthOfficer({
    required this.id,
    required this.officerId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.assignedState,
    required this.assignedRegion,
    required this.regionCode,
    required this.parentSHO,
    required this.permissions,
    required this.staffLimits,
    required this.coverage,
    required this.statistics,
    required this.officeAddress,
    this.officePhone,
    this.emergencyContact,
    required this.isActive,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RegionalHealthOfficer.fromJson(Map<String, dynamic> json) {
    return RegionalHealthOfficer(
      id: json['_id'] ?? '',
      officerId: json['officerId'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      assignedState: json['assignedState'] ?? '',
      assignedRegion: json['assignedRegion'] ?? '',
      regionCode: json['regionCode'] ?? '',
      parentSHO: json['parentSHO'] ?? '',
      permissions: json['permissions'] ?? {},
      staffLimits: json['staffLimits'] ?? {},
      coverage: json['coverage'] ?? {},
      statistics: json['statistics'] ?? {},
      officeAddress: json['officeAddress'] ?? {},
      officePhone: json['officePhone'],
      emergencyContact: json['emergencyContact'],
      isActive: json['isActive'] ?? true,
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'officerId': officerId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'assignedState': assignedState,
      'assignedRegion': assignedRegion,
      'regionCode': regionCode,
      'parentSHO': parentSHO,
      'permissions': permissions,
      'staffLimits': staffLimits,
      'coverage': coverage,
      'statistics': statistics,
      'officeAddress': officeAddress,
      'officePhone': officePhone,
      'emergencyContact': emergencyContact,
      'isActive': isActive,
      'lastLogin': lastLogin?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Getters
  String get formattedOfficerId => officerId;
  
  String get fullRegionName => '$assignedRegion, $assignedState';
  
  String get statusText {
    if (!isActive) return 'Inactive';
    return 'Active';
  }

  int get totalStaff => (statistics['totalStaff'] as int?) ?? 0;
  
  int get activeStaff => (statistics['activeStaff'] as int?) ?? 0;
  
  int get totalPatients => (statistics['totalPatients'] as int?) ?? 0;
  
  int get monthlyPatients => (statistics['monthlyPatients'] as int?) ?? 0;

  int get maxDoctors => (staffLimits['maxDoctors'] as int?) ?? 0;
  
  int get maxNurses => (staffLimits['maxNurses'] as int?) ?? 0;
  
  int get maxLabAssistants => (staffLimits['maxLabAssistants'] as int?) ?? 0;
  
  int get maxPharmacists => (staffLimits['maxPharmacists'] as int?) ?? 0;

  int get totalStaffLimit {
    return maxDoctors + maxNurses + maxLabAssistants + maxPharmacists;
  }

  double get staffUtilization {
    if (totalStaffLimit == 0) return 0;
    return (totalStaff / totalStaffLimit) * 100;
  }

  String get staffUtilizationText {
    return '${staffUtilization.toStringAsFixed(1)}%';
  }

  List<String> get districts => List<String>.from(coverage['districts'] ?? []);
  
  List<String> get subDistricts => List<String>.from(coverage['subDistricts'] ?? []);
  
  int get populationCovered => (coverage['populationCovered'] as int?) ?? 0;
  
  int get hospitalsCovered => (coverage['hospitalsCovered'] as int?) ?? 0;
  
  int get primaryHealthCenters => (coverage['primaryHealthCenters'] as int?) ?? 0;

  String get officeAddressText {
    final address = officeAddress['address'] ?? '';
    final city = officeAddress['city'] ?? '';
    final state = officeAddress['state'] ?? '';
    final pincode = officeAddress['pincode'] ?? '';
    
    List<String> parts = [];
    if (address.isNotEmpty) parts.add(address);
    if (city.isNotEmpty) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    if (pincode.isNotEmpty) parts.add(pincode);
    
    return parts.join(', ');
  }

  bool get canManageStaff => permissions['canManageRegionalStaff'] ?? false;
  
  bool get canViewStaff => permissions['canViewRegionalStaff'] ?? false;
  
  bool get canManageHospitals => permissions['canManageRegionalHospitals'] ?? false;
  
  bool get canViewPatients => permissions['canViewRegionalPatients'] ?? false;
  
  bool get canGenerateReports => permissions['canGenerateRegionalReports'] ?? false;

  // Copy with method for updates
  RegionalHealthOfficer copyWith({
    String? id,
    String? officerId,
    String? fullName,
    String? email,
    String? phone,
    String? assignedState,
    String? assignedRegion,
    String? regionCode,
    String? parentSHO,
    Map<String, dynamic>? permissions,
    Map<String, dynamic>? staffLimits,
    Map<String, dynamic>? coverage,
    Map<String, dynamic>? statistics,
    Map<String, dynamic>? officeAddress,
    String? officePhone,
    Map<String, dynamic>? emergencyContact,
    bool? isActive,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RegionalHealthOfficer(
      id: id ?? this.id,
      officerId: officerId ?? this.officerId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      assignedState: assignedState ?? this.assignedState,
      assignedRegion: assignedRegion ?? this.assignedRegion,
      regionCode: regionCode ?? this.regionCode,
      parentSHO: parentSHO ?? this.parentSHO,
      permissions: permissions ?? this.permissions,
      staffLimits: staffLimits ?? this.staffLimits,
      coverage: coverage ?? this.coverage,
      statistics: statistics ?? this.statistics,
      officeAddress: officeAddress ?? this.officeAddress,
      officePhone: officePhone ?? this.officePhone,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RegionalStaff {
  final String id;
  final String staffId;
  final String staffType;
  final String fullName;
  final String email;
  final String phone;
  final String qualification;
  final Map<String, dynamic> experience;
  final String licenseNumber;
  final List<String> specialization;
  final String assignedRegion;
  final String assignedState;
  final String? assignedHospital;
  final String department;
  final String parentRHO;
  final String parentSHO;
  final String employmentType;
  final DateTime joiningDate;
  final DateTime? contractEndDate;
  final Map<String, dynamic> salary;
  final Map<String, dynamic> address;
  final Map<String, dynamic>? emergencyContact;
  final bool isActive;
  final DateTime? lastLogin;
  final Map<String, dynamic> performance;
  final DateTime createdAt;
  final DateTime updatedAt;

  RegionalStaff({
    required this.id,
    required this.staffId,
    required this.staffType,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.qualification,
    required this.experience,
    required this.licenseNumber,
    required this.specialization,
    required this.assignedRegion,
    required this.assignedState,
    this.assignedHospital,
    required this.department,
    required this.parentRHO,
    required this.parentSHO,
    required this.employmentType,
    required this.joiningDate,
    this.contractEndDate,
    required this.salary,
    required this.address,
    this.emergencyContact,
    required this.isActive,
    this.lastLogin,
    required this.performance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RegionalStaff.fromJson(Map<String, dynamic> json) {
    return RegionalStaff(
      id: json['_id'] ?? '',
      staffId: json['staffId'] ?? '',
      staffType: json['staffType'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      qualification: json['qualification'] ?? '',
      experience: json['experience'] ?? {},
      licenseNumber: json['licenseNumber'] ?? '',
      specialization: List<String>.from(json['specialization'] ?? []),
      assignedRegion: json['assignedRegion'] ?? '',
      assignedState: json['assignedState'] ?? '',
      assignedHospital: json['assignedHospital'],
      department: json['department'] ?? '',
      parentRHO: json['parentRHO'] ?? '',
      parentSHO: json['parentSHO'] ?? '',
      employmentType: json['employmentType'] ?? 'Permanent',
      joiningDate: DateTime.parse(json['joiningDate']),
      contractEndDate: json['contractEndDate'] != null ? DateTime.parse(json['contractEndDate']) : null,
      salary: json['salary'] ?? {},
      address: json['address'] ?? {},
      emergencyContact: json['emergencyContact'],
      isActive: json['isActive'] ?? true,
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      performance: json['performance'] ?? {},
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  String get statusText {
    if (!isActive) return 'Inactive';
    return 'Active';
  }

  String get experienceText {
    final years = experience['years'] ?? 0;
    final months = experience['months'] ?? 0;
    
    if (years == 0 && months == 0) return 'Fresher';
    if (years == 0) return '$months months';
    if (months == 0) return '$years years';
    return '$years years $months months';
  }

  int get patientsHandled => (performance['patientsHandled'] as int?) ?? 0;
  
  double get rating => (performance['rating'] as double?) ?? 3.0;
}

class RHOStatistics {
  final int total;
  final int active;
  final int inactive;
  final int totalStaff;
  final int totalPatients;
  final List<RegionDistribution> regionDistribution;

  RHOStatistics({
    required this.total,
    required this.active,
    required this.inactive,
    required this.totalStaff,
    required this.totalPatients,
    required this.regionDistribution,
  });

  factory RHOStatistics.fromJson(Map<String, dynamic> json) {
    return RHOStatistics(
      total: json['total'] ?? 0,
      active: json['active'] ?? 0,
      inactive: json['inactive'] ?? 0,
      totalStaff: json['totalStaff'] ?? 0,
      totalPatients: json['totalPatients'] ?? 0,
      regionDistribution: (json['regionDistribution'] as List?)
          ?.map((item) => RegionDistribution.fromJson(item))
          .toList() ?? [],
    );
  }
}

class RegionDistribution {
  final String region;
  final int count;
  final int active;
  final int totalStaff;

  RegionDistribution({
    required this.region,
    required this.count,
    required this.active,
    required this.totalStaff,
  });

  factory RegionDistribution.fromJson(Map<String, dynamic> json) {
    return RegionDistribution(
      region: json['_id'] ?? '',
      count: json['count'] ?? 0,
      active: json['active'] ?? 0,
      totalStaff: json['totalStaff'] ?? 0,
    );
  }
}