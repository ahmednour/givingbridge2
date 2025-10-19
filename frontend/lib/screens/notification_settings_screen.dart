import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/notification_provider.dart';
import '../l10n/app_localizations.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize notification settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationSettings),
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.textPrimaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.manageYourNotifications,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Customize which notifications you want to receive',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.spacingXL),

                // All Notifications Toggle
                _buildSectionHeader(l10n.allNotifications, theme),
                const SizedBox(height: AppTheme.spacingM),
                _buildNotificationTile(
                  title: l10n.turnOnAllNotifications,
                  subtitle: 'Enable or disable all notifications at once',
                  icon: Icons.notifications_active,
                  value: notificationProvider.allNotificationsEnabled,
                  onChanged: notificationProvider.toggleAllNotifications,
                  theme: theme,
                  isDark: isDark,
                ),

                const SizedBox(height: AppTheme.spacingXL),

                // Individual Notification Settings
                _buildSectionHeader('Individual Settings', theme),
                const SizedBox(height: AppTheme.spacingM),

                // Push Notifications
                _buildNotificationTile(
                  title: l10n.pushNotifications,
                  subtitle: l10n.receiveDonationNotifications,
                  icon: Icons.phone_android,
                  value: notificationProvider.pushNotifications,
                  onChanged: notificationProvider.updatePushNotifications,
                  theme: theme,
                  isDark: isDark,
                ),

                // Email Notifications
                _buildNotificationTile(
                  title: l10n.emailNotifications,
                  subtitle: l10n.receiveEmailUpdates,
                  icon: Icons.email_outlined,
                  value: notificationProvider.emailNotifications,
                  onChanged: notificationProvider.updateEmailNotifications,
                  theme: theme,
                  isDark: isDark,
                ),

                // Donation Requests
                _buildNotificationTile(
                  title: l10n.donationRequests,
                  subtitle: l10n.notifyOnNewRequests,
                  icon: Icons.request_page_outlined,
                  value: notificationProvider.donationRequests,
                  onChanged: notificationProvider.updateDonationRequests,
                  theme: theme,
                  isDark: isDark,
                ),

                // Donation Approvals
                _buildNotificationTile(
                  title: l10n.donationApprovals,
                  subtitle: l10n.notifyOnApprovals,
                  icon: Icons.check_circle_outline,
                  value: notificationProvider.donationApprovals,
                  onChanged: notificationProvider.updateDonationApprovals,
                  theme: theme,
                  isDark: isDark,
                ),

                // Messages
                _buildNotificationTile(
                  title: l10n.messages,
                  subtitle: l10n.notifyOnNewMessages,
                  icon: Icons.message_outlined,
                  value: notificationProvider.messages,
                  onChanged: notificationProvider.updateMessages,
                  theme: theme,
                  isDark: isDark,
                ),

                // System Updates
                _buildNotificationTile(
                  title: l10n.systemUpdates,
                  subtitle: l10n.notifyOnSystemUpdates,
                  icon: Icons.system_update_outlined,
                  value: notificationProvider.systemUpdates,
                  onChanged: notificationProvider.updateSystemUpdates,
                  theme: theme,
                  isDark: isDark,
                ),

                const SizedBox(height: AppTheme.spacingXL),

                // Reset Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _showResetDialog(context, notificationProvider),
                    icon: const Icon(Icons.restore),
                    label: const Text('Reset to Defaults'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.textSecondaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingL,
                        vertical: AppTheme.spacingM,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimaryColor,
      ),
    );
  }

  Widget _buildNotificationTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppTheme.spacingS),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusS),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryColor,
          activeTrackColor: AppTheme.primaryColor.withOpacity(0.3),
          inactiveThumbColor: AppTheme.textSecondaryColor,
          inactiveTrackColor: AppTheme.textSecondaryColor.withOpacity(0.3),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Notification Settings'),
          content: const Text(
            'Are you sure you want to reset all notification settings to their default values?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                provider.resetToDefaults();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification settings reset to defaults'),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                );
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }
}
