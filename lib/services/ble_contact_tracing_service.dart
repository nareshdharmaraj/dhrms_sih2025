import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'infected_ids_manager.dart';
import 'ble_notification_service.dart';
import '../utils/ble_utils.dart';

// Conditional imports for mobile-only packages
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart'
    if (dart.library.html) 'ble_contact_tracing_web_stub.dart';
import 'package:permission_handler/permission_handler.dart'
    if (dart.library.html) 'ble_contact_tracing_web_stub.dart';

/// Main BLE Contact Tracing Service
/// Handles BLE scanning, broadcasting, and proximity alerts for disease detection
class BLEContactTracingService {
  static final BLEContactTracingService _instance =
      BLEContactTracingService._internal();
  factory BLEContactTracingService() => _instance;
  BLEContactTracingService._internal();

  final FlutterReactiveBle _ble = FlutterReactiveBle();
  final InfectedIDsManager _infectedIDsManager = InfectedIDsManager();
  final BLENotificationService _notificationService = BLENotificationService();

  // Service configuration
  static const String _serviceUUID = '0000180F-0000-1000-8000-00805F9B34FB';
  static const int _proximityThreshold = -60; // RSSI threshold for ~2 meters
  static const int _alertCooldownMinutes =
      15; // Cooldown between alerts for same ID

  // State management
  bool _isInitialized = false;
  bool _isScanning = false;
  bool _isBroadcasting = false;
  String? _deviceId;
  Timer? _scanTimer;
  Timer? _infectedIDsUpdateTimer;

  // Caching for detected devices and alerts
  final Map<String, DateTime> _recentAlerts = {};
  final Map<String, DetectedDevice> _detectedDevices = {};

  // Stream controllers
  final StreamController<DetectedDevice> _deviceDetectedController =
      StreamController<DetectedDevice>.broadcast();
  final StreamController<ProximityAlert> _alertController =
      StreamController<ProximityAlert>.broadcast();
  final StreamController<BLEServiceStatus> _statusController =
      StreamController<BLEServiceStatus>.broadcast();

  // Public streams
  Stream<DetectedDevice> get deviceDetectedStream =>
      _deviceDetectedController.stream;
  Stream<ProximityAlert> get alertStream => _alertController.stream;
  Stream<BLEServiceStatus> get statusStream => _statusController.stream;

  /// Initialize the BLE Contact Tracing Service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _updateStatus(BLEServiceStatus.initializing);

      // Initialize notification service
      await _notificationService.initialize();

      // On web, BLE is not supported - only show notification
      if (kIsWeb) {
        debugPrint('⚠️ BLE not supported on web platform');
        await _initializeDeviceId();
        await _infectedIDsManager.initialize();
        _startInfectedIDsUpdateTimer();
        _isInitialized = true;
        _updateStatus(BLEServiceStatus.ready);
        return true;
      }

      // Check and request permissions (mobile only)
      if (!await _checkPermissions()) {
        _updateStatus(BLEServiceStatus.permissionDenied);
        return false;
      }

      // Generate or retrieve device ID
      await _initializeDeviceId();

      // Initialize infected IDs manager
      await _infectedIDsManager.initialize();

      // Start periodic infected IDs update
      _startInfectedIDsUpdateTimer();

      _isInitialized = true;
      _updateStatus(BLEServiceStatus.ready);

