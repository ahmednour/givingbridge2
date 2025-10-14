class ApiConfig {
  // Check if we're in web mode and use environment variable or default
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );

  static String get baseUrl => _baseUrl;

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
