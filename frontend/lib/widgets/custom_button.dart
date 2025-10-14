import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

enum ButtonVariant { primary, secondary, outline, ghost, danger }

enum ButtonSize { small, medium, large }

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final double? width;
  final double? height;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.leftIcon,
    this.rightIcon,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (!widget.isDisabled && !widget.isLoading) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEnabled =
        !widget.isDisabled && !widget.isLoading && widget.onPressed != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: isEnabled ? widget.onPressed : null,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: widget.width,
                height: widget.height ?? _getButtonHeight(),
                decoration: BoxDecoration(
                  color: _getBackgroundColor(theme, isDark, isEnabled),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  border: _getBorder(theme, isDark, isEnabled),
                  boxShadow: _getShadow(isEnabled),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: _getHorizontalPadding(),
                      vertical: _getVerticalPadding(),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.leftIcon != null) ...[
                          Flexible(child: widget.leftIcon!),
                          const SizedBox(width: AppTheme.spacingS),
                        ],
                        if (widget.isLoading)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _getTextColor(theme, isDark, isEnabled),
                            ),
                          )
                        else
                          Flexible(
                            child: Text(
                              widget.text,
                              style: _getTextStyle(theme, isDark, isEnabled),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (widget.rightIcon != null && !widget.isLoading) ...[
                          const SizedBox(width: AppTheme.spacingS),
                          Flexible(child: widget.rightIcon!),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  double _getButtonHeight() {
    switch (widget.size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 44;
      case ButtonSize.large:
        return 52;
    }
  }

  double _getHorizontalPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return AppTheme.spacingM;
      case ButtonSize.medium:
        return 20.0;
      case ButtonSize.large:
        return AppTheme.spacingL;
    }
  }

  double _getVerticalPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return AppTheme.spacingS;
      case ButtonSize.medium:
        return 12.0;
      case ButtonSize.large:
        return AppTheme.spacingM;
    }
  }

  Color _getBackgroundColor(ThemeData theme, bool isDark, bool isEnabled) {
    final opacity = isEnabled ? 1.0 : 0.5;

    if (_isHovered && isEnabled) {
      switch (widget.variant) {
        case ButtonVariant.primary:
          return AppTheme.primaryDarkColor.withOpacity(opacity);
        case ButtonVariant.secondary:
          return AppTheme.secondaryDarkColor.withOpacity(opacity);
        case ButtonVariant.outline:
          return (isDark ? AppTheme.darkCardColor : AppTheme.cardColor)
              .withOpacity(opacity);
        case ButtonVariant.ghost:
          return (isDark ? AppTheme.darkCardColor : AppTheme.cardColor)
              .withOpacity(opacity);
        case ButtonVariant.danger:
          return AppTheme.errorColor.withOpacity(0.9 * opacity);
      }
    }

    switch (widget.variant) {
      case ButtonVariant.primary:
        return AppTheme.primaryColor.withOpacity(opacity);
      case ButtonVariant.secondary:
        return AppTheme.secondaryColor.withOpacity(opacity);
      case ButtonVariant.outline:
        return Colors.transparent;
      case ButtonVariant.ghost:
        return Colors.transparent;
      case ButtonVariant.danger:
        return AppTheme.errorColor.withOpacity(opacity);
    }
  }

  Color _getTextColor(ThemeData theme, bool isDark, bool isEnabled) {
    final opacity = isEnabled ? 1.0 : 0.5;

    switch (widget.variant) {
      case ButtonVariant.primary:
      case ButtonVariant.secondary:
      case ButtonVariant.danger:
        return Colors.white.withOpacity(opacity);
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
        return (isDark
                ? AppTheme.darkTextPrimaryColor
                : AppTheme.textPrimaryColor)
            .withOpacity(opacity);
    }
  }

  TextStyle _getTextStyle(ThemeData theme, bool isDark, bool isEnabled) {
    double fontSize;
    FontWeight fontWeight = FontWeight.w500;

    switch (widget.size) {
      case ButtonSize.small:
        fontSize = 14;
        break;
      case ButtonSize.medium:
        fontSize = 16;
        break;
      case ButtonSize.large:
        fontSize = 18;
        break;
    }

    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: _getTextColor(theme, isDark, isEnabled),
      height: 1.2,
    );
  }

  Border? _getBorder(ThemeData theme, bool isDark, bool isEnabled) {
    if (widget.variant == ButtonVariant.outline) {
      final borderColor = _isHovered && isEnabled
          ? AppTheme.primaryColor
          : (isDark ? AppTheme.darkBorderColor : AppTheme.borderColor);
      return Border.all(
        color: borderColor.withOpacity(isEnabled ? 1.0 : 0.5),
        width: _isHovered && isEnabled ? 2 : 1,
      );
    }
    return null;
  }

  List<BoxShadow>? _getShadow(bool isEnabled) {
    if (!isEnabled) return null;

    switch (widget.variant) {
      case ButtonVariant.primary:
      case ButtonVariant.secondary:
      case ButtonVariant.danger:
        return _isHovered ? AppTheme.shadowMD : AppTheme.shadowSM;
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
        return _isHovered ? AppTheme.shadowSM : null;
    }
  }
}

