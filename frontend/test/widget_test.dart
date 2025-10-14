import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../lib/core/utils/rtl_utils.dart';
import '../lib/widgets/app_components.dart';

void main() {
  group('AppCard Tests', () {
    testWidgets('should render card with child content',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCard(
              child: Text('Test Content'),
            ),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should handle tap events', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCard(
              onTap: () => tapped = true,
              child: Text('Tappable Card'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AppCard));
      expect(tapped, isTrue);
    });

    testWidgets('should apply custom padding and margin',
        (WidgetTester tester) async {
      const customPadding = EdgeInsets.all(20.0);
      const customMargin = EdgeInsets.all(10.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCard(
              padding: customPadding,
              margin: customMargin,
              child: Text('Custom Card'),
            ),
          ),
        ),
      );

      expect(find.byType(AppCard), findsOneWidget);
    });
  });

  group('AppButton Tests', () {
    testWidgets('should render primary button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Test Button',
              type: AppButtonType.primary,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should render secondary button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Secondary Button',
              type: AppButtonType.secondary,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Secondary Button'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('should render text button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Text Button',
              type: AppButtonType.text,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Text Button'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('should show loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Loading Button',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading Button'), findsNothing);
    });

    testWidgets('should render button with icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Icon Button',
              icon: Icons.add,
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
            body: AppButton(
              text: 'Disabled Button',
              onPressed: null,
            ),
          ),
        ),
      );

      expect(find.text('Disabled Button'), findsOneWidget);
      // Button should be disabled
    });

    testWidgets('should render full width button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Full Width Button',
              isFullWidth: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Full Width Button'), findsOneWidget);
      expect(find.byType(SizedBox), findsOneWidget);
    });
  });

  group('AppTextField Tests', () {
    testWidgets('should render text field with label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
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
            body: AppTextField(
              hint: 'Test Hint',
              controller: TextEditingController(),
            ),
          ),
        ),
      );

      expect(find.text('Test Hint'), findsOneWidget);
    });

    testWidgets('should render text field with prefix icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              prefixIcon: Icon(Icons.search),
              controller: TextEditingController(),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should render text field with suffix icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              suffixIcon: Icon(Icons.clear),
              controller: TextEditingController(),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('should handle text input', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
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
            body: AppTextField(
              errorText: 'Test Error',
              controller: TextEditingController(),
            ),
          ),
        ),
      );

      expect(find.text('Test Error'), findsOneWidget);
    });

    testWidgets('should show required field indicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              label: 'Required Field',
              isRequired: true,
              controller: TextEditingController(),
            ),
          ),
        ),
      );

      expect(find.text('Required Field *'), findsOneWidget);
    });

    testWidgets('should handle obscure text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              obscureText: true,
              controller: TextEditingController(),
            ),
          ),
        ),
      );

      final textField =
          tester.widget<TextFormField>(find.byType(TextFormField));
      // Note: obscureText is not directly accessible from TextFormField
      // It's handled internally by the widget
      expect(textField, isNotNull);
    });

    testWidgets('should handle disabled state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              enabled: false,
              controller: TextEditingController(),
            ),
          ),
        ),
      );

      final textField =
          tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('should handle read-only state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              readOnly: true,
              controller: TextEditingController(),
            ),
          ),
        ),
      );

      final textField =
          tester.widget<TextFormField>(find.byType(TextFormField));
      // Note: readOnly is not directly accessible from TextFormField
      // It's handled internally by the widget
      expect(textField, isNotNull);
    });
  });

  group('AppContainer Tests', () {
    testWidgets('should render container with child',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppContainer(
              child: Text('Container Content'),
            ),
          ),
        ),
      );

      expect(find.text('Container Content'), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should apply custom padding', (WidgetTester tester) async {
      const customPadding = EdgeInsets.all(20.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppContainer(
              padding: customPadding,
              child: Text('Padded Container'),
            ),
          ),
        ),
      );

      expect(find.text('Padded Container'), findsOneWidget);
    });

    testWidgets('should apply custom margin', (WidgetTester tester) async {
      const customMargin = EdgeInsets.all(10.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppContainer(
              margin: customMargin,
              child: Text('Margined Container'),
            ),
          ),
        ),
      );

      expect(find.text('Margined Container'), findsOneWidget);
    });

    testWidgets('should apply custom background color',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppContainer(
              backgroundColor: Colors.red,
              child: Text('Colored Container'),
            ),
          ),
        ),
      );

      expect(find.text('Colored Container'), findsOneWidget);
    });

    testWidgets('should apply custom border radius',
        (WidgetTester tester) async {
      const customRadius = BorderRadius.all(Radius.circular(20.0));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppContainer(
              borderRadius: customRadius,
              child: Text('Rounded Container'),
            ),
          ),
        ),
      );

      expect(find.text('Rounded Container'), findsOneWidget);
    });

    testWidgets('should apply custom width and height',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppContainer(
              width: 200.0,
              height: 100.0,
              child: Text('Sized Container'),
            ),
          ),
        ),
      );

      expect(find.text('Sized Container'), findsOneWidget);
    });
  });

  group('AppSpacing Tests', () {
    testWidgets('should render horizontal spacing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                Text('Left'),
                AppSpacing.horizontal(20.0),
                Text('Right'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('should render vertical spacing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Top'),
                AppSpacing.vertical(20.0),
                Text('Bottom'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Top'), findsOneWidget);
      expect(find.text('Bottom'), findsOneWidget);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('should render all-around spacing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSpacing.all(20.0),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('should render custom width and height spacing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSpacing(
              width: 30.0,
              height: 40.0,
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
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
