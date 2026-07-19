import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class RealSmartwatchPairingScreen extends StatefulWidget {
  const RealSmartwatchPairingScreen({Key? key}) : super(key: key);

  @override
  State<RealSmartwatchPairingScreen> createState() => _RealSmartwatchPairingScreenState();
}

class _RealSmartwatchPairingScreenState extends State<RealSmartwatchPairingScreen> {
  // Bluetooth state
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  
  // Discovery and pairing
  bool _isDiscovering = false;
  List<BluetoothDiscoveryResult> _discoveryResults = [];
  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;
  
  // Pairing state
  String? _selectedDeviceAddress;
  String? _selectedDeviceName;
  bool _isPairing = false;
  String? _pairingId;
  String? _pairingCode;
  
  // API Configuration
  static const String API_BASE_URL = 'http://localhost:5000/api/v1';
  String? authToken; // Should be obtained from secure storage

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    // Get current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;
    
    // Listen for Bluetooth state changes
    FlutterBluetoothSerial.instance.onStateChanged().listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    // Request permissions
    await _requestPermissions();
    
    // If Bluetooth is off, request to turn it on
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await _requestBluetoothOn();
    }
    
    setState(() {});
  }

  Future<void> _requestPermissions() async {
    // Request Bluetooth permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.location, // Required for Bluetooth discovery on Android
    ].request();

    // Check if all permissions are granted
    bool allGranted = statuses.values.every((status) => status == PermissionStatus.granted);
    
    if (!allGranted) {
      _showPermissionDialog();
    }
  }

  Future<void> _requestBluetoothOn() async {
    await FlutterBluetoothSerial.instance.requestEnable();
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bluetooth Permissions Required'),
          content: const Text(
            'This app needs Bluetooth permissions to pair with smartwatches. Please enable all required permissions in settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startDiscovery() async {
    if (_bluetoothState != BluetoothState.STATE_ON) {
      _showBluetoothOffDialog();
      return;
    }

    setState(() {
      _isDiscovering = true;
      _discoveryResults.clear();
    });

    _discoveryStreamSubscription = FlutterBluetoothSerial.instance
        .startDiscovery()
        .listen((BluetoothDiscoveryResult result) {
      setState(() {
        // Filter for potential smartwatch devices
        if (_isLikelySmartwatch(result.device)) {
          _discoveryResults.add(result);
        }
      });
    });

    _discoveryStreamSubscription!.onDone(() {
      setState(() {
        _isDiscovering = false;
      });
    });
  }

  bool _isLikelySmartwatch(BluetoothDevice device) {
    final name = device.name?.toLowerCase() ?? '';
    final watchKeywords = [
      'watch', 'fitness', 'band', 'tracker', 'apple', 'samsung', 
      'fitbit', 'garmin', 'xiaomi', 'huawei', 'amazfit', 'polar'
    ];
    
    return watchKeywords.any((keyword) => name.contains(keyword));
  }

  void _stopDiscovery() {
    _discoveryStreamSubscription?.cancel();
    setState(() {
      _isDiscovering = false;
    });
  }

  void _showBluetoothOffDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bluetooth is Off'),
          content: const Text('Please turn on Bluetooth to discover smartwatches.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _requestBluetoothOn();
              },
              child: const Text('Turn On'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDevice(BluetoothDevice device) async {
    setState(() {
      _selectedDeviceAddress = device.address;
      _selectedDeviceName = device.name;
      _isPairing = true;
    });

    _stopDiscovery();

    try {
      // Initiate pairing with backend
      await _initiatePairing(device);
    } catch (e) {
      setState(() {
        _isPairing = false;
        _selectedDeviceAddress = null;
        _selectedDeviceName = null;
      });
      _showErrorDialog('Failed to start pairing: $e');
    }
  }

  Future<void> _initiatePairing(BluetoothDevice device) async {
    try {
      // Determine device brand from name
      String brand = _detectDeviceBrand(device.name ?? '');
      
      final response = await http.post(
        Uri.parse('$API_BASE_URL/smartwatch/pair'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'device': {
            'deviceName': device.name ?? 'Unknown Device',
            'brand': brand,
            'model': _extractModel(device.name ?? ''),
          },
          'bluetooth': {
            'bluetoothAddress': device.address,
            'bluetoothName': device.name,
            'bluetoothVersion': '5.0', // Default, could be detected
          },
          'pairingMethod': 'passkey',
          'capabilities': _getDefaultCapabilities(brand),
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          _pairingId = data['data']['pairing']['pairingId'];
          _pairingCode = data['data']['pairing']['pairingCode'];
        });
        
        _showPairingDialog();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to initiate pairing');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  String _detectDeviceBrand(String deviceName) {
    final name = deviceName.toLowerCase();
    if (name.contains('apple') || name.contains('watch')) return 'apple';
    if (name.contains('samsung') || name.contains('galaxy')) return 'samsung';
    if (name.contains('fitbit')) return 'fitbit';
    if (name.contains('garmin')) return 'garmin';
    if (name.contains('xiaomi') || name.contains('mi')) return 'xiaomi';
    if (name.contains('huawei')) return 'huawei';
    return 'other';
  }

  String _extractModel(String deviceName) {
    // Simple model extraction - in real app, this would be more sophisticated
    return deviceName.split(' ').last;
  }

  Map<String, dynamic> _getDefaultCapabilities(String brand) {
    switch (brand) {
      case 'apple':
        return {
          'sensors': [
            {'type': 'heart_rate', 'available': true, 'accuracy': 'high', 'sampleRate': 1},
            {'type': 'accelerometer', 'available': true, 'accuracy': 'high', 'sampleRate': 50},
            {'type': 'gyroscope', 'available': true, 'accuracy': 'high', 'sampleRate': 50},
            {'type': 'gps', 'available': true, 'accuracy': 'high', 'sampleRate': 1},
          ],
          'features': ['notifications', 'health_monitoring', 'emergency_sos', 'fall_detection'],
          'batteryLevel': 100,
        };
      case 'samsung':
        return {
          'sensors': [
            {'type': 'heart_rate', 'available': true, 'accuracy': 'high', 'sampleRate': 1},
            {'type': 'accelerometer', 'available': true, 'accuracy': 'high', 'sampleRate': 50},
            {'type': 'gyroscope', 'available': true, 'accuracy': 'medium', 'sampleRate': 50},
          ],
          'features': ['notifications', 'health_monitoring', 'sleep_tracking'],
          'batteryLevel': 100,
        };
      default:
        return {
          'sensors': [
            {'type': 'heart_rate', 'available': true, 'accuracy': 'medium', 'sampleRate': 1},
            {'type': 'accelerometer', 'available': true, 'accuracy': 'medium', 'sampleRate': 25},
          ],
          'features': ['notifications', 'health_monitoring'],
          'batteryLevel': 100,
        };
    }
  }

  void _showPairingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pairing with Smartwatch'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Device: $_selectedDeviceName'),
              const SizedBox(height: 8),
              Text('Pairing Code: $_pairingCode'),
              const SizedBox(height: 16),
              const Text(
                'Please confirm the pairing code on your smartwatch.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _cancelPairing,
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _confirmPairing,
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmPairing() async {
    try {
      // Close pairing dialog
      Navigator.of(context).pop();
      
      // Show loading
      _showLoadingDialog('Confirming pairing...');

      final response = await http.post(
        Uri.parse('$API_BASE_URL/smartwatch/confirm-pairing'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'pairingId': _pairingId,
          'pairingCode': _pairingCode,
          'deviceConfirmation': {
            'batteryLevel': 85,
            'capabilities': _getDefaultCapabilities(_detectDeviceBrand(_selectedDeviceName ?? '')),
          },
        }),
      );

      // Hide loading
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _showSuccessDialog(data['data']['pairing']);
      } else {
        final error = jsonDecode(response.body);
        _showErrorDialog(error['message'] ?? 'Failed to confirm pairing');
      }
    } catch (e) {
      Navigator.of(context).pop(); // Hide loading
      _showErrorDialog('Network error: $e');
    }
  }

  void _cancelPairing() {
    Navigator.of(context).pop();
    setState(() {
      _isPairing = false;
      _selectedDeviceAddress = null;
      _selectedDeviceName = null;
      _pairingId = null;
      _pairingCode = null;
    });
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Text(message),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog(Map<String, dynamic> pairingData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Pairing Successful'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Device: ${pairingData['device']['name']}'),
              Text('Brand: ${pairingData['device']['brand']}'),
              Text('Model: ${pairingData['device']['model']}'),
              Text('Battery: ${pairingData['device']['batteryLevel']}%'),
              const SizedBox(height: 16),
              const Text('Your smartwatch is now connected and ready for health monitoring!'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pairing Failed'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isPairing = false;
                  _selectedDeviceAddress = null;
                  _selectedDeviceName = null;
                  _pairingId = null;
                  _pairingCode = null;
                });
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pair Smartwatch'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          if (_bluetoothState == BluetoothState.STATE_ON && !_isDiscovering)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _startDiscovery,
            ),
        ],
      ),
      body: Column(
        children: [
          // Bluetooth status header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: _getBluetoothStatusColor(),
            child: Row(
              children: [
                Icon(
                  _getBluetoothStatusIcon(),
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  _getBluetoothStatusText(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_bluetoothState == BluetoothState.STATE_OFF)
                  ElevatedButton(
                    onPressed: _requestBluetoothOn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Turn On'),
                  ),
              ],
            ),
          ),

          // Discovery section
          if (_bluetoothState == BluetoothState.STATE_ON) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Available Smartwatches',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_isDiscovering)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _startDiscovery,
                      icon: const Icon(Icons.search),
                      label: const Text('Scan'),
                    ),
                ],
              ),
            ),

            // Device list
            Expanded(
              child: _discoveryResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.watch,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isDiscovering 
                                ? 'Scanning for smartwatches...'
                                : 'No smartwatches found\nTap "Scan" to search for devices',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _discoveryResults.length,
                      itemBuilder: (context, index) {
                        final result = _discoveryResults[index];
                        final device = result.device;
                        
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue[100],
                              child: Icon(
                                Icons.watch,
                                color: Colors.blue[600],
                              ),
                            ),
                            title: Text(
                              device.name ?? 'Unknown Device',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Address: ${device.address}'),
                                Text('Signal: ${result.rssi} dBm'),
                                Text('Brand: ${_detectDeviceBrand(device.name ?? '')}'),
                              ],
                            ),
                            trailing: _isPairing && _selectedDeviceAddress == device.address
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : ElevatedButton(
                                    onPressed: () => _selectDevice(device),
                                    child: const Text('Pair'),
                                  ),
                            onTap: () => _selectDevice(device),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBluetoothStatusColor() {
    switch (_bluetoothState) {
      case BluetoothState.STATE_ON:
        return Colors.green;
      case BluetoothState.STATE_OFF:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getBluetoothStatusIcon() {
    switch (_bluetoothState) {
      case BluetoothState.STATE_ON:
        return Icons.bluetooth_connected;
      case BluetoothState.STATE_OFF:
        return Icons.bluetooth_disabled;
      default:
        return Icons.bluetooth;
    }
  }

  String _getBluetoothStatusText() {
    switch (_bluetoothState) {
      case BluetoothState.STATE_ON:
        return 'Bluetooth is ON';
      case BluetoothState.STATE_OFF:
        return 'Bluetooth is OFF';
      case BluetoothState.STATE_TURNING_ON:
        return 'Turning Bluetooth ON...';
      case BluetoothState.STATE_TURNING_OFF:
        return 'Turning Bluetooth OFF...';
      default:
        return 'Bluetooth status unknown';
    }
  }

  @override
  void dispose() {
    _discoveryStreamSubscription?.cancel();
    super.dispose();
  }
}
