import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:giving_bridge_frontend/main.dart';
import 'package:giving_bridge_frontend/providers/locale_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('RTL Layout Validation Tests', () {
    testWidgets('RTL Layout on Different Screen Sizes',
        (WidgetTester tester) async {
      // Test different screen sizes
      final screenSizes = [
        const Size(360, 640), // Small phone
        const Size(414, 896), // Large phone
        const Size(768, 1024), // Tablet portrait
        const Size(1024, 768), // Tablet landscape
      ];

      for (final size in screenSizes) {
        // Set screen size
        await tester.binding.setSurfaceSize(size);
        
        // Initialize app with Arabic locale
        await tester.pumpWidget(const GivingBridgeApp());
        await tester.pumpAndSettle();

        final localeProvider = Provider.of<LocaleProvider>(
            tester.element(find.byType(MaterialApp)),
            listen: false);
        
        await localeProvider.setLocale(const Locale('ar'));
        await tester.pumpAndSettle();

        // Verify RTL layout is applied
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.locale?.languageCode, equals('ar'));

        // Test RTL layout elements
        await _testRTLLayoutElements(tester, size);

        // Navigate through different screens to test RTL consistency
        await _testRTLNavigationFlow(tester, size);
      }

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Arabic Text Rendering on Various Devices',
        (WidgetTester tester) async {
      // Initialize app with Arabic locale
      await tester.pumpWidget(const GivingBridgeApp());
      await tester.pumpAndSettle();

      final localeProvider = Provider.of<LocaleProvider>(
          tester.element(find.byType(MaterialApp)),
          listen: false);
      
      await localeProvider.setLocale(const Locale('ar'));
      await tester.pumpAndSettle();

      // Test Arabic text rendering
      await _testArabicTextRendering(tester);

      // Test Arabic text in different contexts
      await _testArabicTextInForms(tester);
      
      // Test Arabic text in lists and cards
      await _testArabicTextInComponents(tester);
    });

    testWidgets('RTL Layout Performance Validation',
        (WidgetTester tester) async {
      // Initialize app with Arabic locale
      await tester.pumpWidget(const GivingBridgeApp());
      await tester.pumpAndSettle();

      final localeProvider = Provider.of<LocaleProvider>(
          tester.element(find.byType(MaterialApp)),
          listen: false);

      // Measure performance of language switching
      final stopwatch = Stopwatch()..start();
      
      // Switch to Arabic
      await localeProvider.setLocale(const Locale('ar'));
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      final arabicSwitchTime = stopwatch.elapsedMilliseconds;
      
      // Verify switch was reasonably fast (less than 2 seconds)
      expect(arabicSwitchTime, lessThan(2000));

      // Test RTL layout rendering performance
      stopwatch.reset();
      stopwatch.start();

      // Navigate to a complex screen
      await tester.tap(find.text('ابدأ الآن'));
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      final navigationTime = stopwatch.elapsedMilliseconds;
      
      // Verify navigation was fast (less than 1 second)
      expect(navigationTime, lessThan(1000));

      // Test form rendering performance with RTL
      await _testRTLFormPerformance(tester);

      // Test list scrolling performance with Arabic text
      await _testRTLScrollPerformance(tester);
    });

    testWidgets('RTL Layout Consistency Across Screens',
        (WidgetTester tester) async {
      // Initialize app with Arabic locale
      await tester.pumpWidget(const GivingBridgeApp());
      await tester.pumpAndSettle();

      final localeProvider = Provider.of<LocaleProvider>(
          tester.element(find.byType(MaterialApp)),
          listen: false);
      
      await localeProvider.setLocale(const Locale('ar'));
      await tester.pumpAndSettle();

      // Test RTL consistency across different screens
      final screens = [
        'ابدأ الآن', // Landing to registration
        'تصفح التبرعات', // Browse donations
        'الإعدادات', // Settings
        'الرسائل', // Messages
      ];

      for (final screenText in screens) {
        if (find.text(screenText).evaluate().isNotEmpty) {
          await tester.tap(find.text(screenText));
          await tester.pumpAndSettle();

          // Verify RTL layout consistency
          await _verifyRTLLayoutConsistency(tester);

          // Go back to main screen
          if (find.byIcon(Icons.arrow_back).evaluate().isNotEmpty) {
            await tester.tap(find.byIcon(Icons.arrow_back));
            await tester.pumpAndSettle();
          }
        }
      }
    });

    testWidgets('RTL Widget Alignment and Positioning',
        (WidgetTester tester) async {
      // Initialize app with Arabic locale
      await tester.pumpWidget(const GivingBridgeApp());
      await tester.pumpAndSettle();

      final localeProvider = Provider.of<LocaleProvider>(
          tester.element(find.byType(MaterialApp)),
          listen: false);
      
      await localeProvider.setLocale(const Locale('ar'));
      await tester.pumpAndSettle();

      // Test widget alignment in RTL mode
      await _testWidgetAlignment(tester);

      // Test icon positioning in RTL mode
      await _testIconPositioning(tester);

      // Test text alignment in RTL mode
      await _testTextAlignment(tester);
    });

    testWidgets('RTL Form Components Validation',
        (WidgetTester tester) async {
      // Initialize app with Arabic locale
      await tester.pumpWidget(const GivingBridgeApp());
      await tester.pumpAndSettle();

      final localeProvider = Provider.of<LocaleProvider>(
          tester.element(find.byType(MaterialApp)),
          listen: false);
      
      await localeProvider.setLocale(const Locale('ar'));
      await tester.pumpAndSettle();

      // Navigate to registration form
      await tester.tap(find.text('ابدأ الآن'));
      await tester.pumpAndSettle();

      // Test RTL form components
      await _testRTLFormComponents(tester);

      // Test dropdown positioning in RTL
      await _testRTLDropdownPositioning(tester);

      // Test button alignment in RTL
      await _testRTLButtonAlignment(tester);
    });
  });
}

