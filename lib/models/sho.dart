class SHO {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String phone;
  final String designation;
  final String assignedState;
  final String licenseNumber;
  final String department;
  final bool isActive;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLogin;

  SHO({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.designation,
    required this.assignedState,
    required this.licenseNumber,
    required this.department,
    this.isActive = true,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.lastLogin,
  });

  factory SHO.fromJson(Map<String, dynamic> json) {
    return SHO(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      designation: json['designation'] ?? '',
      assignedState: json['assignedState'] ?? '',
      licenseNumber: json['licenseNumber'] ?? '',
      department: json['department'] ?? '',
      isActive: json['isActive'] ?? true,
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      lastLogin: json['lastLogin'] != null 
          ? DateTime.parse(json['lastLogin']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'designation': designation,
      'assignedState': assignedState,
      'licenseNumber': licenseNumber,
      'department': department,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'SHO(id: $id, username: $username, fullName: $fullName, assignedState: $assignedState, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SHO &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  // Helper method to get display name
  String get displayName => fullName.isNotEmpty ? fullName : username;

  // Helper method to check if SHO is recently active
  bool get isRecentlyActive {
    if (lastLogin == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastLogin!);
    return difference.inDays <= 30; // Active within last 30 days
  }
}