/// Environment configuration for different build flavors
class EnvConfig {
  static const String development = 'development';
  static const String staging = 'staging';
  static const String production = 'production';

  static String get currentEnvironment {
    const env = String.fromEnvironment('ENV', defaultValue: development);
    return env;
  }

  static bool get isDevelopment => currentEnvironment == development;
  static bool get isStaging => currentEnvironment == staging;
  static bool get isProduction => currentEnvironment == production;

  // API Configuration
  static String get apiBaseUrl {
    switch (currentEnvironment) {
      case development:
        return 'http://localhost:3000/api';
      case staging:
        return 'https://staging-api.givingbridge.com/api';
      case production:
        return 'https://api.givingbridge.com/api';
      default:
        return 'http://localhost:3000/api';
    }
  }

  static String get socketUrl {
    switch (currentEnvironment) {
      case development:
        return 'http://localhost:3000';
      case staging:
        return 'https://staging-api.givingbridge.com';
      case production:
        return 'https://api.givingbridge.com';
      default:
        return 'http://localhost:3000';
    }
  }

  // Feature Flags
  static bool get enableAnalytics => isProduction || isStaging;
  static bool get enableCrashReporting => isProduction;
  static bool get enableDebugLogging => isDevelopment;
  static bool get enablePerformanceMonitoring => isProduction;
  static bool get enableRealTimeUpdates => true;
  static bool get enablePushNotifications => false; // Removed for MVP
  static bool get enableFileUpload => true;
  static bool get enableLocationServices => true;
  static bool get enableOfflineMode => true;

  // Cache Configuration
  static Duration get cacheTTL {
    switch (currentEnvironment) {
      case development:
        return const Duration(minutes: 1);
      case staging:
        return const Duration(minutes: 5);
      case production:
        return const Duration(minutes: 15);
      default:
        return const Duration(minutes: 5);
    }
  }

  // Request Timeouts
  static Duration get requestTimeout {
    switch (currentEnvironment) {
      case development:
        return const Duration(seconds: 30);
      case staging:
        return const Duration(seconds: 20);
      case production:
        return const Duration(seconds: 15);
      default:
        return const Duration(seconds: 20);
    }
  }

  // Retry Configuration
  static int get maxRetries {
    switch (currentEnvironment) {
      case development:
        return 1;
      case staging:
        return 2;
      case production:
        return 3;
      default:
        return 2;
    }
  }

  // Logging Configuration
  static String get logLevel {
    switch (currentEnvironment) {
      case development:
        return 'debug';
      case staging:
        return 'info';
      case production:
        return 'warning';
      default:
        return 'info';
    }
  }

  // Security Configuration
  static bool get enableSSL => isProduction || isStaging;
  static bool get enableCertificatePinning => isProduction;
  static bool get enableBiometricAuth => isProduction || isStaging;

  // Performance Configuration
  static bool get enableImageOptimization => isProduction || isStaging;
  static bool get enableCodeSplitting => isProduction || isStaging;
  static bool get enableLazyLoading => true;
  static bool get enableCaching => true;

  // Development Tools
  static bool get enableDevTools => isDevelopment;
  static bool get enableHotReload => isDevelopment;
  static bool get enableInspector => isDevelopment;
  static bool get enablePerformanceOverlay => isDevelopment;

  // Testing Configuration
  static bool get enableTestMode => isDevelopment;
  static bool get enableMockData => isDevelopment;
  static bool get enableTestUsers => isDevelopment;

  // Build Configuration
  static String get buildVersion {
    const version = String.fromEnvironment('VERSION', defaultValue: '1.0.0');
    return version;
  }

  static String get buildNumber {
    const buildNumber =
        String.fromEnvironment('BUILD_NUMBER', defaultValue: '1');
    return buildNumber;
  }

  static String get buildDate {
    const buildDate = String.fromEnvironment('BUILD_DATE', defaultValue: '');
    return buildDate;
  }

  // App Configuration
  static String get appName {
    switch (currentEnvironment) {
      case development:
        return 'GivingBridge Dev';
      case staging:
        return 'GivingBridge Staging';
      case production:
        return 'GivingBridge';
      default:
        return 'GivingBridge';
    }
  }

  static String get appVersion => '$buildVersion+$buildNumber';

  // Database Configuration
  static String get databaseName {
    switch (currentEnvironment) {
      case development:
        return 'givingbridge_dev';
      case staging:
        return 'givingbridge_staging';
      case production:
        return 'givingbridge';
      default:
        return 'givingbridge_dev';
    }
  }

  // File Upload Configuration
  static int get maxFileSize {
    switch (currentEnvironment) {
      case development:
        return 10 * 1024 * 1024; // 10MB
      case staging:
        return 5 * 1024 * 1024; // 5MB
      case production:
        return 5 * 1024 * 1024; // 5MB
      default:
        return 5 * 1024 * 1024; // 5MB
    }
  }

  // Rate Limiting
  static int get rateLimitRequests {
    switch (currentEnvironment) {
      case development:
        return 1000;
      case staging:
        return 500;
      case production:
        return 100;
      default:
        return 100;
    }
  }

  static Duration get rateLimitWindow {
    switch (currentEnvironment) {
      case development:
        return const Duration(minutes: 1);
      case staging:
        return const Duration(minutes: 5);
      case production:
        return const Duration(minutes: 15);
      default:
        return const Duration(minutes: 15);
    }
  }

  // Debug Information
  static Map<String, dynamic> get debugInfo => {
        'environment': currentEnvironment,
        'apiBaseUrl': apiBaseUrl,
        'socketUrl': socketUrl,
        'buildVersion': buildVersion,
        'buildNumber': buildNumber,
        'buildDate': buildDate,
        'enableAnalytics': enableAnalytics,
        'enableCrashReporting': enableCrashReporting,
        'enableDebugLogging': enableDebugLogging,
        'logLevel': logLevel,
        'cacheTTL': cacheTTL.inMinutes,
        'requestTimeout': requestTimeout.inSeconds,
        'maxRetries': maxRetries,
        'maxFileSize': maxFileSize,
        'rateLimitRequests': rateLimitRequests,
        'rateLimitWindow': rateLimitWindow.inMinutes,
      };
}
