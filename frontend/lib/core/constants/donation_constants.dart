/// Donation-related constants and enums
import 'package:flutter/material.dart';

enum DonationCategory {
  medical('medical', 'Medical', 'طبي'),
  education('education', 'Education', 'تعليم'),
  food('food', 'Food', 'طعام'),
  housing('housing', 'Housing', 'إسكان'),
  emergency('emergency', 'Emergency', 'طوارئ'),
  clothes('clothes', 'Clothes', 'ملابس'),
  books('books', 'Books', 'كتب'),
  electronics('electronics', 'Electronics', 'إلكترونيات'),
  furniture('furniture', 'Furniture', 'أثاث'),
  toys('toys', 'Toys', 'ألعاب'),
  other('other', 'Other', 'أخرى');

  const DonationCategory(this.value, this.displayNameEn, this.displayNameAr);

  final String value;
  final String displayNameEn;
  final String displayNameAr;

  String getDisplayName(bool isArabic) =>
      isArabic ? displayNameAr : displayNameEn;

  static DonationCategory fromString(String value) {
    return DonationCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => DonationCategory.other,
    );
  }
}

enum DonationCondition {
  newCondition('new', 'New', 'جديد'),
  likeNew('like-new', 'Like New', 'كالجديد'),
  good('good', 'Good', 'جيد'),
  fair('fair', 'Fair', 'مقبول');

  const DonationCondition(this.value, this.displayNameEn, this.displayNameAr);

  final String value;
  final String displayNameEn;
  final String displayNameAr;

  String getDisplayName(bool isArabic) =>
      isArabic ? displayNameAr : displayNameEn;

  static DonationCondition fromString(String value) {
    return DonationCondition.values.firstWhere(
      (condition) => condition.value == value,
      orElse: () => DonationCondition.good,
    );
  }
}

enum DonationStatus {
  available('available', 'Available', 'متاح'),
  pending('pending', 'Pending', 'في الانتظار'),
  completed('completed', 'Completed', 'مكتمل'),
  cancelled('cancelled', 'Cancelled', 'ملغي');

  const DonationStatus(this.value, this.displayNameEn, this.displayNameAr);

  final String value;
  final String displayNameEn;
  final String displayNameAr;

  String getDisplayName(bool isArabic) =>
      isArabic ? displayNameAr : displayNameEn;

  static DonationStatus fromString(String value) {
    return DonationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => DonationStatus.available,
    );
  }
}

enum RequestStatus {
  pending('pending', 'Pending', 'في الانتظار'),
  approved('approved', 'Approved', 'موافق عليه'),
  declined('declined', 'Declined', 'مرفوض'),
  completed('completed', 'Completed', 'مكتمل'),
  cancelled('cancelled', 'Cancelled', 'ملغي');

  const RequestStatus(this.value, this.displayNameEn, this.displayNameAr);

  final String value;
  final String displayNameEn;
  final String displayNameAr;

  String getDisplayName(bool isArabic) =>
      isArabic ? displayNameAr : displayNameEn;

  static RequestStatus fromString(String value) {
    return RequestStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => RequestStatus.pending,
    );
  }
}

enum UserRole {
  donor('donor', 'Donor', 'متبرع'),
  receiver('receiver', 'Receiver', 'مستقبل'),
  admin('admin', 'Admin', 'مدير');

  const UserRole(this.value, this.displayNameEn, this.displayNameAr);

  final String value;
  final String displayNameEn;
  final String displayNameAr;

  String getDisplayName(bool isArabic) =>
      isArabic ? displayNameAr : displayNameEn;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.donor,
    );
  }
}

class DonationConstants {
  // Validation Limits
  static const int titleMinLength = 3;
  static const int titleMaxLength = 100;
  static const int descriptionMinLength = 10;
  static const int descriptionMaxLength = 1000;
  static const int locationMinLength = 2;
  static const int locationMaxLength = 100;
  static const int messageMaxLength = 500;

