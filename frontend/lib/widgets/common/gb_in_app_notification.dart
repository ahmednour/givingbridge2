import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';

/// In-App Notification Banner
///
/// A floating notification banner that appears at the top/bottom of the screen
/// for real-time notifications without interrupting user flow.
///
/// Features:
/// - Slide-in animation from top/bottom
/// - Auto-dismiss with configurable duration
/// - Swipe-to-dismiss functionality
/// - Multiple notification types
/// - Action buttons support
/// - Dark mode support
/// - Stack multiple notifications
///
/// Usage:
/// ```dart
/// GBInAppNotification.show(
///   context,
///   title: 'New Message',
///   message: 'You have a new message from John',
///   type: GBInAppNotificationType.message,
///   onTap: () => navigateToMessages(),
/// )
/// ```
class GBInAppNotification {
  static OverlayEntry? _currentOverlay;
  static final List<OverlayEntry> _overlayQueue = [];

  /// Show an in-app notification
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    GBInAppNotificationType type = GBInAppNotificationType.info,
    Duration duration = const Duration(seconds: 4),
    GBInAppNotificationPosition position = GBInAppNotificationPosition.top,
    VoidCallback? onTap,
    String? actionLabel,
    VoidCallback? onAction,
    bool enableDismiss = true,
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _GBInAppNotificationWidget(
        title: title,
        message: message,
        type: type,
        duration: duration,
        position: position,
        onTap: onTap,
        actionLabel: actionLabel,
        onAction: onAction,
        enableDismiss: enableDismiss,
        onDismiss: () {
          _currentOverlay?.remove();
          _currentOverlay = null;
          _showNextInQueue(overlay);
        },
      ),
    );

    // If there's a current notification, queue this one
    if (_currentOverlay != null) {
      _overlayQueue.add(overlayEntry);
    } else {
      _currentOverlay = overlayEntry;
      overlay.insert(overlayEntry);
    }
  }

  static void _showNextInQueue(OverlayState overlay) {
    if (_overlayQueue.isNotEmpty) {
      final nextOverlay = _overlayQueue.removeAt(0);
      _currentOverlay = nextOverlay;
      overlay.insert(nextOverlay);
    }
  }

  /// Show success notification
  static void showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      title: title,
      message: message,
      type: GBInAppNotificationType.success,
      duration: duration,
      onTap: onTap,
    );
  }

  /// Show error notification
  static void showError(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 5),
  }) {
    show(
      context,
      title: title,
      message: message,
      type: GBInAppNotificationType.error,
      duration: duration,
      onTap: onTap,
    );
  }

  /// Show warning notification
  static void showWarning(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      title: title,
      message: message,
      type: GBInAppNotificationType.warning,
      duration: duration,
      onTap: onTap,
    );
  }

  /// Show info notification
  static void showInfo(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      title: title,
      message: message,
      type: GBInAppNotificationType.info,
      duration: duration,
      onTap: onTap,
    );
  }

  /// Dismiss current notification
  static void dismiss() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  /// Clear all queued notifications
  static void clearQueue() {
    _overlayQueue.clear();
  }
}

class _GBInAppNotificationWidget extends StatefulWidget {
  final String title;
  final String message;
  final GBInAppNotificationType type;
  final Duration duration;
  final GBInAppNotificationPosition position;
  final VoidCallback? onTap;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool enableDismiss;
  final VoidCallback onDismiss;

  const _GBInAppNotificationWidget({
    Key? key,
    required this.title,
    required this.message,
    required this.type,
    required this.duration,
    required this.position,
    this.onTap,
    this.actionLabel,
    this.onAction,
    required this.enableDismiss,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<_GBInAppNotificationWidget> createState() =>
      _GBInAppNotificationWidgetState();
}

class _GBInAppNotificationWidgetState extends State<_GBInAppNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: DesignSystem.mediumDuration,
      vsync: this,
    );

