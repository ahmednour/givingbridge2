import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';
import 'gb_loading_indicator.dart';

/// Collection of specialized skeleton widgets for different screen types
///
/// Usage:
/// ```dart
/// if (isLoading && donations.isEmpty) {
///   return GBDonationListSkeleton();
/// }
/// ```

/// Skeleton for donation/request card
class GBDonationCardSkeleton extends StatelessWidget {
  const GBDonationCardSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? DesignSystem.neutral800 : DesignSystem.neutral200;

    return GBShimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: DesignSystem.spaceM),
        padding: const EdgeInsets.all(DesignSystem.spaceM),
        decoration: BoxDecoration(
          color: DesignSystem.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          border: Border.all(
            color: isDark ? DesignSystem.neutral700 : DesignSystem.neutral300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(DesignSystem.radiusS),
              ),
            ),
            const SizedBox(height: DesignSystem.spaceM),

            // Title
            Container(
              height: 20,
              width: double.infinity,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: DesignSystem.spaceS),

            // Description lines
            Container(
              height: 14,
              width: double.infinity,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: DesignSystem.spaceXS),
            Container(
              height: 14,
              width: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: DesignSystem.spaceM),

            // Category and location
            Row(
              children: [
                Container(
                  height: 24,
                  width: 80,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                  ),
                ),
                const SizedBox(width: DesignSystem.spaceS),
                Container(
                  height: 24,
                  width: 100,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for donation/request list
class GBDonationListSkeleton extends StatelessWidget {
  final int itemCount;
  final EdgeInsets? padding;

  const GBDonationListSkeleton({
    Key? key,
    this.itemCount = 5,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding ?? const EdgeInsets.all(DesignSystem.spaceM),
      itemCount: itemCount,
      itemBuilder: (context, index) => const GBDonationCardSkeleton(),
    );
  }
}

/// Skeleton for dashboard stat card
class GBStatCardSkeleton extends StatelessWidget {
  const GBStatCardSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? DesignSystem.neutral800 : DesignSystem.neutral200;

    return GBShimmer(
      child: Container(
        padding: const EdgeInsets.all(DesignSystem.spaceL),
        decoration: BoxDecoration(
          color: DesignSystem.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          border: Border.all(
            color: isDark ? DesignSystem.neutral700 : DesignSystem.neutral300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(DesignSystem.radiusS),
              ),
            ),
            const SizedBox(height: DesignSystem.spaceM),

            // Value
            Container(
              height: 32,
              width: 80,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: DesignSystem.spaceS),

            // Label
            Container(
              height: 16,
              width: 120,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for dashboard stats grid
class GBStatsGridSkeleton extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;

  const GBStatsGridSkeleton({
    Key? key,
    this.itemCount = 4,
    this.crossAxisCount = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(DesignSystem.spaceM),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: DesignSystem.spaceM,
        mainAxisSpacing: DesignSystem.spaceM,
        childAspectRatio: 1.5,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const GBStatCardSkeleton(),
    );
  }
}

/// Skeleton for conversation list item
class GBConversationItemSkeleton extends StatelessWidget {
  const GBConversationItemSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? DesignSystem.neutral800 : DesignSystem.neutral200;

    return GBShimmer(
      child: Container(
        padding: const EdgeInsets.all(DesignSystem.spaceM),
        margin: const EdgeInsets.only(bottom: DesignSystem.spaceS),
        decoration: BoxDecoration(
          color: DesignSystem.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(DesignSystem.radiusS),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: baseColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: DesignSystem.spaceM),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Container(
                    height: 16,
                    width: 120,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: DesignSystem.spaceS),

                  // Message preview
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: DesignSystem.spaceS),

            // Time
            Container(
              height: 12,
              width: 40,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for conversation list
class GBConversationListSkeleton extends StatelessWidget {
  final int itemCount;

  const GBConversationListSkeleton({
    Key? key,
    this.itemCount = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(DesignSystem.spaceM),
      itemCount: itemCount,
      itemBuilder: (context, index) => const GBConversationItemSkeleton(),
    );
  }
}

/// Skeleton for dashboard overview
class GBDashboardSkeleton extends StatelessWidget {
  const GBDashboardSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignSystem.spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome header skeleton
          _buildHeaderSkeleton(context),
          const SizedBox(height: DesignSystem.spaceXL),

          // Stats grid
          GBStatsGridSkeleton(
            itemCount: 4,
            crossAxisCount: isDesktop ? 4 : 2,
          ),
          const SizedBox(height: DesignSystem.spaceXL),

          // Recent items section
          _buildSectionHeaderSkeleton(context),
          const SizedBox(height: DesignSystem.spaceM),

          // Recent items list
          ...List.generate(
            3,
            (index) => const GBDonationCardSkeleton(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? DesignSystem.neutral800 : DesignSystem.neutral200;

    return GBShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 28,
            width: 200,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: DesignSystem.spaceS),
          Container(
            height: 16,
            width: 150,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeaderSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? DesignSystem.neutral800 : DesignSystem.neutral200;

    return GBShimmer(
      child: Container(
        height: 24,
        width: 180,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

/// Skeleton for profile screen
class GBProfileSkeleton extends StatelessWidget {
  const GBProfileSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? DesignSystem.neutral800 : DesignSystem.neutral200;

    return GBShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignSystem.spaceL),
        child: Column(
          children: [
            // Avatar
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: baseColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: DesignSystem.spaceL),

            // Name
            Container(
              height: 24,
              width: 180,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: DesignSystem.spaceS),

            // Email
            Container(
              height: 16,
              width: 220,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: DesignSystem.spaceXL),

            // Profile fields
            ...List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: DesignSystem.spaceM),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for notification list
class GBNotificationListSkeleton extends StatelessWidget {
  final int itemCount;

  const GBNotificationListSkeleton({
    Key? key,
    this.itemCount = 6,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? DesignSystem.neutral800 : DesignSystem.neutral200;

    return ListView.separated(
      padding: const EdgeInsets.all(DesignSystem.spaceM),
      itemCount: itemCount,
      separatorBuilder: (context, index) =>
          const SizedBox(height: DesignSystem.spaceS),
      itemBuilder: (context, index) {
        return GBShimmer(
          child: Container(
            padding: const EdgeInsets.all(DesignSystem.spaceM),
            decoration: BoxDecoration(
              color: DesignSystem.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(DesignSystem.radiusS),
              border: Border.all(
                color:
                    isDark ? DesignSystem.neutral700 : DesignSystem.neutral300,
              ),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: baseColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: DesignSystem.spaceM),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: DesignSystem.spaceS),
                      Container(
                        height: 14,
                        width: 200,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