  // Image Constraints
  static const int maxImageCount = 5;
  static const List<String> allowedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp'
  ];
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB

  // Search and Filter
  static const int searchMinLength = 2;
  static const int searchMaxLength = 50;
  static const int maxSearchRadius = 50; // kilometers
  static const int defaultSearchRadius = 10; // kilometers

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Status Colors
  static const Map<String, int> statusColors = {
    'available': 0xFF10B981, // Green
    'pending': 0xFFF59E0B, // Orange
    'completed': 0xFF3B82F6, // Blue
    'cancelled': 0xFF6B7280, // Gray
  };

  // Category Icons
  static const Map<String, String> categoryIcons = {
    'medical': 'medical_services',
    'education': 'school',
    'food': 'restaurant',
    'housing': 'home',
    'emergency': 'emergency',
    'clothes': 'checkroom',
    'books': 'menu_book',
    'electronics': 'devices',
    'furniture': 'chair',
    'toys': 'toys',
    'other': 'category',
  };

  // Condition Colors
  static const Map<String, int> conditionColors = {
    'new': 0xFF10B981, // Green
    'like-new': 0xFF3B82F6, // Blue
    'good': 0xFFF59E0B, // Orange
    'fair': 0xFF6B7280, // Gray
  };

  // Request Status Colors
  static const Map<String, int> requestStatusColors = {
    'pending': 0xFFF59E0B, // Orange
    'approved': 0xFF10B981, // Green
    'declined': 0xFFEF4444, // Red
    'completed': 0xFF3B82F6, // Blue
    'cancelled': 0xFF6B7280, // Gray
  };

  // Time Formats
  static const String timeFormatShort = 'MMM dd, yyyy';
  static const String timeFormatLong = 'MMMM dd, yyyy \'at\' h:mm a';
  static const String timeFormatRelative = 'relative';

  // Distance Units
  static const String distanceUnitKm = 'km';
  static const String distanceUnitMiles = 'miles';

  // Default Values
  static const String defaultCategory = 'other';
  static const String defaultCondition = 'good';
  static const String defaultStatus = 'available';
  static const String defaultLocation = '';

  // Error Messages
  static const String errorTitleRequired = 'Title is required';
  static const String errorDescriptionRequired = 'Description is required';
  static const String errorLocationRequired = 'Location is required';
  static const String errorCategoryRequired = 'Category is required';
  static const String errorConditionRequired = 'Condition is required';
  static const String errorImageTooLarge = 'Image size must be less than 5MB';
  static const String errorInvalidImageFormat = 'Invalid image format';
  static const String errorMaxImagesExceeded = 'Maximum 5 images allowed';

  // Success Messages
  static const String successDonationCreated = 'Donation created successfully';
  static const String successDonationUpdated = 'Donation updated successfully';
  static const String successDonationDeleted = 'Donation deleted successfully';
  static const String successRequestSent = 'Request sent successfully';
  static const String successRequestUpdated = 'Request updated successfully';
}

/// Category descriptions in Arabic and English
class CategoryDescriptions {
  static const Map<String, Map<String, String>> descriptions = {
    'medical': {
      'en': 'Medical supplies, medications, and healthcare equipment',
      'ar': 'مستلزمات طبية وأدوية ومعدات رعاية صحية'
    },
    'education': {
      'en': 'School books, educational supplies, and learning materials',
      'ar': 'كتب مدرسية ولوازم تعليمية ومواد تعلم'
    },
    'food': {
      'en': 'Food items, groceries, and ready-to-eat meals',
      'ar': 'مواد غذائية وبقالة ووجبات جاهزة'
    },
    'housing': {
      'en': 'Home furniture and housing essentials',
      'ar': 'أثاث منزلي ومستلزمات السكن'
    },
    'emergency': {
      'en': 'Urgent aid and emergency supplies',
      'ar': 'مساعدات عاجلة وإمدادات طوارئ'
    },
    'clothes': {
      'en': 'Clothing, shoes, and accessories',
      'ar': 'ملابس وأحذية وإكسسوارات'
    },
    'books': {
      'en': 'Books, magazines, and reading materials',
      'ar': 'كتب ومجلات ومواد قراءة'
    },
    'electronics': {
      'en': 'Electronic devices and technology items',
      'ar': 'أجهزة إلكترونية وعناصر تقنية'
    },
    'furniture': {
      'en': 'Home and office furniture',
      'ar': 'أثاث منزلي ومكتبي'
    },
    'toys': {
      'en': 'Toys and entertainment for children',
      'ar': 'ألعاب وترفيه للأطفال'
    },
    'other': {
      'en': 'Various other items',
      'ar': 'عناصر أخرى متنوعة'
    },
  };

