import 'package:flutter/material.dart';
import '../../services/rtl_layout_service.dart';
import '../../services/arabic_typography_service.dart';

/// A Button widget that automatically adapts to RTL layouts
/// Provides proper directional icon placement for Arabic and other RTL languages
class LocalizedElevatedButton extends StatelessWidget {
  const LocalizedElevatedButton({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    this.statesController,
    required this.child,
    this.icon,
    this.iconAlignment = IconAlignment.start,
  });

  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ValueChanged<bool>? onHover;
  final ValueChanged<bool>? onFocusChange;
  final ButtonStyle? style;
  final FocusNode? focusNode;
  final bool autofocus;
  final Clip clipBehavior;
  final MaterialStatesController? statesController;
  final Widget child;
  final Widget? icon;
  final IconAlignment iconAlignment;

  @override
  Widget build(BuildContext context) {
    final isRTL = RTLLayoutService.isRTL(context);

    // Convert icon alignment for RTL
    IconAlignment directionalIconAlignment = iconAlignment;
    if (isRTL) {
      switch (iconAlignment) {
        case IconAlignment.start:
          directionalIconAlignment = IconAlignment.end;
          break;
        case IconAlignment.end:
          directionalIconAlignment = IconAlignment.start;
          break;
      }
    }

    // Apply Arabic typography to button style if RTL
    ButtonStyle? directionalStyle = style;
    if (isRTL && style?.textStyle?.resolve({}) != null) {
      final currentTextStyle = style!.textStyle!.resolve({})!;
      final arabicTextStyle =
          ArabicTypographyService.getArabicTextStyle(currentTextStyle);
      directionalStyle = style!.copyWith(
        textStyle: MaterialStateProperty.all(arabicTextStyle),
      );
    }

    // Convert padding in button style for RTL
    if (directionalStyle?.padding?.resolve({}) != null) {
      final currentPadding = directionalStyle!.padding!.resolve({})!;
      if (currentPadding is EdgeInsets) {
        final rtlPadding =
            RTLLayoutService.convertPaddingToRTL(currentPadding, isRTL);
        directionalStyle = directionalStyle.copyWith(
          padding: MaterialStateProperty.all(rtlPadding),
        );
      }
    }

    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        onLongPress: onLongPress,
        onHover: onHover,
        onFocusChange: onFocusChange,
        style: directionalStyle,
        focusNode: focusNode,
        autofocus: autofocus,
        clipBehavior: clipBehavior,
        statesController: statesController,
        icon: icon!,
        label: child,
        iconAlignment: directionalIconAlignment,
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      onHover: onHover,
      onFocusChange: onFocusChange,
      style: directionalStyle,
      focusNode: focusNode,
      autofocus: autofocus,
      clipBehavior: clipBehavior,
      statesController: statesController,
      child: child,
    );
  }
}

/// A TextButton widget that automatically adapts to RTL layouts
class LocalizedTextButton extends StatelessWidget {
  const LocalizedTextButton({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    this.statesController,
    required this.child,
    this.icon,
    this.iconAlignment = IconAlignment.start,
  });

  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ValueChanged<bool>? onHover;
  final ValueChanged<bool>? onFocusChange;
  final ButtonStyle? style;
  final FocusNode? focusNode;
  final bool autofocus;
  final Clip clipBehavior;
  final MaterialStatesController? statesController;
  final Widget child;
  final Widget? icon;
  final IconAlignment iconAlignment;

  @override
  Widget build(BuildContext context) {
    final isRTL = RTLLayoutService.isRTL(context);

    // Convert icon alignment for RTL
    IconAlignment directionalIconAlignment = iconAlignment;
    if (isRTL) {
      switch (iconAlignment) {
        case IconAlignment.start:
          directionalIconAlignment = IconAlignment.end;
          break;
        case IconAlignment.end:
          directionalIconAlignment = IconAlignment.start;
          break;
      }
    }

    // Apply Arabic typography to button style if RTL
    ButtonStyle? directionalStyle = style;
    if (isRTL && style?.textStyle?.resolve({}) != null) {
      final currentTextStyle = style!.textStyle!.resolve({})!;
      final arabicTextStyle =
          ArabicTypographyService.getArabicTextStyle(currentTextStyle);
      directionalStyle = style!.copyWith(
        textStyle: MaterialStateProperty.all(arabicTextStyle),
      );
    }

    // Convert padding in button style for RTL
    if (directionalStyle?.padding?.resolve({}) != null) {
      final currentPadding = directionalStyle!.padding!.resolve({})!;
      if (currentPadding is EdgeInsets) {
        final rtlPadding =
            RTLLayoutService.convertPaddingToRTL(currentPadding, isRTL);
        directionalStyle = directionalStyle.copyWith(
          padding: MaterialStateProperty.all(rtlPadding),
        );
      }
    }

    if (icon != null) {
      return TextButton.icon(
        onPressed: onPressed,
        onLongPress: onLongPress,
        onHover: onHover,
        onFocusChange: onFocusChange,
        style: directionalStyle,
        focusNode: focusNode,
        autofocus: autofocus,
        clipBehavior: clipBehavior,
        statesController: statesController,
        icon: icon!,
        label: child,
        iconAlignment: directionalIconAlignment,
      );
    }

    return TextButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      onHover: onHover,
      onFocusChange: onFocusChange,
      style: directionalStyle,
      focusNode: focusNode,
      autofocus: autofocus,
      clipBehavior: clipBehavior,
      statesController: statesController,
      child: child,
    );
  }
}

