import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../lib/core/utils/rtl_utils.dart';
import '../lib/widgets/common/gb_button.dart';
import '../lib/widgets/common/gb_text_field.dart';
import '../lib/widgets/common/web_card.dart';

void main() {
  group('WebCard Tests', () {
    testWidgets('should render card with child content',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WebCard(
              child: Text('Test Content'),
            ),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
      expect(find.byType(WebCard), findsOneWidget);
    });

    testWidgets('should handle tap events', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WebCard(
              onTap: () => tapped = true,
              child: Text('Tappable Card'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(WebCard));
      expect(tapped, isTrue);
    });
  });

  group('GBButton Tests', () {
    testWidgets('should render primary button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GBButton(
              text: 'Test Button',
              variant: GBButtonVariant.primary,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(GBButton), findsOneWidget);
    });

    testWidgets('should render outline button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GBButton(
              text: 'Outline Button',
              variant: GBButtonVariant.outline,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Outline Button'), findsOneWidget);
      expect(find.byType(GBButton), findsOneWidget);
    });

    testWidgets('should show loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GBButton(
              text: 'Loading Button',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should render button with icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GBButton(
              text: 'Icon Button',
              leftIcon: Icon(Icons.add),
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Icon Button'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should handle disabled state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GBButton(
              text: 'Disabled Button',
              onPressed: null,
            ),
          ),
        ),
      );

      expect(find.text('Disabled Button'), findsOneWidget);
    });
  });

  group('GBTextField Tests', () {
    testWidgets('should render text field with label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GBTextField(
              label: 'Test Label',
              controller: TextEditingController(),
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('should render text field with hint',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GBTextField(
              hint: 'Test Hint',
              controller: TextEditingController(),
            ),
          ),
        ),
      );

      expect(find.text('Test Hint'), findsOneWidget);
    });

    testWidgets('should handle text input', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GBTextField(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Test Input');
      expect(controller.text, equals('Test Input'));
    });

    testWidgets('should show error text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GBTextField(
              errorText: 'Test Error',
              controller: TextEditingController(),
            ),
          ),
        ),
      );

      expect(find.text('Test Error'), findsOneWidget);
    });
  });

  group('RTL Utils Tests', () {
    testWidgets('should detect RTL direction', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale('ar'),
          supportedLocales: [Locale('ar'), Locale('en')],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final isRTL = RTLUtils.isRTL(context);
                return Text('RTL: $isRTL');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('RTL: true'), findsOneWidget);
    });

    testWidgets('should detect LTR direction', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale('en'),
          supportedLocales: [Locale('ar'), Locale('en')],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final isRTL = RTLUtils.isRTL(context);
                return Text('RTL: $isRTL');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('RTL: false'), findsOneWidget);
    });

    testWidgets('should get correct text direction',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale('ar'),
          supportedLocales: [Locale('ar'), Locale('en')],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final direction = RTLUtils.getTextDirection(context);
                return Text('Direction: $direction');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Direction: TextDirection.rtl'), findsOneWidget);
    });

    testWidgets('should get correct horizontal padding for RTL',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale('ar'),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final padding = RTLUtils.getHorizontalPadding(
                  context,
                  start: 10.0,
                  end: 20.0,
                );
                return Text('Padding: $padding');
              },
            ),
          ),
        ),
      );

      // In RTL, start becomes right and end becomes left
      expect(find.textContaining('Padding:'), findsOneWidget);
    });

    testWidgets('should get correct horizontal padding for LTR',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale('en'),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final padding = RTLUtils.getHorizontalPadding(
                  context,
                  start: 10.0,
                  end: 20.0,
                );
                return Text('Padding: $padding');
              },
            ),
          ),
        ),
      );

      // In LTR, start stays left and end stays right
      expect(find.textContaining('Padding:'), findsOneWidget);
    });

    testWidgets('should format numbers correctly for Arabic',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale('ar'),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final formatted = RTLUtils.formatNumber(context, 123);
                return Text('Formatted: $formatted');
              },
            ),
          ),
        ),
      );

      expect(find.textContaining('Formatted:'), findsOneWidget);
    });

    testWidgets('should format numbers correctly for English',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale('en'),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final formatted = RTLUtils.formatNumber(context, 123);
                return Text('Formatted: $formatted');
              },
            ),
          ),
        ),
      );

      expect(find.text('Formatted: 123'), findsOneWidget);
    });

    testWidgets('should format dates correctly for Arabic',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale('ar'),
          supportedLocales: [Locale('ar'), Locale('en')],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final formatted =
                    RTLUtils.formatDate(context, DateTime(2024, 1, 15));
                return Text('Date: $formatted');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Date: 15/1/2024'), findsOneWidget);
    });

    testWidgets('should format dates correctly for English',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale('en'),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final formatted =
                    RTLUtils.formatDate(context, DateTime(2024, 1, 15));
                return Text('Date: $formatted');
              },
            ),
          ),
        ),
      );

      expect(find.text('Date: 1/15/2024'), findsOneWidget);
    });
  });
}
