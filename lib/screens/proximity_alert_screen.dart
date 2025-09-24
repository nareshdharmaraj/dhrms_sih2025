import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/ble_contact_tracing_service.dart';
import '../services/infected_ids_manager.dart';
import '../utils/ble_utils.dart';

/// Proximity Alert Screen for Patient Dashboard
/// Displays BLE contact tracing interface and proximity alerts
class ProximityAlertScreen extends StatefulWidget {
  const ProximityAlertScreen({super.key});

  @override
  State<ProximityAlertScreen> createState() => _ProximityAlertScreenState();
}

class _ProximityAlertScreenState extends State<ProximityAlertScreen>
    with TickerProviderStateMixin {
  
  // Services
  final BLEContactTracingService _contactTracingService = BLEContactTracingService();
  final InfectedIDsManager _infectedIDsManager = InfectedIDsManager();

  // State variables
  bool _isInitialized = false;
  bool _isContactTracingActive = false;
  BLEServiceStatus _serviceStatus = BLEServiceStatus.uninitialized;
  List<DetectedDevice> _detectedDevices = [];
  List<ProximityAlert> _recentAlerts = [];
  int _infectedCount = 0;
  
  // Animation controllers
  late AnimationController _scanAnimationController;
  late AnimationController _alertAnimationController;
  late Animation<double> _scanAnimation;
  late Animation<double> _alertAnimation;
  
  // Stream subscriptions
  StreamSubscription<DetectedDevice>? _deviceSubscription;
  StreamSubscription<ProximityAlert>? _alertSubscription;
  StreamSubscription<BLEServiceStatus>? _statusSubscription;
  StreamSubscription<Set<String>>? _infectedIdsSubscription;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeServices();
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    _alertAnimationController.dispose();
    _deviceSubscription?.cancel();
    _alertSubscription?.cancel();
    _statusSubscription?.cancel();
    _infectedIdsSubscription?.cancel();
    super.dispose();
  }

  /// Initialize animations
  void _initializeAnimations() {
    _scanAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _alertAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _scanAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scanAnimationController, curve: Curves.easeInOut),
    );
    
    _alertAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _alertAnimationController, curve: Curves.elasticOut),
    );

    _scanAnimationController.repeat(reverse: true);
  }

  /// Initialize all services
  Future<void> _initializeServices() async {
    try {
      // Initialize BLE Contact Tracing Service
      final initialized = await _contactTracingService.initialize();
      if (!initialized) {
        _showErrorSnackBar('Failed to initialize contact tracing service');
        return;
      }

      // Set up stream subscriptions
      _setupStreamSubscriptions();

      // Update infected IDs count
      _infectedCount = _infectedIDsManager.getInfectedCount();

      setState(() {
        _isInitialized = true;
      });

    } catch (e) {
      _showErrorSnackBar('Initialization error: $e');
    }
  }

  /// Set up stream subscriptions
  void _setupStreamSubscriptions() {
    // Listen to detected devices
    _deviceSubscription = _contactTracingService.deviceDetectedStream.listen(
      (device) {
        setState(() {
          _detectedDevices = _contactTracingService.detectedDevices;
        });
      },
    );

    // Listen to proximity alerts
    _alertSubscription = _contactTracingService.alertStream.listen(
      (alert) {
        setState(() {
          _recentAlerts.insert(0, alert);
          // Keep only last 20 alerts
          if (_recentAlerts.length > 20) {
            _recentAlerts = _recentAlerts.take(20).toList();
          }
        });
        _alertAnimationController.forward().then((_) {
          _alertAnimationController.reverse();
        });
        HapticFeedback.heavyImpact();
      },
    );

    // Listen to service status changes
    _statusSubscription = _contactTracingService.statusStream.listen(
      (status) {
        setState(() {
          _serviceStatus = status;
          _isContactTracingActive = status == BLEServiceStatus.active;
        });
      },
    );

    // Listen to infected IDs updates
    _infectedIdsSubscription = _infectedIDsManager.infectedIdsStream.listen(
      (infectedIds) {
        setState(() {
          _infectedCount = infectedIds.length;
        });
      },
    );
  }

  /// Toggle contact tracing
  Future<void> _toggleContactTracing() async {
    if (!_isInitialized) return;

    try {
      if (_isContactTracingActive) {
        await _contactTracingService.stopContactTracing();
      } else {
        final success = await _contactTracingService.startContactTracing();
        if (!success) {
          _showErrorSnackBar('Failed to start contact tracing');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error toggling contact tracing: $e');
    }
  }

  /// Refresh infected IDs from server
  Future<void> _refreshInfectedIds() async {
    try {
      final success = await _infectedIDsManager.forceRefresh();
      if (success) {
        _showSuccessSnackBar('Infected IDs updated successfully');
      } else {
        _showErrorSnackBar('Failed to update infected IDs');
      }
    } catch (e) {
      _showErrorSnackBar('Error refreshing data: $e');
    }
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Proximity Alerts'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _refreshInfectedIds,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isInitialized ? _buildMainContent() : _buildLoadingContent(),
    );
  }

  /// Build loading content
  Widget _buildLoadingContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
          ),
          SizedBox(height: 16),
          Text(
            'Initializing Contact Tracing...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF424242),
            ),
          ),
        ],
      ),
    );
  }

  /// Build main content
  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildControlPanel(),
          const SizedBox(height: 16),
          _buildStatsCard(),
          const SizedBox(height: 16),
          _buildRecentAlertsSection(),
          const SizedBox(height: 16),
          _buildDetectedDevicesSection(),
        ],
      ),
    );
  }

  /// Build status card
  Widget _buildStatusCard() {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (_serviceStatus) {
      case BLEServiceStatus.active:
        statusColor = Colors.green;
        statusIcon = Icons.shield_outlined;
        statusText = 'Contact Tracing Active';
        break;
      case BLEServiceStatus.stopped:
        statusColor = Colors.orange;
        statusIcon = Icons.pause_circle_outline;
        statusText = 'Contact Tracing Paused';
        break;
      case BLEServiceStatus.error:
        statusColor = Colors.red;
        statusIcon = Icons.error_outline;
        statusText = 'Service Error';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info_outline;
        statusText = 'Initializing...';
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isContactTracingActive ? _scanAnimation.value : 1.0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      statusIcon,
                      color: statusColor,
                      size: 32,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStatusDescription(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build control panel
  Widget _buildControlPanel() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Bluetooth Contact Tracing',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Bluetooth Status Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isContactTracingActive ? Colors.green[100] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isContactTracingActive ? Colors.green[300]! : Colors.grey[400]!,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isContactTracingActive ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                        size: 16,
                        color: _isContactTracingActive ? Colors.green[700] : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isContactTracingActive ? 'ON' : 'OFF',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _isContactTracingActive ? Colors.green[700] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _isContactTracingActive 
                  ? '🔄 Scanning for nearby devices every 5 seconds'
                  : '⚠️ Tap "Start Tracing" to enable Bluetooth scanning for infected users',
              style: TextStyle(
                fontSize: 13,
                color: _isContactTracingActive ? Colors.green[600] : Colors.orange[700],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _toggleContactTracing,
                    icon: Icon(_isContactTracingActive ? Icons.stop : Icons.bluetooth),
                    label: Text(_isContactTracingActive ? 'Stop Tracing' : 'Start Bluetooth Tracing'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isContactTracingActive ? Colors.red : const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _showSettingsDialog(),
                  icon: const Icon(Icons.settings),
                  label: const Text('Settings'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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

  /// Build stats card
  Widget _buildStatsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem(
                  'Infected IDs',
                  _infectedCount.toString(),
                  Icons.warning,
                  Colors.red,
                ),
                _buildStatItem(
                  'Detected Devices',
                  _detectedDevices.length.toString(),
                  Icons.devices,
                  Colors.blue,
                ),
                _buildStatItem(
                  'Recent Alerts',
                  _recentAlerts.length.toString(),
                  Icons.notification_important,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build stat item
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
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
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build recent alerts section
  Widget _buildRecentAlertsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Alerts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_recentAlerts.isNotEmpty)
                  TextButton(
                    onPressed: () => _showAllAlertsDialog(),
                    child: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_recentAlerts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No alerts yet',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              Column(
                children: _recentAlerts.take(3).map((alert) => _buildAlertItem(alert)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  /// Build alert item
  Widget _buildAlertItem(ProximityAlert alert) {
    Color riskColor;
    IconData riskIcon;
    String riskText;

    switch (alert.riskLevel) {
      case RiskLevel.high:
        riskColor = Colors.red;
        riskIcon = Icons.dangerous;
        riskText = 'High Risk';
        break;
      case RiskLevel.medium:
        riskColor = Colors.orange;
        riskIcon = Icons.warning;
        riskText = 'Medium Risk';
        break;
      case RiskLevel.low:
        riskColor = Colors.yellow[700]!;
        riskIcon = Icons.info;
        riskText = 'Low Risk';
        break;
    }

    return AnimatedBuilder(
      animation: _alertAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_alertAnimation.value * 0.05),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border(left: BorderSide(color: riskColor, width: 4)),
            ),
            child: Row(
              children: [
                Icon(riskIcon, color: riskColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        riskText,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: riskColor,
                        ),
                      ),
                      Text(
                        'Distance: ${alert.detectedDevice.estimatedDistance.toStringAsFixed(1)}m',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        _formatTimestamp(alert.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build detected devices section
  Widget _buildDetectedDevicesSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nearby Devices',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_detectedDevices.isEmpty && _isContactTracingActive)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Scanning for nearby devices...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else if (_detectedDevices.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No devices detected',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              Column(
                children: _detectedDevices.take(5).map((device) => _buildDeviceItem(device)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  /// Build device item
  Widget _buildDeviceItem(DetectedDevice device) {
    final isInfected = _infectedIDsManager.isInfected(device.deviceId);
    final proximityCategory = BLEUtils.getRSSIProximity(device.rssi);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isInfected ? Colors.red.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: isInfected ? Border.all(color: Colors.red, width: 1) : null,
      ),
      child: Row(
        children: [
          Icon(
            isInfected ? Icons.coronavirus : Icons.device_hub,
            color: isInfected ? Colors.red : Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Device ${device.deviceId.substring(0, 8)}...',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${device.estimatedDistance.toStringAsFixed(1)}m • ${proximityCategory.name}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatTimestamp(device.timestamp),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Get status description
  String _getStatusDescription() {
    switch (_serviceStatus) {
      case BLEServiceStatus.active:
        return 'Monitoring nearby devices for potential exposure';
      case BLEServiceStatus.stopped:
        return 'Contact tracing is currently paused';
      case BLEServiceStatus.error:
        return 'Please check permissions and try again';
      case BLEServiceStatus.permissionDenied:
        return 'Bluetooth and location permissions required';
      default:
        return 'Setting up contact tracing system...';
    }
  }

  /// Format timestamp for display
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  /// Show settings dialog
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.bluetooth, color: Colors.blue[700]),
            const SizedBox(width: 8),
            const Text('Bluetooth Tracing Settings'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bluetooth Status
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isContactTracingActive ? Colors.green[50] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isContactTracingActive ? Colors.green[200]! : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isContactTracingActive ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                      color: _isContactTracingActive ? Colors.green[700] : Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isContactTracingActive ? 'Bluetooth Tracing Active' : 'Bluetooth Tracing Inactive',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isContactTracingActive ? Colors.green[700] : Colors.grey[600],
                            ),
                          ),
                          Text(
                            _isContactTracingActive 
                                ? 'Scanning for nearby infected users' 
                                : 'Tap "Start Tracing" to enable',
                            style: TextStyle(
                              fontSize: 12,
                              color: _isContactTracingActive ? Colors.green[600] : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // How It Works Section
              const Text(
                'How Bluetooth Tracing Works:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildSettingsStep('1', 'Scans for nearby DHRMS users via Bluetooth'),
              _buildSettingsStep('2', 'Records anonymous contacts with timestamps'),
              _buildSettingsStep('3', 'Downloads infected user IDs from health authorities'),
              _buildSettingsStep('4', 'Alerts you if infected person detected nearby'),
              
              const SizedBox(height: 16),
              
              // Privacy Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.privacy_tip, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Privacy Protected',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '• All data is anonymized\n• No personal information shared\n• Data stored locally on device',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Statistics
              Text(
                'Current Status:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              _buildStatRow('Devices Detected Today', '${_detectedDevices.length}'),
              _buildStatRow('Infected IDs in Database', '$_infectedCount'),
              _buildStatRow('Recent Alerts', '${_recentAlerts.length}'),
            ],
          ),
        ),
        actions: [
          if (!_isContactTracingActive)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _toggleContactTracing();
              },
              icon: const Icon(Icons.bluetooth),
              label: const Text('Enable Bluetooth Tracing'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Build settings step widget
  Widget _buildSettingsStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  /// Build statistics row
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// Show all alerts dialog
  void _showAllAlertsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Alerts'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _recentAlerts.length,
            itemBuilder: (context, index) => _buildAlertItem(_recentAlerts[index]),
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
