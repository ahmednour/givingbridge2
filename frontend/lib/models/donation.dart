class Donation {
  final int id;
  final String title;
  final String description;
  final String category;
  final String condition;
  final String location;
  final int donorId;
  final String donorName;
  final String? imageUrl;
  final bool isAvailable;
  final String status;
  final String createdAt;
  final String updatedAt;

  Donation({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.condition,
    required this.location,
    required this.donorId,
    required this.donorName,
    this.imageUrl,
    required this.isAvailable,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      condition: json['condition'],
      location: json['location'],
      donorId: json['donorId'],
      donorName: json['donorName'],
      imageUrl: json['imageUrl'],
      isAvailable: json['isAvailable'] ?? true,
      status: json['status'] ?? 'available',
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'condition': condition,
      'location': location,
      'donorId': donorId,
      'donorName': donorName,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  String get categoryDisplayName {
    switch (category) {
      case 'food':
        return 'Food';
      case 'clothes':
        return 'Clothes';
      case 'books':
        return 'Books';
      case 'electronics':
        return 'Electronics';
      case 'other':
        return 'Other';
      default:
        return category;
    }
  }

  String get conditionDisplayName {
    switch (condition) {
      case 'new':
        return 'New';
      case 'like-new':
        return 'Like New';
      case 'good':
        return 'Good';
      case 'fair':
        return 'Fair';
      default:
        return condition;
    }
  }

  String get statusDisplayName {
    switch (status) {
      case 'available':
        return 'Available';
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
