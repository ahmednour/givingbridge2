import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Retry configuration
class RetryConfig {
  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;
  final double backoffMultiplier;
  final Duration? timeout;
  final bool Function(dynamic error)? shouldRetry;

  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffMultiplier = 2.0,
    this.timeout,
    this.shouldRetry,
  });

  /// Default retry config for network operations
  static const RetryConfig network = RetryConfig(
    maxAttempts: 3,
    initialDelay: Duration(seconds: 1),
    maxDelay: Duration(seconds: 10),
    backoffMultiplier: 2.0,
    timeout: Duration(seconds: 30),
  );

  /// Default retry config for critical operations
  static const RetryConfig critical = RetryConfig(
    maxAttempts: 5,
    initialDelay: Duration(milliseconds: 500),
    maxDelay: Duration(seconds: 30),
    backoffMultiplier: 1.5,
    timeout: Duration(minutes: 2),
  );

  /// Default retry config for quick operations
  static const RetryConfig quick = RetryConfig(
    maxAttempts: 2,
    initialDelay: Duration(milliseconds: 200),
    maxDelay: Duration(seconds: 2),
    backoffMultiplier: 2.0,
    timeout: Duration(seconds: 10),
  );
}

/// Retry result
class RetryResult<T> {
  final T? data;
  final dynamic error;
  final int attempts;
  final bool success;
  final Duration totalDuration;

  RetryResult({
    this.data,
    this.error,
    required this.attempts,
    required this.success,
    required this.totalDuration,
  });

  bool get isSuccess => success && error == null;
  bool get isFailure => !success;
}

/// Retry service for handling retry logic
class RetryService {
  static final RetryService _instance = RetryService._internal();
  factory RetryService() => _instance;
  RetryService._internal();

  /// Execute operation with retry logic
  static Future<RetryResult<T>> executeWithRetry<T>(
    Future<T> Function() operation, {
    RetryConfig config = RetryConfig.network,
    String? operationName,
  }) async {
    final stopwatch = Stopwatch()..start();
    int attempts = 0;
    Duration delay = config.initialDelay;

    while (attempts < config.maxAttempts) {
      attempts++;

      try {
        if (kDebugMode && operationName != null) {
          debugPrint(
              'RetryService: Attempting $operationName (attempt $attempts/${config.maxAttempts})');
        }

        final result = await operation().timeout(
          config.timeout ?? const Duration(seconds: 30),
        );

        stopwatch.stop();

        if (kDebugMode && operationName != null) {
          debugPrint(
              'RetryService: $operationName succeeded after $attempts attempts');
        }

        return RetryResult<T>(
          data: result,
          attempts: attempts,
          success: true,
          totalDuration: stopwatch.elapsed,
        );
      } catch (error) {
        if (kDebugMode && operationName != null) {
          debugPrint(
              'RetryService: $operationName failed on attempt $attempts: $error');
        }

        // Check if we should retry this error
        if (config.shouldRetry != null && !config.shouldRetry!(error)) {
          stopwatch.stop();
          return RetryResult<T>(
            error: error,
            attempts: attempts,
            success: false,
            totalDuration: stopwatch.elapsed,
          );
        }

        // If this was the last attempt, return failure
        if (attempts >= config.maxAttempts) {
          stopwatch.stop();
          return RetryResult<T>(
            error: error,
            attempts: attempts,
            success: false,
            totalDuration: stopwatch.elapsed,
          );
        }

        // Wait before next attempt
        await Future.delayed(delay);

        // Calculate next delay with exponential backoff
        delay = Duration(
          milliseconds: min(
            (delay.inMilliseconds * config.backoffMultiplier).round(),
            config.maxDelay.inMilliseconds,
          ),
        );
      }
    }

    stopwatch.stop();
    return RetryResult<T>(
      error: 'Max attempts exceeded',
      attempts: attempts,
      success: false,
      totalDuration: stopwatch.elapsed,
    );
  }

