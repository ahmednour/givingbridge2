class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? location;
  final String? avatarUrl;
  final String createdAt;
  final String updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.location,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      phone: json['phone'],
      location: json['location'],
      avatarUrl: json['avatarUrl'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  bool get isDonor => role == 'donor';
  bool get isReceiver => role == 'receiver';
  bool get isAdmin => role == 'admin';
}
