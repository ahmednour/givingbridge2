import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../core/config/api_config.dart';

/// Model for backend notification
class BackendNotification {
  final int id;
  final int userId;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final int? relatedId;
  final String? relatedType;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  BackendNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.relatedId,
    this.relatedType,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BackendNotification.fromJson(Map<String, dynamic> json) {
    return BackendNotification(
      id: json['id'],
      userId: json['userId'],
      type: json['type'],
      title: json['title'],
      message: json['message'],
      isRead: json['isRead'] ?? false,
      relatedId: json['relatedId'],
      relatedType: json['relatedType'],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'isRead': isRead,
      'relatedId': relatedId,
      'relatedType': relatedType,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Notification types
  static const String typeDonationRequest = 'donation_request';
  static const String typeDonationApproved = 'donation_approved';
  static const String typeNewDonation = 'new_donation';
  static const String typeMessage = 'message';
  static const String typeReminder = 'reminder';
  static const String typeSystem = 'system';
  static const String typeCelebration = 'celebration';
}

/// Pagination info for notifications
class NotificationPagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasMore;

  NotificationPagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasMore,
  });

  factory NotificationPagination.fromJson(Map<String, dynamic> json) {
    return NotificationPagination(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      totalPages: json['totalPages'] ?? 0,
      hasMore: json['hasMore'] ?? false,
    );
  }
}

/// Response for paginated notifications
class NotificationsResponse {
  final List<BackendNotification> notifications;
  final NotificationPagination pagination;

  NotificationsResponse({
    required this.notifications,
    required this.pagination,
  });

  bool get hasMore => pagination.hasMore;
  int get currentPage => pagination.page;
  int get totalPages => pagination.totalPages;
}

/// Service for backend notification API endpoints
class BackendNotificationService {
  static String get baseUrl => '${ApiConfig.baseUrl}/notifications';

  /// Helper method to get headers with auth token
  static Future<Map<String, String>> _getHeaders() async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    String? token = await ApiService.getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Get all notifications with pagination and filtering
  static Future<ApiResponse<NotificationsResponse>> getNotifications({
    int page = 1,
    int limit = 20,
    bool? unreadOnly,
  }) async {
    try {
      List<String> params = [];
      params.add('page=$page');
      params.add('limit=$limit');
      if (unreadOnly != null) params.add('unreadOnly=$unreadOnly');

      final queryParams = '?${params.join('&')}';

      final response = await http.get(
        Uri.parse('$baseUrl$queryParams'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final notifications = (data['notifications'] as List)
            .map((json) => BackendNotification.fromJson(json))
            .toList();

        final pagination = NotificationPagination.fromJson(data['pagination']);

        return ApiResponse.success(
          NotificationsResponse(
            notifications: notifications,
            pagination: pagination,
          ),
        );
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to load notifications');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Get unread notification count
  static Future<ApiResponse<int>> getUnreadCount() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/unread-count'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(data['count'] ?? 0);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to get unread count');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Mark a notification as read
  static Future<ApiResponse<BackendNotification>> markAsRead(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id/read'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final notification = BackendNotification.fromJson(data['notification']);
        return ApiResponse.success(notification);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to mark notification as read');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Mark all notifications as read
  static Future<ApiResponse<String>> markAllAsRead() async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/read-all'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(data['message'] ?? 'All marked as read');
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to mark all as read');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Delete a notification
  static Future<ApiResponse<String>> deleteNotification(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(data['message'] ?? 'Notification deleted');
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to delete notification');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Delete all notifications
  static Future<ApiResponse<String>> deleteAllNotifications() async {
    try {
      final response = await http.delete(
        Uri.parse(baseUrl),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(
            data['message'] ?? 'All notifications deleted');
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
            error['message'] ?? 'Failed to delete all notifications');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
}
