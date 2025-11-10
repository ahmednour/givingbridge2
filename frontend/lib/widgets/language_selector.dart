import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../core/theme/app_theme.dart';

class LanguageSelector extends StatelessWidget {
  final bool showAsButton;
  final bool showCurrentLanguage;
  
  const LanguageSelector({
    Key? key,
    this.showAsButton = false,
    this.showCurrentLanguage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        if (showAsButton) {
          return _buildLanguageButton(context, localeProvider);
        } else {
          return _buildLanguageDropdown(context, localeProvider);
        }
      },
    );
  }

  Widget _buildLanguageButton(BuildContext context, LocaleProvider localeProvider) {
    final l10n = AppLocalizations.of(context)!;
    
    return InkWell(
      onTap: () => _showLanguageModal(context, localeProvider),
      borderRadius: BorderRadius.circular(AppTheme.radiusM),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.borderColor),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageFlag(localeProvider.locale.languageCode),
            const SizedBox(width: AppTheme.spacingS),
            Text(
              _getLanguageName(localeProvider.locale.languageCode, l10n),
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(width: AppTheme.spacingS),
            Icon(
              localeProvider.getDirectionalIcon(
                start: Icons.keyboard_arrow_down,
                end: Icons.keyboard_arrow_down,
              ),
              size: 20,
              color: AppTheme.textSecondaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown(BuildContext context, LocaleProvider localeProvider) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: localeProvider.locale.languageCode,
          icon: Icon(
            localeProvider.getDirectionalIcon(
              start: Icons.keyboard_arrow_down,
              end: Icons.keyboard_arrow_down,
            ),
            color: AppTheme.textSecondaryColor,
          ),
          items: [
            DropdownMenuItem(
              value: 'en',
              child: Row(
                children: [
                  _buildLanguageFlag('en'),
                  const SizedBox(width: AppTheme.spacingS),
                  Text(l10n.english),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'ar',
              child: Row(
                children: [
                  _buildLanguageFlag('ar'),
                  const SizedBox(width: AppTheme.spacingS),
                  Text(l10n.arabic),
                ],
              ),
            ),
          ],
          onChanged: (String? languageCode) {
            if (languageCode != null) {
              _changeLanguage(context, localeProvider, languageCode);
            }
          },
        ),
      ),
    );
  }

  Widget _buildLanguageFlag(String languageCode) {
    return Container(
      width: 24,
      height: 18,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: _getFlagWidget(languageCode),
      ),
    );
  }

  Widget _getFlagWidget(String languageCode) {
    // For now, use text flags. In a real app, you'd use flag images
    switch (languageCode) {
      case 'ar':
        return Container(
          color: Colors.green,
          child: const Center(
            child: Text(
              'ع',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      case 'en':
      default:
        return Container(
          color: Colors.blue,
          child: const Center(
            child: Text(
              'EN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
    }
  }

  String _getLanguageName(String languageCode, AppLocalizations l10n) {
    switch (languageCode) {
      case 'ar':
        return l10n.arabic;
      case 'en':
      default:
        return l10n.english;
    }
  }

  void _showLanguageModal(BuildContext context, LocaleProvider localeProvider) {
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusL)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              
              // Title
              Text(
                l10n.selectLanguagePrompt,
                style: AppTheme.headingMedium,
              ),
              const SizedBox(height: AppTheme.spacingM),
              
              // Current language indicator
              if (showCurrentLanguage) ...[
                Text(
                  l10n.currentLanguage,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
              ],
              
              // Language options
              _buildLanguageOption(
                context,
                localeProvider,
                'en',
                l10n.english,
                localeProvider.locale.languageCode == 'en',
              ),
              const SizedBox(height: AppTheme.spacingS),
              _buildLanguageOption(
                context,
                localeProvider,
                'ar',
                l10n.arabic,
                localeProvider.locale.languageCode == 'ar',
              ),
              
              const SizedBox(height: AppTheme.spacingL),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    LocaleProvider localeProvider,
    String languageCode,
    String languageName,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _changeLanguage(context, localeProvider, languageCode);
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
          ),
        ),
        child: Row(
          children: [
            _buildLanguageFlag(languageCode),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Text(
                languageName,
                style: AppTheme.bodyMedium.copyWith(
                  color: isSelected ? AppTheme.primaryColor : null,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _changeLanguage(BuildContext context, LocaleProvider localeProvider, String languageCode) {
    final l10n = AppLocalizations.of(context)!;
    
    localeProvider.setLocale(Locale(languageCode)).then((_) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.languageChanged),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        ),
      );
    });
  }
}

// Simple language toggle button for quick switching
class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return IconButton(
          onPressed: () {
            localeProvider.toggleLocale();
            
            final l10n = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.languageChanged),
                backgroundColor: AppTheme.successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
              ),
            );
          },
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              localeProvider.isArabic ? 'EN' : 'ع',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          tooltip: localeProvider.isArabic ? AppLocalizations.of(context)!.switchToEnglish : AppLocalizations.of(context)!.switchToArabic,
        );
      },
    );
  }
}