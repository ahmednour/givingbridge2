import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme_enhanced.dart';
import '../../core/constants/ui_constants.dart';
import '../../widgets/app_components.dart';
import '../../services/error_handler.dart';
import '../../services/offline_service.dart';
import '../../services/network_status_service.dart';
import '../../services/retry_service.dart';
import '../../l10n/app_localizations.dart';

/// Enhanced error handling widget with offline support
class ErrorHandlingWidget extends StatefulWidget {
  final Widget child;
  final Future<void> Function()? onRetry;
  final Widget Function(BuildContext context, AppException error)? errorBuilder;
  final bool showRetryButton;
  final bool showOfflineIndicator;
  final RetryConfig retryConfig;

  const ErrorHandlingWidget({
    Key? key,
    required this.child,
    this.onRetry,
    this.errorBuilder,
    this.showRetryButton = true,
    this.showOfflineIndicator = true,
    this.retryConfig = RetryConfig.network,
  }) : super(key: key);

  @override
  State<ErrorHandlingWidget> createState() => _ErrorHandlingWidgetState();
}

class _ErrorHandlingWidgetState extends State<ErrorHandlingWidget> {
  AppException? _error;
  bool _isRetrying = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Offline Indicator
        if (widget.showOfflineIndicator)
          Consumer<NetworkStatusService>(
            builder: (context, networkService, _) {
              if (networkService.isOnline) {
                return const SizedBox.shrink();
              }

              return Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: UIConstants.spacingM,
                  vertical: UIConstants.spacingS,
                ),
                color: AppTheme.warningColor,
                child: Row(
                  children: [
                    Icon(
                      Icons.wifi_off,
                      color: Colors.white,
                      size: 16,
                    ),
                    AppSpacing.horizontal(UIConstants.spacingS),
                    Expanded(
                      child: Text(
                        l10n.offlineMode,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => networkService.forceCheck(),
                      child: Text(
                        l10n.retry,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

        // Main Content
        Expanded(
          child: _error != null ? _buildErrorState() : widget.child,
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    final l10n = AppLocalizations.of(context)!;

    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context, _error!);
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(UIConstants.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color:
                    ErrorHandler.getErrorColor(_error!).withOpacity( 0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                ErrorHandler.getErrorIcon(_error!),
                color: ErrorHandler.getErrorColor(_error!),
                size: 40,
              ),
            ),

            AppSpacing.vertical(UIConstants.spacingL),

            // Error Title
            Text(
              l10n.somethingWentWrong,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
              textAlign: TextAlign.center,
            ),

            AppSpacing.vertical(UIConstants.spacingS),

            // Error Message
            Text(
              ErrorHandler.getUserFriendlyMessage(_error!),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
              textAlign: TextAlign.center,
            ),

            AppSpacing.vertical(UIConstants.spacingL),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.showRetryButton && widget.onRetry != null) ...[
                  AppButton(
                    text: l10n.retry,
                    icon: Icons.refresh,
                    type: AppButtonType.primary,
                    onPressed: _isRetrying ? null : _handleRetry,
                    isLoading: _isRetrying,
                  ),
                  AppSpacing.horizontal(UIConstants.spacingM),
                ],
                AppButton(
                  text: l10n.goBack,
                  icon: Icons.arrow_back,
                  type: AppButtonType.secondary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            // Offline Operations Info
            Consumer<OfflineService>(
              builder: (context, offlineService, _) {
                if (offlineService.pendingOperationsCount == 0) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: EdgeInsets.only(top: UIConstants.spacingL),
                  child: Container(
                    padding: EdgeInsets.all(UIConstants.spacingM),
                    decoration: BoxDecoration(
                      color: AppTheme.infoColor.withOpacity( 0.1),
                      borderRadius: BorderRadius.circular(UIConstants.radiusM),
                      border: Border.all(
                        color: AppTheme.infoColor.withOpacity( 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.cloud_off_outlined,
                              color: AppTheme.infoColor,
                              size: 20,
                            ),
                            AppSpacing.horizontal(UIConstants.spacingS),
                            Expanded(
                              child: Text(
                                l10n.pendingOperations(
                                    offlineService.pendingOperationsCount),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.infoColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.vertical(UIConstants.spacingS),
                        AppButton(
                          text: l10n.syncNow,
                          icon: Icons.sync,
                          type: AppButtonType.secondary,
                          size: AppButtonSize.small,
                          onPressed: () => offlineService.forceSync(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRetry() async {
    if (widget.onRetry == null) return;

    setState(() {
      _isRetrying = true;
    });

    try {
      await RetryService.executeWithRetry<void>(
        widget.onRetry!,
        config: widget.retryConfig,
        operationName: 'ErrorHandlingWidget_Retry',
      );

      setState(() {
        _error = null;
      });
    } catch (error) {
      setState(() {
        _error = ErrorHandler.handleException(error, null);
      });
    } finally {
      setState(() {
        _isRetrying = false;
      });
    }
  }

  void setError(AppException error) {
    setState(() {
      _error = error;
    });
  }

  void clearError() {
    setState(() {
      _error = null;
    });
  }
}

/// Error boundary for catching widget errors
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

      return ErrorHandlingWidget(
        onRetry: () async {
          setState(() {
            _error = null;
          });
        },
        child: const SizedBox.shrink(),
      );
    }

    return widget.child;
  }
}

/// Offline-aware widget wrapper
class OfflineAwareWidget extends StatelessWidget {
  final Widget child;
  final Widget Function(BuildContext context, bool isOffline)? offlineBuilder;
  final bool showOfflineIndicator;

  const OfflineAwareWidget({
    Key? key,
    required this.child,
    this.offlineBuilder,
    this.showOfflineIndicator = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkStatusService>(
      builder: (context, networkService, _) {
        if (networkService.isOffline && offlineBuilder != null) {
          return offlineBuilder!(context, true);
        }

        return Column(
          children: [
            if (showOfflineIndicator && networkService.isOffline)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: UIConstants.spacingM,
                  vertical: UIConstants.spacingS,
                ),
                color: AppTheme.warningColor,
                child: Row(
                  children: [
                    Icon(
                      Icons.wifi_off,
                      color: Colors.white,
                      size: 16,
                    ),
                    AppSpacing.horizontal(UIConstants.spacingS),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.offlineMode,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => networkService.forceCheck(),
                      child: Text(
                        AppLocalizations.of(context)!.retry,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}

/// Retry button widget with enhanced styling
class EnhancedRetryButton extends StatelessWidget {
  final Future<void> Function() onRetry;
  final String? text;
  final IconData? icon;
  final RetryConfig config;
  final AppButtonType type;
  final AppButtonSize size;

  const EnhancedRetryButton({
    Key? key,
    required this.onRetry,
    this.text,
    this.icon,
    this.config = RetryConfig.network,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppButton(
      text: text ?? l10n.retry,
      icon: icon ?? Icons.refresh,
      type: type,
      size: size,
      onPressed: () async {
        await RetryService.executeWithRetry<void>(
          onRetry,
          config: config,
          operationName: 'EnhancedRetryButton',
        );
      },
    );
  }
}

/// Error snackbar with retry option
class ErrorSnackbar {
  static void show(
    BuildContext context,
    AppException error, {
    VoidCallback? onRetry,
    String? retryText,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final message = ErrorHandler.getUserFriendlyMessage(error);
    final icon = ErrorHandler.getErrorIcon(error);
    final color = ErrorHandler.getErrorColor(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            AppSpacing.horizontal(UIConstants.spacingS),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusM),
        ),
        margin: EdgeInsets.all(UIConstants.spacingM),
        duration: const Duration(seconds: 4),
        action: onRetry != null
            ? SnackBarAction(
                label: retryText ?? l10n.retry,
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : SnackBarAction(
                label: l10n.dismiss,
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
      ),
    );
  }
}
