import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';
import '../../services/error_handler.dart';
import 'gb_button.dart';

/// Collection of reusable error widgets with retry mechanisms
///
/// Usage:
/// ```dart
/// if (hasError) {
///   return GBErrorWidget(
///     error: error,
///     onRetry: () => loadData(),
///   );
/// }
/// ```

/// Standard error widget with retry button
class GBErrorWidget extends StatelessWidget {
  final AppException? error;
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final String? retryButtonText;
  final IconData? icon;
  final bool showDetails;

  const GBErrorWidget({
    Key? key,
    this.error,
    this.title,
    this.message,
    this.onRetry,
    this.retryButtonText,
    this.icon,
    this.showDetails = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final errorIcon = icon ?? _getIcon();
    final errorColor = _getColor();
    final errorTitle = title ?? _getTitle();
    final errorMessage = message ?? _getMessage();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error Icon
            Container(
              padding: const EdgeInsets.all(DesignSystem.spaceL),
              decoration: BoxDecoration(
                color: errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                errorIcon,
                size: 64,
                color: errorColor,
              ),
            ),
            const SizedBox(height: DesignSystem.spaceL),

            // Error Title
            Text(
              errorTitle,
              style: DesignSystem.displaySmall(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignSystem.spaceM),

            // Error Message
            Text(
              errorMessage,
              style: DesignSystem.bodyMedium(context).copyWith(
                color:
                    isDark ? DesignSystem.neutral400 : DesignSystem.neutral600,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),

            // Error Details (Debug)
            if (showDetails && error != null) ...[
              const SizedBox(height: DesignSystem.spaceM),
              Container(
                padding: const EdgeInsets.all(DesignSystem.spaceM),
                decoration: BoxDecoration(
                  color: isDark
                      ? DesignSystem.neutral800
                      : DesignSystem.neutral100,
                  borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                ),
                child: Text(
                  'Code: ${error?.code}\nDetails: ${error?.details}',
                  style: DesignSystem.bodySmall(context).copyWith(
                    fontFamily: 'monospace',
                    color: DesignSystem.neutral500,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            // Retry Button
            if (onRetry != null) ...[
              const SizedBox(height: DesignSystem.spaceXL),
              GBButton(
                text: retryButtonText ?? 'Try Again',
                variant: GBButtonVariant.primary,
                onPressed: onRetry,
                leftIcon: const Icon(Icons.refresh),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    if (error != null) {
      return ErrorHandler.getErrorIcon(error!);
    }
    return Icons.error_outline_rounded;
  }

  Color _getColor() {
    if (error != null) {
      return ErrorHandler.getErrorColor(error!);
    }
    return DesignSystem.error;
  }

  String _getTitle() {
    if (error is NetworkException) return 'Connection Error';
    if (error is AuthenticationException) return 'Authentication Failed';
    if (error is ValidationException) return 'Invalid Input';
    if (error is ServerException) return 'Server Error';
    if (error is OfflineException) return 'Offline Mode';
    return 'Something Went Wrong';
  }

  String _getMessage() {
    if (error != null) {
      return ErrorHandler.getUserFriendlyMessage(error!);
    }
    return 'An unexpected error occurred. Please try again later.';
  }
}

/// Inline error widget (for smaller spaces)
class GBInlineError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final Color? color;

  const GBInlineError({
    Key? key,
    required this.message,
    this.onRetry,
    this.icon,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final errorColor = color ?? DesignSystem.error;

    return Container(
      padding: const EdgeInsets.all(DesignSystem.spaceM),
      decoration: BoxDecoration(
        color: errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignSystem.radiusS),
        border: Border.all(
          color: errorColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.error_outline,
            color: errorColor,
            size: 20,
          ),
          const SizedBox(width: DesignSystem.spaceM),
          Expanded(
            child: Text(
              message,
              style: DesignSystem.bodyMedium(context).copyWith(
                color:
                    isDark ? DesignSystem.neutral200 : DesignSystem.neutral900,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: DesignSystem.spaceM),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Network error widget with specific messaging
class GBNetworkError extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;

  const GBNetworkError({
    Key? key,
    this.onRetry,
    this.customMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GBErrorWidget(
      icon: Icons.wifi_off_rounded,
      title: 'No Internet Connection',
      message: customMessage ??
          'Please check your internet connection and try again.',
      onRetry: onRetry,
      retryButtonText: 'Retry',
      error: const NetworkException(
        message: 'No internet connection',
        code: 'NO_INTERNET',
      ),
    );
  }
}

/// Server error widget
class GBServerError extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;

  const GBServerError({
    Key? key,
    this.onRetry,
    this.customMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GBErrorWidget(
      icon: Icons.cloud_off_outlined,
      title: 'Server Unavailable',
      message: customMessage ??
          'Our servers are currently unavailable. Please try again in a moment.',
      onRetry: onRetry,
      retryButtonText: 'Try Again',
      error: const ServerException(
        message: 'Server error',
        code: 'SERVER_ERROR',
      ),
    );
  }
}

/// Timeout error widget
class GBTimeoutError extends StatelessWidget {
  final VoidCallback? onRetry;

  const GBTimeoutError({
    Key? key,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GBErrorWidget(
      icon: Icons.timer_off_outlined,
      title: 'Request Timed Out',
      message: 'The request took too long to complete. Please try again.',
      onRetry: onRetry,
      retryButtonText: 'Retry',
      error: const NetworkException(
        message: 'Request timeout',
        code: 'TIMEOUT',
      ),
    );
  }
}

/// Error snackbar with retry action
class GBErrorSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
    IconData? icon,
    Color? backgroundColor,
  }) {
    final color = backgroundColor ?? DesignSystem.error;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon ?? Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: DesignSystem.spaceM),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusS),
        ),
        margin: const EdgeInsets.all(DesignSystem.spaceM),
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  onRetry();
                },
              )
            : SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
      ),
    );
  }

  static void showNetworkError(
    BuildContext context, {
    VoidCallback? onRetry,
  }) {
    show(
      context,
      message: 'No internet connection. Please check your network.',
      icon: Icons.wifi_off,
      backgroundColor: DesignSystem.warning,
      onRetry: onRetry,
    );
  }

  static void showServerError(
    BuildContext context, {
    VoidCallback? onRetry,
  }) {
    show(
      context,
      message: 'Server error occurred. Please try again later.',
      icon: Icons.cloud_off,
      onRetry: onRetry,
    );
  }

  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      icon: Icons.check_circle,
      backgroundColor: DesignSystem.success,
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      icon: Icons.info_outline,
      backgroundColor: DesignSystem.primaryBlue,
      duration: duration,
    );
  }

  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      icon: Icons.warning_amber,
      backgroundColor: DesignSystem.warning,
      duration: duration,
    );
  }
}

/// Retry mechanism widget with exponential backoff
class GBRetryMechanism extends StatefulWidget {
  final Future<void> Function() onRetry;
  final Widget Function(
      BuildContext context, bool isRetrying, VoidCallback retry) builder;
  final int maxRetries;
  final Duration initialDelay;
  final void Function(int attempt, dynamic error)? onRetryFailed;

  const GBRetryMechanism({
    Key? key,
    required this.onRetry,
    required this.builder,
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.onRetryFailed,
  }) : super(key: key);

  @override
  State<GBRetryMechanism> createState() => _GBRetryMechanismState();
}

class _GBRetryMechanismState extends State<GBRetryMechanism> {
  bool _isRetrying = false;
  int _retryCount = 0;

  Future<void> _handleRetry() async {
    if (_isRetrying || _retryCount >= widget.maxRetries) return;

    setState(() {
      _isRetrying = true;
      _retryCount++;
    });

    try {
      // Exponential backoff
      if (_retryCount > 1) {
        final delay = widget.initialDelay * _retryCount;
        await Future.delayed(delay);
      }

      await widget.onRetry();

      // Reset on success
      setState(() {
        _retryCount = 0;
      });
    } catch (error) {
      widget.onRetryFailed?.call(_retryCount, error);

      if (_retryCount >= widget.maxRetries) {
        // Max retries reached
        if (mounted) {
          GBErrorSnackbar.show(
            context,
            message:
                'Failed after $_retryCount attempts. Please try again later.',
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _isRetrying, _handleRetry);
  }
}
