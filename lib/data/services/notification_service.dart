import 'dart:math';
import '../models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Mock notification storage - replace with actual database/API calls
  final List<NotificationModel> _notifications = [];
  final List<Function(NotificationModel)> _listeners = [];

  // Get all notifications for a user
  List<NotificationModel> getAllNotifications() {
    return List.from(_notifications);
  }

  // Get unread notifications
  List<NotificationModel> getUnreadNotifications() {
    return _notifications.where((notification) => !notification.isRead).toList();
  }

  // Get notifications by type
  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return _notifications.where((notification) => notification.type == type).toList();
  }

  // Get notifications by priority
  List<NotificationModel> getNotificationsByPriority(NotificationPriority priority) {
    return _notifications.where((notification) => notification.priority == priority).toList();
  }

  // Get unread count
  int getUnreadCount() {
    return _notifications.where((notification) => !notification.isRead).length;
  }

  // Add a new notification
  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification); // Add to beginning for chronological order
    _notifyListeners(notification);
  }

  // Mark notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  // Mark all notifications as read
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  // Delete notification
  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
  }

  // Clear all notifications
  void clearAllNotifications() {
    _notifications.clear();
  }

  // Add listener for new notifications
  void addListener(Function(NotificationModel) listener) {
    _listeners.add(listener);
  }

  // Remove listener
  void removeListener(Function(NotificationModel) listener) {
    _listeners.remove(listener);
  }

  // Notify all listeners
  void _notifyListeners(NotificationModel notification) {
    for (final listener in _listeners) {
      listener(notification);
    }
  }

  // Create specific notification types
  void sendApprovalNotification({
    required String title,
    required String message,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) {
    final notification = NotificationModel(
      id: _generateId(),
      title: title,
      message: message,
      type: NotificationType.approval,
      priority: NotificationPriority.high,
      timestamp: DateTime.now(),
      actionUrl: actionUrl,
      metadata: metadata,
    );
    addNotification(notification);
  }

  void sendRejectionNotification({
    required String title,
    required String message,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) {
    final notification = NotificationModel(
      id: _generateId(),
      title: title,
      message: message,
      type: NotificationType.rejection,
      priority: NotificationPriority.high,
      timestamp: DateTime.now(),
      actionUrl: actionUrl,
      metadata: metadata,
    );
    addNotification(notification);
  }

  void sendReminderNotification({
    required String title,
    required String message,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) {
    final notification = NotificationModel(
      id: _generateId(),
      title: title,
      message: message,
      type: NotificationType.reminder,
      priority: NotificationPriority.normal,
      timestamp: DateTime.now(),
      actionUrl: actionUrl,
      metadata: metadata,
    );
    addNotification(notification);
  }

  void sendEmergencyNotification({
    required String title,
    required String message,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) {
    final notification = NotificationModel(
      id: _generateId(),
      title: title,
      message: message,
      type: NotificationType.emergency,
      priority: NotificationPriority.critical,
      timestamp: DateTime.now(),
      actionUrl: actionUrl,
      metadata: metadata,
    );
    addNotification(notification);
  }

  void sendAppointmentNotification({
    required String title,
    required String message,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) {
    final notification = NotificationModel(
      id: _generateId(),
      title: title,
      message: message,
      type: NotificationType.appointment,
      priority: NotificationPriority.normal,
      timestamp: DateTime.now(),
      actionUrl: actionUrl,
      metadata: metadata,
    );
    addNotification(notification);
  }

  void sendMedicationReminder({
    required String title,
    required String message,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) {
    final notification = NotificationModel(
      id: _generateId(),
      title: title,
      message: message,
      type: NotificationType.medication,
      priority: NotificationPriority.normal,
      timestamp: DateTime.now(),
      actionUrl: actionUrl,
      metadata: metadata,
    );
    addNotification(notification);
  }

  // Generate unique ID for notifications
  String _generateId() {
    final random = Random();
    return 'notif_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(1000)}';
  }

  // Initialize with sample notifications (for development)
  void initializeSampleNotifications() {
    final sampleNotifications = [
      NotificationModel(
        id: _generateId(),
        title: 'Registration Approved',
        message: 'Your hospital registration has been approved by the Regional Officer.',
        type: NotificationType.approval,
        priority: NotificationPriority.high,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: _generateId(),
        title: 'Appointment Reminder',
        message: 'You have an appointment tomorrow at 10:00 AM with Dr. Smith.',
        type: NotificationType.appointment,
        priority: NotificationPriority.normal,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      NotificationModel(
        id: _generateId(),
        title: 'Medication Reminder',
        message: 'Time to take your morning medication.',
        type: NotificationType.medication,
        priority: NotificationPriority.normal,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      NotificationModel(
        id: _generateId(),
        title: 'System Maintenance',
        message: 'The system will undergo maintenance tonight from 12:00 AM to 2:00 AM.',
        type: NotificationType.system,
        priority: NotificationPriority.low,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      NotificationModel(
        id: _generateId(),
        title: 'Emergency Alert',
        message: 'Health emergency reported in your area. Please take necessary precautions.',
        type: NotificationType.emergency,
        priority: NotificationPriority.critical,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];

    _notifications.addAll(sampleNotifications);
  }
}
