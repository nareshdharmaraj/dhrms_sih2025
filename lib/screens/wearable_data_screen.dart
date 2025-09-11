import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import '../services/bluetooth_wearable_service.dart';
import '../models/wearable_device.dart';
import '../models/wearable_data.dart';

class WearableDataScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const WearableDataScreen({super.key, required this.userData});

  @override
  _WearableDataScreenState createState() => _WearableDataScreenState();
}

class _WearableDataScreenState extends State<WearableDataScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final BluetoothWearableService _bluetoothService = BluetoothWearableService();
  bool isLoading = false;
  String selectedTimeRange = 'Today';
  bool _isBluetoothEnabled = false;
  List<WearableDevice> _availableDevices = [];
  final List<WearableDevice> _connectedDevices = [];
  bool _isScanning = false;
  
  // Real-time wearable data from connected devices
  Map<String, dynamic> wearableData = {
    'heartRate': {
      'current': 0,
      'min': 0,
      'max': 0,
      'data': <int>[],
      'isLive': false,
    },
    'steps': {
      'current': 0,
      'goal': 10000,
      'data': <int>[],
      'isLive': false,
    },
    'sleep': {
      'totalHours': 0.0,
      'deepSleep': 0.0,
      'lightSleep': 0.0,
      'remSleep': 0.0,
      'quality': 0,
      'isLive': false,
    },
    'bloodPressure': {
      'systolic': 0,
      'diastolic': 0,
      'lastReading': DateTime.now(), // Initialize with current time
      'isLive': false,
    },
    'bloodOxygen': {
      'current': 0,
      'data': <int>[],
      'isLive': false,
    },
    'temperature': {
      'current': 0.0,
      'data': <double>[],
      'isLive': false,
    },
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this); // Added Bluetooth tab
    _initializeBluetoothService();
    loadWearableData();
  }

  Future<void> _initializeBluetoothService() async {
    try {
      // Check if we're running on web
      if (kIsWeb) {
        // On web, Bluetooth is not supported - show appropriate message
        setState(() {
          _isBluetoothEnabled = false;
        });
        print('Bluetooth is not supported on web platform');
        return;
      }
      
      _isBluetoothEnabled = await _bluetoothService.initialize();
      if (_isBluetoothEnabled) {
        // Listen to device streams
        _bluetoothService.availableDevicesStream.listen((devices) {
          if (mounted) {
            setState(() {
              _availableDevices = devices;
            });
          }
        });

        _bluetoothService.deviceStatusStream.listen((device) {
          if (mounted) {
            setState(() {
              if (device.isConnected) {
                if (!_connectedDevices.any((d) => d.macAddress == device.macAddress)) {
                  _connectedDevices.add(device);
                }
              } else {
                _connectedDevices.removeWhere((d) => d.macAddress == device.macAddress);
              }
            });
          }
        });

        // Listen to real-time wearable data
        _bluetoothService.dataStream.listen((data) {
          if (mounted) {
            _updateWearableDataFromBluetooth(data);
          }
        });
      }
    } catch (e) {
      print('Error initializing Bluetooth: $e');
      if (mounted) {
        setState(() {
          _isBluetoothEnabled = false;
        });
      }
    }
  }

  void _updateWearableDataFromBluetooth(WearableData data) {
    setState(() {
      switch (data.dataType) {
        case WearableDataType.heartRate:
          // Update heart rate data with validation
          if (data.value > 0 && data.value < 300) { // Valid heart rate range
            wearableData['heartRate']['current'] = data.value.toInt();
            wearableData['heartRate']['isLive'] = true;
            wearableData['heartRate']['lastUpdate'] = DateTime.now();
            
            // Update min/max values
            if (wearableData['heartRate']['min'] == 0 || data.value < wearableData['heartRate']['min']) {
              wearableData['heartRate']['min'] = data.value.toInt();
            }
            if (data.value > wearableData['heartRate']['max']) {
              wearableData['heartRate']['max'] = data.value.toInt();
            }
            
            // Add to data array (keep last 24 hours of data)
            List<int> hrData = List<int>.from(wearableData['heartRate']['data']);
            hrData.add(data.value.toInt());
            if (hrData.length > 288) { // 24 hours * 12 (5-minute intervals)
              hrData.removeAt(0);
            }
            wearableData['heartRate']['data'] = hrData;
          }
          break;
          
        case WearableDataType.steps:
          // Update step count with validation
          if (data.value >= 0) { // Steps should be non-negative
            wearableData['steps']['current'] = data.value.toInt();
            wearableData['steps']['isLive'] = true;
            wearableData['steps']['lastUpdate'] = DateTime.now();
            
            // Add to hourly data array
            List<int> stepData = List<int>.from(wearableData['steps']['data']);
            stepData.add(data.value.toInt());
            if (stepData.length > 24) { // Keep 24 hours of hourly data
              stepData.removeAt(0);
            }
            wearableData['steps']['data'] = stepData;
          }
          break;
          
        case WearableDataType.oxygenSaturation:
          // Update blood oxygen with validation
          if (data.value >= 70 && data.value <= 100) { // Valid SpO2 range
            wearableData['bloodOxygen']['current'] = data.value.toInt();
            wearableData['bloodOxygen']['isLive'] = true;
            wearableData['bloodOxygen']['lastUpdate'] = DateTime.now();
            
            // Add to data array
            List<int> o2Data = List<int>.from(wearableData['bloodOxygen']['data']);
            o2Data.add(data.value.toInt());
            if (o2Data.length > 144) { // 12 hours * 12 (5-minute intervals)
              o2Data.removeAt(0);
            }
            wearableData['bloodOxygen']['data'] = o2Data;
          }
          break;
          
        case WearableDataType.temperature:
          // Update body temperature with validation
          if (data.value >= 30.0 && data.value <= 45.0) { // Valid body temperature range
            wearableData['temperature']['current'] = data.value;
            wearableData['temperature']['isLive'] = true;
            wearableData['temperature']['lastUpdate'] = DateTime.now();
            
            // Add to data array
            List<double> tempData = List<double>.from(wearableData['temperature']['data']);
            tempData.add(data.value);
            if (tempData.length > 144) { // 12 hours * 12 (5-minute intervals)
              tempData.removeAt(0);
            }
            wearableData['temperature']['data'] = tempData;
          }
          break;
          
        case WearableDataType.bloodPressure:
          // Update blood pressure with validation
          if (data.value >= 50 && data.value <= 250 && // Systolic range
              data.secondaryValue != null && 
              data.secondaryValue! >= 30 && data.secondaryValue! <= 150) { // Diastolic range
            wearableData['bloodPressure']['systolic'] = data.value.toInt();
            wearableData['bloodPressure']['diastolic'] = data.secondaryValue!.toInt();
            wearableData['bloodPressure']['lastReading'] = DateTime.now();
            wearableData['bloodPressure']['isLive'] = true;
          }
          break;
          
        case WearableDataType.sleep:
          // Update sleep data with validation
          if (data.value >= 0 && data.value <= 24) { // Valid sleep hours range
            wearableData['sleep']['totalHours'] = data.value;
            wearableData['sleep']['isLive'] = true;
            wearableData['sleep']['lastUpdate'] = DateTime.now();
            
            // If metadata contains sleep stage breakdown
            if (data.metadata != null) {
              var metadataJson = data.metadata!.toJson();
              if (metadataJson.containsKey('deepSleep')) {
                wearableData['sleep']['deepSleep'] = metadataJson['deepSleep'];
              }
              if (metadataJson.containsKey('lightSleep')) {
                wearableData['sleep']['lightSleep'] = metadataJson['lightSleep'];
              }
              if (metadataJson.containsKey('remSleep')) {
                wearableData['sleep']['remSleep'] = metadataJson['remSleep'];
              }
              if (metadataJson.containsKey('quality')) {
                wearableData['sleep']['quality'] = metadataJson['quality'];
              }
            }
          }
          break;
          
        default:
          break;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bluetoothService.dispose();
    super.dispose();
  }

  Future<void> loadWearableData() async {
    setState(() => isLoading = true);
    
    try {
      // Only load data if devices are connected
      if (_connectedDevices.isNotEmpty) {
        // Request fresh data from all connected devices
        for (var device in _connectedDevices) {
          await _requestDataFromDevice(device);
        }
        
        // Load historical data from backend API
        await _loadHistoricalData();
      } else {
        // Reset data when no devices are connected
        _resetWearableData();
      }
      
    } catch (e) {
      print('Error loading wearable data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _requestDataFromDevice(WearableDevice device) async {
    // Request current data from connected device
    if (device.capabilities.contains(WearableCapability.heartRate)) {
      // Send command to get heart rate data
      // This would be implemented based on device protocol
    }
    
    if (device.capabilities.contains(WearableCapability.steps)) {
      // Send command to get step count
      // This would be implemented based on device protocol
    }
    
    if (device.capabilities.contains(WearableCapability.oxygenSaturation)) {
      // Send command to get SpO2 data
      // This would be implemented based on device protocol
    }
    
    // Add other data types as needed
  }

  Future<void> _loadHistoricalData() async {
    // Load historical data from backend API for charts
    try {
      // This would make API calls to get stored wearable data
      // For now, we'll only use real-time data from devices
      print('Loading historical data from API...');
    } catch (e) {
      print('Error loading historical data: $e');
    }
  }

  void _resetWearableData() {
    setState(() {
      wearableData = {
        'heartRate': {
          'current': 0,
          'min': 0,
          'max': 0,
          'data': <int>[],
          'isLive': false,
        },
        'steps': {
          'current': 0,
          'goal': 10000,
          'data': <int>[],
          'isLive': false,
        },
        'sleep': {
          'totalHours': 0.0,
          'deepSleep': 0.0,
          'lightSleep': 0.0,
          'remSleep': 0.0,
          'quality': 0,
          'isLive': false,
        },
        'bloodPressure': {
          'systolic': 0,
          'diastolic': 0,
          'lastReading': DateTime.now(),
          'isLive': false,
        },
        'bloodOxygen': {
          'current': 0,
          'data': <int>[],
          'isLive': false,
        },
        'temperature': {
          'current': 0.0,
          'data': <double>[],
          'isLive': false,
        },
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.white,
              Colors.green.shade50,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Modern App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.purple.shade600,
                        Colors.purple.shade800,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.watch,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Wearable Data',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Real-time health monitoring',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                title: Text(
                  'Health Metrics',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              actions: [
                Container(
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      _connectedDevices.isNotEmpty ? Icons.bluetooth_connected : Icons.bluetooth,
                      color: _connectedDevices.isNotEmpty ? Colors.green : Colors.white,
                    ),
                    onPressed: _showBluetoothDialog,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.sync, color: Colors.white),
                    onPressed: loadWearableData,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: PopupMenuButton<String>(
                    icon: Icon(Icons.access_time, color: Colors.white),
                    onSelected: (value) {
                      setState(() => selectedTimeRange = value);
                      loadWearableData();
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'Today', child: Text('Today')),
                      PopupMenuItem(value: 'Week', child: Text('This Week')),
                      PopupMenuItem(value: 'Month', child: Text('This Month')),
                    ],
                  ),
                ),
              ],
            ),
            
            // Content
            SliverToBoxAdapter(
              child: isLoading
                  ? _buildLoadingState()
                  : Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Quick Stats
                          _buildQuickStats(),
                          SizedBox(height: 24),
                          
                          // Tabs for different metrics
                          _buildMetricsTabs(),
                          SizedBox(height: 100),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 15,
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade600),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Syncing wearable data...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Real-time Health Data',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              if (_connectedDevices.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickStatCard(
                  'Heart Rate',
                  wearableData['heartRate']['current'] > 0 
                      ? '${wearableData['heartRate']['current']} bpm'
                      : 'No data',
                  Icons.favorite,
                  Colors.red,
                  wearableData['heartRate']['isLive'] ? 'Live data' : 'Connect device',
                  wearableData['heartRate']['isLive'],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildQuickStatCard(
                  'Steps',
                  wearableData['steps']['current'] > 0
                      ? NumberFormat('#,###').format(wearableData['steps']['current'])
                      : 'No data',
                  Icons.directions_walk,
                  Colors.blue,
                  wearableData['steps']['isLive']
                      ? '${((wearableData['steps']['current'] / wearableData['steps']['goal']) * 100).toInt()}% of goal'
                      : 'Connect device',
                  wearableData['steps']['isLive'],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickStatCard(
                  'Sleep',
                  wearableData['sleep']['totalHours'] > 0
                      ? '${wearableData['sleep']['totalHours']}h'
                      : 'No data',
                  Icons.bedtime,
                  Colors.purple,
                  wearableData['sleep']['isLive']
                      ? '${wearableData['sleep']['quality']}% quality'
                      : 'Connect device',
                  wearableData['sleep']['isLive'],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildQuickStatCard(
                  'Blood O2',
                  wearableData['bloodOxygen']['current'] > 0
                      ? '${wearableData['bloodOxygen']['current']}%'
                      : 'No data',
                  Icons.air,
                  Colors.teal,
                  wearableData['bloodOxygen']['isLive'] ? 'Live reading' : 'Connect device',
                  wearableData['bloodOxygen']['isLive'],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard(String title, String value, IconData icon, Color color, String status, bool isLive) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isLive)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isLive ? color : Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 10,
              color: isLive ? Colors.grey.shade500 : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.purple.shade600,
                borderRadius: BorderRadius.circular(20),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              isScrollable: true,
              tabs: [
                Tab(text: 'Devices'),
                Tab(text: 'Heart'),
                Tab(text: 'Activity'),
                Tab(text: 'Sleep'),
                Tab(text: 'Vitals'),
              ],
            ),
          ),
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBluetoothDevicesTab(),
                _buildHeartRateTab(),
                _buildActivityTab(),
                _buildSleepTab(),
                _buildVitalsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartRateTab() {
    bool hasData = wearableData['heartRate']['isLive'] && wearableData['heartRate']['data'].isNotEmpty;
    
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Heart Rate Monitoring',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              if (wearableData['heartRate']['isLive'])
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: Colors.green, size: 8),
                      SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),
          
          if (!hasData)
            _buildNoDataMessage(
              'Connect a wearable device to see real-time heart rate data',
              Icons.favorite,
              Colors.red,
            )
          else ...[
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: wearableData['heartRate']['data']
                          .asMap()
                          .entries
                          .map<FlSpot>((entry) => FlSpot(entry.key.toDouble(), entry.value.toDouble()))
                          .toList(),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.red.withOpacity(0.1),
                      ),
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricSummary('Current', '${wearableData['heartRate']['current']} bpm', Colors.red),
                _buildMetricSummary('Min', '${wearableData['heartRate']['min']} bpm', Colors.green),
                _buildMetricSummary('Max', '${wearableData['heartRate']['max']} bpm', Colors.orange),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    double progressPercentage = wearableData['steps']['current'] / wearableData['steps']['goal'];
    
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                children: [
                  CircularProgressIndicator(
                    value: progressPercentage,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          NumberFormat('#,###').format(wearableData['steps']['current']),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        Text(
                          'steps',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricSummary('Goal', NumberFormat('#,###').format(wearableData['steps']['goal']), Colors.green),
              _buildMetricSummary('Remaining', NumberFormat('#,###').format(wearableData['steps']['goal'] - wearableData['steps']['current']), Colors.orange),
              _buildMetricSummary('Progress', '${(progressPercentage * 100).toInt()}%', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSleepTab() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sleep Analysis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.bedtime, color: Colors.purple, size: 40),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${wearableData['sleep']['totalHours']} hours',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    Text(
                      'Total sleep time',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSleepStageCard('Deep Sleep', wearableData['sleep']['deepSleep'], Colors.indigo),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildSleepStageCard('Light Sleep', wearableData['sleep']['lightSleep'], Colors.blue),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildSleepStageCard('REM Sleep', wearableData['sleep']['remSleep'], Colors.purple),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.star, color: Colors.green, size: 24),
                SizedBox(width: 12),
                Text(
                  'Sleep Quality: ${wearableData['sleep']['quality']}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsTab() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vital Signs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 16),
          _buildVitalCard(
            'Blood Pressure',
            '${wearableData['bloodPressure']['systolic']}/${wearableData['bloodPressure']['diastolic']} mmHg',
            Icons.monitor_heart,
            Colors.red,
            'Last reading: ${DateFormat('HH:mm').format(wearableData['bloodPressure']['lastReading'] ?? DateTime.now())}',
          ),
          SizedBox(height: 12),
          _buildVitalCard(
            'Blood Oxygen',
            '${wearableData['bloodOxygen']['current']}%',
            Icons.air,
            Colors.teal,
            'Excellent level',
          ),
          SizedBox(height: 12),
          _buildVitalCard(
            'Body Temperature',
            '${wearableData['temperature']['current']}°C',
            Icons.thermostat,
            Colors.orange,
            'Normal range',
          ),
        ],
      ),
    );
  }

  Widget _buildMetricSummary(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSleepStageCard(String stage, double hours, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '${hours}h',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            stage,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVitalCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBluetoothDevicesTab() {
    // Show web-specific message if running on web
    if (kIsWeb) {
      return SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wearable Devices',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.orange.shade50,
                    Colors.orange.shade100,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.web,
                    size: 64,
                    color: Colors.orange.shade400,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Web Platform Limitation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Bluetooth device connectivity is not supported on web browsers for security reasons.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.mobile_friendly, color: Colors.blue.shade600),
                        SizedBox(height: 8),
                        Text(
                          'To connect wearable devices:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• Use the mobile app (Android/iOS)\n• Download from app store\n• Full Bluetooth support available',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Could implement web-based data import or demo mode
                          _showWebDataImportDialog();
                        },
                        icon: Icon(Icons.upload_file),
                        label: Text('Import Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          // Show demo mode with sample data
                          _showDemoModeDialog();
                        },
                        icon: Icon(Icons.play_arrow),
                        label: Text('Demo Mode'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange.shade600,
                          side: BorderSide(color: Colors.orange.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Original Bluetooth devices tab for mobile platforms
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bluetooth Devices',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isScanning ? null : _startDeviceScan,
                icon: _isScanning 
                    ? SizedBox(
                        width: 16, 
                        height: 16, 
                        child: CircularProgressIndicator(strokeWidth: 2)
                      )
                    : Icon(Icons.search),
                label: Text(_isScanning ? 'Scanning...' : 'Scan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // Connected Devices Section
          if (_connectedDevices.isNotEmpty) ...[
            Text(
              'Connected Devices (${_connectedDevices.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade700,
              ),
            ),
            SizedBox(height: 8),
            ..._connectedDevices.map((device) => _buildDeviceCard(device, true)),
            SizedBox(height: 16),
          ],
          
          // Available Devices Section
          Text(
            'Available Devices (${_availableDevices.length})',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          
          if (_availableDevices.isEmpty && !_isScanning)
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.bluetooth_disabled, size: 48, color: Colors.grey.shade400),
                    SizedBox(height: 12),
                    Text(
                      'No devices found',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Make sure your wearable device is in pairing mode',
                      style: TextStyle(color: Colors.grey.shade500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: List.generate(_availableDevices.length, (index) {
                return _buildDeviceCard(_availableDevices[index], false);
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(WearableDevice device, bool isConnected) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isConnected ? Colors.green.shade200 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isConnected ? Colors.green.shade100 : Colors.purple.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getDeviceIcon(device.deviceType),
              color: isConnected ? Colors.green.shade600 : Colors.purple.shade600,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.deviceName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  '${device.manufacturer} ${device.model}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (isConnected) ...[
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.battery_std, size: 16, color: Colors.green.shade600),
                      SizedBox(width: 4),
                      Text(
                        '${device.batteryLevel}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.access_time, size: 16, color: Colors.grey.shade500),
                      SizedBox(width: 4),
                      Text(
                        'Last sync: ${DateFormat('HH:mm').format(device.lastSyncTime)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => isConnected 
                ? _disconnectDevice(device)
                : _connectDevice(device),
            style: ElevatedButton.styleFrom(
              backgroundColor: isConnected ? Colors.red.shade600 : Colors.purple.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              isConnected ? 'Disconnect' : 'Connect',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
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
        return Icons.favorite;
      case WearableDeviceType.bloodPressureMonitor:
        return Icons.monitor_heart;
      case WearableDeviceType.pulseOximeter:
        return Icons.air;
    }
  }

  void _startDeviceScan() async {
    if (!_isBluetoothEnabled) {
      _showBluetoothNotEnabledDialog();
      return;
    }
    
    setState(() {
      _isScanning = true;
    });
    
    await _bluetoothService.startDeviceScan(duration: Duration(seconds: 15));
    
    // Stop scanning after 15 seconds
    Future.delayed(Duration(seconds: 15), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    });
  }

  void _connectDevice(WearableDevice device) async {
    try {
      bool success = await _bluetoothService.connectToDevice(
        device, 
        widget.userData['_id'] ?? '',
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connected to ${device.deviceName}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        throw Exception('Connection failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _disconnectDevice(WearableDevice device) async {
    try {
      bool success = await _bluetoothService.disconnectDevice(device);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Disconnected from ${device.deviceName}'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to disconnect: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showBluetoothDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.bluetooth, color: Colors.purple.shade600),
            SizedBox(width: 8),
            Text('Bluetooth Devices'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Connected: ${_connectedDevices.length} devices'),
            Text('Available: ${_availableDevices.length} devices'),
            SizedBox(height: 16),
            Text(
              'Go to the Devices tab to manage your wearable connections.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _tabController.animateTo(0); // Switch to Devices tab
            },
            child: Text('Manage Devices'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBluetoothNotEnabledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.bluetooth_disabled, color: Colors.red),
            SizedBox(width: 8),
            Text('Bluetooth Disabled'),
          ],
        ),
        content: Text(
          'Bluetooth is not enabled. Please enable Bluetooth in your device settings to connect to wearable devices.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataMessage(String message, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 48,
                color: color.withOpacity(0.5),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'No Real Device Data',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _tabController.animateTo(0); // Switch to Devices tab
              },
              icon: Icon(Icons.bluetooth),
              label: Text('Connect Device'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWebDataImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.upload_file, color: Colors.blue.shade600),
            SizedBox(width: 8),
            Text('Import Health Data'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Import health data from various sources:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Text('• CSV files from fitness apps'),
            Text('• Apple Health exports'),
            Text('• Google Fit data'),
            Text('• Manual data entry'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Note: This feature is coming soon for web platform.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDemoModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.play_arrow, color: Colors.orange.shade600),
            SizedBox(width: 8),
            Text('Demo Mode'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Demo mode will simulate wearable device data for testing purposes.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Text('Demo data includes:'),
            Text('• Simulated heart rate readings'),
            Text('• Step count progression'),
            Text('• Blood oxygen levels'),
            Text('• Sleep tracking data'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Demo data is for testing only and not real health metrics.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startDemoMode();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text('Start Demo'),
          ),
        ],
      ),
    );
  }

  void _startDemoMode() {
    // This could implement a demo mode with simulated data for web testing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Demo mode is coming soon for web platform'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
