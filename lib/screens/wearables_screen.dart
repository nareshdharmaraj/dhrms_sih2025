import 'package:flutter/material.dart';
import '../models/wearable_device.dart';
import '../models/wearable_data.dart';
import '../services/wearable_service.dart';
import '../services/bluetooth_wearable_service.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_button.dart';

class WearablesScreen extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic>? patientData;

  const WearablesScreen({
    super.key,
    required this.patientId,
    this.patientData,
  });

  @override
  State<WearablesScreen> createState() => _WearablesScreenState();
}

class _WearablesScreenState extends State<WearablesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final BluetoothWearableService _bluetoothService = BluetoothWearableService();
  
  List<WearableDevice> _connectedDevices = [];
  List<WearableDevice> _availableDevices = [];
  final Map<WearableDataType, WearableData> _latestReadings = {};
  List<WearableData> _recentAlerts = [];
  bool _isLoading = true;
  bool _isScanning = false;
  bool _isBluetoothEnabled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initializeWearables();
    _setupListeners();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initializeWearables() async {
    setState(() => _isLoading = true);

    // Initialize Bluetooth service
    _isBluetoothEnabled = await _bluetoothService.initialize();
    
    // Load patient devices and data
    await _loadPatientDevices();
    await _loadLatestReadings();
    await _loadRecentAlerts();

    setState(() => _isLoading = false);
  }

  void _setupListeners() {
    // Listen to real-time data updates
    _bluetoothService.dataStream.listen((data) {
      setState(() {
        _latestReadings[data.dataType] = data;
      });
    });

    // Listen to device status updates
    _bluetoothService.deviceStatusStream.listen((device) {
      setState(() {
        final index = _connectedDevices.indexWhere((d) => d.macAddress == device.macAddress);
        if (index != -1) {
          _connectedDevices[index] = device;
        }
      });
    });

    // Listen to available devices
    _bluetoothService.availableDevicesStream.listen((devices) {
      setState(() {
        _availableDevices = devices;
      });
    });
  }

  Future<void> _loadPatientDevices() async {
    final result = await WearableService.getPatientDevices(widget.patientId);
    if (result['success']) {
      setState(() {
        _connectedDevices = (result['devices'] as List<WearableDevice>)
            .where((device) => device.isConnected)
            .toList();
      });
    }
  }

  Future<void> _loadLatestReadings() async {
    final vitalTypes = [
      WearableDataType.heartRate,
      WearableDataType.bloodPressure,
      WearableDataType.oxygenSaturation,
      WearableDataType.temperature,
      WearableDataType.steps,
      WearableDataType.calories,
    ];

    for (final type in vitalTypes) {
      final result = await WearableService.getLatestData(
        patientId: widget.patientId,
        dataType: type,
        limit: 1,
      );

      if (result['success'] && (result['readings'] as List).isNotEmpty) {
        final readings = result['readings'] as List<WearableData>;
        setState(() {
          _latestReadings[type] = readings.first;
        });
      }
    }
  }

  Future<void> _loadRecentAlerts() async {
    final result = await WearableService.getAlerts(
      patientId: widget.patientId,
      limit: 10,
    );

    if (result['success']) {
      setState(() {
        _recentAlerts = result['alerts'] as List<WearableData>;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wearable Health Monitoring',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppConstants.primaryBlue,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.devices), text: 'Devices'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.warning), text: 'Alerts'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildDevicesTab(),
                _buildAnalyticsTab(),
                _buildAlertsTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connection Status
          _buildConnectionStatusCard(),
          const SizedBox(height: 20),

          // Latest Vitals Grid
          Text(
            'Current Vitals',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          _buildVitalsGrid(),
          
          const SizedBox(height: 20),

          // Activity Summary
          Text(
            'Today\'s Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          _buildActivitySummary(),

          const SizedBox(height: 20),

          // Quick Actions
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildConnectionStatusCard() {
    final connectedCount = _connectedDevices.length;
    final isAnyConnected = connectedCount > 0;

    // Start pulse animation if any device is connected
    if (isAnyConnected && !_pulseController.isAnimating) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pulseController.repeat(reverse: true);
      });
    }
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: isAnyConnected ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isAnyConnected ? AppConstants.successGreen : AppConstants.lightGrey,
                      boxShadow: isAnyConnected
                          ? [
                              BoxShadow(
                                color: AppConstants.successGreen.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      isAnyConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              isAnyConnected ? 'Connected' : 'No Devices Connected',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isAnyConnected ? AppConstants.successGreen : AppConstants.mediumGrey,
              ),
            ),
            Text(
              isAnyConnected 
                  ? '$connectedCount device${connectedCount > 1 ? 's' : ''} monitoring your health'
                  : 'Connect your wearable devices to start monitoring',
              style: TextStyle(
                color: AppConstants.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalsGrid() {
    final vitals = [
      _buildVitalCard(
        'Heart Rate',
        _latestReadings[WearableDataType.heartRate],
        Icons.favorite,
        AppConstants.errorRed,
      ),
      _buildVitalCard(
        'Blood Pressure',
        _latestReadings[WearableDataType.bloodPressure],
        Icons.monitor_weight,
        AppConstants.primaryBlue,
      ),
      _buildVitalCard(
        'Oxygen Level',
        _latestReadings[WearableDataType.oxygenSaturation],
        Icons.air,
        AppConstants.primaryGreen,
      ),
      _buildVitalCard(
        'Temperature',
        _latestReadings[WearableDataType.temperature],
        Icons.thermostat,
        AppConstants.warningOrange,
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: vitals,
    );
  }

  Widget _buildVitalCard(String title, WearableData? data, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppConstants.secondaryText,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              data != null ? data.formattedValue : '--',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: data?.status == WearableDataStatus.normal 
                    ? AppConstants.primaryText 
                    : AppConstants.errorRed,
              ),
              textAlign: TextAlign.center,
            ),
            if (data != null)
              Text(
                data.timeAgo,
                style: TextStyle(
                  fontSize: 10,
                  color: AppConstants.hintText,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySummary() {
    final stepsData = _latestReadings[WearableDataType.steps];
    final caloriesData = _latestReadings[WearableDataType.calories];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildActivityItem(
                'Steps',
                stepsData?.value.toInt().toString() ?? '0',
                Icons.directions_walk,
                AppConstants.primaryBlue,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: AppConstants.lightGrey,
            ),
            Expanded(
              child: _buildActivityItem(
                'Calories',
                caloriesData?.value.toInt().toString() ?? '0',
                Icons.local_fire_department,
                AppConstants.warningOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryText,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppConstants.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Sync Devices',
                icon: Icons.sync,
                onPressed: _connectedDevices.isNotEmpty ? _syncDevices : null,
                backgroundColor: AppConstants.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Add Device',
                icon: Icons.add,
                onPressed: _showAddDeviceDialog,
                backgroundColor: AppConstants.successGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'View Trends',
                icon: Icons.trending_up,
                onPressed: () => _tabController.animateTo(2),
                backgroundColor: AppConstants.primaryPurple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Health Report',
                icon: Icons.assessment,
                onPressed: _generateHealthReport,
                backgroundColor: AppConstants.warningOrange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDevicesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connected Devices
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Connected Devices',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryText,
                ),
              ),
              IconButton(
                onPressed: _loadPatientDevices,
                icon: Icon(Icons.refresh, color: AppConstants.primaryBlue),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (_connectedDevices.isEmpty)
            _buildEmptyDevicesCard()
          else
            ..._connectedDevices.map((device) => _buildDeviceCard(device)),

          const SizedBox(height: 20),

          // Available Devices
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Devices',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryText,
                ),
              ),
              CustomButton(
                text: _isScanning ? 'Scanning...' : 'Scan',
                icon: Icons.search,
                onPressed: _isBluetoothEnabled ? _startDeviceScan : null,
                backgroundColor: AppConstants.primaryBlue,
                isLoading: _isScanning,
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_availableDevices.isEmpty && !_isScanning)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.bluetooth_searching,
                        size: 48,
                        color: AppConstants.lightGrey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No devices found',
                        style: TextStyle(
                          color: AppConstants.secondaryText,
                        ),
                      ),
                      Text(
                        'Make sure your device is in pairing mode',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppConstants.hintText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ..._availableDevices.map((device) => _buildAvailableDeviceCard(device)),
        ],
      ),
    );
  }

  Widget _buildEmptyDevicesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.watch_off,
                size: 48,
                color: AppConstants.lightGrey,
              ),
              const SizedBox(height: 12),
              Text(
                'No connected devices',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppConstants.secondaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Connect your wearable devices to start monitoring your health',
                style: TextStyle(
                  color: AppConstants.hintText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceCard(WearableDevice device) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: device.isOnline ? AppConstants.successGreen : AppConstants.lightGrey,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getDeviceIcon(device.deviceType),
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          device.deviceName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${device.manufacturer} ${device.model}'),
            Row(
              children: [
                Icon(
                  Icons.battery_std,
                  size: 16,
                  color: _getBatteryColor(device.batteryLevel),
                ),
                Text(
                  ' ${device.batteryLevel}%',
                  style: TextStyle(
                    color: _getBatteryColor(device.batteryLevel),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: device.isOnline ? AppConstants.lightGreen : AppConstants.lightGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    device.connectionStatus.displayName,
                    style: TextStyle(
                      fontSize: 10,
                      color: device.isOnline ? AppConstants.successGreen : AppConstants.mediumGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleDeviceAction(device, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'sync',
              child: ListTile(
                leading: Icon(Icons.sync),
                title: Text('Sync Now'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'disconnect',
              child: ListTile(
                leading: Icon(Icons.bluetooth_disabled),
                title: Text('Disconnect'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'remove',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Remove Device'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableDeviceCard(WearableDevice device) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppConstants.primaryBlue,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getDeviceIcon(device.deviceType),
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          device.deviceName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${device.manufacturer} ${device.model}'),
        trailing: CustomButton(
          text: 'Connect',
          icon: Icons.bluetooth,
          onPressed: () => _connectToDevice(device),
          backgroundColor: AppConstants.successGreen,
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Analytics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          
          // Analytics will be implemented here
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.analytics,
                      size: 64,
                      color: AppConstants.lightGrey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Advanced Analytics Coming Soon',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Detailed health trends, insights, and predictions will be available here',
                      style: TextStyle(
                        color: AppConstants.hintText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Health Alerts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryText,
                ),
              ),
              IconButton(
                onPressed: _loadRecentAlerts,
                icon: Icon(Icons.refresh, color: AppConstants.primaryBlue),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_recentAlerts.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 64,
                        color: AppConstants.successGreen,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Health Alerts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.successGreen,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'All your health parameters are within normal ranges',
                        style: TextStyle(
                          color: AppConstants.hintText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ..._recentAlerts.map((alert) => _buildAlertCard(alert)),
        ],
      ),
    );
  }

  Widget _buildAlertCard(WearableData alert) {
    Color alertColor;
    IconData alertIcon;

    switch (alert.alertLevel) {
      case WearableAlertLevel.critical:
        alertColor = AppConstants.errorRed;
        alertIcon = Icons.error;
        break;
      case WearableAlertLevel.high:
        alertColor = AppConstants.warningOrange;
        alertIcon = Icons.warning;
        break;
      case WearableAlertLevel.medium:
        alertColor = Colors.orange;
        alertIcon = Icons.info;
        break;
      default:
        alertColor = AppConstants.primaryBlue;
        alertIcon = Icons.info_outline;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: alertColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(alertIcon, color: alertColor, size: 24),
        ),
        title: Text(
          '${alert.dataType.displayName} Alert',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Value: ${alert.formattedValue}'),
            Text(
              'Status: ${alert.status.displayName}',
              style: TextStyle(color: alertColor),
            ),
            Text(
              alert.timeAgo,
              style: TextStyle(
                fontSize: 12,
                color: AppConstants.hintText,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: alertColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            alert.alertLevel.displayName.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: alertColor,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getDeviceIcon(WearableDeviceType type) {
    switch (type) {
      case WearableDeviceType.smartwatch:
        return Icons.watch;
      case WearableDeviceType.fitnessBand:
        return Icons.fitness_center;
      case WearableDeviceType.heartMonitor:
        return Icons.monitor_heart;
      case WearableDeviceType.bloodPressureMonitor:
        return Icons.monitor_weight;
      case WearableDeviceType.pulseOximeter:
        return Icons.air;
    }
  }

  Color _getBatteryColor(int batteryLevel) {
    if (batteryLevel > 50) return AppConstants.successGreen;
    if (batteryLevel > 20) return AppConstants.warningOrange;
    return AppConstants.errorRed;
  }

  void _syncDevices() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Syncing devices...')),
    );
    
    await _loadLatestReadings();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Devices synced successfully'),
        backgroundColor: AppConstants.successGreen,
      ),
    );
  }

  void _showAddDeviceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Wearable Device'),
        content: const Text(
          'To add a new device:\n\n'
          '1. Make sure your device is in pairing mode\n'
          '2. Go to the Devices tab\n'
          '3. Tap "Scan" to discover available devices\n'
          '4. Select your device and tap "Connect"',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _generateHealthReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating health report...')),
    );
    // TODO: Implement health report generation
  }

  void _startDeviceScan() async {
    setState(() => _isScanning = true);
    await _bluetoothService.startDeviceScan();
    setState(() => _isScanning = false);
  }

  void _connectToDevice(WearableDevice device) async {
    final success = await _bluetoothService.connectToDevice(device, widget.patientId);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected to ${device.deviceName}'),
          backgroundColor: AppConstants.successGreen,
        ),
      );
      await _loadPatientDevices();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect to ${device.deviceName}'),
          backgroundColor: AppConstants.errorRed,
        ),
      );
    }
  }

  void _handleDeviceAction(WearableDevice device, String action) async {
    switch (action) {
      case 'sync':
        _syncDevices();
        break;
      case 'disconnect':
        await _bluetoothService.disconnectDevice(device);
        await _loadPatientDevices();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Disconnected from ${device.deviceName}'),
            backgroundColor: AppConstants.warningOrange,
          ),
        );
        break;
      case 'remove':
        _showRemoveDeviceDialog(device);
        break;
    }
  }

  void _showRemoveDeviceDialog(WearableDevice device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Device'),
        content: Text('Are you sure you want to remove ${device.deviceName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await WearableService.deleteDevice(device.id, deleteData: false);
              if (result['success']) {
                await _loadPatientDevices();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${device.deviceName} removed'),
                    backgroundColor: AppConstants.successGreen,
                  ),
                );
              }
            },
            child: Text(
              'Remove',
              style: TextStyle(color: AppConstants.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}
