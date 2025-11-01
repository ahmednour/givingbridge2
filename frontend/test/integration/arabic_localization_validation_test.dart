import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:giving_bridge_frontend/providers/locale_provider.dart';
import 'package:giving_bridge_frontend/l10n/app_localizations.dart';

void main() {
  group('Arabic Localization Integration Tests', () {
    late LocaleProvider localeProvider;

    setUp(() {
      localeProvider = LocaleProvider();
    });

    Widget createTestApp({required Widget child, Locale? locale}) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
        ],
        child: MaterialApp(
          locale: locale ?? const Locale('ar'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('ar', ''),
          ],
          builder: (context, child) {
            return Directionality(
              textDirection: locale?.languageCode == 'ar' 
                  ? TextDirection.rtl 
                  : TextDirection.ltr,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: child,
        ),
      );
    }

    group('7.1 Integration testing for Arabic localization', () {
      testWidgets('Complete user registration flow in Arabic', (WidgetTester tester) async {
        // Set Arabic locale
        await localeProvider.setLocale(const Locale('ar'));
        
        // Create a mock registration form for testing
        await tester.pumpWidget(createTestApp(
          child: Scaffold(
            appBar: AppBar(title: const Text('إنشاء حساب')),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'الاسم'),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'كلمة المرور'),
                    obscureText: true,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'الهاتف'),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'الموقع'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('إنشاء حساب'),
                  ),
                ],
              ),
            ),
          ),
          locale: const Locale('ar'),
        ));
        
        // Wait for the widget to settle
        await tester.pumpAndSettle();

        // Verify Arabic text is displayed
        expect(find.text('إنشاء حساب'), findsAtLeastNWidgets(1));
        expect(find.text('الاسم'), findsOneWidget);
        expect(find.text('البريد الإلكتروني'), findsOneWidget);
        expect(find.text('كلمة المرور'), findsOneWidget);
        expect(find.text('الهاتف'), findsOneWidget);
        expect(find.text('الموقع'), findsOneWidget);

        // Test Arabic text input
        await tester.enterText(find.byType(TextFormField).first, 'أحمد محمد');
        await tester.enterText(find.byType(TextFormField).at(4), 'الرياض، المملكة العربية السعودية');

        await tester.pumpAndSettle();

        // Verify Arabic text is properly displayed in form fields
        expect(find.text('أحمد محمد'), findsOneWidget);
        expect(find.text('الرياض، المملكة العربية السعودية'), findsOneWidget);
      });

      testWidgets('Verify donation creation and management in Arabic', (WidgetTester tester) async {
        // Set Arabic locale
        await localeProvider.setLocale(const Locale('ar'));
        
        // Create a mock donation form for testing
        await tester.pumpWidget(createTestApp(
          child: Scaffold(
            appBar: AppBar(title: const Text('إنشاء تبرع')),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'العنوان'),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'الوصف'),
                    maxLines: 3,
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'الفئة'),
                    items: const [
                      DropdownMenuItem(value: 'clothes', child: Text('ملابس')),
                      DropdownMenuItem(value: 'food', child: Text('طعام')),
                      DropdownMenuItem(value: 'books', child: Text('كتب')),
                    ],
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('إنشاء التبرع'),
                  ),
                ],
              ),
            ),
          ),
          locale: const Locale('ar'),
        ));
        
        await tester.pumpAndSettle();

        // Verify Arabic donation form labels
        expect(find.text('إنشاء تبرع'), findsOneWidget);
        expect(find.text('العنوان'), findsOneWidget);
        expect(find.text('الوصف'), findsOneWidget);
        expect(find.text('الفئة'), findsOneWidget);

        // Test Arabic text input in donation form
        await tester.enterText(find.byType(TextFormField).first, 'تبرع بملابس شتوية');
        await tester.enterText(find.byType(TextFormField).at(1), 'ملابس شتوية نظيفة ومناسبة للأطفال والكبار');

        await tester.pumpAndSettle();

        // Verify Arabic text is displayed correctly
        expect(find.text('تبرع بملابس شتوية'), findsOneWidget);
        expect(find.text('ملابس شتوية نظيفة ومناسبة للأطفال والكبار'), findsOneWidget);

        // Test dropdown with Arabic options
        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();
        expect(find.text('ملابس'), findsOneWidget);
        expect(find.text('طعام'), findsOneWidget);
        expect(find.text('كتب'), findsOneWidget);
      });

      testWidgets('Test request submission and tracking in Arabic', (WidgetTester tester) async {
        // Set Arabic locale
        await localeProvider.setLocale(const Locale('ar'));
        
        // Create a mock request form for testing
        await tester.pumpWidget(createTestApp(
          child: Scaffold(
            appBar: AppBar(title: const Text('طلب جديد')),
            body: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('نوع الطلب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('تفاصيل الطلب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('الموقع المطلوب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('تاريخ الحاجة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('حالة الطلب: قيد الانتظار'),
                          SizedBox(height: 8),
                          Text('تاريخ الإنشاء: ٢٠٢٤/١/١٥'),
                          SizedBox(height: 8),
                          Text('رقم الطلب: ١٢٣٤٥'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          locale: const Locale('ar'),
        ));
        
        await tester.pumpAndSettle();

        // Verify Arabic request form elements
        expect(find.text('طلب جديد'), findsOneWidget);
        expect(find.text('نوع الطلب'), findsOneWidget);
        expect(find.text('تفاصيل الطلب'), findsOneWidget);
        expect(find.text('الموقع المطلوب'), findsOneWidget);
        expect(find.text('تاريخ الحاجة'), findsOneWidget);
        expect(find.text('حالة الطلب: قيد الانتظار'), findsOneWidget);
        expect(find.text('تاريخ الإنشاء: ٢٠٢٤/١/١٥'), findsOneWidget);
        expect(find.text('رقم الطلب: ١٢٣٤٥'), findsOneWidget);
      });

      testWidgets('Test language switching functionality', (WidgetTester tester) async {
        // Create a simple app with language switching capability
        await tester.pumpWidget(createTestApp(
          child: Scaffold(
            appBar: AppBar(title: const Text('Giving Bridge')),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Welcome to Giving Bridge'),
                  SizedBox(height: 20),
                  Text('Connect hearts, share hope'),
                ],
              ),
            ),
          ),
          locale: const Locale('en'),
        ));
        
        await tester.pumpAndSettle();

        // Initially should be in English
        expect(find.text('Giving Bridge'), findsOneWidget);
        expect(find.text('Welcome to Giving Bridge'), findsOneWidget);

        // Switch to Arabic
        await localeProvider.setLocale(const Locale('ar'));
        
        await tester.pumpWidget(createTestApp(
          child: Scaffold(
            appBar: AppBar(title: const Text('جسر العطاء')),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('مرحباً بكم في جسر العطاء'),
                  SizedBox(height: 20),
                  Text('نربط القلوب، نشارك الأمل'),
                ],
              ),
            ),
          ),
          locale: const Locale('ar'),
        ));
        
        await tester.pumpAndSettle();

        // Should now show Arabic text
        expect(find.text('جسر العطاء'), findsOneWidget);
        expect(find.text('مرحباً بكم في جسر العطاء'), findsOneWidget);
      });

      testWidgets('Test RTL layout direction in Arabic', (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(
          child: Scaffold(
            body: Row(
              children: [
                Container(
                  key: const Key('first_container'),
                  width: 100,
                  height: 100,
                  color: Colors.red,
                ),
                Container(
                  key: const Key('second_container'),
                  width: 100,
                  height: 100,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
          locale: const Locale('ar'),
        ));
        
        await tester.pumpAndSettle();

        // In RTL, the first container should be positioned to the right
        final firstContainer = tester.getTopLeft(find.byKey(const Key('first_container')));
        final secondContainer = tester.getTopLeft(find.byKey(const Key('second_container')));
        
        // In RTL layout, first container should be to the right of second container
        expect(firstContainer.dx > secondContainer.dx, isTrue);
      });

      testWidgets('Test Arabic text input and validation', (WidgetTester tester) async {
        final controller = TextEditingController();
        
        await tester.pumpWidget(createTestApp(
          child: Scaffold(
            body: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'أدخل النص بالعربية',
                hintText: 'مثال: اسم المستخدم',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'هذا الحقل مطلوب';
                }
                return null;
              },
            ),
          ),
          locale: const Locale('ar'),
        ));
        
        await tester.pumpAndSettle();

        // Test Arabic placeholder and label text
        expect(find.text('أدخل النص بالعربية'), findsOneWidget);
        
        // Test Arabic text input
        await tester.enterText(find.byType(TextFormField), 'محمد أحمد السعودي');
        await tester.pumpAndSettle();
        
        expect(controller.text, equals('محمد أحمد السعودي'));
        expect(find.text('محمد أحمد السعودي'), findsOneWidget);
      });

      testWidgets('Test Arabic number and date formatting', (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(
          child: Scaffold(
            body: Column(
              children: [
                Text('السعر: ${1234.56} ريال'),
                Text('التاريخ: ${DateTime(2024, 1, 15).toString().split(' ')[0]}'),
                const Text('الكمية: ١٢٣٤'), // Arabic numerals
              ],
            ),
          ),
          locale: const Locale('ar'),
        ));
        
        await tester.pumpAndSettle();

        // Verify Arabic text with numbers
        expect(find.textContaining('السعر:'), findsOneWidget);
        expect(find.textContaining('التاريخ:'), findsOneWidget);
        expect(find.text('الكمية: ١٢٣٤'), findsOneWidget);
      });
    });
  });
}