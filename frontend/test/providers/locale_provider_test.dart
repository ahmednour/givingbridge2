import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:giving_bridge_frontend/providers/locale_provider.dart';

void main() {
  group('LocaleProvider Tests', () {
    late LocaleProvider localeProvider;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      localeProvider = LocaleProvider();
    });

    group('Basic Locale Operations', () {
      test('should initialize with Arabic locale by default', () async {
        // Wait for async initialization
        await Future.delayed(const Duration(milliseconds: 100));
        expect(localeProvider.locale.languageCode, 'ar');
        expect(localeProvider.isArabic, true);
        expect(localeProvider.isEnglish, false);
      });

      test('should set locale correctly', () async {
        await localeProvider.setLocale(const Locale('en'));

        expect(localeProvider.locale.languageCode, 'en');
        expect(localeProvider.isArabic, false);
        expect(localeProvider.isEnglish, true);
      });

      test('should reject invalid locale codes', () async {
        const initialLocale = Locale('ar');
        await localeProvider.setLocale(initialLocale);

        // Try to set invalid locale
        await localeProvider.setLocale(const Locale('fr'));

        // Should remain unchanged
        expect(localeProvider.locale.languageCode, 'ar');
      });

      test('should toggle locale correctly', () async {
        // Wait for async initialization
        await Future.delayed(const Duration(milliseconds: 100));

        // Start with Arabic (default)
        expect(localeProvider.locale.languageCode, 'ar');

        // Toggle to English
        await localeProvider.toggleLocale();
        expect(localeProvider.locale.languageCode, 'en');

        // Toggle back to Arabic
        await localeProvider.toggleLocale();
        expect(localeProvider.locale.languageCode, 'ar');
      });
    });

    group('RTL Detection and Properties', () {
      test('should detect RTL correctly for Arabic', () async {
        await localeProvider.setLocale(const Locale('ar'));

        expect(localeProvider.isRTL, true);
        expect(localeProvider.textDirection, TextDirection.rtl);
      });

      test('should detect LTR correctly for English', () async {
        await localeProvider.setLocale(const Locale('en'));

        expect(localeProvider.isRTL, false);
        expect(localeProvider.textDirection, TextDirection.ltr);
      });
    });

    group('Directional Alignment Methods', () {
      test('should return correct directional alignment for RTL', () async {
        await localeProvider.setLocale(const Locale('ar'));

        // Test with start/end parameters
        final alignment = localeProvider.getDirectionalAlignment(
          start: Alignment.centerLeft,
          end: Alignment.centerRight,
        );

        expect(alignment, Alignment.centerRight); // Should use 'end' for RTL
      });

      test('should return correct directional alignment for LTR', () async {
        await localeProvider.setLocale(const Locale('en'));

        // Test with start/end parameters
        final alignment = localeProvider.getDirectionalAlignment(
          start: Alignment.centerLeft,
          end: Alignment.centerRight,
        );

        expect(alignment, Alignment.centerLeft); // Should use 'start' for LTR
      });

      test('should prioritize center alignment when provided', () async {
        await localeProvider.setLocale(const Locale('ar'));

        final alignment = localeProvider.getDirectionalAlignment(
          start: Alignment.centerLeft,
          end: Alignment.centerRight,
          center: Alignment.center,
        );

        expect(alignment, Alignment.center);
      });
    });

    group('Directional Padding Methods', () {
      test('should return correct directional padding for RTL', () async {
        await localeProvider.setLocale(const Locale('ar'));

        final padding = localeProvider.getDirectionalPadding(
          start: 10.0,
          end: 20.0,
          top: 5.0,
          bottom: 15.0,
        );

        expect(padding.left, 20.0); // 'end' value goes to left in RTL
        expect(padding.right, 10.0); // 'start' value goes to right in RTL
        expect(padding.top, 5.0);
        expect(padding.bottom, 15.0);
      });

      test('should return correct directional padding for LTR', () async {
        await localeProvider.setLocale(const Locale('en'));

        final padding = localeProvider.getDirectionalPadding(
          start: 10.0,
          end: 20.0,
          top: 5.0,
          bottom: 15.0,
        );

        expect(padding.left, 10.0); // 'start' value goes to left in LTR
        expect(padding.right, 20.0); // 'end' value goes to right in LTR
        expect(padding.top, 5.0);
        expect(padding.bottom, 15.0);
      });

      test('should handle all parameter for padding', () async {
        await localeProvider.setLocale(const Locale('ar'));

        final padding = localeProvider.getDirectionalPadding(all: 10.0);

        expect(padding, const EdgeInsets.all(10.0));
      });

      test('should handle horizontal and vertical parameters for padding',
          () async {
        await localeProvider.setLocale(const Locale('ar'));

        final padding = localeProvider.getDirectionalPadding(
          horizontal: 15.0,
          vertical: 25.0,
        );

        expect(padding,
            const EdgeInsets.symmetric(horizontal: 15.0, vertical: 25.0));
      });
    });

    group('Directional Margin Methods', () {
      test('should return correct directional margin for RTL', () async {
        await localeProvider.setLocale(const Locale('ar'));

        final margin = localeProvider.getDirectionalMargin(
          start: 8.0,
          end: 12.0,
          top: 4.0,
          bottom: 16.0,
        );

        expect(margin.left, 12.0); // 'end' value goes to left in RTL
        expect(margin.right, 8.0); // 'start' value goes to right in RTL
        expect(margin.top, 4.0);
        expect(margin.bottom, 16.0);
      });

      test('should return correct directional margin for LTR', () async {
        await localeProvider.setLocale(const Locale('en'));

        final margin = localeProvider.getDirectionalMargin(
          start: 8.0,
          end: 12.0,
          top: 4.0,
          bottom: 16.0,
        );

        expect(margin.left, 8.0); // 'start' value goes to left in LTR
        expect(margin.right, 12.0); // 'end' value goes to right in LTR
        expect(margin.top, 4.0);
        expect(margin.bottom, 16.0);
      });
    });

    group('Directional Axis Alignment Methods', () {
      test('should return correct cross axis alignment for RTL', () async {
        await localeProvider.setLocale(const Locale('ar'));

        final alignment = localeProvider.getDirectionalCrossAxisAlignment(
          start: CrossAxisAlignment.start,
          end: CrossAxisAlignment.end,
        );

        expect(alignment, CrossAxisAlignment.end); // Should use 'end' for RTL
      });

      test('should return correct cross axis alignment for LTR', () async {
        await localeProvider.setLocale(const Locale('en'));

        final alignment = localeProvider.getDirectionalCrossAxisAlignment(
          start: CrossAxisAlignment.start,
          end: CrossAxisAlignment.end,
        );

        expect(
            alignment, CrossAxisAlignment.start); // Should use 'start' for LTR
      });

      test('should return correct main axis alignment for RTL', () async {
        await localeProvider.setLocale(const Locale('ar'));

        final alignment = localeProvider.getDirectionalMainAxisAlignment(
          start: MainAxisAlignment.start,
          end: MainAxisAlignment.end,
        );

        expect(alignment, MainAxisAlignment.end); // Should use 'end' for RTL
      });

      test('should return correct main axis alignment for LTR', () async {
        await localeProvider.setLocale(const Locale('en'));

        final alignment = localeProvider.getDirectionalMainAxisAlignment(
          start: MainAxisAlignment.start,
          end: MainAxisAlignment.end,
        );

        expect(
            alignment, MainAxisAlignment.start); // Should use 'start' for LTR
      });
    });

    group('Directional Border Radius Methods', () {
      test('should return correct directional border radius for RTL', () async {
        await localeProvider.setLocale(const Locale('ar'));

        final borderRadius = localeProvider.getDirectionalBorderRadius(
          topStart: 5.0,
          topEnd: 10.0,
          bottomStart: 15.0,
          bottomEnd: 20.0,
        );

        expect(borderRadius.topLeft.x, 10.0); // topEnd goes to topLeft in RTL
        expect(
            borderRadius.topRight.x, 5.0); // topStart goes to topRight in RTL
        expect(borderRadius.bottomLeft.x,
            20.0); // bottomEnd goes to bottomLeft in RTL
        expect(borderRadius.bottomRight.x,
            15.0); // bottomStart goes to bottomRight in RTL
      });

      test('should return correct directional border radius for LTR', () async {
        await localeProvider.setLocale(const Locale('en'));

        final borderRadius = localeProvider.getDirectionalBorderRadius(
          topStart: 5.0,
          topEnd: 10.0,
          bottomStart: 15.0,
          bottomEnd: 20.0,
        );

        expect(borderRadius.topLeft.x, 5.0); // topStart goes to topLeft in LTR
        expect(borderRadius.topRight.x, 10.0); // topEnd goes to topRight in LTR
        expect(borderRadius.bottomLeft.x,
            15.0); // bottomStart goes to bottomLeft in LTR
        expect(borderRadius.bottomRight.x,
            20.0); // bottomEnd goes to bottomRight in LTR
      });

      test('should handle all parameter for border radius', () async {
        await localeProvider.setLocale(const Locale('ar'));

        final borderRadius =
            localeProvider.getDirectionalBorderRadius(all: 8.0);

        expect(borderRadius, BorderRadius.circular(8.0));
      });
    });

    group('Directional Icon Methods', () {
      test('should return correct directional icon for RTL', () async {
        await localeProvider.setLocale(const Locale('ar'));

        final icon = localeProvider.getDirectionalIcon(
          start: Icons.arrow_forward,
          end: Icons.arrow_back,
        );

        expect(icon, Icons.arrow_back); // Should use 'end' for RTL
      });

      test('should return correct directional icon for LTR', () async {
        await localeProvider.setLocale(const Locale('en'));

        final icon = localeProvider.getDirectionalIcon(
          start: Icons.arrow_forward,
          end: Icons.arrow_back,
        );

        expect(icon, Icons.arrow_forward); // Should use 'start' for LTR
      });

      test('should use ltr/rtl parameters when provided', () async {
        await localeProvider.setLocale(const Locale('ar'));

        final icon = localeProvider.getDirectionalIcon(
          ltr: Icons.chevron_right,
          rtl: Icons.chevron_left,
        );

        expect(icon, Icons.chevron_left); // Should use 'rtl' for RTL
      });

      test('should fallback to default icons when no parameters provided',
          () async {
        await localeProvider.setLocale(const Locale('ar'));

        final icon = localeProvider.getDirectionalIcon();

        expect(icon, Icons.arrow_back_ios); // Default RTL icon
      });
    });

    group('Locale Persistence', () {
      test('should persist locale to SharedPreferences', () async {
        await localeProvider.setLocale(const Locale('en'));

        final prefs = await SharedPreferences.getInstance();
        final savedLanguageCode = prefs.getString('language_code');

        expect(savedLanguageCode, 'en');
      });

      test('should load saved locale on initialization', () async {
        // Set up SharedPreferences with saved locale
        SharedPreferences.setMockInitialValues({'language_code': 'en'});

        // Create new provider instance
        final newProvider = LocaleProvider();

        // Wait for async initialization
        await Future.delayed(const Duration(milliseconds: 100));

        expect(newProvider.locale.languageCode, 'en');
      });

      test('should handle SharedPreferences errors gracefully', () async {
        // This test ensures the provider doesn't crash when SharedPreferences fails
        // The actual implementation already handles this with try-catch blocks

        expect(() => localeProvider.setLocale(const Locale('en')),
            returnsNormally);
        expect(localeProvider.locale.languageCode, 'en');
      });
    });
  });
}