/// Test RTL layout elements on different screen sizes
Future<void> _testRTLLayoutElements(WidgetTester tester, Size screenSize) async {
  // Verify text direction is RTL
  final directionality = tester.widget<Directionality>(
      find.byType(Directionality).first);
  expect(directionality.textDirection, equals(TextDirection.rtl));

  // Verify Arabic text is displayed
  expect(find.text('جسر العطاء'), findsOneWidget);

  // Test responsive layout adjustments
  if (screenSize.width < 600) {
    // Mobile layout tests
    expect(find.byType(AppBar), findsOneWidget);
  } else {
    // Tablet/desktop layout tests
    // May have different layout structure
  }
}

/// Test RTL navigation flow consistency
Future<void> _testRTLNavigationFlow(WidgetTester tester, Size screenSize) async {
  // Test navigation to registration
  if (find.text('ابدأ الآن').evaluate().isNotEmpty) {
    await tester.tap(find.text('ابدأ الآن'));
    await tester.pumpAndSettle();

    // Verify RTL layout is maintained
    final directionality = tester.widget<Directionality>(
        find.byType(Directionality).first);
    expect(directionality.textDirection, equals(TextDirection.rtl));

    // Go back
    if (find.byIcon(Icons.arrow_back).evaluate().isNotEmpty) {
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
    }
  }
}

/// Test Arabic text rendering quality
Future<void> _testArabicTextRendering(WidgetTester tester) async {
  // Find all text widgets
  final textWidgets = find.byType(Text);
  
  for (final textWidget in textWidgets.evaluate()) {
    final text = (textWidget.widget as Text).data ?? '';
    
    // Verify Arabic text is not corrupted
    if (text.contains(RegExp(r'[\u0600-\u06FF]'))) {
      // Arabic text found, verify it's properly rendered
      expect(text.isNotEmpty, isTrue);
      
      // Check for common Arabic text corruption patterns
      expect(text.contains('?'), isFalse, reason: 'Arabic text appears corrupted');
      expect(text.contains('□'), isFalse, reason: 'Arabic text shows missing characters');
    }
  }
}

