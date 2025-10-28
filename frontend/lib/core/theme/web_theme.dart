import 'package:flutter/material.dart';
import 'design_system.dart';

/// Modern Web-Style Theme Configuration
/// Optimized for desktop browsers with React/Next.js aesthetics
class WebTheme {
  // ========== WEB-SPECIFIC SPACING ==========

  /// Max content width for readability (like container-xl in Tailwind)
  static const double maxContentWidth = 1280.0;
  static const double maxContentWidthLarge = 1536.0;
  static const double maxContentWidthSmall = 1024.0;

  /// Sidebar widths
  static const double sidebarWidth = 280.0;
  static const double sidebarCollapsedWidth = 80.0;

  /// Header heights
  static const double headerHeight = 72.0;
  static const double headerHeightCompact = 64.0;

  /// Section spacing for web layouts
  static const double sectionSpacingSmall = 48.0;
  static const double sectionSpacingMedium = 80.0;
  static const double sectionSpacingLarge = 120.0;

  // ========== WEB-STYLE SHADOWS ==========

  /// Subtle shadow for cards (like Tailwind shadow-sm)
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          spreadRadius: 0,
          offset: const Offset(0, 1),
        ),
      ];

  /// Hover state shadow (like Tailwind shadow-md)
  static List<BoxShadow> get hoverShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 20,
          spreadRadius: -2,
          offset: const Offset(0, 4),
        ),
      ];

  /// Elevated shadow for modals/dropdowns (like Tailwind shadow-xl)
  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 40,
          spreadRadius: -4,
          offset: const Offset(0, 12),
        ),
      ];

  // ========== WEB TRANSITIONS ==========

  static const Duration hoverDuration = Duration(milliseconds: 200);
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Curve webCurve = Curves.easeInOut;

  // ========== RESPONSIVE GRID ==========

  /// Get responsive columns based on screen width
  static int getGridColumns(double width) {
    if (width < DesignSystem.tablet) return 1; // Mobile
    if (width < DesignSystem.desktop) return 2; // Tablet
    if (width < DesignSystem.desktopLarge) return 3; // Desktop
    return 4; // Large desktop
  }

  /// Get responsive card width
  static double getCardWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < DesignSystem.tablet) return double.infinity;
    if (width < DesignSystem.desktop) return 360;
    return 400;
  }

  /// Get container padding based on screen width
  static EdgeInsets getContainerPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < DesignSystem.tablet) {
      return const EdgeInsets.all(DesignSystem.spaceM);
    } else if (width < DesignSystem.desktop) {
      return const EdgeInsets.all(DesignSystem.spaceXL);
    } else {
      return const EdgeInsets.symmetric(
        horizontal: DesignSystem.spaceXXL,
        vertical: DesignSystem.spaceXL,
      );
    }
  }

  // ========== WEB COLORS ==========

  /// Background overlay for modals
  static Color get modalOverlay => Colors.black.withValues(alpha: 0.5);

  /// Hover state backgrounds
  static Color get hoverBackground => DesignSystem.neutral100;
  static Color get hoverBackgroundDark => DesignSystem.neutral800;

  /// Active/selected state
  static Color get activeBackground =>
      DesignSystem.primaryBlue.withValues(alpha: 0.08);
  static Color get activeBackgroundDark =>
      DesignSystem.primaryBlue.withValues(alpha: 0.16);

  // ========== NAVIGATION STYLES ==========

  static BoxDecoration get navItemDecoration => BoxDecoration(
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        border: Border.all(
          color: Colors.transparent,
          width: 1,
        ),
      );

  static BoxDecoration navItemHoverDecoration(BuildContext context) =>
      BoxDecoration(
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        color: Theme.of(context).brightness == Brightness.dark
            ? hoverBackgroundDark
            : hoverBackground,
      );

  static BoxDecoration navItemActiveDecoration(BuildContext context) =>
      BoxDecoration(
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        color: Theme.of(context).brightness == Brightness.dark
            ? activeBackgroundDark
            : activeBackground,
        border: Border.all(
          color: DesignSystem.primaryBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      );

  // ========== CARD STYLES ==========

  static BoxDecoration cardDecoration(BuildContext context) => BoxDecoration(
        color: DesignSystem.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(DesignSystem.radiusL),
        border: Border.all(
          color: DesignSystem.getBorderColor(context),
          width: 1,
        ),
        boxShadow: cardShadow,
      );

  static BoxDecoration cardHoverDecoration(BuildContext context) =>
      BoxDecoration(
        color: DesignSystem.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(DesignSystem.radiusL),
        border: Border.all(
          color: DesignSystem.primaryBlue.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: hoverShadow,
      );

  // ========== SECTION CONTAINER ==========

  /// Wraps content with max-width and center alignment (like container in Tailwind)
  static Widget section({
    required Widget child,
    double? maxWidth,
    EdgeInsets? padding,
    Color? backgroundColor,
  }) {
    return Container(
      width: double.infinity,
      color: backgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? maxContentWidth,
          ),
          child: Padding(
            padding: padding ??
                const EdgeInsets.symmetric(
                  horizontal: DesignSystem.spaceXL,
                  vertical: DesignSystem.spaceXXL,
                ),
            child: child,
          ),
        ),
      ),
    );
  }

  // ========== RESPONSIVE BUILDER ==========

  static Widget responsive({
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < DesignSystem.tablet) {
          return mobile;
        } else if (constraints.maxWidth < DesignSystem.desktop) {
          return tablet ?? mobile;
        } else {
          return desktop ?? tablet ?? mobile;
        }
      },
    );
  }
}
