/// Hospital data models with enhanced location and RHO assignment information
/// for the DHRMS (Digital Health Record Management System)

class HospitalAddress {
  final String street;
  final String city;
  final String state;
  final String district;
  final String? subDistrict;
  final String pincode;

  const HospitalAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.district,
    this.subDistrict,
    required this.pincode,
  });

  factory HospitalAddress.fromJson(Map<String, dynamic> json) {
    return HospitalAddress(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      district: json['district'] ?? '',
      subDistrict: json['subDistrict'],
      pincode: json['pincode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'district': district,
      'subDistrict': subDistrict,
      'pincode': pincode,
    };
  }

  /// Get formatted address string
  String get formattedAddress {
    List<String> parts = [street, city];
    if (subDistrict != null && subDistrict!.isNotEmpty) {
      parts.add(subDistrict!);
    }
    parts.addAll([district, state, pincode]);
    return parts.where((part) => part.isNotEmpty).join(', ');
  }

  /// Get location for RHO assignment (state, district, sub-district)
  String get locationForRHO {
    if (subDistrict != null && subDistrict!.isNotEmpty) {
      return '$subDistrict, $district, $state';
    }
    return '$district, $state';
  }
}

class HospitalRHOAssignment {
  final String? assignedRHOId;
  final String? assignedRHOName;
  final String assignmentType; // 'automatic' or 'manual'
  final DateTime? assignmentDate;
  final bool isActive;

  const HospitalRHOAssignment({
    this.assignedRHOId,
    this.assignedRHOName,
    required this.assignmentType,
    this.assignmentDate,
    required this.isActive,
  });

  factory HospitalRHOAssignment.fromJson(Map<String, dynamic> json) {
    return HospitalRHOAssignment(
      assignedRHOId: json['assignedRHOId'],
      assignedRHOName: json['assignedRHOName'],
      assignmentType: json['assignmentType'] ?? 'automatic',
      assignmentDate: json['assignmentDate'] != null 
          ? DateTime.parse(json['assignmentDate']) 
          : null,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignedRHOId': assignedRHOId,
      'assignedRHOName': assignedRHOName,
      'assignmentType': assignmentType,
      'assignmentDate': assignmentDate?.toIso8601String(),
      'isActive': isActive,
    };
  }

  bool get hasAssignment => assignedRHOId != null && assignedRHOId!.isNotEmpty;
  String get statusText => hasAssignment ? 'Assigned' : 'Unassigned';
  String get typeText => assignmentType == 'manual' ? 'Manual' : 'Automatic';
}

class HospitalLocationInfo {
  final HospitalAddress address;
  final HospitalRHOAssignment rhoAssignment;
  final String? stateCode;
  final String? districtCode;

  const HospitalLocationInfo({
    required this.address,
    required this.rhoAssignment,
    this.stateCode,
    this.districtCode,
  });

