import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

enum ButtonVariant { primary, secondary, outline, ghost, danger }

enum ButtonSize { small, medium, large }

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final double? width;

  const AppButton({
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
  }) : super(key: key);

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
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
      end: 0.98,
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

  Color _getBackgroundColor() {
    if (widget.isDisabled || widget.isLoading) {
      return AppTheme.textDisabledColor;
    }

    switch (widget.variant) {
      case ButtonVariant.primary:
        return _isHovered ? AppTheme.primaryDarkColor : AppTheme.primaryColor;
      case ButtonVariant.secondary:
        return _isHovered
            ? AppTheme.secondaryDarkColor
            : AppTheme.secondaryColor;
      case ButtonVariant.danger:
        return _isHovered
            ? AppTheme.errorColor.withValues(alpha: 0.9)
            : AppTheme.errorColor;
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
        return _isHovered
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : Colors.transparent;
    }
  }

  Color _getTextColor() {
    if (widget.isDisabled || widget.isLoading) {
      return Colors.white;
    }

    switch (widget.variant) {
      case ButtonVariant.primary:
      case ButtonVariant.secondary:
      case ButtonVariant.danger:
        return Colors.white;
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
        return _isHovered ? AppTheme.primaryColor : AppTheme.textPrimaryColor;
    }
  }

  BorderSide _getBorderSide() {
    if (widget.variant == ButtonVariant.outline) {
      return BorderSide(
        color: widget.isDisabled
            ? AppTheme.textDisabledColor
            : AppTheme.primaryColor,
        width: 1.5,
      );
    }
    return BorderSide.none;
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 13;
      case ButtonSize.medium:
        return 14;
      case ButtonSize.large:
        return 16;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.width,
                decoration: BoxDecoration(
                  color: _getBackgroundColor(),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  border: Border.fromBorderSide(_getBorderSide()),
                  boxShadow: _shouldShowShadow() ? AppTheme.shadowSM : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isClickable() ? widget.onPressed : null,
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    child: Padding(
                      padding: _getPadding(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.leftIcon != null) ...[
                            widget.leftIcon!,
                            const SizedBox(width: AppTheme.spacingS),
                          ],
                          if (widget.isLoading) ...[
                            SizedBox(
                              width: _getFontSize(),
                              height: _getFontSize(),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    _getTextColor()),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingS),
                          ],
                          Text(
                            widget.text,
                            style: TextStyle(
                              fontSize: _getFontSize(),
                              fontWeight: FontWeight.w500,
                              color: _getTextColor(),
                              height: 1.0,
                            ),
                          ),
                          if (widget.rightIcon != null) ...[
                            const SizedBox(width: AppTheme.spacingS),
                            widget.rightIcon!,
                          ],
                        ],
                      ),
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

  bool _isClickable() {
    return !widget.isDisabled && !widget.isLoading && widget.onPressed != null;
  }

  bool _shouldShowShadow() {
    return (widget.variant == ButtonVariant.primary ||
            widget.variant == ButtonVariant.secondary ||
            widget.variant == ButtonVariant.danger) &&
        !widget.isDisabled;
  }
}
