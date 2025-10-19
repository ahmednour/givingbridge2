import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';
import 'gb_rating.dart';

/// Feedback Card Component for displaying ratings and reviews
///
/// Shows a complete review with:
/// - Reviewer name and avatar
/// - Star rating
/// - Review text/comment
/// - Timestamp
/// - Optional helpful/report actions
class GBFeedbackCard extends StatelessWidget {
  /// Name of the person who left the review
  final String reviewerName;

  /// Avatar URL of the reviewer
  final String? reviewerAvatarUrl;

  /// Star rating (0.0 to 5.0)
  final double rating;

  /// Review comment text
  final String? comment;

  /// When the review was posted
  final DateTime timestamp;

  /// Number of people who found this helpful
  final int? helpfulCount;

  /// Callback when "Helpful" button is tapped
  final VoidCallback? onHelpfulTap;

  /// Callback when "Report" button is tapped
  final VoidCallback? onReportTap;

  /// Show action buttons (helpful, report)
  final bool showActions;

  /// Compact mode (smaller padding, no actions)
  final bool compact;

  const GBFeedbackCard({
    Key? key,
    required this.reviewerName,
    required this.rating,
    required this.timestamp,
    this.reviewerAvatarUrl,
    this.comment,
    this.helpfulCount,
    this.onHelpfulTap,
    this.onReportTap,
    this.showActions = true,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.all(compact ? DesignSystem.spaceM : DesignSystem.spaceL),
      decoration: BoxDecoration(
        color: DesignSystem.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(DesignSystem.radiusL),
        border: Border.all(
          color: DesignSystem.getBorderColor(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, Rating, Date
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: compact ? 16 : 20,
                backgroundColor: DesignSystem.primaryBlue.withOpacity(0.1),
                backgroundImage: reviewerAvatarUrl != null
                    ? NetworkImage(reviewerAvatarUrl!)
                    : null,
                child: reviewerAvatarUrl == null
                    ? Icon(
                        Icons.person,
                        size: compact ? 16 : 20,
                        color: DesignSystem.primaryBlue,
                      )
                    : null,
              ),
              const SizedBox(width: DesignSystem.spaceM),

              // Name and Rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reviewerName,
                      style: DesignSystem.titleSmall(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GBRating(
                      rating: rating,
                      size: compact ? 14 : 16,
                      spacing: 2,
                    ),
                  ],
                ),
              ),

              // Timestamp
              Text(
                _formatTimestamp(timestamp),
                style: DesignSystem.bodySmall(context).copyWith(
                  color: DesignSystem.textSecondary,
                ),
              ),
            ],
          ),

          // Review Comment
          if (comment != null && comment!.isNotEmpty) ...[
            const SizedBox(height: DesignSystem.spaceM),
            Text(
              comment!,
              style: DesignSystem.bodyMedium(context),
            ),
          ],

          // Action Buttons
          if (showActions && !compact) ...[
            const SizedBox(height: DesignSystem.spaceM),
            Row(
              children: [
                // Helpful button
                if (onHelpfulTap != null)
                  TextButton.icon(
                    onPressed: onHelpfulTap,
                    icon: Icon(
                      Icons.thumb_up_outlined,
                      size: 16,
                      color: DesignSystem.textSecondary,
                    ),
                    label: Text(
                      helpfulCount != null && helpfulCount! > 0
                          ? 'Helpful ($helpfulCount)'
                          : 'Helpful',
                      style: DesignSystem.bodySmall(context).copyWith(
                        color: DesignSystem.textSecondary,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignSystem.spaceM,
                        vertical: DesignSystem.spaceS,
                      ),
                    ),
                  ),

                const SizedBox(width: DesignSystem.spaceS),

                // Report button
                if (onReportTap != null)
                  TextButton.icon(
                    onPressed: onReportTap,
                    icon: Icon(
                      Icons.flag_outlined,
                      size: 16,
                      color: DesignSystem.textSecondary,
                    ),
                    label: Text(
                      'Report',
                      style: DesignSystem.bodySmall(context).copyWith(
                        color: DesignSystem.textSecondary,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignSystem.spaceM,
                        vertical: DesignSystem.spaceS,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Rating Summary Component
///
/// Displays overall rating statistics with:
/// - Average rating and total count
/// - Star distribution breakdown
/// - Progress bars for each rating level
class GBRatingSummary extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // {5: 45, 4: 30, 3: 15, 2: 8, 1: 2}

  const GBRatingSummary({
    Key? key,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spaceL),
      decoration: BoxDecoration(
        color: DesignSystem.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(DesignSystem.radiusL),
        border: Border.all(
          color: DesignSystem.getBorderColor(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rating Overview',
            style: DesignSystem.titleMedium(context).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DesignSystem.spaceL),

          // Average Rating Display
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: DesignSystem.headlineLarge(context).copyWith(
                  fontWeight: FontWeight.w700,
                  color: DesignSystem.warning,
                ),
              ),
              const SizedBox(width: DesignSystem.spaceS),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GBRating(
                      rating: averageRating,
                      size: 18,
                      spacing: 2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalReviews reviews',
                      style: DesignSystem.bodySmall(context).copyWith(
                        color: DesignSystem.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: DesignSystem.spaceL),
          const Divider(height: 1),
          const SizedBox(height: DesignSystem.spaceL),

          // Rating Distribution
          ...List.generate(5, (index) {
            final stars = 5 - index; // 5, 4, 3, 2, 1
            final count = ratingDistribution[stars] ?? 0;
            final percentage = totalReviews > 0 ? count / totalReviews : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: DesignSystem.spaceM),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    child: Text(
                      '$stars',
                      style: DesignSystem.bodySmall(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: DesignSystem.spaceS),
                  Icon(
                    Icons.star,
                    size: 14,
                    color: DesignSystem.warning,
                  ),
                  const SizedBox(width: DesignSystem.spaceM),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: DesignSystem.neutral100,
                        color: DesignSystem.warning,
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: DesignSystem.spaceM),
                  SizedBox(
                    width: 40,
                    child: Text(
                      count.toString(),
                      style: DesignSystem.bodySmall(context).copyWith(
                        color: DesignSystem.textSecondary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Usage Examples:
/// 
/// // Single review
/// GBFeedbackCard(
///   reviewerName: 'John Doe',
///   rating: 4.5,
///   comment: 'Great donor, items were exactly as described!',
///   timestamp: DateTime.now().subtract(Duration(days: 2)),
///   helpfulCount: 5,
///   onHelpfulTap: () => print('Helpful tapped'),
///   onReportTap: () => print('Report tapped'),
/// )
/// 
/// // Rating summary
/// GBRatingSummary(
///   averageRating: 4.7,
///   totalReviews: 100,
///   ratingDistribution: {5: 70, 4: 20, 3: 5, 2: 3, 1: 2},
/// )
