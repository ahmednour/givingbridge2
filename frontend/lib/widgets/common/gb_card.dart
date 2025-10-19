import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';

/// Enhanced Card Component for GivingBridge
/// Features: Elevation levels, hover animations, gradient backgrounds, clickable
class GBCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Gradient? gradient;
  final int elevation;
  final bool showBorder;
  final Color? borderColor;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool hoverLift;
  final double? width;
  final double? height;

  const GBCard({
    Key? key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.gradient,
    this.elevation = 0,
    this.showBorder = true,
    this.borderColor,
    this.borderRadius = DesignSystem.radiusL,
    this.onTap,
    this.hoverLift = true,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<GBCard> createState() => _GBCardState();
}

class _GBCardState extends State<GBCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DesignSystem.shortDuration,
      vsync: this,
    );
    _elevationAnimation = Tween<double>(
      begin: 0,
      end: widget.hoverLift ? 4 : 0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: DesignSystem.defaultCurve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<BoxShadow> _getBoxShadow() {
    final baseElevation = widget.elevation;
    final hoverElevation = _isHovered && widget.hoverLift ? 4 : 0;
    final totalElevation = baseElevation + hoverElevation;

    switch (totalElevation) {
      case 0:
        return DesignSystem.elevationNone;
      case 1:
        return DesignSystem.elevation1;
      case 2:
        return DesignSystem.elevation2;
      case 3:
        return DesignSystem.elevation3;
      default:
        return DesignSystem.elevation4;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor =
        widget.backgroundColor ?? DesignSystem.getSurfaceColor(context);

    return MouseRegion(
      onEnter: (_) {
        if (widget.hoverLift || widget.onTap != null) {
          setState(() => _isHovered = true);
          _controller.forward();
        }
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -_elevationAnimation.value),
              child: AnimatedContainer(
                duration: DesignSystem.shortDuration,
                curve: DesignSystem.defaultCurve,
                width: widget.width,
                height: widget.height,
                padding:
                    widget.padding ?? const EdgeInsets.all(DesignSystem.spaceL),
                decoration: BoxDecoration(
                  color: widget.gradient == null ? bgColor : null,
                  gradient: widget.gradient,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: widget.showBorder
                      ? Border.all(
                          color: widget.borderColor ??
                              DesignSystem.getBorderColor(context),
                          width: 1.5,
                        )
                      : null,
                  boxShadow: _getBoxShadow(),
                ),
                child: child,
              ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

/// Stat Card for displaying dashboard statistics
class GBStatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final String? trend;
  final bool showCountUp;
  final VoidCallback? onTap;

  const GBStatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.trend,
    this.showCountUp = true,
    this.onTap,
  }) : super(key: key);

  @override
  State<GBStatCard> createState() => _GBStatCardState();
}

class _GBStatCardState extends State<GBStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _countAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Extract number from value string for animation
    final numberMatch = RegExp(r'\d+').firstMatch(widget.value);
    final targetNumber =
        numberMatch != null ? double.parse(numberMatch.group(0)!) : 0.0;

    _countAnimation = Tween<double>(
      begin: 0.0,
      end: targetNumber,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    if (widget.showCountUp) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GBCard(
      elevation: 1,
      onTap: widget.onTap,
      hoverLift: widget.onTap != null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(DesignSystem.spaceM),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.color.withOpacity(0.2),
                  widget.color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
            ),
            child: Icon(
              widget.icon,
              color: widget.color,
              size: DesignSystem.iconSizeLarge,
            ),
          ),

          const SizedBox(height: DesignSystem.spaceL),

          // Value with count-up animation
          if (widget.showCountUp && _countAnimation.value > 0)
            AnimatedBuilder(
              animation: _countAnimation,
              builder: (context, child) {
                return Text(
                  widget.value.replaceAll(
                      RegExp(r'\d+'), _countAnimation.value.toInt().toString()),
                  style: DesignSystem.displaySmall(context).copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                );
              },
            )
          else
            Text(
              widget.value,
              style: DesignSystem.displaySmall(context).copyWith(
                fontSize: 36,
                fontWeight: FontWeight.w800,
              ),
            ),

          const SizedBox(height: DesignSystem.spaceS),

          // Title
          Text(
            widget.title,
            style: DesignSystem.bodyMedium(context).copyWith(
              color: DesignSystem.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),

          // Subtitle or Trend
          if (widget.subtitle != null || widget.trend != null) ...[
            const SizedBox(height: DesignSystem.spaceS),
            if (widget.trend != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignSystem.spaceS,
                  vertical: DesignSystem.spaceXS,
                ),
                decoration: BoxDecoration(
                  color: DesignSystem.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.trending_up,
                      size: 14,
                      color: DesignSystem.success,
                    ),
                    const SizedBox(width: DesignSystem.spaceXS),
                    Text(
                      widget.trend!,
                      style: DesignSystem.labelSmall(context).copyWith(
                        color: DesignSystem.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              )
            else if (widget.subtitle != null)
              Text(
                widget.subtitle!,
                style: DesignSystem.bodySmall(context),
              ),
          ],
        ],
      ),
    );
  }
}

