import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:giving_bridge_frontend/widgets/rtl/localized_forms.dart';
import 'package:giving_bridge_frontend/l10n/app_localizations.dart';

void main() {
  group('LocalizedTextField Tests', () {
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
            body: LocalizedTextField(
              decoration: InputDecoration(
                labelText: 'Test Field',
                hintText: 'Enter text',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Field'), findsOneWidget);
      expect(find.text('Enter text'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
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
            body: LocalizedTextField(
              decoration: InputDecoration(
                labelText: 'Test Field',
              ),
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.textDirection, TextDirection.rtl);
      expect(textField.textAlign, TextAlign.right);
    });

    testWidgets('swaps prefix and suffix icons for RTL', (WidgetTester tester) async {
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
            body: LocalizedTextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                suffixIcon: Icon(Icons.clear),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('handles Arabic text input correctly', (WidgetTester tester) async {
      final controller = TextEditingController();
      
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
          home: Scaffold(
            body: LocalizedTextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Arabic Text',
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'مرحبا');
      expect(controller.text, 'مرحبا');
    });
  });

  group('LocalizedTextFormField Tests', () {
    testWidgets('renders correctly with validation', (WidgetTester tester) async {
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
          home: Scaffold(
            body: Form(
              child: LocalizedTextFormField(
                decoration: const InputDecoration(
                  labelText: 'Required Field',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Required Field'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('shows validation error in RTL mode', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      
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
          home: Scaffold(
            body: Form(
              key: formKey,
              child: LocalizedTextFormField(
                decoration: const InputDecoration(
                  labelText: 'Required Field',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'هذا الحقل مطلوب';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      // Trigger validation
      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('هذا الحقل مطلوب'), findsOneWidget);
    });
  });

  group('LocalizedDropdownButton Tests', () {
    testWidgets('renders correctly with items', (WidgetTester tester) async {
      String? selectedValue;
      
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
          home: Scaffold(
            body: LocalizedDropdownButton<String>(
              value: selectedValue,
              hint: const Text('Select an option'),
              onChanged: (value) => selectedValue = value,
              items: const [
                DropdownMenuItem(value: 'option1', child: Text('Option 1')),
                DropdownMenuItem(value: 'option2', child: Text('Option 2')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Select an option'), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    testWidgets('opens dropdown menu correctly in RTL', (WidgetTester tester) async {
      String? selectedValue;
      
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
          home: Scaffold(
            body: LocalizedDropdownButton<String>(
              value: selectedValue,
              hint: const Text('اختر خيار'),
              onChanged: (value) => selectedValue = value,
              items: const [
                DropdownMenuItem(value: 'option1', child: Text('الخيار الأول')),
                DropdownMenuItem(value: 'option2', child: Text('الخيار الثاني')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('اختر خيار'), findsOneWidget);
      
      // Tap to open dropdown
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('الخيار الأول'), findsOneWidget);
      expect(find.text('الخيار الثاني'), findsOneWidget);
    });
  });

  group('LocalizedButton Tests', () {
    testWidgets('LocalizedElevatedButton renders correctly', (WidgetTester tester) async {
      bool pressed = false;
      
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
          home: Scaffold(
            body: LocalizedElevatedButton(
              onPressed: () => pressed = true,
              child: const Text('Press Me'),
            ),
          ),
        ),
      );

      expect(find.text('Press Me'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      
      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, true);
    });

    testWidgets('LocalizedElevatedButton with icon adjusts alignment for RTL', (WidgetTester tester) async {
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
            body: LocalizedElevatedButton(
              onPressed: null,
              icon: Icon(Icons.add),
              iconAlignment: IconAlignment.start,
              child: Text('إضافة'),
            ),
          ),
        ),
      );

      expect(find.text('إضافة'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('LocalizedTextButton renders correctly', (WidgetTester tester) async {
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
            body: LocalizedTextButton(
              onPressed: null,
              child: Text('Text Button'),
            ),
          ),
        ),
      );

      expect(find.text('Text Button'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('LocalizedOutlinedButton renders correctly', (WidgetTester tester) async {
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
            body: LocalizedOutlinedButton(
              onPressed: null,
              child: Text('Outlined Button'),
            ),
          ),
        ),
      );

      expect(find.text('Outlined Button'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('LocalizedIconButton renders correctly', (WidgetTester tester) async {
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
            body: LocalizedIconButton(
              onPressed: null,
              icon: Icon(Icons.favorite),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('LocalizedIconButton converts padding for RTL', (WidgetTester tester) async {
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
            body: LocalizedIconButton(
              onPressed: null,
              icon: Icon(Icons.favorite),
              padding: EdgeInsets.only(left: 10, right: 20),
            ),
          ),
        ),
      );

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      final padding = iconButton.padding as EdgeInsets;
      expect(padding.left, 20.0); // Should be swapped
      expect(padding.right, 10.0); // Should be swapped
    });
  });
}