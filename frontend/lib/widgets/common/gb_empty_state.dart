import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';
import 'gb_button.dart';

/// Enhanced Empty State Component for GivingBridge
/// Provides meaningful feedback when no data is available
class GBEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;
  final double? iconSize;

  const GBEmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.iconSize,
  }) : super(key: key);

  /// Preset for no donations
  factory GBEmptyState.noDonations({VoidCallback? onCreate}) {
    return GBEmptyState(
      icon: Icons.volunteer_activism_outlined,
      title: 'No donations yet',
      message: 'Start making a difference by creating your first donation',
      actionLabel: 'Create Donation',
      onAction: onCreate,
      iconColor: DesignSystem.accentPink,
    );
  }

  /// Preset for no requests
  factory GBEmptyState.noRequests({VoidCallback? onBrowse}) {
    return GBEmptyState(
      icon: Icons.inbox_outlined,
      title: 'No requests yet',
      message: 'Browse available donations and request items you need',
      actionLabel: 'Browse Donations',
      onAction: onBrowse,
      iconColor: DesignSystem.primaryBlue,
    );
  }

  /// Preset for no search results
  factory GBEmptyState.noSearchResults() {
    return const GBEmptyState(
      icon: Icons.search_off,
      title: 'No results found',
      message: 'Try adjusting your filters or search terms',
      iconColor: DesignSystem.textSecondary,
    );
  }

  /// Preset for no data available
  factory GBEmptyState.noData({VoidCallback? onRefresh}) {
    return GBEmptyState(
      icon: Icons.inbox_outlined,
      title: 'No data available',
      message: 'Check back later for updates',
      actionLabel: onRefresh != null ? 'Refresh' : null,
      onAction: onRefresh,
      iconColor: DesignSystem.textSecondary,
    );
  }

  /// Preset for offline state
  factory GBEmptyState.offline({VoidCallback? onRetry}) {
    return GBEmptyState(
      icon: Icons.wifi_off,
      title: 'You\'re offline',
      message: 'Please check your internet connection and try again',
      actionLabel: 'Retry',
      onAction: onRetry,
      iconColor: DesignSystem.warning,
    );
  }

  /// Preset for error state
  factory GBEmptyState.error({VoidCallback? onRetry}) {
    return GBEmptyState(
      icon: Icons.error_outline,
      title: 'Something went wrong',
      message: 'We couldn\'t load the data. Please try again',
      actionLabel: 'Retry',
      onAction: onRetry,
      iconColor: DesignSystem.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? DesignSystem.primaryBlue;
    final effectiveIconSize = iconSize ?? 120.0;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(DesignSystem.spaceXXL),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Icon Container
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: effectiveIconSize,
                height: effectiveIconSize,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      effectiveIconColor.withOpacity(0.2),
                      effectiveIconColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(effectiveIconSize / 2),
                ),
                child: Icon(
                  icon,
                  size: effectiveIconSize * 0.5,
                  color: effectiveIconColor,
                ),
              ),
            ),

            const SizedBox(height: DesignSystem.spaceXL),

            // Title
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Text(
                title,
                style: DesignSystem.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: DesignSystem.spaceS),

            // Message
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Text(
                message,
                style: DesignSystem.bodyMedium(context).copyWith(
                  color: DesignSystem.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Action Button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: DesignSystem.spaceXL),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: GBPrimaryButton(
                  text: actionLabel!,
                  onPressed: onAction,
                  size: GBButtonSize.large,
                  leftIcon: const Icon(Icons.add_circle_outline),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading skeleton component for better perceived performance
class GBSkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const GBSkeletonLoader({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<GBSkeletonLoader> createState() => _GBSkeletonLoaderState();
}

class _GBSkeletonLoaderState extends State<GBSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ??
                BorderRadius.circular(DesignSystem.radiusM),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                _animation.value - 0.5,
                _animation.value,
                _animation.value + 0.5,
              ],
              colors: const [
                DesignSystem.neutral200,
                DesignSystem.neutral100,
                DesignSystem.neutral200,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton card for loading states
class GBSkeletonCard extends StatelessWidget {
  const GBSkeletonCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spaceL),
      decoration: BoxDecoration(
        color: DesignSystem.surfaceLight,
        borderRadius: BorderRadius.circular(DesignSystem.radiusL),
        border: Border.all(color: DesignSystem.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const GBSkeletonLoader(
                width: 64,
                height: 64,
                borderRadius:
                    BorderRadius.all(Radius.circular(DesignSystem.radiusM)),
              ),
              const SizedBox(width: DesignSystem.spaceL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    GBSkeletonLoader(width: double.infinity, height: 20),
                    SizedBox(height: DesignSystem.spaceS),
                    GBSkeletonLoader(width: 200, height: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.spaceL),
          const GBSkeletonLoader(width: 100, height: 24),
        ],
      ),
    );
  }
}
