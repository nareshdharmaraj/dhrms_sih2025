import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';

class ProximityAlertsScreen extends StatefulWidget {
  const ProximityAlertsScreen({super.key});

  @override
  State<ProximityAlertsScreen> createState() => _ProximityAlertsScreenState();
}

class _ProximityAlertsScreenState extends State<ProximityAlertsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _proximityAlertsEnabled = true;
  bool _emergencyAlertsEnabled = true;
  bool _healthFacilityAlertsEnabled = true;
  double _alertRadius = 5.0; // in kilometers

  final List<ProximityAlert> _recentAlerts = [
    ProximityAlert(
      id: '1',
      type: AlertType.healthFacility,
      title: 'City General Hospital',
      message: 'Major hospital within 2km of your location',
      distance: 1.8,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      priority: AlertPriority.medium,
      location: 'Downtown Medical District',
    ),
    ProximityAlert(
      id: '2',
      type: AlertType.pharmacy,
      title: 'MediCare Pharmacy',
      message: 'Pharmacy open 24/7 nearby',
      distance: 0.5,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
      priority: AlertPriority.low,
      location: 'Main Street Plaza',
    ),
    ProximityAlert(
      id: '3',
      type: AlertType.emergency,
      title: 'Emergency Alert',
      message: 'Road accident reported - emergency services on route',
      distance: 0.3,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
      priority: AlertPriority.high,
      location: 'Highway 101 Junction',
    ),
    ProximityAlert(
      id: '4',
      type: AlertType.healthRisk,
      title: 'Air Quality Alert',
      message: 'Poor air quality detected in your area',
      distance: 0.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
      priority: AlertPriority.medium,
      location: 'Current Location',
    ),
  ];

  final List<HealthFacility> _nearbyFacilities = [
    HealthFacility(
      id: '1',
      name: 'City General Hospital',
      type: FacilityType.hospital,
      distance: 1.8,
      rating: 4.5,
      address: '123 Medical Center Dr',
      phone: '+1 555 0123',
      isOpen: true,
      specialties: ['Emergency', 'Cardiology', 'Surgery'],
    ),
    HealthFacility(
      id: '2',
      name: 'QuickCare Clinic',
      type: FacilityType.clinic,
      distance: 0.7,
      rating: 4.2,
      address: '456 Health Ave',
      phone: '+1 555 0456',
      isOpen: true,
      specialties: ['General Practice', 'Pediatrics'],
    ),
    HealthFacility(
      id: '3',
      name: 'MediCare Pharmacy',
      type: FacilityType.pharmacy,
      distance: 0.5,
      rating: 4.8,
      address: '789 Main St',
      phone: '+1 555 0789',
      isOpen: true,
      specialties: ['Prescription', 'OTC Medicines'],
    ),
    HealthFacility(
      id: '4',
      name: 'Emergency Care Center',
      type: FacilityType.emergency,
      distance: 2.3,
      rating: 4.7,
      address: '321 Emergency Blvd',
      phone: '+1 555 0321',
      isOpen: true,
      specialties: ['24/7 Emergency', 'Trauma Care'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proximity Alerts'),
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Alerts'),
            Tab(text: 'Nearby'),
            Tab(text: 'Map'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildAlertsTab(), _buildNearbyTab(), _buildMapTab()],
      ),
    );
  }

  Widget _buildAlertsTab() {
    final unreadAlerts = _recentAlerts.where((alert) => !alert.isRead).toList();
    final readAlerts = _recentAlerts.where((alert) => alert.isRead).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAlertsSummary(),
          const SizedBox(height: 20),
          if (unreadAlerts.isNotEmpty) ...[
            Text(
              'New Alerts (${unreadAlerts.length})',
              style: AppTextStyles.headline6.copyWith(
                color: AppColors.grey800,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...unreadAlerts.map((alert) => _buildAlertCard(alert)),
            const SizedBox(height: 20),
          ],
          if (readAlerts.isNotEmpty) ...[
            Text(
              'Previous Alerts',
              style: AppTextStyles.headline6.copyWith(
                color: AppColors.grey800,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...readAlerts.map((alert) => _buildAlertCard(alert)),
          ],
          if (_recentAlerts.isEmpty)
            _buildEmptyState(
              'No alerts yet',
              'Proximity alerts will appear here',
            ),
        ],
      ),
    );
  }

  Widget _buildAlertsSummary() {
    final unreadCount = _recentAlerts.where((alert) => !alert.isRead).length;
    final highPriorityCount = _recentAlerts
        .where((alert) => alert.priority == AlertPriority.high && !alert.isRead)
        .length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryOrange, AppColors.primaryRed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alert Status',
                  style: AppTextStyles.headline6.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$unreadCount new alerts',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white70,
                  ),
                ),
                if (highPriorityCount > 0)
                  Text(
                    '$highPriorityCount high priority',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _proximityAlertsEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(ProximityAlert alert) {
    Color priorityColor;
    IconData alertIcon;

    switch (alert.priority) {
      case AlertPriority.high:
        priorityColor = AppColors.error;
        break;
      case AlertPriority.medium:
        priorityColor = AppColors.warning;
        break;
      case AlertPriority.low:
        priorityColor = AppColors.info;
        break;
    }

    switch (alert.type) {
      case AlertType.emergency:
        alertIcon = Icons.emergency;
        break;
      case AlertType.healthFacility:
        alertIcon = Icons.local_hospital;
        break;
      case AlertType.pharmacy:
        alertIcon = Icons.local_pharmacy;
        break;
      case AlertType.healthRisk:
        alertIcon = Icons.warning;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alert.isRead ? AppColors.grey300 : priorityColor,
          width: alert.isRead ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _markAsRead(alert),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(alertIcon, color: priorityColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              alert.title,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: alert.isRead
                                    ? AppColors.grey700
                                    : AppColors.grey900,
                              ),
                            ),
                          ),
                          if (!alert.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: priorityColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.message,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppColors.grey500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${alert.distance.toStringAsFixed(1)}km away',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.grey500,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppColors.grey500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimestamp(alert.timestamp),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.grey500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nearby Health Facilities',
            style: AppTextStyles.headline6.copyWith(
              color: AppColors.grey800,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._nearbyFacilities.map((facility) => _buildFacilityCard(facility)),
        ],
      ),
    );
  }

  Widget _buildFacilityCard(HealthFacility facility) {
    IconData facilityIcon;
    Color facilityColor;

    switch (facility.type) {
      case FacilityType.hospital:
        facilityIcon = Icons.local_hospital;
        facilityColor = AppColors.error;
        break;
      case FacilityType.clinic:
        facilityIcon = Icons.medical_services;
        facilityColor = AppColors.primaryBlue;
        break;
      case FacilityType.pharmacy:
        facilityIcon = Icons.local_pharmacy;
        facilityColor = AppColors.primaryGreen;
        break;
      case FacilityType.emergency:
        facilityIcon = Icons.emergency;
        facilityColor = AppColors.primaryRed;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: facilityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(facilityIcon, color: facilityColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        facility.name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: AppColors.warning),
                          const SizedBox(width: 4),
                          Text(
                            facility.rating.toString(),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.grey600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: facility.isOpen
                                  ? AppColors.success.withOpacity(0.1)
                                  : AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              facility.isOpen ? 'Open' : 'Closed',
                              style: AppTextStyles.caption.copyWith(
                                color: facility.isOpen
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '${facility.distance.toStringAsFixed(1)}km',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              facility.address,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: facility.specialties.map((specialty) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    specialty,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.grey700,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _callFacility(facility),
                    icon: const Icon(Icons.phone),
                    label: const Text('Call'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _getDirections(facility),
                    icon: const Icon(Icons.directions),
                    label: const Text('Directions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: facilityColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.grey300),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 64, color: AppColors.grey500),
                  const SizedBox(height: 16),
                  Text(
                    'Interactive Map',
                    style: AppTextStyles.headline6.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Map integration would show your location\nand nearby health facilities',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildMapLegend(),
        ],
      ),
    );
  }

  Widget _buildMapLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Map Legend',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildLegendItem(
            Icons.my_location,
            'Your Location',
            AppColors.primaryBlue,
          ),
          _buildLegendItem(Icons.local_hospital, 'Hospitals', AppColors.error),
          _buildLegendItem(
            Icons.medical_services,
            'Clinics',
            AppColors.primaryBlue,
          ),
          _buildLegendItem(
            Icons.local_pharmacy,
            'Pharmacies',
            AppColors.primaryGreen,
          ),
          _buildLegendItem(Icons.emergency, 'Emergency', AppColors.primaryRed),
        ],
      ),
    );
  }

  Widget _buildLegendItem(IconData icon, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: AppColors.grey400),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.headline6.copyWith(color: AppColors.grey600),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Proximity Settings'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Proximity Alerts'),
                subtitle: const Text('Enable location-based alerts'),
                value: _proximityAlertsEnabled,
                onChanged: (value) {
                  setState(() {
                    _proximityAlertsEnabled = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Emergency Alerts'),
                subtitle: const Text('Critical emergency notifications'),
                value: _emergencyAlertsEnabled,
                onChanged: (value) {
                  setState(() {
                    _emergencyAlertsEnabled = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Health Facility Alerts'),
                subtitle: const Text('Nearby hospitals and clinics'),
                value: _healthFacilityAlertsEnabled,
                onChanged: (value) {
                  setState(() {
                    _healthFacilityAlertsEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Alert Radius: ${_alertRadius.toStringAsFixed(1)} km',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Slider(
                value: _alertRadius,
                min: 1.0,
                max: 10.0,
                divisions: 18,
                onChanged: (value) {
                  setState(() {
                    _alertRadius = value;
                  });
                },
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
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Settings saved!')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _markAsRead(ProximityAlert alert) {
    setState(() {
      alert.isRead = true;
    });
  }

  void _callFacility(HealthFacility facility) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Calling ${facility.name}...')));
  }

  void _getDirections(HealthFacility facility) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Getting directions to ${facility.name}...')),
    );
  }
}

enum AlertType { emergency, healthFacility, pharmacy, healthRisk }

enum AlertPriority { high, medium, low }

enum FacilityType { hospital, clinic, pharmacy, emergency }

class ProximityAlert {
  final String id;
  final AlertType type;
  final String title;
  final String message;
  final double distance;
  final DateTime timestamp;
  bool isRead;
  final AlertPriority priority;
  final String location;

  ProximityAlert({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.distance,
    required this.timestamp,
    required this.isRead,
    required this.priority,
    required this.location,
  });
}

class HealthFacility {
  final String id;
  final String name;
  final FacilityType type;
  final double distance;
  final double rating;
  final String address;
  final String phone;
  final bool isOpen;
  final List<String> specialties;

  HealthFacility({
    required this.id,
    required this.name,
    required this.type,
    required this.distance,
    required this.rating,
    required this.address,
    required this.phone,
    required this.isOpen,
    required this.specialties,
  });
}
