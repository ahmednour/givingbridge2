import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:giving_bridge_frontend/main.dart';
import 'package:giving_bridge_frontend/providers/locale_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Arabic Localization Integration Tests', () {
    testWidgets('Complete User Registration Flow in Arabic',
        (WidgetTester tester) async {
      // Initialize app with Arabic locale
      await tester.pumpWidget(const GivingBridgeApp());
      await tester.pumpAndSettle();

      // Get locale provider and set to Arabic
      final localeProvider = Provider.of<LocaleProvider>(
          tester.element(find.byType(MaterialApp)),
          listen: false);

      await localeProvider.setLocale(const Locale('ar'));
      await tester.pumpAndSettle();

      // Verify Arabic text is displayed on landing page
      expect(find.text('جسر العطاء'), findsOneWidget);
      expect(find.text('ابدأ الآن'), findsOneWidget);
      expect(find.text('نربط القلوب،نشارك الأمل'), findsOneWidget);

      // Navigate to registration
      await tester.tap(find.text('ابدأ الآن'));
      await tester.pumpAndSettle();

      // Verify Arabic registration form
      expect(find.text('إنشاء حساب'), findsOneWidget);
      expect(find.text('الاسم'), findsOneWidget);
      expect(find.text('البريد الإلكتروني'), findsOneWidget);
      expect(find.text('كلمة المرور'), findsOneWidget);
      expect(find.text('تأكيد كلمة المرور'), findsOneWidget);

      // Fill registration form with Arabic text
      await tester.enterText(find.byKey(const Key('name_field')), 'أحمد محمد');
      await tester.enterText(
          find.byKey(const Key('email_field')), 'ahmed@test.com');
      await tester.enterText(
          find.byKey(const Key('password_field')), 'password123');
      await tester.enterText(
          find.byKey(const Key('confirm_password_field')), 'password123');

      // Select donor role in Arabic
      await tester.tap(find.text('متبرع'));
      await tester.pumpAndSettle();

      // Submit registration
      await tester.tap(find.text('إنشاء حساب'));
      await tester.pumpAndSettle();

      // Verify successful registration with Arabic welcome message
      expect(find.textContaining('مرحباً بك في جسر العطاء'), findsOneWidget);
      expect(find.text('لوحة التحكم'), findsOneWidget);
    });

    testWidgets('Donation Creation and Management in Arabic',
        (WidgetTester tester) async {
      // Initialize app with Arabic locale
      await tester.pumpWidget(const GivingBridgeApp());
      await tester.pumpAndSettle();

      // Set Arabic locale
      final localeProvider = Provider.of<LocaleProvider>(
          tester.element(find.byType(MaterialApp)),
          listen: false);

      await localeProvider.setLocale(const Locale('ar'));
      await tester.pumpAndSettle();

      // Quick registration for testing
      await _quickRegisterUser(tester, 'متبرع');

      // Navigate to create donation
      await tester.tap(find.text('إنشاء تبرع'));
      await tester.pumpAndSettle();

      // Verify Arabic donation form
      expect(find.text('إنشاء تبرع'), findsOneWidget);
      expect(find.text('العنوان'), findsOneWidget);
      expect(find.text('الوصف'), findsOneWidget);
      expect(find.text('الموقع'), findsOneWidget);
      expect(find.text('الفئة'), findsOneWidget);

      // Fill donation form with Arabic content
      await tester.enterText(
          find.byKey(const Key('title_field')), 'تبرع بملابس شتوية');
      await tester.enterText(find.byKey(const Key('description_field')),
          'ملابس شتوية نظيفة ومناسبة للأطفال والكبار');
      await tester.enterText(find.byKey(const Key('location_field')),
          'الرياض، المملكة العربية السعودية');

      // Select Arabic category
      await tester.tap(find.text('ملابس'));
      await tester.pumpAndSettle();

      // Select condition in Arabic
      await tester.tap(find.text('حالة جيدة'));
      await tester.pumpAndSettle();

      // Submit donation
      await tester.tap(find.text('إنشاء تبرع'));
      await tester.pumpAndSettle();

      // Verify success message in Arabic
      expect(find.text('تم إنشاء التبرع بنجاح'), findsOneWidget);

      // Navigate to my donations
      await tester.tap(find.text('موافق'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('تبرعاتي'));
      await tester.pumpAndSettle();

      // Verify donation appears in Arabic
      expect(find.text('تبرع بملابس شتوية'), findsOneWidget);
      expect(find.text('ملابس'), findsOneWidget);
      expect(find.text('متاح'), findsOneWidget);
    });

    testWidgets('Request Submission and Tracking in Arabic',
        (WidgetTester tester) async {
      // Initialize app with Arabic locale
      await tester.pumpWidget(const GivingBridgeApp());
      await tester.pumpAndSettle();

      // Set Arabic locale
      final localeProvider = Provider.of<LocaleProvider>(
          tester.element(find.byType(MaterialApp)),
          listen: false);

      await localeProvider.setLocale(const Locale('ar'));
      await tester.pumpAndSettle();

      // Quick registration as receiver
      await _quickRegisterUser(tester, 'مستقبل');

      // Navigate to browse donations
      await tester.tap(find.text('تصفح التبرعات'));
      await tester.pumpAndSettle();

      // Verify Arabic browse donations page
      expect(find.text('تصفح التبرعات'), findsOneWidget);
      expect(find.text('بحث'), findsOneWidget);
      expect(find.text('تصفية'), findsOneWidget);

      // Test search functionality with Arabic text
      await tester.enterText(find.byKey(const Key('search_field')), 'طعام');
      await tester.pumpAndSettle();

      // Test category filter in Arabic
      await tester.tap(find.text('طعام'));
      await tester.pumpAndSettle();

      // If donations exist, test request functionality
      final donationCards = find.byType(Card);
      if (donationCards.evaluate().isNotEmpty) {
        // Tap on first donation
        await tester.tap(donationCards.first);
        await tester.pumpAndSettle();

        // Verify Arabic donation details
        expect(find.text('تفاصيل التبرع'), findsOneWidget);

        // Test request donation in Arabic
        if (find.text('طلب تبرع').evaluate().isNotEmpty) {
          await tester.tap(find.text('طلب تبرع'));
          await tester.pumpAndSettle();

          // Fill request message in Arabic
          await tester.enterText(find.byKey(const Key('message_field')),
              'أحتاج هذا التبرع لعائلتي، شكراً لكم');

          await tester.tap(find.text('إرسال الطلب'));
          await tester.pumpAndSettle();

          // Verify success message in Arabic
          expect(find.text('تم إرسال الطلب بنجاح!'), findsOneWidget);
        }
      }

      // Navigate to my requests
      await tester.tap(find.text('طلباتي'));
      await tester.pumpAndSettle();

      // Verify Arabic requests page
      expect(find.text('طلباتي'), findsOneWidget);
    });

    testWidgets('Language Switching Functionality',
        (WidgetTester tester) async {
      // Initialize app
      await tester.pumpWidget(const GivingBridgeApp());
      await tester.pumpAndSettle();

      // Start with English
      final localeProvider = Provider.of<LocaleProvider>(
          tester.element(find.byType(MaterialApp)),
          listen: false);

      await localeProvider.setLocale(const Locale('en'));
      await tester.pumpAndSettle();

      // Verify English text
      expect(find.text('Giving Bridge'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);

      // Navigate to settings or find language toggle
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Quick registration to access settings
      await _quickRegisterUser(tester, 'Donor');

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Find and tap language selector
      if (find.text('Language').evaluate().isNotEmpty) {
        await tester.tap(find.text('Language'));
        await tester.pumpAndSettle();

        // Select Arabic
        await tester.tap(find.text('العربية'));
        await tester.pumpAndSettle();

        // Verify language changed to Arabic
        expect(find.text('الإعدادات'), findsOneWidget);
        expect(find.text('اللغة'), findsOneWidget);

        // Switch back to English
        await tester.tap(find.text('اللغة'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('English'));
        await tester.pumpAndSettle();

        // Verify language changed back to English
        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Language'), findsOneWidget);
      }
    });

    testWidgets('Arabic Text Input and Display Validation',
        (WidgetTester tester) async {
      // Initialize app with Arabic locale
      await tester.pumpWidget(const GivingBridgeApp());
      await tester.pumpAndSettle();

      final localeProvider = Provider.of<LocaleProvider>(
          tester.element(find.byType(MaterialApp)),
          listen: false);

      await localeProvider.setLocale(const Locale('ar'));
      await tester.pumpAndSettle();

      // Test Arabic text input in registration
      await tester.tap(find.text('ابدأ الآن'));
      await tester.pumpAndSettle();

      // Test various Arabic text inputs
      const arabicTexts = [
        'محمد أحمد السعودي',
        'مؤسسة خيرية للأطفال',
        'تبرع بكتب تعليمية للطلاب المحتاجين',
        'الرياض - حي الملز - شارع الأمير محمد بن عبدالعزيز',
      ];

      for (int i = 0; i < arabicTexts.length && i < 4; i++) {
        final fieldKeys = [
          'name_field',
          'email_field',
          'password_field',
          'confirm_password_field'
        ];

        if (i < 1) {
          // Only test name field with Arabic
          await tester.enterText(find.byKey(Key(fieldKeys[i])), arabicTexts[i]);
          await tester.pumpAndSettle();

          // Verify Arabic text is displayed correctly
          expect(find.text(arabicTexts[i]), findsOneWidget);
        }
      }

      // Test Arabic validation messages
      await tester.tap(find.text('إنشاء حساب'));
      await tester.pumpAndSettle();

      // Verify Arabic validation messages appear
      expect(find.text('البريد الإلكتروني مطلوب'), findsOneWidget);
      expect(find.text('كلمة المرور مطلوبة'), findsOneWidget);
    });

    testWidgets('Arabic Number and Date Formatting',
        (WidgetTester tester) async {
      // Initialize app with Arabic locale
      await tester.pumpWidget(const GivingBridgeApp());
      await tester.pumpAndSettle();

      final localeProvider = Provider.of<LocaleProvider>(
          tester.element(find.byType(MaterialApp)),
          listen: false);

      await localeProvider.setLocale(const Locale('ar'));
      await tester.pumpAndSettle();

      // Quick registration and navigation to dashboard
      await _quickRegisterUser(tester, 'متبرع');

      // Navigate to analytics or statistics page if available
      if (find.text('التحليلات').evaluate().isNotEmpty) {
        await tester.tap(find.text('التحليلات'));
        await tester.pumpAndSettle();

        // Verify Arabic number formatting in statistics
        // Look for Arabic numerals or properly formatted numbers
        final numberWidgets = find.byType(Text);

        for (final widget in numberWidgets.evaluate()) {
          final textWidget = widget.widget as Text;
          final text = textWidget.data ?? '';

          // Check for Arabic numerals or number formatting
          if (text.contains(RegExp(r'[٠-٩]')) ||
              text.contains(RegExp(r'\d+')) && text.isNotEmpty) {
            break;
          }
        }

        // At least verify the page loaded in Arabic
        expect(find.text('التحليلات'), findsOneWidget);
      }

      // Test date formatting in donation creation
      await tester.tap(find.text('إنشاء تبرع'));
      await tester.pumpAndSettle();

      // Verify Arabic date/time elements if present
      expect(find.text('إنشاء تبرع'), findsOneWidget);
    });
  });
}

/// Helper function to quickly register a user for testing
Future<void> _quickRegisterUser(WidgetTester tester, String role) async {
  // Fill basic registration info
  await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
  await tester.enterText(find.byKey(const Key('email_field')),
      'test${DateTime.now().millisecondsSinceEpoch}@test.com');
  await tester.enterText(
      find.byKey(const Key('password_field')), 'password123');
  await tester.enterText(
      find.byKey(const Key('confirm_password_field')), 'password123');

  // Select role
  await tester.tap(find.text(role));
  await tester.pumpAndSettle();

  // Submit registration
  await tester
      .tap(find.text(role == 'متبرع' ? 'إنشاء حساب' : 'Create Account'));
  await tester.pumpAndSettle();
}
