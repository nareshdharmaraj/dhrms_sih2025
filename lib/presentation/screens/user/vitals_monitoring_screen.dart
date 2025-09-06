import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';

class VitalsMonitoringScreen extends StatefulWidget {
  const VitalsMonitoringScreen({super.key});

  @override
  State<VitalsMonitoringScreen> createState() => _VitalsMonitoringScreenState();
}

class _VitalsMonitoringScreenState extends State<VitalsMonitoringScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _isConnected = false;
  bool _isMonitoring = false;

  // Current vital readings
  final Map<String, VitalReading> _currentVitals = {
    'heartRate': VitalReading(
      value: 72,
      unit: 'bpm',
      status: VitalStatus.normal,
      lastUpdated: DateTime.now(),
    ),
    'bloodPressure': VitalReading(
      value: 120,
      unit: 'mmHg',
      status: VitalStatus.normal,
      lastUpdated: DateTime.now(),
      secondaryValue: 80,
    ),
    'temperature': VitalReading(
      value: 98.6,
      unit: '°F',
      status: VitalStatus.normal,
      lastUpdated: DateTime.now(),
    ),
    'oxygenSaturation': VitalReading(
      value: 98,
      unit: '%',
      status: VitalStatus.normal,
      lastUpdated: DateTime.now(),
    ),
    'respiratoryRate': VitalReading(
      value: 16,
      unit: '/min',
      status: VitalStatus.normal,
      lastUpdated: DateTime.now(),
    ),
  };

  // Vital history for charts
  final List<VitalHistory> _heartRateHistory = [
    VitalHistory(DateTime.now().subtract(const Duration(hours: 4)), 68),
    VitalHistory(DateTime.now().subtract(const Duration(hours: 3)), 72),
    VitalHistory(DateTime.now().subtract(const Duration(hours: 2)), 75),
    VitalHistory(DateTime.now().subtract(const Duration(hours: 1)), 70),
    VitalHistory(DateTime.now(), 72),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _toggleConnection() {
    setState(() {
      _isConnected = !_isConnected;
    });

    if (_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connected to smartwatch'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      setState(() {
        _isMonitoring = false;
      });
      _pulseController.stop();
    }
  }

  void _toggleMonitoring() {
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please connect your device first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isMonitoring = !_isMonitoring;
    });

    if (_isMonitoring) {
      _pulseController.repeat(reverse: true);
      // Simulate real-time updates
      _startVitalUpdates();
    } else {
      _pulseController.stop();
    }
  }

  void _startVitalUpdates() {
    // Simulate real-time vital updates
    Future.delayed(const Duration(seconds: 2), () {
      if (_isMonitoring) {
        // Update heart rate
        setState(() {
          _currentVitals['heartRate'] = VitalReading(
            value: 70 + (DateTime.now().millisecond % 10),
            unit: 'bpm',
            status: VitalStatus.normal,
            lastUpdated: DateTime.now(),
          );
        });
        _startVitalUpdates();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Vitals Monitoring'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
          indicatorColor: AppColors.white,
          tabs: const [
            Tab(text: 'Live', icon: Icon(Icons.monitor_heart)),
            Tab(text: 'History', icon: Icon(Icons.timeline)),
            Tab(text: 'Settings', icon: Icon(Icons.settings)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
            ),
            onPressed: _toggleConnection,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildLiveTab(), _buildHistoryTab(), _buildSettingsTab()],
      ),
    );
  }

  Widget _buildLiveTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connection status card
          _buildConnectionCard(),
          const SizedBox(height: AppDimensions.marginLarge),

          // Live vitals grid
          Text(
            'Current Vitals',
            style: AppTextStyles.headline6.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.marginMedium),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: AppDimensions.marginMedium,
            mainAxisSpacing: AppDimensions.marginMedium,
            childAspectRatio: 1.1,
            children: [
              _buildVitalCard(
                'Heart Rate',
                _currentVitals['heartRate']!,
                Icons.favorite,
                AppColors.error,
              ),
              _buildVitalCard(
                'Blood Pressure',
                _currentVitals['bloodPressure']!,
                Icons.monitor_weight,
                AppColors.primaryBlue,
              ),
              _buildVitalCard(
                'Temperature',
                _currentVitals['temperature']!,
                Icons.thermostat,
                AppColors.primaryOrange,
              ),
              _buildVitalCard(
                'Oxygen Saturation',
                _currentVitals['oxygenSaturation']!,
                Icons.air,
                AppColors.primaryGreen,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.marginLarge),

          // Quick actions
          Text(
            'Quick Actions',
            style: AppTextStyles.headline6.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.marginMedium),

          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Take ECG',
                  Icons.monitor_heart,
                  AppColors.primaryBlue,
                  () => _takeECG(),
                ),
              ),
              const SizedBox(width: AppDimensions.marginMedium),
              Expanded(
                child: _buildActionButton(
                  'Check Pulse',
                  Icons.favorite,
                  AppColors.error,
                  () => _checkPulse(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.marginMedium),

          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Blood Oxygen',
                  Icons.air,
                  AppColors.primaryGreen,
                  () => _checkBloodOxygen(),
                ),
              ),
              const SizedBox(width: AppDimensions.marginMedium),
              Expanded(
                child: _buildActionButton(
                  'Sleep Analysis',
                  Icons.bedtime,
                  AppColors.primaryBlue,
                  () => _analyzeSleep(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time period selector
          Row(
            children: [
              Text(
                'Time Period:',
                style: AppTextStyles.subtitle1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppDimensions.marginMedium),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTimePeriodChip('Today', true),
                      _buildTimePeriodChip('Week', false),
                      _buildTimePeriodChip('Month', false),
                      _buildTimePeriodChip('Year', false),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.marginLarge),

          // Heart rate chart
          _buildVitalChart(
            'Heart Rate Trends',
            _heartRateHistory,
            'bpm',
            AppColors.error,
          ),
          const SizedBox(height: AppDimensions.marginLarge),

          // Summary statistics
          Text(
            'Today\'s Summary',
            style: AppTextStyles.headline6.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.marginMedium),

          _buildSummaryCard(),
          const SizedBox(height: AppDimensions.marginLarge),

          // Recent readings
          Text(
            'Recent Readings',
            style: AppTextStyles.headline6.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.marginMedium),

          ..._currentVitals.entries.map(
            (entry) =>
                _buildHistoryItem(_getVitalDisplayName(entry.key), entry.value),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      children: [
        // Device settings
        Text(
          'Device Settings',
          style: AppTextStyles.headline6.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppDimensions.marginMedium),

        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.bluetooth),
                title: const Text('Connected Devices'),
                subtitle: Text(
                  _isConnected
                      ? 'Apple Watch Series 8'
                      : 'No devices connected',
                ),
                trailing: Switch(
                  value: _isConnected,
                  onChanged: (_) => _toggleConnection(),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.sync),
                title: const Text('Auto Sync'),
                subtitle: const Text('Automatically sync vital data'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Toggle auto sync
                  },
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.battery_charging_full),
                title: const Text('Battery Optimization'),
                subtitle: const Text('Optimize for battery life'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Battery settings
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.marginLarge),

        // Alert settings
        Text(
          'Alert Settings',
          style: AppTextStyles.headline6.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppDimensions.marginMedium),

        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.warning),
                title: const Text('High Heart Rate Alert'),
                subtitle: const Text('Alert when HR > 100 bpm'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Toggle HR alert
                  },
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.warning),
                title: const Text('Low Heart Rate Alert'),
                subtitle: const Text('Alert when HR < 60 bpm'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Toggle low HR alert
                  },
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.local_hospital),
                title: const Text('Emergency Contacts'),
                subtitle: const Text('Manage emergency contacts'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Manage emergency contacts
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.marginLarge),

        // Data settings
        Text(
          'Data & Privacy',
          style: AppTextStyles.headline6.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppDimensions.marginMedium),

        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Export Data'),
                subtitle: const Text('Download your vital data'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Export data
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Clear Data'),
                subtitle: const Text('Delete all stored vital data'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Clear data
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isMonitoring ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isConnected
                          ? AppColors.success
                          : AppColors.grey400,
                      boxShadow: _isMonitoring
                          ? [
                              BoxShadow(
                                color: AppColors.success.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      _isConnected ? Icons.watch : Icons.watch_off,
                      color: AppColors.white,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            Text(
              _isConnected ? 'Device Connected' : 'Device Disconnected',
              style: AppTextStyles.subtitle1.copyWith(
                fontWeight: FontWeight.bold,
                color: _isConnected ? AppColors.success : AppColors.grey600,
              ),
            ),
            const SizedBox(height: AppDimensions.marginSmall),

            Text(
              _isConnected
                  ? 'Apple Watch Series 8'
                  : 'Connect your smartwatch to start monitoring',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.marginLarge),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isConnected ? _toggleMonitoring : _toggleConnection,
                icon: Icon(
                  _isConnected
                      ? (_isMonitoring ? Icons.stop : Icons.play_arrow)
                      : Icons.bluetooth,
                ),
                label: Text(
                  _isConnected
                      ? (_isMonitoring ? 'Stop Monitoring' : 'Start Monitoring')
                      : 'Connect Device',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isConnected
                      ? (_isMonitoring ? AppColors.error : AppColors.success)
                      : AppColors.primaryBlue,
                  foregroundColor: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalCard(
    String title,
    VitalReading reading,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: AppDimensions.marginSmall),

            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.marginSmall),

            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: reading.secondaryValue != null
                        ? '${reading.value.toInt()}/${reading.secondaryValue!.toInt()}'
                        : reading.value.toString(),
                    style: AppTextStyles.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(reading.status),
                    ),
                  ),
                  TextSpan(
                    text: ' ${reading.unit}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.marginSmall),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingSmall,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(reading.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Text(
                _getStatusText(reading.status),
                style: AppTextStyles.bodySmall.copyWith(
                  color: _getStatusColor(reading.status),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: AppDimensions.marginSmall),
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePeriodChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: AppDimensions.marginSmall),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          // TODO: Filter by time period
        },
        selectedColor: AppColors.primaryBlue.withValues(alpha: 0.2),
        checkmarkColor: AppColors.primaryBlue,
      ),
    );
  }

  Widget _buildVitalChart(
    String title,
    List<VitalHistory> data,
    String unit,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.subtitle1.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey300),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: const Center(
                child: Text(
                  'Chart visualization would go here\n(Line chart showing vital trends)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.grey500),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildChartStat('Min', '68', unit),
                _buildChartStat('Max', '78', unit),
                _buildChartStat('Avg', '72', unit),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartStat(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: AppTextStyles.subtitle1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey900,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Steps',
                    '8,450',
                    Icons.directions_walk,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Calories',
                    '320',
                    Icons.local_fire_department,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Active Time',
                    '2h 15m',
                    Icons.fitness_center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 24),
        const SizedBox(height: AppDimensions.marginSmall),
        Text(
          value,
          style: AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(String title, VitalReading reading) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginSmall),
      child: ListTile(
        title: Text(title),
        subtitle: Text(_formatDateTime(reading.lastUpdated)),
        trailing: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: reading.secondaryValue != null
                    ? '${reading.value.toInt()}/${reading.secondaryValue!.toInt()}'
                    : reading.value.toString(),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(reading.status),
                ),
              ),
              TextSpan(
                text: ' ${reading.unit}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(VitalStatus status) {
    switch (status) {
      case VitalStatus.normal:
        return AppColors.success;
      case VitalStatus.warning:
        return AppColors.warning;
      case VitalStatus.critical:
        return AppColors.error;
    }
  }

  String _getStatusText(VitalStatus status) {
    switch (status) {
      case VitalStatus.normal:
        return 'Normal';
      case VitalStatus.warning:
        return 'Warning';
      case VitalStatus.critical:
        return 'Critical';
    }
  }

  String _getVitalDisplayName(String key) {
    switch (key) {
      case 'heartRate':
        return 'Heart Rate';
      case 'bloodPressure':
        return 'Blood Pressure';
      case 'temperature':
        return 'Temperature';
      case 'oxygenSaturation':
        return 'Oxygen Saturation';
      case 'respiratoryRate':
        return 'Respiratory Rate';
      default:
        return key;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _takeECG() {
    // TODO: Implement ECG functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('ECG feature coming soon')));
  }

  void _checkPulse() {
    // TODO: Implement pulse check
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Place finger on camera to check pulse')),
    );
  }

  void _checkBloodOxygen() {
    // TODO: Implement blood oxygen check
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Blood oxygen check starting...')),
    );
  }

  void _analyzeSleep() {
    // TODO: Implement sleep analysis
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sleep analysis feature coming soon')),
    );
  }
}

enum VitalStatus { normal, warning, critical }

class VitalReading {
  final double value;
  final double? secondaryValue;
  final String unit;
  final VitalStatus status;
  final DateTime lastUpdated;

  VitalReading({
    required this.value,
    this.secondaryValue,
    required this.unit,
    required this.status,
    required this.lastUpdated,
  });
}

class VitalHistory {
  final DateTime timestamp;
  final double value;

  VitalHistory(this.timestamp, this.value);
}