/// Donation/Request Card Component
class GBDonationCard extends StatelessWidget {
  final String title;
  final String description;
  final String category;
  final String? status;
  final String donorName;
  final String? location;
  final IconData categoryIcon;
  final VoidCallback? onTap;
  final VoidCallback? onMessage;
  final VoidCallback? onRequest;
  final List<Widget>? actions;

  const GBDonationCard({
    Key? key,
    required this.title,
    required this.description,
    required this.category,
    this.status,
    required this.donorName,
    this.location,
    required this.categoryIcon,
    this.onTap,
    this.onMessage,
    this.onRequest,
    this.actions,
  }) : super(key: key);

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'available':
        return DesignSystem.success;
      case 'pending':
        return DesignSystem.warning;
      case 'completed':
        return DesignSystem.info;
      case 'cancelled':
        return DesignSystem.error;
      default:
        return DesignSystem.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GBCard(
      elevation: 1,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      DesignSystem.secondaryGreen.withOpacity(0.2),
                      DesignSystem.secondaryGreen.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                ),
                child: Icon(
                  categoryIcon,
                  color: DesignSystem.secondaryGreen,
                  size: 32,
                ),
              ),

              const SizedBox(width: DesignSystem.spaceL),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: DesignSystem.titleMedium(context).copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: DesignSystem.spaceXS),
                    Text(
                      description,
                      style: DesignSystem.bodyMedium(context).copyWith(
                        color: DesignSystem.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: DesignSystem.spaceS),

                    // Tags
                    Wrap(
                      spacing: DesignSystem.spaceS,
                      runSpacing: DesignSystem.spaceS,
                      children: [
                        _buildChip(
                            category.toUpperCase(), DesignSystem.primaryBlue),
                        if (status != null)
                          _buildChip(
                              status!.toUpperCase(), _getStatusColor(status)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: DesignSystem.spaceL),

          // Footer
          Row(
            children: [
              // Donor info
              Expanded(
                child: Row(
                  children: [
                    if (location != null) ...[
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: DesignSystem.textSecondary,
                      ),
                      const SizedBox(width: DesignSystem.spaceXS),
                      Expanded(
                        child: Text(
                          location!,
                          style: DesignSystem.bodySmall(context),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ] else
                      Expanded(
                        child: Text(
                          'By $donorName',
                          style: DesignSystem.bodySmall(context),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),

              // Actions
              if (actions != null)
                ...actions!
              else ...[
                if (onMessage != null)
                  IconButton(
                    icon: const Icon(Icons.message_outlined),
                    onPressed: onMessage,
                    iconSize: DesignSystem.iconSizeSmall,
                    tooltip: 'Message donor',
                  ),
                if (onRequest != null)
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: onRequest,
                    iconSize: DesignSystem.iconSizeSmall,
                    color: DesignSystem.primaryBlue,
                    tooltip: 'Request donation',
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSystem.spaceS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(DesignSystem.radiusS),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
