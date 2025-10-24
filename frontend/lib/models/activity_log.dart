import 'package:flutter/material.dart';
import '../core/theme/design_system.dart';

enum ActivityCategory {
  auth,
  donation,
  request,
  message,
  user,
  admin,
  notification,
  report,
}

class ActivityLog {
  final int id;
  final int userId;
  final String userName;
  final String userRole;
  final String action;
  final ActivityCategory actionCategory;
  final String description;
  final String? entityType;
  final int? entityId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  ActivityLog({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.action,
    required this.actionCategory,
    required this.description,
    this.entityType,
    this.entityId,
    this.metadata,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userRole: json['userRole'],
      action: json['action'],
      actionCategory: _parseCategory(json['actionCategory']),
      description: json['description'],
      entityType: json['entityType'],
      entityId: json['entityId'],
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'action': action,
      'actionCategory': actionCategory.name,
      'description': description,
      'entityType': entityType,
      'entityId': entityId,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static ActivityCategory _parseCategory(String category) {
    switch (category.toLowerCase()) {
      case 'auth':
        return ActivityCategory.auth;
      case 'donation':
        return ActivityCategory.donation;
      case 'request':
        return ActivityCategory.request;
      case 'message':
        return ActivityCategory.message;
      case 'user':
        return ActivityCategory.user;
      case 'admin':
        return ActivityCategory.admin;
      case 'notification':
        return ActivityCategory.notification;
      case 'report':
        return ActivityCategory.report;
      default:
        return ActivityCategory.user;
    }
  }

  // Helper getters for UI display
  String get categoryDisplayName {
    switch (actionCategory) {
      case ActivityCategory.auth:
        return 'Authentication';
      case ActivityCategory.donation:
        return 'Donation';
      case ActivityCategory.request:
        return 'Request';
      case ActivityCategory.message:
        return 'Message';
      case ActivityCategory.user:
        return 'User';
      case ActivityCategory.admin:
        return 'Admin';
      case ActivityCategory.notification:
        return 'Notification';
      case ActivityCategory.report:
        return 'Report';
    }
  }

  IconData get categoryIcon {
    switch (actionCategory) {
      case ActivityCategory.auth:
        return Icons.login;
      case ActivityCategory.donation:
        return Icons.volunteer_activism;
      case ActivityCategory.request:
        return Icons.request_page;
      case ActivityCategory.message:
        return Icons.message;
      case ActivityCategory.user:
        return Icons.person;
      case ActivityCategory.admin:
        return Icons.admin_panel_settings;
      case ActivityCategory.notification:
        return Icons.notifications;
      case ActivityCategory.report:
        return Icons.report;
    }
  }

  Color get categoryColor {
    switch (actionCategory) {
      case ActivityCategory.auth:
        return DesignSystem.info;
      case ActivityCategory.donation:
        return DesignSystem.success;
      case ActivityCategory.request:
        return DesignSystem.primaryBlue;
      case ActivityCategory.message:
        return DesignSystem.neutral600;
      case ActivityCategory.user:
        return DesignSystem.warning;
      case ActivityCategory.admin:
        return DesignSystem.error;
      case ActivityCategory.notification:
        return DesignSystem.info;
      case ActivityCategory.report:
        return DesignSystem.error;
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String get formattedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
}

class ActivityLogStatistics {
  final int totalLogs;
  final Map<String, int> byCategory;
  final Map<String, int> byRole;
  final List<TopUser> topUsers;
  final List<TimelineData> timeline;

  ActivityLogStatistics({
    required this.totalLogs,
    required this.byCategory,
    required this.byRole,
    required this.topUsers,
    required this.timeline,
  });

  factory ActivityLogStatistics.fromJson(Map<String, dynamic> json) {
    return ActivityLogStatistics(
      totalLogs: json['totalLogs'] ?? 0,
      byCategory: (json['byCategory'] as List?)?.fold<Map<String, int>>(
            {},
            (map, item) => map
              ..[item['actionCategory']] = item['count'] is int
                  ? item['count']
                  : int.parse(item['count'].toString()),
          ) ??
          {},
      byRole: (json['byRole'] as List?)?.fold<Map<String, int>>(
            {},
            (map, item) => map
              ..[item['userRole']] = item['count'] is int
                  ? item['count']
                  : int.parse(item['count'].toString()),
          ) ??
          {},
      topUsers: (json['topUsers'] as List?)
              ?.map((user) => TopUser.fromJson(user))
              .toList() ??
          [],
      timeline: (json['timeline'] as List?)
              ?.map((data) => TimelineData.fromJson(data))
              .toList() ??
          [],
    );
  }
}

class TopUser {
  final int userId;
  final String userName;
  final int activityCount;

  TopUser({
    required this.userId,
    required this.userName,
    required this.activityCount,
  });

  factory TopUser.fromJson(Map<String, dynamic> json) {
    return TopUser(
      userId: json['userId'],
      userName: json['userName'],
      activityCount: int.parse(json['activityCount'].toString()),
    );
  }
}

class TimelineData {
  final DateTime date;
  final int count;

  TimelineData({
    required this.date,
    required this.count,
  });

  factory TimelineData.fromJson(Map<String, dynamic> json) {
    return TimelineData(
      date: DateTime.parse(json['date']),
      count: int.parse(json['count'].toString()),
    );
  }
}
