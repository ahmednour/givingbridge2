import 'package:flutter/material.dart';
import '../../services/rtl_layout_service.dart';
import '../../services/arabic_typography_service.dart';

/// A DropdownButton widget that automatically adapts to RTL layouts
/// Provides proper directional menu positioning for Arabic and other RTL languages
class LocalizedDropdownButton<T> extends StatelessWidget {
  const LocalizedDropdownButton({
    super.key,
    required this.items,
    this.selectedItemBuilder,
    this.value,
    this.hint,
    this.disabledHint,
    this.onChanged,
    this.onTap,
    this.elevation = 8,
    this.style,
    this.underline,
    this.icon,
    this.iconDisabledColor,
    this.iconEnabledColor,
    this.iconSize = 24.0,
    this.isDense = false,
    this.isExpanded = false,
    this.itemHeight,
    this.focusColor,
    this.focusNode,
    this.autofocus = false,
    this.dropdownColor,
    this.menuMaxHeight,
    this.enableFeedback,
    this.alignment = AlignmentDirectional.centerStart,
    this.borderRadius,
    this.padding,
  });

  final List<DropdownMenuItem<T>>? items;
  final DropdownButtonBuilder? selectedItemBuilder;
  final T? value;
  final Widget? hint;
  final Widget? disabledHint;
  final ValueChanged<T?>? onChanged;
  final VoidCallback? onTap;
  final int elevation;
  final TextStyle? style;
  final Widget? underline;
  final Widget? icon;
  final Color? iconDisabledColor;
  final Color? iconEnabledColor;
  final double iconSize;
  final bool isDense;
  final bool isExpanded;
  final double? itemHeight;
  final Color? focusColor;
  final FocusNode? focusNode;
  final bool autofocus;
  final Color? dropdownColor;
  final double? menuMaxHeight;
  final bool? enableFeedback;
  final AlignmentGeometry alignment;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isRTL = RTLLayoutService.isRTL(context);
    
    // Apply Arabic typography if RTL
    TextStyle? directionalStyle = style;
    if (isRTL && style != null) {
      directionalStyle = ArabicTypographyService.getArabicTextStyle(style!);
    } else if (isRTL) {
      directionalStyle = ArabicTypographyService.getArabicTextStyle(
        const TextStyle(),
      );
    }

    // Convert alignment for RTL
    AlignmentGeometry directionalAlignment = alignment;
    if (alignment is Alignment) {
      directionalAlignment = RTLLayoutService.convertAlignmentToRTL(
        alignment as Alignment,
        isRTL,
      );
    }

    // Convert border radius for RTL
    BorderRadius? directionalBorderRadius = borderRadius;
    if (borderRadius != null) {
      directionalBorderRadius = RTLLayoutService.convertBorderRadiusToRTL(
        borderRadius!,
        isRTL,
      );
    }

    // Convert padding for RTL
    EdgeInsetsGeometry? directionalPadding = padding;
    if (padding != null && padding is EdgeInsets) {
      directionalPadding = RTLLayoutService.convertPaddingToRTL(
        padding as EdgeInsets,
        isRTL,
      );
    }

    // Use appropriate dropdown icon for RTL
    Widget? directionalIcon = icon;
    if (icon == null) {
      directionalIcon = Icon(
        RTLLayoutService.getDirectionalIcon(
          context,
          ltrIcon: Icons.arrow_drop_down,
          rtlIcon: Icons.arrow_drop_down,
        ),
      );
    }

    return DropdownButton<T>(
      items: items,
      selectedItemBuilder: selectedItemBuilder,
      value: value,
      hint: hint,
      disabledHint: disabledHint,
      onChanged: onChanged,
      onTap: onTap,
      elevation: elevation,
      style: directionalStyle,
      underline: underline,
      icon: directionalIcon,
      iconDisabledColor: iconDisabledColor,
      iconEnabledColor: iconEnabledColor,
      iconSize: iconSize,
      isDense: isDense,
      isExpanded: isExpanded,
      itemHeight: itemHeight,
      focusColor: focusColor,
      focusNode: focusNode,
      autofocus: autofocus,
      dropdownColor: dropdownColor,
      menuMaxHeight: menuMaxHeight,
      enableFeedback: enableFeedback,
      alignment: directionalAlignment,
      borderRadius: directionalBorderRadius,
      padding: directionalPadding,
    );
  }
}

/// A DropdownButtonFormField widget that automatically adapts to RTL layouts
class LocalizedDropdownButtonFormField<T> extends StatelessWidget {
  const LocalizedDropdownButtonFormField({
    super.key,
    required this.items,
    this.selectedItemBuilder,
    this.value,
    this.hint,
    this.disabledHint,
    this.onChanged,
    this.onTap,
    this.elevation = 8,
    this.style,
    this.icon,
    this.iconDisabledColor,
    this.iconEnabledColor,
    this.iconSize = 24.0,
    this.isDense = false,
    this.isExpanded = false,
    this.itemHeight,
    this.focusColor,
    this.focusNode,
    this.autofocus = false,
    this.dropdownColor,
    this.menuMaxHeight,
    this.enableFeedback,
    this.alignment = AlignmentDirectional.centerStart,
    this.borderRadius,
    this.decoration,
    this.onSaved,
    this.validator,
    this.autovalidateMode,
  });

