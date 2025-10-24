import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../../core/constants/ui_constants.dart';
import '../widgets/app_components.dart';

/// Accessibility service for ARIA labels, keyboard navigation, and screen reader support
class AccessibilityService {
  static final AccessibilityService _instance =
      AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  bool _isScreenReaderEnabled = false;
  bool _isHighContrastEnabled = false;
  bool _isLargeTextEnabled = false;
  double _textScaleFactor = 1.0;

  /// Initialize accessibility service
  void initialize(BuildContext context) {
    _textScaleFactor = MediaQuery.of(context).textScaler.scale(1.0);
    _isScreenReaderEnabled = MediaQuery.of(context).accessibleNavigation;
    _isHighContrastEnabled = MediaQuery.of(context).highContrast;
    _isLargeTextEnabled = _textScaleFactor > 1.2;
  }

  /// Check if screen reader is enabled
  bool get isScreenReaderEnabled => _isScreenReaderEnabled;

  /// Check if high contrast is enabled
  bool get isHighContrastEnabled => _isHighContrastEnabled;

  /// Check if large text is enabled
  bool get isLargeTextEnabled => _isLargeTextEnabled;

  /// Get text scale factor
  double get textScaleFactor => _textScaleFactor;

  /// Create accessible button
  static Widget accessibleButton({
    required Widget child,
    required VoidCallback? onPressed,
    String? semanticLabel,
    String? hint,
    bool excludeSemantics = false,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: hint,
      button: true,
      enabled: onPressed != null,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }

  /// Create accessible text field
  static Widget accessibleTextField({
    required Widget child,
    String? label,
    String? hint,
    String? errorText,
    bool isRequired = false,
    bool excludeSemantics = false,
  }) {
    // Add "required" to label if field is required
    final semanticLabel =
        isRequired && label != null ? '$label, required field' : label;
    final semanticHint = hint ?? (isRequired ? 'This field is required' : null);

    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      textField: true,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }

  /// Create accessible image
  static Widget accessibleImage({
    required Widget child,
    required String semanticLabel,
    String? hint,
    bool excludeSemantics = false,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: hint,
      image: true,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }

  /// Create accessible card
  static Widget accessibleCard({
    required Widget child,
    String? semanticLabel,
    String? hint,
    VoidCallback? onTap,
    bool excludeSemantics = false,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: hint,
      button: onTap != null,
      onTap: onTap,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }

  /// Create accessible list item
  static Widget accessibleListItem({
    required Widget child,
    required int index,
    required int totalItems,
    String? semanticLabel,
    String? hint,
    VoidCallback? onTap,
    bool excludeSemantics = false,
  }) {
    final position = '$index من $totalItems';
    return Semantics(
      label: semanticLabel,
      hint: hint,
      button: onTap != null,
      onTap: onTap,
      excludeSemantics: excludeSemantics,
      child: Semantics(
        label: position,
        excludeSemantics: true,
        child: child,
      ),
    );
  }

  /// Create accessible progress indicator
  static Widget accessibleProgressIndicator({
    required double value,
    String? semanticLabel,
    String? hint,
    bool excludeSemantics = false,
  }) {
    final percentage = (value * 100).round();
    return Semantics(
      label: semanticLabel ?? 'التقدم',
      hint: hint ?? '$percentage بالمئة',
      slider: true,
      value: value.toString(),
      excludeSemantics: excludeSemantics,
      child: LinearProgressIndicator(value: value),
    );
  }

  /// Create accessible switch
  static Widget accessibleSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    String? semanticLabel,
    String? hint,
    bool excludeSemantics = false,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: hint,
      toggled: value,
      excludeSemantics: excludeSemantics,
      child: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  /// Create accessible checkbox
  static Widget accessibleCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    String? semanticLabel,
    String? hint,
    bool excludeSemantics = false,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: hint,
      checked: value,
      excludeSemantics: excludeSemantics,
      child: Checkbox(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  /// Create accessible tab
  static Widget accessibleTab({
    required Widget child,
    required String semanticLabel,
    String? hint,
    bool isSelected = false,
    bool excludeSemantics = false,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: hint,
      selected: isSelected,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }

  /// Create accessible dialog
  static Widget accessibleDialog({
    required Widget child,
    required String semanticLabel,
    String? hint,
    bool excludeSemantics = false,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: hint,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }

  /// Create accessible announcement
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.rtl);
  }

  /// Create accessible focus management
  static void requestFocus(BuildContext context, FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  /// Create accessible navigation
  static void navigateTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
    announce(context, 'تم الانتقال إلى $routeName');
  }

  /// Get accessible colors based on contrast requirements
  static Color getAccessibleColor(BuildContext context, Color baseColor) {
    final accessibilityService = AccessibilityService();

    if (accessibilityService.isHighContrastEnabled) {
      // Use high contrast colors
      return baseColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    }

    return baseColor;
  }

  /// Get accessible text style
  static TextStyle getAccessibleTextStyle(
      BuildContext context, TextStyle baseStyle) {
    final accessibilityService = AccessibilityService();

    if (accessibilityService.isLargeTextEnabled) {
      return baseStyle.copyWith(
        fontSize: baseStyle.fontSize! * accessibilityService.textScaleFactor,
      );
    }

    return baseStyle;
  }

  /// Get accessible button size
  static Size getAccessibleButtonSize(BuildContext context) {
    final accessibilityService = AccessibilityService();

    if (accessibilityService.isLargeTextEnabled) {
      return Size(
        UIConstants.buttonHeightM * accessibilityService.textScaleFactor,
        UIConstants.buttonHeightM * accessibilityService.textScaleFactor,
      );
    }

    return const Size(UIConstants.buttonHeightM, UIConstants.buttonHeightM);
  }

  /// Get accessible spacing
  static double getAccessibleSpacing(BuildContext context, double baseSpacing) {
    final accessibilityService = AccessibilityService();

    if (accessibilityService.isLargeTextEnabled) {
      return baseSpacing * accessibilityService.textScaleFactor;
    }

    return baseSpacing;
  }
}

/// Accessible button widget
class AccessibleButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final String? semanticLabel;
  final String? hint;
  final Color? backgroundColor;
  final Color? textColor;

  const AccessibleButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.semanticLabel,
    this.hint,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final button = AppButton(
      text: text,
      onPressed: onPressed,
      type: type,
      size: size,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );

    return AccessibilityService.accessibleButton(
      child: button,
      onPressed: onPressed,
      semanticLabel: semanticLabel ?? text,
      hint: hint,
    );
  }
}

/// Accessible text field widget
class AccessibleTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool isRequired;

  const AccessibleTextField({
    Key? key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.textInputAction,
    this.focusNode,
    this.isRequired = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textField = AppTextField(
      label: label,
      hint: hint,
      helperText: helperText,
      errorText: errorText,
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      onTap: onTap,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      validator: validator,
      textInputAction: textInputAction,
      focusNode: focusNode,
      isRequired: isRequired,
    );

    return AccessibilityService.accessibleTextField(
      child: textField,
      label: label,
      hint: hint,
      errorText: errorText,
      isRequired: isRequired,
    );
  }
}

/// Accessible card widget
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool enableRipple;
  final String? semanticLabel;
  final String? hint;

  const AccessibleCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.enableRipple = true,
    this.semanticLabel,
    this.hint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final card = AppCard(
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      elevation: elevation,
      borderRadius: borderRadius,
      onTap: onTap,
      enableRipple: enableRipple,
      child: child,
    );

    return AccessibilityService.accessibleCard(
      child: card,
      semanticLabel: semanticLabel,
      hint: hint,
      onTap: onTap,
    );
  }
}