      debugPrint('✅ BLE Contact Tracing Service initialized successfully');
      return true;
    } catch (e) {
      debugPrint('❌ BLE Contact Tracing Service initialization failed: $e');
      _updateStatus(BLEServiceStatus.error);
      return false;
    }
  }

  /// Start contact tracing (scanning + broadcasting)
  Future<bool> startContactTracing() async {
    if (!_isInitialized) {
      debugPrint('⚠️ Service not initialized. Call initialize() first.');
      return false;
    }

    try {
      _updateStatus(BLEServiceStatus.starting);

      // On web, simulate contact tracing without BLE
      if (kIsWeb) {
        debugPrint('🌐 Simulating contact tracing on web platform');
        _updateStatus(BLEServiceStatus.active);
        return true;
      }

      // Start scanning for nearby devices (mobile only)
      await startScanning();

      // Start broadcasting device ID (mobile only)
      await startBroadcasting();

      _updateStatus(BLEServiceStatus.active);
      debugPrint('✅ Contact tracing started successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to start contact tracing: $e');
      _updateStatus(BLEServiceStatus.error);
      return false;
    }
  }

  /// Stop contact tracing
  Future<void> stopContactTracing() async {
    await stopScanning();
    await stopBroadcasting();
    _updateStatus(BLEServiceStatus.stopped);
    debugPrint('🛑 Contact tracing stopped');
  }

  /// Start BLE scanning for nearby devices
  Future<void> startScanning() async {
    if (_isScanning) return;
    if (kIsWeb) return; // Skip BLE operations on web

    try {
      _isScanning = true;

      _scanTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        await _performScan();
      });

      debugPrint('📡 BLE scanning started');
    } catch (e) {
      debugPrint('❌ Failed to start scanning: $e');
      _isScanning = false;
    }
  }

  /// Stop BLE scanning
  Future<void> stopScanning() async {
    _scanTimer?.cancel();
    _scanTimer = null;
    _isScanning = false;
    debugPrint('📡 BLE scanning stopped');
  }

  /// Start BLE broadcasting
  Future<void> startBroadcasting() async {
    if (_isBroadcasting || _deviceId == null) return;
    if (kIsWeb) return; // Skip BLE operations on web

    try {
      // Note: BLE advertising in Flutter is limited
      // This is a placeholder for actual BLE advertising implementation
      // In practice, you might need to use platform-specific code

      _isBroadcasting = true;
      debugPrint('📢 BLE broadcasting started with ID: $_deviceId');
    } catch (e) {
      debugPrint('❌ Failed to start broadcasting: $e');
      _isBroadcasting = false;
    }
  }

  /// Stop BLE broadcasting
  Future<void> stopBroadcasting() async {
    _isBroadcasting = false;
    debugPrint('📢 BLE broadcasting stopped');
  }

  /// Perform a single BLE scan
  Future<void> _performScan() async {
    if (kIsWeb) return; // Skip BLE operations on web

    try {
      final scanStream = _ble.scanForDevices(
        withServices: [Uuid.parse(_serviceUUID)],
        scanMode: ScanMode.lowLatency,
      );

      final subscription = scanStream.listen(
        (device) => _handleDetectedDevice(device),
        onError: (error) => debugPrint('❌ Scan error: $error'),
      );

      // Scan for 3 seconds
      await Future.delayed(const Duration(seconds: 3));
      await subscription.cancel();
    } catch (e) {
      debugPrint('❌ Scan failed: $e');
    }
  }

  /// Handle detected BLE device
  void _handleDetectedDevice(DiscoveredDevice device) {
    if (device.serviceData.isEmpty) return;

    try {
      // Extract device ID from service data
      final serviceData = device.serviceData[Uuid.parse(_serviceUUID)];
      if (serviceData == null || serviceData.isEmpty) return;

      final deviceId = utf8.decode(serviceData);
      final rssi = device.rssi;

      // Check if device is close enough (within ~2 meters)
      if (rssi < _proximityThreshold) return;

      final detectedDevice = DetectedDevice(
        deviceId: deviceId,
        rssi: rssi,
        timestamp: DateTime.now(),
        estimatedDistance: BLEUtils.calculateDistance(rssi),
      );

      _detectedDevices[deviceId] = detectedDevice;
      _deviceDetectedController.add(detectedDevice);

      // Check if this device ID is infected
      _checkForInfectedDevice(detectedDevice);
    } catch (e) {
      debugPrint('❌ Error handling detected device: $e');
    }
  }

  /// Check if detected device is infected and trigger alert
  void _checkForInfectedDevice(DetectedDevice device) {
    if (!_infectedIDsManager.isInfected(device.deviceId)) return;

    // Check alert cooldown
    final lastAlert = _recentAlerts[device.deviceId];
    if (lastAlert != null) {
      final cooldown = DateTime.now().difference(lastAlert);
      if (cooldown.inMinutes < _alertCooldownMinutes) return;
    }

    // Trigger proximity alert
    final alert = ProximityAlert(
      infectedDeviceId: device.deviceId,
      detectedDevice: device,
      timestamp: DateTime.now(),
      riskLevel: _calculateRiskLevel(device),
    );

    _recentAlerts[device.deviceId] = DateTime.now();
    _alertController.add(alert);
    _notificationService.showProximityAlert(alert);

    debugPrint(
      '🚨 PROXIMITY ALERT: Infected device detected - ID: ${device.deviceId}, Distance: ${device.estimatedDistance.toStringAsFixed(1)}m',
    );
  }

  /// Calculate risk level based on proximity and duration
  RiskLevel _calculateRiskLevel(DetectedDevice device) {
    if (device.estimatedDistance <= 1.0) return RiskLevel.high;
    if (device.estimatedDistance <= 1.5) return RiskLevel.medium;
    return RiskLevel.low;
  }

  /// Check and request necessary permissions
  Future<bool> _checkPermissions() async {
    if (kIsWeb) return true; // No BLE permissions needed on web

    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.locationWhenInUse,
      Permission.notification,
    ];

    for (final permission in permissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        final result = await permission.request();
        if (!result.isGranted) {
          debugPrint('❌ Permission denied: $permission');
          return false;
        }
      }
    }

    return true;
  }

  /// Initialize or retrieve device ID
  Future<void> _initializeDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString('ble_device_id');

    if (_deviceId == null) {
      // Generate anonymized device ID
      _deviceId = BLEUtils.generateAnonymizedId();
      await prefs.setString('ble_device_id', _deviceId!);
    }

    debugPrint('📱 Device ID: $_deviceId');
  }

  /// Start timer for periodic infected IDs updates
  void _startInfectedIDsUpdateTimer() {
    _infectedIDsUpdateTimer = Timer.periodic(
      const Duration(minutes: 5),
      (timer) => _infectedIDsManager.fetchInfectedIDs(),
    );
  }

  /// Update service status
  void _updateStatus(BLEServiceStatus status) {
    _statusController.add(status);
  }

  /// Get current status
  bool get isInitialized => _isInitialized;
  bool get isScanning => _isScanning;
  bool get isBroadcasting => _isBroadcasting;
  String? get deviceId => _deviceId;

  /// Get detected devices
  List<DetectedDevice> get detectedDevices => _detectedDevices.values.toList();

  /// Get recent alerts
  List<String> get recentAlertDeviceIds => _recentAlerts.keys.toList();

  /// Dispose resources
  void dispose() {
    _scanTimer?.cancel();
    _infectedIDsUpdateTimer?.cancel();
    _deviceDetectedController.close();
    _alertController.close();
    _statusController.close();
    _infectedIDsManager.dispose();
  }
}

