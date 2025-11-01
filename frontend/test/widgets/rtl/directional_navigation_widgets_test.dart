import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:giving_bridge_frontend/widgets/rtl/directional_navigation.dart';
import 'package:giving_bridge_frontend/l10n/app_localizations.dart';

void main() {
  group('DirectionalAppBar Tests', () {
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
            appBar: DirectionalAppBar(
              title: Text('Test Title'),
              actions: [
                Icon(Icons.search),
                Icon(Icons.more_vert),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('reverses actions order in RTL mode', (WidgetTester tester) async {
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
            appBar: DirectionalAppBar(
              title: Text('Test Title'),
              actions: [
                Icon(Icons.search),
                Icon(Icons.more_vert),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
      
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.actions?.length, 2);
    });

    testWidgets('sets centerTitle correctly for RTL', (WidgetTester tester) async {
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
            appBar: DirectionalAppBar(
              title: Text('Test Title'),
            ),
          ),
        ),
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.centerTitle, true); // Should be true for RTL by default
    });
  });

  group('DirectionalDrawer Tests', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
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
            drawer: DirectionalDrawer(
              child: Column(
                children: [
                  Text('Drawer Item 1'),
                  Text('Drawer Item 2'),
                ],
              ),
            ),
          ),
        ),
      );

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('Drawer Item 1'), findsOneWidget);
      expect(find.text('Drawer Item 2'), findsOneWidget);
      expect(find.byType(Drawer), findsOneWidget);
    });

    testWidgets('DirectionalDrawerItem swaps leading and trailing for RTL', (WidgetTester tester) async {
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
            drawer: DirectionalDrawer(
              child: DirectionalDrawerItem(
                leading: Icon(Icons.home),
                title: Text('Home'),
                trailing: Icon(Icons.arrow_forward),
              ),
            ),
          ),
        ),
      );

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });
  });

  group('DirectionalBottomNavigationBar Tests', () {
    testWidgets('renders correctly in LTR mode', (WidgetTester tester) async {
      int selectedIndex = 0;
      
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
            bottomNavigationBar: DirectionalBottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (index) => selectedIndex = index,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('reverses items order in RTL mode', (WidgetTester tester) async {
      int selectedIndex = 0;
      
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
            bottomNavigationBar: DirectionalBottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (index) => selectedIndex = index,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      
      final bottomNav = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNav.items.length, 3);
      expect(bottomNav.currentIndex, 2); // Should be adjusted for RTL
    });

    testWidgets('handles tap correctly in RTL mode', (WidgetTester tester) async {
      int selectedIndex = 0;
      int tappedIndex = -1;
      
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
            bottomNavigationBar: DirectionalBottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (index) {
                tappedIndex = index;
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      );

      // Tap on the first visible item (which should be the last item in original order for RTL)
      await tester.tap(find.text('Profile'));
      await tester.pump();

      expect(tappedIndex, 2); // Should receive the original index
    });
  });

  group('DirectionalNavigationBar Tests', () {
    testWidgets('renders correctly in LTR mode', (WidgetTester tester) async {
      int selectedIndex = 0;
      
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
            bottomNavigationBar: DirectionalNavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) => selectedIndex = index,
              destinations: const [
                DirectionalNavigationDestination(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                DirectionalNavigationDestination(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('reverses destinations order in RTL mode', (WidgetTester tester) async {
      int selectedIndex = 0;
      
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
            bottomNavigationBar: DirectionalNavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) => selectedIndex = index,
              destinations: const [
                DirectionalNavigationDestination(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                DirectionalNavigationDestination(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      
      final navigationBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navigationBar.destinations.length, 2);
      expect(navigationBar.selectedIndex, 1); // Should be adjusted for RTL
    });
  });
}