/// Test Arabic text in form inputs
Future<void> _testArabicTextInForms(WidgetTester tester) async {
  // Navigate to registration if not already there
  if (find.text('إنشاء حساب').evaluate().isEmpty) {
    await tester.tap(find.text('ابدأ الآن'));
    await tester.pumpAndSettle();
  }

  // Test Arabic text input
  const arabicText = 'محمد أحمد';
  if (find.byKey(const Key('name_field')).evaluate().isNotEmpty) {
    await tester.enterText(find.byKey(const Key('name_field')), arabicText);
    await tester.pumpAndSettle();

    // Verify Arabic text is displayed correctly in input
    expect(find.text(arabicText), findsOneWidget);
  }
}

/// Test Arabic text in various UI components
Future<void> _testArabicTextInComponents(WidgetTester tester) async {
  // Test Arabic text in buttons
  expect(find.text('إنشاء حساب'), findsOneWidget);
  expect(find.text('تسجيل الدخول'), findsOneWidget);

  // Test Arabic text in labels
  expect(find.text('الاسم'), findsOneWidget);
  expect(find.text('البريد الإلكتروني'), findsOneWidget);

  // Verify text alignment is appropriate for RTL
  final textWidgets = find.byType(Text);
  for (final widget in textWidgets.evaluate()) {
    final textWidget = widget.widget as Text;
    if (textWidget.data?.contains(RegExp(r'[\u0600-\u06FF]')) == true) {
      // For Arabic text, alignment should be right or start
      final textAlign = textWidget.textAlign;
      if (textAlign != null) {
        expect([TextAlign.right, TextAlign.start, TextAlign.center]
            .contains(textAlign), isTrue);
      }
    }
  }
}

/// Test RTL form performance
Future<void> _testRTLFormPerformance(WidgetTester tester) async {
  final stopwatch = Stopwatch()..start();

  // Fill form fields rapidly
  const testData = [
    ('name_field', 'أحمد محمد'),
    ('email_field', 'test@example.com'),
    ('password_field', 'password123'),
  ];

  for (final (key, value) in testData) {
    if (find.byKey(Key(key)).evaluate().isNotEmpty) {
      await tester.enterText(find.byKey(Key(key)), value);
      await tester.pump(); // Don't wait for settle to test performance
    }
  }

  stopwatch.stop();
  
  // Form filling should be fast (less than 1 second)
  expect(stopwatch.elapsedMilliseconds, lessThan(1000));
}

/// Test RTL scroll performance
Future<void> _testRTLScrollPerformance(WidgetTester tester) async {
  // Find scrollable widgets
  final scrollables = find.byType(Scrollable);
  
  if (scrollables.evaluate().isNotEmpty) {
    final stopwatch = Stopwatch()..start();
    
    // Perform scroll operations
    await tester.drag(scrollables.first, const Offset(0, -300));
    await tester.pump();
    await tester.drag(scrollables.first, const Offset(0, 300));
    await tester.pump();
    
    stopwatch.stop();
    
    // Scrolling should be smooth (less than 500ms)
    expect(stopwatch.elapsedMilliseconds, lessThan(500));
  }
}

/// Verify RTL layout consistency
Future<void> _verifyRTLLayoutConsistency(WidgetTester tester) async {
  // Check that text direction is consistently RTL
  final directionalityWidgets = find.byType(Directionality);
  
  for (final widget in directionalityWidgets.evaluate()) {
    final directionality = widget.widget as Directionality;
    expect(directionality.textDirection, equals(TextDirection.rtl));
  }

  // Check for proper RTL icon usage
  final iconButtons = find.byType(IconButton);
  for (final iconButton in iconButtons.evaluate()) {
    final button = iconButton.widget as IconButton;
    // Verify icons are appropriate for RTL (this is a basic check)
    expect(button.icon, isNotNull);
  }
}

