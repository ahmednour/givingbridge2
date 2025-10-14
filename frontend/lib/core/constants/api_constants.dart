import 'package:flutter/foundation.dart';

/// API endpoint constants
class APIConstants {
  // Base URLs - will be overridden by environment config
  static const String _defaultBaseUrl = 'http://localhost:3000/api';
  static const String _defaultSocketUrl = 'http://localhost:3000';

  // Get base URL from environment or use default
  static String get baseUrl {
    if (kDebugMode) {
      // In debug mode, try to get from environment or use default
      return const String.fromEnvironment('API_BASE_URL',
          defaultValue: _defaultBaseUrl);
    }
    return _defaultBaseUrl;
  }

  // Get socket URL from environment or use default
  static String get socketUrl {
    if (kDebugMode) {
      // In debug mode, try to get from environment or use default
      return const String.fromEnvironment('SOCKET_URL',
          defaultValue: _defaultSocketUrl);
    }
    return _defaultSocketUrl;
  }

  // Authentication Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/me';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';

  // User Endpoints
  static const String users = '/users';
  static const String userById = '/users/{id}';
  static const String updateProfile = '/users/{id}';
  static const String deleteUser = '/users/{id}';
  static const String userStats = '/users/{id}/stats';

  // Donation Endpoints
  static const String donations = '/donations';
  static const String donationById = '/donations/{id}';
  static const String myDonations = '/donations/donor/my-donations';
  static const String donationStats = '/donations/admin/stats';
  static const String donationCategories = '/donations/categories';
  static const String donationConditions = '/donations/conditions';

  // Request Endpoints
  static const String requests = '/requests';
  static const String requestById = '/requests/{id}';
  static const String myRequests = '/requests/receiver/my-requests';
  static const String incomingRequests = '/requests/donor/incoming-requests';
  static const String updateRequestStatus = '/requests/{id}/status';
  static const String requestStats = '/requests/admin/stats';

  // Message Endpoints
  static const String messages = '/messages';
  static const String messageById = '/messages/{id}';
  static const String conversations = '/messages/conversations';
  static const String conversationMessages = '/messages/conversation/{userId}';
  static const String markMessageRead = '/messages/{id}/read';
  static const String markConversationRead =
      '/messages/conversation/{userId}/read';
  static const String unreadCount = '/messages/unread-count';

  // File Upload Endpoints
  static const String uploadImage = '/upload/image';
  static const String uploadAvatar = '/upload/avatar';
  static const String uploadDocument = '/upload/document';

  // Notification Endpoints
  static const String notifications = '/notifications';
  static const String notificationById = '/notifications/{id}';
  static const String markNotificationRead = '/notifications/{id}/read';
  static const String markAllNotificationsRead = '/notifications/read-all';
  static const String notificationSettings = '/notifications/settings';

  // Analytics Endpoints
  static const String analytics = '/analytics';
  static const String dashboardStats = '/analytics/dashboard';
  static const String donationAnalytics = '/analytics/donations';
  static const String userAnalytics = '/analytics/users';
  static const String requestAnalytics = '/analytics/requests';

  // Search Endpoints
  static const String searchDonations = '/search/donations';
  static const String searchUsers = '/search/users';
  static const String searchRequests = '/search/requests';

  // Location Endpoints
  static const String locations = '/locations';
  static const String nearbyDonations = '/locations/nearby-donations';
  static const String locationSuggestions = '/locations/suggestions';

  // Category Endpoints
  static const String categories = '/categories';
  static const String categoryById = '/categories/{id}';

  // Health Check
  static const String health = '/health';
  static const String status = '/status';

  // WebSocket Events
  static const String socketConnect = 'connect';
  static const String socketDisconnect = 'disconnect';
  static const String socketJoinRoom = 'join_room';
  static const String socketLeaveRoom = 'leave_room';
  static const String socketNewMessage = 'new_message';
  static const String socketMessageRead = 'message_read';
  static const String socketTyping = 'typing';
  static const String socketStopTyping = 'stop_typing';
  static const String socketNewNotification = 'new_notification';
  static const String socketRequestUpdate = 'request_update';
  static const String socketDonationUpdate = 'donation_update';

  // Query Parameters
  static const String pageParam = 'page';
  static const String limitParam = 'limit';
  static const String sortParam = 'sort';
  static const String orderParam = 'order';
  static const String searchParam = 'search';
  static const String categoryParam = 'category';
  static const String locationParam = 'location';
  static const String statusParam = 'status';
  static const String availableParam = 'available';
  static const String conditionParam = 'condition';

  // Default Values
  static const int defaultPage = 1;
  static const int defaultLimit = 20;
  static const int maxLimit = 100;
  static const String defaultSort = 'createdAt';
  static const String defaultOrder = 'desc';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Retry Configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  // File Upload Limits
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxDocumentSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx'];

  // Pagination
  static const int itemsPerPage = 20;
  static const int maxItemsPerPage = 100;

  // Cache Keys
  static const String cacheKeyUser = 'user';
  static const String cacheKeyDonations = 'donations';
  static const String cacheKeyRequests = 'requests';
  static const String cacheKeyMessages = 'messages';
  static const String cacheKeyNotifications = 'notifications';
  static const String cacheKeyCategories = 'categories';
  static const String cacheKeyLocations = 'locations';

  // Cache TTL (Time To Live)
  static const Duration cacheTTLShort = Duration(minutes: 5);
  static const Duration cacheTTLMedium = Duration(minutes: 15);
  static const Duration cacheTTLLong = Duration(hours: 1);
  static const Duration cacheTTLVeryLong = Duration(hours: 24);
}
