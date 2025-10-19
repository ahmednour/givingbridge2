import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';

/// Notification Card Component
///
/// A standardized card for displaying individual notifications
/// with support for different types, states, and actions.
///
/// Features:
/// - Multiple notification types (donation, request, message, system)
/// - Read/unread states with visual indicators
/// - Swipe-to-delete functionality
/// - Action buttons (mark as read, delete, view)
/// - Timestamp formatting
/// - Icon and color coding
/// - Dark mode support
///
/// Usage:
/// ```dart
/// GBNotificationCard(
///   title: 'New Donation Request',
///   message: 'Someone requested your books',
///   timestamp: DateTime.now(),
///   isRead: false,
///   type: GBNotificationType.donationRequest,
///   onTap: () => {},
///   onMarkAsRead: () => {},
///   onDelete: () => {},
/// )
/// ```
class GBNotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final GBNotificationType type;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;
  final bool enableSwipeToDelete;
  final bool showActions;

  const GBNotificationCard({
    Key? key,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.type = GBNotificationType.system,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
    this.enableSwipeToDelete = true,
    this.showActions = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = _getNotificationConfig();

    final cardContent = InkWell(
      onTap: onTap ?? onMarkAsRead,
      borderRadius: BorderRadius.circular(DesignSystem.radiusM),
      child: Container(
        padding: const EdgeInsets.all(DesignSystem.spaceM),
        decoration: BoxDecoration(
          color: _getBackgroundColor(context, isDark),
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          border: Border.all(
            color: isRead
                ? DesignSystem.getBorderColor(context)
                : config.color.withOpacity(0.2),
            width: isRead ? 1 : 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: config.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignSystem.radiusM),
              ),
              child: Icon(
                config.icon,
                color: config.color,
                size: 24,
              ),
            ),

            const SizedBox(width: DesignSystem.spaceM),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with unread indicator
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: DesignSystem.titleSmall(context).copyWith(
                            fontWeight:
                                isRead ? FontWeight.w500 : FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isRead) ...[
                        const SizedBox(width: DesignSystem.spaceS),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: config.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: DesignSystem.spaceXS),

                  // Message
                  Text(
                    message,
                    style: DesignSystem.bodyMedium(context).copyWith(
                      color: isDark
                          ? DesignSystem.textSecondaryDark
                          : DesignSystem.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: DesignSystem.spaceS),

                  // Timestamp
                  Text(
                    _formatTimestamp(context, timestamp),
                    style: DesignSystem.labelSmall(context).copyWith(
                      color: DesignSystem.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // Actions Menu
            if (showActions)
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  size: 20,
                  color: DesignSystem.textTertiary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                ),
                itemBuilder: (context) => [
                  if (!isRead && onMarkAsRead != null)
                    PopupMenuItem(
                      value: 'mark_read',
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 18,
                            color: DesignSystem.success,
                          ),
                          const SizedBox(width: DesignSystem.spaceS),
                          const Text('Mark as read'),
                        ],
                      ),
                    ),
                  if (onTap != null)
                    PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(
                            Icons.open_in_new,
                            size: 18,
                            color: DesignSystem.primaryBlue,
                          ),
                          const SizedBox(width: DesignSystem.spaceS),
                          const Text('View details'),
                        ],
                      ),
                    ),
                  if (onDelete != null)
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: DesignSystem.error,
                          ),
                          const SizedBox(width: DesignSystem.spaceS),
                          const Text('Delete'),
                        ],
                      ),
                    ),
                ],
                onSelected: (value) {
                  if (value == 'mark_read') {
                    onMarkAsRead?.call();
                  } else if (value == 'view') {
                    onTap?.call();
                  } else if (value == 'delete') {
                    onDelete?.call();
                  }
                },
              ),
          ],
        ),
      ),
    );

    // Wrap with Dismissible for swipe-to-delete
    if (enableSwipeToDelete && onDelete != null) {
      return Dismissible(
        key: Key('notification_${timestamp.millisecondsSinceEpoch}'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: DesignSystem.spaceL),
          decoration: BoxDecoration(
            color: DesignSystem.error,
            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          ),
          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 24,
          ),
        ),
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Notification'),
              content: const Text(
                'Are you sure you want to delete this notification?',
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusM),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.error,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) {
          onDelete?.call();
        },
        child: cardContent,
      );
    }

    return cardContent;
  }

  Color _getBackgroundColor(BuildContext context, bool isDark) {
    if (isRead) {
      return isDark ? DesignSystem.surfaceDark : DesignSystem.surfaceLight;
    }
    // Unread notifications have subtle highlight
    final config = _getNotificationConfig();
    return isDark
        ? config.color.withOpacity(0.08)
        : config.color.withOpacity(0.04);
  }

  _NotificationConfig _getNotificationConfig() {
    switch (type) {
      case GBNotificationType.donationRequest:
        return _NotificationConfig(
          icon: Icons.handshake,
          color: DesignSystem.primaryBlue,
        );
      case GBNotificationType.donationApproved:
        return _NotificationConfig(
          icon: Icons.check_circle,
          color: DesignSystem.success,
        );
      case GBNotificationType.newDonation:
        return _NotificationConfig(
          icon: Icons.inventory,
          color: DesignSystem.secondaryGreen,
        );
      case GBNotificationType.message:
        return _NotificationConfig(
          icon: Icons.message,
          color: DesignSystem.accentPurple,
        );
      case GBNotificationType.reminder:
        return _NotificationConfig(
          icon: Icons.schedule,
          color: DesignSystem.warning,
        );
      case GBNotificationType.system:
        return _NotificationConfig(
          icon: Icons.info,
          color: DesignSystem.info,
        );
      case GBNotificationType.celebration:
        return _NotificationConfig(
          icon: Icons.celebration,
          color: DesignSystem.accentPink,
        );
    }
  }

  String _formatTimestamp(BuildContext context, DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

class _NotificationConfig {
  final IconData icon;
  final Color color;

  _NotificationConfig({
    required this.icon,
    required this.color,
  });
}

enum GBNotificationType {
  donationRequest,
  donationApproved,
  newDonation,
  message,
  reminder,
  system,
  celebration,
}
