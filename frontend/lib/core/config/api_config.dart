class ApiConfig {
  // For now, use a hardcoded URL to test if the issue is with the JS interop
  static String get baseUrl => 'http://localhost:3000/api';

  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String profileEndpoint = '/auth/me';

  // Users endpoints
  static const String usersEndpoint = '/users';

  // Donation endpoints
  static const String donationsEndpoint = '/donations';

  // Request endpoints
  static const String requestsEndpoint = '/requests';

  // Message endpoints
  static const String messagesEndpoint = '/messages';
}
