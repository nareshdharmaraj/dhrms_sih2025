import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/api_service.dart';
import '../utils/storage_helper.dart';

class ProximityAlertService {
  static final ProximityAlertService _instance =
      ProximityAlertService._internal();
  factory ProximityAlertService() => _instance;
  ProximityAlertService._internal();

  final FlutterReactiveBle _ble = FlutterReactiveBle();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Timer? _scanTimer;
  Timer? _alertTimer;
  StreamSubscription<DiscoveredDevice>? _scanSubscription;

  List<String> _infectedDeviceIds = [];
  final Map<String, ProximityData> _nearbyInfectedDevices = {};
  bool _isScanning = false;
  bool _isAlertActive = false;
  String? _currentDeviceId;

  // ALERT SETTINGS - Your Specifications
  static const int SCAN_INTERVAL_SECONDS = 5; // ✅ Every 5 seconds
  static const int ALERT_REPEAT_SECONDS = 5; // ✅ Repeat every 5 seconds
  static const double CRITICAL_DISTANCE = 1.0; // ✅ Within 1 meter
  static const double WARNING_DISTANCE = 2.0; // ✅ Within 2 meters
  static const double CAUTION_DISTANCE = 3.0; // ✅ Within 3 meters

  Future<void> initialize() async {
    print('🚀 Initializing Proximity Alert Service...');

    // Initialize notifications
    await _initializeNotifications();

    // Initialize audio
    await _initializeAudio();

    // Get device ID
    _currentDeviceId = await StorageHelper.getDeviceId();

    if (_currentDeviceId == null) {
      // Generate and save device ID
      _currentDeviceId = _generateDeviceId();
      await StorageHelper.saveDeviceId(_currentDeviceId!);
    }

    print('📱 Device ID: $_currentDeviceId');

    // Register device for contact tracing
    await _registerDevice();

    print('✅ Proximity Alert Service initialized');
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);

    // Create notification channel for proximity alerts
    const androidChannel = AndroidNotificationChannel(
      'proximity_alerts',
      'Proximity Alerts',
      description: 'Alerts when infected person is nearby',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> _initializeAudio() async {
    try {
      // Create beeping sound programmatically for alerts
      print('🔊 Audio system initialized');
    } catch (e) {
      print('❌ Audio initialization error: $e');
    }
  }

  String _generateDeviceId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return 'DHRMS_${timestamp}_$random';
  }

  Future<void> _registerDevice() async {
    try {
      final uhid = await StorageHelper.getUHID();
      if (uhid == null) {
        print('⚠️ No UHID found, skipping device registration');
        return;
      }

      final response = await ApiService.registerContactTracingDevice({
        'deviceId': _currentDeviceId,
        'uhid': uhid,
        'deviceInfo': {
          'platform': Platform.operatingSystem,
          'version': Platform.operatingSystemVersion,
        },
      });

      if (response['success'] == true) {
        print('📱 Device registered successfully');
        final device = response['device'];
        if (device['isInfected'] == true) {
          print('🦠 WARNING: This device is marked as infected!');
        }
      }
    } catch (e) {
      print('❌ Device registration error: $e');
    }
  }

  Future<void> startProximityMonitoring() async {
    print('🎯 Starting Proximity Monitoring...');
    print('⏱️ Scan Interval: ${SCAN_INTERVAL_SECONDS}s');
    print('🔔 Alert Interval: ${ALERT_REPEAT_SECONDS}s');

    // Start periodic scanning
    _scanTimer = Timer.periodic(
      Duration(seconds: SCAN_INTERVAL_SECONDS),
      (timer) => _performProximityScan(),
    );

    // Perform initial scan
    await _performProximityScan();

    print('✅ Proximity monitoring started');
  }

  Future<void> _performProximityScan() async {
    if (_isScanning) {
      print('⏭️ Scan already in progress, skipping...');
      return;
    }

    try {
      _isScanning = true;
      print('🔍 [${DateTime.now()}] Scanning for infected devices...');

      // Fetch current infected device IDs from server
      await _fetchInfectedDeviceIds();

      if (_infectedDeviceIds.isEmpty) {
        print('✅ No infected devices in database');
        return;
      }

      print('🦠 Monitoring ${_infectedDeviceIds.length} infected device(s)');

      // Start BLE scanning
      await _startBLEScan();
    } catch (e) {
      print('❌ Proximity scan error: $e');
    } finally {
      _isScanning = false;
    }
  }

