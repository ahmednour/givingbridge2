import 'package:flutter/material.dart';
import '../constants/ui_constants.dart';
import '../utils/rtl_utils.dart';

/// Enhanced theme system with RTL support and Arabic-first design
class AppTheme {
  // Color Palette
  static const Color primaryColor = Color(0xFF2E7D32); // Deep Green
  static const Color primaryLightColor = Color(0xFF4CAF50); // Light Green
  static const Color primaryDarkColor = Color(0xFF1B5E20); // Dark Green
  static const Color secondaryColor = Color(0xFF1976D2); // Blue
  static const Color accentColor = Color(0xFFFF9800); // Orange

  static const Color backgroundColor = Color(0xFFFAFAFA); // Light Gray
  static const Color surfaceColor = Color(0xFFFFFFFF); // White
  static const Color errorColor = Color(0xFFD32F2F); // Red
  static const Color warningColor = Color(0xFFFF9800); // Orange
  static const Color successColor = Color(0xFF4CAF50); // Green
  static const Color infoColor = Color(0xFF2196F3); // Blue

  static const Color textPrimaryColor = Color(0xFF212121); // Dark Gray
  static const Color textSecondaryColor = Color(0xFF757575); // Medium Gray
  static const Color textHintColor = Color(0xFFBDBDBD); // Light Gray
  static const Color textDisabledColor = Color(0xFFE0E0E0); // Very Light Gray

  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color shadowColor = Color(0x1A000000);

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        primaryContainer: primaryLightColor,
        secondary: secondaryColor,
        secondaryContainer: Color(0xFFE3F2FD),
        surface: backgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryColor,
        onError: Colors.white,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card Theme - Removed for Flutter 3.24.0 compatibility
      // cardTheme: CardThemeData(...),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spacingL,
            vertical: UIConstants.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusM),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spacingM,
            vertical: UIConstants.spacingS,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spacingL,
            vertical: UIConstants.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusM),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusM),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusM),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusM),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusM),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: UIConstants.spacingM,
          vertical: UIConstants.spacingM,
        ),
        hintStyle: const TextStyle(color: textHintColor),
        labelStyle: const TextStyle(color: textSecondaryColor),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimaryColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textPrimaryColor,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textSecondaryColor,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimaryColor,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textPrimaryColor,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textSecondaryColor,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: textSecondaryColor,
        size: UIConstants.iconM,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: UIConstants.dividerThickness,
        space: UIConstants.spacingM,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Tab Bar Theme - Removed for Flutter 3.24.0 compatibility
      // tabBarTheme: const TabBarThemeData(...),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: backgroundColor,
        selectedColor: primaryLightColor,
        labelStyle: const TextStyle(color: textPrimaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
        ),
      ),

      // Dialog Theme - Removed for Flutter 3.24.0 compatibility
      // dialogTheme: DialogThemeData(...),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimaryColor,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusM),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Dark Theme (for future implementation)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      // Dark theme implementation would go here
    );
  }

  // RTL-aware spacing
  static EdgeInsets getRTLPadding(
    BuildContext context, {
    double? start,
    double? end,
    double? top,
    double? bottom,
  }) {
    final horizontalPadding = RTLUtils.getHorizontalPadding(
      context,
      start: start,
      end: end,
    );

    return EdgeInsets.only(
      left: horizontalPadding.left,
      right: horizontalPadding.right,
      top: top ?? 0,
      bottom: bottom ?? 0,
    );
  }

  // RTL-aware margin
  static EdgeInsets getRTLMargin(
    BuildContext context, {
    double? start,
    double? end,
    double? top,
    double? bottom,
  }) {
    return RTLUtils.getMargin(
      context,
      start: start,
      end: end,
      top: top,
      bottom: bottom,
    );
  }

  // RTL-aware border radius
  static BorderRadius getRTLBorderRadius(
    BuildContext context, {
    double? topStart,
    double? topEnd,
    double? bottomStart,
    double? bottomEnd,
    double? all,
  }) {
    return RTLUtils.getBorderRadius(
      context,
      topStart: topStart,
      topEnd: topEnd,
      bottomStart: bottomStart,
      bottomEnd: bottomEnd,
      all: all,
    );
  }

  // RTL-aware alignment
  static Alignment getRTLAlignment(
    BuildContext context, {
    Alignment? start,
    Alignment? end,
    Alignment? center,
  }) {
    return RTLUtils.getAlignment(
      context,
      start: start,
      end: end,
      center: center,
    );
  }

  // RTL-aware cross axis alignment
  static CrossAxisAlignment getRTLCrossAxisAlignment(
    BuildContext context, {
    CrossAxisAlignment? start,
    CrossAxisAlignment? end,
    CrossAxisAlignment? center,
  }) {
    return RTLUtils.getCrossAxisAlignment(
      context,
      start: start,
      end: end,
      center: center,
    );
  }

  // RTL-aware main axis alignment
  static MainAxisAlignment getRTLMainAxisAlignment(
    BuildContext context, {
    MainAxisAlignment? start,
    MainAxisAlignment? end,
    MainAxisAlignment? center,
  }) {
    return RTLUtils.getMainAxisAlignment(
      context,
      start: start,
      end: end,
      center: center,
    );
  }
}
