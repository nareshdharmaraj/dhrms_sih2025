import 'dart:async';
import 'dart:math';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/wearable_device.dart';
import '../models/wearable_data.dart';
import '../services/wearable_service.dart';

class BluetoothWearableService {
  static final BluetoothWearableService _instance = BluetoothWearableService._internal();
  factory BluetoothWearableService() => _instance;
  BluetoothWearableService._internal();

  // Streams for real-time data
  final StreamController<WearableData> _dataStreamController = StreamController<WearableData>.broadcast();
  final StreamController<WearableDevice> _deviceStatusController = StreamController<WearableDevice>.broadcast();
  final StreamController<List<WearableDevice>> _availableDevicesController = StreamController<List<WearableDevice>>.broadcast();

  Stream<WearableData> get dataStream => _dataStreamController.stream;
  Stream<WearableDevice> get deviceStatusStream => _deviceStatusController.stream;
  Stream<List<WearableDevice>> get availableDevicesStream => _availableDevicesController.stream;

  // State management
  bool _isBluetoothEnabled = false;
  bool _isScanning = false;
  final Map<String, WearableDevice> _connectedDevices = {};
  final Map<String, WearableDevice> _availableDevices = {};
  Timer? _dataGenerationTimer;
  Timer? _deviceScanTimer;

  // Getters
  bool get isBluetoothEnabled => _isBluetoothEnabled;
  bool get isScanning => _isScanning;
  List<WearableDevice> get connectedDevices => _connectedDevices.values.toList();
  List<WearableDevice> get availableDevices => _availableDevices.values.toList();

  // Initialize service
  Future<bool> initialize() async {
    try {
      // Check if Bluetooth is supported
      if (await FlutterBluePlus.isSupported == false) {
        print("Bluetooth not supported by this device");
        return false;
      }

      // Request Bluetooth permissions
      final bluetoothPermission = await Permission.bluetooth.request();
      final bluetoothScanPermission = await Permission.bluetoothScan.request();
      final bluetoothConnectPermission = await Permission.bluetoothConnect.request();
      final locationPermission = await Permission.locationWhenInUse.request();

      if (bluetoothPermission.isGranted && 
          bluetoothScanPermission.isGranted && 
          bluetoothConnectPermission.isGranted &&
          locationPermission.isGranted) {
        
        // Check if Bluetooth is turned on
        final isOn = await FlutterBluePlus.isOn;
        _isBluetoothEnabled = isOn;
        
        if (!isOn) {
          // Try to turn on Bluetooth
          await FlutterBluePlus.turnOn();
          // Wait a bit and check again
          await Future.delayed(Duration(seconds: 2));
          _isBluetoothEnabled = await FlutterBluePlus.isOn;
        }
        
        return _isBluetoothEnabled;
      } else {
        print('Bluetooth permissions not granted');
        return false;
      }
    } catch (e) {
      print('Error initializing Bluetooth service: $e');
      return false;
    }
  }

