import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Service for handling cultural formatting of numbers, dates, and currency for Arabic locale
class CulturalFormattingService {
  // Arabic-Indic digits mapping
  static const Map<String, String> _arabicNumerals = {
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩',
  };

  // Western digits mapping (reverse of Arabic numerals)
  static const Map<String, String> _westernNumerals = {
    '٠': '0',
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
  };

  /// Convert Western numerals to Arabic-Indic numerals
  static String toArabicNumerals(String input) {
    String result = input;
    _arabicNumerals.forEach((western, arabic) {
      result = result.replaceAll(western, arabic);
    });
    return result;
  }

  /// Convert Arabic-Indic numerals to Western numerals
  static String toWesternNumerals(String input) {
    String result = input;
    _westernNumerals.forEach((arabic, western) {
      result = result.replaceAll(arabic, western);
    });
    return result;
  }

  /// Format number based on locale preference
  static String formatNumber({
    required num number,
    required Locale locale,
    bool useArabicNumerals = true,
    int? decimalPlaces,
  }) {
    final formatter = NumberFormat.decimalPattern(locale.toString());
    
    if (decimalPlaces != null) {
      formatter.minimumFractionDigits = decimalPlaces;
      formatter.maximumFractionDigits = decimalPlaces;
    }
    
    String formatted = formatter.format(number);
    
    // Convert to Arabic numerals if Arabic locale and preference is set
    if (locale.languageCode == 'ar' && useArabicNumerals) {
      formatted = toArabicNumerals(formatted);
    }
    
    return formatted;
  }

  /// Format currency for Arabic locale (Saudi Riyal)
  static String formatCurrency({
    required double amount,
    required Locale locale,
    String currencyCode = 'SAR',
    bool useArabicNumerals = true,
    bool showCurrencySymbol = true,
  }) {
    if (locale.languageCode == 'ar') {
      // Arabic currency formatting
      final formatter = NumberFormat.currency(
        locale: 'ar_SA',
        symbol: showCurrencySymbol ? 'ر.س' : '',
        decimalDigits: 2,
      );
      
      String formatted = formatter.format(amount);
      
      if (useArabicNumerals) {
        formatted = toArabicNumerals(formatted);
      }
      
      // Adjust currency symbol position for Arabic
      if (showCurrencySymbol) {
        formatted = formatted.replaceAll('ر.س', '');
        formatted = 'ر.س $formatted';
      }
      
      return formatted;
    } else {
      // English currency formatting
      final formatter = NumberFormat.currency(
        locale: 'en_US',
        symbol: showCurrencySymbol ? 'SAR ' : '',
        decimalDigits: 2,
      );
      
      return formatter.format(amount);
    }
  }

  /// Format date according to Arabic cultural preferences
  static String formatDate({
    required DateTime date,
    required Locale locale,
    DateFormat? customFormat,
    bool useArabicNumerals = true,
  }) {
    DateFormat formatter;
    
    if (customFormat != null) {
      formatter = customFormat;
    } else if (locale.languageCode == 'ar') {
      // Arabic date format: day/month/year
      formatter = DateFormat('dd/MM/yyyy', 'ar');
    } else {
      // English date format
      formatter = DateFormat('MM/dd/yyyy', 'en');
    }
    
    String formatted = formatter.format(date);
    
    // Convert to Arabic numerals if Arabic locale
    if (locale.languageCode == 'ar' && useArabicNumerals) {
      formatted = toArabicNumerals(formatted);
    }
    
    return formatted;
  }

  /// Format time according to cultural preferences
  static String formatTime({
    required DateTime dateTime,
    required Locale locale,
    bool use24HourFormat = false,
    bool useArabicNumerals = true,
  }) {
    DateFormat formatter;
    
    if (locale.languageCode == 'ar') {
      formatter = use24HourFormat 
          ? DateFormat('HH:mm', 'ar')
          : DateFormat('h:mm a', 'ar');
    } else {
      formatter = use24HourFormat 
          ? DateFormat('HH:mm', 'en')
          : DateFormat('h:mm a', 'en');
    }
    
    String formatted = formatter.format(dateTime);
    
    // Convert to Arabic numerals if Arabic locale
    if (locale.languageCode == 'ar' && useArabicNumerals) {
      formatted = toArabicNumerals(formatted);
    }
    
    return formatted;
  }

