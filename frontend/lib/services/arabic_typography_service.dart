import 'package:flutter/material.dart';
import 'font_loading_service.dart';

/// Service for handling Arabic-specific typography and text styling
class ArabicTypographyService {
  // Arabic text characteristics
  static const double _arabicLineHeightMultiplier = 1.6;

  /// Get Arabic-specific text style with proper font and spacing
  static TextStyle getArabicTextStyle(TextStyle baseStyle) {
    final fontSize = baseStyle.fontSize ?? 14.0;
    
    return baseStyle.copyWith(
      fontFamily: FontLoadingService.getArabicFontFamily(),
      height: getArabicLineHeight(fontSize) / fontSize,
      letterSpacing: fontSize * 0.02, // Slight letter spacing for Arabic
      wordSpacing: fontSize * 0.1, // Appropriate word spacing
    );
  }

  /// Calculate appropriate line height for Arabic text
  static double getArabicLineHeight(double fontSize) {
    return fontSize * _arabicLineHeightMultiplier;
  }

  /// Get directional text alignment based on context and locale
  static TextAlign getDirectionalTextAlign(BuildContext context, TextAlign? align) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    
    if (align == null) {
      return isRTL ? TextAlign.right : TextAlign.left;
    }

    // Convert alignment for RTL
    switch (align) {
      case TextAlign.left:
        return isRTL ? TextAlign.right : TextAlign.left;
      case TextAlign.right:
        return isRTL ? TextAlign.left : TextAlign.right;
      case TextAlign.start:
        return isRTL ? TextAlign.right : TextAlign.left;
      case TextAlign.end:
        return isRTL ? TextAlign.left : TextAlign.right;
      default:
        return align;
    }
  }

  /// Create a text style optimized for Arabic headings
  static TextStyle createArabicHeadingStyle({
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: FontLoadingService.getArabicFontFamily(),
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w600,
      height: getArabicLineHeight(fontSize) / fontSize,
      color: color,
      letterSpacing: fontSize * 0.01,
    );
  }

  /// Create a text style optimized for Arabic body text
  static TextStyle createArabicBodyStyle({
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: FontLoadingService.getArabicFontFamily(),
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w400,
      height: getArabicLineHeight(fontSize) / fontSize,
      color: color,
      letterSpacing: fontSize * 0.02,
      wordSpacing: fontSize * 0.1,
    );
  }

  /// Create a text style optimized for Arabic captions and small text
  static TextStyle createArabicCaptionStyle({
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: FontLoadingService.getArabicFontFamily(),
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w400,
      height: (getArabicLineHeight(fontSize) + 2) / fontSize, // Slightly more line height for small text
      color: color,
      letterSpacing: fontSize * 0.03,
    );
  }

  /// Get appropriate text direction for mixed content
  static TextDirection getTextDirectionForContent(String text) {
    // Simple heuristic: if text contains Arabic characters, use RTL
    final arabicRegex = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]');
    
    if (arabicRegex.hasMatch(text)) {
      return TextDirection.rtl;
    }
    
    return TextDirection.ltr;
  }

  /// Check if text contains Arabic characters
  static bool containsArabicText(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]');
    return arabicRegex.hasMatch(text);
  }

  /// Create a localized text style based on current locale
  static TextStyle createLocalizedTextStyle({
    required BuildContext context,
    required TextStyle baseStyle,
  }) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    
    if (isRTL) {
      return getArabicTextStyle(baseStyle);
    }
    
    return baseStyle;
  }

  /// Get appropriate font weight for Arabic text
  /// Arabic fonts often need different weight mapping
  static FontWeight getArabicFontWeight(FontWeight originalWeight) {
    switch (originalWeight) {
      case FontWeight.w100:
      case FontWeight.w200:
      case FontWeight.w300:
        return FontWeight.w400; // Arabic fonts don't have very light weights
      case FontWeight.w400:
        return FontWeight.w400;
      case FontWeight.w500:
        return FontWeight.w500;
      case FontWeight.w600:
        return FontWeight.w600;
      case FontWeight.w700:
        return FontWeight.w700;
      case FontWeight.w800:
      case FontWeight.w900:
        return FontWeight.w700; // Limit to available weights
      default:
        return FontWeight.w400;
    }
  }

  /// Create a text theme optimized for Arabic typography
  static TextTheme createArabicTextTheme(TextTheme baseTheme) {
    return TextTheme(
      displayLarge: baseTheme.displayLarge != null 
          ? getArabicTextStyle(baseTheme.displayLarge!) 
          : null,
      displayMedium: baseTheme.displayMedium != null 
          ? getArabicTextStyle(baseTheme.displayMedium!) 
          : null,
      displaySmall: baseTheme.displaySmall != null 
          ? getArabicTextStyle(baseTheme.displaySmall!) 
          : null,
      headlineLarge: baseTheme.headlineLarge != null 
          ? getArabicTextStyle(baseTheme.headlineLarge!) 
          : null,
      headlineMedium: baseTheme.headlineMedium != null 
          ? getArabicTextStyle(baseTheme.headlineMedium!) 
          : null,
      headlineSmall: baseTheme.headlineSmall != null 
          ? getArabicTextStyle(baseTheme.headlineSmall!) 
          : null,
      titleLarge: baseTheme.titleLarge != null 
          ? getArabicTextStyle(baseTheme.titleLarge!) 
          : null,
      titleMedium: baseTheme.titleMedium != null 
          ? getArabicTextStyle(baseTheme.titleMedium!) 
          : null,
      titleSmall: baseTheme.titleSmall != null 
          ? getArabicTextStyle(baseTheme.titleSmall!) 
          : null,
      bodyLarge: baseTheme.bodyLarge != null 
          ? getArabicTextStyle(baseTheme.bodyLarge!) 
          : null,
      bodyMedium: baseTheme.bodyMedium != null 
          ? getArabicTextStyle(baseTheme.bodyMedium!) 
          : null,
      bodySmall: baseTheme.bodySmall != null 
          ? getArabicTextStyle(baseTheme.bodySmall!) 
          : null,
      labelLarge: baseTheme.labelLarge != null 
          ? getArabicTextStyle(baseTheme.labelLarge!) 
          : null,
      labelMedium: baseTheme.labelMedium != null 
          ? getArabicTextStyle(baseTheme.labelMedium!) 
          : null,
      labelSmall: baseTheme.labelSmall != null 
          ? getArabicTextStyle(baseTheme.labelSmall!) 
          : null,
    );
  }
}