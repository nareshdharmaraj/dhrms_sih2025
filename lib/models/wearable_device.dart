class WearableDevice {
  final String id;
  final String patientId;
  final String deviceName;
  final WearableDeviceType deviceType;
  final String manufacturer;
  final String model;
  final String macAddress;
  final String bluetoothId;
  final bool isConnected;
  final int batteryLevel;
  final String? firmwareVersion;
  final List<WearableCapability> capabilities;
  final DateTime lastSyncTime;
  final WearableConnectionStatus connectionStatus;
  final bool autoSync;
  final int syncInterval;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WearableDevice({
    required this.id,
    required this.patientId,
    required this.deviceName,
    required this.deviceType,
    required this.manufacturer,
    required this.model,
    required this.macAddress,
    required this.bluetoothId,
    required this.isConnected,
    required this.batteryLevel,
    this.firmwareVersion,
    required this.capabilities,
    required this.lastSyncTime,
    required this.connectionStatus,
    this.autoSync = true,
    this.syncInterval = 300,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WearableDevice.fromJson(Map<String, dynamic> json) {
    return WearableDevice(
      id: json['_id'] ?? json['id'] ?? '',
      patientId: json['patientId'] ?? '',
      deviceName: json['deviceName'] ?? '',
      deviceType: WearableDeviceType.fromString(json['deviceType'] ?? ''),
      manufacturer: json['manufacturer'] ?? '',
      model: json['model'] ?? '',
      macAddress: json['macAddress'] ?? '',
      bluetoothId: json['bluetoothId'] ?? '',
      isConnected: json['isConnected'] ?? false,
      batteryLevel: json['batteryLevel'] ?? 0,
      firmwareVersion: json['firmwareVersion'],
      capabilities: (json['capabilities'] as List<dynamic>? ?? [])
          .map((cap) => WearableCapability.fromString(cap.toString()))
          .toList(),
      lastSyncTime: DateTime.parse(json['lastSyncTime'] ?? DateTime.now().toIso8601String()),
      connectionStatus: WearableConnectionStatus.fromString(json['connectionStatus'] ?? 'disconnected'),
      autoSync: json['autoSync'] ?? true,
      syncInterval: json['syncInterval'] ?? 300,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'deviceName': deviceName,
      'deviceType': deviceType.value,
      'manufacturer': manufacturer,
      'model': model,
      'macAddress': macAddress,
      'bluetoothId': bluetoothId,
      'isConnected': isConnected,
      'batteryLevel': batteryLevel,
      'firmwareVersion': firmwareVersion,
      'capabilities': capabilities.map((cap) => cap.value).toList(),
      'lastSyncTime': lastSyncTime.toIso8601String(),
      'connectionStatus': connectionStatus.value,
      'autoSync': autoSync,
      'syncInterval': syncInterval,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  WearableDevice copyWith({
    String? id,
    String? patientId,
    String? deviceName,
    WearableDeviceType? deviceType,
    String? manufacturer,
    String? model,
    String? macAddress,
    String? bluetoothId,
    bool? isConnected,
    int? batteryLevel,
    String? firmwareVersion,
    List<WearableCapability>? capabilities,
    DateTime? lastSyncTime,
    WearableConnectionStatus? connectionStatus,
    bool? autoSync,
    int? syncInterval,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WearableDevice(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      macAddress: macAddress ?? this.macAddress,
      bluetoothId: bluetoothId ?? this.bluetoothId,
      isConnected: isConnected ?? this.isConnected,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      capabilities: capabilities ?? this.capabilities,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      autoSync: autoSync ?? this.autoSync,
      syncInterval: syncInterval ?? this.syncInterval,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOnline {
    final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));
    return isConnected && lastSyncTime.isAfter(fiveMinutesAgo);
  }

  String get batteryStatus {
    if (batteryLevel > 50) return 'good';
    if (batteryLevel > 20) return 'medium';
    return 'low';
  }

  bool supportsCapability(WearableCapability capability) {
    return capabilities.contains(capability);
  }
}

enum WearableDeviceType {
  smartwatch('smartwatch'),
  fitnessBand('fitness_band'),
  heartMonitor('heart_monitor'),
  bloodPressureMonitor('blood_pressure_monitor'),
  pulseOximeter('pulse_oximeter');

  const WearableDeviceType(this.value);
  final String value;

  static WearableDeviceType fromString(String value) {
    for (var type in WearableDeviceType.values) {
      if (type.value == value) return type;
    }
    return WearableDeviceType.smartwatch;
  }

  String get displayName {
    switch (this) {
      case WearableDeviceType.smartwatch:
        return 'Smart Watch';
      case WearableDeviceType.fitnessBand:
        return 'Fitness Band';
      case WearableDeviceType.heartMonitor:
        return 'Heart Monitor';
      case WearableDeviceType.bloodPressureMonitor:
        return 'Blood Pressure Monitor';
      case WearableDeviceType.pulseOximeter:
        return 'Pulse Oximeter';
    }
  }
}

enum WearableCapability {
  heartRate('heart_rate'),
  bloodPressure('blood_pressure'),
  oxygenSaturation('oxygen_saturation'),
  temperature('temperature'),
  steps('steps'),
  calories('calories'),
  sleep('sleep'),
  ecg('ecg'),
  stress('stress');

  const WearableCapability(this.value);
  final String value;

  static WearableCapability fromString(String value) {
    for (var capability in WearableCapability.values) {
      if (capability.value == value) return capability;
    }
    return WearableCapability.heartRate;
  }

  String get displayName {
    switch (this) {
      case WearableCapability.heartRate:
        return 'Heart Rate';
      case WearableCapability.bloodPressure:
        return 'Blood Pressure';
      case WearableCapability.oxygenSaturation:
        return 'Oxygen Saturation';
      case WearableCapability.temperature:
        return 'Temperature';
      case WearableCapability.steps:
        return 'Steps';
      case WearableCapability.calories:
        return 'Calories';
      case WearableCapability.sleep:
        return 'Sleep';
      case WearableCapability.ecg:
        return 'ECG';
      case WearableCapability.stress:
        return 'Stress';
    }
  }
}

enum WearableConnectionStatus {
  connected('connected'),
  disconnected('disconnected'),
  syncing('syncing'),
  error('error');

  const WearableConnectionStatus(this.value);
  final String value;

  static WearableConnectionStatus fromString(String value) {
    for (var status in WearableConnectionStatus.values) {
      if (status.value == value) return status;
    }
    return WearableConnectionStatus.disconnected;
  }

  String get displayName {
    switch (this) {
      case WearableConnectionStatus.connected:
        return 'Connected';
      case WearableConnectionStatus.disconnected:
        return 'Disconnected';
      case WearableConnectionStatus.syncing:
        return 'Syncing';
      case WearableConnectionStatus.error:
        return 'Error';
    }
  }
}
