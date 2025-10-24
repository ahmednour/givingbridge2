class NotificationPreference {
  final int id;
  final int userId;

  // Email Notifications
  final bool emailEnabled;
  final bool emailNewMessage;
  final bool emailDonationRequest;
  final bool emailRequestUpdate;
  final bool emailDonationUpdate;

  // Push Notifications
  final bool pushEnabled;
  final bool pushNewMessage;
  final bool pushDonationRequest;
  final bool pushRequestUpdate;
  final bool pushDonationUpdate;

  // In-App Notifications
  final bool inAppEnabled;
  final bool inAppNewMessage;
  final bool inAppDonationRequest;
  final bool inAppRequestUpdate;
  final bool inAppDonationUpdate;

  // Additional Settings
  final bool soundEnabled;
  final bool vibrationEnabled;

  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationPreference({
    required this.id,
    required this.userId,
    required this.emailEnabled,
    required this.emailNewMessage,
    required this.emailDonationRequest,
    required this.emailRequestUpdate,
    required this.emailDonationUpdate,
    required this.pushEnabled,
    required this.pushNewMessage,
    required this.pushDonationRequest,
    required this.pushRequestUpdate,
    required this.pushDonationUpdate,
    required this.inAppEnabled,
    required this.inAppNewMessage,
    required this.inAppDonationRequest,
    required this.inAppRequestUpdate,
    required this.inAppDonationUpdate,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationPreference.fromJson(Map<String, dynamic> json) {
    return NotificationPreference(
      id: json['id'] as int,
      userId: json['userId'] as int,
      emailEnabled: json['emailEnabled'] as bool? ?? true,
      emailNewMessage: json['emailNewMessage'] as bool? ?? true,
      emailDonationRequest: json['emailDonationRequest'] as bool? ?? true,
      emailRequestUpdate: json['emailRequestUpdate'] as bool? ?? true,
      emailDonationUpdate: json['emailDonationUpdate'] as bool? ?? true,
      pushEnabled: json['pushEnabled'] as bool? ?? true,
      pushNewMessage: json['pushNewMessage'] as bool? ?? true,
      pushDonationRequest: json['pushDonationRequest'] as bool? ?? true,
      pushRequestUpdate: json['pushRequestUpdate'] as bool? ?? true,
      pushDonationUpdate: json['pushDonationUpdate'] as bool? ?? true,
      inAppEnabled: json['inAppEnabled'] as bool? ?? true,
      inAppNewMessage: json['inAppNewMessage'] as bool? ?? true,
      inAppDonationRequest: json['inAppDonationRequest'] as bool? ?? true,
      inAppRequestUpdate: json['inAppRequestUpdate'] as bool? ?? true,
      inAppDonationUpdate: json['inAppDonationUpdate'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'emailEnabled': emailEnabled,
      'emailNewMessage': emailNewMessage,
      'emailDonationRequest': emailDonationRequest,
      'emailRequestUpdate': emailRequestUpdate,
      'emailDonationUpdate': emailDonationUpdate,
      'pushEnabled': pushEnabled,
      'pushNewMessage': pushNewMessage,
      'pushDonationRequest': pushDonationRequest,
      'pushRequestUpdate': pushRequestUpdate,
      'pushDonationUpdate': pushDonationUpdate,
      'inAppEnabled': inAppEnabled,
      'inAppNewMessage': inAppNewMessage,
      'inAppDonationRequest': inAppDonationRequest,
      'inAppRequestUpdate': inAppRequestUpdate,
      'inAppDonationUpdate': inAppDonationUpdate,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  NotificationPreference copyWith({
    int? id,
    int? userId,
    bool? emailEnabled,
    bool? emailNewMessage,
    bool? emailDonationRequest,
    bool? emailRequestUpdate,
    bool? emailDonationUpdate,
    bool? pushEnabled,
    bool? pushNewMessage,
    bool? pushDonationRequest,
    bool? pushRequestUpdate,
    bool? pushDonationUpdate,
    bool? inAppEnabled,
    bool? inAppNewMessage,
    bool? inAppDonationRequest,
    bool? inAppRequestUpdate,
    bool? inAppDonationUpdate,
    bool? soundEnabled,
    bool? vibrationEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationPreference(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      emailNewMessage: emailNewMessage ?? this.emailNewMessage,
      emailDonationRequest: emailDonationRequest ?? this.emailDonationRequest,
      emailRequestUpdate: emailRequestUpdate ?? this.emailRequestUpdate,
      emailDonationUpdate: emailDonationUpdate ?? this.emailDonationUpdate,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      pushNewMessage: pushNewMessage ?? this.pushNewMessage,
      pushDonationRequest: pushDonationRequest ?? this.pushDonationRequest,
      pushRequestUpdate: pushRequestUpdate ?? this.pushRequestUpdate,
      pushDonationUpdate: pushDonationUpdate ?? this.pushDonationUpdate,
      inAppEnabled: inAppEnabled ?? this.inAppEnabled,
      inAppNewMessage: inAppNewMessage ?? this.inAppNewMessage,
      inAppDonationRequest: inAppDonationRequest ?? this.inAppDonationRequest,
      inAppRequestUpdate: inAppRequestUpdate ?? this.inAppRequestUpdate,
      inAppDonationUpdate: inAppDonationUpdate ?? this.inAppDonationUpdate,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'NotificationPreference(id: $id, userId: $userId, '
        'emailEnabled: $emailEnabled, pushEnabled: $pushEnabled, '
        'inAppEnabled: $inAppEnabled, soundEnabled: $soundEnabled, '
        'vibrationEnabled: $vibrationEnabled)';
  }
}
