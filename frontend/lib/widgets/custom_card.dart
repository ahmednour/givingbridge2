import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'custom_button.dart';

enum CardVariant { filled, outlined, elevated }

class CustomCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final CardVariant variant;
  final VoidCallback? onTap;
  final bool isInteractive;
  final Color? backgroundColor;
  final double borderRadius;

  const CustomCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.variant = CardVariant.filled,
    this.onTap,
    this.isInteractive = false,
    this.backgroundColor,
    this.borderRadius = AppTheme.radiusMedium,
  }) : super(key: key);

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    if (widget.isInteractive || widget.onTap != null) {
      setState(() => _isHovered = isHovered);
      if (isHovered) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: widget.margin,
      child: MouseRegion(
        onEnter: (_) => _handleHover(true),
        onExit: (_) => _handleHover(false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: widget.width,
                  height: widget.height,
                  decoration: _getDecoration(theme, isDark),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: widget.padding ??
                            const EdgeInsets.all(AppTheme.spacing16),
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  BoxDecoration _getDecoration(ThemeData theme, bool isDark) {
    Color backgroundColor;
    Border? border;
    List<BoxShadow>? boxShadow;

    if (widget.backgroundColor != null) {
      backgroundColor = widget.backgroundColor!;
    } else {
      backgroundColor = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
    }

    switch (widget.variant) {
      case CardVariant.filled:
        if (_isHovered) {
          boxShadow = AppTheme.mediumShadow;
        } else {
          boxShadow = AppTheme.softShadow;
        }
        break;

      case CardVariant.outlined:
        border = Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          width: 1,
        );
        if (_isHovered) {
          boxShadow = AppTheme.softShadow;
        }
        break;

      case CardVariant.elevated:
        boxShadow = _isHovered ? AppTheme.mediumShadow : AppTheme.softShadow;
        break;
    }

    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      border: border,
      boxShadow: boxShadow,
    );
  }
}

// Specialized card widgets
class DonationCard extends StatelessWidget {
  final String title;
  final String description;
  final String? imageUrl;
  final String? category;
  final String? location;
  final String donorName;
  final VoidCallback? onTap;
  final VoidCallback? onRequest;
  final bool showRequestButton;

  const DonationCard({
    Key? key,
    required this.title,
    required this.description,
    this.imageUrl,
    this.category,
    this.location,
    required this.donorName,
    this.onTap,
    this.onRequest,
    this.showRequestButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CustomCard(
      isInteractive: true,
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          if (imageUrl != null)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusMedium),
                  topRight: Radius.circular(AppTheme.radiusMedium),
                ),
                color: isDark
                    ? AppTheme.darkSurfaceVariant
                    : AppTheme.lightSurfaceVariant,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusMedium),
                  topRight: Radius.circular(AppTheme.radiusMedium),
                ),
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.darkSurfaceVariant
                            : AppTheme.lightSurfaceVariant,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: AppTheme.lightTextTertiary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Content section
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category badge
                if (category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing8,
                      vertical: AppTheme.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Text(
                      category!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                if (category != null) const SizedBox(height: AppTheme.spacing8),

                // Title
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: AppTheme.spacing8),

                // Description
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.lightTextSecondary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: AppTheme.spacing16),

                // Footer
                Row(
                  children: [
                    // Donor info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Donated by',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isDark
                                  ? AppTheme.darkTextTertiary
                                  : AppTheme.lightTextTertiary,
                            ),
                          ),
                          Text(
                            donorName,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (location != null) ...[
                            const SizedBox(height: AppTheme.spacing4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: isDark
                                      ? AppTheme.darkTextTertiary
                                      : AppTheme.lightTextTertiary,
                                ),
                                const SizedBox(width: AppTheme.spacing4),
                                Expanded(
                                  child: Text(
                                    location!,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: isDark
                                          ? AppTheme.darkTextTertiary
                                          : AppTheme.lightTextTertiary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Request button
                    if (showRequestButton && onRequest != null)
                      PrimaryButton(
                        text: 'Request',
                        size: ButtonSize.small,
                        onPressed: onRequest,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final String? subtitle;
  final Widget? trailing;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.subtitle,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CustomCard(
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            decoration: BoxDecoration(
              color: (iconColor ?? AppTheme.primaryColor).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppTheme.primaryColor,
              size: 24,
            ),
          ),

          const SizedBox(width: AppTheme.spacing16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.lightTextSecondary,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? AppTheme.darkTextTertiary
                          : AppTheme.lightTextTertiary,
                    ),
                  ),
              ],
            ),
          ),

          // Trailing widget
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
