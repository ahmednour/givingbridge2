import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';

/// Timeline Component for GivingBridge
///
/// A vertical timeline widget that displays chronological events with:
/// - Color-coded status indicators
/// - Event titles and descriptions
/// - Timestamps
/// - Connecting lines between events
/// - Custom icons for each event type
class GBTimeline extends StatelessWidget {
  /// List of timeline events
  final List<GBTimelineEvent> events;

  /// Spacing between events
  final double eventSpacing;

  /// Line thickness connecting events
  final double lineWidth;

  /// Show time on the right side
  final bool showTime;

  /// Compact mode (smaller spacing)
  final bool compact;

  const GBTimeline({
    Key? key,
    required this.events,
    this.eventSpacing = 24,
    this.lineWidth = 2,
    this.showTime = true,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        events.length,
        (index) => _buildTimelineItem(
          context,
          events[index],
          isFirst: index == 0,
          isLast: index == events.length - 1,
        ),
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, GBTimelineEvent event,
      {required bool isFirst, required bool isLast}) {
    final spacing = compact ? eventSpacing * 0.75 : eventSpacing;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator column
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Top line (hidden for first item)
                if (!isFirst)
                  Container(
                    width: lineWidth,
                    height: spacing / 2,
                    color: event.lineColor ?? DesignSystem.neutral300,
                  ),

                // Event indicator dot/icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: event.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: event.color,
                      width: 2,
                    ),
                  ),
                  child: event.icon != null
                      ? Icon(
                          event.icon,
                          size: 16,
                          color: event.color,
                        )
                      : Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: event.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                ),

                // Bottom line (hidden for last item)
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: lineWidth,
                      color: event.lineColor ?? DesignSystem.neutral300,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Event content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : spacing,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and time row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: DesignSystem.titleSmall(context).copyWith(
                                fontWeight: FontWeight.w600,
                                color: event.isActive
                                    ? DesignSystem.textPrimary
                                    : DesignSystem.textSecondary,
                              ),
                            ),
                            if (event.subtitle != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                event.subtitle!,
                                style: DesignSystem.bodySmall(context).copyWith(
                                  color: DesignSystem.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (showTime && event.timestamp != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          _formatTimestamp(event.timestamp!),
                          style: DesignSystem.bodySmall(context).copyWith(
                            color: DesignSystem.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Description
                  if (event.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      event.description!,
                      style: DesignSystem.bodyMedium(context).copyWith(
                        color: event.isActive
                            ? DesignSystem.textPrimary
                            : DesignSystem.textSecondary,
                      ),
                    ),
                  ],

                  // Custom widget
                  if (event.widget != null) ...[
                    const SizedBox(height: 8),
                    event.widget!,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 365) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
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

/// Timeline Event Model
class GBTimelineEvent {
  /// Event title
  final String title;

  /// Optional subtitle
  final String? subtitle;

  /// Event description
  final String? description;

  /// Event timestamp
  final DateTime? timestamp;

  /// Event color
  final Color color;

  /// Line color (connecting to next event)
  final Color? lineColor;

  /// Event icon
  final IconData? icon;

  /// Whether this is the current/active event
  final bool isActive;

  /// Custom widget to display below description
  final Widget? widget;

  const GBTimelineEvent({
    required this.title,
    this.subtitle,
    this.description,
    this.timestamp,
    required this.color,
    this.lineColor,
    this.icon,
    this.isActive = false,
    this.widget,
  });

  /// Factory for request lifecycle events
  factory GBTimelineEvent.requestCreated({
    required DateTime timestamp,
    String? message,
  }) {
    return GBTimelineEvent(
      title: 'Request Created',
      subtitle: 'Waiting for donor approval',
      description: message,
      timestamp: timestamp,
      color: DesignSystem.primaryBlue,
      icon: Icons.send,
    );
  }

  factory GBTimelineEvent.requestApproved({
    required DateTime timestamp,
    String? donorMessage,
  }) {
    return GBTimelineEvent(
      title: 'Request Approved',
      subtitle: 'Donor accepted your request',
      description: donorMessage,
      timestamp: timestamp,
      color: DesignSystem.success,
      icon: Icons.check_circle,
    );
  }

  factory GBTimelineEvent.requestDeclined({
    required DateTime timestamp,
    String? reason,
  }) {
    return GBTimelineEvent(
      title: 'Request Declined',
      subtitle: 'Donor declined your request',
      description: reason,
      timestamp: timestamp,
      color: DesignSystem.error,
      icon: Icons.cancel,
    );
  }

  factory GBTimelineEvent.donationInProgress({
    required DateTime timestamp,
  }) {
    return GBTimelineEvent(
      title: 'Donation In Progress',
      subtitle: 'Waiting for item delivery',
      timestamp: timestamp,
      color: DesignSystem.warning,
      icon: Icons.local_shipping,
      isActive: true,
    );
  }

  factory GBTimelineEvent.donationCompleted({
    required DateTime timestamp,
  }) {
    return GBTimelineEvent(
      title: 'Donation Completed',
      subtitle: 'Item received successfully',
      timestamp: timestamp,
      color: DesignSystem.success,
      icon: Icons.done_all,
    );
  }

  factory GBTimelineEvent.requestCancelled({
    required DateTime timestamp,
  }) {
    return GBTimelineEvent(
      title: 'Request Cancelled',
      subtitle: 'You cancelled this request',
      timestamp: timestamp,
      color: DesignSystem.neutral500,
      icon: Icons.close,
    );
  }
}

/// Usage Examples:
/// 
/// // Basic timeline
/// GBTimeline(
///   events: [
///     GBTimelineEvent.requestCreated(
///       timestamp: DateTime.now().subtract(Duration(days: 2)),
///       message: 'Need items for my family',
///     ),
///     GBTimelineEvent.requestApproved(
///       timestamp: DateTime.now().subtract(Duration(days: 1)),
///       donorMessage: 'Happy to help!',
///     ),
///     GBTimelineEvent.donationInProgress(
///       timestamp: DateTime.now(),
///     ),
///   ],
/// )
/// 
/// // Compact timeline
/// GBTimeline(
///   events: events,
///   compact: true,
///   showTime: false,
/// )
