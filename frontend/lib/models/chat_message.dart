class ChatMessage {
  final int id;
  final int senderId;
  final String senderName;
  final int receiverId;
  final String receiverName;
  final int? donationId;
  final int? requestId;
  final String? conversationId;
  final String content;
  final bool isRead;
  final String createdAt;
  final String updatedAt;
  final String? messageType; // 'text', 'image', 'file'
  final String? attachmentUrl;
  final String? attachmentName;
  final int? attachmentSize;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    this.donationId,
    this.requestId,
    this.conversationId,
    required this.content,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
    this.messageType = 'text',
    this.attachmentUrl,
    this.attachmentName,
    this.attachmentSize,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['senderId'] ?? json['sender_id'],
      senderName: json['senderName'] ?? json['sender_name'],
      receiverId: json['receiverId'] ?? json['receiver_id'],
      receiverName: json['receiverName'] ?? json['receiver_name'],
      donationId: json['donationId'] ?? json['donation_id'],
      requestId: json['requestId'] ?? json['request_id'],
      conversationId: json['conversationId'] ?? json['conversation_id'],
      content: json['content'],
      isRead: json['isRead'] ?? json['is_read'] ?? false,
      createdAt: json['createdAt'] ?? json['created_at'] ?? json['createdAt'],
      updatedAt: json['updatedAt'] ?? json['updated_at'] ?? json['updatedAt'],
      messageType: json['messageType'] ?? json['message_type'] ?? 'text',
      attachmentUrl: json['attachmentUrl'] ?? json['attachment_url'],
      attachmentName: json['attachmentName'] ?? json['attachment_name'],
      attachmentSize: json['attachmentSize'] ?? json['attachment_size'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'donationId': donationId,
      'requestId': requestId,
      'conversationId': conversationId,
      'content': content,
      'isRead': isRead,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'messageType': messageType,
      'attachmentUrl': attachmentUrl,
      'attachmentName': attachmentName,
      'attachmentSize': attachmentSize,
    };
  }

  ChatMessage copyWith({
    int? id,
    int? senderId,
    String? senderName,
    int? receiverId,
    String? receiverName,
    int? donationId,
    int? requestId,
    String? conversationId,
    String? content,
    bool? isRead,
    String? createdAt,
    String? updatedAt,
    String? messageType,
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      donationId: donationId ?? this.donationId,
      requestId: requestId ?? this.requestId,
      conversationId: conversationId ?? this.conversationId,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messageType: messageType ?? this.messageType,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentName: attachmentName ?? this.attachmentName,
      attachmentSize: attachmentSize ?? this.attachmentSize,
    );
  }

  bool get isTextMessage => messageType == 'text' || messageType == null;
  bool get isImageMessage => messageType == 'image';
  bool get isFileMessage => messageType == 'file';
  bool get hasAttachment => attachmentUrl != null && attachmentUrl!.isNotEmpty;

  String get displayName => senderName.isNotEmpty ? senderName : 'Unknown User';

  DateTime get createdAtDateTime => DateTime.parse(createdAt);
  DateTime get updatedAtDateTime => DateTime.parse(updatedAt);

  bool get isRecent {
    final now = DateTime.now();
    final messageTime = createdAtDateTime;
    final difference = now.difference(messageTime);
    return difference.inMinutes < 5;
  }

  String get timeAgo {
    final now = DateTime.now();
    final messageTime = createdAtDateTime;
    final difference = now.difference(messageTime);

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

  String get formattedTime {
    final messageTime = createdAtDateTime;
    final now = DateTime.now();
    final difference = now.difference(messageTime);

    if (difference.inDays > 0) {
      return '${messageTime.day}/${messageTime.month} ${messageTime.hour.toString().padLeft(2, '0')}:${messageTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${messageTime.hour.toString().padLeft(2, '0')}:${messageTime.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChatMessage(id: $id, senderId: $senderId, senderName: $senderName, receiverId: $receiverId, receiverName: $receiverName, content: $content, isRead: $isRead, createdAt: $createdAt)';
  }
}
