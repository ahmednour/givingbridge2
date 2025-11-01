import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  static const String _languageCodeKey = 'language_code';
  static const String _countryCodeKey = 'country_code';
  
  Locale _locale = const Locale('ar'); // Default to Arabic
  bool _isInitialized = false;
  bool _isLoading = false;

  Locale get locale => _locale;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  /// Check if current locale is RTL
  bool get isRTL => _locale.languageCode == 'ar';

  /// Get text direction based on current locale
  TextDirection get textDirection => isRTL ? TextDirection.rtl : TextDirection.ltr;

  /// Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('ar', ''), // Arabic
  ];

  LocaleProvider() {
    _initializeLocale();
  }

  /// Initialize locale from saved preferences or system locale
  Future<void> _initializeLocale() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Try to load saved locale first
      final savedLanguageCode = prefs.getString(_languageCodeKey);
      final savedCountryCode = prefs.getString(_countryCodeKey);
      
      if (savedLanguageCode != null) {
        final savedLocale = Locale(savedLanguageCode, savedCountryCode ?? '');
        if (_isSupportedLocale(savedLocale)) {
          _locale = savedLocale;
        }
      } else {
        // If no saved locale, try to use system locale
        final systemLocale = _getSystemLocale();
        if (_isSupportedLocale(systemLocale)) {
          _locale = systemLocale;
        } else {
          // Fallback to Arabic as default
          _locale = const Locale('ar');
        }
        
        // Save the determined locale
        await _persistLocale(_locale);
      }
      
      _isInitialized = true;
    } catch (e) {
      // Handle errors gracefully
      debugPrint('Error initializing locale: $e');
      _locale = const Locale('ar'); // Fallback to Arabic
      _isInitialized = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get system locale
  Locale _getSystemLocale() {
    try {
      final systemLocales = WidgetsBinding.instance.platformDispatcher.locales;
      if (systemLocales.isNotEmpty) {
        return systemLocales.first;
      }
    } catch (e) {
      debugPrint('Error getting system locale: $e');
    }
    return const Locale('en'); // Default fallback
  }

  /// Check if locale is supported
  bool _isSupportedLocale(Locale locale) {
    return supportedLocales.any((supportedLocale) => 
        supportedLocale.languageCode == locale.languageCode);
  }

  /// Set locale with improved error handling and validation
  Future<void> setLocale(Locale locale) async {
    if (!_isSupportedLocale(locale)) {
      debugPrint('Unsupported locale: ${locale.languageCode}');
      return;
    }

    if (_locale == locale) {
      return; // No change needed
    }

    final previousLocale = _locale;
    _locale = locale;
    
    try {
      await _persistLocale(locale);
      notifyListeners();
    } catch (e) {
      // Revert on error
      debugPrint('Error saving locale: $e');
      _locale = previousLocale;
      notifyListeners();
      rethrow;
    }
  }

  /// Persist locale to SharedPreferences
  Future<void> _persistLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setString(_languageCodeKey, locale.languageCode),
        prefs.setString(_countryCodeKey, locale.countryCode ?? ''),
      ]);
    } catch (e) {
      debugPrint('Error persisting locale: $e');
      // Don't rethrow here to allow app to continue working
    }
  }

  /// Toggle between supported languages
  Future<void> toggleLocale() async {
    final newLocale = _locale.languageCode == 'en' 
        ? const Locale('ar') 
        : const Locale('en');
    await setLocale(newLocale);
  }

  /// Reset to system locale
  Future<void> resetToSystemLocale() async {
    final systemLocale = _getSystemLocale();
    if (_isSupportedLocale(systemLocale)) {
      await setLocale(systemLocale);
    } else {
      await setLocale(const Locale('en')); // Fallback to English
    }
  }

  /// Clear saved locale preferences
  Future<void> clearSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_languageCodeKey),
        prefs.remove(_countryCodeKey),
      ]);
    } catch (e) {
      debugPrint('Error clearing saved locale: $e');
    }
  }

  bool get isArabic => _locale.languageCode == 'ar';
  bool get isEnglish => _locale.languageCode == 'en';

  /// Get directional alignment based on current locale
  Alignment getDirectionalAlignment({
    Alignment? start,
    Alignment? end,
    Alignment? center,
  }) {
    if (center != null) return center;
    return isRTL
        ? (end ?? Alignment.centerRight)
        : (start ?? Alignment.centerLeft);
  }

  /// Get directional padding based on current locale
  EdgeInsets getDirectionalPadding({
    double? start,
    double? end,
    double? top,
    double? bottom,
    double? horizontal,
    double? vertical,
    double? all,
  }) {
    if (all != null) {
      return EdgeInsets.all(all);
    }
    if (horizontal != null || vertical != null) {
      return EdgeInsets.symmetric(
        horizontal: horizontal ?? 0,
        vertical: vertical ?? 0,
      );
    }
    
    return EdgeInsets.only(
      left: isRTL ? (end ?? 0) : (start ?? 0),
      right: isRTL ? (start ?? 0) : (end ?? 0),
      top: top ?? 0,
      bottom: bottom ?? 0,
    );
  }

  /// Get directional margin based on current locale
  EdgeInsets getDirectionalMargin({
    double? start,
    double? end,
    double? top,
    double? bottom,
    double? horizontal,
    double? vertical,
    double? all,
  }) {
    if (all != null) {
      return EdgeInsets.all(all);
    }
    if (horizontal != null || vertical != null) {
      return EdgeInsets.symmetric(
        horizontal: horizontal ?? 0,
        vertical: vertical ?? 0,
      );
    }
    
    return EdgeInsets.only(
      left: isRTL ? (end ?? 0) : (start ?? 0),
      right: isRTL ? (start ?? 0) : (end ?? 0),
      top: top ?? 0,
      bottom: bottom ?? 0,
    );
  }

  /// Get cross axis alignment based on current locale
  CrossAxisAlignment getDirectionalCrossAxisAlignment({
    CrossAxisAlignment? start,
    CrossAxisAlignment? end,
    CrossAxisAlignment? center,
  }) {
    if (center != null) return center;
    return isRTL
        ? (end ?? CrossAxisAlignment.end)
        : (start ?? CrossAxisAlignment.start);
  }

  /// Get main axis alignment based on current locale
  MainAxisAlignment getDirectionalMainAxisAlignment({
    MainAxisAlignment? start,
    MainAxisAlignment? end,
    MainAxisAlignment? center,
  }) {
    if (center != null) return center;
    return isRTL
        ? (end ?? MainAxisAlignment.end)
        : (start ?? MainAxisAlignment.start);
  }

  /// Get directional border radius based on current locale
  BorderRadius getDirectionalBorderRadius({
    double? topStart,
    double? topEnd,
    double? bottomStart,
    double? bottomEnd,
    double? all,
  }) {
    if (all != null) {
      return BorderRadius.circular(all);
    }

    return BorderRadius.only(
      topLeft: Radius.circular(isRTL ? (topEnd ?? 0) : (topStart ?? 0)),
      topRight: Radius.circular(isRTL ? (topStart ?? 0) : (topEnd ?? 0)),
      bottomLeft: Radius.circular(isRTL ? (bottomEnd ?? 0) : (bottomStart ?? 0)),
      bottomRight: Radius.circular(isRTL ? (bottomStart ?? 0) : (bottomEnd ?? 0)),
    );
  }

  /// Get directional icon based on current locale
  IconData getDirectionalIcon({
    IconData? start,
    IconData? end,
    IconData? ltr,
    IconData? rtl,
  }) {
    if (isRTL) {
      return end ?? rtl ?? Icons.arrow_back_ios;
    } else {
      return start ?? ltr ?? Icons.arrow_forward_ios;
    }
  }
}
