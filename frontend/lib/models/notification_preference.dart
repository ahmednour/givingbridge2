// Simplified notification preferences for MVP - only basic in-app notifications for messages
class NotificationPreference {
  final int id;
  final int userId;

  // Basic in-app notifications (only for messages)
  final bool inAppEnabled;
  final bool inAppNewMessage;

  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationPreference({
    required this.id,
    required this.userId,
    required this.inAppEnabled,
    required this.inAppNewMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationPreference.fromJson(Map<String, dynamic> json) {
    return NotificationPreference(
      id: json['id'] as int,
      userId: json['userId'] as int,
      inAppEnabled: json['inAppEnabled'] as bool? ?? true,
      inAppNewMessage: json['inAppNewMessage'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'inAppEnabled': inAppEnabled,
      'inAppNewMessage': inAppNewMessage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  NotificationPreference copyWith({
    int? id,
    int? userId,
    bool? inAppEnabled,
    bool? inAppNewMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationPreference(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      inAppEnabled: inAppEnabled ?? this.inAppEnabled,
      inAppNewMessage: inAppNewMessage ?? this.inAppNewMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'NotificationPreference(id: $id, userId: $userId, '
        'inAppEnabled: $inAppEnabled, inAppNewMessage: $inAppNewMessage)';
  }
}
