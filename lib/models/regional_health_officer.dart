// Model for area assignments within districts
class AssignedArea {
  final String name;
  final String code;
  final String type; // 'area' or 'full-district'
  final int population;
  final double areaKm2;

  AssignedArea({
    required this.name,
    required this.code,
    required this.type,
    required this.population,
    required this.areaKm2,
  });

  factory AssignedArea.fromJson(Map<String, dynamic> json) {
    return AssignedArea(
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      type: json['type'] ?? 'area',
      population: json['population'] ?? 0,
      areaKm2: (json['areaKm2'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'type': type,
      'population': population,
      'areaKm2': areaKm2,
    };
  }

  // Display formatted area name
  String get displayName {
    if (type == 'full-district') {
      return 'Full District';
    }
    return name;
  }

  // Population text with formatting
  String get populationText {
    if (population >= 1000000) {
      return '${(population / 1000000).toStringAsFixed(1)}M';
    } else if (population >= 1000) {
      return '${(population / 1000).toStringAsFixed(0)}K';
    }
    return population.toString();
  }
}

class RegionalHealthOfficer {
  final String id;
  final String officerId;
  final String fullName;
  final String email;
  final String phone;
  final String assignedState;
  final String assignedDistrict;
  final String assignedRegion;
  final String regionCode;
  final String districtCode;
  final List<AssignedArea> assignedAreas;  // New field for area assignments
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
    required this.assignedDistrict,
    required this.assignedRegion,
    required this.regionCode,
    required this.districtCode,
    required this.assignedAreas,
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
    try {
      return RegionalHealthOfficer(
        id: json['_id'] ?? '',
        officerId: json['officerId'] ?? '',
        fullName: json['fullName'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        assignedState: json['assignedState'] ?? '',
        assignedDistrict: json['assignedDistrict'] ?? '',
        assignedRegion: json['assignedRegion'] ?? '',
        regionCode: json['regionCode'] ?? '',
        districtCode: json['districtCode'] ?? '',
        assignedAreas: (json['assignedAreas'] as List?)
            ?.map((area) => AssignedArea.fromJson(area))
            .toList() ?? [],
        parentSHO: json['parentSHO'] is String 
            ? json['parentSHO'] 
            : (json['parentSHO'] as Map<String, dynamic>?)?['_id'] ?? '',
        permissions: Map<String, dynamic>.from(json['permissions'] ?? {}),
        staffLimits: Map<String, dynamic>.from(json['staffLimits'] ?? {}),
        coverage: Map<String, dynamic>.from(json['coverage'] ?? {}),
        statistics: Map<String, dynamic>.from(json['statistics'] ?? {}),
        officeAddress: Map<String, dynamic>.from(json['officeAddress'] ?? {}),
        officePhone: json['officePhone'],
        emergencyContact: json['emergencyContact'] != null 
            ? Map<String, dynamic>.from(json['emergencyContact']) 
            : null,
        isActive: json['isActive'] ?? true,
        lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      );
    } catch (e, stackTrace) {
      print('❌ Error in RegionalHealthOfficer.fromJson: $e');
      print('❌ Stack trace: $stackTrace');
      print('❌ JSON that caused error: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'officerId': officerId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'assignedState': assignedState,
      'assignedDistrict': assignedDistrict,
      'assignedRegion': assignedRegion,
      'regionCode': regionCode,
      'districtCode': districtCode,
      'assignedAreas': assignedAreas.map((area) => area.toJson()).toList(),
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

  // Area assignment related getters
  bool get hasSpecificAreaAssignment => assignedAreas.isNotEmpty && 
      assignedAreas.any((area) => area.type == 'area');
  
  bool get hasFullDistrictAssignment => assignedAreas.isEmpty || 
      assignedAreas.any((area) => area.type == 'full-district');
  
  String get assignmentTypeText => hasSpecificAreaAssignment ? 'Area-specific' : 'Full District';
  
  List<String> get assignedAreaNames => assignedAreas.map((area) => area.displayName).toList();
  
  String get assignedAreasText {
    if (assignedAreas.isEmpty) return 'Full District';
    if (assignedAreas.length == 1) return assignedAreas.first.displayName;
    if (assignedAreas.length <= 3) {
      return assignedAreaNames.join(', ');
    }
    return '${assignedAreaNames.take(2).join(', ')} +${assignedAreas.length - 2} more';
  }
  
  int get totalAssignedPopulation => assignedAreas.fold(0, (sum, area) => sum + area.population);
  
  double get totalAssignedAreaKm2 => assignedAreas.fold(0.0, (sum, area) => sum + area.areaKm2);
  
  String get assignedPopulationText {
    final pop = totalAssignedPopulation;
    if (pop >= 1000000) {
      return '${(pop / 1000000).toStringAsFixed(1)}M people';
    } else if (pop >= 1000) {
      return '${(pop / 1000).toStringAsFixed(0)}K people';
    }
    return '$pop people';
  }

  // Copy with method for updates
  RegionalHealthOfficer copyWith({
    String? id,
    String? officerId,
    String? fullName,
    String? email,
    String? phone,
    String? assignedState,
    String? assignedDistrict,
    String? assignedRegion,
    String? regionCode,
    String? districtCode,
    List<AssignedArea>? assignedAreas,
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
      assignedDistrict: assignedDistrict ?? this.assignedDistrict,
      assignedRegion: assignedRegion ?? this.assignedRegion,
      regionCode: regionCode ?? this.regionCode,
      districtCode: districtCode ?? this.districtCode,
      assignedAreas: assignedAreas ?? this.assignedAreas,
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