import 'package:flutter/material.dart';
import '../../services/rtl_layout_service.dart';

/// A Drawer widget that automatically adapts to RTL layouts
/// Provides proper directional slide animation and layout for Arabic and other RTL languages
class DirectionalDrawer extends StatelessWidget {
  const DirectionalDrawer({
    super.key,
    this.backgroundColor,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.shape,
    this.width,
    this.child,
    this.semanticLabel,
    this.clipBehavior = Clip.none,
  });

  final Color? backgroundColor;
  final double? elevation;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final ShapeBorder? shape;
  final double? width;
  final Widget? child;
  final String? semanticLabel;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final isRTL = RTLLayoutService.isRTL(context);
    
    // Convert shape border radius for RTL if it's a RoundedRectangleBorder
    ShapeBorder? directionalShape = shape;
    if (shape is RoundedRectangleBorder) {
      final roundedShape = shape as RoundedRectangleBorder;
      if (roundedShape.borderRadius is BorderRadius) {
        directionalShape = roundedShape.copyWith(
          borderRadius: RTLLayoutService.convertBorderRadiusToRTL(
            roundedShape.borderRadius as BorderRadius,
            isRTL,
          ),
        );
      }
    }

    return Drawer(
      backgroundColor: backgroundColor,
      elevation: elevation,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      shape: directionalShape,
      width: width,
      semanticLabel: semanticLabel,
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}

/// A DrawerHeader widget that automatically adapts to RTL layouts
class DirectionalDrawerHeader extends StatelessWidget {
  const DirectionalDrawerHeader({
    super.key,
    this.decoration,
    this.margin = const EdgeInsets.only(bottom: 8.0),
    this.padding = const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.fastOutSlowIn,
    required this.child,
  });

  final Decoration? decoration;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Duration duration;
  final Curve curve;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isRTL = RTLLayoutService.isRTL(context);
    
    // Convert padding to RTL
    EdgeInsetsGeometry directionalPadding = padding;
    if (padding is EdgeInsets) {
      directionalPadding = RTLLayoutService.convertPaddingToRTL(
        padding as EdgeInsets,
        isRTL,
      );
    }

    // Convert margin to RTL
    EdgeInsetsGeometry directionalMargin = margin;
    if (margin is EdgeInsets) {
      directionalMargin = RTLLayoutService.convertPaddingToRTL(
        margin as EdgeInsets,
        isRTL,
      );
    }

    // Convert decoration border radius if it's a BoxDecoration
    Decoration? directionalDecoration = decoration;
    if (decoration is BoxDecoration) {
      final boxDecoration = decoration as BoxDecoration;
      if (boxDecoration.borderRadius != null && boxDecoration.borderRadius is BorderRadius) {
        directionalDecoration = boxDecoration.copyWith(
          borderRadius: RTLLayoutService.convertBorderRadiusToRTL(
            boxDecoration.borderRadius as BorderRadius,
            isRTL,
          ),
        );
      }
    }

    return DrawerHeader(
      decoration: directionalDecoration,
      margin: directionalMargin,
      padding: directionalPadding,
      duration: duration,
      curve: curve,
      child: child,
    );
  }
}

/// A ListTile widget optimized for drawer items with RTL support
class DirectionalDrawerItem extends StatelessWidget {
  const DirectionalDrawerItem({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.isThreeLine = false,
    this.dense,
    this.visualDensity,
    this.shape,
    this.style,
    this.selectedColor,
    this.iconColor,
    this.textColor,
    this.contentPadding,
    this.enabled = true,
    this.onTap,
    this.onLongPress,
    this.mouseCursor,
    this.selected = false,
    this.focusColor,
    this.hoverColor,
    this.splashColor,
    this.focusNode,
    this.autofocus = false,
    this.tileColor,
    this.selectedTileColor,
    this.enableFeedback,
    this.horizontalTitleGap,
    this.minVerticalPadding,
    this.minLeadingWidth,
  });

  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final bool isThreeLine;
  final bool? dense;
  final VisualDensity? visualDensity;
  final ShapeBorder? shape;
  final ListTileStyle? style;
  final Color? selectedColor;
  final Color? iconColor;
  final Color? textColor;
  final EdgeInsetsGeometry? contentPadding;
  final bool enabled;
  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;
  final MouseCursor? mouseCursor;
  final bool selected;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? splashColor;
  final FocusNode? focusNode;
  final bool autofocus;
  final Color? tileColor;
  final Color? selectedTileColor;
  final bool? enableFeedback;
  final double? horizontalTitleGap;
  final double? minVerticalPadding;
  final double? minLeadingWidth;

  @override
  Widget build(BuildContext context) {
    final isRTL = RTLLayoutService.isRTL(context);
    
    // Convert content padding to RTL
    EdgeInsetsGeometry? directionalContentPadding = contentPadding;
    if (contentPadding != null && contentPadding is EdgeInsets) {
      directionalContentPadding = RTLLayoutService.convertPaddingToRTL(
        contentPadding as EdgeInsets,
        isRTL,
      );
    }

    // Swap leading and trailing for RTL
    Widget? directionalLeading = leading;
    Widget? directionalTrailing = trailing;
    
    if (isRTL) {
      directionalLeading = trailing;
      directionalTrailing = leading;
    }

    return ListTile(
      leading: directionalLeading,
      title: title,
      subtitle: subtitle,
      trailing: directionalTrailing,
      isThreeLine: isThreeLine,
      dense: dense,
      visualDensity: visualDensity,
      shape: shape,
      style: style,
      selectedColor: selectedColor,
      iconColor: iconColor,
      textColor: textColor,
      contentPadding: directionalContentPadding,
      enabled: enabled,
      onTap: onTap,
      onLongPress: onLongPress,
      mouseCursor: mouseCursor,
      selected: selected,
      focusColor: focusColor,
      hoverColor: hoverColor,
      splashColor: splashColor,
      focusNode: focusNode,
      autofocus: autofocus,
      tileColor: tileColor,
      selectedTileColor: selectedTileColor,
      enableFeedback: enableFeedback,
      horizontalTitleGap: horizontalTitleGap,
      minVerticalPadding: minVerticalPadding,
      minLeadingWidth: minLeadingWidth,
    );
  }
}