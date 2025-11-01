import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/rtl_layout_service.dart';

/// An AppBar widget that automatically adapts to RTL layouts
/// Provides proper directional icon positioning and layout for Arabic and other RTL languages
class DirectionalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DirectionalAppBar({
    super.key,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.title,
    this.actions,
    this.flexibleSpace,
    this.bottom,
    this.elevation,
    this.scrolledUnderElevation,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.shadowColor,
    this.surfaceTintColor,
    this.shape,
    this.backgroundColor,
    this.foregroundColor,
    this.iconTheme,
    this.actionsIconTheme,
    this.primary = true,
    this.centerTitle,
    this.excludeHeaderSemantics = false,
    this.titleSpacing,
    this.toolbarOpacity = 1.0,
    this.bottomOpacity = 1.0,
    this.toolbarHeight,
    this.leadingWidth,
    this.toolbarTextStyle,
    this.titleTextStyle,
    this.systemOverlayStyle,
    this.forceMaterialTransparency = false,
    this.clipBehavior,
  });

  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Widget? title;
  final List<Widget>? actions;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;
  final double? elevation;
  final double? scrolledUnderElevation;
  final ScrollNotificationPredicate notificationPredicate;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final ShapeBorder? shape;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconThemeData? iconTheme;
  final IconThemeData? actionsIconTheme;
  final bool primary;
  final bool? centerTitle;
  final bool excludeHeaderSemantics;
  final double? titleSpacing;
  final double toolbarOpacity;
  final double bottomOpacity;
  final double? toolbarHeight;
  final double? leadingWidth;
  final TextStyle? toolbarTextStyle;
  final TextStyle? titleTextStyle;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final bool forceMaterialTransparency;
  final Clip? clipBehavior;

  @override
  Widget build(BuildContext context) {
    final isRTL = RTLLayoutService.isRTL(context);
    
    // Reverse actions order for RTL
    List<Widget>? directionalActions;
    if (actions != null) {
      directionalActions = isRTL ? actions!.reversed.toList() : actions;
    }

    // Determine center title based on RTL context
    bool? directionalCenterTitle = centerTitle;
    if (directionalCenterTitle == null) {
      // Default behavior: center title in RTL, left-align in LTR
      directionalCenterTitle = isRTL;
    }

    // Create directional leading widget if needed
    Widget? directionalLeading = leading;
    if (leading == null && automaticallyImplyLeading) {
      // Let AppBar handle automatic leading, but ensure proper RTL behavior
      directionalLeading = null;
    }

    return AppBar(
      leading: directionalLeading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: title,
      actions: directionalActions,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
      elevation: elevation,
      scrolledUnderElevation: scrolledUnderElevation,
      notificationPredicate: notificationPredicate,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      shape: shape,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      iconTheme: iconTheme,
      actionsIconTheme: actionsIconTheme,
      primary: primary,
      centerTitle: directionalCenterTitle,
      excludeHeaderSemantics: excludeHeaderSemantics,
      titleSpacing: titleSpacing,
      toolbarOpacity: toolbarOpacity,
      bottomOpacity: bottomOpacity,
      toolbarHeight: toolbarHeight,
      leadingWidth: leadingWidth,
      toolbarTextStyle: toolbarTextStyle,
      titleTextStyle: titleTextStyle,
      systemOverlayStyle: systemOverlayStyle,
      forceMaterialTransparency: forceMaterialTransparency,
      clipBehavior: clipBehavior,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    toolbarHeight ?? kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
  );
}

/// A helper widget for creating RTL-aware app bar actions
class DirectionalAppBarAction extends StatelessWidget {
  const DirectionalAppBarAction({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.padding,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isRTL = RTLLayoutService.isRTL(context);
    
    // Convert padding to RTL if provided
    EdgeInsetsGeometry? directionalPadding = padding;
    if (padding != null && padding is EdgeInsets) {
      directionalPadding = RTLLayoutService.convertPaddingToRTL(
        padding as EdgeInsets,
        isRTL,
      );
    }

    Widget actionButton = IconButton(
      icon: icon,
      onPressed: onPressed,
      tooltip: tooltip,
      padding: directionalPadding ?? const EdgeInsets.all(8.0),
    );

    return actionButton;
  }
}