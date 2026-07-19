enum AlertType {
  outbreak,
  capacity,
  system,
  emergency,
  weather,
  supply,
  staff,
  infrastructure,
}

enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}

enum AlertStatus {
  active,
  acknowledged,
  resolved,
  dismissed,
}

class HealthAlert {
  final String alertId;
  final String title;
  final String description;
  final AlertType type;
  final AlertSeverity severity;
  final AlertStatus status;
  final DateTime createdAt;
  final DateTime? acknowledgedAt;
  final DateTime? resolvedAt;
  final DateTime? expiresAt;
  final String regionId;
  final String? locationSpecific;
  final double? latitude;
  final double? longitude;
  final Map<String, dynamic>? metadata;
  final List<String> affectedAreas;
  final List<AlertAction> recommendedActions;
  final String? acknowledgedBy;
  final String? resolvedBy;
  final int affectedPopulation;
  final String source;

  HealthAlert({
    required this.alertId,
    required this.title,
    required this.description,
    required this.type,
    required this.severity,
    required this.status,
    required this.createdAt,
    this.acknowledgedAt,
    this.resolvedAt,
    this.expiresAt,
    required this.regionId,
    this.locationSpecific,
    this.latitude,
    this.longitude,
    this.metadata,
    required this.affectedAreas,
    required this.recommendedActions,
    this.acknowledgedBy,
    this.resolvedBy,
    required this.affectedPopulation,
    required this.source,
  });

  factory HealthAlert.fromJson(Map<String, dynamic> json) {
    return HealthAlert(
      alertId: json['alertId'],
      title: json['title'],
      description: json['description'],
      type: AlertType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => AlertType.system,
      ),
      severity: AlertSeverity.values.firstWhere(
        (e) => e.toString().split('.').last == json['severity'],
        orElse: () => AlertSeverity.medium,
      ),
      status: AlertStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => AlertStatus.active,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      acknowledgedAt: json['acknowledgedAt'] != null 
          ? DateTime.parse(json['acknowledgedAt']) 
          : null,
      resolvedAt: json['resolvedAt'] != null 
          ? DateTime.parse(json['resolvedAt']) 
          : null,
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt']) 
          : null,
      regionId: json['regionId'],
      locationSpecific: json['locationSpecific'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      metadata: json['metadata']?.cast<String, dynamic>(),
      affectedAreas: List<String>.from(json['affectedAreas'] ?? []),
      recommendedActions: (json['recommendedActions'] as List? ?? [])
          .map((item) => AlertAction.fromJson(item))
          .toList(),
      acknowledgedBy: json['acknowledgedBy'],
      resolvedBy: json['resolvedBy'],
      affectedPopulation: json['affectedPopulation'] ?? 0,
      source: json['source'] ?? 'system',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alertId': alertId,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'severity': severity.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'acknowledgedAt': acknowledgedAt?.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'regionId': regionId,
      'locationSpecific': locationSpecific,
      'latitude': latitude,
      'longitude': longitude,
      'metadata': metadata,
      'affectedAreas': affectedAreas,
      'recommendedActions': recommendedActions.map((action) => action.toJson()).toList(),
      'acknowledgedBy': acknowledgedBy,
      'resolvedBy': resolvedBy,
      'affectedPopulation': affectedPopulation,
      'source': source,
    };
  }

  HealthAlert copyWith({
    String? alertId,
    String? title,
    String? description,
    AlertType? type,
    AlertSeverity? severity,
    AlertStatus? status,
    DateTime? createdAt,
    DateTime? acknowledgedAt,
    DateTime? resolvedAt,
    DateTime? expiresAt,
    String? regionId,
    String? locationSpecific,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? metadata,
    List<String>? affectedAreas,
    List<AlertAction>? recommendedActions,
    String? acknowledgedBy,
    String? resolvedBy,
    int? affectedPopulation,
    String? source,
  }) {
    return HealthAlert(
      alertId: alertId ?? this.alertId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      regionId: regionId ?? this.regionId,
      locationSpecific: locationSpecific ?? this.locationSpecific,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      metadata: metadata ?? this.metadata,
      affectedAreas: affectedAreas ?? this.affectedAreas,
      recommendedActions: recommendedActions ?? this.recommendedActions,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      affectedPopulation: affectedPopulation ?? this.affectedPopulation,
      source: source ?? this.source,
    );
  }

  bool get isActive => status == AlertStatus.active;
  bool get isAcknowledged => status == AlertStatus.acknowledged;
  bool get isResolved => status == AlertStatus.resolved;
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  
  Duration get timeSinceCreated => DateTime.now().difference(createdAt);
  
  String get timeAgo {
    final duration = timeSinceCreated;
    if (duration.inMinutes < 1) {
      return 'Just now';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h ago';
    } else {
      return '${duration.inDays}d ago';
    }
  }
}

class AlertAction {
  final String actionId;
  final String title;
  final String description;
  final String priority;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? completedBy;
  final String? notes;

  AlertAction({
    required this.actionId,
    required this.title,
    required this.description,
    required this.priority,
    required this.isCompleted,
    this.completedAt,
    this.completedBy,
    this.notes,
  });

