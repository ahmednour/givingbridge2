import 'package:flutter/material.dart';

/// Application constants to eliminate magic numbers and strings
class AppConstants {
  // User roles
  static const String donorRole = 'donor';
  static const String receiverRole = 'receiver';
  static const String adminRole = 'admin';

  // Donation categories
  static const String foodCategory = 'food';
  static const String clothesCategory = 'clothes';
  static const String booksCategory = 'books';
  static const String electronicsCategory = 'electronics';
  static const String otherCategory = 'other';

  // Donation conditions
  static const String newCondition = 'new';
  static const String likeNewCondition = 'like-new';
  static const String goodCondition = 'good';
  static const String fairCondition = 'fair';

  // Donation statuses
  static const String availableStatus = 'available';
  static const String pendingStatus = 'pending';
  static const String completedStatus = 'completed';
  static const String cancelledStatus = 'cancelled';

  // Request statuses
  static const String requestPendingStatus = 'pending';
  static const String requestApprovedStatus = 'approved';
  static const String requestDeclinedStatus = 'declined';
  static const String requestCompletedStatus = 'completed';
  static const String requestCancelledStatus = 'cancelled';

  // UI Constants
  static const double sidebarWidth = 280.0;
  static const double imageHeight = 200.0;
  static const double avatarRadius = 20.0;
  static const double iconSize = 24.0;
  static const double smallIconSize = 16.0;
  static const double largeIconSize = 30.0;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // Border radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;

  // Validation limits
  static const int passwordMinLength = 6;
  static const int nameMinLength = 2;
  static const int titleMinLength = 3;
  static const int descriptionMinLength = 10;
  static const int locationMinLength = 2;
  static const int messageMaxLength = 500;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // API timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration socketTimeout = Duration(seconds: 10);

  // Error messages
  static const String networkError =
      'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String validationError =
      'Please check your input and try again.';
  static const String authenticationError =
      'Authentication failed. Please login again.';
  static const String permissionError =
      'You do not have permission to perform this action.';

  // Success messages
  static const String donationCreatedSuccess = 'Donation created successfully!';
  static const String donationUpdatedSuccess = 'Donation updated successfully!';
  static const String donationDeletedSuccess = 'Donation deleted successfully!';
  static const String requestSentSuccess = 'Request sent successfully!';
  static const String requestUpdatedSuccess = 'Request updated successfully!';
  static const String messageSentSuccess = 'Message sent successfully!';
  static const String profileUpdatedSuccess = 'Profile updated successfully!';

  // Empty state messages
  static const String noDonationsFound = 'No donations found';
  static const String noRequestsFound = 'No requests found';
  static const String noMessagesFound = 'No messages found';
  static const String noUsersFound = 'No users found';

  // Category display names
  static const Map<String, String> categoryDisplayNames = {
    foodCategory: 'Food',
    clothesCategory: 'Clothes',
    booksCategory: 'Books',
    electronicsCategory: 'Electronics',
    otherCategory: 'Other',
  };

  // Condition display names
  static const Map<String, String> conditionDisplayNames = {
    newCondition: 'New',
    likeNewCondition: 'Like New',
    goodCondition: 'Good',
    fairCondition: 'Fair',
  };

  // Status display names
  static const Map<String, String> statusDisplayNames = {
    availableStatus: 'Available',
    pendingStatus: 'Pending',
    completedStatus: 'Completed',
    cancelledStatus: 'Cancelled',
  };

  // Request status display names
  static const Map<String, String> requestStatusDisplayNames = {
    requestPendingStatus: 'Pending',
    requestApprovedStatus: 'Approved',
    requestDeclinedStatus: 'Declined',
    requestCompletedStatus: 'Completed',
    requestCancelledStatus: 'Cancelled',
  };

  // Category icons
  static const Map<String, IconData> categoryIcons = {
    foodCategory: Icons.restaurant,
    clothesCategory: Icons.checkroom,
    booksCategory: Icons.menu_book,
    electronicsCategory: Icons.devices,
    otherCategory: Icons.category,
  };

  // Status colors
  static const Map<String, Color> statusColors = {
    availableStatus: Colors.green,
    pendingStatus: Colors.orange,
    completedStatus: Colors.blue,
    cancelledStatus: Colors.grey,
  };

  // Request status colors
  static const Map<String, Color> requestStatusColors = {
    requestPendingStatus: Colors.orange,
    requestApprovedStatus: Colors.green,
    requestDeclinedStatus: Colors.red,
    requestCompletedStatus: Colors.blue,
    requestCancelledStatus: Colors.grey,
  };

  // Condition colors
  static const Map<String, Color> conditionColors = {
    newCondition: Colors.green,
    likeNewCondition: Colors.lightGreen,
    goodCondition: Colors.orange,
    fairCondition: Colors.red,
  };

  // Role colors
  static const Map<String, Color> roleColors = {
    donorRole: Colors.blue,
    receiverRole: Colors.purple,
    adminRole: Colors.amber,
  };

  // Role icons
  static const Map<String, IconData> roleIcons = {
    donorRole: Icons.volunteer_activism,
    receiverRole: Icons.person_outline,
    adminRole: Icons.admin_panel_settings,
  };

  // Helper methods
  static String getCategoryDisplayName(String category) {
    return categoryDisplayNames[category] ?? category;
  }

  static String getConditionDisplayName(String condition) {
    return conditionDisplayNames[condition] ?? condition;
  }

  static String getStatusDisplayName(String status) {
    return statusDisplayNames[status] ?? status;
  }

  static String getRequestStatusDisplayName(String status) {
    return requestStatusDisplayNames[status] ?? status;
  }

  static IconData getCategoryIcon(String category) {
    return categoryIcons[category] ?? Icons.category;
  }

  static Color getStatusColor(String status) {
    return statusColors[status] ?? Colors.grey;
  }

  static Color getRequestStatusColor(String status) {
    return requestStatusColors[status] ?? Colors.grey;
  }

  static Color getConditionColor(String condition) {
    return conditionColors[condition] ?? Colors.grey;
  }

  static Color getRoleColor(String role) {
    return roleColors[role] ?? Colors.grey;
  }

  static IconData getRoleIcon(String role) {
    return roleIcons[role] ?? Icons.person;
  }

  // Validation helpers
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= passwordMinLength;
  }

  static bool isValidName(String name) {
    return name.trim().length >= nameMinLength;
  }

  static bool isValidTitle(String title) {
    return title.trim().length >= titleMinLength;
  }

  static bool isValidDescription(String description) {
    return description.trim().length >= descriptionMinLength;
  }

  static bool isValidLocation(String location) {
    return location.trim().length >= locationMinLength;
  }

  static bool isValidMessage(String message) {
    return message.trim().length <= messageMaxLength;
  }
}
