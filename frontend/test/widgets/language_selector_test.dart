import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../lib/widgets/language_selector.dart';
import '../../lib/providers/locale_provider.dart';
import '../../lib/l10n/app_localizations.dart';
import '../../lib/core/theme/app_theme.dart';

void main() {
  group('LanguageSelector Widget Tests', () {
    late LocaleProvider localeProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({'language_code': 'ar'});
      localeProvider = LocaleProvider();
      // Wait for initialization to complete
      await Future.delayed(const Duration(milliseconds: 100));
    });

    Widget createTestWidget({bool showAsButton = false}) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('ar', ''),
        ],
        theme: AppTheme.lightTheme,
        home: ChangeNotifierProvider<LocaleProvider>.value(
          value: localeProvider,
          child: Scaffold(
            body: LanguageSelector(showAsButton: showAsButton),
          ),
        ),
      );
    }

    testWidgets('should display language dropdown by default', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should find dropdown button
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    testWidgets('should display language button when showAsButton is true', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(showAsButton: true));
      await tester.pumpAndSettle();

      // Should find InkWell (button)
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('should show language modal when button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(showAsButton: true));
      await tester.pumpAndSettle();

      // Tap the language button
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      // Should show modal bottom sheet
      expect(find.text('Select your preferred language'), findsOneWidget);
    });

    testWidgets('should change locale when language option is selected', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initial locale should be Arabic (default)
      expect(localeProvider.locale.languageCode, 'ar');

      // Tap dropdown to open options
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Select English option
      await tester.tap(find.text('English').last);
      await tester.pumpAndSettle();

      // Locale should now be English
      expect(localeProvider.locale.languageCode, 'en');
    });
  });

  group('LanguageToggleButton Widget Tests', () {
    late LocaleProvider localeProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({'language_code': 'ar'});
      localeProvider = LocaleProvider();
      // Wait for initialization to complete
      await Future.delayed(const Duration(milliseconds: 100));
    });

    Widget createTestWidget() {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('ar', ''),
        ],
        theme: AppTheme.lightTheme,
        home: ChangeNotifierProvider<LocaleProvider>.value(
          value: localeProvider,
          child: const Scaffold(
            body: LanguageToggleButton(),
          ),
        ),
      );
    }

    testWidgets('should display toggle button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should find IconButton
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('should toggle language when pressed', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initial locale should be Arabic
      expect(localeProvider.locale.languageCode, 'ar');

      // Tap the toggle button
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Locale should now be English
      expect(localeProvider.locale.languageCode, 'en');

      // Tap again to toggle back
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Locale should be Arabic again
      expect(localeProvider.locale.languageCode, 'ar');
    });

    testWidgets('should show correct text based on current locale', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show 'EN' when current locale is Arabic
      expect(find.text('EN'), findsOneWidget);

      // Toggle to English
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Should show Arabic character when current locale is English
      expect(find.text('ع'), findsOneWidget);
    });
  });
}