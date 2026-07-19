import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];
  String _selectedFilter = 'All';
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    
    // Initialize sample notifications for development
    if (_notifications.isEmpty) {
      _notificationService.initializeSampleNotifications();
      _loadNotifications();
    }
  }

  void _loadNotifications() {
    setState(() {
      _notifications = _notificationService.getAllNotifications();
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<NotificationModel> filtered = _notificationService.getAllNotifications();

    // Filter by read status
    if (_showUnreadOnly) {
      filtered = filtered.where((n) => !n.isRead).toList();
    }

    // Filter by type
    if (_selectedFilter != 'All') {
      final filterType = NotificationType.values.firstWhere(
        (type) => type.displayName == _selectedFilter,
        orElse: () => NotificationType.general,
      );
      filtered = filtered.where((n) => n.type == filterType).toList();
    }

    setState(() {
      _notifications = filtered;
    });
  }

  void _markAsRead(NotificationModel notification) {
    if (!notification.isRead) {
      _notificationService.markAsRead(notification.id);
      _loadNotifications();
    }
  }

  void _markAllAsRead() {
    _notificationService.markAllAsRead();
    _loadNotifications();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _deleteNotification(NotificationModel notification) {
    _notificationService.deleteNotification(notification.id);
    _loadNotifications();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification deleted'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to delete all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _notificationService.clearAllNotifications();
              _loadNotifications();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications cleared'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return AppColors.grey500;
      case NotificationPriority.normal:
        return AppColors.primaryBlue;
      case NotificationPriority.high:
        return AppColors.warning;
      case NotificationPriority.critical:
        return AppColors.error;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.approval:
        return AppColors.success;
      case NotificationType.rejection:
        return AppColors.error;
      case NotificationType.emergency:
        return AppColors.error;
      case NotificationType.alert:
        return AppColors.warning;
      case NotificationType.appointment:
        return AppColors.primaryBlue;
      case NotificationType.medication:
        return AppColors.primaryGreen;
      case NotificationType.system:
        return AppColors.grey600;
      default:
        return AppColors.primaryBlue;
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.mark_email_read),
            tooltip: 'Mark all as read',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear_all') {
                _clearAllNotifications();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Clear All'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Type Filter
                Row(
                  children: [
                    Text(
                      'Filter: ',
                      style: AppTextStyles.label,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            'All',
                            ...NotificationType.values.map((type) => type.displayName),
                          ].map((filter) {
                            final isSelected = _selectedFilter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(filter),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedFilter = filter;
                                  });
                                  _applyFilters();
                                },
                                selectedColor: AppColors.primaryBlue.withOpacity(0.2),
                                checkmarkColor: AppColors.primaryBlue,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Unread Filter
                Row(
                  children: [
                    Checkbox(
                      value: _showUnreadOnly,
                      onChanged: (value) {
                        setState(() {
                          _showUnreadOnly = value ?? false;
                        });
                        _applyFilters();
                      },
                      activeColor: AppColors.primaryBlue,
                    ),
                    const Text('Show unread only'),
                    const Spacer(),
                    Text(
                      '${_notificationService.getUnreadCount()} unread',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Notifications List
          Expanded(
            child: _notifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _buildNotificationCard(notification);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            _showUnreadOnly ? 'No unread notifications' : 'No notifications',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _showUnreadOnly
                ? 'You\'re all caught up!'
                : 'Notifications will appear here when you receive them',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grey500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification.isRead ? 1 : 3,
      child: InkWell(
        onTap: () => _markAsRead(notification),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: notification.isRead
                ? null
                : Border.all(
                    color: _getPriorityColor(notification.priority).withOpacity(0.3),
                    width: 2,
                  ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Type Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTypeColor(notification.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      notification.type.icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Title and Type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: AppTextStyles.subtitle1.copyWith(
                            fontWeight: notification.isRead
                                ? FontWeight.normal
                                : FontWeight.w600,
                          ),
                        ),
                        Text(
                          notification.type.displayName,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: _getTypeColor(notification.type),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Priority Indicator
                  if (notification.priority != NotificationPriority.normal)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(notification.priority),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        notification.priority.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  
                  // Unread Indicator
                  if (!notification.isRead)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  
                  // More Actions
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteNotification(notification);
                      } else if (value == 'mark_read') {
                        _markAsRead(notification);
                      }
                    },
                    itemBuilder: (context) => [
                      if (!notification.isRead)
                        const PopupMenuItem(
                          value: 'mark_read',
                          child: Row(
                            children: [
                              Icon(Icons.mark_email_read),
                              SizedBox(width: 8),
                              Text('Mark as read'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Message
              Text(
                notification.message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: notification.isRead
                      ? AppColors.grey600
                      : AppColors.grey800,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Footer Row
              Row(
                children: [
                  Text(
                    _getTimeAgo(notification.timestamp),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                  const Spacer(),
                  if (notification.actionUrl != null)
                    TextButton(
                      onPressed: () {
                        // Handle action URL navigation
                        _markAsRead(notification);
                      },
                      child: const Text('Take Action'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
