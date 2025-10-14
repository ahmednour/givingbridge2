import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

/// Custom exception classes for different types of errors
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.details,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: $message';
}

class NetworkException extends AppException {
  const NetworkException({
    required String message,
    String? code,
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );
}

class AuthenticationException extends AppException {
  const AuthenticationException({
    required String message,
    String? code,
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );
}

class ValidationException extends AppException {
  const ValidationException({
    required String message,
    String? code,
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );
}

class ServerException extends AppException {
  const ServerException({
    required String message,
    String? code,
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );
}

class CacheException extends AppException {
  const CacheException({
    required String message,
    String? code,
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );
}

class OfflineException extends AppException {
  const OfflineException({
    required String message,
    String? code,
    dynamic details,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          details: details,
          stackTrace: stackTrace,
        );
}

/// Error handling service for centralized error management
class ErrorHandler {
  static const String _logTag = 'ErrorHandler';

  /// Handle different types of exceptions and convert them to AppException
  static AppException handleException(dynamic error, StackTrace? stackTrace) {
    if (error is AppException) {
      return error;
    }

    if (error is SocketException) {
      return NetworkException(
        message: 'No internet connection. Please check your network settings.',
        code: 'NO_INTERNET',
        details: error.toString(),
        stackTrace: stackTrace,
      );
    }

    if (error is HttpException) {
      return NetworkException(
        message: 'Network error occurred. Please try again.',
        code: 'HTTP_ERROR',
        details: error.toString(),
        stackTrace: stackTrace,
      );
    }

    if (error is FormatException) {
      return ValidationException(
        message: 'Invalid data format. Please try again.',
        code: 'FORMAT_ERROR',
        details: error.toString(),
        stackTrace: stackTrace,
      );
    }

    if (error is PlatformException) {
      return ServerException(
        message: 'Platform error: ${error.message ?? 'Unknown error'}',
        code: error.code,
        details: error.toString(),
        stackTrace: stackTrace,
      );
    }

    // Generic exception
    return AppException(
      message: 'An unexpected error occurred. Please try again.',
      code: 'UNKNOWN_ERROR',
      details: error.toString(),
      stackTrace: stackTrace,
    );
  }

  /// Get user-friendly error message
  static String getUserFriendlyMessage(AppException exception) {
    switch (exception.runtimeType) {
      case NetworkException:
        return 'Network connection error. Please check your internet connection and try again.';
      case AuthenticationException:
        return 'Authentication failed. Please log in again.';
      case ValidationException:
        return exception.message;
      case ServerException:
        return 'Server error. Please try again later.';
      case CacheException:
        return 'Data loading error. Please refresh the page.';
      case OfflineException:
        return 'You are offline. Some features may not be available.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Get error icon based on exception type
  static IconData getErrorIcon(AppException exception) {
    switch (exception.runtimeType) {
      case NetworkException:
        return Icons.wifi_off;
      case AuthenticationException:
        return Icons.lock_outline;
      case ValidationException:
        return Icons.warning_outlined;
      case ServerException:
        return Icons.error_outline;
      case CacheException:
        return Icons.cached_outlined;
      case OfflineException:
        return Icons.cloud_off_outlined;
      default:
        return Icons.error_outline;
    }
  }

  /// Get error color based on exception type
  static Color getErrorColor(AppException exception) {
    switch (exception.runtimeType) {
      case NetworkException:
        return Colors.orange;
      case AuthenticationException:
        return Colors.red;
      case ValidationException:
        return Colors.amber;
      case ServerException:
        return Colors.red;
      case CacheException:
        return Colors.blue;
      case OfflineException:
        return Colors.grey;
      default:
        return Colors.red;
    }
  }

  /// Log error for debugging
  static void logError(AppException exception) {
    debugPrint('[$_logTag] ${exception.runtimeType}: ${exception.message}');
    if (exception.details != null) {
      debugPrint('[$_logTag] Details: ${exception.details}');
    }
    if (exception.stackTrace != null) {
      debugPrint('[$_logTag] StackTrace: ${exception.stackTrace}');
    }
  }

  /// Show error snackbar
  static void showErrorSnackbar(BuildContext context, AppException exception) {
    final message = getUserFriendlyMessage(exception);
    final icon = getErrorIcon(exception);
    final color = getErrorColor(exception);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show error dialog
  static void showErrorDialog(BuildContext context, AppException exception) {
    final message = getUserFriendlyMessage(exception);
    final icon = getErrorIcon(exception);
    final color = getErrorColor(exception);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(icon, color: color, size: 48),
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show retry dialog
  static Future<bool> showRetryDialog(
      BuildContext context, AppException exception) async {
    final message = getUserFriendlyMessage(exception);
    final icon = getErrorIcon(exception);
    final color = getErrorColor(exception);

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            icon: Icon(icon, color: color, size: 48),
            title: Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Retry'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

/// Error boundary widget for catching and handling errors
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext context, AppException error)? errorBuilder;
  final VoidCallback? onError;

  const ErrorBoundary({
    Key? key,
    required this.child,
    this.errorBuilder,
    this.onError,
  }) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  AppException? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, _error!);
      }

      return _DefaultErrorWidget(
        error: _error!,
        onRetry: () {
          setState(() {
            _error = null;
          });
        },
      );
    }

    return widget.child;
  }
}

/// Default error widget
class _DefaultErrorWidget extends StatelessWidget {
  final AppException error;
  final VoidCallback? onRetry;

  const _DefaultErrorWidget({
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final message = ErrorHandler.getUserFriendlyMessage(error);
    final icon = ErrorHandler.getErrorIcon(error);
    final color = ErrorHandler.getErrorColor(error);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 64),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error handling mixin for widgets
mixin ErrorHandlingMixin<T extends StatefulWidget> on State<T> {
  void handleError(dynamic error, StackTrace? stackTrace) {
    final appException = ErrorHandler.handleException(error, stackTrace);
    ErrorHandler.logError(appException);
    ErrorHandler.showErrorSnackbar(context, appException);
  }

  Future<void> handleAsyncError(Future<void> Function() operation) async {
    try {
      await operation();
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  Future<T?> handleAsyncOperation<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return null;
    }
  }
}

/// Global error handler for uncaught exceptions
class GlobalErrorHandler {
  static void initialize() {
    FlutterError.onError = (FlutterErrorDetails details) {
      ErrorHandler.logError(
        AppException(
          message: details.exception.toString(),
          code: 'FLUTTER_ERROR',
          details: details.context?.toString(),
          stackTrace: details.stack,
        ),
      );
    };
  }
}
