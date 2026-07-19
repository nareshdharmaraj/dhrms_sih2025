import 'dart:math';
import '../models/health_alert_model.dart';

class HealthAlertsService {
  static final HealthAlertsService _instance = HealthAlertsService._internal();
  factory HealthAlertsService() => _instance;
  HealthAlertsService._internal();

  // Mock data storage - replace with actual API calls
  final List<HealthAlert> _alerts = [];
  final List<Function(HealthAlert)> _listeners = [];

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await Future.delayed(const Duration(milliseconds: 500));
    _generateMockAlerts();
    _isInitialized = true;
  }

  // Get all alerts
  Future<List<HealthAlert>> getAllAlerts() async {
    await initialize();
    return List.from(_alerts);
  }

  // Get alerts by status
  Future<List<HealthAlert>> getAlertsByStatus(AlertStatus status) async {
    await initialize();
    return _alerts.where((alert) => alert.status == status).toList();
  }

  // Get alerts by severity
  Future<List<HealthAlert>> getAlertsBySeverity(AlertSeverity severity) async {
    await initialize();
    return _alerts.where((alert) => alert.severity == severity).toList();
  }

  // Get alerts by type
  Future<List<HealthAlert>> getAlertsByType(AlertType type) async {
    await initialize();
    return _alerts.where((alert) => alert.type == type).toList();
  }

  // Get active alerts
  Future<List<HealthAlert>> getActiveAlerts() async {
    await initialize();
    return _alerts.where((alert) => alert.isActive).toList();
  }

  // Get critical alerts
  Future<List<HealthAlert>> getCriticalAlerts() async {
    await initialize();
    return _alerts.where((alert) => 
        alert.severity == AlertSeverity.critical && alert.isActive).toList();
  }

  // Get alert summary
  Future<AlertSummary> getAlertSummary() async {
    await initialize();
    
    final alertsByType = <AlertType, int>{};
    final alertsBySeverity = <AlertSeverity, int>{};
    
    for (final alert in _alerts) {
      alertsByType[alert.type] = (alertsByType[alert.type] ?? 0) + 1;
      alertsBySeverity[alert.severity] = (alertsBySeverity[alert.severity] ?? 0) + 1;
    }
    
    return AlertSummary(
      totalAlerts: _alerts.length,
      activeAlerts: _alerts.where((a) => a.isActive).length,
      criticalAlerts: _alerts.where((a) => a.severity == AlertSeverity.critical).length,
      acknowledgedAlerts: _alerts.where((a) => a.isAcknowledged).length,
      resolvedAlerts: _alerts.where((a) => a.isResolved).length,
      alertsByType: alertsByType,
      alertsBySeverity: alertsBySeverity,
      recentAlerts: _alerts.take(5).toList(),
    );
  }

  // Acknowledge an alert
  Future<void> acknowledgeAlert(String alertId, String officerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _alerts.indexWhere((alert) => alert.alertId == alertId);
    if (index != -1) {
      _alerts[index] = _alerts[index].copyWith(
        status: AlertStatus.acknowledged,
        acknowledgedAt: DateTime.now(),
        acknowledgedBy: officerId,
      );
      _notifyListeners(_alerts[index]);
    }
  }

  // Resolve an alert
  Future<void> resolveAlert(String alertId, String officerId, String? notes) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _alerts.indexWhere((alert) => alert.alertId == alertId);
    if (index != -1) {
      _alerts[index] = _alerts[index].copyWith(
        status: AlertStatus.resolved,
        resolvedAt: DateTime.now(),
        resolvedBy: officerId,
        metadata: {
          ...(_alerts[index].metadata ?? {}),
          'resolution_notes': notes ?? '',
        },
      );
      _notifyListeners(_alerts[index]);
    }
  }

  // Dismiss an alert
  Future<void> dismissAlert(String alertId, String officerId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final index = _alerts.indexWhere((alert) => alert.alertId == alertId);
    if (index != -1) {
      _alerts[index] = _alerts[index].copyWith(
        status: AlertStatus.dismissed,
        resolvedAt: DateTime.now(),
        resolvedBy: officerId,
      );
      _notifyListeners(_alerts[index]);
    }
  }

  // Create a new alert
  Future<HealthAlert> createAlert({
    required String title,
    required String description,
    required AlertType type,
    required AlertSeverity severity,
    required String regionId,
    String? locationSpecific,
    double? latitude,
    double? longitude,
    List<String>? affectedAreas,
    List<AlertAction>? recommendedActions,
    int? affectedPopulation,
    DateTime? expiresAt,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final alert = HealthAlert(
      alertId: _generateAlertId(),
      title: title,
      description: description,
      type: type,
      severity: severity,
      status: AlertStatus.active,
      createdAt: DateTime.now(),
      regionId: regionId,
      locationSpecific: locationSpecific,
      latitude: latitude,
      longitude: longitude,
      affectedAreas: affectedAreas ?? [],
      recommendedActions: recommendedActions ?? [],
      affectedPopulation: affectedPopulation ?? 0,
      source: 'manual',
      expiresAt: expiresAt,
    );
    
    _alerts.insert(0, alert);
    _notifyListeners(alert);
    
    return alert;
  }

  // Mark action as completed
  Future<void> completeAction(String alertId, String actionId, String officerId, String? notes) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final alertIndex = _alerts.indexWhere((alert) => alert.alertId == alertId);
    if (alertIndex != -1) {
      final alert = _alerts[alertIndex];
      final updatedActions = alert.recommendedActions.map((action) {
        if (action.actionId == actionId) {
          return AlertAction(
            actionId: action.actionId,
            title: action.title,
            description: action.description,
            priority: action.priority,
            isCompleted: true,
            completedAt: DateTime.now(),
            completedBy: officerId,
            notes: notes,
          );
        }
        return action;
      }).toList();
      
      _alerts[alertIndex] = alert.copyWith(recommendedActions: updatedActions);
      _notifyListeners(_alerts[alertIndex]);
    }
  }

  // Get alerts by location proximity
  Future<List<HealthAlert>> getAlertsByLocation(double latitude, double longitude, double radiusKm) async {
    await initialize();
    
    return _alerts.where((alert) {
      if (alert.latitude == null || alert.longitude == null) return false;
      
      final distance = _calculateDistance(
        latitude, longitude, 
        alert.latitude!, alert.longitude!
      );
      
      return distance <= radiusKm;
    }).toList();
  }

  // Add listener for alert updates
  void addListener(Function(HealthAlert) listener) {
    _listeners.add(listener);
  }

  // Remove listener
  void removeListener(Function(HealthAlert) listener) {
    _listeners.remove(listener);
  }

  // Notify all listeners
  void _notifyListeners(HealthAlert alert) {
    for (final listener in _listeners) {
      listener(alert);
    }
  }

  // Generate unique alert ID
  String _generateAlertId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(1000);
    return 'ALERT_${timestamp}_$random';
  }

  // Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Generate mock alerts for development
  void _generateMockAlerts() {
    final mockAlerts = [
      HealthAlert(
        alertId: _generateAlertId(),
        title: 'Dengue Outbreak in Kakkanad',
        description: 'Significant increase in dengue cases reported in Kakkanad area. Immediate attention required for vector control measures.',
        type: AlertType.outbreak,
        severity: AlertSeverity.critical,
        status: AlertStatus.active,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        regionId: 'ERN001',
        locationSpecific: 'Kakkanad, Ernakulam',
        latitude: 10.0261,
        longitude: 76.3105,
        affectedAreas: ['Kakkanad', 'Palarivattom', 'Edapally'],
        recommendedActions: [
          AlertAction(
            actionId: 'ACT001',
            title: 'Deploy Health Teams',
            description: 'Deploy health surveillance teams to affected areas',
            priority: 'High',
            isCompleted: false,
          ),
          AlertAction(
            actionId: 'ACT002',
            title: 'Vector Control',
            description: 'Initiate mosquito control and fogging operations',
            priority: 'Critical',
            isCompleted: false,
          ),
        ],
        affectedPopulation: 15000,
        source: 'field_report',
      ),
      HealthAlert(
        alertId: _generateAlertId(),
        title: 'Hospital Capacity Alert',
        description: 'ICU capacity at Ernakulam Medical College Hospital has reached 95%. Consider patient transfers.',
        type: AlertType.capacity,
        severity: AlertSeverity.high,
        status: AlertStatus.acknowledged,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        acknowledgedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        acknowledgedBy: 'OFF001',
        regionId: 'ERN001',
        locationSpecific: 'Ernakulam Medical College',
        latitude: 10.0089,
        longitude: 76.3131,
        affectedAreas: ['Kalamassery'],
        recommendedActions: [
          AlertAction(
            actionId: 'ACT003',
            title: 'Coordinate Transfers',
            description: 'Coordinate with other hospitals for patient transfers',
            priority: 'High',
            isCompleted: true,
            completedAt: DateTime.now().subtract(const Duration(minutes: 15)),
            completedBy: 'OFF001',
          ),
        ],
        affectedPopulation: 500,
        source: 'hospital_system',
      ),
      HealthAlert(
        alertId: _generateAlertId(),
        title: 'Medical Supply Shortage',
        description: 'Critical shortage of oxygen cylinders reported across multiple hospitals in the region.',
        type: AlertType.supply,
        severity: AlertSeverity.high,
        status: AlertStatus.active,
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        regionId: 'ERN001',
        affectedAreas: ['Ernakulam', 'Thrissur'],
        recommendedActions: [
          AlertAction(
            actionId: 'ACT004',
            title: 'Emergency Procurement',
            description: 'Initiate emergency procurement of oxygen cylinders',
            priority: 'Critical',
            isCompleted: false,
          ),
          AlertAction(
            actionId: 'ACT005',
            title: 'Redistribute Stock',
            description: 'Redistribute existing stock from surplus hospitals',
            priority: 'High',
            isCompleted: false,
          ),
        ],
        affectedPopulation: 2000,
        source: 'supply_chain',
      ),
      HealthAlert(
        alertId: _generateAlertId(),
        title: 'Heavy Rainfall Health Advisory',
        description: 'Heavy rainfall expected in the region. Risk of waterborne diseases and flooding at healthcare facilities.',
        type: AlertType.weather,
        severity: AlertSeverity.medium,
        status: AlertStatus.active,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        regionId: 'ERN001',
        affectedAreas: ['Ernakulam', 'Kottayam', 'Alappuzha'],
        recommendedActions: [
          AlertAction(
            actionId: 'ACT006',
            title: 'Issue Advisory',
            description: 'Issue public health advisory for waterborne diseases',
            priority: 'Medium',
            isCompleted: false,
          ),
          AlertAction(
            actionId: 'ACT007',
            title: 'Prepare Emergency Response',
            description: 'Prepare emergency response teams for potential flooding',
            priority: 'Medium',
            isCompleted: false,
          ),
        ],
        affectedPopulation: 500000,
        source: 'weather_service',
        expiresAt: DateTime.now().add(const Duration(days: 2)),
      ),
      HealthAlert(
        alertId: _generateAlertId(),
        title: 'System Maintenance Alert',
        description: 'Scheduled maintenance of the regional health information system will cause temporary service interruption.',
        type: AlertType.system,
        severity: AlertSeverity.low,
        status: AlertStatus.resolved,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        resolvedAt: DateTime.now().subtract(const Duration(hours: 2)),
        resolvedBy: 'SYS001',
        regionId: 'ERN001',
        affectedAreas: ['System Wide'],
        recommendedActions: [],
        affectedPopulation: 0,
        source: 'system',
      ),
    ];
    
    _alerts.addAll(mockAlerts);
  }

  // Export alerts to different formats
  Future<String> exportAlertsToCSV(List<HealthAlert> alerts) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'alerts_export_${DateTime.now().millisecondsSinceEpoch}.csv';
  }

  Future<String> exportAlertsToPDF(List<HealthAlert> alerts) async {
    await Future.delayed(const Duration(seconds: 1));
    return 'alerts_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
  }

  // Real-time alert stream
  Stream<HealthAlert> getAlertStream() async* {
    await initialize();
    
    // Simulate real-time alerts
    while (true) {
      await Future.delayed(const Duration(minutes: 5));
      
      // Randomly generate new alerts (for demo purposes)
      if (Random().nextBool()) {
        final newAlert = await _generateRandomAlert();
        yield newAlert;
      }
    }
  }

  Future<HealthAlert> _generateRandomAlert() async {
    final types = AlertType.values;
    final severities = AlertSeverity.values;
    final random = Random();
    
    final alert = HealthAlert(
      alertId: _generateAlertId(),
      title: 'System Generated Alert',
      description: 'This is a randomly generated alert for demonstration purposes.',
      type: types[random.nextInt(types.length)],
      severity: severities[random.nextInt(severities.length)],
      status: AlertStatus.active,
      createdAt: DateTime.now(),
      regionId: 'ERN001',
      affectedAreas: ['Auto-Generated'],
      recommendedActions: [],
      affectedPopulation: random.nextInt(1000),
      source: 'system',
    );
    
    _alerts.insert(0, alert);
    _notifyListeners(alert);
    
    return alert;
  }

  // Clear resolved alerts
  Future<void> clearResolvedAlerts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _alerts.removeWhere((alert) => alert.isResolved);
  }

  // Get alerts statistics
  Future<Map<String, dynamic>> getAlertsStatistics() async {
    await initialize();
    
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));
    final last7Days = now.subtract(const Duration(days: 7));
    
    return {
      'total_alerts': _alerts.length,
      'active_alerts': _alerts.where((a) => a.isActive).length,
      'alerts_last_24h': _alerts.where((a) => a.createdAt.isAfter(last24Hours)).length,
      'alerts_last_7d': _alerts.where((a) => a.createdAt.isAfter(last7Days)).length,
      'critical_alerts': _alerts.where((a) => a.severity == AlertSeverity.critical).length,
      'average_response_time': _calculateAverageResponseTime(),
      'resolution_rate': _calculateResolutionRate(),
    };
  }

  double _calculateAverageResponseTime() {
    final acknowledgedAlerts = _alerts.where((a) => a.acknowledgedAt != null);
    if (acknowledgedAlerts.isEmpty) return 0.0;
    
    final totalTime = acknowledgedAlerts.fold<int>(0, (sum, alert) => 
        sum + alert.acknowledgedAt!.difference(alert.createdAt).inMinutes);
    
    return totalTime / acknowledgedAlerts.length;
  }

  double _calculateResolutionRate() {
    if (_alerts.isEmpty) return 0.0;
    final resolvedCount = _alerts.where((a) => a.isResolved).length;
    return (resolvedCount / _alerts.length) * 100;
  }
}
