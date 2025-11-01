import 'package:flutter/material.dart';
import '../../services/rtl_layout_service.dart';

/// A BottomNavigationBar widget that automatically adapts to RTL layouts
/// Provides proper directional item ordering for Arabic and other RTL languages
class DirectionalBottomNavigationBar extends StatelessWidget {
  const DirectionalBottomNavigationBar({
    super.key,
    required this.items,
    this.onTap,
    this.currentIndex = 0,
    this.elevation,
    this.type,
    this.fixedColor,
    this.backgroundColor,
    this.iconSize = 24.0,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.selectedIconTheme,
    this.unselectedIconTheme,
    this.selectedFontSize = 14.0,
    this.unselectedFontSize = 12.0,
    this.selectedLabelStyle,
    this.unselectedLabelStyle,
    this.showSelectedLabels,
    this.showUnselectedLabels,
    this.mouseCursor,
    this.enableFeedback,
    this.landscapeLayout,
    this.useLegacyColorScheme = true,
  });

  final List<BottomNavigationBarItem> items;
  final ValueChanged<int>? onTap;
  final int currentIndex;
  final double? elevation;
  final BottomNavigationBarType? type;
  final Color? fixedColor;
  final Color? backgroundColor;
  final double iconSize;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final IconThemeData? selectedIconTheme;
  final IconThemeData? unselectedIconTheme;
  final double selectedFontSize;
  final double unselectedFontSize;
  final TextStyle? selectedLabelStyle;
  final TextStyle? unselectedLabelStyle;
  final bool? showSelectedLabels;
  final bool? showUnselectedLabels;
  final MouseCursor? mouseCursor;
  final bool? enableFeedback;
  final BottomNavigationBarLandscapeLayout? landscapeLayout;
  final bool useLegacyColorScheme;

  @override
  Widget build(BuildContext context) {
    final isRTL = RTLLayoutService.isRTL(context);
    
    // Reverse items order for RTL
    final directionalItems = isRTL ? items.reversed.toList() : items;
    
    // Adjust current index for RTL
    final directionalCurrentIndex = isRTL 
        ? (items.length - 1 - currentIndex) 
        : currentIndex;

    // Create RTL-aware onTap callback
    ValueChanged<int>? directionalOnTap;
    if (onTap != null) {
      directionalOnTap = (int index) {
        final originalIndex = isRTL 
            ? (items.length - 1 - index) 
            : index;
        onTap!(originalIndex);
      };
    }

    return BottomNavigationBar(
      items: directionalItems,
      onTap: directionalOnTap,
      currentIndex: directionalCurrentIndex,
      elevation: elevation,
      type: type,
      fixedColor: fixedColor,
      backgroundColor: backgroundColor,
      iconSize: iconSize,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      selectedIconTheme: selectedIconTheme,
      unselectedIconTheme: unselectedIconTheme,
      selectedFontSize: selectedFontSize,
      unselectedFontSize: unselectedFontSize,
      selectedLabelStyle: selectedLabelStyle,
      unselectedLabelStyle: unselectedLabelStyle,
      showSelectedLabels: showSelectedLabels,
      showUnselectedLabels: showUnselectedLabels,
      mouseCursor: mouseCursor,
      enableFeedback: enableFeedback,
      landscapeLayout: landscapeLayout,
      useLegacyColorScheme: useLegacyColorScheme,
    );
  }
}

/// A NavigationBar widget that automatically adapts to RTL layouts (Material 3)
class DirectionalNavigationBar extends StatelessWidget {
  const DirectionalNavigationBar({
    super.key,
    this.animationDuration,
    this.selectedIndex = 0,
    required this.destinations,
    this.onDestinationSelected,
    this.backgroundColor,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.indicatorColor,
    this.indicatorShape,
    this.height,
    this.labelBehavior,
    this.overlayColor,
  });

  final Duration? animationDuration;
  final int selectedIndex;
  final List<Widget> destinations;
  final ValueChanged<int>? onDestinationSelected;
  final Color? backgroundColor;
  final double? elevation;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final Color? indicatorColor;
  final ShapeBorder? indicatorShape;
  final double? height;
  final NavigationDestinationLabelBehavior? labelBehavior;
  final MaterialStateProperty<Color?>? overlayColor;

  @override
  Widget build(BuildContext context) {
    final isRTL = RTLLayoutService.isRTL(context);
    
    // Reverse destinations order for RTL
    final directionalDestinations = isRTL 
        ? destinations.reversed.toList() 
        : destinations;
    
    // Adjust selected index for RTL
    final directionalSelectedIndex = isRTL 
        ? (destinations.length - 1 - selectedIndex) 
        : selectedIndex;

    // Create RTL-aware onDestinationSelected callback
    ValueChanged<int>? directionalOnDestinationSelected;
    if (onDestinationSelected != null) {
      directionalOnDestinationSelected = (int index) {
        final originalIndex = isRTL 
            ? (destinations.length - 1 - index) 
            : index;
        onDestinationSelected!(originalIndex);
      };
    }

    return NavigationBar(
      animationDuration: animationDuration,
      selectedIndex: directionalSelectedIndex,
      destinations: directionalDestinations,
      onDestinationSelected: directionalOnDestinationSelected,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      indicatorColor: indicatorColor,
      indicatorShape: indicatorShape,
      height: height,
      labelBehavior: labelBehavior,
      overlayColor: overlayColor,
    );
  }
}

/// A helper widget for creating RTL-aware navigation destinations
class DirectionalNavigationDestination extends StatelessWidget {
  const DirectionalNavigationDestination({
    super.key,
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.tooltip,
  });

  final Widget icon;
  final Widget? selectedIcon;
  final String label;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return NavigationDestination(
      icon: icon,
      selectedIcon: selectedIcon,
      label: label,
      tooltip: tooltip,
    );
  }
}