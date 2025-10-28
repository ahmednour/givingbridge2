import 'package:flutter/material.dart';
import '../theme/design_system.dart';

/// Responsive utilities for mobile-first design
class ResponsiveUtils {
  // ========== BREAKPOINT HELPERS ==========
  
  /// Get current screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < DesignSystem.mobileMedium) {
      return ScreenSize.mobileSmall;
    } else if (width < DesignSystem.tablet) {
      return ScreenSize.mobileMedium;
    } else if (width < DesignSystem.desktop) {
      return ScreenSize.tablet;
    } else if (width < DesignSystem.desktopLarge) {
      return ScreenSize.desktop;
    } else {
      return ScreenSize.desktopLarge;
    }
  }

  /// Check if device is mobile (small or medium)
  static bool isMobile(BuildContext context) {
    final screenSize = getScreenSize(context);
    return screenSize == ScreenSize.mobileSmall || 
           screenSize == ScreenSize.mobileMedium;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    return getScreenSize(context) == ScreenSize.tablet;
  }

  /// Check if device is desktop or larger
  static bool isDesktop(BuildContext context) {
    final screenSize = getScreenSize(context);
    return screenSize == ScreenSize.desktop || 
           screenSize == ScreenSize.desktopLarge;
  }

  /// Check if device has touch interface (mobile or tablet)
  static bool isTouchDevice(BuildContext context) {
    return isMobile(context) || isTablet(context);
  }

  // ========== RESPONSIVE VALUES ==========

  /// Get responsive value based on screen size
  static T responsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  /// Get responsive padding
  static EdgeInsets responsivePadding(BuildContext context) {
    return EdgeInsets.all(
      responsiveValue(
        context,
        mobile: DesignSystem.spaceM,
        tablet: DesignSystem.spaceL,
        desktop: DesignSystem.spaceXL,
      ),
    );
  }

  /// Get responsive horizontal padding
  static EdgeInsets responsiveHorizontalPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: responsiveValue(
        context,
        mobile: DesignSystem.spaceM,
        tablet: DesignSystem.spaceL,
        desktop: DesignSystem.spaceXL,
      ),
    );
  }

  /// Get responsive vertical padding
  static EdgeInsets responsiveVerticalPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      vertical: responsiveValue(
        context,
        mobile: DesignSystem.spaceL,
        tablet: DesignSystem.spaceXL,
        desktop: DesignSystem.spaceXXL,
      ),
    );
  }

  // ========== GRID & LAYOUT HELPERS ==========

  /// Get responsive column count for grids
  static int getGridColumns(BuildContext context, {
    int mobileColumns = 1,
    int tabletColumns = 2,
    int desktopColumns = 3,
  }) {
    return responsiveValue(
      context,
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );
  }

  /// Get responsive cross axis count for GridView
  static int getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < DesignSystem.mobileMedium) {
      return 1; // Single column on small mobile
    } else if (width < DesignSystem.tablet) {
      return 2; // Two columns on larger mobile
    } else if (width < DesignSystem.desktop) {
      return 3; // Three columns on tablet
    } else {
      return 4; // Four columns on desktop
    }
  }

  /// Get responsive aspect ratio for cards
  static double getCardAspectRatio(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 0.8, // Taller cards on mobile
      tablet: 1.0, // Square cards on tablet
      desktop: 1.2, // Wider cards on desktop
    );
  }

  // ========== TYPOGRAPHY HELPERS ==========

  /// Get responsive text scale factor
  static double getTextScaleFactor(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 0.9,
      tablet: 1.0,
      desktop: 1.1,
    );
  }

  /// Get responsive font size
  static double responsiveFontSize(
    BuildContext context, {
    required double baseFontSize,
    double? mobileScale,
    double? tabletScale,
    double? desktopScale,
  }) {
    final scale = responsiveValue(
      context,
      mobile: mobileScale ?? 0.9,
      tablet: tabletScale ?? 1.0,
      desktop: desktopScale ?? 1.1,
    );
    
    return baseFontSize * scale;
  }

  // ========== SPACING HELPERS ==========

  /// Get responsive spacing between elements
  static double getSpacing(BuildContext context, {
    double mobileSpacing = DesignSystem.spaceM,
    double tabletSpacing = DesignSystem.spaceL,
    double desktopSpacing = DesignSystem.spaceXL,
  }) {
    return responsiveValue(
      context,
      mobile: mobileSpacing,
      tablet: tabletSpacing,
      desktop: desktopSpacing,
    );
  }

  /// Get responsive section spacing
  static double getSectionSpacing(BuildContext context) {
    return responsiveValue(
      context,
      mobile: DesignSystem.spaceXXL,
      tablet: DesignSystem.spaceXXXL,
      desktop: 80.0,
    );
  }

  // ========== TOUCH TARGET HELPERS ==========

  /// Get minimum touch target size for current device
  static double getTouchTargetSize(BuildContext context) {
    return isTouchDevice(context) 
        ? DesignSystem.minTouchTarget 
        : 40.0; // Smaller targets for desktop
  }

  /// Get responsive button height
  static double getButtonHeight(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 48.0, // Larger touch targets on mobile
      tablet: 44.0,
      desktop: 40.0,
    );
  }

  // ========== LAYOUT HELPERS ==========

  /// Get responsive max width for content
  static double getMaxContentWidth(BuildContext context) {
    return responsiveValue(
      context,
      mobile: double.infinity,
      tablet: 768.0,
      desktop: 1200.0,
    );
  }

  /// Get responsive sidebar width
  static double getSidebarWidth(BuildContext context) {
    return responsiveValue(
      context,
      mobile: MediaQuery.of(context).size.width * 0.85,
      tablet: 320.0,
      desktop: 280.0,
    );
  }

  /// Check if should use drawer navigation (mobile/tablet)
  static bool shouldUseDrawer(BuildContext context) {
    return !isDesktop(context);
  }

  /// Check if should show navigation rail (desktop)
  static bool shouldShowNavigationRail(BuildContext context) {
    return isDesktop(context);
  }

  // ========== ANIMATION HELPERS ==========

  /// Get responsive animation duration
  static Duration getAnimationDuration(BuildContext context) {
    return isTouchDevice(context) 
        ? DesignSystem.shortDuration 
        : DesignSystem.mediumDuration;
  }

  // ========== UTILITY WIDGETS ==========

  /// Responsive builder widget
  static Widget responsive(
    BuildContext context, {
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  /// Responsive visibility widget
  static Widget showOn({
    required BuildContext context,
    required Widget child,
    bool mobile = true,
    bool tablet = true,
    bool desktop = true,
  }) {
    final shouldShow = (isMobile(context) && mobile) ||
                     (isTablet(context) && tablet) ||
                     (isDesktop(context) && desktop);
    
    return shouldShow ? child : const SizedBox.shrink();
  }

  /// Responsive conditional widget
  static Widget? showOnMobile(BuildContext context, Widget child) {
    return isMobile(context) ? child : null;
  }

  static Widget? showOnTablet(BuildContext context, Widget child) {
    return isTablet(context) ? child : null;
  }

  static Widget? showOnDesktop(BuildContext context, Widget child) {
    return isDesktop(context) ? child : null;
  }
}

/// Screen size enumeration
enum ScreenSize {
  mobileSmall,
  mobileMedium,
  tablet,
  desktop,
  desktopLarge,
}

/// Responsive layout builder
class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenSize screenSize) builder;

  const ResponsiveLayoutBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveUtils.getScreenSize(context);
    return builder(context, screenSize);
  }
}

/// Responsive grid widget
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = DesignSystem.spaceM,
    this.runSpacing = DesignSystem.spaceM,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveUtils.getGridColumns(
      context,
      mobileColumns: mobileColumns,
      tabletColumns: tabletColumns,
      desktopColumns: desktopColumns,
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
        childAspectRatio: ResponsiveUtils.getCardAspectRatio(context),
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}