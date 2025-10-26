import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/design_system.dart';
import '../widgets/common/gb_button.dart';
import '../widgets/common/gb_notification_badge.dart';
import '../widgets/common/gb_notification_card.dart';
import '../widgets/common/web_card.dart';
import '../l10n/app_localizations.dart';
import '../providers/backend_notification_provider.dart';
import '../providers/notification_preference_provider.dart';
import '../services/backend_notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late BackendNotificationProvider _notificationProvider;
  late NotificationPreferenceProvider _preferenceProvider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _notificationProvider =
        Provider.of<BackendNotificationProvider>(context, listen: false);
    _preferenceProvider =
        Provider.of<NotificationPreferenceProvider>(context, listen: false);
    _notificationProvider.initialize();
    _preferenceProvider.loadPreferences();
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
              color: DesignSystem.getSurfaceColor(context),
              border: Border(
                bottom: BorderSide(
                  color: DesignSystem.getBorderColor(context),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: DesignSystem.primaryBlue,
              unselectedLabelColor: DesignSystem.textSecondary,
              indicatorColor: DesignSystem.primaryBlue,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)!.all),
                      const SizedBox(width: DesignSystem.spaceXS),
                      Consumer<BackendNotificationProvider>(
                        builder: (context, provider, child) {
                          return _buildNotificationBadge(
                              provider.notifications.length);
                        },
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)!.unread),
                      const SizedBox(width: DesignSystem.spaceXS),
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
            child: Consumer<BackendNotificationProvider>(
              builder: (context, provider, child) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNotificationsList(context, theme, isDark, isDesktop,
                        provider.notifications),
                    _buildNotificationsList(context, theme, isDark, isDesktop,
                        provider.unreadNotifications),
                    _buildNotificationSettings(
                        context, theme, isDark, isDesktop),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spaceM),
      decoration: BoxDecoration(
        color: DesignSystem.getSurfaceColor(context),
        border: Border(
          bottom: BorderSide(
            color: DesignSystem.getBorderColor(context),
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
                      color: DesignSystem.textSecondary,
                    ),
                  ),
              ],
            ),
          ),

          // Mark all as read
          if (_getUnreadCount() > 0)
            GBButton(
              text: l10n.markAllAsRead,
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

    return GBNotificationBadge.small(
      count: count,
      showPulse: count > 0 && _tabController.index == 1, // Pulse on unread tab
    );
  }

  Widget _buildNotificationsList(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    bool isDesktop,
    List<BackendNotification> notifications,
  ) {
    if (notifications.isEmpty) {
      return _buildEmptyState(context, theme, isDark);
    }

    return RefreshIndicator(
      onRefresh: _refreshNotifications,
      child: ListView.builder(
        padding: EdgeInsets.all(
            isDesktop ? DesignSystem.spaceL : DesignSystem.spaceM),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: DesignSystem.spaceM),
            child: _buildEnhancedNotificationCard(notification),
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
            color: DesignSystem.neutral400,
          ),
          const SizedBox(height: DesignSystem.spaceM),
          Text(
            l10n.noNotifications,
            style: theme.textTheme.titleMedium?.copyWith(
              color: DesignSystem.textSecondary,
            ),
          ),
          const SizedBox(height: DesignSystem.spaceS),
          Text(
            l10n.allCaughtUp,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: DesignSystem.neutral400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedNotificationCard(BackendNotification notification) {
    return GBNotificationCard(
      title: notification.title,
      message: notification.message,
      timestamp: notification.createdAt,
      isRead: notification.isRead,
      type: _mapNotificationType(notification.type),
      onTap: () => _handleNotificationTap(notification),
      onMarkAsRead: () => _markAsRead(notification.id),
      onDelete: () => _deleteNotification(notification.id),
      enableSwipeToDelete: true,
      showActions: true,
    );
  }

  GBNotificationType _mapNotificationType(String type) {
    switch (type) {
      case 'donation_request':
        return GBNotificationType.donationRequest;
      case 'donation_approved':
        return GBNotificationType.donationApproved;
      case 'new_donation':
        return GBNotificationType.newDonation;
      case 'reminder':
        return GBNotificationType.reminder;
      case 'celebration':
        return GBNotificationType.celebration;
      case 'message':
        return GBNotificationType.message;
      case 'system':
        return GBNotificationType.system;
      default:
        return GBNotificationType.system;
    }
  }

  void _handleNotificationTap(BackendNotification notification) {
    _markAsRead(notification.id);
    // Navigate based on notification type
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening: ${notification.title}'),
      ),
    );
  }

  Widget _buildNotificationSettings(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: EdgeInsets.all(
          isDesktop ? DesignSystem.spaceXL : DesignSystem.spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.notificationSettings,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: DesignSystem.spaceL),

          // Push Notifications
          WebCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.pushNotifications,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: DesignSystem.spaceM),
                _buildSettingToggle(
                  l10n.donationRequests,
                  l10n.notifyDonationRequests,
                  'pushDonationRequest',
                  true,
                  theme,
                  isDark,
                ),
                _buildSettingToggle(
                  l10n.newDonations,
                  l10n.notifyNewDonations,
                  'pushNewMessage',
                  true,
                  theme,
                  isDark,
                ),
                _buildSettingToggle(
                  l10n.statusUpdates,
                  l10n.notifyStatusUpdates,
                  'pushRequestUpdate',
                  true,
                  theme,
                  isDark,
                ),
                _buildSettingToggle(
                  l10n.reminders,
                  l10n.notifyReminders,
                  'pushDonationUpdate',
                  false,
                  theme,
                  isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: DesignSystem.spaceL),

          // Email Notifications
          WebCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.emailNotifications,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: DesignSystem.spaceM),
                _buildSettingToggle(
                  l10n.weeklySummary,
                  l10n.receiveWeeklySummary,
                  'emailDonationRequest',
                  true,
                  theme,
                  isDark,
                ),
                _buildSettingToggle(
                  l10n.importantUpdates,
                  l10n.receiveImportantUpdates,
                  'emailRequestUpdate',
                  true,
                  theme,
                  isDark,
                ),
                _buildSettingToggle(
                  l10n.marketingEmails,
                  l10n.receiveMarketingEmails,
                  'emailDonationUpdate',
                  false,
                  theme,
                  isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: DesignSystem.spaceXL),

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
    String preferenceKey,
    bool value,
    ThemeData theme,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignSystem.spaceM),
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
                    color: DesignSystem.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) async {
              // Update the preference
              final success = await _preferenceProvider.updatePreference(
                  preferenceKey, newValue);

              if (success && mounted) {
                final l10n = AppLocalizations.of(context)!;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${newValue ? l10n.enabled : l10n.disabled} $title'),
                  ),
                );
              } else if (!success && mounted) {
                final l10n = AppLocalizations.of(context)!;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.failedToUpdateSetting),
                    backgroundColor: DesignSystem.error,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  int _getUnreadCount() {
    return _notificationProvider.unreadCount;
  }

  void _markAsRead(int notificationId) {
    _notificationProvider.markAsRead(notificationId);
  }

  void _markAllAsRead() {
    _notificationProvider.markAllAsRead();

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.allNotificationsRead),
      ),
    );
  }

  void _deleteNotification(int notificationId) {
    _notificationProvider.deleteNotification(notificationId);

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
                // Clear all notifications using provider
                _notificationProvider.deleteAllNotifications();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.allNotificationsCleared),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.error,
            ),
            child: Text(l10n.clearAll),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshNotifications() async {
    await _notificationProvider.refresh();

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.notificationsRefreshed),
        ),
      );
    }
  }
}