// Convenience constructors
class PrimaryButton extends CustomButton {
  const PrimaryButton({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    bool isLoading = false,
    bool isDisabled = false,
    Widget? leftIcon,
    Widget? rightIcon,
    double? width,
    double? height,
  }) : super(
          key: key,
          text: text,
          onPressed: onPressed,
          variant: ButtonVariant.primary,
          size: size,
          isLoading: isLoading,
          isDisabled: isDisabled,
          leftIcon: leftIcon,
          rightIcon: rightIcon,
          width: width,
          height: height,
        );
}

class SecondaryButton extends CustomButton {
  const SecondaryButton({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    bool isLoading = false,
    bool isDisabled = false,
    Widget? leftIcon,
    Widget? rightIcon,
    double? width,
    double? height,
  }) : super(
          key: key,
          text: text,
          onPressed: onPressed,
          variant: ButtonVariant.secondary,
          size: size,
          isLoading: isLoading,
          isDisabled: isDisabled,
          leftIcon: leftIcon,
          rightIcon: rightIcon,
          width: width,
          height: height,
        );
}

class OutlineButton extends CustomButton {
  const OutlineButton({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    bool isLoading = false,
    bool isDisabled = false,
    Widget? leftIcon,
    Widget? rightIcon,
    double? width,
    double? height,
  }) : super(
          key: key,
          text: text,
          onPressed: onPressed,
          variant: ButtonVariant.outline,
          size: size,
          isLoading: isLoading,
          isDisabled: isDisabled,
          leftIcon: leftIcon,
          rightIcon: rightIcon,
          width: width,
          height: height,
        );
}

class GhostButton extends CustomButton {
  const GhostButton({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    bool isLoading = false,
    bool isDisabled = false,
    Widget? leftIcon,
    Widget? rightIcon,
    double? width,
    double? height,
  }) : super(
          key: key,
          text: text,
          onPressed: onPressed,
          variant: ButtonVariant.ghost,
          size: size,
          isLoading: isLoading,
          isDisabled: isDisabled,
          leftIcon: leftIcon,
          rightIcon: rightIcon,
          width: width,
          height: height,
        );
}

class DangerButton extends CustomButton {
  const DangerButton({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    bool isLoading = false,
    bool isDisabled = false,
    Widget? leftIcon,
    Widget? rightIcon,
    double? width,
    double? height,
  }) : super(
          key: key,
          text: text,
          onPressed: onPressed,
          variant: ButtonVariant.danger,
          size: size,
          isLoading: isLoading,
          isDisabled: isDisabled,
          leftIcon: leftIcon,
          rightIcon: rightIcon,
          width: width,
          height: height,
        );
}
