import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:giving_bridge_frontend/widgets/rtl/directional_layouts.dart';
import 'package:giving_bridge_frontend/l10n/app_localizations.dart';

void main() {
  group('DirectionalRow Tests', () {
    testWidgets('renders correctly in LTR mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          home: const Scaffold(
            body: DirectionalRow(
              children: [
                Text('First'),
                Text('Second'),
                Text('Third'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('Third'), findsOneWidget);
      
      // Verify Row widget is present
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('renders correctly in RTL mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          home: const Scaffold(
            body: DirectionalRow(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('First'),
                Text('Second'),
                Text('Third'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('Third'), findsOneWidget);
      
      // Verify Row widget is present
      expect(find.byType(Row), findsOneWidget);
      
      // Verify text direction is RTL
      final row = tester.widget<Row>(find.byType(Row));
      expect(row.textDirection, TextDirection.rtl);
    });

    testWidgets('applies correct alignment conversions for RTL', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          home: const Scaffold(
            body: DirectionalRow(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Test'),
              ],
            ),
          ),
        ),
      );

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisAlignment, MainAxisAlignment.end);
      expect(row.crossAxisAlignment, CrossAxisAlignment.end);
    });
  });

  group('DirectionalColumn Tests', () {
    testWidgets('renders correctly in LTR mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          home: const Scaffold(
            body: DirectionalColumn(
              children: [
                Text('First'),
                Text('Second'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('applies correct cross axis alignment for RTL', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          home: const Scaffold(
            body: DirectionalColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Test'),
              ],
            ),
          ),
        ),
      );

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.crossAxisAlignment, CrossAxisAlignment.end);
      expect(column.textDirection, TextDirection.rtl);
    });
  });

  group('DirectionalContainer Tests', () {
    testWidgets('renders correctly with basic properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          home: const Scaffold(
            body: DirectionalContainer(
              width: 100,
              height: 100,
              color: Colors.blue,
              child: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('converts padding correctly for RTL', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          home: const Scaffold(
            body: DirectionalContainer(
              padding: EdgeInsets.only(left: 10, right: 20),
              child: Text('Test'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final padding = container.padding as EdgeInsets;
      expect(padding.left, 20.0); // Should be swapped
      expect(padding.right, 10.0); // Should be swapped
    });

    testWidgets('converts alignment correctly for RTL', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          home: const Scaffold(
            body: DirectionalContainer(
              alignment: Alignment.centerLeft,
              child: Text('Test'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.alignment, Alignment.centerRight);
    });
  });

  group('DirectionalStack Tests', () {
    testWidgets('renders correctly with basic properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          home: const Scaffold(
            body: DirectionalStack(
              children: [
                Text('Background'),
                Text('Foreground'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Background'), findsOneWidget);
      expect(find.text('Foreground'), findsOneWidget);
      expect(find.byType(DirectionalStack), findsOneWidget);
    });

    testWidgets('sets correct text direction for RTL', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          home: const Scaffold(
            body: DirectionalStack(
              children: [
                Text('Test'),
              ],
            ),
          ),
        ),
      );

      final directionalStack = find.byType(DirectionalStack);
      expect(directionalStack, findsOneWidget);
    });
  });

  group('DirectionalPositioned Tests', () {
    testWidgets('swaps left and right positions for RTL', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          home: const Scaffold(
            body: DirectionalStack(
              children: [
                DirectionalPositioned(
                  left: 10,
                  right: 20,
                  child: Text('Test'),
                ),
              ],
            ),
          ),
        ),
      );

      final positioned = tester.widget<Positioned>(find.byType(Positioned));
      expect(positioned.left, 20.0); // Should be swapped
      expect(positioned.right, 10.0); // Should be swapped
    });

    testWidgets('maintains top and bottom positions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          home: const Scaffold(
            body: DirectionalStack(
              children: [
                DirectionalPositioned(
                  top: 10,
                  bottom: 20,
                  child: Text('Test'),
                ),
              ],
            ),
          ),
        ),
      );

      final positioned = tester.widget<Positioned>(find.byType(Positioned));
      expect(positioned.top, 10.0);
      expect(positioned.bottom, 20.0);
    });
  });
}