  factory HospitalLocationInfo.fromJson(Map<String, dynamic> json) {
    return HospitalLocationInfo(
      address: HospitalAddress.fromJson(json['address'] ?? {}),
      rhoAssignment: HospitalRHOAssignment.fromJson(json['rhoAssignment'] ?? {}),
      stateCode: json['stateCode'],
      districtCode: json['districtCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address.toJson(),
      'rhoAssignment': rhoAssignment.toJson(),
      'stateCode': stateCode,
      'districtCode': districtCode,
    };
  }

  String get fullLocation => address.formattedAddress;
  String get rhoLocationKey => address.locationForRHO;
  bool get hasRHOAssignment => rhoAssignment.hasAssignment;
}

class HospitalBasicInfo {
  final String hospitalId;
  final String hospitalName;
  final String email;
  final String contactNumber;
  final String registrationNumber;
  final String licenseId;
  final String hospitalType;
  final List<String> specialties;
  final int totalBeds;
  final bool emergencyServices;
  final bool ambulanceServices;
  final String? website;
  final int? establishedYear;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HospitalBasicInfo({
    required this.hospitalId,
    required this.hospitalName,
    required this.email,
    required this.contactNumber,
    required this.registrationNumber,
    required this.licenseId,
    required this.hospitalType,
    required this.specialties,
    required this.totalBeds,
    required this.emergencyServices,
    required this.ambulanceServices,
    this.website,
    this.establishedYear,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HospitalBasicInfo.fromJson(Map<String, dynamic> json) {
    return HospitalBasicInfo(
      hospitalId: json['hospitalId'] ?? '',
      hospitalName: json['hospitalName'] ?? '',
      email: json['email'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      registrationNumber: json['registrationNumber'] ?? '',
      licenseId: json['licenseId'] ?? '',
      hospitalType: json['hospitalType'] ?? '',
      specialties: List<String>.from(json['specialties'] ?? []),
      totalBeds: json['totalBeds'] ?? 0,
      emergencyServices: json['emergencyServices'] ?? false,
      ambulanceServices: json['ambulanceServices'] ?? false,
      website: json['website'],
      establishedYear: json['establishedYear'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hospitalId': hospitalId,
      'hospitalName': hospitalName,
      'email': email,
      'contactNumber': contactNumber,
      'registrationNumber': registrationNumber,
      'licenseId': licenseId,
      'hospitalType': hospitalType,
      'specialties': specialties,
      'totalBeds': totalBeds,
      'emergencyServices': emergencyServices,
      'ambulanceServices': ambulanceServices,
      'website': website,
      'establishedYear': establishedYear,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get statusText => isActive ? 'Active' : 'Inactive';
  String get servicesText {
    List<String> services = [];
    if (emergencyServices) services.add('Emergency');
    if (ambulanceServices) services.add('Ambulance');
    return services.isNotEmpty ? services.join(', ') : 'Basic';
  }
  
  String get specialtiesText {
    if (specialties.isEmpty) return 'General';
    if (specialties.length <= 3) return specialties.join(', ');
    return '${specialties.take(2).join(', ')} +${specialties.length - 2} more';
  }
}

class Hospital {
  final HospitalBasicInfo basicInfo;
  final HospitalLocationInfo locationInfo;
  final Map<String, dynamic>? statistics;
  final Map<String, dynamic>? adminDetails;

  const Hospital({
    required this.basicInfo,
    required this.locationInfo,
    this.statistics,
    this.adminDetails,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      basicInfo: HospitalBasicInfo.fromJson(json),
      locationInfo: HospitalLocationInfo.fromJson(json),
      statistics: json['statistics'],
      adminDetails: json['adminDetails'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {
      ...basicInfo.toJson(),
      ...locationInfo.toJson(),
    };
    
    if (statistics != null) result['statistics'] = statistics;
    if (adminDetails != null) result['adminDetails'] = adminDetails;
    
    return result;
  }

  // Getters for easy access
  String get hospitalId => basicInfo.hospitalId;
  String get hospitalName => basicInfo.hospitalName;
  String get hospitalType => basicInfo.hospitalType;
  String get fullAddress => locationInfo.fullLocation;
  String get state => locationInfo.address.state;
  String get district => locationInfo.address.district;
  String? get subDistrict => locationInfo.address.subDistrict;
  String? get assignedRHOId => locationInfo.rhoAssignment.assignedRHOId;
  bool get hasRHOAssignment => locationInfo.hasRHOAssignment;
  bool get isActive => basicInfo.isActive;

  /// Get display name for lists
  String get displayName => '${basicInfo.hospitalName} (${basicInfo.hospitalId})';

  /// Get location summary for RHO assignment
  String get locationSummary => locationInfo.rhoLocationKey;

  /// Check if hospital needs RHO assignment
  bool get needsRHOAssignment => !hasRHOAssignment;

  /// Get RHO assignment status
  String get rhoAssignmentStatus => locationInfo.rhoAssignment.statusText;
}

/// Model for hospital list items (for displaying in lists)
class HospitalListItem {
  final String hospitalId;
  final String hospitalName;
  final String hospitalType;
  final String location;
  final String? assignedRHOId;
  final bool isActive;
  final int totalBeds;
  final bool emergencyServices;

  const HospitalListItem({
    required this.hospitalId,
    required this.hospitalName,
    required this.hospitalType,
    required this.location,
    this.assignedRHOId,
    required this.isActive,
    required this.totalBeds,
    required this.emergencyServices,
  });

  factory HospitalListItem.fromHospital(Hospital hospital) {
    return HospitalListItem(
      hospitalId: hospital.hospitalId,
      hospitalName: hospital.hospitalName,
      hospitalType: hospital.hospitalType,
      location: hospital.locationSummary,
      assignedRHOId: hospital.assignedRHOId,
      isActive: hospital.isActive,
      totalBeds: hospital.basicInfo.totalBeds,
      emergencyServices: hospital.basicInfo.emergencyServices,
    );
  }

  factory HospitalListItem.fromJson(Map<String, dynamic> json) {
    return HospitalListItem(
      hospitalId: json['hospitalId'] ?? '',
      hospitalName: json['hospitalName'] ?? '',
      hospitalType: json['hospitalType'] ?? '',
      location: json['location'] ?? '',
      assignedRHOId: json['assignedRHOId'],
      isActive: json['isActive'] ?? true,
      totalBeds: json['totalBeds'] ?? 0,
      emergencyServices: json['emergencyServices'] ?? false,
    );
  }

  String get statusText => isActive ? 'Active' : 'Inactive';
  String get rhoStatusText => assignedRHOId != null ? 'Assigned' : 'Unassigned';
  String get capacityText => '$totalBeds beds';
  String get servicesText => emergencyServices ? 'Emergency' : 'Standard';
}

/// Hospital registration request model
class HospitalRegistrationRequest {
  final HospitalBasicInfo basicInfo;
  final HospitalAddress address;
  final Map<String, dynamic> adminDetails;
  final String? preferredRHOId;

  const HospitalRegistrationRequest({
    required this.basicInfo,
    required this.address,
    required this.adminDetails,
    this.preferredRHOId,
  });

  Map<String, dynamic> toJson() {
    return {
      'hospitalName': basicInfo.hospitalName,
      'email': basicInfo.email,
      'contactNumber': basicInfo.contactNumber,
      'registrationNumber': basicInfo.registrationNumber,
      'licenseId': basicInfo.licenseId,
      'hospitalType': basicInfo.hospitalType,
      'specialties': basicInfo.specialties,
      'totalBeds': basicInfo.totalBeds,
      'emergencyServices': basicInfo.emergencyServices,
      'ambulanceServices': basicInfo.ambulanceServices,
      'website': basicInfo.website,
      'establishedYear': basicInfo.establishedYear,
      'address': address.toJson(),
      'adminDetails': adminDetails,
      'preferredRHOId': preferredRHOId,
    };
  }
}

/// Hospital search filters
class HospitalSearchFilters {
  final String? state;
  final String? district;
  final String? subDistrict;
  final String? hospitalType;
  final String? assignedRHOId;
  final bool? isActive;
  final bool? hasEmergencyServices;
  final List<String>? specialties;

  const HospitalSearchFilters({
    this.state,
    this.district,
    this.subDistrict,
    this.hospitalType,
    this.assignedRHOId,
    this.isActive,
    this.hasEmergencyServices,
    this.specialties,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> filters = {};
    
    if (state != null) filters['state'] = state;
    if (district != null) filters['district'] = district;
    if (subDistrict != null) filters['subDistrict'] = subDistrict;
    if (hospitalType != null) filters['hospitalType'] = hospitalType;
    if (assignedRHOId != null) filters['assignedRHOId'] = assignedRHOId;
    if (isActive != null) filters['isActive'] = isActive;
    if (hasEmergencyServices != null) filters['hasEmergencyServices'] = hasEmergencyServices;
    if (specialties != null && specialties!.isNotEmpty) filters['specialties'] = specialties;
    
    return filters;
  }

  bool get hasFilters => 
      state != null || 
      district != null || 
      subDistrict != null || 
      hospitalType != null || 
      assignedRHOId != null || 
      isActive != null || 
      hasEmergencyServices != null || 
      (specialties?.isNotEmpty ?? false);
}