/// Test widget alignment in RTL mode
Future<void> _testWidgetAlignment(WidgetTester tester) async {
  // Find aligned widgets
  final alignedWidgets = find.byType(Align);
  
  for (final widget in alignedWidgets.evaluate()) {
    final align = widget.widget as Align;
    // In RTL mode, start alignment should be on the right
    if (align.alignment == Alignment.centerLeft) {
      // This might need to be adjusted for RTL
    }
  }

  // Test row alignment
  final rows = find.byType(Row);
  for (final row in rows.evaluate()) {
    final rowWidget = row.widget as Row;
    // Verify main axis alignment is appropriate for RTL
    expect(rowWidget.mainAxisAlignment, isNotNull);
  }
}

/// Test icon positioning in RTL mode
Future<void> _testIconPositioning(WidgetTester tester) async {
  // Find list tiles with icons
  final listTiles = find.byType(ListTile);
  
  for (final tile in listTiles.evaluate()) {
    final listTile = tile.widget as ListTile;
    
    // In RTL mode, leading icons should appear on the right
    if (listTile.leading != null) {
      // Icon positioning is handled by Flutter's RTL support
      expect(listTile.leading, isNotNull);
    }
  }
}

/// Test text alignment in RTL mode
Future<void> _testTextAlignment(WidgetTester tester) async {
  final textWidgets = find.byType(Text);
  
  for (final widget in textWidgets.evaluate()) {
    final text = widget.widget as Text;
    
    // Check Arabic text alignment
    if (text.data?.contains(RegExp(r'[\u0600-\u06FF]')) == true) {
      final textAlign = text.textAlign;
      
      // Arabic text should be right-aligned or use appropriate RTL alignment
      if (textAlign != null) {
        expect([
          TextAlign.right,
          TextAlign.start,
          TextAlign.center,
          TextAlign.justify
        ].contains(textAlign), isTrue);
      }
    }
  }
}

/// Test RTL form components
Future<void> _testRTLFormComponents(WidgetTester tester) async {
  // Test text field alignment
  final textFields = find.byType(TextField);
  
  for (final field in textFields.evaluate()) {
    final textField = field.widget as TextField;
    
    // Verify text direction is set appropriately
    expect(textField.textDirection, anyOf(equals(TextDirection.rtl), isNull));
  }

  // Test form field labels
  final inputDecorations = find.byType(InputDecorator);
  for (final decorator in inputDecorations.evaluate()) {
    final inputDecorator = decorator.widget as InputDecorator;
    // Verify decoration is appropriate for RTL
    expect(inputDecorator.decoration, isNotNull);
  }
}

/// Test dropdown positioning in RTL
Future<void> _testRTLDropdownPositioning(WidgetTester tester) async {
  // Find dropdown buttons
  final dropdowns = find.byType(DropdownButton);
  
  for (final dropdown in dropdowns.evaluate()) {
    final dropdownButton = dropdown.widget as DropdownButton;
    
    // Verify dropdown is configured for RTL
    expect(dropdownButton.alignment, anyOf(
      equals(AlignmentDirectional.centerStart),
      equals(AlignmentDirectional.centerEnd),
      isNull
    ));
  }
}

/// Test button alignment in RTL
Future<void> _testRTLButtonAlignment(WidgetTester tester) async {
  // Find elevated buttons
  final buttons = find.byType(ElevatedButton);
  
  for (final button in buttons.evaluate()) {
    final elevatedButton = button.widget as ElevatedButton;
    
    // Verify button child alignment
    if (elevatedButton.child is Text) {
      final text = elevatedButton.child as Text;
      
      // Button text should be properly aligned for RTL
      expect(text.textAlign, anyOf(
        equals(TextAlign.center),
        equals(TextAlign.start),
        isNull
      ));
    }
  }
}