  final List<DropdownMenuItem<T>>? items;
  final DropdownButtonBuilder? selectedItemBuilder;
  final T? value;
  final Widget? hint;
  final Widget? disabledHint;
  final ValueChanged<T?>? onChanged;
  final VoidCallback? onTap;
  final int elevation;
  final TextStyle? style;
  final Widget? icon;
  final Color? iconDisabledColor;
  final Color? iconEnabledColor;
  final double iconSize;
  final bool isDense;
  final bool isExpanded;
  final double? itemHeight;
  final Color? focusColor;
  final FocusNode? focusNode;
  final bool autofocus;
  final Color? dropdownColor;
  final double? menuMaxHeight;
  final bool? enableFeedback;
  final AlignmentGeometry alignment;
  final BorderRadius? borderRadius;
  final InputDecoration? decoration;
  final FormFieldSetter<T>? onSaved;
  final FormFieldValidator<T>? validator;
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    final isRTL = RTLLayoutService.isRTL(context);
    
    // Apply Arabic typography if RTL
    TextStyle? directionalStyle = style;
    if (isRTL && style != null) {
      directionalStyle = ArabicTypographyService.getArabicTextStyle(style!);
    } else if (isRTL) {
      directionalStyle = ArabicTypographyService.getArabicTextStyle(
        const TextStyle(),
      );
    }

    // Convert alignment for RTL
    AlignmentGeometry directionalAlignment = alignment;
    if (alignment is Alignment) {
      directionalAlignment = RTLLayoutService.convertAlignmentToRTL(
        alignment as Alignment,
        isRTL,
      );
    }

    // Convert border radius for RTL
    BorderRadius? directionalBorderRadius = borderRadius;
    if (borderRadius != null) {
      directionalBorderRadius = RTLLayoutService.convertBorderRadiusToRTL(
        borderRadius!,
        isRTL,
      );
    }

    // Convert decoration padding for RTL
    InputDecoration? directionalDecoration = decoration;
    if (decoration?.contentPadding != null && decoration!.contentPadding is EdgeInsets) {
      directionalDecoration = decoration!.copyWith(
        contentPadding: RTLLayoutService.convertPaddingToRTL(
          decoration!.contentPadding as EdgeInsets,
          isRTL,
        ),
      );
    }

    // Swap prefix and suffix icons for RTL
    if (isRTL && directionalDecoration != null) {
      directionalDecoration = directionalDecoration.copyWith(
        prefixIcon: decoration?.suffixIcon,
        suffixIcon: decoration?.prefixIcon,
        prefix: decoration?.suffix,
        suffix: decoration?.prefix,
      );
    }

    // Use appropriate dropdown icon for RTL
    Widget? directionalIcon = icon;
    if (icon == null) {
      directionalIcon = Icon(
        RTLLayoutService.getDirectionalIcon(
          context,
          ltrIcon: Icons.arrow_drop_down,
          rtlIcon: Icons.arrow_drop_down,
        ),
      );
    }

    return DropdownButtonFormField<T>(
      items: items,
      selectedItemBuilder: selectedItemBuilder,
      value: value,
      hint: hint,
      disabledHint: disabledHint,
      onChanged: onChanged,
      onTap: onTap,
      elevation: elevation,
      style: directionalStyle,
      icon: directionalIcon,
      iconDisabledColor: iconDisabledColor,
      iconEnabledColor: iconEnabledColor,
      iconSize: iconSize,
      isDense: isDense,
      isExpanded: isExpanded,
      itemHeight: itemHeight,
      focusColor: focusColor,
      focusNode: focusNode,
      autofocus: autofocus,
      dropdownColor: dropdownColor,
      menuMaxHeight: menuMaxHeight,
      enableFeedback: enableFeedback,
      alignment: directionalAlignment,
      borderRadius: directionalBorderRadius,
      decoration: directionalDecoration,
      onSaved: onSaved,
      validator: validator,
      autovalidateMode: autovalidateMode,
    );
  }
}

/// A helper widget for creating RTL-aware dropdown menu items
class LocalizedDropdownMenuItem<T> extends StatelessWidget {
  const LocalizedDropdownMenuItem({
    super.key,
    this.onTap,
    this.value,
    this.enabled = true,
    this.alignment = AlignmentDirectional.centerStart,
    required this.child,
  });

  final VoidCallback? onTap;
  final T? value;
  final bool enabled;
  final AlignmentGeometry alignment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isRTL = RTLLayoutService.isRTL(context);
    
    // Convert alignment for RTL
    AlignmentGeometry directionalAlignment = alignment;
    if (alignment is Alignment) {
      directionalAlignment = RTLLayoutService.convertAlignmentToRTL(
        alignment as Alignment,
        isRTL,
      );
    }

    return DropdownMenuItem<T>(
      onTap: onTap,
      value: value,
      enabled: enabled,
      alignment: directionalAlignment,
      child: child,
    );
  }
}