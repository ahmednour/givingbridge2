import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme Provider for managing app theme state
///
/// Features:
/// - Theme toggle (light/dark/system)
/// - Persistent theme preference
/// - Smooth theme transitions
/// - System theme detection
///
/// Usage:
/// ```dart
/// final themeProvider = Provider.of<ThemeProvider>(context);
/// themeProvider.toggleTheme();
/// themeProvider.setThemeMode(ThemeMode.dark);
/// ```
class ThemeProvider extends ChangeNotifier {
  static const String _themePrefKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  ThemeProvider() {
    _loadThemePreference();
  }

  /// Current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Whether dark mode is currently active
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Whether light mode is currently active
  bool get isLightMode => _themeMode == ThemeMode.light;

  /// Whether using system theme
  bool get isSystemMode => _themeMode == ThemeMode.system;

  /// Whether provider is initialized
  bool get isInitialized => _isInitialized;

  /// Load theme preference from SharedPreferences
  Future<void> _loadThemePreference() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final themeModeString = _prefs.getString(_themePrefKey);

      if (themeModeString != null) {
        _themeMode = _parseThemeMode(themeModeString);
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Parse theme mode from string
  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Convert theme mode to string
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
      default:
        return 'system';
    }
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    // Save preference
    try {
      await _prefs.setString(_themePrefKey, _themeModeToString(mode));
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }

  /// Set to light mode
  Future<void> setLightMode() async {
    await setThemeMode(ThemeMode.light);
  }

  /// Set to dark mode
  Future<void> setDarkMode() async {
    await setThemeMode(ThemeMode.dark);
  }

  /// Set to system mode
  Future<void> setSystemMode() async {
    await setThemeMode(ThemeMode.system);
  }

  /// Get effective brightness based on system
  Brightness getEffectiveBrightness(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness;
    }
    return _themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light;
  }

  /// Check if dark mode should be active
  bool shouldUseDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
}
