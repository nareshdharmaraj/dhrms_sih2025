class WearableData {
  final String id;
  final String patientId;
  final String deviceId;
  final WearableDataType dataType;
  final DateTime timestamp;
  final DateTime hourlyTimestamp;
  final double value;
  final double? secondaryValue;
  final String unit;
  final int quality;
  final WearableDataStatus status;
  final WearableDataMetadata? metadata;
  final bool isProcessed;
  final bool isAggregated;
  final bool triggerAlert;
  final WearableAlertLevel alertLevel;
  final WearableDataSource source;
  final String? syncBatchId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WearableData({
    required this.id,
    required this.patientId,
    required this.deviceId,
    required this.dataType,
    required this.timestamp,
    required this.hourlyTimestamp,
    required this.value,
    this.secondaryValue,
    required this.unit,
    this.quality = 100,
    required this.status,
    this.metadata,
    this.isProcessed = false,
    this.isAggregated = false,
    this.triggerAlert = false,
    this.alertLevel = WearableAlertLevel.none,
    this.source = WearableDataSource.realTime,
    this.syncBatchId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WearableData.fromJson(Map<String, dynamic> json) {
    return WearableData(
      id: json['_id'] ?? json['id'] ?? '',
      patientId: json['patientId'] ?? '',
      deviceId: json['deviceId'] ?? '',
      dataType: WearableDataType.fromString(json['dataType'] ?? ''),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      hourlyTimestamp: DateTime.parse(json['hourlyTimestamp'] ?? DateTime.now().toIso8601String()),
      value: (json['value'] ?? 0).toDouble(),
      secondaryValue: json['secondaryValue']?.toDouble(),
      unit: json['unit'] ?? '',
      quality: json['quality'] ?? 100,
      status: WearableDataStatus.fromString(json['status'] ?? 'normal'),
      metadata: json['metadata'] != null ? WearableDataMetadata.fromJson(json['metadata']) : null,
      isProcessed: json['isProcessed'] ?? false,
      isAggregated: json['isAggregated'] ?? false,
      triggerAlert: json['triggerAlert'] ?? false,
      alertLevel: WearableAlertLevel.fromString(json['alertLevel'] ?? 'none'),
      source: WearableDataSource.fromString(json['source'] ?? 'real_time'),
      syncBatchId: json['syncBatchId'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'deviceId': deviceId,
      'dataType': dataType.value,
      'timestamp': timestamp.toIso8601String(),
      'hourlyTimestamp': hourlyTimestamp.toIso8601String(),
      'value': value,
      'secondaryValue': secondaryValue,
      'unit': unit,
      'quality': quality,
      'status': status.value,
      'metadata': metadata?.toJson(),
      'isProcessed': isProcessed,
      'isAggregated': isAggregated,
      'triggerAlert': triggerAlert,
      'alertLevel': alertLevel.value,
      'source': source.value,
      'syncBatchId': syncBatchId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get formattedValue {
    if (secondaryValue != null) {
      return '${value.toInt()}/${secondaryValue!.toInt()} $unit';
    }
    return '$value $unit';
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }

  bool get isRecent {
    final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));
    return timestamp.isAfter(fiveMinutesAgo);
  }

  bool get isWithinNormalRange {
    return status == WearableDataStatus.normal;
  }
}

class WearableDataMetadata {
  final String? activityType;
  final String? sleepStage;
  final int? ecgDuration;
  final int? ecgSampleRate;
  final String? stressLevel;
  final double? ambientTemperature;
  final double? humidity;
  final int? batteryLevel;
  final int? signalStrength;

  const WearableDataMetadata({
    this.activityType,
    this.sleepStage,
    this.ecgDuration,
    this.ecgSampleRate,
    this.stressLevel,
    this.ambientTemperature,
    this.humidity,
    this.batteryLevel,
    this.signalStrength,
  });

  factory WearableDataMetadata.fromJson(Map<String, dynamic> json) {
    return WearableDataMetadata(
      activityType: json['activityType'],
      sleepStage: json['sleepStage'],
      ecgDuration: json['ecgDuration'],
      ecgSampleRate: json['ecgSampleRate'],
      stressLevel: json['stressLevel'],
      ambientTemperature: json['ambientTemperature']?.toDouble(),
      humidity: json['humidity']?.toDouble(),
      batteryLevel: json['batteryLevel'],
      signalStrength: json['signalStrength'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activityType': activityType,
      'sleepStage': sleepStage,
      'ecgDuration': ecgDuration,
      'ecgSampleRate': ecgSampleRate,
      'stressLevel': stressLevel,
      'ambientTemperature': ambientTemperature,
      'humidity': humidity,
      'batteryLevel': batteryLevel,
      'signalStrength': signalStrength,
    };
  }
}

enum WearableDataType {
  heartRate('heart_rate'),
  bloodPressure('blood_pressure'),
  oxygenSaturation('oxygen_saturation'),
  temperature('temperature'),
  steps('steps'),
  calories('calories'),
  sleep('sleep'),
  ecg('ecg'),
  stress('stress'),
  activity('activity');

  const WearableDataType(this.value);
  final String value;

  static WearableDataType fromString(String value) {
    for (var type in WearableDataType.values) {
      if (type.value == value) return type;
    }
    return WearableDataType.heartRate;
  }

  String get displayName {
    switch (this) {
      case WearableDataType.heartRate:
        return 'Heart Rate';
      case WearableDataType.bloodPressure:
        return 'Blood Pressure';
      case WearableDataType.oxygenSaturation:
        return 'Oxygen Saturation';
      case WearableDataType.temperature:
        return 'Temperature';
      case WearableDataType.steps:
        return 'Steps';
      case WearableDataType.calories:
        return 'Calories';
      case WearableDataType.sleep:
        return 'Sleep';
      case WearableDataType.ecg:
        return 'ECG';
      case WearableDataType.stress:
        return 'Stress';
      case WearableDataType.activity:
        return 'Activity';
    }
  }

  String get defaultUnit {
    switch (this) {
      case WearableDataType.heartRate:
        return 'bpm';
      case WearableDataType.bloodPressure:
        return 'mmHg';
      case WearableDataType.oxygenSaturation:
        return '%';
      case WearableDataType.temperature:
        return '°C';
      case WearableDataType.steps:
        return 'steps';
      case WearableDataType.calories:
        return 'kcal';
      case WearableDataType.sleep:
        return 'hours';
      case WearableDataType.ecg:
        return 'mV';
      case WearableDataType.stress:
        return 'level';
      case WearableDataType.activity:
        return 'minutes';
    }
  }
}

enum WearableDataStatus {
  normal('normal'),
  warning('warning'),
  critical('critical'),
  unknown('unknown');

  const WearableDataStatus(this.value);
  final String value;

  static WearableDataStatus fromString(String value) {
    for (var status in WearableDataStatus.values) {
      if (status.value == value) return status;
    }
    return WearableDataStatus.unknown;
  }

  String get displayName {
    switch (this) {
      case WearableDataStatus.normal:
        return 'Normal';
      case WearableDataStatus.warning:
        return 'Warning';
      case WearableDataStatus.critical:
        return 'Critical';
      case WearableDataStatus.unknown:
        return 'Unknown';
    }
  }
}

enum WearableAlertLevel {
  none('none'),
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

  const WearableAlertLevel(this.value);
  final String value;

  static WearableAlertLevel fromString(String value) {
    for (var level in WearableAlertLevel.values) {
      if (level.value == value) return level;
    }
    return WearableAlertLevel.none;
  }

  String get displayName {
    switch (this) {
      case WearableAlertLevel.none:
        return 'None';
      case WearableAlertLevel.low:
        return 'Low';
      case WearableAlertLevel.medium:
        return 'Medium';
      case WearableAlertLevel.high:
        return 'High';
      case WearableAlertLevel.critical:
        return 'Critical';
    }
  }
}

enum WearableDataSource {
  realTime('real_time'),
  batchSync('batch_sync'),
  manualEntry('manual_entry');

  const WearableDataSource(this.value);
  final String value;

  static WearableDataSource fromString(String value) {
    for (var source in WearableDataSource.values) {
      if (source.value == value) return source;
    }
    return WearableDataSource.realTime;
  }

  String get displayName {
    switch (this) {
      case WearableDataSource.realTime:
        return 'Real-time';
      case WearableDataSource.batchSync:
        return 'Batch Sync';
      case WearableDataSource.manualEntry:
        return 'Manual Entry';
    }
  }
}