/// Detected BLE device model
class DetectedDevice {
  final String deviceId;
  final int rssi;
  final DateTime timestamp;
  final double estimatedDistance;

  DetectedDevice({
    required this.deviceId,
    required this.rssi,
    required this.timestamp,
    required this.estimatedDistance,
  });

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'rssi': rssi,
    'timestamp': timestamp.toIso8601String(),
    'estimatedDistance': estimatedDistance,
  };
}

/// Proximity alert model
class ProximityAlert {
  final String infectedDeviceId;
  final DetectedDevice detectedDevice;
  final DateTime timestamp;
  final RiskLevel riskLevel;

  ProximityAlert({
    required this.infectedDeviceId,
    required this.detectedDevice,
    required this.timestamp,
    required this.riskLevel,
  });

  Map<String, dynamic> toJson() => {
    'infectedDeviceId': infectedDeviceId,
    'detectedDevice': detectedDevice.toJson(),
    'timestamp': timestamp.toIso8601String(),
    'riskLevel': riskLevel.name,
  };
}

/// Risk level enumeration
enum RiskLevel { low, medium, high }

/// BLE service status enumeration
enum BLEServiceStatus {
  uninitialized,
  initializing,
  ready,
  starting,
  active,
  stopped,
  permissionDenied,
  error,
}
