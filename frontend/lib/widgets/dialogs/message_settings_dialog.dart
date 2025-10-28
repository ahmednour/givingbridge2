import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';
import '../../l10n/app_localizations.dart';

class MessageSettingsDialog extends StatefulWidget {
  final Map<String, bool> currentSettings;
  final Function(String key, bool value) onSettingChanged;

  const MessageSettingsDialog({
    Key? key,
    required this.currentSettings,
    required this.onSettingChanged,
  }) : super(key: key);

  @override
  State<MessageSettingsDialog> createState() => _MessageSettingsDialogState();
}

class _MessageSettingsDialogState extends State<MessageSettingsDialog> {
  late Map<String, bool> _settings;

  @override
  void initState() {
    super.initState();
    _settings = Map<String, bool>.from(widget.currentSettings);
  }

  void _updateSetting(String key, bool value) {
    setState(() {
      _settings[key] = value;
    });
    widget.onSettingChanged(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusL),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.messageSettings,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: DesignSystem.neutral900,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: DesignSystem.neutral600,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Message Notifications Section
            _buildSectionHeader(
                l10n.notifications, Icons.notifications_outlined),
            const SizedBox(height: 16),
            _buildSettingsCard([
              _buildToggleTile(
                l10n.notifyOnNewMessages,
                l10n.notifyOnNewMessages,
                'messageNotifications',
                _settings['messageNotifications'] ?? true,
                isDark,
              ),
              const Divider(height: 1),
              _buildToggleTile(
                l10n.sound,
                l10n.playSoundForMessages,
                'messageSound',
                _settings['messageSound'] ?? true,
                isDark,
              ),
              const Divider(height: 1),
              _buildToggleTile(
                l10n.vibration,
                l10n.vibrateForMessages,
                'messageVibration',
                _settings['messageVibration'] ?? true,
                isDark,
              ),
            ]),

            const SizedBox(height: 24),

            // Privacy Section
            _buildSectionHeader(l10n.privacy, Icons.privacy_tip_outlined),
            const SizedBox(height: 16),
            _buildSettingsCard([
              _buildToggleTile(
                l10n.readReceipts,
                l10n.showReadReceipts,
                'readReceipts',
                _settings['readReceipts'] ?? true,
                isDark,
              ),
              const Divider(height: 1),
              _buildToggleTile(
                l10n.typingIndicators,
                l10n.showTypingIndicators,
                'typingIndicators',
                _settings['typingIndicators'] ?? true,
                isDark,
              ),
            ]),

            const SizedBox(height: 24),

            // Message History Section
            _buildSectionHeader(l10n.messageHistory, Icons.history_outlined),
            const SizedBox(height: 16),
            _buildSettingsCard([
              _buildToggleTile(
                l10n.autoDeleteMessages,
                l10n.automaticallyDeleteOldMessages,
                'autoDeleteMessages',
                _settings['autoDeleteMessages'] ?? false,
                isDark,
              ),
            ]),

            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.close),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: DesignSystem.primaryBlue),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: DesignSystem.neutral900,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: DesignSystem.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        border: Border.all(
          color: DesignSystem.getBorderColor(context),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildToggleTile(
    String title,
    String subtitle,
    String key,
    bool value,
    bool isDark,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? DesignSystem.neutral100 : DesignSystem.neutral900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? DesignSystem.neutral400 : DesignSystem.neutral600,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: (newValue) => _updateSetting(key, newValue),
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return DesignSystem.primaryBlue;
          }
          return DesignSystem.neutral400;
        }),
      ),
    );
  }
}
