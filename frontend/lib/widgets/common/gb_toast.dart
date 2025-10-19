import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';

/// Enhanced Toast Notification System for GivingBridge
/// Provides non-blocking feedback for user actions
enum GBToastType { success, error, warning, info }

class GBToast {
  static void show(
    BuildContext context, {
    required String message,
    GBToastType type = GBToastType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _GBToastWidget(
        message: message,
        type: type,
        onDismiss: () => overlayEntry.remove(),
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );

    overlay.insert(overlayEntry);

    // Auto dismiss after duration
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, type: GBToastType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, type: GBToastType.error);
  }

  static void warning(BuildContext context, String message) {
    show(context, message: message, type: GBToastType.warning);
  }

  static void info(BuildContext context, String message) {
    show(context, message: message, type: GBToastType.info);
  }
}

class _GBToastWidget extends StatefulWidget {
  final String message;
  final GBToastType type;
  final VoidCallback onDismiss;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _GBToastWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<_GBToastWidget> createState() => _GBToastWidgetState();
}

class _GBToastWidgetState extends State<_GBToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DesignSystem.mediumDuration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: DesignSystem.emphasizedCurve,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case GBToastType.success:
        return DesignSystem.success;
      case GBToastType.error:
        return DesignSystem.error;
      case GBToastType.warning:
        return DesignSystem.warning;
      case GBToastType.info:
        return DesignSystem.info;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case GBToastType.success:
        return Icons.check_circle;
      case GBToastType.error:
        return Icons.error;
      case GBToastType.warning:
        return Icons.warning;
      case GBToastType.info:
        return Icons.info;
    }
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: DesignSystem.spaceXL,
      left: DesignSystem.spaceL,
      right: DesignSystem.spaceL,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(DesignSystem.radiusL),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignSystem.spaceL,
                vertical: DesignSystem.spaceM,
              ),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                boxShadow: DesignSystem.elevation4,
              ),
              child: Row(
                children: [
                  Icon(
                    _getIcon(),
                    color: Colors.white,
                    size: DesignSystem.iconSizeMedium,
                  ),
                  const SizedBox(width: DesignSystem.spaceM),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: DesignSystem.bodyMedium(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (widget.actionLabel != null &&
                      widget.onAction != null) ...[
                    const SizedBox(width: DesignSystem.spaceM),
                    TextButton(
                      onPressed: () {
                        widget.onAction?.call();
                        _dismiss();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      child: Text(widget.actionLabel!),
                    ),
                  ],
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _dismiss,
                    iconSize: 20,
                    constraints: const BoxConstraints(
                      minWidth: DesignSystem.minTouchTarget,
                      minHeight: DesignSystem.minTouchTarget,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Usage Examples:
/// 
/// GBToast.success(context, 'Donation created successfully!');
/// 
/// GBToast.error(context, 'Failed to load data');
/// 
/// GBToast.show(
///   context,
///   message: 'Request sent',
///   type: GBToastType.success,
///   actionLabel: 'View',
///   onAction: () => Navigator.pushNamed(context, '/requests'),
/// );
