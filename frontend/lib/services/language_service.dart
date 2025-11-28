import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';

class LanguageService {
  static const String _firstLaunchKey = 'is_first_launch';
  static const String _languageSetupCompleteKey = 'language_setup_complete';

  /// Check if this is the first app launch
  static Future<bool> isFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_firstLaunchKey) ?? true;
    } catch (e) {
      debugPrint('Error checking first launch: $e');
      return true;
    }
  }

  /// Mark first launch as complete
  static Future<void> markFirstLaunchComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_firstLaunchKey, false);
    } catch (e) {
      debugPrint('Error marking first launch complete: $e');
    }
  }

  /// Check if language setup is complete
  static Future<bool> isLanguageSetupComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_languageSetupCompleteKey) ?? false;
    } catch (e) {
      debugPrint('Error checking language setup: $e');
      return false;
    }
  }

  /// Mark language setup as complete
  static Future<void> markLanguageSetupComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_languageSetupCompleteKey, true);
    } catch (e) {
      debugPrint('Error marking language setup complete: $e');
    }
  }

  /// Get preferred locale based on system settings and user preferences
  static Future<Locale> getPreferredLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguageCode = prefs.getString('language_code');

      if (savedLanguageCode != null) {
        return Locale(savedLanguageCode);
      }

      // Try to detect system locale
      final systemLocales = WidgetsBinding.instance.platformDispatcher.locales;
      if (systemLocales.isNotEmpty) {
        final systemLocale = systemLocales.first;
        if (LocaleProvider.supportedLocales.any(
            (locale) => locale.languageCode == systemLocale.languageCode)) {
          return systemLocale;
        }
      }

      // Default to Arabic for Saudi Arabia project
      return const Locale('ar');
    } catch (e) {
      debugPrint('Error getting preferred locale: $e');
      return const Locale('ar');
    }
  }

  /// Handle smooth language transition with animation
  static Future<void> changeLanguageWithTransition(
    BuildContext context,
    LocaleProvider localeProvider,
    Locale newLocale, {
    Duration animationDuration = const Duration(milliseconds: 300),
  }) async {
    if (localeProvider.locale == newLocale) {
      return; // No change needed
    }

    try {
      // Show loading indicator during transition
      if (context.mounted) {
        _showLanguageTransitionOverlay(context, animationDuration);
      }

      // Change the locale
      await localeProvider.setLocale(newLocale);

      // Wait for animation to complete
      await Future.delayed(animationDuration);
    } catch (e) {
      debugPrint('Error during language transition: $e');

      // Show error message if context is still mounted
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedToChangeLanguage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show overlay during language transition
  static void _showLanguageTransitionOverlay(
    BuildContext context,
    Duration duration,
  ) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => AnimatedContainer(
        duration: duration,
        color: Colors.black.withOpacity(0.3),
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 16),
                  Text(AppLocalizations.of(context)!.changingLanguage),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Remove overlay after animation
    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }

  /// Validate locale support
  static bool isLocaleSupported(Locale locale) {
    return LocaleProvider.supportedLocales.any((supportedLocale) =>
        supportedLocale.languageCode == locale.languageCode);
  }

  /// Get locale display name
  static String getLocaleDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      default:
        return locale.languageCode.toUpperCase();
    }
  }

  /// Get locale native name
  static String getLocaleNativeName(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      default:
        return locale.languageCode;
    }
  }

  /// Reset language preferences (for testing or troubleshooting)
  static Future<void> resetLanguagePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove('language_code'),
        prefs.remove('country_code'),
        prefs.remove(_languageSetupCompleteKey),
      ]);
    } catch (e) {
      debugPrint('Error resetting language preferences: $e');
    }
  }

  /// Export language settings for backup
  static Future<Map<String, dynamic>> exportLanguageSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'language_code': prefs.getString('language_code'),
        'country_code': prefs.getString('country_code'),
        'language_setup_complete': prefs.getBool(_languageSetupCompleteKey),
        'first_launch': prefs.getBool(_firstLaunchKey),
      };
    } catch (e) {
      debugPrint('Error exporting language settings: $e');
      return {};
    }
  }

  /// Import language settings from backup
  static Future<void> importLanguageSettings(
      Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (settings['language_code'] != null) {
        await prefs.setString('language_code', settings['language_code']);
      }

      if (settings['country_code'] != null) {
        await prefs.setString('country_code', settings['country_code']);
      }

      if (settings['language_setup_complete'] != null) {
        await prefs.setBool(
            _languageSetupCompleteKey, settings['language_setup_complete']);
      }

      if (settings['first_launch'] != null) {
        await prefs.setBool(_firstLaunchKey, settings['first_launch']);
      }
    } catch (e) {
      debugPrint('Error importing language settings: $e');
    }
  }
}