/// An OutlinedButton widget that automatically adapts to RTL layouts
class LocalizedOutlinedButton extends StatelessWidget {
  const LocalizedOutlinedButton({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    this.statesController,
    required this.child,
    this.icon,
    this.iconAlignment = IconAlignment.start,
  });

  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ValueChanged<bool>? onHover;
  final ValueChanged<bool>? onFocusChange;
  final ButtonStyle? style;
  final FocusNode? focusNode;
  final bool autofocus;
  final Clip clipBehavior;
  final MaterialStatesController? statesController;
  final Widget child;
  final Widget? icon;
  final IconAlignment iconAlignment;

  @override
  Widget build(BuildContext context) {
    final isRTL = RTLLayoutService.isRTL(context);

    // Convert icon alignment for RTL
    IconAlignment directionalIconAlignment = iconAlignment;
    if (isRTL) {
      switch (iconAlignment) {
        case IconAlignment.start:
          directionalIconAlignment = IconAlignment.end;
          break;
        case IconAlignment.end:
          directionalIconAlignment = IconAlignment.start;
          break;
      }
    }

    // Apply Arabic typography to button style if RTL
    ButtonStyle? directionalStyle = style;
    if (isRTL && style?.textStyle?.resolve({}) != null) {
      final currentTextStyle = style!.textStyle!.resolve({})!;
      final arabicTextStyle =
          ArabicTypographyService.getArabicTextStyle(currentTextStyle);
      directionalStyle = style!.copyWith(
        textStyle: MaterialStateProperty.all(arabicTextStyle),
      );
    }

    // Convert padding in button style for RTL
    if (directionalStyle?.padding?.resolve({}) != null) {
      final currentPadding = directionalStyle!.padding!.resolve({})!;
      if (currentPadding is EdgeInsets) {
        final rtlPadding =
            RTLLayoutService.convertPaddingToRTL(currentPadding, isRTL);
        directionalStyle = directionalStyle.copyWith(
          padding: MaterialStateProperty.all(rtlPadding),
        );
      }
    }

    if (icon != null) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        onLongPress: onLongPress,
        onHover: onHover,
        onFocusChange: onFocusChange,
        style: directionalStyle,
        focusNode: focusNode,
        autofocus: autofocus,
        clipBehavior: clipBehavior,
        statesController: statesController,
        icon: icon!,
        label: child,
        iconAlignment: directionalIconAlignment,
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      onHover: onHover,
      onFocusChange: onFocusChange,
      style: directionalStyle,
      focusNode: focusNode,
      autofocus: autofocus,
      clipBehavior: clipBehavior,
      statesController: statesController,
      child: child,
    );
  }
}

/// An IconButton widget that automatically adapts to RTL layouts
class LocalizedIconButton extends StatelessWidget {
  const LocalizedIconButton({
    super.key,
    this.iconSize,
    this.visualDensity,
    this.padding,
    this.alignment,
    this.splashRadius,
    this.color,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.splashColor,
    this.disabledColor,
    required this.onPressed,
    this.mouseCursor,
    this.focusNode,
    this.autofocus = false,
    this.tooltip,
    this.enableFeedback,
    this.constraints,
    this.style,
    this.isSelected,
    this.selectedIcon,
    required this.icon,
  });

  final double? iconSize;
  final VisualDensity? visualDensity;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;
  final double? splashRadius;
  final Color? color;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? highlightColor;
  final Color? splashColor;
  final Color? disabledColor;
  final VoidCallback? onPressed;
  final MouseCursor? mouseCursor;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? tooltip;
  final bool? enableFeedback;
  final BoxConstraints? constraints;
  final ButtonStyle? style;
  final bool? isSelected;
  final Widget? selectedIcon;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final isRTL = RTLLayoutService.isRTL(context);

    // Convert padding for RTL
    EdgeInsetsGeometry? directionalPadding = padding;
    if (padding != null && padding is EdgeInsets) {
      directionalPadding = RTLLayoutService.convertPaddingToRTL(
        padding as EdgeInsets,
        isRTL,
      );
    }

    // Convert alignment for RTL
    AlignmentGeometry? directionalAlignment = alignment;
    if (alignment != null && alignment is Alignment) {
      directionalAlignment = RTLLayoutService.convertAlignmentToRTL(
        alignment as Alignment,
        isRTL,
      );
    }

    return IconButton(
      iconSize: iconSize,
      visualDensity: visualDensity,
      padding: directionalPadding,
      alignment: directionalAlignment ?? Alignment.center,
      splashRadius: splashRadius,
      color: color,
      focusColor: focusColor,
      hoverColor: hoverColor,
      highlightColor: highlightColor,
      splashColor: splashColor,
      disabledColor: disabledColor,
      onPressed: onPressed,
      mouseCursor: mouseCursor,
      focusNode: focusNode,
      autofocus: autofocus,
      tooltip: tooltip,
      enableFeedback: enableFeedback,
      constraints: constraints,
      style: style,
      isSelected: isSelected,
      selectedIcon: selectedIcon,
      icon: icon,
    );
  }
}
