import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';

/// Notification Badge Component
///
/// A standardized badge for showing unread notification counts
/// with support for different sizes and positions.
///
/// Features:
/// - Multiple size variants (small, medium, large)
/// - Overflow handling (99+)
/// - Position variants (inline, floating, corner)
/// - Animated pulse effect
/// - Context-aware colors (dark mode support)
///
/// Usage:
/// ```dart
/// GBNotificationBadge(count: 5)
/// GBNotificationBadge.floating(count: 12)
/// GBNotificationBadge.corner(count: 3, child: Icon(Icons.notifications))
/// ```
class GBNotificationBadge extends StatefulWidget {
  final int count;
  final GBNotificationBadgeSize size;
  final GBNotificationBadgePosition position;
  final Widget? child; // For corner position
  final bool showPulse;
  final Color? color;

  const GBNotificationBadge({
    Key? key,
    required this.count,
    this.size = GBNotificationBadgeSize.medium,
    this.position = GBNotificationBadgePosition.inline,
    this.child,
    this.showPulse = false,
    this.color,
  }) : super(key: key);

  /// Small inline badge
  factory GBNotificationBadge.small({
    required int count,
    bool showPulse = false,
    Color? color,
  }) {
    return GBNotificationBadge(
      count: count,
      size: GBNotificationBadgeSize.small,
      position: GBNotificationBadgePosition.inline,
      showPulse: showPulse,
      color: color,
    );
  }

  /// Medium inline badge (default)
  factory GBNotificationBadge.medium({
    required int count,
    bool showPulse = false,
    Color? color,
  }) {
    return GBNotificationBadge(
      count: count,
      size: GBNotificationBadgeSize.medium,
      position: GBNotificationBadgePosition.inline,
      showPulse: showPulse,
      color: color,
    );
  }

  /// Large inline badge
  factory GBNotificationBadge.large({
    required int count,
    bool showPulse = false,
    Color? color,
  }) {
    return GBNotificationBadge(
      count: count,
      size: GBNotificationBadgeSize.large,
      position: GBNotificationBadgePosition.inline,
      showPulse: showPulse,
      color: color,
    );
  }

  /// Floating badge (absolute positioning)
  factory GBNotificationBadge.floating({
    required int count,
    GBNotificationBadgeSize size = GBNotificationBadgeSize.small,
    bool showPulse = false,
    Color? color,
  }) {
    return GBNotificationBadge(
      count: count,
      size: size,
      position: GBNotificationBadgePosition.floating,
      showPulse: showPulse,
      color: color,
    );
  }

  /// Corner badge (wraps child widget)
  factory GBNotificationBadge.corner({
    required int count,
    required Widget child,
    GBNotificationBadgeSize size = GBNotificationBadgeSize.small,
    bool showPulse = false,
    Color? color,
  }) {
    return GBNotificationBadge(
      count: count,
      size: size,
      position: GBNotificationBadgePosition.corner,
      child: child,
      showPulse: showPulse,
      color: color,
    );
  }

  @override
  State<GBNotificationBadge> createState() => _GBNotificationBadgeState();
}

class _GBNotificationBadgeState extends State<GBNotificationBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.showPulse && widget.count > 0) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(GBNotificationBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showPulse && widget.count > 0) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.count == 0) {
      return widget.position == GBNotificationBadgePosition.corner &&
              widget.child != null
          ? widget.child!
          : const SizedBox.shrink();
    }

    final badgeWidget = _buildBadge(context);

    if (widget.position == GBNotificationBadgePosition.corner) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          widget.child ?? const SizedBox.shrink(),
          Positioned(
            right: -6,
            top: -6,
            child: badgeWidget,
          ),
        ],
      );
    }

    return badgeWidget;
  }

  Widget _buildBadge(BuildContext context) {
    final dimensions = _getDimensions();
    final color = widget.color ?? DesignSystem.error;
    final displayText = widget.count > 99 ? '99+' : widget.count.toString();

    final badge = Container(
      padding: EdgeInsets.symmetric(
        horizontal: dimensions.paddingH,
        vertical: dimensions.paddingV,
      ),
      constraints: BoxConstraints(
        minWidth: dimensions.minSize,
        minHeight: dimensions.minSize,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
        border: Border.all(
          color: DesignSystem.getSurfaceColor(context),
          width: widget.position == GBNotificationBadgePosition.corner ? 2 : 0,
        ),
      ),
      child: Center(
        child: Text(
          displayText,
          style: DesignSystem.labelSmall(context).copyWith(
            color: Colors.white,
            fontSize: dimensions.fontSize,
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );

    if (widget.showPulse && widget.count > 0) {
      return ScaleTransition(
        scale: _pulseAnimation,
        child: badge,
      );
    }

    return badge;
  }

  _BadgeDimensions _getDimensions() {
    switch (widget.size) {
      case GBNotificationBadgeSize.small:
        return const _BadgeDimensions(
          minSize: 16,
          paddingH: 4,
          paddingV: 2,
          fontSize: 10,
        );
      case GBNotificationBadgeSize.medium:
        return const _BadgeDimensions(
          minSize: 20,
          paddingH: 6,
          paddingV: 2,
          fontSize: 11,
        );
      case GBNotificationBadgeSize.large:
        return const _BadgeDimensions(
          minSize: 24,
          paddingH: 8,
          paddingV: 4,
          fontSize: 12,
        );
    }
  }
}

class _BadgeDimensions {
  final double minSize;
  final double paddingH;
  final double paddingV;
  final double fontSize;

  const _BadgeDimensions({
    required this.minSize,
    required this.paddingH,
    required this.paddingV,
    required this.fontSize,
  });
}

enum GBNotificationBadgeSize {
  small,
  medium,
  large,
}

enum GBNotificationBadgePosition {
  inline,
  floating,
  corner,
}
