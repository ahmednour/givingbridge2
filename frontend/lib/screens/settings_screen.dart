import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/language_selector.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocaleProvider, AuthProvider>(
      builder: (context, localeProvider, authProvider, child) {
        final l10n = AppLocalizations.of(context)!;

        return Directionality(
          textDirection: localeProvider.textDirection,
          child: Scaffold(
            body: ListView(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              children: [
                // Language Settings Section
                _buildSectionHeader(l10n.language, Icons.language),
                const SizedBox(height: AppTheme.spacingM),
                _buildLanguageSettingsCard(context, localeProvider, l10n),

                const SizedBox(height: AppTheme.spacingXL),

                // Account Settings Section
                _buildSectionHeader(l10n.profile, Icons.person),
                const SizedBox(height: AppTheme.spacingM),
                _buildAccountSettingsCard(context, authProvider, l10n),

                const SizedBox(height: AppTheme.spacingXL),

                // App Settings Section
                _buildSectionHeader(l10n.settings, Icons.settings),
                const SizedBox(height: AppTheme.spacingM),
                _buildAppSettingsCard(context, l10n),

                const SizedBox(height: AppTheme.spacingXL),

                // About Section
                _buildSectionHeader('About', Icons.info),
                const SizedBox(height: AppTheme.spacingM),
                _buildAboutCard(context, l10n),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
        const SizedBox(width: AppTheme.spacingS),
        Text(
          title,
          style: AppTheme.headingSmall.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSettingsCard(BuildContext context,
      LocaleProvider localeProvider, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.changeAppLanguage,
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              l10n.selectLanguagePrompt,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Current Language Display
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  Text(
                    '${l10n.currentLanguage}: ${localeProvider.isArabic ? l10n.arabic : l10n.english}',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Language Selector
            const LanguageSelector(showAsButton: false),

            const SizedBox(height: AppTheme.spacingM),

            // Quick Toggle Button
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      localeProvider.toggleLocale();
                    },
                    icon: const Icon(Icons.swap_horiz),
                    label: Text(
                      localeProvider.isArabic
                          ? l10n.switchToEnglish
                          : l10n.switchToArabic,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingM,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSettingsCard(
      BuildContext context, AuthProvider authProvider, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(l10n.profile),
            subtitle: Text('${l10n.edit} ${l10n.profile}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(l10n.notifications),
            subtitle: Text('${l10n.manageYourNotifications}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.security),
            title: Text(l10n.privacy),
            subtitle: Text(l10n.privacySecurity),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to privacy settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettingsCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: Text(l10n.darkMode),
            subtitle: Text(l10n.switchBetweenLightDark),
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (bool value) {
              // Toggle theme mode
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: Text(l10n.vibration),
            subtitle: Text(l10n.vibrateForMessages),
            value: true, // This would come from settings provider
            onChanged: (bool value) {
              // Toggle vibration
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up_outlined),
            title: Text(l10n.sound),
            subtitle: Text(l10n.playSoundForMessages),
            value: true, // This would come from settings provider
            onChanged: (bool value) {
              // Toggle sound
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text('${l10n.appTitle} v1.0.0'),
            subtitle: Text(l10n.madeWithLove),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(l10n.helpAndSupport),
            subtitle: Text(l10n.getHelpContactSupport),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to help
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.termsAndConditions),
            subtitle: Text(l10n.readTermsConditions),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to terms
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.privacyPolicy),
            subtitle: Text(l10n.readPrivacyPolicy),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to privacy policy
            },
          ),
        ],
      ),
    );
  }
}
