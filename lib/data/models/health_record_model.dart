class HealthRecord {
  final String id;
  final String patientId;
  final String patientName;
  final String? doctorId;
  final String? doctorName;
  final String? hospitalId;
  final String? hospitalName;
  final DateTime date;
  final String
  type; // 'checkup', 'test', 'prescription', 'vaccination', 'emergency'
  final String? diagnosis;
  final String? symptoms;
  final String? treatment;
  final List<String> medications;
  final List<TestResult> testResults;
  final List<String> attachments;
  final VitalSigns? vitals;
  final String status; // 'active', 'completed', 'cancelled'
  final String? notes;
  final double? cost;
  final String? insuranceClaimId;

  const HealthRecord({
    required this.id,
    required this.patientId,
    required this.patientName,
    this.doctorId,
    this.doctorName,
    this.hospitalId,
    this.hospitalName,
    required this.date,
    required this.type,
    this.diagnosis,
    this.symptoms,
    this.treatment,
    this.medications = const [],
    this.testResults = const [],
    this.attachments = const [],
    this.vitals,
    this.status = 'active',
    this.notes,
    this.cost,
    this.insuranceClaimId,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      patientName: json['patient_name'] as String,
      doctorId: json['doctor_id'] as String?,
      doctorName: json['doctor_name'] as String?,
      hospitalId: json['hospital_id'] as String?,
      hospitalName: json['hospital_name'] as String?,
      date: DateTime.parse(json['date'] as String),
      type: json['type'] as String,
      diagnosis: json['diagnosis'] as String?,
      symptoms: json['symptoms'] as String?,
      treatment: json['treatment'] as String?,
      medications:
          (json['medications'] as List<dynamic>?)?.cast<String>() ?? [],
      testResults:
          (json['test_results'] as List<dynamic>?)
              ?.map((e) => TestResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      attachments:
          (json['attachments'] as List<dynamic>?)?.cast<String>() ?? [],
      vitals: json['vitals'] != null
          ? VitalSigns.fromJson(json['vitals'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String? ?? 'active',
      notes: json['notes'] as String?,
      cost: (json['cost'] as num?)?.toDouble(),
      insuranceClaimId: json['insurance_claim_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'patient_name': patientName,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'hospital_id': hospitalId,
      'hospital_name': hospitalName,
      'date': date.toIso8601String(),
      'type': type,
      'diagnosis': diagnosis,
      'symptoms': symptoms,
      'treatment': treatment,
      'medications': medications,
      'test_results': testResults.map((e) => e.toJson()).toList(),
      'attachments': attachments,
      'vitals': vitals?.toJson(),
      'status': status,
      'notes': notes,
      'cost': cost,
      'insurance_claim_id': insuranceClaimId,
    };
  }
}

class TestResult {
  final String name;
  final String value;
  final String unit;
  final String? normalRange;
  final bool isNormal;
  final String? notes;

  const TestResult({
    required this.name,
    required this.value,
    required this.unit,
    this.normalRange,
    this.isNormal = true,
    this.notes,
  });

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      name: json['name'] as String,
      value: json['value'] as String,
      unit: json['unit'] as String,
      normalRange: json['normal_range'] as String?,
      isNormal: json['is_normal'] as bool? ?? true,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'unit': unit,
      'normal_range': normalRange,
      'is_normal': isNormal,
      'notes': notes,
    };
  }
}

class VitalSigns {
  final double? heartRate;
  final double? systolicBP;
  final double? diastolicBP;
  final double? oxygenSaturation;
  final double? bodyTemperature;
  final double? bloodSugar;
  final double? weight;
  final double? height;
  final DateTime timestamp;

  const VitalSigns({
    this.heartRate,
    this.systolicBP,
    this.diastolicBP,
    this.oxygenSaturation,
    this.bodyTemperature,
    this.bloodSugar,
    this.weight,
    this.height,
    required this.timestamp,
  });

  factory VitalSigns.fromJson(Map<String, dynamic> json) {
    return VitalSigns(
      heartRate: (json['heart_rate'] as num?)?.toDouble(),
      systolicBP: (json['systolic_bp'] as num?)?.toDouble(),
      diastolicBP: (json['diastolic_bp'] as num?)?.toDouble(),
      oxygenSaturation: (json['oxygen_saturation'] as num?)?.toDouble(),
      bodyTemperature: (json['body_temperature'] as num?)?.toDouble(),
      bloodSugar: (json['blood_sugar'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heart_rate': heartRate,
      'systolic_bp': systolicBP,
      'diastolic_bp': diastolicBP,
      'oxygen_saturation': oxygenSaturation,
      'body_temperature': bodyTemperature,
      'blood_sugar': bloodSugar,
      'weight': weight,
      'height': height,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool get hasAbnormalVitals {
    if (heartRate != null && (heartRate! < 60 || heartRate! > 100)) return true;
    if (systolicBP != null && (systolicBP! < 90 || systolicBP! > 140)) {
      return true;
    }
    if (diastolicBP != null && (diastolicBP! < 60 || diastolicBP! > 90)) {
      return true;
    }
    if (oxygenSaturation != null && oxygenSaturation! < 95) return true;
    if (bodyTemperature != null &&
        (bodyTemperature! < 36.1 || bodyTemperature! > 37.2)) {
      return true;
    }
    return false;
  }
}