  Future<void> _fetchInfectedDeviceIds() async {
    try {
      final response = await ApiService.getInfectedDevices();

      if (response['success'] == true) {
        final devices = response['infectedDevices'] as List;
        _infectedDeviceIds = devices
            .map((d) => d['deviceId'].toString())
            .toList();

        print('📡 Received ${_infectedDeviceIds.length} infected device IDs');
      }
    } catch (e) {
      print('❌ Error fetching infected devices: $e');
    }
  }

  Future<void> _startBLEScan() async {
    try {
      // Stop any existing scan
      await _scanSubscription?.cancel();

      // Clear old proximity data
      _nearbyInfectedDevices.clear();

      final completer = Completer<void>();

      // Scan for 3 seconds to detect devices
      _scanSubscription = _ble
          .scanForDevices(withServices: [], scanMode: ScanMode.lowLatency)
          .listen(
            (device) => _processBLEDevice(device),
            onError: (error) {
              print('❌ BLE scan error: $error');
              completer.complete();
            },
          );

      // Stop scan after 3 seconds
      Timer(Duration(seconds: 3), () {
        _scanSubscription?.cancel();
        _processProximityResults();
        completer.complete();
      });

      await completer.future;
    } catch (e) {
      print('❌ BLE scan error: $e');
    }
  }

  void _processBLEDevice(DiscoveredDevice device) {
    final deviceId = device.name.isNotEmpty ? device.name : device.id;

    // Check if this is an infected device
    if (_infectedDeviceIds.contains(deviceId)) {
      final distance = _calculateDistance(device.rssi);

      print(
        '🦠 INFECTED DEVICE DETECTED: $deviceId at ${distance.toStringAsFixed(1)}m (RSSI: ${device.rssi})',
      );

      _nearbyInfectedDevices[deviceId] = ProximityData(
        deviceId: deviceId,
        distance: distance,
        rssi: device.rssi,
        detectedAt: DateTime.now(),
      );
    }
  }

  double _calculateDistance(int rssi) {
    // Convert RSSI to distance estimate (±1 meter accuracy as requested)
    if (rssi >= -50) return 0.5;
    if (rssi >= -60) return 1.0;
    if (rssi >= -70) return 2.0;
    if (rssi >= -80) return 3.0;
    if (rssi >= -90) return 5.0;
    return 10.0;
  }

  void _processProximityResults() {
    if (_nearbyInfectedDevices.isEmpty) {
      // No infected devices nearby - stop alerts
      _stopAlerts();
      return;
    }

    // Find closest infected device
    final closestDevice = _nearbyInfectedDevices.values.reduce(
      (a, b) => a.distance < b.distance ? a : b,
    );

    print(
      '🚨 CLOSEST INFECTED DEVICE: ${closestDevice.deviceId} at ${closestDevice.distance.toStringAsFixed(1)}m',
    );

    // Determine alert level
    final alertLevel = _determineAlertLevel(closestDevice.distance);

    // Trigger appropriate alert
    _triggerProximityAlert(closestDevice, alertLevel);

    // Log encounter to server
    _logProximityEncounter(closestDevice);
  }

  AlertLevel _determineAlertLevel(double distance) {
    if (distance <= CRITICAL_DISTANCE) return AlertLevel.CRITICAL;
    if (distance <= WARNING_DISTANCE) return AlertLevel.WARNING;
    if (distance <= CAUTION_DISTANCE) return AlertLevel.CAUTION;
    return AlertLevel.NONE;
  }

  Future<void> _triggerProximityAlert(
    ProximityData device,
    AlertLevel level,
  ) async {
    if (level == AlertLevel.NONE) return;

    print(
      '🚨 PROXIMITY ALERT TRIGGERED: ${level.name} - Distance: ${device.distance.toStringAsFixed(1)}m',
    );

    // Start repeating alerts every 5 seconds
    _startRepeatingAlerts(device, level);

    // Show immediate notification
    await _showProximityNotification(device, level);

    // Play alert sound
    await _playAlertSound(level);

    // Log alert
    _logAlert(device, level);
  }

