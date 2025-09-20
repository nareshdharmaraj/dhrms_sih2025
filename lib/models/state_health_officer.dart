class StateHealthOfficer {
  final String id;
  final String officerId;
  final String fullName;
  final String email;
  final String phone;
  final String assignedState;
  final Map<String, dynamic> permissions;
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;

  StateHealthOfficer({
    required this.id,
    required this.officerId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.assignedState,
    required this.permissions,
    this.isActive = true,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StateHealthOfficer.fromJson(Map<String, dynamic> json) {
    return StateHealthOfficer(
      id: json['_id'] ?? json['id'] ?? '',
      officerId: json['officerId'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      assignedState: json['assignedState'] ?? '',
      permissions: Map<String, dynamic>.from(json['permissions'] ?? {}),
      isActive: json['isActive'] ?? true,
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'officerId': officerId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'assignedState': assignedState,
      'permissions': permissions,
      'isActive': isActive,
      'lastLogin': lastLogin?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Get formatted officer ID for display
  String get formattedOfficerId => officerId;

  // Get status text
  String get statusText => isActive ? 'Active' : 'Inactive';

  @override
  String toString() {
    return 'StateHealthOfficer(id: $id, officerId: $officerId, fullName: $fullName)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StateHealthOfficer &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class SHOStatistics {
  final int total;
  final int active;
  final int inactive;
  final Map<String, int> byState;

  SHOStatistics({
    required this.total,
    required this.active,
    required this.inactive,
    this.byState = const {},
  });

  factory SHOStatistics.fromJson(Map<String, dynamic> json) {
    return SHOStatistics(
      total: json['total'] ?? 0,
      active: json['active'] ?? 0,
      inactive: json['inactive'] ?? 0,
      byState: Map<String, int>.from(json['byState'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'active': active,
      'inactive': inactive,
      'byState': byState,
    };
  }
}