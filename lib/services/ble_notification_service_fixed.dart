import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ble_contact_tracing_service.dart';

// Conditional import for Firebase Messaging - only on mobile platforms
import 'package:firebase_messaging/firebase_messaging.dart'
    if (dart.library.html) 'ble_notification_service_web_stub.dart'
    as firebase_messaging;

/// BLE notification service for proximity alerts
/// Handles both local notifications and Firebase Cloud Messaging (mobile only)
class BLENotificationService {
  static final BLENotificationService _instance =
      BLENotificationService._internal();
  factory BLENotificationService() => _instance;
  BLENotificationService._internal();

  // Services
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Firebase messaging - only available on mobile platforms
  dynamic _firebaseMessaging;

  // State
  bool _isInitialized = false;
  bool _notificationsEnabled = true;

  // Notification channels
  static const String _proximityChannelId = 'proximity_alerts';
  static const String _generalChannelId = 'general_alerts';

  /// Initialize the notification service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Initialize local notifications
      await _initializeLocalNotifications();

      // Initialize Firebase messaging only on mobile platforms
      if (!kIsWeb) {
        await _initializeFirebaseMessaging();
      }

      // Load notification preferences
      await _loadNotificationPreferences();

      _isInitialized = true;
      debugPrint('✅ BLE Notification Service initialized');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to initialize BLE Notification Service: $e');
      return false;
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    // Android initialization settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _createNotificationChannels();
    }
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      // Proximity alerts channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _proximityChannelId,
          'Proximity Alerts',
          description: 'Alerts when infected individuals are nearby',
          importance: Importance.high,
          enableVibration: true,
          enableLights: true,
        ),
      );

      // General alerts channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _generalChannelId,
          'General Alerts',
          description: 'General health and system notifications',
          importance: Importance.defaultImportance,
        ),
      );
    }
  }

  /// Initialize Firebase messaging (mobile only)
  Future<void> _initializeFirebaseMessaging() async {
    if (kIsWeb) return; // Skip on web

    try {
      _firebaseMessaging = firebase_messaging.FirebaseMessaging.instance;

      // Request permission for notifications
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Get FCM token
      final token = await _firebaseMessaging.getToken();
      debugPrint('📱 FCM Token: $token');

      // Handle foreground messages
      firebase_messaging.FirebaseMessaging.onMessage.listen(
        _handleForegroundMessage,
      );

      // Handle background messages
      firebase_messaging.FirebaseMessaging.onBackgroundMessage(
        _handleBackgroundMessage,
      );

      // Handle notification taps
      firebase_messaging.FirebaseMessaging.onMessageOpenedApp.listen(
        _handleNotificationTap,
      );
    } catch (e) {
      debugPrint('⚠️ Firebase Messaging not available: $e');
    }
  }

  /// Show proximity alert notification
  Future<void> showProximityAlert(ProximityAlert alert) async {
    if (!_notificationsEnabled || !_isInitialized) return;

    try {
      final riskEmoji = _getRiskEmoji(alert.riskLevel);
      final distanceText = alert.detectedDevice.estimatedDistance
          .toStringAsFixed(1);

      final androidDetails = AndroidNotificationDetails(
        _proximityChannelId,
        'Proximity Alerts',
        channelDescription: 'Alerts when infected individuals are nearby',
        importance: Importance.high,
        ticker: 'Proximity Alert',
        enableVibration: true,
        enableLights: true,
        color: const Color(0xFFFF6B6B),
        ledColor: const Color(0xFFFF0000),
        ledOnMs: 1000,
        ledOffMs: 500,
        playSound: true,
        icon: '@drawable/ic_warning',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        badgeNumber: 1,
      );

      final platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        alert.timestamp.millisecondsSinceEpoch.hashCode,
        '$riskEmoji Proximity Alert',
        'Infected individual detected ${distanceText}m away. Take precautions.',
        platformDetails,
        payload: json.encode({
          'type': 'proximity_alert',
          'alert_data': alert.toJson(),
        }),
      );

      // Log alert
      await _logAlert(alert);
    } catch (e) {
      debugPrint('❌ Error showing proximity alert: $e');
    }
  }

  /// Show general notification
  Future<void> showGeneralNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (!_notificationsEnabled || !_isInitialized) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        _generalChannelId,
        'General Alerts',
        channelDescription: 'General health and system notifications',
        importance: Importance.defaultImportance,
        ticker: 'Health Alert',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.hashCode,
        title,
        body,
        platformDetails,
        payload: json.encode({'type': 'general', 'data': data ?? {}}),
      );
    } catch (e) {
      debugPrint('❌ Error showing general notification: $e');
    }
  }

  /// Handle foreground Firebase messages (mobile only)
  void _handleForegroundMessage(dynamic message) {
    if (kIsWeb) return;

    debugPrint('📬 Received foreground message: ${message.messageId}');

    if (message.notification != null) {
      showGeneralNotification(
        title: message.notification!.title ?? 'Health Alert',
        body: message.notification!.body ?? '',
        data: message.data,
      );
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('📱 Notification tapped: ${response.payload}');

    if (response.payload != null) {
      try {
        final data = json.decode(response.payload!);
        _handleNotificationAction(data);
      } catch (e) {
        debugPrint('❌ Error handling notification tap: $e');
      }
    }
  }

  /// Handle notification actions
  void _handleNotificationAction(Map<String, dynamic> data) {
    final type = data['type'] as String?;

    switch (type) {
      case 'proximity_alert':
        // Navigate to proximity screen or show alert details
        debugPrint('🚨 Proximity alert tapped');
        break;
      case 'general':
        // Handle general notification tap
        debugPrint('📋 General notification tapped');
        break;
      default:
        debugPrint('❓ Unknown notification type: $type');
    }
  }

  /// Handle Firebase notification tap (mobile only)
  void _handleNotificationTap(dynamic message) {
    if (kIsWeb) return;

    debugPrint('📱 FCM notification tapped: ${message.messageId}');
    _handleNotificationAction(message.data);
  }

  /// Log alert for analytics
  Future<void> _logAlert(ProximityAlert alert) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alertsKey = 'proximity_alerts_log';
      final existing = prefs.getStringList(alertsKey) ?? [];

      existing.add(
        json.encode({
          'timestamp': alert.timestamp.toIso8601String(),
          'risk_level': alert.riskLevel.name,
          'distance': alert.detectedDevice.estimatedDistance,
        }),
      );

      // Keep only last 100 alerts
      if (existing.length > 100) {
        existing.removeRange(0, existing.length - 100);
      }

      await prefs.setStringList(alertsKey, existing);
    } catch (e) {
      debugPrint('❌ Error logging alert: $e');
    }
  }

  /// Get risk level emoji
  String _getRiskEmoji(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.high:
        return '🚨';
      case RiskLevel.medium:
        return '⚠️';
      case RiskLevel.low:
        return '⚡';
    }
  }

  /// Load notification preferences
  Future<void> _loadNotificationPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    } catch (e) {
      debugPrint('❌ Error loading notification preferences: $e');
    }
  }

  /// Enable/disable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      _notificationsEnabled = enabled;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', enabled);

      debugPrint('🔔 Notifications ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      debugPrint('❌ Error setting notification preference: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    debugPrint('🗑️ All notifications cancelled');
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Get notification history
  Future<List<Map<String, dynamic>>> getAlertHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alertsJson = prefs.getStringList('proximity_alerts_log') ?? [];

      return alertsJson.map((alertJson) {
        return Map<String, dynamic>.from(json.decode(alertJson));
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting alert history: $e');
      return [];
    }
  }

  /// Clear notification history
  Future<void> clearAlertHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('proximity_alerts_log');
      debugPrint('🗑️ Alert history cleared');
    } catch (e) {
      debugPrint('❌ Error clearing alert history: $e');
    }
  }

  // Getters
  bool get isInitialized => _isInitialized;
  bool get notificationsEnabled => _notificationsEnabled;
}

/// Background message handler for Firebase (mobile only)
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(dynamic message) async {
  if (kIsWeb) return;

  debugPrint('📬 Handling background message: ${message.messageId}');

  // Handle background notification logic here
  // This function runs in a separate isolate
}
