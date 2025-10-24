import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/design_system.dart';
import '../../core/theme/web_theme.dart';

/// Modern Web-Style Button with Hover Effects
/// Variants: primary, secondary, outline, ghost, danger
class WebButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final WebButtonVariant variant;
  final WebButtonSize size;
  final double? width;
  final bool fullWidth;

  const WebButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = WebButtonVariant.primary,
    this.size = WebButtonSize.medium,
    this.width,
    this.fullWidth = false,
  }) : super(key: key);

  @override
  State<WebButton> createState() => _WebButtonState();
}

class _WebButtonState extends State<WebButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _getColors(isDark);
    final sizing = _getSizing();

    return MouseRegion(
      cursor: widget.onPressed != null && !widget.isLoading
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) {
        setState(() {
          _isHovered = false;
          _isPressed = false;
        });
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed != null && !widget.isLoading
            ? widget.onPressed
            : null,
        child: AnimatedContainer(
          duration: WebTheme.hoverDuration,
          curve: WebTheme.webCurve,
          width: widget.fullWidth ? double.infinity : widget.width,
          height: sizing.height,
          decoration: BoxDecoration(
            color: _getBackgroundColor(colors),
            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
            border: widget.variant == WebButtonVariant.outline
                ? Border.all(
                    color: _getBorderColor(colors),
                    width: 1,
                  )
                : null,
            boxShadow: _isHovered && widget.variant == WebButtonVariant.primary
                ? WebTheme.cardShadow
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
                        colors.foreground,
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
                          color: colors.foreground,
                        ),
                        SizedBox(width: sizing.gap),
                      ],
                      Text(
                        widget.text,
                        style: sizing.textStyle.copyWith(
                          color: colors.foreground,
                        ),
                      ),
                    ],
                  ),
          ),
        ).animate(target: _isPressed ? 1 : 0).scale(
              begin: const Offset(1, 1),
              end: const Offset(0.98, 0.98),
              duration: 100.ms,
            ),
      ),
    );
  }

  _ButtonColors _getColors(bool isDark) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    switch (widget.variant) {
      case WebButtonVariant.primary:
        return _ButtonColors(
          background:
              isDisabled ? DesignSystem.neutral300 : DesignSystem.primaryBlue,
          backgroundHover: DesignSystem.primaryBlueDark,
          foreground: Colors.white,
          border: Colors.transparent,
        );

      case WebButtonVariant.secondary:
        return _ButtonColors(
          background: isDisabled
              ? DesignSystem.neutral200
              : DesignSystem.secondaryGreen,
          backgroundHover: DesignSystem.secondaryGreenDark,
          foreground: Colors.white,
          border: Colors.transparent,
        );

      case WebButtonVariant.outline:
        return _ButtonColors(
          background: Colors.transparent,
          backgroundHover:
              isDark ? DesignSystem.neutral800 : DesignSystem.neutral100,
          foreground:
              isDark ? DesignSystem.textPrimaryDark : DesignSystem.textPrimary,
          border: DesignSystem.getBorderColor(context),
        );

      case WebButtonVariant.ghost:
        return _ButtonColors(
          background: Colors.transparent,
          backgroundHover:
              isDark ? DesignSystem.neutral800 : DesignSystem.neutral100,
          foreground:
              isDark ? DesignSystem.textPrimaryDark : DesignSystem.textPrimary,
          border: Colors.transparent,
        );

      case WebButtonVariant.danger:
        return _ButtonColors(
          background: isDisabled ? DesignSystem.neutral300 : DesignSystem.error,
          backgroundHover: const Color(0xFFDC2626),
          foreground: Colors.white,
          border: Colors.transparent,
        );
    }
  }

  Color _getBackgroundColor(_ButtonColors colors) {
    if (widget.onPressed == null || widget.isLoading) {
      return colors.background;
    }
    return _isHovered ? colors.backgroundHover : colors.background;
  }

  Color _getBorderColor(_ButtonColors colors) {
    return _isHovered ? DesignSystem.primaryBlue : colors.border;
  }

  _ButtonSizing _getSizing() {
    switch (widget.size) {
      case WebButtonSize.small:
        return _ButtonSizing(
          height: 36,
          iconSize: 16,
          gap: 6,
          textStyle: DesignSystem.labelMedium(context),
        );

      case WebButtonSize.medium:
        return _ButtonSizing(
          height: 44,
          iconSize: 20,
          gap: 8,
          textStyle: DesignSystem.labelLarge(context),
        );

      case WebButtonSize.large:
        return _ButtonSizing(
          height: 52,
          iconSize: 24,
          gap: 10,
          textStyle: DesignSystem.titleMedium(context),
        );
    }
  }
}

class _ButtonColors {
  final Color background;
  final Color backgroundHover;
  final Color foreground;
  final Color border;

  _ButtonColors({
    required this.background,
    required this.backgroundHover,
    required this.foreground,
    required this.border,
  });
}

class _ButtonSizing {
  final double height;
  final double iconSize;
  final double gap;
  final TextStyle textStyle;

  _ButtonSizing({
    required this.height,
    required this.iconSize,
    required this.gap,
    required this.textStyle,
  });
}

enum WebButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  danger,
}

enum WebButtonSize {
  small,
  medium,
  large,
}