  /// Execute operation with retry and callback
  static Future<T?> executeWithRetryAndCallback<T>(
    Future<T> Function() operation, {
    RetryConfig config = RetryConfig.network,
    String? operationName,
    void Function(int attempt, dynamic error)? onRetry,
    void Function(T result)? onSuccess,
    void Function(dynamic error)? onFailure,
  }) async {
    final result = await executeWithRetry<T>(
      operation,
      config: config,
      operationName: operationName,
    );

    if (result.isSuccess) {
      onSuccess?.call(result.data as T);
      return result.data;
    } else {
      onFailure?.call(result.error);
      return null;
    }
  }

  /// Execute multiple operations with retry
  static Future<List<RetryResult<T>>> executeMultipleWithRetry<T>(
    List<Future<T> Function()> operations, {
    RetryConfig config = RetryConfig.network,
    String? operationName,
    bool stopOnFirstFailure = false,
  }) async {
    final results = <RetryResult<T>>[];

    for (int i = 0; i < operations.length; i++) {
      final result = await executeWithRetry<T>(
        operations[i],
        config: config,
        operationName: operationName != null ? '$operationName-$i' : null,
      );

      results.add(result);

      if (stopOnFirstFailure && result.isFailure) {
        break;
      }
    }

    return results;
  }

  /// Execute operation with circuit breaker pattern
  static Future<T?> executeWithCircuitBreaker<T>(
    Future<T> Function() operation, {
    required String circuitName,
    int failureThreshold = 5,
    Duration timeoutDuration = const Duration(minutes: 1),
    RetryConfig config = RetryConfig.network,
  }) async {
    // This would implement circuit breaker pattern
    // For now, we'll use simple retry
    return await executeWithRetryAndCallback<T>(
      operation,
      config: config,
      operationName: circuitName,
    );
  }
}

/// Retry mixin for classes that need retry functionality
mixin RetryMixin {
  /// Execute operation with retry
  Future<T?> executeWithRetry<T>(
    Future<T> Function() operation, {
    RetryConfig config = RetryConfig.network,
    String? operationName,
  }) async {
    final result = await RetryService.executeWithRetry<T>(
      operation,
      config: config,
      operationName: operationName,
    );

    return result.isSuccess ? result.data : null;
  }

  /// Execute operation with retry and error handling
  Future<T?> executeWithRetryAndErrorHandling<T>(
    Future<T> Function() operation, {
    RetryConfig config = RetryConfig.network,
    String? operationName,
    void Function(dynamic error)? onError,
  }) async {
    try {
      return await executeWithRetry<T>(
        operation,
        config: config,
        operationName: operationName,
      );
    } catch (error) {
      onError?.call(error);
      return null;
    }
  }
}

/// Retry widget for UI operations
class RetryWidget extends StatefulWidget {
  final Future<void> Function() operation;
  final Widget Function(BuildContext context, bool isLoading, dynamic error)
      builder;
  final RetryConfig config;
  final String? operationName;

  const RetryWidget({
    Key? key,
    required this.operation,
    required this.builder,
    this.config = RetryConfig.network,
    this.operationName,
  }) : super(key: key);

  @override
  State<RetryWidget> createState() => _RetryWidgetState();
}

class _RetryWidgetState extends State<RetryWidget> {
  bool _isLoading = false;
  dynamic _error;

  @override
  void initState() {
    super.initState();
    _executeOperation();
  }

  Future<void> _executeOperation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await RetryService.executeWithRetry<void>(
      widget.operation,
      config: widget.config,
      operationName: widget.operationName,
    );

    setState(() {
      _isLoading = false;
      _error = result.isFailure ? result.error : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _isLoading, _error);
  }
}

/// Retry button widget
class RetryButton extends StatelessWidget {
  final Future<void> Function() onRetry;
  final String? text;
  final IconData? icon;
  final RetryConfig config;

  const RetryButton({
    Key? key,
    required this.onRetry,
    this.text,
    this.icon,
    this.config = RetryConfig.network,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        await RetryService.executeWithRetry<void>(
          onRetry,
          config: config,
          operationName: 'RetryButton',
        );
      },
      icon: Icon(icon ?? Icons.refresh),
      label: Text(text ?? 'Retry'),
    );
  }
}
