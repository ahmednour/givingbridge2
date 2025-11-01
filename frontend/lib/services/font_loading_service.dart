import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// Service for managing Arabic font loading and fallback systems
class FontLoadingService {
  static const String _arabicFontFamily = 'Cairo';
  static const String _fallbackFontFamily = 'Roboto';
  
  static bool _fontsLoaded = false;
  static bool _loadingFailed = false;

  /// Preload Arabic fonts during app initialization
  static Future<void> preloadArabicFonts() async {
    if (_fontsLoaded) return;

    try {
      // Preload all Cairo font weights
      await Future.wait([
        _loadFontAsset('assets/fonts/Cairo_regular_4b11e795d4ad8cd5df4d5a6499fd802f226d4f2005612e8963e1a39053d18d1b.ttf'),
        _loadFontAsset('assets/fonts/Cairo_500_e3d37369ef6468651f579859edf81b7c8952a26e4e4bd20ae685b86714396b77.ttf'),
        _loadFontAsset('assets/fonts/Cairo_600_1b16088a549cf542a3e12718ec366a54883588accd7bfa7e459d5aebbb48ef10.ttf'),
        _loadFontAsset('assets/fonts/Cairo_700_6ba65ef98b11bcd9889f0df67db2cd6ed86c891f2b5f07bf1403aeae0b9e696c.ttf'),
      ]);
      
      _fontsLoaded = true;
      debugPrint('Arabic fonts preloaded successfully');
    } catch (e) {
      _loadingFailed = true;
      debugPrint('Failed to preload Arabic fonts: $e');
    }
  }

  /// Load a specific font asset
  static Future<void> _loadFontAsset(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      // Font loading is handled automatically by Flutter when declared in pubspec.yaml
      // This method ensures the assets are cached
    } catch (e) {
      debugPrint('Failed to load font asset $assetPath: $e');
      rethrow;
    }
  }

  /// Get the appropriate font family for Arabic text with fallback
  static String getArabicFontFamily() {
    if (_loadingFailed) {
      return _fallbackFontFamily;
    }
    return _arabicFontFamily;
  }

  /// Get font family based on locale
  static String getFontFamilyForLocale(Locale locale) {
    if (locale.languageCode == 'ar') {
      return getArabicFontFamily();
    }
    return _fallbackFontFamily;
  }

  /// Check if Arabic fonts are loaded
  static bool get areArabicFontsLoaded => _fontsLoaded;

  /// Check if font loading failed
  static bool get didFontLoadingFail => _loadingFailed;

  /// Create a TextStyle with appropriate font family for the given locale
  static TextStyle createLocalizedTextStyle({
    required Locale locale,
    TextStyle? baseStyle,
  }) {
    final fontFamily = getFontFamilyForLocale(locale);
    
    if (baseStyle != null) {
      return baseStyle.copyWith(fontFamily: fontFamily);
    }
    
    return TextStyle(fontFamily: fontFamily);
  }

  /// Get font fallback list for Arabic text
  static List<String> getArabicFontFallbacks() {
    return [
      _arabicFontFamily,
      'Noto Sans Arabic',
      'Arial Unicode MS',
      _fallbackFontFamily,
    ];
  }
}