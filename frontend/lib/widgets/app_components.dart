import 'package:flutter/material.dart';
import '../core/constants/ui_constants.dart';
import '../core/theme/app_theme_enhanced.dart';
import '../core/utils/rtl_utils.dart';

/// RTL-aware card widget with consistent styling
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool enableRipple;

  const AppCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.enableRipple = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: backgroundColor ?? AppTheme.surfaceColor,
      elevation: elevation ?? UIConstants.elevationM,
      shadowColor: AppTheme.shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ??
            AppTheme.getRTLBorderRadius(context, all: UIConstants.radiusM),
      ),
      margin: margin ?? EdgeInsets.zero,
      child: Padding(
        padding: padding ?? EdgeInsets.all(UIConstants.spacingM),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ??
            AppTheme.getRTLBorderRadius(context, all: UIConstants.radiusM),
        enableFeedback: enableRipple,
        child: card,
      );
    }

    return card;
  }
}

/// RTL-aware button with consistent styling
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;

  const AppButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isRTL = RTLUtils.isRTL(context);

    Widget button;

    switch (type) {
      case AppButtonType.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppTheme.primaryColor,
            foregroundColor: textColor ?? Colors.white,
            elevation: UIConstants.elevationM,
            padding: padding ?? _getPadding(size),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ?? UIConstants.radiusM,
              ),
            ),
            textStyle: _getTextStyle(size),
          ),
          child: _buildButtonContent(context, isRTL),
        );
        break;
      case AppButtonType.secondary:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor ?? AppTheme.primaryColor,
            side: BorderSide(color: backgroundColor ?? AppTheme.primaryColor),
            padding: padding ?? _getPadding(size),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ?? UIConstants.radiusM,
              ),
            ),
            textStyle: _getTextStyle(size),
          ),
          child: _buildButtonContent(context, isRTL),
        );
        break;
      case AppButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: textColor ?? AppTheme.primaryColor,
            padding: padding ?? _getPadding(size),
            textStyle: _getTextStyle(size),
          ),
          child: _buildButtonContent(context, isRTL),
        );
        break;
    }

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  Widget _buildButtonContent(BuildContext context, bool isRTL) {
    if (isLoading) {
      return SizedBox(
        width: UIConstants.iconS,
        height: UIConstants.iconS,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isRTL) ...[
            Text(text),
            SizedBox(width: UIConstants.spacingS),
            Icon(icon, size: UIConstants.iconS),
          ] else ...[
            Icon(icon, size: UIConstants.iconS),
            SizedBox(width: UIConstants.spacingS),
            Text(text),
          ],
        ],
      );
    }

    return Text(text);
  }

  EdgeInsets _getPadding(AppButtonSize size) {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: UIConstants.spacingM,
          vertical: UIConstants.spacingS,
        );
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: UIConstants.spacingL,
          vertical: UIConstants.spacingM,
        );
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: UIConstants.spacingXL,
          vertical: UIConstants.spacingL,
        );
    }
  }

  TextStyle _getTextStyle(AppButtonSize size) {
    switch (size) {
      case AppButtonSize.small:
        return const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        );
      case AppButtonSize.medium:
        return const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        );
      case AppButtonSize.large:
        return const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        );
    }
  }
}

/// RTL-aware text field with consistent styling
class AppTextField extends StatelessWidget {
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
  final EdgeInsets? contentPadding;
  final Color? fillColor;
  final bool isRequired;

  const AppTextField({
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
    this.contentPadding,
    this.fillColor,
    this.isRequired = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isRTL = RTLUtils.isRTL(context);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      onTap: onTap,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      textInputAction: textInputAction,
      focusNode: focusNode,
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      textAlign: isRTL ? TextAlign.right : TextAlign.left,
      decoration: InputDecoration(
        labelText: label != null && isRequired ? '$label *' : label,
        hintText: hint,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fillColor ?? AppTheme.backgroundColor,
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: UIConstants.spacingM,
              vertical: UIConstants.spacingM,
            ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusM),
          borderSide: const BorderSide(color: AppTheme.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusM),
          borderSide: const BorderSide(color: AppTheme.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusM),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusM),
          borderSide: const BorderSide(color: AppTheme.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusM),
          borderSide: const BorderSide(color: AppTheme.errorColor, width: 2),
        ),
        labelStyle: const TextStyle(color: AppTheme.textSecondaryColor),
        hintStyle: const TextStyle(color: AppTheme.textHintColor),
        helperStyle: const TextStyle(color: AppTheme.textSecondaryColor),
        errorStyle: const TextStyle(color: AppTheme.errorColor),
      ),
    );
  }
}

/// RTL-aware container with consistent spacing
class AppContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;

  const AppContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.width,
    this.height,
    this.alignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        border: border,
        boxShadow: boxShadow,
      ),
      alignment: alignment,
      child: child,
    );
  }
}

/// RTL-aware spacing widget
class AppSpacing extends StatelessWidget {
  final double? width;
  final double? height;
  final double? all;

  const AppSpacing({
    Key? key,
    this.width,
    this.height,
    this.all,
  }) : super(key: key);

  const AppSpacing.horizontal(this.width, {Key? key})
      : height = null,
        all = null,
        super(key: key);

  const AppSpacing.vertical(this.height, {Key? key})
      : width = null,
        all = null,
        super(key: key);

  const AppSpacing.all(this.all, {Key? key})
      : width = null,
        height = null,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: all ?? width,
      height: all ?? height,
    );
  }
}

/// Button types enum
enum AppButtonType {
  primary,
  secondary,
  text,
}

/// Button sizes enum
enum AppButtonSize {
  small,
  medium,
  large,
}
