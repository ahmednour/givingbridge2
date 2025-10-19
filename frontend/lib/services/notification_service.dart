import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Centralized notification service for consistent error/success/info messages
class NotificationService {
  /// Show an error notification
  static void showError(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 4)}) {
    _showNotification(
      context,
      message: message,
      backgroundColor: AppTheme.errorColor,
      icon: Icons.error_outline,
      duration: duration,
    );
  }

  /// Show a success notification
  static void showSuccess(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 3)}) {
    _showNotification(
      context,
      message: message,
      backgroundColor: AppTheme.successColor,
      icon: Icons.check_circle_outline,
      duration: duration,
    );
  }

  /// Show an info notification
  static void showInfo(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 3)}) {
    _showNotification(
      context,
      message: message,
      backgroundColor: AppTheme.infoColor,
      icon: Icons.info_outline,
      duration: duration,
    );
  }

  /// Show a warning notification
  static void showWarning(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 4)}) {
    _showNotification(
      context,
      message: message,
      backgroundColor: AppTheme.warningColor,
      icon: Icons.warning_amber_outlined,
      duration: duration,
    );
  }

  /// Show a loading notification (for long operations)
  static void showLoading(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
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
        backgroundColor: AppTheme.textPrimaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(days: 1), // Stay until manually dismissed
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
      ),
    );
  }

  /// Hide the current snackbar
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Show a notification with custom parameters
  static void _showNotification(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
    required Duration duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
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
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show a confirmation dialog
  static Future<bool> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDangerous = false,
  }) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  if (isDangerous)
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppTheme.errorColor,
                    ),
                  if (isDangerous) const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              content: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    cancelText,
                    style: const TextStyle(color: AppTheme.textSecondaryColor),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDangerous
                        ? AppTheme.errorColor
                        : AppTheme.primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingL,
                      vertical: AppTheme.spacingM,
                    ),
                  ),
                  child: Text(
                    confirmText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// Show delete confirmation dialog
  static Future<bool> showDeleteConfirmation(
    BuildContext context, {
    required String itemName,
    String? additionalMessage,
  }) async {
    return await showConfirmation(
      context,
      title: 'Delete $itemName?',
      message: additionalMessage ??
          'Are you sure you want to delete this $itemName? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDangerous: true,
    );
  }

  /// Show logout confirmation dialog
  static Future<bool> showLogoutConfirmation(BuildContext context) async {
    return await showConfirmation(
      context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      cancelText: 'Cancel',
      isDangerous: false,
    );
  }

  /// Show a bottom sheet notification (for more complex content)
  static void showBottomSheetNotification(
    BuildContext context, {
    required String title,
    required String message,
    IconData? icon,
    Color? iconColor,
    Widget? actions,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXL),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color:
                        (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: iconColor ?? AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingL),
              ],
              Text(
                title,
                style: AppTheme.headingMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingM),
              Text(
                message,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              if (actions != null) ...[
                const SizedBox(height: AppTheme.spacingXL),
                actions,
              ],
            ],
          ),
        );
      },
    );
  }
}
