import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../services/wearable_service.dart';
import '../widgets/custom_button.dart';

class WearablesScreen extends StatefulWidget {
  final String patientId;

  const WearablesScreen({
    super.key,
    required this.patientId,
  });

  @override
  State<WearablesScreen> createState() => _WearablesScreenState();
}

class _WearablesScreenState extends State<WearablesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<Map<String, dynamic>> _devices = [];
  Map<String, dynamic>? _latestData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final deviceResponse = await WearableService.getPatientDevices(widget.patientId);
      if (deviceResponse['success']) {
        _devices = List<Map<String, dynamic>>.from(deviceResponse['data']['devices'] ?? []);
      }
      
      final dataResponse = await WearableService.getLatestData(patientId: widget.patientId);
      if (dataResponse['success']) {
        _latestData = dataResponse['data'];
      }
    } catch (e) {
      print('Error loading wearable data: $e');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wearable Devices'),
        backgroundColor: AppConstants.primaryBlue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.devices), text: 'Devices'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.warning), text: 'Alerts'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
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
    final connectedDevices = _devices.where((d) => d['connectionStatus'] == 'connected').toList();
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConnectionStatus(connectedDevices),
          SizedBox(height: 20),
          if (_latestData != null) _buildLatestReadings(),
          SizedBox(height: 20),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(List<Map<String, dynamic>> connectedDevices) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  connectedDevices.isNotEmpty ? Icons.check_circle : Icons.warning,
                  color: connectedDevices.isNotEmpty ? Colors.green : Colors.orange,
                ),
                SizedBox(width: 8),
                Text(
                  'Device Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              connectedDevices.isNotEmpty
                  ? '${connectedDevices.length} device(s) connected'
                  : 'No devices connected',
              style: TextStyle(
                fontSize: 16,
                color: connectedDevices.isNotEmpty ? Colors.green : Colors.orange,
              ),
            ),
            if (connectedDevices.isNotEmpty)
              Column(
                children: connectedDevices.map((device) => ListTile(
                  leading: Icon(Icons.watch),
                  title: Text(device['deviceName'] ?? 'Unknown Device'),
                  subtitle: Text(device['deviceType']?.toString().split('.').last ?? 'Unknown Type'),
                  trailing: Icon(Icons.circle, color: Colors.green, size: 12),
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestReadings() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Latest Readings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                if (_latestData!['heartRate'] != null)
                  _buildReadingCard(
                    'Heart Rate',
                    '${_latestData!['heartRate']} bpm',
                    Icons.favorite,
                    Colors.red,
                  ),
                if (_latestData!['oxygenLevel'] != null)
                  _buildReadingCard(
                    'SpO2',
                    '${_latestData!['oxygenLevel']}%',
                    Icons.opacity,
                    Colors.blue,
                  ),
                if (_latestData!['steps'] != null)
                  _buildReadingCard(
                    'Steps',
                    '${_latestData!['steps']}',
                    Icons.directions_walk,
                    Colors.green,
                  ),
                if (_latestData!['calories'] != null)
                  _buildReadingCard(
                    'Calories',
                    '${_latestData!['calories']}',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Sync Data',
                    onPressed: _loadData,
                    icon: Icons.sync,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    text: 'Connect Device',
                    onPressed: () => _tabController.animateTo(1),
                    backgroundColor: AppConstants.secondaryBlue,
                    icon: Icons.bluetooth,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevicesTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connected Devices',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: _devices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.devices, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No devices registered',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 16),
                        CustomButton(
                          text: 'Add Device',
                          onPressed: () {
                            // TODO: Implement device addition
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Device addition coming soon!')),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.watch,
                            color: device['connectionStatus'] == 'connected'
                                ? Colors.green
                                : Colors.grey,
                          ),
                          title: Text(device['deviceName'] ?? 'Unknown Device'),
                          subtitle: Text(
                            '${device['deviceType']?.toString().split('.').last ?? 'Unknown'} • ${device['connectionStatus'] ?? 'Unknown'}',
                          ),
                          trailing: device['connectionStatus'] == 'connected'
                              ? Icon(Icons.circle, color: Colors.green, size: 12)
                              : Icon(Icons.circle, color: Colors.grey, size: 12),
                          onTap: () {
                            // TODO: Show device details
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Device details coming soon!')),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Health Analytics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Analytics Dashboard',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Detailed analytics and trends coming soon!',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Health Alerts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No Alerts',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Health alerts and notifications will appear here',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
