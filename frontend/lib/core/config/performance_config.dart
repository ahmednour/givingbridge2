import 'package:flutter/foundation.dart';

/// Performance configuration for the application
class PerformanceConfig {
  // Image optimization settings
  static const int maxImageCacheSize = 100; // MB
  static const int maxImageCacheCount = 1000;
  static const Duration imageCacheDuration = Duration(days: 7);
  
  // Network settings
  static const Duration networkTimeout = Duration(seconds: 30);
  static const int maxConcurrentRequests = 6;
  static const Duration requestRetryDelay = Duration(seconds: 2);
  
  // Animation settings
  static Duration get animationDuration {
    return kDebugMode 
        ? const Duration(milliseconds: 300)
        : const Duration(milliseconds: 200);
  }
  
  // Memory management
  static const int maxListItemsInMemory = 500;
  static const Duration memoryCleanupInterval = Duration(minutes: 5);
  
  // Performance monitoring
  static const bool enablePerformanceMonitoring = kDebugMode;
  static const Duration performanceLogInterval = Duration(seconds: 30);
  
  // Bundle optimization
  static const bool enableCodeSplitting = true;
  static const bool enableTreeShaking = true;
  static const bool enableMinification = !kDebugMode;
  
  // Image quality settings based on device performance
  static int getImageQuality() {
    // In a real app, you'd check device capabilities
    return kDebugMode ? 90 : 85;
  }
  
  // Get optimal image dimensions based on screen
  static Map<String, int> getImageDimensions(double screenWidth) {
    if (screenWidth < 480) {
      return {'width': 400, 'height': 300};
    } else if (screenWidth < 768) {
      return {'width': 600, 'height': 450};
    } else if (screenWidth < 1024) {
      return {'width': 800, 'height': 600};
    } else {
      return {'width': 1200, 'height': 900};
    }
  }
}