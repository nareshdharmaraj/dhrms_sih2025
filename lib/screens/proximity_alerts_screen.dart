import 'package:flutter/material.dart';
import '../core/services/geolocation_service.dart';

class ProximityAlertsScreen extends StatefulWidget {
  const ProximityAlertsScreen({super.key});

  @override
  State<ProximityAlertsScreen> createState() => _ProximityAlertsScreenState();
}

class _ProximityAlertsScreenState extends State<ProximityAlertsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _allAlerts = [];
  List<Map<String, dynamic>> _highRiskAlerts = [];
  Map<String, dynamic> _areaStats = {};
  bool _isLoading = false;
  bool _notificationsEnabled = true;
  double _alertRadius = 5.0; // km

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _allAlerts = GeolocationService.getProximityAlerts(
        maxDistance: _alertRadius,
      );
      _highRiskAlerts = GeolocationService.getHighRiskAlerts();
      _areaStats = GeolocationService.getAreaHealthStats();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Health Alerts'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.orange[200],
          tabs: const [
            Tab(icon: Icon(Icons.warning), text: 'All Alerts'),
            Tab(icon: Icon(Icons.priority_high), text: 'High Risk'),
            Tab(icon: Icon(Icons.analytics), text: 'Statistics'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAllAlertsTab(),
                _buildHighRiskTab(),
                _buildStatisticsTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _reportNewAlert,
        backgroundColor: Colors.orange[700],
        child: const Icon(Icons.add_alert),
      ),
    );
  }

  Widget _buildAllAlertsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Alert Summary Card
          Card(
            color: _highRiskAlerts.isNotEmpty
                ? Colors.red[50]
                : Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    _highRiskAlerts.isNotEmpty
                        ? Icons.warning
                        : Icons.check_circle,
                    color: _highRiskAlerts.isNotEmpty
                        ? Colors.red[700]
                        : Colors.green[700],
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _highRiskAlerts.isNotEmpty
                              ? 'Health Alerts in Your Area'
                              : 'Your Area is Safe',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _highRiskAlerts.isNotEmpty
                                ? Colors.red[700]
                                : Colors.green[700],
                          ),
                        ),
                        Text(
                          _highRiskAlerts.isNotEmpty
                              ? '${_allAlerts.length} active alerts within ${_alertRadius.round()}km'
                              : 'No high-risk health alerts in your vicinity',
                          style: TextStyle(
                            color: _highRiskAlerts.isNotEmpty
                                ? Colors.red[600]
                                : Colors.green[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_notificationsEnabled)
                    Icon(Icons.notifications_active, color: Colors.blue[700]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Filter Options
          Row(
            children: [
              const Text(
                'Alert Radius: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Slider(
                  value: _alertRadius,
                  min: 1.0,
                  max: 20.0,
                  divisions: 19,
                  label: '${_alertRadius.round()} km',
                  onChanged: (value) {
                    setState(() {
                      _alertRadius = value;
                    });
                  },
                  onChangeEnd: (value) {
                    _loadData();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Alert List
          if (_allAlerts.isEmpty)
            _buildNoAlertsCard()
          else
            ..._allAlerts.map((alert) => _buildAlertCard(alert)),
        ],
      ),
    );
  }

  Widget _buildHighRiskTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // High Risk Warning
        if (_highRiskAlerts.isNotEmpty)
          Card(
            color: Colors.red[100],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.emergency, color: Colors.red[700], size: 48),
                  const SizedBox(height: 8),
                  Text(
                    'HIGH RISK AREA',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  Text(
                    'Multiple high-severity health alerts detected',
                    style: TextStyle(color: Colors.red[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _showEmergencyContacts,
                    icon: const Icon(Icons.phone),
                    label: const Text('Emergency Contacts'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        // High Risk Alerts
        if (_highRiskAlerts.isEmpty)
          Card(
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.verified_user, color: Colors.green[700], size: 48),
                  const SizedBox(height: 8),
                  Text(
                    'No High Risk Alerts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  Text(
                    'Your area is currently safe from high-risk health threats',
                    style: TextStyle(color: Colors.green[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ..._highRiskAlerts
              .map((alert) => _buildAlertCard(alert, isHighRisk: true))
              ,
      ],
    );
  }

  Widget _buildStatisticsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Area Overview
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Area Health Overview',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildStatRow(
                  'Coverage Radius',
                  _areaStats['coverageRadius'] ?? 'N/A',
                ),
                _buildStatRow(
                  'Total Hospitals',
                  '${_areaStats['totalHospitals'] ?? 0}',
                ),
                _buildStatRow(
                  'Emergency Services',
                  '${_areaStats['emergencyHospitals'] ?? 0}',
                ),
                _buildStatRow(
                  'Available Beds',
                  '${_areaStats['availableBeds'] ?? 0}',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Alert Statistics
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alert Statistics',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildStatRow('Active Alerts', '${_allAlerts.length}'),
                _buildStatRow('High Risk Alerts', '${_highRiskAlerts.length}'),
                _buildStatRow(
                  'Medium Risk Alerts',
                  '${_allAlerts.where((a) => a['severity'] == 'Medium').length}',
                ),
                _buildStatRow(
                  'Low Risk Alerts',
                  '${_allAlerts.where((a) => a['severity'] == 'Low').length}',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Disease Distribution
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Disease Distribution',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ..._getDiseaseDistribution().entries
                    .map(
                      (entry) => _buildDiseaseStatRow(entry.key, entry.value),
                    )
                    ,
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Safety Recommendations
        Card(
          color: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.health_and_safety, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Safety Recommendations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._getSafetyRecommendations()
                    .map(
                      (rec) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• '),
                            Expanded(child: Text(rec)),
                          ],
                        ),
                      ),
                    )
                    ,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoAlertsCard() {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green[700], size: 64),
            const SizedBox(height: 16),
            Text(
              'All Clear!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No health alerts in your area within ${_alertRadius.round()}km radius.',
              style: TextStyle(color: Colors.green[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Stay safe and follow general health guidelines.',
              style: TextStyle(
                color: Colors.green[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(
    Map<String, dynamic> alert, {
    bool isHighRisk = false,
  }) {
    Color alertColor = alert['severity'] == 'High'
        ? Colors.red
        : alert['severity'] == 'Medium'
        ? Colors.orange
        : Colors.yellow[700]!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isHighRisk ? 8 : 2,
      child: Container(
        decoration: isHighRisk
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red, width: 2),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: alertColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      alert['type'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: alertColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      alert['severity'],
                      style: TextStyle(
                        color: alertColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${alert['location']} (${alert['distance']} km away)',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${alert['affectedCount']} confirmed cases',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Text(
                    alert['reportedTime'],
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ExpansionTile(
                title: const Text('Precautions & Guidelines'),
                tilePadding: EdgeInsets.zero,
                children: [
                  ...((alert['precautions'] as List<String>).map(
                    (precaution) => Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• '),
                          Expanded(child: Text(precaution)),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _shareAlert(alert),
                          icon: const Icon(Icons.share),
                          label: const Text('Share Alert'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _getMoreInfo(alert),
                          icon: const Icon(Icons.info),
                          label: const Text('More Info'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: alertColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDiseaseStatRow(String disease, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(disease)),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: count / _allAlerts.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
            ),
          ),
          const SizedBox(width: 8),
          Text('$count'),
        ],
      ),
    );
  }

  Map<String, int> _getDiseaseDistribution() {
    Map<String, int> distribution = {};
    for (var alert in _allAlerts) {
      String type = alert['type'];
      distribution[type] = (distribution[type] ?? 0) + 1;
    }
    return distribution;
  }

  List<String> _getSafetyRecommendations() {
    List<String> recommendations = [
      'Maintain personal hygiene and wash hands frequently',
      'Wear appropriate protective gear in crowded areas',
      'Keep your vaccination schedule up to date',
      'Report any symptoms to healthcare authorities immediately',
    ];

    if (_highRiskAlerts.isNotEmpty) {
      recommendations.addAll([
        'Avoid non-essential travel to affected areas',
        'Stock essential medicines and first aid supplies',
        'Stay informed about latest health guidelines',
      ]);
    }

    return recommendations;
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alert Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Receive push notifications for new alerts'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Alert Radius: ${_alertRadius.round()} km',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _alertRadius,
              min: 1.0,
              max: 20.0,
              divisions: 19,
              label: '${_alertRadius.round()} km',
              onChanged: (value) {
                setState(() {
                  _alertRadius = value;
                });
              },
              onChangeEnd: (value) {
                _loadData();
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Save Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyContacts() {
    final contacts = GeolocationService.getEmergencyContacts();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Contacts'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: contacts.entries
                .map(
                  (entry) => ListTile(
                    leading: const Icon(Icons.phone),
                    title: Text(
                      entry.key.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim(),
                    ),
                    subtitle: Text(entry.value),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Calling ${entry.value}...')),
                      );
                    },
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _reportNewAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Health Alert'),
        content: const Text(
          'Do you want to report a health concern in your area? '
          'This will help notify other users and health authorities.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showReportForm();
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _showReportForm() {
    String diseaseType = '';
    String location = '';
    int affectedCount = 1;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Health Alert'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Disease/Condition Type',
                  hintText: 'e.g., COVID-19, Dengue, Flu',
                ),
                onChanged: (value) => diseaseType = value,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Specific area or landmark',
                ),
                onChanged: (value) => location = value,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Number of Affected People',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => affectedCount = int.tryParse(value) ?? 1,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (diseaseType.isNotEmpty && location.isNotEmpty) {
                final success = GeolocationService.reportInfectedLocation(
                  diseaseType,
                  location,
                  affectedCount,
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Alert reported successfully. Thank you for helping the community!'
                          : 'Failed to report alert. Please try again.',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );

                if (success) {
                  _loadData();
                }
              }
            },
            child: const Text('Submit Report'),
          ),
        ],
      ),
    );
  }

  void _shareAlert(Map<String, dynamic> alert) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Alert shared with contacts')));
  }

  void _getMoreInfo(Map<String, dynamic> alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(alert['type']),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Location: ${alert['location']}'),
              Text('Distance: ${alert['distance']} km'),
              Text('Severity: ${alert['severity']}'),
              Text('Affected Count: ${alert['affectedCount']}'),
              Text('Reported: ${alert['reportedTime']}'),
              const SizedBox(height: 16),
              const Text(
                'Recommended Actions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...((alert['precautions'] as List<String>).map(
                (precaution) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Text('• $precaution'),
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
