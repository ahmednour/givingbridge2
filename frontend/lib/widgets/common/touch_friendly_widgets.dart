import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/design_system.dart';
import '../../core/utils/responsive_utils.dart';

/// Touch-friendly button with proper sizing and feedback
class TouchButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final TouchButtonVariant variant;
  final TouchButtonSize size;
  final bool fullWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const TouchButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = TouchButtonVariant.primary,
    this.size = TouchButtonSize.medium,
    this.fullWidth = false,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  State<TouchButton> createState() => _TouchButtonState();
}

class _TouchButtonState extends State<TouchButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
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

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _animationController.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final sizing = _getSizing(context);
    final colors = _getColors(context);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onPressed != null && !widget.isLoading
                ? widget.onPressed
                : null,
            child: Container(
              width: widget.fullWidth ? double.infinity : null,
              height: sizing.height,
              constraints: BoxConstraints(
                minWidth: sizing.minWidth,
                minHeight: ResponsiveUtils.getTouchTargetSize(context),
              ),
              decoration: BoxDecoration(
                color: colors.backgroundColor,
                borderRadius: BorderRadius.circular(sizing.borderRadius),
                border: widget.variant == TouchButtonVariant.outline
                    ? Border.all(
                        color: colors.borderColor,
                        width: 1,
                      )
                    : null,
                boxShadow: widget.variant == TouchButtonVariant.primary
                    ? DesignSystem.elevation2
                    : null,
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: sizing.iconSize,
                        height: sizing.iconSize,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colors.foregroundColor,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              size: sizing.iconSize,
                              color: colors.foregroundColor,
                            ),
                            SizedBox(width: sizing.spacing),
                          ],
                          Text(
                            widget.text,
                            style: sizing.textStyle.copyWith(
                              color: colors.foregroundColor,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  _TouchButtonSizing _getSizing(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    
    switch (widget.size) {
      case TouchButtonSize.small:
        return _TouchButtonSizing(
          height: isMobile ? 40 : 36,
          minWidth: isMobile ? 80 : 64,
          iconSize: isMobile ? 18 : 16,
          spacing: DesignSystem.spaceS,
          borderRadius: DesignSystem.radiusM,
          textStyle: DesignSystem.labelMedium(context),
        );
      case TouchButtonSize.medium:
        return _TouchButtonSizing(
          height: isMobile ? 48 : 44,
          minWidth: isMobile ? 100 : 80,
          iconSize: isMobile ? 22 : 20,
          spacing: DesignSystem.spaceM,
          borderRadius: DesignSystem.radiusM,
          textStyle: DesignSystem.labelLarge(context),
        );
      case TouchButtonSize.large:
        return _TouchButtonSizing(
          height: isMobile ? 56 : 52,
          minWidth: isMobile ? 120 : 100,
          iconSize: isMobile ? 26 : 24,
          spacing: DesignSystem.spaceM,
          borderRadius: DesignSystem.radiusL,
          textStyle: DesignSystem.titleMedium(context),
        );
    }
  }

  _TouchButtonColors _getColors(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    
    switch (widget.variant) {
      case TouchButtonVariant.primary:
        return _TouchButtonColors(
          backgroundColor: widget.backgroundColor ??
              (isDisabled ? DesignSystem.neutral300 : DesignSystem.primaryBlue),
          foregroundColor: widget.foregroundColor ?? Colors.white,
          borderColor: Colors.transparent,
        );
      case TouchButtonVariant.secondary:
        return _TouchButtonColors(
          backgroundColor: widget.backgroundColor ??
              (isDisabled ? DesignSystem.neutral200 : DesignSystem.secondaryGreen),
          foregroundColor: widget.foregroundColor ?? Colors.white,
          borderColor: Colors.transparent,
        );
      case TouchButtonVariant.outline:
        return _TouchButtonColors(
          backgroundColor: Colors.transparent,
          foregroundColor: widget.foregroundColor ??
              (isDisabled ? DesignSystem.textDisabled : DesignSystem.primaryBlue),
          borderColor: isDisabled ? DesignSystem.neutral300 : DesignSystem.primaryBlue,
        );
      case TouchButtonVariant.ghost:
        return _TouchButtonColors(
          backgroundColor: Colors.transparent,
          foregroundColor: widget.foregroundColor ??
              (isDisabled ? DesignSystem.textDisabled : DesignSystem.textPrimary),
          borderColor: Colors.transparent,
        );
    }
  }
}

/// Touch-friendly input field with proper sizing
class TouchTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;

  const TouchTextField({
    Key? key,
    this.label,
    this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: DesignSystem.labelLarge(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignSystem.spaceS),
        ],
        TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          style: DesignSystem.bodyMedium(context),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: enabled
                ? DesignSystem.getSurfaceColor(context)
                : DesignSystem.neutral100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
              borderSide: BorderSide(
                color: DesignSystem.getBorderColor(context),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
              borderSide: BorderSide(
                color: DesignSystem.getBorderColor(context),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
              borderSide: const BorderSide(
                color: DesignSystem.primaryBlue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
              borderSide: const BorderSide(
                color: DesignSystem.error,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: DesignSystem.spaceM,
              vertical: isMobile ? DesignSystem.spaceM : DesignSystem.spaceS,
            ),
          ),
        ),
      ],
    );
  }
}

/// Touch-friendly card with proper spacing and feedback
class TouchCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final bool enableFeedback;

  const TouchCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.enableFeedback = true,
  }) : super(key: key);

  @override
  State<TouchCard> createState() => _TouchCardState();
}

class _TouchCardState extends State<TouchCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

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

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _animationController.forward();
      if (widget.enableFeedback) {
        HapticFeedback.lightImpact();
      }
    }
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: widget.margin ?? 
                EdgeInsets.all(isMobile ? DesignSystem.spaceM : DesignSystem.spaceS),
            child: Material(
              color: widget.backgroundColor ?? DesignSystem.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(DesignSystem.radiusL),
              elevation: 2,
              child: InkWell(
                onTap: widget.onTap,
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                child: Container(
                  padding: widget.padding ?? 
                      EdgeInsets.all(isMobile ? DesignSystem.spaceL : DesignSystem.spaceM),
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Touch-friendly list tile with proper spacing
class TouchListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  const TouchListTile({
    Key? key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Container(
          constraints: BoxConstraints(
            minHeight: ResponsiveUtils.getTouchTargetSize(context),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? DesignSystem.spaceL : DesignSystem.spaceM,
            vertical: isMobile ? DesignSystem.spaceM : DesignSystem.spaceS,
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                SizedBox(width: isMobile ? DesignSystem.spaceL : DesignSystem.spaceM),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DefaultTextStyle(
                      style: DesignSystem.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.w500,
                        color: enabled ? null : DesignSystem.textDisabled,
                      ),
                      child: title,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      DefaultTextStyle(
                        style: DesignSystem.bodySmall(context).copyWith(
                          color: enabled ? DesignSystem.textSecondary : DesignSystem.textDisabled,
                        ),
                        child: subtitle!,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: isMobile ? DesignSystem.spaceL : DesignSystem.spaceM),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Data classes
class _TouchButtonSizing {
  final double height;
  final double minWidth;
  final double iconSize;
  final double spacing;
  final double borderRadius;
  final TextStyle textStyle;

  _TouchButtonSizing({
    required this.height,
    required this.minWidth,
    required this.iconSize,
    required this.spacing,
    required this.borderRadius,
    required this.textStyle,
  });
}

class _TouchButtonColors {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  _TouchButtonColors({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
  });
}

enum TouchButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
}

enum TouchButtonSize {
  small,
  medium,
  large,
}