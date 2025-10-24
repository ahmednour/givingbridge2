import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';

/// Standardized loading indicator widget
///
/// Usage:
/// ```dart
/// GBLoadingIndicator() // Default centered spinner
/// GBLoadingIndicator.inline() // Small inline spinner
/// GBLoadingIndicator.overlay() // Full screen overlay
/// GBLoadingIndicator.linear() // Linear progress bar
/// ```
class GBLoadingIndicator extends StatelessWidget {
  final GBLoadingType type;
  final String? message;
  final double? size;
  final Color? color;
  final double? strokeWidth;

  const GBLoadingIndicator({
    Key? key,
    this.type = GBLoadingType.centered,
    this.message,
    this.size,
    this.color,
    this.strokeWidth,
  }) : super(key: key);

  const GBLoadingIndicator.inline({
    Key? key,
    this.message,
    this.size = 20,
    this.color,
    this.strokeWidth = 2,
  })  : type = GBLoadingType.inline,
        super(key: key);

  const GBLoadingIndicator.overlay({
    Key? key,
    this.message,
    this.size,
    this.color,
    this.strokeWidth,
  })  : type = GBLoadingType.overlay,
        super(key: key);

  const GBLoadingIndicator.linear({
    Key? key,
    this.message,
    this.color,
  })  : type = GBLoadingType.linear,
        size = null,
        strokeWidth = null,
        super(key: key);

  const GBLoadingIndicator.card({
    Key? key,
    this.message,
    this.size,
    this.color,
    this.strokeWidth,
  })  : type = GBLoadingType.card,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case GBLoadingType.centered:
        return _buildCentered(context);
      case GBLoadingType.inline:
        return _buildInline(context);
      case GBLoadingType.overlay:
        return _buildOverlay(context);
      case GBLoadingType.linear:
        return _buildLinear(context);
      case GBLoadingType.card:
        return _buildCard(context);
    }
  }

  Widget _buildCentered(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size ?? 40,
            height: size ?? 40,
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth ?? 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? DesignSystem.primaryBlue,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: DesignSystem.spaceM),
            Text(
              message!,
              style: DesignSystem.bodyMedium(context).copyWith(
                color:
                    isDark ? DesignSystem.neutral400 : DesignSystem.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInline(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size ?? 20,
          height: size ?? 20,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth ?? 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? DesignSystem.primaryBlue,
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(width: DesignSystem.spaceS),
          Text(
            message!,
            style: DesignSystem.bodySmall(context).copyWith(
              color: color ?? DesignSystem.primaryBlue,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(DesignSystem.spaceXL),
          decoration: BoxDecoration(
            color: DesignSystem.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(DesignSystem.radiusL),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: size ?? 48,
                height: size ?? 48,
                child: CircularProgressIndicator(
                  strokeWidth: strokeWidth ?? 4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    color ?? DesignSystem.primaryBlue,
                  ),
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: DesignSystem.spaceL),
                Text(
                  message!,
                  style: DesignSystem.bodyMedium(context),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinear(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? DesignSystem.primaryBlue,
          ),
          backgroundColor: DesignSystem.neutral200,
        ),
        if (message != null) ...[
          const SizedBox(height: DesignSystem.spaceM),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: DesignSystem.spaceM),
            child: Text(
              message!,
              style: DesignSystem.bodySmall(context),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(DesignSystem.spaceL),
      decoration: BoxDecoration(
        color: DesignSystem.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        border: Border.all(
          color: isDark ? DesignSystem.neutral700 : DesignSystem.neutral300,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: size ?? 24,
            height: size ?? 24,
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth ?? 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? DesignSystem.primaryBlue,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(width: DesignSystem.spaceM),
            Expanded(
              child: Text(
                message!,
                style: DesignSystem.bodyMedium(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum GBLoadingType {
  centered,
  inline,
  overlay,
  linear,
  card,
}

/// Shimmer loading effect for skeleton screens
class GBShimmer extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final Color? baseColor;
  final Color? highlightColor;

  const GBShimmer({
    Key? key,
    required this.child,
    this.enabled = true,
    this.baseColor,
    this.highlightColor,
  }) : super(key: key);

  @override
  State<GBShimmer> createState() => _GBShimmerState();
}

class _GBShimmerState extends State<GBShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = widget.baseColor ??
        (isDark ? DesignSystem.neutral800 : DesignSystem.neutral200);
    final highlightColor = widget.highlightColor ??
        (isDark ? DesignSystem.neutral700 : DesignSystem.neutral100);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                _animation.value - 1,
                _animation.value,
                _animation.value + 1,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Skeleton loading card
class GBSkeletonCard extends StatelessWidget {
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;

  const GBSkeletonCard({
    Key? key,
    this.height,
    this.width,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GBShimmer(
      child: Container(
        height: height ?? 100,
        width: width,
        decoration: BoxDecoration(
          color: isDark ? DesignSystem.neutral800 : DesignSystem.neutral200,
          borderRadius:
              borderRadius ?? BorderRadius.circular(DesignSystem.radiusM),
        ),
      ),
    );
  }
}

/// Skeleton loading list
class GBSkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsets? padding;

  const GBSkeletonList({
    Key? key,
    this.itemCount = 5,
    this.itemHeight = 100,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding ?? const EdgeInsets.all(DesignSystem.spaceM),
      itemCount: itemCount,
      separatorBuilder: (context, index) =>
          const SizedBox(height: DesignSystem.spaceM),
      itemBuilder: (context, index) {
        return GBSkeletonCard(height: itemHeight);
      },
    );
  }
}
