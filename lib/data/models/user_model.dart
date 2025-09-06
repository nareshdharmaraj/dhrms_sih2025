class UserModel {
  final String id;
  final String role;
  final String username;
  final String password;
  final UserProfile profile;

  const UserModel({
    required this.id,
    required this.role,
    required this.username,
    required this.password,
    required this.profile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      role: json['role'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      profile: UserProfile.fromJson(json['profile'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'username': username,
      'password': password,
      'profile': profile.toJson(),
    };
  }

  UserModel copyWith({
    String? id,
    String? role,
    String? username,
    String? password,
    UserProfile? profile,
  }) {
    return UserModel(
      id: id ?? this.id,
      role: role ?? this.role,
      username: username ?? this.username,
      password: password ?? this.password,
      profile: profile ?? this.profile,
    );
  }
}

class UserProfile {
  final String name;
  final String? aadhaarLast4;
  final String? uniqueHealthId;
  final String phone;
  final String? address;
  final String? employer;
  final String? emergencyContact;
  final String? bloodGroup;
  final String? dateOfBirth;
  final String? occupation;
  final String? hospitalName;
  final String? hospitalId;
  final String? licenseNumber;
  final String? department;
  final String? email;
  final String? specialization;
  final String? designation;
  final String? region;
  final String? employeeId;
  final String? officeAddress;

  const UserProfile({
    required this.name,
    this.aadhaarLast4,
    this.uniqueHealthId,
    required this.phone,
    this.address,
    this.employer,
    this.emergencyContact,
    this.bloodGroup,
    this.dateOfBirth,
    this.occupation,
    this.hospitalName,
    this.hospitalId,
    this.licenseNumber,
    this.department,
    this.email,
    this.specialization,
    this.designation,
    this.region,
    this.employeeId,
    this.officeAddress,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      aadhaarLast4: json['aadhaar_last_4'] as String?,
      uniqueHealthId: json['unique_health_id'] as String?,
      phone: json['phone'] as String,
      address: json['address'] as String?,
      employer: json['employer'] as String?,
      emergencyContact: json['emergency_contact'] as String?,
      bloodGroup: json['blood_group'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      occupation: json['occupation'] as String?,
      hospitalName: json['hospital_name'] as String?,
      hospitalId: json['hospital_id'] as String?,
      licenseNumber: json['license_number'] as String?,
      department: json['department'] as String?,
      email: json['email'] as String?,
      specialization: json['specialization'] as String?,
      designation: json['designation'] as String?,
      region: json['region'] as String?,
      employeeId: json['employee_id'] as String?,
      officeAddress: json['office_address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'aadhaar_last_4': aadhaarLast4,
      'unique_health_id': uniqueHealthId,
      'phone': phone,
      'address': address,
      'employer': employer,
      'emergency_contact': emergencyContact,
      'blood_group': bloodGroup,
      'date_of_birth': dateOfBirth,
      'occupation': occupation,
      'hospital_name': hospitalName,
      'hospital_id': hospitalId,
      'license_number': licenseNumber,
      'department': department,
      'email': email,
      'specialization': specialization,
      'designation': designation,
      'region': region,
      'employee_id': employeeId,
      'office_address': officeAddress,
    };
  }

  UserProfile copyWith({
    String? name,
    String? aadhaarLast4,
    String? uniqueHealthId,
    String? phone,
    String? address,
    String? employer,
    String? emergencyContact,
    String? bloodGroup,
    String? dateOfBirth,
    String? occupation,
    String? hospitalName,
    String? hospitalId,
    String? licenseNumber,
    String? department,
    String? email,
    String? specialization,
    String? designation,
    String? region,
    String? employeeId,
    String? officeAddress,
  }) {
    return UserProfile(
      name: name ?? this.name,
      aadhaarLast4: aadhaarLast4 ?? this.aadhaarLast4,
      uniqueHealthId: uniqueHealthId ?? this.uniqueHealthId,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      employer: employer ?? this.employer,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      occupation: occupation ?? this.occupation,
      hospitalName: hospitalName ?? this.hospitalName,
      hospitalId: hospitalId ?? this.hospitalId,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      department: department ?? this.department,
      email: email ?? this.email,
      specialization: specialization ?? this.specialization,
      designation: designation ?? this.designation,
      region: region ?? this.region,
      employeeId: employeeId ?? this.employeeId,
      officeAddress: officeAddress ?? this.officeAddress,
    );
  }
}
