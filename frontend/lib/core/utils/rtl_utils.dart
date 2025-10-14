import 'package:flutter/material.dart';

/// RTL-aware utilities for proper Arabic layout support
class RTLUtils {
  /// Check if current locale is RTL
  static bool isRTL(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar';
  }

  /// Get text direction based on locale
  static TextDirection getTextDirection(BuildContext context) {
    return isRTL(context) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Get horizontal padding based on text direction
  static EdgeInsets getHorizontalPadding(
    BuildContext context, {
    double? start,
    double? end,
    double? horizontal,
  }) {
    if (horizontal != null) {
      return EdgeInsets.symmetric(horizontal: horizontal);
    }

    final isRtl = isRTL(context);
    return EdgeInsets.only(
      left: isRtl ? (end ?? 0) : (start ?? 0),
      right: isRtl ? (start ?? 0) : (end ?? 0),
    );
  }

  /// Get margin based on text direction
  static EdgeInsets getMargin(
    BuildContext context, {
    double? start,
    double? end,
    double? top,
    double? bottom,
  }) {
    final isRtl = isRTL(context);
    return EdgeInsets.only(
      left: isRtl ? (end ?? 0) : (start ?? 0),
      right: isRtl ? (start ?? 0) : (end ?? 0),
      top: top ?? 0,
      bottom: bottom ?? 0,
    );
  }

  /// Get alignment based on text direction
  static Alignment getAlignment(
    BuildContext context, {
    Alignment? start,
    Alignment? end,
    Alignment? center,
  }) {
    if (center != null) return center;

    final isRtl = isRTL(context);
    return isRtl
        ? (end ?? Alignment.centerRight)
        : (start ?? Alignment.centerLeft);
  }

  /// Get cross axis alignment based on text direction
  static CrossAxisAlignment getCrossAxisAlignment(
    BuildContext context, {
    CrossAxisAlignment? start,
    CrossAxisAlignment? end,
    CrossAxisAlignment? center,
  }) {
    if (center != null) return center;

    final isRtl = isRTL(context);
    return isRtl
        ? (end ?? CrossAxisAlignment.end)
        : (start ?? CrossAxisAlignment.start);
  }

  /// Get main axis alignment based on text direction
  static MainAxisAlignment getMainAxisAlignment(
    BuildContext context, {
    MainAxisAlignment? start,
    MainAxisAlignment? end,
    MainAxisAlignment? center,
  }) {
    if (center != null) return center;

    final isRtl = isRTL(context);
    return isRtl
        ? (end ?? MainAxisAlignment.end)
        : (start ?? MainAxisAlignment.start);
  }

  /// Get border radius based on text direction
  static BorderRadius getBorderRadius(
    BuildContext context, {
    double? topStart,
    double? topEnd,
    double? bottomStart,
    double? bottomEnd,
    double? all,
  }) {
    if (all != null) {
      return BorderRadius.circular(all);
    }

    final isRtl = isRTL(context);
    return BorderRadius.only(
      topLeft: Radius.circular(isRtl ? (topEnd ?? 0) : (topStart ?? 0)),
      topRight: Radius.circular(isRtl ? (topStart ?? 0) : (topEnd ?? 0)),
      bottomLeft:
          Radius.circular(isRtl ? (bottomEnd ?? 0) : (bottomStart ?? 0)),
      bottomRight:
          Radius.circular(isRtl ? (bottomStart ?? 0) : (bottomEnd ?? 0)),
    );
  }

  /// Get icon based on text direction
  static IconData getDirectionalIcon(
    BuildContext context,
    IconData arrow_back, {
    IconData? start,
    IconData? end,
    IconData? ltr,
    IconData? rtl,
  }) {
    final isRtl = isRTL(context);

    if (isRtl) {
      return end ?? rtl ?? Icons.arrow_back_ios;
    } else {
      return start ?? ltr ?? Icons.arrow_forward_ios;
    }
  }

  /// Get reverse icon based on text direction
  static IconData getReverseDirectionalIcon(
    BuildContext context, {
    IconData? start,
    IconData? end,
    IconData? ltr,
    IconData? rtl,
  }) {
    final isRtl = isRTL(context);

    if (isRtl) {
      return start ?? ltr ?? Icons.arrow_forward_ios;
    } else {
      return end ?? rtl ?? Icons.arrow_back_ios;
    }
  }

  /// Format number based on locale
  static String formatNumber(BuildContext context, num number) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'ar') {
      // Convert to Arabic-Indic numerals
      return number.toString().replaceAllMapped(
            RegExp(r'[0-9]'),
            (match) => String.fromCharCode(
                match.group(0)!.codeUnitAt(0) + 0x0660 - 0x0030),
          );
    }
    return number.toString();
  }

  /// Format date based on locale
  static String formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'ar') {
      // Use Arabic date format
      return '${date.day}/${date.month}/${date.year}';
    }
    return '${date.month}/${date.day}/${date.year}';
  }

  /// Get text style with proper direction
  static TextStyle getTextStyle(BuildContext context, TextStyle baseStyle) {
    return baseStyle;
  }

  /// Wrap widget with proper direction
  static Widget wrapWithDirection(BuildContext context, Widget child) {
    return Directionality(
      textDirection: getTextDirection(context),
      child: child,
    );
  }

  /// Get flex alignment for RTL
  static MainAxisAlignment getFlexAlignment(
    BuildContext context, {
    MainAxisAlignment? start,
    MainAxisAlignment? end,
    MainAxisAlignment? center,
  }) {
    if (center != null) return center;

    final isRtl = isRTL(context);
    return isRtl
        ? (end ?? MainAxisAlignment.end)
        : (start ?? MainAxisAlignment.start);
  }
}
