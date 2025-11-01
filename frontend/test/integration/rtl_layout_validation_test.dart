import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:giving_bridge_frontend/providers/locale_provider.dart';
import 'package:giving_bridge_frontend/l10n/app_localizations.dart';

void main() {
  group('Cross-platform RTL Layout Validation Tests', () {
    late LocaleProvider localeProvider;

    setUp(() {
      localeProvider = LocaleProvider();
    });

    Widget createTestApp({
      required Widget child,
      Locale? locale,
      Size? screenSize,
    }) {
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
            return MediaQuery(
              data: MediaQueryData(
                size: screenSize ?? const Size(800, 600),
                devicePixelRatio: 1.0,
              ),
              child: Directionality(
                textDirection: locale?.languageCode == 'ar' 
                    ? TextDirection.rtl 
                    : TextDirection.ltr,
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
          home: child,
        ),
      );
    }

    group('7.2 Cross-platform RTL layout validation', () {
      testWidgets('Test RTL layouts on mobile screen size', (WidgetTester tester) async {
        const mobileSize = Size(375, 667); // iPhone SE size
        
        await tester.pumpWidget(createTestApp(
          screenSize: mobileSize,
          locale: const Locale('ar'),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('اختبار الهاتف المحمول'),
              leading: const Icon(Icons.menu),
              actions: const [
                Icon(Icons.search),
                Icon(Icons.notifications),
              ],
            ),
            body: const Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('البطاقة الأولى'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('البطاقة الثانية'),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: const Text(
                    'هذا نص تجريبي لاختبار التخطيط من اليمين إلى اليسار على الهاتف المحمول',
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
          ),
        ));
        
        await tester.pumpAndSettle();

        // Verify mobile layout elements are present
        expect(find.text('اختبار الهاتف المحمول'), findsOneWidget);
        expect(find.text('البطاقة الأولى'), findsOneWidget);
        expect(find.text('البطاقة الثانية'), findsOneWidget);

        // Verify RTL layout on mobile
        final firstCard = tester.getTopLeft(find.text('البطاقة الأولى'));
        final secondCard = tester.getTopLeft(find.text('البطاقة الثانية'));
        
        // In RTL, first card should be to the right of second card
        expect(firstCard.dx > secondCard.dx, isTrue);

        // Verify app bar icons are positioned correctly for RTL
        final menuIcon = tester.getTopLeft(find.byIcon(Icons.menu));
        final searchIcon = tester.getTopLeft(find.byIcon(Icons.search));
        
        // Menu should be on the right in RTL, search on the left
        expect(menuIcon.dx > searchIcon.dx, isTrue);
      });

      testWidgets('Test RTL layouts on tablet screen size', (WidgetTester tester) async {
        const tabletSize = Size(768, 1024); // iPad size
        
        await tester.pumpWidget(createTestApp(
          screenSize: tabletSize,
          locale: const Locale('ar'),
          child: Scaffold(
            appBar: AppBar(title: const Text('اختبار الجهاز اللوحي')),
            body: Row(
              children: [
                // Sidebar
                Container(
                  width: 250,
                  color: Colors.grey[100],
                  child: const Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.home),
                        title: Text('الرئيسية'),
                      ),
                      ListTile(
                        leading: Icon(Icons.favorite),
                        title: Text('التبرعات'),
                      ),
                      ListTile(
                        leading: Icon(Icons.message),
                        title: Text('الرسائل'),
                      ),
                    ],
                  ),
                ),
                // Main content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'المحتوى الرئيسي',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 200,
                                color: Colors.blue[100],
                                child: const Center(child: Text('قسم أول')),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                height: 200,
                                color: Colors.green[100],
                                child: const Center(child: Text('قسم ثاني')),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
        
        await tester.pumpAndSettle();

        // Verify tablet layout elements
        expect(find.text('اختبار الجهاز اللوحي'), findsOneWidget);
        expect(find.text('الرئيسية'), findsOneWidget);
        expect(find.text('التبرعات'), findsOneWidget);
        expect(find.text('المحتوى الرئيسي'), findsOneWidget);

        // Verify sidebar is positioned correctly for RTL (should be on the right)
        final sidebar = tester.getTopLeft(find.text('الرئيسية'));
        final mainContent = tester.getTopLeft(find.text('المحتوى الرئيسي'));
        
        // In RTL, sidebar should be to the right of main content
        expect(sidebar.dx > mainContent.dx, isTrue);

        // Verify content sections are laid out RTL
        final firstSection = tester.getCenter(find.text('قسم أول'));
        final secondSection = tester.getCenter(find.text('قسم ثاني'));
        
        // First section should be to the right of second section in RTL
        expect(firstSection.dx > secondSection.dx, isTrue);
      });

      testWidgets('Test RTL layouts on desktop screen size', (WidgetTester tester) async {
        const desktopSize = Size(1920, 1080); // Full HD desktop
        
        await tester.pumpWidget(createTestApp(
          screenSize: desktopSize,
          locale: const Locale('ar'),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('اختبار سطح المكتب'),
              actions: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.account_circle),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.settings),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left panel (right in RTL)
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'اللوحة الجانبية',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 16),
                          Text('عنصر قائمة 1'),
                          Text('عنصر قائمة 2'),
                          Text('عنصر قائمة 3'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Main content
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'المحتوى الرئيسي لسطح المكتب',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 150,
                                margin: const EdgeInsets.only(left: 12),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: const Center(child: Text('بطاقة 1')),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 150,
                                margin: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: const Center(child: Text('بطاقة 2')),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 150,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: Colors.orange[100],
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: const Center(child: Text('بطاقة 3')),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Right panel (left in RTL)
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'اللوحة الثانوية',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 16),
                          Text('معلومات إضافية'),
                          Text('إحصائيات'),
                          Text('روابط سريعة'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
        
        await tester.pumpAndSettle();

        // Verify desktop layout elements
        expect(find.text('اختبار سطح المكتب'), findsOneWidget);
        expect(find.text('اللوحة الجانبية'), findsOneWidget);
        expect(find.text('المحتوى الرئيسي لسطح المكتب'), findsOneWidget);
        expect(find.text('اللوحة الثانوية'), findsOneWidget);

        // Verify three-column layout positioning for RTL
        final leftPanel = tester.getCenter(find.text('اللوحة الجانبية'));
        final mainContent = tester.getCenter(find.text('المحتوى الرئيسي لسطح المكتب'));
        final rightPanel = tester.getCenter(find.text('اللوحة الثانوية'));
        
        // In RTL: left panel should be rightmost, right panel should be leftmost
        expect(leftPanel.dx > mainContent.dx, isTrue);
        expect(mainContent.dx > rightPanel.dx, isTrue);

        // Verify cards are laid out RTL within main content
        final card1 = tester.getCenter(find.text('بطاقة 1'));
        final card2 = tester.getCenter(find.text('بطاقة 2'));
        final card3 = tester.getCenter(find.text('بطاقة 3'));
        
        // Cards should be ordered right to left: card1, card2, card3
        expect(card1.dx > card2.dx, isTrue);
        expect(card2.dx > card3.dx, isTrue);
      });

      testWidgets('Verify Arabic text rendering on different screen densities', (WidgetTester tester) async {
        final testCases = [
          {'density': 1.0, 'name': 'MDPI'},
          {'density': 1.5, 'name': 'HDPI'},
          {'density': 2.0, 'name': 'XHDPI'},
          {'density': 3.0, 'name': 'XXHDPI'},
        ];

        for (final testCase in testCases) {
          await tester.pumpWidget(
            MediaQuery(
              data: MediaQueryData(
                size: const Size(400, 600),
                devicePixelRatio: testCase['density'] as double,
              ),
              child: MaterialApp(
                locale: const Locale('ar'),
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('ar', ''),
                ],
                builder: (context, child) {
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: child ?? const SizedBox.shrink(),
                  );
                },
                home: Scaffold(
                  appBar: AppBar(
                    title: Text('اختبار ${testCase['name']}'),
                  ),
                  body: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نص عربي بخط صغير',
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'نص عربي بخط متوسط',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'نص عربي بخط كبير',
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'نص عربي بخط عريض',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'هذا نص طويل باللغة العربية لاختبار كيفية عرض النص على كثافات مختلفة من الشاشات. يجب أن يظهر النص بوضوح وبشكل صحيح على جميع الأجهزة.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          
          await tester.pumpAndSettle();

          // Verify Arabic text is rendered at different densities
          expect(find.text('نص عربي بخط صغير'), findsOneWidget);
          expect(find.text('نص عربي بخط متوسط'), findsOneWidget);
          expect(find.text('نص عربي بخط كبير'), findsOneWidget);
          expect(find.text('نص عربي بخط عريض'), findsOneWidget);
          expect(find.textContaining('هذا نص طويل باللغة العربية'), findsOneWidget);
        }
      });

      testWidgets('Validate performance of RTL layouts', (WidgetTester tester) async {
        // Create a complex RTL layout to test performance
        await tester.pumpWidget(createTestApp(
          locale: const Locale('ar'),
          child: Scaffold(
            appBar: AppBar(title: const Text('اختبار الأداء')),
            body: ListView.builder(
              itemCount: 100,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(child: Text('${index + 1}')),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'عنصر رقم ${index + 1}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'وصف تفصيلي للعنصر رقم ${index + 1} باللغة العربية',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_back_ios),
                    ],
                  ),
                );
              },
            ),
          ),
        ));
        
        // Measure performance by timing the pump and settle
        final stopwatch = Stopwatch()..start();
        await tester.pumpAndSettle();
        stopwatch.stop();

        // Verify the layout rendered successfully
        expect(find.text('اختبار الأداء'), findsOneWidget);
        expect(find.text('عنصر رقم 1'), findsOneWidget);
        
        // Performance should be reasonable (less than 5 seconds for 100 items)
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));

        // Test scrolling performance
        final scrollStopwatch = Stopwatch()..start();
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pumpAndSettle();
        scrollStopwatch.stop();

        // Scrolling should be smooth (less than 1 second)
        expect(scrollStopwatch.elapsedMilliseconds, lessThan(1000));
      });

      testWidgets('Test RTL layout consistency across different widgets', (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(
          locale: const Locale('ar'),
          child: Scaffold(
            appBar: AppBar(title: const Text('اختبار التناسق')),
            body: const SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Test Card widget
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text('اسم المستخدم'),
                      subtitle: Text('معلومات إضافية'),
                      trailing: Icon(Icons.arrow_back_ios),
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Test ExpansionTile
                  Card(
                    child: ExpansionTile(
                      leading: Icon(Icons.folder),
                      title: Text('مجلد قابل للتوسيع'),
                      children: [
                        ListTile(
                          title: Text('عنصر فرعي 1'),
                          leading: Icon(Icons.file_copy),
                        ),
                        ListTile(
                          title: Text('عنصر فرعي 2'),
                          leading: Icon(Icons.file_copy),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Test DataTable
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text('الاسم')),
                          DataColumn(label: Text('العمر')),
                          DataColumn(label: Text('المدينة')),
                        ],
                        rows: [
                          DataRow(cells: [
                            DataCell(Text('أحمد')),
                            DataCell(Text('25')),
                            DataCell(Text('الرياض')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('فاطمة')),
                            DataCell(Text('30')),
                            DataCell(Text('جدة')),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
        
        await tester.pumpAndSettle();

        // Verify all widgets render correctly with Arabic text
        expect(find.text('اختبار التناسق'), findsOneWidget);
        expect(find.text('اسم المستخدم'), findsOneWidget);
        expect(find.text('مجلد قابل للتوسيع'), findsOneWidget);
        expect(find.text('الاسم'), findsOneWidget);
        expect(find.text('أحمد'), findsOneWidget);
        expect(find.text('فاطمة'), findsOneWidget);

        // Test expansion functionality
        await tester.tap(find.text('مجلد قابل للتوسيع'));
        await tester.pumpAndSettle();
        
        expect(find.text('عنصر فرعي 1'), findsOneWidget);
        expect(find.text('عنصر فرعي 2'), findsOneWidget);

        // Verify RTL layout in ListTile
        final leadingIcon = tester.getCenter(find.byIcon(Icons.person));
        final titleText = tester.getCenter(find.text('اسم المستخدم'));
        final trailingIcon = tester.getCenter(find.byIcon(Icons.arrow_back_ios));
        
        // In RTL: leading should be on right, trailing on left
        expect(leadingIcon.dx > titleText.dx, isTrue);
        expect(titleText.dx > trailingIcon.dx, isTrue);
      });
    });
  });
}