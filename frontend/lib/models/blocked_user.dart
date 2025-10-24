class BlockedUser {
  final int id;
  final int blockerId;
  final int blockedId;
  final String? reason;
  final String createdAt;
  final UserInfo? blockedUserInfo;

  BlockedUser({
    required this.id,
    required this.blockerId,
    required this.blockedId,
    this.reason,
    required this.createdAt,
    this.blockedUserInfo,
  });

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    return BlockedUser(
      id: json['id'],
      blockerId: json['blockerId'],
      blockedId: json['blockedId'],
      reason: json['reason'],
      createdAt: json['createdAt'],
      blockedUserInfo: json['blockedUser'] != null
          ? UserInfo.fromJson(json['blockedUser'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'blockerId': blockerId,
      'blockedId': blockedId,
      'reason': reason,
      'createdAt': createdAt,
      if (blockedUserInfo != null) 'blockedUser': blockedUserInfo!.toJson(),
    };
  }
}

class UserInfo {
  final int id;
  final String name;
  final String email;
  final String? avatarUrl;

  UserInfo({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
    };
  }
}
