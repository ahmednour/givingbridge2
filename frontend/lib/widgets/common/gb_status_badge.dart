import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';

/// Status badge component for displaying request/donation status
///
/// Features:
/// - Color-coded status indicators
/// - Multiple size variants
/// - Icon support
/// - Predefined status types with consistent styling
/// - Custom status support
///
/// Usage:
/// ```dart
/// GBStatusBadge.pending()
/// GBStatusBadge.approved()
/// GBStatusBadge.completed()
/// GBStatusBadge(
///   label: 'Custom',
///   color: Colors.purple,
///   icon: Icons.star,
/// )
/// ```
class GBStatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final GBStatusBadgeSize size;
  final bool outlined;

  const GBStatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
    this.size = GBStatusBadgeSize.medium,
    this.outlined = false,
  });

  // Factory constructors for common statuses

  /// Pending status (yellow/warning)
  factory GBStatusBadge.pending({
    GBStatusBadgeSize size = GBStatusBadgeSize.medium,
    bool outlined = false,
  }) {
    return GBStatusBadge(
      label: 'Pending',
      backgroundColor: DesignSystem.warning.withOpacity(0.1),
      textColor: DesignSystem.warning,
      icon: Icons.schedule,
      size: size,
      outlined: outlined,
    );
  }

  /// Approved status (blue/primary)
  factory GBStatusBadge.approved({
    GBStatusBadgeSize size = GBStatusBadgeSize.medium,
    bool outlined = false,
  }) {
    return GBStatusBadge(
      label: 'Approved',
      backgroundColor: DesignSystem.primaryBlue.withOpacity(0.1),
      textColor: DesignSystem.primaryBlue,
      icon: Icons.check_circle,
      size: size,
      outlined: outlined,
    );
  }

  /// Declined status (red/error)
  factory GBStatusBadge.declined({
    GBStatusBadgeSize size = GBStatusBadgeSize.medium,
    bool outlined = false,
  }) {
    return GBStatusBadge(
      label: 'Declined',
      backgroundColor: DesignSystem.error.withOpacity(0.1),
      textColor: DesignSystem.error,
      icon: Icons.cancel,
      size: size,
      outlined: outlined,
    );
  }

  /// In Progress status (blue/info)
  factory GBStatusBadge.inProgress({
    GBStatusBadgeSize size = GBStatusBadgeSize.medium,
    bool outlined = false,
  }) {
    return GBStatusBadge(
      label: 'In Progress',
      backgroundColor: DesignSystem.info.withOpacity(0.1),
      textColor: DesignSystem.info,
      icon: Icons.sync,
      size: size,
      outlined: outlined,
    );
  }

  /// Completed status (green/success)
  factory GBStatusBadge.completed({
    GBStatusBadgeSize size = GBStatusBadgeSize.medium,
    bool outlined = false,
  }) {
    return GBStatusBadge(
      label: 'Completed',
      backgroundColor: DesignSystem.success.withOpacity(0.1),
      textColor: DesignSystem.success,
      icon: Icons.check_circle_outline,
      size: size,
      outlined: outlined,
    );
  }

  /// Cancelled status (gray/neutral)
  factory GBStatusBadge.cancelled({
    GBStatusBadgeSize size = GBStatusBadgeSize.medium,
    bool outlined = false,
  }) {
    return GBStatusBadge(
      label: 'Cancelled',
      backgroundColor: DesignSystem.neutral300.withOpacity(0.1),
      textColor: DesignSystem.neutral600,
      icon: Icons.block,
      size: size,
      outlined: outlined,
    );
  }

  /// Active status (green/success)
  factory GBStatusBadge.active({
    GBStatusBadgeSize size = GBStatusBadgeSize.medium,
    bool outlined = false,
  }) {
    return GBStatusBadge(
      label: 'Active',
      backgroundColor: DesignSystem.success.withOpacity(0.1),
      textColor: DesignSystem.success,
      icon: Icons.circle,
      size: size,
      outlined: outlined,
    );
  }

  /// Inactive status (gray/neutral)
  factory GBStatusBadge.inactive({
    GBStatusBadgeSize size = GBStatusBadgeSize.medium,
    bool outlined = false,
  }) {
    return GBStatusBadge(
      label: 'Inactive',
      backgroundColor: DesignSystem.neutral300.withOpacity(0.1),
      textColor: DesignSystem.neutral600,
      icon: Icons.circle_outlined,
      size: size,
      outlined: outlined,
    );
  }

  /// Draft status (gray/neutral)
  factory GBStatusBadge.draft({
    GBStatusBadgeSize size = GBStatusBadgeSize.medium,
    bool outlined = false,
  }) {
    return GBStatusBadge(
      label: 'Draft',
      backgroundColor: DesignSystem.neutral300.withOpacity(0.1),
      textColor: DesignSystem.neutral600,
      icon: Icons.edit,
      size: size,
      outlined: outlined,
    );
  }

  /// Urgent status (red/error)
  factory GBStatusBadge.urgent({
    GBStatusBadgeSize size = GBStatusBadgeSize.medium,
    bool outlined = false,
  }) {
    return GBStatusBadge(
      label: 'Urgent',
      backgroundColor: DesignSystem.error.withOpacity(0.1),
      textColor: DesignSystem.error,
      icon: Icons.priority_high,
      size: size,
      outlined: outlined,
    );
  }

  /// New status (primary blue)
  factory GBStatusBadge.newStatus({
    GBStatusBadgeSize size = GBStatusBadgeSize.medium,
    bool outlined = false,
  }) {
    return GBStatusBadge(
      label: 'New',
      backgroundColor: DesignSystem.primaryBlue.withOpacity(0.1),
      textColor: DesignSystem.primaryBlue,
      icon: Icons.fiber_new,
      size: size,
      outlined: outlined,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizeConfig = _getSizeConfig();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizeConfig.horizontalPadding,
        vertical: sizeConfig.verticalPadding,
      ),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : backgroundColor,
        border: outlined ? Border.all(color: textColor, width: 1.5) : null,
        borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: sizeConfig.iconSize,
              color: textColor,
            ),
            SizedBox(width: sizeConfig.iconSpacing),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: sizeConfig.fontSize,
              fontWeight: sizeConfig.fontWeight,
              color: textColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeSizeConfig _getSizeConfig() {
    switch (size) {
      case GBStatusBadgeSize.small:
        return _BadgeSizeConfig(
          horizontalPadding: 8,
          verticalPadding: 4,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          iconSize: 12,
          iconSpacing: 4,
          borderRadius: DesignSystem.radiusS,
        );
      case GBStatusBadgeSize.medium:
        return _BadgeSizeConfig(
          horizontalPadding: 12,
          verticalPadding: 6,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          iconSize: 14,
          iconSpacing: 6,
          borderRadius: DesignSystem.radiusM,
        );
      case GBStatusBadgeSize.large:
        return _BadgeSizeConfig(
          horizontalPadding: 16,
          verticalPadding: 8,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          iconSize: 16,
          iconSpacing: 8,
          borderRadius: DesignSystem.radiusM,
        );
    }
  }
}

/// Size variants for status badge
enum GBStatusBadgeSize {
  small,
  medium,
  large,
}

/// Internal configuration for badge sizing
class _BadgeSizeConfig {
  final double horizontalPadding;
  final double verticalPadding;
  final double fontSize;
  final FontWeight fontWeight;
  final double iconSize;
  final double iconSpacing;
  final double borderRadius;

  _BadgeSizeConfig({
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.fontSize,
    required this.fontWeight,
    required this.iconSize,
    required this.iconSpacing,
    required this.borderRadius,
  });
}
