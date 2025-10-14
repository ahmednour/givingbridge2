class Conversation {
  final String id;
  final String? title;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final String? lastMessageId;
  final String? lastMessageContent;
  final String? lastMessageSenderId;
  final String? lastMessageSenderName;
  final String? lastMessageTime;
  final int unreadCount;
  final bool isActive;
  final String? donationId;
  final String? requestId;
  final String createdAt;
  final String updatedAt;

  Conversation({
    required this.id,
    this.title,
    required this.participantIds,
    required this.participantNames,
    this.lastMessageId,
    this.lastMessageContent,
    this.lastMessageSenderId,
    this.lastMessageSenderName,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isActive = true,
    this.donationId,
    this.requestId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      title: json['title'],
      participantIds: List<String>.from(
          json['participantIds'] ?? json['participant_ids'] ?? []),
      participantNames: Map<String, String>.from(
          json['participantNames'] ?? json['participant_names'] ?? {}),
      lastMessageId: json['lastMessageId'] ?? json['last_message_id'],
      lastMessageContent:
          json['lastMessageContent'] ?? json['last_message_content'],
      lastMessageSenderId:
          json['lastMessageSenderId'] ?? json['last_message_sender_id'],
      lastMessageSenderName:
          json['lastMessageSenderName'] ?? json['last_message_sender_name'],
      lastMessageTime: json['lastMessageTime'] ?? json['last_message_time'],
      unreadCount: json['unreadCount'] ?? json['unread_count'] ?? 0,
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      donationId: json['donationId'] ?? json['donation_id'],
      requestId: json['requestId'] ?? json['request_id'],
      createdAt: json['createdAt'] ?? json['created_at'],
      updatedAt: json['updatedAt'] ?? json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'participantIds': participantIds,
      'participantNames': participantNames,
      'lastMessageId': lastMessageId,
      'lastMessageContent': lastMessageContent,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageSenderName': lastMessageSenderName,
      'lastMessageTime': lastMessageTime,
      'unreadCount': unreadCount,
      'isActive': isActive,
      'donationId': donationId,
      'requestId': requestId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Conversation copyWith({
    String? id,
    String? title,
    List<String>? participantIds,
    Map<String, String>? participantNames,
    String? lastMessageId,
    String? lastMessageContent,
    String? lastMessageSenderId,
    String? lastMessageSenderName,
    String? lastMessageTime,
    int? unreadCount,
    bool? isActive,
    String? donationId,
    String? requestId,
    String? createdAt,
    String? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      participantIds: participantIds ?? this.participantIds,
      participantNames: participantNames ?? this.participantNames,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageSenderName:
          lastMessageSenderName ?? this.lastMessageSenderName,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isActive: isActive ?? this.isActive,
      donationId: donationId ?? this.donationId,
      requestId: requestId ?? this.requestId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayTitle {
    if (title != null && title!.isNotEmpty) {
      return title!;
    }

    if (participantNames.length == 2) {
      final otherParticipant = participantNames.values.first;
      return otherParticipant;
    }

    return 'Group Chat';
  }

  String get otherParticipantId {
    if (participantIds.length == 2) {
      return participantIds.first;
    }
    return '';
  }

  String get otherParticipantName {
    if (participantNames.length == 2) {
      return participantNames.values.first;
    }
    return '';
  }

  bool get hasUnreadMessages => unreadCount > 0;

  bool get isGroupChat => participantIds.length > 2;

  bool get isDonationRelated => donationId != null && donationId!.isNotEmpty;

  bool get isRequestRelated => requestId != null && requestId!.isNotEmpty;

  DateTime get createdAtDateTime => DateTime.parse(createdAt);
  DateTime get updatedAtDateTime => DateTime.parse(updatedAt);

  DateTime? get lastMessageDateTime {
    if (lastMessageTime == null) return null;
    return DateTime.parse(lastMessageTime!);
  }

  String get timeAgo {
    final now = DateTime.now();
    final lastTime = lastMessageDateTime ?? updatedAtDateTime;
    final difference = now.difference(lastTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String get formattedLastMessageTime {
    final lastTime = lastMessageDateTime ?? updatedAtDateTime;
    final now = DateTime.now();
    final difference = now.difference(lastTime);

    if (difference.inDays > 0) {
      return '${lastTime.day}/${lastTime.month} ${lastTime.hour.toString().padLeft(2, '0')}:${lastTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${lastTime.hour.toString().padLeft(2, '0')}:${lastTime.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Conversation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Conversation(id: $id, title: $title, participantIds: $participantIds, unreadCount: $unreadCount, lastMessageContent: $lastMessageContent)';
  }
}