  static String getDescription(String category, bool isArabic) {
    final categoryDesc = descriptions[category];
    if (categoryDesc == null) return '';
    return categoryDesc[isArabic ? 'ar' : 'en'] ?? '';
  }
}

/// Helper class for category-related utilities
class CategoryHelper {
  /// Get all categories with icons (for filter/browse screens)
  static List<Map<String, dynamic>> getAllCategories() {
    return [
      {'value': 'all', 'label': 'All', 'icon': Icons.apps},
      {
        'value': DonationCategory.medical.value,
        'label': 'Medical',
        'icon': Icons.medical_services
      },
      {
        'value': DonationCategory.education.value,
        'label': 'Education',
        'icon': Icons.school
      },
      {
        'value': DonationCategory.food.value,
        'label': 'Food',
        'icon': Icons.restaurant
      },
      {
        'value': DonationCategory.housing.value,
        'label': 'Housing',
        'icon': Icons.home
      },
      {
        'value': DonationCategory.emergency.value,
        'label': 'Emergency',
        'icon': Icons.emergency
      },
      {
        'value': DonationCategory.clothes.value,
        'label': 'Clothes',
        'icon': Icons.checkroom
      },
      {
        'value': DonationCategory.books.value,
        'label': 'Books',
        'icon': Icons.menu_book
      },
      {
        'value': DonationCategory.electronics.value,
        'label': 'Electronics',
        'icon': Icons.devices
      },
      {
        'value': DonationCategory.furniture.value,
        'label': 'Furniture',
        'icon': Icons.chair
      },
      {
        'value': DonationCategory.toys.value,
        'label': 'Toys',
        'icon': Icons.toys
      },
      {
        'value': DonationCategory.other.value,
        'label': 'Other',
        'icon': Icons.category
      },
    ];
  }

  /// Get category icon
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'medical':
        return Icons.medical_services;
      case 'education':
        return Icons.school;
      case 'food':
        return Icons.restaurant;
      case 'housing':
        return Icons.home;
      case 'emergency':
        return Icons.emergency;
      case 'clothes':
        return Icons.checkroom;
      case 'books':
        return Icons.menu_book;
      case 'electronics':
        return Icons.devices;
      case 'furniture':
        return Icons.chair;
      case 'toys':
        return Icons.toys;
      default:
        return Icons.category;
    }
  }

  /// Get category color
  static Color getCategoryColor(String category) {
    switch (category) {
      case 'medical':
        return const Color(0xFFEF4444); // Red
      case 'education':
        return const Color(0xFF3B82F6); // Blue
      case 'food':
        return const Color(0xFF10B981); // Green
      case 'housing':
        return const Color(0xFF8B5CF6); // Purple
      case 'emergency':
        return const Color(0xFFDC2626); // Dark Red
      case 'clothes':
        return const Color(0xFF06B6D4); // Cyan
      case 'books':
        return const Color(0xFF0EA5E9); // Sky Blue
      case 'electronics':
        return const Color(0xFFF59E0B); // Orange
      case 'furniture':
        return const Color(0xFF84CC16); // Lime
      case 'toys':
        return const Color(0xFFEC4899); // Pink
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  /// Get status color
  static Color getStatusColor(String status) {
    return Color(DonationConstants.statusColors[status] ?? 0xFF6B7280);
  }

  /// Get condition color
  static Color getConditionColor(String condition) {
    return Color(DonationConstants.conditionColors[condition] ?? 0xFF6B7280);
  }

  /// Get request status color
  static Color getRequestStatusColor(String status) {
    return Color(DonationConstants.requestStatusColors[status] ?? 0xFF6B7280);
  }
}