  factory AlertAction.fromJson(Map<String, dynamic> json) {
    return AlertAction(
      actionId: json['actionId'],
      title: json['title'],
      description: json['description'],
      priority: json['priority'],
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      completedBy: json['completedBy'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'actionId': actionId,
      'title': title,
      'description': description,
      'priority': priority,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'completedBy': completedBy,
      'notes': notes,
    };
  }
}

// Extensions for better UI display
extension AlertTypeExtension on AlertType {
  String get displayName {
    switch (this) {
      case AlertType.outbreak:
        return 'Disease Outbreak';
      case AlertType.capacity:
        return 'Hospital Capacity';
      case AlertType.system:
        return 'System Alert';
      case AlertType.emergency:
        return 'Emergency';
      case AlertType.weather:
        return 'Weather Alert';
      case AlertType.supply:
        return 'Medical Supply';
      case AlertType.staff:
        return 'Staff Alert';
      case AlertType.infrastructure:
        return 'Infrastructure';
    }
  }

  String get icon {
    switch (this) {
      case AlertType.outbreak:
        return '🦠';
      case AlertType.capacity:
        return '🏥';
      case AlertType.system:
        return '⚙️';
      case AlertType.emergency:
        return '🚨';
      case AlertType.weather:
        return '🌪️';
      case AlertType.supply:
        return '💊';
      case AlertType.staff:
        return '👥';
      case AlertType.infrastructure:
        return '🏗️';
    }
  }
}

extension AlertSeverityExtension on AlertSeverity {
  String get displayName {
    switch (this) {
      case AlertSeverity.low:
        return 'Low';
      case AlertSeverity.medium:
        return 'Medium';
      case AlertSeverity.high:
        return 'High';
      case AlertSeverity.critical:
        return 'Critical';
    }
  }

  String get colorHex {
    switch (this) {
      case AlertSeverity.low:
        return '#4CAF50'; // Green
      case AlertSeverity.medium:
        return '#FF9800'; // Orange
      case AlertSeverity.high:
        return '#FF5722'; // Red Orange
      case AlertSeverity.critical:
        return '#F44336'; // Red
    }
  }
}

extension AlertStatusExtension on AlertStatus {
  String get displayName {
    switch (this) {
      case AlertStatus.active:
        return 'Active';
      case AlertStatus.acknowledged:
        return 'Acknowledged';
      case AlertStatus.resolved:
        return 'Resolved';
      case AlertStatus.dismissed:
        return 'Dismissed';
    }
  }
}

// Alert Summary for dashboard display
class AlertSummary {
  final int totalAlerts;
  final int activeAlerts;
  final int criticalAlerts;
  final int acknowledgedAlerts;
  final int resolvedAlerts;
  final Map<AlertType, int> alertsByType;
  final Map<AlertSeverity, int> alertsBySeverity;
  final List<HealthAlert> recentAlerts;

  AlertSummary({
    required this.totalAlerts,
    required this.activeAlerts,
    required this.criticalAlerts,
    required this.acknowledgedAlerts,
    required this.resolvedAlerts,
    required this.alertsByType,
    required this.alertsBySeverity,
    required this.recentAlerts,
  });

  factory AlertSummary.fromJson(Map<String, dynamic> json) {
    return AlertSummary(
      totalAlerts: json['totalAlerts'],
      activeAlerts: json['activeAlerts'],
      criticalAlerts: json['criticalAlerts'],
      acknowledgedAlerts: json['acknowledgedAlerts'],
      resolvedAlerts: json['resolvedAlerts'],
      alertsByType: Map<AlertType, int>.fromEntries(
        (json['alertsByType'] as Map<String, dynamic>).entries.map(
          (entry) => MapEntry(
            AlertType.values.firstWhere(
              (type) => type.toString().split('.').last == entry.key,
            ),
            entry.value as int,
          ),
        ),
      ),
      alertsBySeverity: Map<AlertSeverity, int>.fromEntries(
        (json['alertsBySeverity'] as Map<String, dynamic>).entries.map(
          (entry) => MapEntry(
            AlertSeverity.values.firstWhere(
              (severity) => severity.toString().split('.').last == entry.key,
            ),
            entry.value as int,
          ),
        ),
      ),
      recentAlerts: (json['recentAlerts'] as List)
          .map((item) => HealthAlert.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAlerts': totalAlerts,
      'activeAlerts': activeAlerts,
      'criticalAlerts': criticalAlerts,
      'acknowledgedAlerts': acknowledgedAlerts,
      'resolvedAlerts': resolvedAlerts,
      'alertsByType': Map<String, int>.fromEntries(
        alertsByType.entries.map(
          (entry) => MapEntry(
            entry.key.toString().split('.').last,
            entry.value,
          ),
        ),
      ),
      'alertsBySeverity': Map<String, int>.fromEntries(
        alertsBySeverity.entries.map(
          (entry) => MapEntry(
            entry.key.toString().split('.').last,
            entry.value,
          ),
        ),
      ),
      'recentAlerts': recentAlerts.map((alert) => alert.toJson()).toList(),
    };
  }
}