  // Device Discovery
  Future<void> startDeviceScan({Duration duration = const Duration(seconds: 10)}) async {
    if (!_isBluetoothEnabled || _isScanning) return;

    _isScanning = true;
    _availableDevices.clear();

    try {
      // Start scanning for devices
      await FlutterBluePlus.startScan(timeout: duration);
      
      // Listen for scan results
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          final device = result.device;
          // Filter for potential wearable devices
          if (_isLikelyWearableDevice(device.name, device.id.id)) {
            final wearableDevice = _createDeviceFromScanResult(result);
            _availableDevices[wearableDevice.id] = wearableDevice;
            _availableDevicesController.add(availableDevices);
          }
        }
      });

      // Also add some simulated devices for demo purposes
      _simulateDeviceDiscovery();

    } catch (e) {
      print('Error during device scan: $e');
      // Fallback to simulated devices
      _simulateDeviceDiscovery();
    }

    // Stop scanning after specified duration
    _deviceScanTimer = Timer(duration, () {
      stopDeviceScan();
    });
  }

  void stopDeviceScan() {
    _isScanning = false;
    _deviceScanTimer?.cancel();
    FlutterBluePlus.stopScan();
  }

  bool _isLikelyWearableDevice(String deviceName, String deviceId) {
    final wearableKeywords = [
      'watch', 'band', 'fit', 'health', 'heart', 'polar', 'garmin', 
      'apple', 'samsung', 'fitbit', 'xiaomi', 'huawei', 'amazfit'
    ];
    
    final name = deviceName.toLowerCase();
    return wearableKeywords.any((keyword) => name.contains(keyword));
  }

  WearableDevice _createDeviceFromScanResult(ScanResult scanResult) {
    final device = scanResult.device;
    final deviceName = device.name.isNotEmpty ? device.name : 'Unknown Device';
    
    // Determine device type based on name
    WearableDeviceType deviceType = WearableDeviceType.smartwatch;
    final name = deviceName.toLowerCase();
    if (name.contains('band') || name.contains('fit')) {
      deviceType = WearableDeviceType.fitnessBand;
    } else if (name.contains('heart') || name.contains('polar')) {
      deviceType = WearableDeviceType.heartMonitor;
    }

    return WearableDevice(
      id: device.id.id,
      patientId: '',
      deviceName: deviceName,
      deviceType: deviceType,
      manufacturer: _guessManufacturer(deviceName),
      model: deviceName,
      macAddress: device.id.id,
      bluetoothId: device.id.id,
      isConnected: false,
      batteryLevel: 85 + Random().nextInt(15), // Simulated battery level
      capabilities: _getDeviceCapabilities(deviceType),
      lastSyncTime: DateTime.now(),
      connectionStatus: WearableConnectionStatus.disconnected,
      autoSync: true,
      syncInterval: 300,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  String _guessManufacturer(String deviceName) {
    final name = deviceName.toLowerCase();
    if (name.contains('apple')) return 'Apple';
    if (name.contains('samsung')) return 'Samsung';
    if (name.contains('fitbit')) return 'Fitbit';
    if (name.contains('garmin')) return 'Garmin';
    if (name.contains('polar')) return 'Polar';
    if (name.contains('xiaomi')) return 'Xiaomi';
    if (name.contains('huawei')) return 'Huawei';
    if (name.contains('amazfit')) return 'Amazfit';
    return 'Unknown';
  }

  void _simulateDeviceDiscovery() {
    // Simulate discovering common wearable devices
    final sampleDevices = [
      _createSampleDevice('Apple Watch Series 8', WearableDeviceType.smartwatch, 'Apple', 'Series 8'),
      _createSampleDevice('Samsung Galaxy Watch 5', WearableDeviceType.smartwatch, 'Samsung', 'Galaxy Watch 5'),
      _createSampleDevice('Fitbit Charge 5', WearableDeviceType.fitnessBand, 'Fitbit', 'Charge 5'),
      _createSampleDevice('Garmin Vivosmart 4', WearableDeviceType.fitnessBand, 'Garmin', 'Vivosmart 4'),
      _createSampleDevice('Polar H10', WearableDeviceType.heartMonitor, 'Polar', 'H10'),
    ];

    for (int i = 0; i < sampleDevices.length; i++) {
      Timer(Duration(seconds: i + 1), () {
        if (_isScanning) {
          final device = sampleDevices[i];
          _availableDevices[device.macAddress] = device;
          _availableDevicesController.add(_availableDevices.values.toList());
        }
      });
    }
  }

  WearableDevice _createSampleDevice(String name, WearableDeviceType type, String manufacturer, String model) {
    final random = Random();
    return WearableDevice(
      id: '',
      patientId: '',
      deviceName: name,
      deviceType: type,
      manufacturer: manufacturer,
      model: model,
      macAddress: '${random.nextInt(256).toRadixString(16).padLeft(2, '0')}:${random.nextInt(256).toRadixString(16).padLeft(2, '0')}:${random.nextInt(256).toRadixString(16).padLeft(2, '0')}:${random.nextInt(256).toRadixString(16).padLeft(2, '0')}:${random.nextInt(256).toRadixString(16).padLeft(2, '0')}:${random.nextInt(256).toRadixString(16).padLeft(2, '0')}',
      bluetoothId: 'BT_${random.nextInt(10000)}',
      isConnected: false,
      batteryLevel: 70 + random.nextInt(30),
      firmwareVersion: '${random.nextInt(5) + 1}.${random.nextInt(10)}.${random.nextInt(10)}',
      capabilities: _getDeviceCapabilities(type),
      lastSyncTime: DateTime.now().subtract(Duration(minutes: random.nextInt(60))),
      connectionStatus: WearableConnectionStatus.disconnected,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  List<WearableCapability> _getDeviceCapabilities(WearableDeviceType type) {
    switch (type) {
      case WearableDeviceType.smartwatch:
        return [
          WearableCapability.heartRate,
          WearableCapability.steps,
          WearableCapability.calories,
          WearableCapability.sleep,
          WearableCapability.stress,
        ];
      case WearableDeviceType.fitnessBand:
        return [
          WearableCapability.heartRate,
          WearableCapability.steps,
          WearableCapability.calories,
          WearableCapability.sleep,
        ];
      case WearableDeviceType.heartMonitor:
        return [
          WearableCapability.heartRate,
          WearableCapability.ecg,
        ];
      case WearableDeviceType.bloodPressureMonitor:
        return [
          WearableCapability.bloodPressure,
          WearableCapability.heartRate,
        ];
      case WearableDeviceType.pulseOximeter:
        return [
          WearableCapability.oxygenSaturation,
          WearableCapability.heartRate,
        ];
    }
  }

  // Device Connection
  Future<bool> connectToDevice(WearableDevice device, String patientId) async {
    try {
      // Simulate connection process
      await Future.delayed(const Duration(seconds: 2));

      // Register device if not already registered
      if (device.id.isEmpty) {
        final result = await WearableService.registerDevice(
          patientId: patientId,
          deviceName: device.deviceName,
          deviceType: device.deviceType,
          manufacturer: device.manufacturer,
          model: device.model,
          macAddress: device.macAddress,
          bluetoothId: device.bluetoothId,
          firmwareVersion: device.firmwareVersion,
          capabilities: device.capabilities,
        );

        if (!result['success']) {
          throw Exception(result['message']);
        }

        device = result['device'] as WearableDevice;
      }

      // Update device status
      final updatedDevice = device.copyWith(
        isConnected: true,
        connectionStatus: WearableConnectionStatus.connected,
        lastSyncTime: DateTime.now(),
      );

      _connectedDevices[device.macAddress] = updatedDevice;
      _availableDevices.remove(device.macAddress);

      // Update device status in backend
      await WearableService.updateDeviceStatus(
        deviceId: device.id,
        connectionStatus: WearableConnectionStatus.connected,
        isConnected: true,
      );

      _deviceStatusController.add(updatedDevice);

      // Start data generation for this device
      _startDataGeneration(updatedDevice, patientId);

      return true;
    } catch (e) {
      print('Error connecting to device: $e');
      return false;
    }
  }

  Future<bool> disconnectDevice(WearableDevice device) async {
    try {
      // Update device status
      final updatedDevice = device.copyWith(
        isConnected: false,
        connectionStatus: WearableConnectionStatus.disconnected,
      );

      _connectedDevices.remove(device.macAddress);

      // Update device status in backend
      if (device.id.isNotEmpty) {
        await WearableService.updateDeviceStatus(
          deviceId: device.id,
          connectionStatus: WearableConnectionStatus.disconnected,
          isConnected: false,
        );
      }

      _deviceStatusController.add(updatedDevice);
      return true;
    } catch (e) {
      print('Error disconnecting device: $e');
      return false;
    }
  }

  // Data Generation and Monitoring
  void _startDataGeneration(WearableDevice device, String patientId) {
    if (_dataGenerationTimer != null) return;

    _dataGenerationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _generateHealthData(device, patientId);
    });
  }

  void _generateHealthData(WearableDevice device, String patientId) {
    final random = Random();
    final now = DateTime.now();

    for (final capability in device.capabilities) {
      late WearableData data;

      switch (capability) {
        case WearableCapability.heartRate:
          data = WearableData(
            id: '',
            patientId: patientId,
            deviceId: device.id,
            dataType: WearableDataType.heartRate,
            timestamp: now,
            hourlyTimestamp: DateTime(now.year, now.month, now.day, now.hour),
            value: 60 + random.nextDouble() * 40, // 60-100 bpm
            unit: 'bpm',
            status: WearableDataStatus.normal,
            createdAt: now,
            updatedAt: now,
          );
          break;

        case WearableCapability.oxygenSaturation:
          data = WearableData(
            id: '',
            patientId: patientId,
            deviceId: device.id,
            dataType: WearableDataType.oxygenSaturation,
            timestamp: now,
            hourlyTimestamp: DateTime(now.year, now.month, now.day, now.hour),
            value: 95 + random.nextDouble() * 5, // 95-100%
            unit: '%',
            status: WearableDataStatus.normal,
            createdAt: now,
            updatedAt: now,
          );
          break;

        case WearableCapability.temperature:
          data = WearableData(
            id: '',
            patientId: patientId,
            deviceId: device.id,
            dataType: WearableDataType.temperature,
            timestamp: now,
            hourlyTimestamp: DateTime(now.year, now.month, now.day, now.hour),
            value: 36.1 + random.nextDouble() * 1.1, // 36.1-37.2°C
            unit: '°C',
            status: WearableDataStatus.normal,
            createdAt: now,
            updatedAt: now,
          );
          break;

        case WearableCapability.steps:
          data = WearableData(
            id: '',
            patientId: patientId,
            deviceId: device.id,
            dataType: WearableDataType.steps,
            timestamp: now,
            hourlyTimestamp: DateTime(now.year, now.month, now.day, now.hour),
            value: random.nextDouble() * 500, // Steps per 30 seconds
            unit: 'steps',
            status: WearableDataStatus.normal,
            createdAt: now,
            updatedAt: now,
          );
          break;

        case WearableCapability.calories:
          data = WearableData(
            id: '',
            patientId: patientId,
            deviceId: device.id,
            dataType: WearableDataType.calories,
            timestamp: now,
            hourlyTimestamp: DateTime(now.year, now.month, now.day, now.hour),
            value: random.nextDouble() * 10, // Calories per 30 seconds
            unit: 'kcal',
            status: WearableDataStatus.normal,
            createdAt: now,
            updatedAt: now,
          );
          break;

        default:
          continue;
      }

      // Emit data to stream
      _dataStreamController.add(data);

      // Store data in backend
      _storeDataPoint(data);
    }
  }

  void _storeDataPoint(WearableData data) async {
    try {
      final dataPoint = WearableService.createDataPoint(
        patientId: data.patientId,
        deviceId: data.deviceId,
        dataType: data.dataType,
        value: data.value,
        secondaryValue: data.secondaryValue,
        unit: data.unit,
        quality: data.quality,
        metadata: data.metadata?.toJson(),
        source: data.source,
      );

      await WearableService.storeWearableData([dataPoint]);
    } catch (e) {
      print('Error storing data point: $e');
    }
  }

  // Battery monitoring
  void updateDeviceBattery(String macAddress, int batteryLevel) {
    final device = _connectedDevices[macAddress];
    if (device != null) {
      final updatedDevice = device.copyWith(batteryLevel: batteryLevel);
      _connectedDevices[macAddress] = updatedDevice;
      _deviceStatusController.add(updatedDevice);

      // Update in backend
      if (device.id.isNotEmpty) {
        WearableService.updateDeviceStatus(
          deviceId: device.id,
          batteryLevel: batteryLevel,
        );
      }
    }
  }

  // Cleanup
  void dispose() {
    _dataGenerationTimer?.cancel();
    _deviceScanTimer?.cancel();
    _dataStreamController.close();
    _deviceStatusController.close();
    _availableDevicesController.close();
  }

  // Manual data entry (for testing purposes)
  void addManualData({
    required String patientId,
    required String deviceId,
    required WearableDataType dataType,
    required double value,
    double? secondaryValue,
  }) {
    final now = DateTime.now();
    final data = WearableData(
      id: '',
      patientId: patientId,
      deviceId: deviceId,
      dataType: dataType,
      timestamp: now,
      hourlyTimestamp: DateTime(now.year, now.month, now.day, now.hour),
      value: value,
      secondaryValue: secondaryValue,
      unit: dataType.defaultUnit,
      status: WearableService.isValueInNormalRange(dataType, value, secondaryValue: secondaryValue)
          ? WearableDataStatus.normal 
          : WearableDataStatus.warning,
      source: WearableDataSource.manualEntry,
      createdAt: now,
      updatedAt: now,
    );

    _dataStreamController.add(data);
    _storeDataPoint(data);
  }
}