  /// Format date and time together
  static String formatDateTime({
    required DateTime dateTime,
    required Locale locale,
    bool use24HourFormat = false,
    bool useArabicNumerals = true,
  }) {
    final date = formatDate(
      date: dateTime,
      locale: locale,
      useArabicNumerals: useArabicNumerals,
    );
    
    final time = formatTime(
      dateTime: dateTime,
      locale: locale,
      use24HourFormat: use24HourFormat,
      useArabicNumerals: useArabicNumerals,
    );
    
    if (locale.languageCode == 'ar') {
      return '$date في $time'; // "date at time" in Arabic
    } else {
      return '$date at $time';
    }
  }

  /// Format percentage for Arabic locale
  static String formatPercentage({
    required double percentage,
    required Locale locale,
    int decimalPlaces = 1,
    bool useArabicNumerals = true,
  }) {
    final formatter = NumberFormat.percentPattern(locale.toString());
    formatter.minimumFractionDigits = decimalPlaces;
    formatter.maximumFractionDigits = decimalPlaces;
    
    String formatted = formatter.format(percentage / 100);
    
    // Convert to Arabic numerals if Arabic locale
    if (locale.languageCode == 'ar' && useArabicNumerals) {
      formatted = toArabicNumerals(formatted);
    }
    
    return formatted;
  }

  /// Format phone number for Saudi Arabia
  static String formatPhoneNumber({
    required String phoneNumber,
    required Locale locale,
    bool useArabicNumerals = true,
  }) {
    // Remove any non-digit characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Format Saudi phone number
    if (cleaned.startsWith('966')) {
      // International format
      cleaned = cleaned.substring(3);
    }
    
    if (cleaned.startsWith('0')) {
      // Remove leading zero
      cleaned = cleaned.substring(1);
    }
    
    // Format as: 5XX XXX XXXX
    if (cleaned.length == 9) {
      final formatted = '${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6)}';
      
      if (locale.languageCode == 'ar' && useArabicNumerals) {
        return toArabicNumerals(formatted);
      }
      
      return formatted;
    }
    
    // Return original if can't format
    return phoneNumber;
  }

  /// Get culturally appropriate relative time formatting
  static String formatRelativeTime({
    required DateTime dateTime,
    required Locale locale,
    bool useArabicNumerals = true,
  }) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (locale.languageCode == 'ar') {
      if (difference.inMinutes < 1) {
        return 'الآن';
      } else if (difference.inMinutes < 60) {
        final minutes = difference.inMinutes.toString();
        final arabicMinutes = useArabicNumerals ? toArabicNumerals(minutes) : minutes;
        return 'منذ $arabicMinutes دقيقة';
      } else if (difference.inHours < 24) {
        final hours = difference.inHours.toString();
        final arabicHours = useArabicNumerals ? toArabicNumerals(hours) : hours;
        return 'منذ $arabicHours ساعة';
      } else if (difference.inDays < 7) {
        final days = difference.inDays.toString();
        final arabicDays = useArabicNumerals ? toArabicNumerals(days) : days;
        return 'منذ $arabicDays يوم';
      } else {
        return formatDate(date: dateTime, locale: locale, useArabicNumerals: useArabicNumerals);
      }
    } else {
      // English relative time
      if (difference.inMinutes < 1) {
        return 'now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minutes ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hours ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return formatDate(date: dateTime, locale: locale);
      }
    }
  }

  /// Parse Arabic numerals input to Western numerals for processing
  static String parseArabicInput(String input) {
    return toWesternNumerals(input);
  }

  /// Get appropriate decimal separator for locale
  static String getDecimalSeparator(Locale locale) {
    if (locale.languageCode == 'ar') {
      return '٫'; // Arabic decimal separator
    }
    return '.';
  }

  /// Get appropriate thousands separator for locale
  static String getThousandsSeparator(Locale locale) {
    if (locale.languageCode == 'ar') {
      return '٬'; // Arabic thousands separator
    }
    return ',';
  }
}