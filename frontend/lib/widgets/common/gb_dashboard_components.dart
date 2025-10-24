import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';
import 'dart:math' as math;

/// Enhanced stat card with animation and trend indicator
class GBStatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final double? trend; // Percentage change (positive or negative)
  final VoidCallback? onTap;
  final bool isLoading;

  const GBStatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.trend,
    this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<GBStatCard> createState() => _GBStatCardState();
}

class _GBStatCardState extends State<GBStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(DesignSystem.spaceL),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered
                          ? widget.color.withOpacity(0.2)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: _isHovered ? 20 : 10,
                      offset: Offset(0, _isHovered ? 8 : 4),
                    ),
                  ],
                ),
                child: widget.isLoading
                    ? _buildSkeleton()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.all(DesignSystem.spaceM),
                                decoration: BoxDecoration(
                                  color: widget.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                      DesignSystem.radiusM),
                                ),
                                child: Icon(
                                  widget.icon,
                                  color: widget.color,
                                  size: 28,
                                ),
                              ),
                              const Spacer(),
                              if (widget.trend != null)
                                _buildTrendIndicator(widget.trend!),
                            ],
                          ),
                          const SizedBox(height: DesignSystem.spaceL),
                          Text(
                            widget.value,
                            style: DesignSystem.displayMedium(context).copyWith(
                              fontWeight: FontWeight.w700,
                              color: DesignSystem.neutral900,
                            ),
                          ),
                          const SizedBox(height: DesignSystem.spaceXS),
                          Text(
                            widget.title,
                            style: DesignSystem.bodyMedium(context).copyWith(
                              color: DesignSystem.neutral600,
                            ),
                          ),
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: DesignSystem.spaceXS),
                            Text(
                              widget.subtitle!,
                              style: DesignSystem.bodySmall(context).copyWith(
                                color: DesignSystem.neutral500,
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTrendIndicator(double trend) {
    final isPositive = trend > 0;
    final color = isPositive ? DesignSystem.success : DesignSystem.error;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSystem.spaceS,
        vertical: DesignSystem.spaceXS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignSystem.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: color,
            size: 16,
          ),
          const SizedBox(width: DesignSystem.spaceXXS),
          Text(
            '${trend.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: DesignSystem.neutral200,
            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          ),
        ),
        const SizedBox(height: DesignSystem.spaceL),
        Container(
          width: 100,
          height: 32,
          decoration: BoxDecoration(
            color: DesignSystem.neutral200,
            borderRadius: BorderRadius.circular(DesignSystem.radiusS),
          ),
        ),
        const SizedBox(height: DesignSystem.spaceS),
        Container(
          width: 140,
          height: 16,
          decoration: BoxDecoration(
            color: DesignSystem.neutral200,
            borderRadius: BorderRadius.circular(DesignSystem.radiusS),
          ),
        ),
      ],
    );
  }
}

/// Quick action card with icon and label
class GBQuickActionCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const GBQuickActionCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  State<GBQuickActionCard> createState() => _GBQuickActionCardState();
}

class _GBQuickActionCardState extends State<GBQuickActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(DesignSystem.spaceL),
          decoration: BoxDecoration(
            gradient: _isHovered
                ? LinearGradient(
                    colors: [
                      widget.color.withOpacity(0.1),
                      widget.color.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: _isHovered ? null : Colors.white,
            borderRadius: BorderRadius.circular(DesignSystem.radiusL),
            border: Border.all(
              color: _isHovered
                  ? widget.color.withOpacity(0.3)
                  : DesignSystem.neutral200,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(DesignSystem.spaceL),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(_isHovered ? 0.2 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: 32,
                ),
              ),
              const SizedBox(height: DesignSystem.spaceM),
              Text(
                widget.title,
                style: DesignSystem.titleMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: DesignSystem.neutral900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignSystem.spaceXS),
              Text(
                widget.description,
                style: DesignSystem.bodySmall(context).copyWith(
                  color: DesignSystem.neutral600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Activity timeline item
class GBActivityItem extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color color;
  final bool isLast;

  const GBActivityItem({
    Key? key,
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.color,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignSystem.spaceS),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                margin:
                    const EdgeInsets.symmetric(vertical: DesignSystem.spaceXS),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.3), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: DesignSystem.spaceM),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: DesignSystem.titleSmall(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: DesignSystem.spaceXXS),
              Text(
                description,
                style: DesignSystem.bodyMedium(context).copyWith(
                  color: DesignSystem.neutral600,
                ),
              ),
              const SizedBox(height: DesignSystem.spaceXXS),
              Text(
                time,
                style: DesignSystem.bodySmall(context).copyWith(
                  color: DesignSystem.neutral500,
                ),
              ),
              if (!isLast) const SizedBox(height: DesignSystem.spaceL),
            ],
          ),
        ),
      ],
    );
  }
}

/// Progress ring indicator
class GBProgressRing extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final String label;
  final Color color;
  final double size;

  const GBProgressRing({
    Key? key,
    required this.progress,
    required this.label,
    required this.color,
    this.size = 120,
  }) : super(key: key);

  @override
  State<GBProgressRing> createState() => _GBProgressRingState();
}

class _GBProgressRingState extends State<GBProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _ProgressRingPainter(
              progress: _animation.value,
              color: widget.color,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(_animation.value * 100).toInt()}%',
                    style: DesignSystem.headlineSmall(context).copyWith(
                      fontWeight: FontWeight.w700,
                      color: widget.color,
                    ),
                  ),
                  Text(
                    widget.label,
                    style: DesignSystem.bodySmall(context).copyWith(
                      color: DesignSystem.neutral600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ProgressRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background circle
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