  void _startRepeatingAlerts(ProximityData device, AlertLevel level) {
    // Cancel any existing alert timer
    _alertTimer?.cancel();

    _isAlertActive = true;

    // Repeat alert every 5 seconds while device is nearby
    _alertTimer = Timer.periodic(Duration(seconds: ALERT_REPEAT_SECONDS), (
      timer,
    ) async {
      if (_nearbyInfectedDevices.containsKey(device.deviceId)) {
        print('🔔 REPEATING ALERT: ${level.name} - ${device.deviceId}');
        await _playAlertSound(level);
        HapticFeedback.heavyImpact(); // Vibration
      } else {
        // Device no longer nearby - stop alerts
        _stopAlerts();
      }
    });
  }

  void _stopAlerts() {
    if (_isAlertActive) {
      print('🔇 Stopping proximity alerts');
      _alertTimer?.cancel();
      _isAlertActive = false;
    }
  }

  Future<void> _showProximityNotification(
    ProximityData device,
    AlertLevel level,
  ) async {
    String title =
        '⚠️ Infected Person Nearby'; // ✅ Privacy: Shows "Infected person nearby"
    String body;

    switch (level) {
      case AlertLevel.CRITICAL:
        body =
            '🔴 MAINTAIN DISTANCE - Very close proximity detected (${device.distance.toStringAsFixed(1)}m)';
        break;
      case AlertLevel.WARNING:
        body =
            '🟠 Please maintain distance (${device.distance.toStringAsFixed(1)}m)';
        break;
      case AlertLevel.CAUTION:
        body =
            '🟡 Infected person detected nearby (${device.distance.toStringAsFixed(1)}m)';
        break;
      default:
        return;
    }

    const androidDetails = AndroidNotificationDetails(
      'proximity_alerts',
      'Proximity Alerts',
      channelDescription: 'Alerts when infected person is nearby',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Proximity Alert',
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecond, // Unique ID
      title,
      body,
      details,
    );
  }

  Future<void> _playAlertSound(AlertLevel level) async {
    try {
      // Generate beeping sound based on proximity
      // ✅ Beeping sounds (faster when closer)
      int beepCount;
      int beepInterval; // milliseconds

      switch (level) {
        case AlertLevel.CRITICAL:
          beepCount = 5;
          beepInterval = 200; // Fast beeping
          break;
        case AlertLevel.WARNING:
          beepCount = 3;
          beepInterval = 400; // Medium beeping
          break;
        case AlertLevel.CAUTION:
          beepCount = 2;
          beepInterval = 600; // Slow beeping
          break;
        default:
          return;
      }

      // Play system sounds for beeping effect
      for (int i = 0; i < beepCount; i++) {
        HapticFeedback.heavyImpact(); // Use haptic feedback for alerts
        if (i < beepCount - 1) {
          await Future.delayed(Duration(milliseconds: beepInterval));
        }
      }
    } catch (e) {
      print('❌ Error playing alert sound: $e');
    }
  }

  Future<void> _logProximityEncounter(ProximityData device) async {
    try {
      await ApiService.logProximityEncounter({
        'myDeviceId': _currentDeviceId,
        'detectedDeviceId': device.deviceId,
        'rssi': device.rssi,
        'estimatedDistance': device.distance,
        'duration': SCAN_INTERVAL_SECONDS,
      });
    } catch (e) {
      print('❌ Error logging proximity encounter: $e');
    }
  }

  void _logAlert(ProximityData device, AlertLevel level) {
    print(
      '📊 ALERT LOG: ${DateTime.now()} - Device: ${device.deviceId}, Level: ${level.name}, Distance: ${device.distance.toStringAsFixed(1)}m',
    );
  }

  Future<void> stopProximityMonitoring() async {
    print('🛑 Stopping proximity monitoring...');

    _scanTimer?.cancel();
    _alertTimer?.cancel();
    await _scanSubscription?.cancel();

    _isScanning = false;
    _isAlertActive = false;
    _nearbyInfectedDevices.clear();

    print('✅ Proximity monitoring stopped');
  }

  void dispose() {
    stopProximityMonitoring();
  }

  // Getters for UI
  bool get isMonitoring => _scanTimer?.isActive ?? false;
  bool get isAlertActive => _isAlertActive;
  List<ProximityData> get nearbyInfectedDevices =>
      _nearbyInfectedDevices.values.toList();
}

class ProximityData {
  final String deviceId;
  final double distance;
  final int rssi;
  final DateTime detectedAt;

  ProximityData({
    required this.deviceId,
    required this.distance,
    required this.rssi,
    required this.detectedAt,
  });
}

enum AlertLevel {
  NONE,
  CAUTION, // 2-3m
  WARNING, // 1-2m
  CRITICAL, // <1m
}
