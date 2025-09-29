import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

enum CardVariant {
  primary,
  secondary,
  outlined,
  elevated,
  filled
}

enum CardSize {
  small,
  medium,
  large
}

class AppCard extends StatefulWidget {
  final Widget? child;
  final CardVariant variant;
  final CardSize size;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool showShadow;
  final bool isSelected;
  final bool isHoverable;

  // Stat card properties
  final String? title;
  final String? value;
  final IconData? icon;
  final Color? iconColor;

  const AppCard({
    Key? key,
    this.child,
    this.variant = CardVariant.outlined,
    this.size = CardSize.medium,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderColor,
    this.showShadow = false,
    this.isSelected = false,
    this.isHoverable = true,
    this.title,
    this.value,
    this.icon,
    this.iconColor,
  }) : assert(child != null || (title != null && value != null)),
       super(key: key);

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _elevationAnimation = Tween<double>(
      begin: 0,
      end: 4,
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

  EdgeInsetsGeometry _getPadding() {
    if (widget.padding != null) return widget.padding!;

    switch (widget.size) {
      case CardSize.small:
        return const EdgeInsets.all(AppTheme.spacingM);
      case CardSize.medium:
        return const EdgeInsets.all(AppTheme.spacingL);
      case CardSize.large:
        return const EdgeInsets.all(AppTheme.spacingXL);
    }
  }

  Color _getBackgroundColor() {
    if (widget.backgroundColor != null) return widget.backgroundColor!;

    if (widget.isSelected) {
      return AppTheme.primaryColor.withValues(alpha: 0.1);
    }

    switch (widget.variant) {
      case CardVariant.primary:
        return AppTheme.primaryColor;
      case CardVariant.secondary:
        return AppTheme.secondaryColor;
      case CardVariant.outlined:
      case CardVariant.elevated:
        return AppTheme.surfaceColor;
      case CardVariant.filled:
        return AppTheme.dividerColor;
    }
  }

  Color _getBorderColor() {
    if (widget.borderColor != null) return widget.borderColor!;

    if (widget.isSelected) {
      return AppTheme.primaryColor;
    }

    switch (widget.variant) {
      case CardVariant.outlined:
        return _isHovered ? AppTheme.primaryColor : AppTheme.borderColor;
      case CardVariant.primary:
      case CardVariant.secondary:
      case CardVariant.elevated:
      case CardVariant.filled:
        return Colors.transparent;
    }
  }

  List<BoxShadow>? _getBoxShadow() {
    if (widget.variant == CardVariant.elevated || widget.showShadow) {
      if (_isHovered && widget.isHoverable) {
        return AppTheme.shadowMD;
      }
      return AppTheme.shadowSM;
    }
    return null;
  }

  void _handleHover(bool isHovered) {
    if (!widget.isHoverable) return;

    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  Widget _buildChild() {
    if (widget.child != null) {
      return widget.child!;
    }

    // Build stat card layout
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (widget.icon != null) ...[
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: (widget.iconColor ?? AppTheme.primaryColor).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Icon(
                  widget.icon!,
                  color: widget.iconColor ?? AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.title != null)
                    Text(
                      widget.title!,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  if (widget.value != null)
                    Text(
                      widget.value!,
                      style: AppTheme.headingMedium,
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      child: MouseRegion(
        onEnter: (_) => _handleHover(true),
        onExit: (_) => _handleHover(false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _elevationAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  color: _getBackgroundColor(),
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  border: Border.all(
                    color: _getBorderColor(),
                    width: widget.variant == CardVariant.outlined ? 1 : 0,
                  ),
                  boxShadow: _getBoxShadow(),
                ),
                padding: _getPadding(),
                child: _buildChild(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class AppCardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  const AppCardHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.titleStyle,
    this.subtitleStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: titleStyle ?? AppTheme.headingSmall,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppTheme.spacingXS),
                Text(
                  subtitle!,
                  style: subtitleStyle ?? AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppTheme.spacingM),
          trailing!,
        ],
      ],
    );
  }
}

class AppCardFooter extends StatelessWidget {
  final List<Widget> actions;
  final MainAxisAlignment alignment;

  const AppCardFooter({
    Key? key,
    required this.actions,
    this.alignment = MainAxisAlignment.end,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: actions
          .map((action) => Padding(
                padding: const EdgeInsets.only(left: AppTheme.spacingS),
                child: action,
              ))
          .toList(),
    );
  }
}