    // Slide from top or bottom based on position
    final begin = widget.position == GBInAppNotificationPosition.top
        ? const Offset(0, -1)
        : const Offset(0, 1);
    final end = Offset.zero;

    _slideAnimation = Tween<Offset>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: DesignSystem.emphasizedCurve,
    ));

    // Show animation
    _controller.forward();

    // Auto-dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final config = _getConfig();

    final notification = SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: DesignSystem.spaceM,
          right: DesignSystem.spaceM,
          top: widget.position == GBInAppNotificationPosition.top
              ? DesignSystem.spaceM
              : 0,
          bottom: widget.position == GBInAppNotificationPosition.bottom
              ? DesignSystem.spaceM
              : 0,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: size.width > 600 ? 500 : double.infinity,
          ),
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: widget.onTap != null
                  ? () {
                      widget.onTap!();
                      _dismiss();
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.all(DesignSystem.spaceM),
                decoration: BoxDecoration(
                  color: isDark
                      ? DesignSystem.cardDark
                      : DesignSystem.surfaceLight,
                  borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                  border: Border.all(
                    color: config.color.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: DesignSystem.elevation4,
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: config.color.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(DesignSystem.radiusM),
                      ),
                      child: Icon(
                        config.icon,
                        color: config.color,
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: DesignSystem.spaceM),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: DesignSystem.titleSmall(context).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: DesignSystem.spaceXS),
                          Text(
                            widget.message,
                            style: DesignSystem.bodySmall(context),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Action button or dismiss
                    if (widget.actionLabel != null && widget.onAction != null)
                      TextButton(
                        onPressed: () {
                          widget.onAction!();
                          _dismiss();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: config.color,
                        ),
                        child: Text(widget.actionLabel!),
                      )
                    else if (widget.enableDismiss)
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        color: DesignSystem.textSecondary,
                        onPressed: _dismiss,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final wrappedNotification = Dismissible(
      key: UniqueKey(),
      direction: widget.enableDismiss
          ? DismissDirection.horizontal
          : DismissDirection.none,
      onDismissed: (direction) => _dismiss(),
      child: notification,
    );

    return Positioned(
      top: widget.position == GBInAppNotificationPosition.top ? 0 : null,
      bottom: widget.position == GBInAppNotificationPosition.bottom ? 0 : null,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: Align(
          alignment: widget.position == GBInAppNotificationPosition.top
              ? Alignment.topCenter
              : Alignment.bottomCenter,
          child: wrappedNotification,
        ),
      ),
    );
  }

  _InAppNotificationConfig _getConfig() {
    switch (widget.type) {
      case GBInAppNotificationType.success:
        return _InAppNotificationConfig(
          icon: Icons.check_circle,
          color: DesignSystem.success,
        );
      case GBInAppNotificationType.error:
        return _InAppNotificationConfig(
          icon: Icons.error,
          color: DesignSystem.error,
        );
      case GBInAppNotificationType.warning:
        return _InAppNotificationConfig(
          icon: Icons.warning,
          color: DesignSystem.warning,
        );
      case GBInAppNotificationType.info:
        return _InAppNotificationConfig(
          icon: Icons.info,
          color: DesignSystem.info,
        );
      case GBInAppNotificationType.message:
        return _InAppNotificationConfig(
          icon: Icons.message,
          color: DesignSystem.accentPurple,
        );
      case GBInAppNotificationType.donation:
        return _InAppNotificationConfig(
          icon: Icons.favorite,
          color: DesignSystem.accentPink,
        );
    }
  }
}

class _InAppNotificationConfig {
  final IconData icon;
  final Color color;

  _InAppNotificationConfig({
    required this.icon,
    required this.color,
  });
}

enum GBInAppNotificationType {
  success,
  error,
  warning,
  info,
  message,
  donation,
}

enum GBInAppNotificationPosition {
  top,
  bottom,
}
