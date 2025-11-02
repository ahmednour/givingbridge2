class ApiConfig {
  // Dynamic base URL based on platform
  static String get baseUrl {
    // IMPORTANT: When running Flutter outside Docker, use your computer's IP
    // When running inside Docker, use host.docker.internal
    
    // Your computer's IP on the network
    const String host = '192.168.100.7'; // Your computer's IP
    
    // Alternative options:
    // const String host = '10.0.2.2'; // Android Emulator (only if backend is on localhost)
    // const String host = 'localhost'; // iOS Simulator or Web
    // const String host = 'host.docker.internal'; // If Flutter runs in Docker
    
    return 'http://$host:3000/api';
  }

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
