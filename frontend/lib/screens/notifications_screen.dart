import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/design_system.dart';
import '../widgets/common/gb_button.dart';
import '../l10n/app_localizations.dart';
import '../providers/notification_provider.dart';

// Simplified notifications screen for MVP - only basic in-app message notifications
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late NotificationProvider _notificationProvider;

  @override
  void initState() {
    super.initState();
    _notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    _notificationProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: DesignSystem.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: DesignSystem.getSurfaceColor(context),
        elevation: 0,
        title: Text(
          l10n.notificationSettings,
          style: const TextStyle(
            color: DesignSystem.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DesignSystem.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(DesignSystem.spaceL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Basic Notification Settings',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: DesignSystem.spaceS),
                Text(
                  'Simplified notification settings for MVP. Only basic in-app notifications for messages are supported.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: DesignSystem.textSecondary,
                  ),
                ),
                const SizedBox(height: DesignSystem.spaceXL),

                // In-App Notifications Card
                Container(
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
                        'In-App Notifications',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: DesignSystem.spaceM),
                      
                      // Enable In-App Notifications
                      _buildSettingToggle(
                        'Enable Notifications',
                        'Show notifications within the app',
                        provider.inAppNotifications,
                        (value) => provider.updateInAppNotifications(value),
                        theme,
                      ),
                      
                      const SizedBox(height: DesignSystem.spaceM),
                      
                      // Message Notifications
                      _buildSettingToggle(
                        'Message Notifications',
                        'Get notified when you receive new messages',
                        provider.messages,
                        (value) => provider.updateMessages(value),
                        theme,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: DesignSystem.spaceXL),

                // Reset Button
                GBButton(
                  text: 'Reset to Defaults',
                  onPressed: () => _showResetDialog(context, provider),
                  variant: GBButtonVariant.outline,
                  size: GBButtonSize.medium,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingToggle(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    ThemeData theme,
  ) {
    return Row(
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
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: DesignSystem.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: DesignSystem.primaryBlue,
        ),
      ],
    );
  }

  void _showResetDialog(BuildContext context, NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.resetNotificationSettings),
        content: Text(
          AppLocalizations.of(context)!.resetNotificationConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          GBButton(
            text: 'Reset',
            onPressed: () {
              provider.resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.notificationSettingsReset),
                  backgroundColor: DesignSystem.success,
                ),
              );
            },
            variant: GBButtonVariant.primary,
            size: GBButtonSize.small,
          ),
        ],
      ),
    );
  }
}