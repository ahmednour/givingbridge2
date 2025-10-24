import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/design_system.dart';
import '../../core/theme/web_theme.dart';

/// Modern Web-Style Card with Hover Effects
/// Designed to look like cards in modern web apps (shadcn/ui, MUI, etc.)
class WebCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool enableHover;
  final bool enableShadow;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const WebCard({
    Key? key,
    required this.child,
    this.padding,
    this.onTap,
    this.enableHover = true,
    this.enableShadow = true,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<WebCard> createState() => _WebCardState();
}

class _WebCardState extends State<WebCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final decoration = _isHovered && widget.enableHover
        ? WebTheme.cardHoverDecoration(context).copyWith(
            color:
                widget.backgroundColor ?? DesignSystem.getSurfaceColor(context),
          )
        : WebTheme.cardDecoration(context).copyWith(
            color:
                widget.backgroundColor ?? DesignSystem.getSurfaceColor(context),
            boxShadow: widget.enableShadow ? WebTheme.cardShadow : null,
          );

    Widget card = Container(
      width: widget.width,
      height: widget.height,
      decoration: decoration,
      child: Padding(
        padding: widget.padding ?? const EdgeInsets.all(DesignSystem.spaceL),
        child: widget.child,
      ),
    );

    if (widget.onTap != null) {
      card = MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: card,
        ),
      );
    } else if (widget.enableHover) {
      card = MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: card,
      );
    }

    return card.animate(target: _isHovered ? 1 : 0).moveY(
          begin: 0,
          end: -4,
          duration: WebTheme.hoverDuration,
          curve: WebTheme.webCurve,
        );
  }
}
