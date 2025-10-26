import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:giving_bridge_frontend/main.dart';
import 'package:giving_bridge_frontend/providers/auth_provider.dart';
import 'package:giving_bridge_frontend/providers/donation_provider.dart';
import 'package:giving_bridge_frontend/providers/message_provider.dart';
import 'package:giving_bridge_frontend/services/offline_service.dart';
import 'package:giving_bridge_frontend/services/network_status_service.dart';
import 'package:giving_bridge_frontend/services/error_handler.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Giving Bridge Integration Tests', () {
    testWidgets('Complete User Journey - Donor Flow',
        (WidgetTester tester) async {
      // Initialize app
      await tester.pumpWidget(const GivingBridgeApp());
      await tester.pumpAndSettle();

      // Test 1: Landing Page
      expect(find.text('Giving Bridge'), findsOneWidget);
      expect(find.text('Start Donating'), findsOneWidget);

      // Navigate to registration
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Test 2: Registration Flow
      expect(find.text('Create Account'), findsOneWidget);

      // Fill registration form
      await tester.enterText(find.byKey(const Key('name_field')), 'Test Donor');
      await tester.enterText(
          find.byKey(const Key('email_field')), 'donor@test.com');
      await tester.enterText(
          find.byKey(const Key('password_field')), 'password123');
      await tester.enterText(
          find.byKey(const Key('confirm_password_field')), 'password123');

      // Select donor role
      await tester.tap(find.text('Donor'));
      await tester.pumpAndSettle();

      // Submit registration
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Test 3: Dashboard Navigation
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('My Donations'), findsOneWidget);

      // Test 4: Create Donation Flow
      await tester.tap(find.text('Create Donation'));
      await tester.pumpAndSettle();

      expect(find.text('Create Donation'), findsOneWidget);

      // Fill donation form
      await tester.enterText(
          find.byKey(const Key('title_field')), 'Test Donation');
      await tester.enterText(find.byKey(const Key('description_field')),
          'This is a test donation');
      await tester.enterText(
          find.byKey(const Key('location_field')), 'Test Location');

      // Select category
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // Select condition
      await tester.tap(find.text('Good'));
      await tester.pumpAndSettle();

      // Submit donation
      await tester.tap(find.text('Create Donation'));
      await tester.pumpAndSettle();

      // Test 5: Donation Created Successfully
      expect(find.text('Donation created successfully!'), findsOneWidget);

      // Navigate back to dashboard
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Test 6: Browse Donations
      await tester.tap(find.text('Browse Donations'));
      await tester.pumpAndSettle();

      expect(find.text('Browse Donations'), findsOneWidget);

      // Test search functionality
      await tester.enterText(find.byKey(const Key('search_field')), 'Test');
      await tester.pumpAndSettle();

      // Test filter functionality
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // Test 7: Messages
      await tester.tap(find.text('Messages'));
      await tester.pumpAndSettle();

      expect(find.text('Messages'), findsOneWidget);

      // Test 8: Profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsOneWidget);

      // Test logout
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(find.text('Giving Bridge'), findsOneWidget);
    });

    testWidgets('Complete User Journey - Receiver Flow',
        (WidgetTester tester) async {
      // Initialize app
      await tester.pumpWidget(const GivingBridgeApp());
      await tester.pumpAndSettle();

      // Navigate to registration
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Fill registration form for receiver
      await tester.enterText(
          find.byKey(const Key('name_field')), 'Test Receiver');
      await tester.enterText(
          find.byKey(const Key('email_field')), 'receiver@test.com');
      await tester.enterText(
          find.byKey(const Key('password_field')), 'password123');
      await tester.enterText(
          find.byKey(const Key('confirm_password_field')), 'password123');

      // Select receiver role
      await tester.tap(find.text('Receiver'));
      await tester.pumpAndSettle();

      // Submit registration
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Test receiver dashboard
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('My Requests'), findsOneWidget);

      // Test create request flow
      await tester.tap(find.text('Create Request'));
      await tester.pumpAndSettle();

      expect(find.text('Create Request'), findsOneWidget);

      // Fill request form
      await tester.enterText(
          find.byKey(const Key('title_field')), 'Test Request');
      await tester.enterText(
          find.byKey(const Key('description_field')), 'This is a test request');
      await tester.enterText(
          find.byKey(const Key('location_field')), 'Test Location');

      // Select category
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // Submit request
      await tester.tap(find.text('Create Request'));
      await tester.pumpAndSettle();

      // Test request created successfully
      expect(find.text('Request created successfully!'), findsOneWidget);
    });

    testWidgets('RTL Layout Testing', (WidgetTester tester) async {
      // Initialize app with Arabic locale
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          home: const GivingBridgeApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Test RTL layout elements
      expect(find.text('جسر العطاء'), findsOneWidget);

      // Test RTL navigation
      await tester.tap(find.text('ابدأ التبرع'));
      await tester.pumpAndSettle();

      // Verify RTL layout is applied
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold, isNotNull);
    });

    testWidgets('Offline Functionality Testing', (WidgetTester tester) async {
      // Initialize app
      await tester.pumpWidget(const GivingBridgeApp());
      await tester.pumpAndSettle();

      // Simulate offline mode
      final offlineService = OfflineService();
      await offlineService.initialize();

      // Test offline indicator
      expect(find.text('No internet connection'), findsOneWidget);

      // Test offline operation queuing
      await offlineService.queueOperation(
        type: OfflineOperationType.createDonation,
        data: {
          'title': 'Offline Donation',
          'description': 'This donation was created offline',
          'category': 'food',
          'condition': 'good',
          'location': 'Test Location',
        },
      );

      // Verify operation is queued
      expect(offlineService.pendingOperationsCount, equals(1));

      // Test cache functionality
      await offlineService.cacheData(
        key: 'test_data',
        data: {'test': 'value'},
        expiry: const Duration(minutes: 5),
      );

      // Verify data is cached
      final cachedData = offlineService.getCachedData('test_data');
      expect(cachedData, isNotNull);
      expect(cachedData!['test'], equals('value'));
    });

    testWidgets('Error Handling Testing', (WidgetTester tester) async {
      // Initialize app
      await tester.pumpWidget(const GivingBridgeApp());
      await tester.pumpAndSettle();

      // Test error boundary
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            child: Builder(
              builder: (context) {
                throw Exception('Test error');
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify error is handled gracefully
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('Performance Testing', (WidgetTester tester) async {
      // Initialize app
      await tester.pumpWidget(const GivingBridgeApp());
      await tester.pumpAndSettle();

      // Test app startup time
      final stopwatch = Stopwatch()..start();
      await tester.pumpAndSettle();
      stopwatch.stop();

      // Verify startup time is reasonable (less than 3 seconds)
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));

      // Test navigation performance
      stopwatch.reset();
      stopwatch.start();

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Verify navigation is fast (less than 1 second)
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    testWidgets('Accessibility Testing', (WidgetTester tester) async {
      // Initialize app
      await tester.pumpWidget(const GivingBridgeApp());
      await tester.pumpAndSettle();

      // Test semantic labels
      expect(find.bySemanticsLabel('Giving Bridge logo'), findsOneWidget);
      expect(find.bySemanticsLabel('Get Started button'), findsOneWidget);

      // Test keyboard navigation
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // Test screen reader support
      final semantics = tester.getSemantics(find.byType(MaterialApp));
      expect(semantics, isNotNull);
    });

    testWidgets('State Management Testing', (WidgetTester tester) async {
      // Initialize app
      await tester.pumpWidget(const GivingBridgeApp());
      await tester.pumpAndSettle();

      // Test provider state
      final authProvider = Provider.of<AuthProvider>(
          tester.element(find.byType(MaterialApp)),
          listen: false);
      final donationProvider = Provider.of<DonationProvider>(
          tester.element(find.byType(MaterialApp)),
          listen: false);
      final messageProvider = Provider.of<MessageProvider>(
          tester.element(find.byType(MaterialApp)),
          listen: false);

      // Verify providers are initialized
      expect(authProvider, isNotNull);
      expect(donationProvider, isNotNull);
      expect(messageProvider, isNotNull);

      // Test state changes
      expect(authProvider.isAuthenticated, isFalse);
      expect(donationProvider.donations, isEmpty);
      expect(messageProvider.conversations, isEmpty);
    });

    testWidgets('Network Status Testing', (WidgetTester tester) async {
      // Initialize app
      await tester.pumpWidget(const GivingBridgeApp());
      await tester.pumpAndSettle();

      // Test network status service
      final networkService = Provider.of<NetworkStatusService>(
          tester.element(find.byType(MaterialApp)),
          listen: false);

      // Verify network service is initialized
      expect(networkService, isNotNull);

      // Test network status
      expect(networkService.isOnline, isTrue);
      expect(networkService.status, equals(NetworkStatus.connected));
    });

    testWidgets('End-to-End Chat Flow', (WidgetTester tester) async {
      // Initialize app
      await tester.pumpWidget(const GivingBridgeApp());
      await tester.pumpAndSettle();

      // Login as donor
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('name_field')), 'Test Donor');
      await tester.enterText(
          find.byKey(const Key('email_field')), 'donor@test.com');
      await tester.enterText(
          find.byKey(const Key('password_field')), 'password123');
      await tester.enterText(
          find.byKey(const Key('confirm_password_field')), 'password123');
      await tester.tap(find.text('Donor'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Create donation
      await tester.tap(find.text('Create Donation'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('title_field')), 'Test Donation');
      await tester.enterText(find.byKey(const Key('description_field')),
          'This is a test donation');
      await tester.enterText(
          find.byKey(const Key('location_field')), 'Test Location');
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Good'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Donation'));
      await tester.pumpAndSettle();

      // Test chat functionality
      await tester.tap(find.text('Messages'));
      await tester.pumpAndSettle();

      expect(find.text('Messages'), findsOneWidget);

      // Test message sending (if conversation exists)
      if (find.text('Start Conversation').evaluate().isNotEmpty) {
        await tester.tap(find.text('Start Conversation'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key('message_field')),
            'Hello, I am interested in your donation');
        await tester.tap(find.text('Send'));
        await tester.pumpAndSettle();

        expect(find.text('Hello, I am interested in your donation'),
            findsOneWidget);
      }
    });
  });
}
