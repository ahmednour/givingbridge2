import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Performance monitoring and optimization service
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  final Map<String, DateTime> _startTimes = {};
  final Map<String, List<Duration>> _metrics = {};
  final List<PerformanceMetric> _performanceLog = [];
  
  Timer? _memoryMonitorTimer;
  bool _isMonitoring = false;

  /// Initialize performance monitoring
  void initialize() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _startMemoryMonitoring();
    
    if (kDebugMode) {
      developer.log('Performance monitoring initialized', name: 'PerformanceService');
    }
  }

  /// Dispose performance monitoring
  void dispose() {
    _memoryMonitorTimer?.cancel();
    _isMonitoring = false;
  }

  /// Start timing an operation
  void startTimer(String operationName) {
    _startTimes[operationName] = DateTime.now();
  }

  /// End timing an operation and record the duration
  Duration? endTimer(String operationName) {
    final startTime = _startTimes.remove(operationName);
    if (startTime == null) return null;

    final duration = DateTime.now().difference(startTime);
    _recordMetric(operationName, duration);
    
    if (kDebugMode) {
      developer.log(
        'Operation "$operationName" took ${duration.inMilliseconds}ms',
        name: 'PerformanceService',
      );
    }
    
    return duration;
  }

  /// Record a custom metric
  void recordMetric(String name, Duration duration) {
    _recordMetric(name, duration);
  }

  /// Record frame rendering time
  void recordFrameTime(Duration frameTime) {
    _recordMetric('frame_render', frameTime);
    
    // Log slow frames (>16.67ms for 60fps)
    if (frameTime.inMilliseconds > 16) {
      _logSlowFrame(frameTime);
    }
  }

  /// Record network request time
  void recordNetworkRequest(String endpoint, Duration duration, bool success) {
    _recordMetric('network_$endpoint', duration);
    
    final metric = PerformanceMetric(
      name: 'network_request',
      value: duration.inMilliseconds.toDouble(),
      timestamp: DateTime.now(),
      metadata: {
        'endpoint': endpoint,
        'success': success,
        'duration_ms': duration.inMilliseconds,
      },
    );
    
    _performanceLog.add(metric);
    
    if (kDebugMode) {
      developer.log(
        'Network request to $endpoint: ${duration.inMilliseconds}ms (${success ? 'success' : 'failed'})',
        name: 'PerformanceService',
      );
    }
  }

  /// Record image loading time
  void recordImageLoad(String imageUrl, Duration duration, bool fromCache) {
    _recordMetric('image_load', duration);
    
    final metric = PerformanceMetric(
      name: 'image_load',
      value: duration.inMilliseconds.toDouble(),
      timestamp: DateTime.now(),
      metadata: {
        'url': imageUrl,
        'from_cache': fromCache,
        'duration_ms': duration.inMilliseconds,
      },
    );
    
    _performanceLog.add(metric);
  }

  /// Record app startup time
  void recordAppStartup(Duration startupTime) {
    final metric = PerformanceMetric(
      name: 'app_startup',
      value: startupTime.inMilliseconds.toDouble(),
      timestamp: DateTime.now(),
      metadata: {
        'duration_ms': startupTime.inMilliseconds,
      },
    );
    
    _performanceLog.add(metric);
    
    if (kDebugMode) {
      developer.log(
        'App startup took ${startupTime.inMilliseconds}ms',
        name: 'PerformanceService',
      );
    }
  }

  /// Get average duration for an operation
  Duration? getAverageDuration(String operationName) {
    final durations = _metrics[operationName];
    if (durations == null || durations.isEmpty) return null;

    final totalMs = durations.fold<int>(0, (sum, duration) => sum + duration.inMilliseconds);
    return Duration(milliseconds: (totalMs / durations.length).round());
  }

  /// Get performance statistics
  Map<String, dynamic> getPerformanceStats() {
    final stats = <String, dynamic>{};
    
    for (final entry in _metrics.entries) {
      final durations = entry.value;
      if (durations.isNotEmpty) {
        final totalMs = durations.fold<int>(0, (sum, duration) => sum + duration.inMilliseconds);
        stats[entry.key] = {
          'count': durations.length,
          'average_ms': (totalMs / durations.length).round(),
          'min_ms': durations.map((d) => d.inMilliseconds).reduce((a, b) => a < b ? a : b),
          'max_ms': durations.map((d) => d.inMilliseconds).reduce((a, b) => a > b ? a : b),
        };
      }
    }
    
    return stats;
  }

  /// Get recent performance metrics
  List<PerformanceMetric> getRecentMetrics({int limit = 100}) {
    final sortedMetrics = List<PerformanceMetric>.from(_performanceLog)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return sortedMetrics.take(limit).toList();
  }

  /// Clear all performance data
  void clearMetrics() {
    _metrics.clear();
    _performanceLog.clear();
    _startTimes.clear();
  }

  /// Check if performance is degraded
  bool isPerformanceDegraded() {
    final frameMetrics = _metrics['frame_render'];
    if (frameMetrics != null && frameMetrics.isNotEmpty) {
      final recentFrames = frameMetrics.length > 10 
          ? frameMetrics.sublist(frameMetrics.length - 10)
          : frameMetrics;
      
      final averageFrameTime = recentFrames.fold<int>(0, (sum, duration) => 
          sum + duration.inMilliseconds) / recentFrames.length;
      
      // Consider performance degraded if average frame time > 20ms
      return averageFrameTime > 20;
    }
    
    return false;
  }

  /// Get memory usage information
  Future<Map<String, dynamic>> getMemoryInfo() async {
    try {
      // This would require platform-specific implementation
      // For now, return mock data
      return {
        'used_memory_mb': 0,
        'available_memory_mb': 0,
        'total_memory_mb': 0,
        'memory_pressure': 'normal', // low, normal, high, critical
      };
    } catch (e) {
      if (kDebugMode) {
        developer.log('Failed to get memory info: $e', name: 'PerformanceService');
      }
      return {};
    }
  }

  /// Optimize performance based on current conditions
  void optimizePerformance() {
    if (isPerformanceDegraded()) {
      // Implement performance optimizations
      _reduceAnimations();
      _clearCaches();
      _reduceImageQuality();
      
      if (kDebugMode) {
        developer.log('Performance optimization applied', name: 'PerformanceService');
      }
    }
  }

  /// Private methods
  void _recordMetric(String name, Duration duration) {
    _metrics.putIfAbsent(name, () => <Duration>[]).add(duration);
    
    // Keep only last 100 measurements per metric
    if (_metrics[name]!.length > 100) {
      _metrics[name]!.removeAt(0);
    }
  }

  void _logSlowFrame(Duration frameTime) {
    final metric = PerformanceMetric(
      name: 'slow_frame',
      value: frameTime.inMilliseconds.toDouble(),
      timestamp: DateTime.now(),
      metadata: {
        'duration_ms': frameTime.inMilliseconds,
        'threshold_exceeded': true,
      },
    );
    
    _performanceLog.add(metric);
    
    if (kDebugMode) {
      developer.log(
        'Slow frame detected: ${frameTime.inMilliseconds}ms',
        name: 'PerformanceService',
      );
    }
  }

  void _startMemoryMonitoring() {
    _memoryMonitorTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) async {
        final memoryInfo = await getMemoryInfo();
        
        final metric = PerformanceMetric(
          name: 'memory_usage',
          value: (memoryInfo['used_memory_mb'] ?? 0).toDouble(),
          timestamp: DateTime.now(),
          metadata: memoryInfo,
        );
        
        _performanceLog.add(metric);
      },
    );
  }

  void _reduceAnimations() {
    // This would be implemented by reducing animation durations
    // or disabling non-essential animations
  }

  void _clearCaches() {
    // Clear image caches and other memory-intensive caches
    // This would integrate with CachedNetworkImage and other caching systems
  }

  void _reduceImageQuality() {
    // Reduce image quality settings for better performance
    // This would be implemented by adjusting image loading parameters
  }
}

/// Performance metric data class
class PerformanceMetric {
  final String name;
  final double value;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  PerformanceMetric({
    required this.name,
    required this.value,
    required this.timestamp,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// Performance monitoring widget
class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final String? operationName;

  const PerformanceMonitor({
    Key? key,
    required this.child,
    this.operationName,
  }) : super(key: key);

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  final PerformanceService _performanceService = PerformanceService();
  late String _operationName;

  @override
  void initState() {
    super.initState();
    _operationName = widget.operationName ?? 'widget_${widget.runtimeType}';
    _performanceService.startTimer(_operationName);
  }

  @override
  void dispose() {
    _performanceService.endTimer(_operationName);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}