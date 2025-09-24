import 'dart:async';
import 'package:flutter/material.dart';
import '../services/proximity_alert_service.dart';
import '../utils/storage_helper.dart';

class ProximityAlertScreen extends StatefulWidget {
  const ProximityAlertScreen({super.key});

  @override
  State<ProximityAlertScreen> createState() => _ProximityAlertScreenState();
}

class _ProximityAlertScreenState extends State<ProximityAlertScreen> {
  final ProximityAlertService _alertService = ProximityAlertService();
  bool _isInitialized = false;
  bool _isMonitoring = false;
  String? _deviceId;
  String? _uhid;
  List<ProximityData> _nearbyDevices = [];
  Timer? _uiUpdateTimer;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      await _alertService.initialize();
      _deviceId = await StorageHelper.getDeviceId();
      _uhid = await StorageHelper.getUHID();

      setState(() {
        _isInitialized = true;
      });

      print('✅ Proximity Alert Service initialized successfully');
    } catch (e) {
      print('❌ Error initializing service: $e');
      _showErrorDialog(
        'Initialization Error',
        'Failed to initialize proximity monitoring: $e',
      );
    }
  }

  Future<void> _startMonitoring() async {
    try {
      await _alertService.startProximityMonitoring();
      setState(() {
        _isMonitoring = true;
      });

      // Start periodic UI updates
      _startUIUpdates();

      _showSuccessSnackBar(
        '🎯 Proximity monitoring started - Scanning every 5 seconds',
      );
    } catch (e) {
      print('❌ Error starting monitoring: $e');
      _showErrorDialog(
        'Monitoring Error',
        'Failed to start proximity monitoring: $e',
      );
    }
  }

  Future<void> _stopMonitoring() async {
    try {
      await _alertService.stopProximityMonitoring();
      _uiUpdateTimer?.cancel();

      setState(() {
        _isMonitoring = false;
        _nearbyDevices = [];
      });

      _showSuccessSnackBar('🛑 Proximity monitoring stopped');
    } catch (e) {
      print('❌ Error stopping monitoring: $e');
      _showErrorDialog('Stop Error', 'Failed to stop proximity monitoring: $e');
    }
  }

  void _startUIUpdates() {
    _uiUpdateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isMonitoring) {
        timer.cancel();
        return;
      }

      setState(() {
        _nearbyDevices = _alertService.nearbyInfectedDevices;
      });
    });
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛡️ Contact Tracing'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: _isInitialized ? _buildMainContent() : _buildLoadingContent(),
    );
  }

  Widget _buildLoadingContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Initializing Proximity Alert System...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDeviceInfoCard(),
          const SizedBox(height: 16),
          _buildControlCard(),
          const SizedBox(height: 16),
          _buildStatusCard(),
          if (_nearbyDevices.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildNearbyDevicesCard(),
          ],
          const Spacer(),
          _buildSpecificationsCard(),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📱 Device Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Device ID', _deviceId ?? 'Not available'),
            _buildInfoRow('UHID', _uhid ?? 'Not set'),
            _buildInfoRow(
              'Status',
              _isInitialized ? '✅ Initialized' : '⚠️ Initializing',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '🎯 Proximity Monitoring Control',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isMonitoring ? _stopMonitoring : _startMonitoring,
              icon: Icon(_isMonitoring ? Icons.stop : Icons.play_arrow),
              label: Text(
                _isMonitoring ? 'Stop Monitoring' : 'Start Monitoring',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isMonitoring
                    ? Colors.red[600]
                    : Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Current Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Monitoring',
              _isMonitoring ? '🟢 Active' : '🔴 Inactive',
            ),
            _buildInfoRow(
              'Alert Status',
              _alertService.isAlertActive ? '🚨 ALERTING' : '🟢 Normal',
            ),
            _buildInfoRow('Nearby Infected', '${_nearbyDevices.length}'),
            _buildInfoRow(
              'Last Update',
              DateTime.now().toString().substring(11, 19),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyDevicesCard() {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.red[600]),
                const SizedBox(width: 8),
                Text(
                  '🚨 INFECTED DEVICES NEARBY',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...(_nearbyDevices.map((device) => _buildDeviceAlertCard(device))),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceAlertCard(ProximityData device) {
    String riskLevel;
    Color riskColor;

    if (device.distance <= 1.0) {
      riskLevel = '🔴 CRITICAL';
      riskColor = Colors.red[700]!;
    } else if (device.distance <= 2.0) {
      riskLevel = '🟠 WARNING';
      riskColor = Colors.orange[700]!;
    } else {
      riskLevel = '🟡 CAUTION';
      riskColor = Colors.yellow[700]!;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: riskColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Infected Person Nearby', // ✅ Privacy: Shows "Infected person nearby"
            style: TextStyle(fontWeight: FontWeight.bold, color: riskColor),
          ),
          const SizedBox(height: 4),
          Text('Distance: ${device.distance.toStringAsFixed(1)}m'),
          Text('Risk Level: $riskLevel'),
          Text('Detected: ${device.detectedAt.toString().substring(11, 19)}'),
        ],
      ),
    );
  }

  Widget _buildSpecificationsCard() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚙️ System Specifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 8),
            _buildSpecRow('Scan Interval', '5 seconds'),
            _buildSpecRow('Alert Frequency', '5 seconds'),
            _buildSpecRow('Audio Alerts', 'Beeping (faster when closer)'),
            _buildSpecRow('Privacy Mode', 'Shows "Infected person nearby"'),
            _buildSpecRow('Distance Accuracy', '±1 meter (Bluetooth)'),
            _buildSpecRow('Battery Impact', 'Optimized for 5-second scanning'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _uiUpdateTimer?.cancel();
    _alertService.dispose();
    super.dispose();
  }
}
