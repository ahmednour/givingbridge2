import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/common/gb_card.dart';
import '../widgets/common/gb_button.dart';
import '../widgets/custom_card.dart';
import '../l10n/app_localizations.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data for notifications
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'type': 'donation_request',
      'title': 'New donation request',
      'message': 'Someone requested your donated books',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
      'isRead': false,
      'icon': Icons.handshake,
      'color': AppTheme.primaryColor,
    },
    {
      'id': '2',
      'type': 'donation_approved',
      'title': 'Donation approved!',
      'message': 'Your request for winter clothes has been approved',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': false,
      'icon': Icons.check_circle,
      'color': AppTheme.successColor,
    },
    {
      'id': '3',
      'type': 'reminder',
      'title': 'Pickup reminder',
      'message': 'Don\'t forget to pick up your donated items today',
      'timestamp': DateTime.now().subtract(const Duration(hours: 6)),
      'isRead': true,
      'icon': Icons.schedule,
      'color': AppTheme.warningColor,
    },
    {
      'id': '4',
      'type': 'donation_completed',
      'title': 'Donation completed',
      'message': 'Thank you for your donation! It has reached the recipient.',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': true,
      'icon': Icons.celebration,
      'color': AppTheme.secondaryColor,
    },
    {
      'id': '5',
      'type': 'new_donation',
      'title': 'New donation available',
      'message': 'Electronics donation available in your area',
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      'isRead': true,
      'icon': Icons.inventory,
      'color': AppTheme.infoColor,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;

    return Scaffold(
      body: Column(
        children: [
          // Header with actions
          _buildHeader(context, theme, isDark),

          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurfaceColor : AppTheme.surfaceColor,
              border: Border(
                bottom: BorderSide(
                  color:
                      isDark ? AppTheme.darkBorderColor : AppTheme.borderColor,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: isDark
                  ? AppTheme.darkTextSecondaryColor
                  : AppTheme.textSecondaryColor,
              indicatorColor: AppTheme.primaryColor,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)!.all),
                      const SizedBox(width: AppTheme.spacingXS),
                      _buildNotificationBadge(_notifications.length),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)!.unread),
                      const SizedBox(width: AppTheme.spacingXS),
                      _buildNotificationBadge(_getUnreadCount()),
                    ],
                  ),
                ),
                Tab(text: AppLocalizations.of(context)!.settings),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationsList(
                    context, theme, isDark, isDesktop, _notifications),
                _buildNotificationsList(context, theme, isDark, isDesktop,
                    _getUnreadNotifications()),
                _buildNotificationSettings(context, theme, isDark, isDesktop),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceColor : AppTheme.surfaceColor,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.notifications,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_getUnreadCount() > 0)
                  Text(
                    l10n.unreadNotifications(_getUnreadCount()),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppTheme.darkTextSecondaryColor
                          : AppTheme.textSecondaryColor,
                    ),
                  ),
              ],
            ),
          ),

          // Mark all as read
          if (_getUnreadCount() > 0)
            GBButton(
              text: l10n.markAllRead,
              size: GBButtonSize.small,
              variant: GBButtonVariant.ghost,
              onPressed: _markAllAsRead,
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationBadge(int count) {
    if (count == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6.0,
        vertical: 2.0,
      ),
      decoration: BoxDecoration(
        color: AppTheme.errorColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildNotificationsList(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    bool isDesktop,
    List<Map<String, dynamic>> notifications,
  ) {
    if (notifications.isEmpty) {
      return _buildEmptyState(context, theme, isDark);
    }

    return RefreshIndicator(
      onRefresh: _refreshNotifications,
      child: ListView.builder(
        padding:
            EdgeInsets.all(isDesktop ? AppTheme.spacingL : AppTheme.spacingM),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildNotificationCard(notification, theme, isDark),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: isDark
                ? AppTheme.textDisabledColor
                : AppTheme.textDisabledColor,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            l10n.noNotifications,
            style: theme.textTheme.titleMedium?.copyWith(
              color: isDark
                  ? AppTheme.darkTextSecondaryColor
                  : AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            l10n.allCaughtUp,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppTheme.textDisabledColor
                  : AppTheme.textDisabledColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
      Map<String, dynamic> notification, ThemeData theme, bool isDark) {
    final isRead = notification['isRead'] as bool;

    return GBCard(
      onTap: () => _markAsRead(notification['id']),
      backgroundColor: !isRead
          ? (isDark
              ? AppTheme.primaryColor.withOpacity(0.05)
              : AppTheme.primaryColor.withOpacity(0.03))
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (notification['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Icon(
              notification['icon'],
              color: notification['color'],
              size: 24,
            ),
          ),

          const SizedBox(width: 12.0),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification['title'],
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight:
                              isRead ? FontWeight.w500 : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Text(
                  notification['message'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppTheme.darkTextSecondaryColor
                        : AppTheme.textSecondaryColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  _formatTimestamp(notification['timestamp']),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark
                        ? AppTheme.textDisabledColor
                        : AppTheme.textDisabledColor,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              size: 20,
              color: isDark
                  ? AppTheme.textDisabledColor
                  : AppTheme.textDisabledColor,
            ),
            itemBuilder: (context) => [
              if (!isRead)
                PopupMenuItem(
                  value: 'mark_read',
                  child: Text(AppLocalizations.of(context)!.markAsRead),
                ),
              PopupMenuItem(
                value: 'delete',
                child: Text(AppLocalizations.of(context)!.delete),
              ),
            ],
            onSelected: (value) {
              if (value == 'mark_read') {
                _markAsRead(notification['id']);
              } else if (value == 'delete') {
                _deleteNotification(notification['id']);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding:
          EdgeInsets.all(isDesktop ? AppTheme.spacingXL : AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.notificationSettings,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: AppTheme.spacingL),

          // Push Notifications
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.pushNotifications,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                _buildSettingToggle(
                  l10n.donationRequests,
                  l10n.notifyDonationRequests,
                  true,
                  theme,
                  isDark,
                ),
                _buildSettingToggle(
                  l10n.newDonations,
                  l10n.notifyNewDonations,
                  true,
                  theme,
                  isDark,
                ),
                _buildSettingToggle(
                  l10n.statusUpdates,
                  l10n.notifyStatusUpdates,
                  true,
                  theme,
                  isDark,
                ),
                _buildSettingToggle(
                  l10n.reminders,
                  l10n.notifyReminders,
                  false,
                  theme,
                  isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingL),

          // Email Notifications
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.emailNotifications,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                _buildSettingToggle(
                  l10n.weeklySummary,
                  l10n.receiveWeeklySummary,
                  true,
                  theme,
                  isDark,
                ),
                _buildSettingToggle(
                  l10n.importantUpdates,
                  l10n.receiveImportantUpdates,
                  true,
                  theme,
                  isDark,
                ),
                _buildSettingToggle(
                  l10n.marketingEmails,
                  l10n.receiveMarketingEmails,
                  false,
                  theme,
                  isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingXL),

          // Clear all notifications
          GBButton(
            text: l10n.clearAllNotifications,
            fullWidth: true,
            leftIcon: const Icon(Icons.clear_all, size: 20),
            onPressed: _clearAllNotifications,
            variant: GBButtonVariant.danger,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingToggle(
    String title,
    String subtitle,
    bool value,
    ThemeData theme,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppTheme.darkTextSecondaryColor
                        : AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              // TODO: Implement setting toggle
              final l10n = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('${newValue ? l10n.enabled : l10n.disabled} $title'),
                ),
              );
            },
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  int _getUnreadCount() {
    return _notifications.where((n) => !(n['isRead'] as bool)).length;
  }

  List<Map<String, dynamic>> _getUnreadNotifications() {
    return _notifications.where((n) => !(n['isRead'] as bool)).toList();
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final notification =
          _notifications.firstWhere((n) => n['id'] == notificationId);
      notification['isRead'] = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.allNotificationsRead),
      ),
    );
  }

  void _deleteNotification(String notificationId) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == notificationId);
    });

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.notificationDeleted),
      ),
    );
  }

  void _clearAllNotifications() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAllNotifications),
        content: Text(l10n.clearAllConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _notifications.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.allNotificationsCleared),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text(l10n.clearAll),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshNotifications() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.notificationsRefreshed),
        ),
      );
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    final l10n = AppLocalizations.of(context)!;

    if (difference.inMinutes < 1) {
      return l10n.justNow;
    } else if (difference.inHours < 1) {
      return l10n.minutesAgo(difference.inMinutes);
    } else if (difference.inDays < 1) {
      return l10n.hoursAgo(difference.inHours);
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
