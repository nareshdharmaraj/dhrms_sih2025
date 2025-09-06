class ProximityAlert {
  final String id;
  final String userId;
  final String alertedUserId;
  final DateTime timestamp;
  final double distance;
  final String location;
  final String? infectionType;
  final String severity; // 'low', 'medium', 'high', 'critical'
  final String status; // 'active', 'acknowledged', 'resolved'
  final String? actionTaken;
  final List<String> notifiedHospitals;

  const ProximityAlert({
    required this.id,
    required this.userId,
    required this.alertedUserId,
    required this.timestamp,
    required this.distance,
    required this.location,
    this.infectionType,
    this.severity = 'medium',
    this.status = 'active',
    this.actionTaken,
    this.notifiedHospitals = const [],
  });

  factory ProximityAlert.fromJson(Map<String, dynamic> json) {
    return ProximityAlert(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      alertedUserId: json['alerted_user_id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      distance: (json['distance'] as num).toDouble(),
      location: json['location'] as String,
      infectionType: json['infection_type'] as String?,
      severity: json['severity'] as String? ?? 'medium',
      status: json['status'] as String? ?? 'active',
      actionTaken: json['action_taken'] as String?,
      notifiedHospitals:
          (json['notified_hospitals'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'alerted_user_id': alertedUserId,
      'timestamp': timestamp.toIso8601String(),
      'distance': distance,
      'location': location,
      'infection_type': infectionType,
      'severity': severity,
      'status': status,
      'action_taken': actionTaken,
      'notified_hospitals': notifiedHospitals,
    };
  }
}

class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String type; // 'hospital', 'ambulance', 'police', 'family'
  final String? address;
  final String? specialization;
  final bool isActive;
  final double? latitude;
  final double? longitude;
  final double? distance;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.type,
    this.address,
    this.specialization,
    this.isActive = true,
    this.latitude,
    this.longitude,
    this.distance,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      type: json['type'] as String,
      address: json['address'] as String?,
      specialization: json['specialization'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distance: (json['distance'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'type': type,
      'address': address,
      'specialization': specialization,
      'is_active': isActive,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
    };
  }
}

class TelemedicineSession {
  final String id;
  final String patientId;
  final String doctorId;
  final String patientName;
  final String doctorName;
  final DateTime scheduledTime;
  final DateTime? actualStartTime;
  final DateTime? endTime;
  final String status; // 'scheduled', 'ongoing', 'completed', 'cancelled'
  final String? meetingLink;
  final String? sessionNotes;
  final String? prescription;
  final List<String> attachments;
  final double? cost;
  final String? paymentStatus;

  const TelemedicineSession({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.patientName,
    required this.doctorName,
    required this.scheduledTime,
    this.actualStartTime,
    this.endTime,
    this.status = 'scheduled',
    this.meetingLink,
    this.sessionNotes,
    this.prescription,
    this.attachments = const [],
    this.cost,
    this.paymentStatus,
  });

  factory TelemedicineSession.fromJson(Map<String, dynamic> json) {
    return TelemedicineSession(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      doctorId: json['doctor_id'] as String,
      patientName: json['patient_name'] as String,
      doctorName: json['doctor_name'] as String,
      scheduledTime: DateTime.parse(json['scheduled_time'] as String),
      actualStartTime: json['actual_start_time'] != null
          ? DateTime.parse(json['actual_start_time'] as String)
          : null,
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      status: json['status'] as String? ?? 'scheduled',
      meetingLink: json['meeting_link'] as String?,
      sessionNotes: json['session_notes'] as String?,
      prescription: json['prescription'] as String?,
      attachments:
          (json['attachments'] as List<dynamic>?)?.cast<String>() ?? [],
      cost: (json['cost'] as num?)?.toDouble(),
      paymentStatus: json['payment_status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'patient_name': patientName,
      'doctor_name': doctorName,
      'scheduled_time': scheduledTime.toIso8601String(),
      'actual_start_time': actualStartTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'status': status,
      'meeting_link': meetingLink,
      'session_notes': sessionNotes,
      'prescription': prescription,
      'attachments': attachments,
      'cost': cost,
      'payment_status': paymentStatus,
    };
  }

  Duration? get duration {
    if (actualStartTime != null && endTime != null) {
      return endTime!.difference(actualStartTime!);
    }
    return null;
  }
}
