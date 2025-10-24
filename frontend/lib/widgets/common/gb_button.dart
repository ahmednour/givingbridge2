import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';

/// Enhanced Button Component for GivingBridge
/// Features: Ripple animation, loading states, icons, accessibility
enum GBButtonVariant { primary, secondary, outline, ghost, danger, success }

enum GBButtonSize { small, medium, large }

class GBButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final GBButtonVariant variant;
  final GBButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final double? width;
  final bool fullWidth;

  const GBButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.variant = GBButtonVariant.primary,
    this.size = GBButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.leftIcon,
    this.rightIcon,
    this.width,
    this.fullWidth = false,
  }) : super(key: key);

  @override
  State<GBButton> createState() => _GBButtonState();
}

class _GBButtonState extends State<GBButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DesignSystem.shortDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: DesignSystem.emphasizedCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isEnabled =>
      !widget.isDisabled && !widget.isLoading && widget.onPressed != null;

  Color _getBackgroundColor() {
    if (!_isEnabled) {
      return DesignSystem.neutral300;
    }

    final baseColor = _getVariantColor();

    if (_isPressed) {
      return _darkenColor(baseColor, 0.2);
    } else if (_isHovered) {
      return _darkenColor(baseColor, 0.1);
    }

    return baseColor;
  }

  Color _getVariantColor() {
    switch (widget.variant) {
      case GBButtonVariant.primary:
        return DesignSystem.primaryBlue;
      case GBButtonVariant.secondary:
        return DesignSystem.secondaryGreen;
      case GBButtonVariant.danger:
        return DesignSystem.error;
      case GBButtonVariant.success:
        return DesignSystem.success;
      case GBButtonVariant.outline:
      case GBButtonVariant.ghost:
        return _isHovered || _isPressed
            ? DesignSystem.primaryBlue.withOpacity(0.1)
            : Colors.transparent;
    }
  }

  Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  Color _getTextColor() {
    if (!_isEnabled) {
      return DesignSystem.textDisabled;
    }

    switch (widget.variant) {
      case GBButtonVariant.primary:
      case GBButtonVariant.secondary:
      case GBButtonVariant.danger:
      case GBButtonVariant.success:
        return Colors.white;
      case GBButtonVariant.outline:
      case GBButtonVariant.ghost:
        return DesignSystem.textPrimary;
    }
  }

  Border? _getBorder() {
    if (widget.variant == GBButtonVariant.outline) {
      return Border.all(
        color: _isEnabled ? DesignSystem.primaryBlue : DesignSystem.border,
        width: _isHovered ? 2 : 1.5,
      );
    }
    return null;
  }

  List<BoxShadow>? _getShadow() {
    if (!_isEnabled || widget.variant == GBButtonVariant.ghost) {
      return null;
    }

    if (widget.variant == GBButtonVariant.outline) {
      return _isHovered ? DesignSystem.elevation1 : null;
    }

    return _isHovered ? DesignSystem.elevation3 : DesignSystem.elevation2;
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case GBButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: DesignSystem.spaceL,
          vertical: DesignSystem.spaceS,
        );
      case GBButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: DesignSystem.spaceXL,
          vertical: DesignSystem.spaceM,
        );
      case GBButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 20,
        );
    }
  }

  double _getHeight() {
    switch (widget.size) {
      case GBButtonSize.small:
        return 44; // Increased from 36 for better touch targets
      case GBButtonSize.medium:
        return 48;
      case GBButtonSize.large:
        return 56;
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case GBButtonSize.small:
        return 14;
      case GBButtonSize.medium:
        return 16;
      case GBButtonSize.large:
        return 18;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case GBButtonSize.small:
        return DesignSystem.iconSizeSmall;
      case GBButtonSize.medium:
        return DesignSystem.iconSizeMedium;
      case GBButtonSize.large:
        return DesignSystem.iconSizeLarge;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onPressed != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: _buildButton(context),
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    return Semantics(
      button: true,
      enabled: _isEnabled,
      label: widget.text,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: _isEnabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
        child: GestureDetector(
          onTapDown: (_) {
            if (_isEnabled) {
              setState(() => _isPressed = true);
              _controller.forward();
            }
          },
          onTapUp: (_) {
            if (_isEnabled) {
              setState(() => _isPressed = false);
              _controller.reverse();
            }
          },
          onTapCancel: () {
            if (_isEnabled) {
              setState(() => _isPressed = false);
              _controller.reverse();
            }
          },
          onTap: _isEnabled ? widget.onPressed : null,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedContainer(
              duration: DesignSystem.shortDuration,
              curve: DesignSystem.defaultCurve,
              width: widget.fullWidth ? double.infinity : widget.width,
              height: _getHeight(),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                border: _getBorder(),
                boxShadow: _getShadow(),
              ),
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: _getPadding(),
                  child: Row(
                    mainAxisSize:
                        widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.leftIcon != null && !widget.isLoading) ...[
                        IconTheme(
                          data: IconThemeData(
                            color: _getTextColor(),
                            size: _getIconSize(),
                          ),
                          child: widget.leftIcon!,
                        ),
                        const SizedBox(width: DesignSystem.spaceS),
                      ],
                      if (widget.isLoading) ...[
                        SizedBox(
                          width: _getIconSize(),
                          height: _getIconSize(),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(_getTextColor()),
                          ),
                        ),
                        const SizedBox(width: DesignSystem.spaceS),
                      ],
                      Flexible(
                        child: Text(
                          widget.text,
                          style: TextStyle(
                            fontSize: _getFontSize(),
                            fontWeight: FontWeight.w600,
                            color: _getTextColor(),
                            height: 1.2,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.rightIcon != null && !widget.isLoading) ...[
                        const SizedBox(width: DesignSystem.spaceS),
                        IconTheme(
                          data: IconThemeData(
                            color: _getTextColor(),
                            size: _getIconSize(),
                          ),
                          child: widget.rightIcon!,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Convenience constructors for common button types
class GBPrimaryButton extends GBButton {
  const GBPrimaryButton({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    GBButtonSize size = GBButtonSize.medium,
    bool isLoading = false,
    Widget? leftIcon,
    Widget? rightIcon,
    double? width,
    bool fullWidth = false,
  }) : super(
          key: key,
          text: text,
          onPressed: onPressed,
          variant: GBButtonVariant.primary,
          size: size,
          isLoading: isLoading,
          leftIcon: leftIcon,
          rightIcon: rightIcon,
          width: width,
          fullWidth: fullWidth,
        );
}

class GBSecondaryButton extends GBButton {
  const GBSecondaryButton({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    GBButtonSize size = GBButtonSize.medium,
    bool isLoading = false,
    Widget? leftIcon,
    Widget? rightIcon,
    double? width,
    bool fullWidth = false,
  }) : super(
          key: key,
          text: text,
          onPressed: onPressed,
          variant: GBButtonVariant.secondary,
          size: size,
          isLoading: isLoading,
          leftIcon: leftIcon,
          rightIcon: rightIcon,
          width: width,
          fullWidth: fullWidth,
        );
}

class GBOutlineButton extends GBButton {
  const GBOutlineButton({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    GBButtonSize size = GBButtonSize.medium,
    bool isLoading = false,
    Widget? leftIcon,
    Widget? rightIcon,
    double? width,
    bool fullWidth = false,
  }) : super(
          key: key,
          text: text,
          onPressed: onPressed,
          variant: GBButtonVariant.outline,
          size: size,
          isLoading: isLoading,
          leftIcon: leftIcon,
          rightIcon: rightIcon,
          width: width,
          fullWidth: fullWidth,
        );
}
