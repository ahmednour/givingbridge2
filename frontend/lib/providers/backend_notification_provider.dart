import 'package:flutter/material.dart';
import '../services/backend_notification_service.dart';
import '../services/socket_service.dart';

/// Provider for managing backend notifications (data from API)
class BackendNotificationProvider extends ChangeNotifier {
  final SocketService _socketService = SocketService();

  List<BackendNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  // Getters
  List<BackendNotification> get notifications => _notifications;
  List<BackendNotification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;

  /// Initialize and load notifications
  Future<void> initialize() async {
    await loadNotifications();
    _setupSocketListeners();
    _loadUnreadCount();
  }

  /// Set up WebSocket listeners for real-time notifications
  void _setupSocketListeners() {
    _socketService.onNewNotification = (notification) {
      // Add new notification to the top
      _notifications.insert(0, notification);
      _unreadCount++;
      notifyListeners();
    };

    _socketService.onUnreadNotificationCount = (count) {
      _unreadCount = count;
      notifyListeners();
    };
  }

  /// Load notifications from backend
  Future<void> loadNotifications({
    bool refresh = false,
    bool unreadOnly = false,
    int limit = 20,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _notifications.clear();
      _hasMore = true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await BackendNotificationService.getNotifications(
        page: _currentPage,
        limit: limit,
        unreadOnly: unreadOnly,
      );

      if (response.success && response.data != null) {
        if (refresh) {
          _notifications = response.data!.notifications;
        } else {
          _notifications.addAll(response.data!.notifications);
        }

        _hasMore = response.data!.hasMore;
        _currentPage = response.data!.currentPage;
      } else {
        _error = response.error ?? 'Failed to load notifications';
      }
    } catch (e) {
      _error = 'Error loading notifications: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more notifications (pagination)
  Future<void> loadMore({bool unreadOnly = false}) async {
    if (!_hasMore || _isLoading) return;

    _currentPage++;
    await loadNotifications(unreadOnly: unreadOnly);
  }

  /// Refresh notifications
  Future<void> refresh({bool unreadOnly = false}) async {
    await loadNotifications(refresh: true, unreadOnly: unreadOnly);
    await _loadUnreadCount();
  }

  /// Load unread count
  Future<void> _loadUnreadCount() async {
    try {
      final response = await BackendNotificationService.getUnreadCount();
      if (response.success && response.data != null) {
        _unreadCount = response.data!;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading unread count: $e');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(int id) async {
    try {
      final response = await BackendNotificationService.markAsRead(id);

      if (response.success) {
        // Update local notification
        final index = _notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          final notification = _notifications[index];
          if (!notification.isRead) {
            _notifications[index] = BackendNotification(
              id: notification.id,
              userId: notification.userId,
              type: notification.type,
              title: notification.title,
              message: notification.message,
              isRead: true,
              relatedId: notification.relatedId,
              relatedType: notification.relatedType,
              metadata: notification.metadata,
              createdAt: notification.createdAt,
              updatedAt: notification.updatedAt,
            );
            _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
            notifyListeners();
          }
        }

        // Also mark via WebSocket for real-time sync
        _socketService.markNotificationAsRead(id);
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final response = await BackendNotificationService.markAllAsRead();

      if (response.success) {
        // Update all local notifications
        _notifications = _notifications.map((notification) {
          return BackendNotification(
            id: notification.id,
            userId: notification.userId,
            type: notification.type,
            title: notification.title,
            message: notification.message,
            isRead: true,
            relatedId: notification.relatedId,
            relatedType: notification.relatedType,
            metadata: notification.metadata,
            createdAt: notification.createdAt,
            updatedAt: notification.updatedAt,
          );
        }).toList();

        _unreadCount = 0;
        notifyListeners();

        // Also mark via WebSocket
        _socketService.markAllNotificationsRead();
      }
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(int id) async {
    try {
      final response = await BackendNotificationService.deleteNotification(id);

      if (response.success) {
        final notification = _notifications.firstWhere((n) => n.id == id);
        _notifications.removeWhere((n) => n.id == id);

        if (!notification.isRead) {
          _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
        }

        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      return false;
    }
  }

  /// Delete all notifications
  Future<bool> deleteAllNotifications() async {
    try {
      final response =
          await BackendNotificationService.deleteAllNotifications();

      if (response.success) {
        _notifications.clear();
        _unreadCount = 0;
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error deleting all notifications: $e');
      return false;
    }
  }

  /// Filter notifications by type
  List<BackendNotification> filterByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  /// Get notifications grouped by date
  Map<String, List<BackendNotification>> getGroupedByDate() {
    final Map<String, List<BackendNotification>> grouped = {};

    for (final notification in _notifications) {
      final dateKey = _formatDateKey(notification.createdAt);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }

      grouped[dateKey]!.add(notification);
    }

    return grouped;
  }

  /// Format date key for grouping
  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(date.year, date.month, date.day);

    if (notificationDate == today) {
      return 'Today';
    } else if (notificationDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(notificationDate).inDays < 7) {
      return '${_getDayName(date.weekday)}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Get day name
  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }

  /// Dispose and cleanup
  @override
  void dispose() {
    _socketService.onNewNotification = null;
    _socketService.onUnreadNotificationCount = null;
    super.dispose();
  }
}
