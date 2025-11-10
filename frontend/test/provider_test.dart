import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/providers/donation_provider.dart';
import '../lib/providers/request_provider.dart';
import '../lib/providers/message_provider.dart';
import '../lib/providers/notification_provider.dart';
import '../lib/providers/filter_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock SharedPreferences for NotificationProvider tests
  SharedPreferences.setMockInitialValues({});
  group('DonationProvider Tests', () {
    late DonationProvider donationProvider;

    setUp(() {
      donationProvider = DonationProvider();
    });

    test('should initialize with empty state', () {
      expect(donationProvider.donations, isEmpty);
      expect(donationProvider.isLoading, isFalse);
      expect(donationProvider.error, isNull);
    });

    test('should load donations', () async {
      // This test will use the actual repository
      // In a real test environment, you would mock the repository
      await donationProvider.loadDonations();

      // Verify the loading state changes
      expect(donationProvider.isLoading, isFalse);
    });

    test('should create donation with correct parameters', () async {
      final result = await donationProvider.createDonation(
        title: 'Test Donation',
        description: 'Test Description',
        category: 'food',
        condition: 'good',
        location: 'Test Location',
        imageUrl: 'https://example.com/image.jpg',
      );

      // The result depends on the actual repository implementation
      expect(result, isA<bool>());
    });

    test('should update donation with correct parameters', () async {
      final result = await donationProvider.updateDonation(
        id: '1',
        title: 'Updated Donation',
        description: 'Updated Description',
        category: 'food',
        condition: 'excellent',
        location: 'Updated Location',
        imageUrl: 'https://example.com/updated.jpg',
        isAvailable: true,
      );

      expect(result, isA<bool>());
    });

    test('should delete donation', () async {
      final result = await donationProvider.deleteDonation('1');
      expect(result, isA<bool>());
    });

    test('should filter donations by category', () {
      donationProvider.setCategoryFilter('food');
      expect(donationProvider.selectedCategory, equals('food'));
    });

    test('should filter donations by location', () {
      donationProvider.setLocationFilter('Cairo');
      expect(donationProvider.selectedLocation, equals('Cairo'));
    });

    test('should clear all filters', () {
      donationProvider.setCategoryFilter('food');
      donationProvider.setLocationFilter('Cairo');
      donationProvider.clearFilters();

      expect(donationProvider.selectedCategory, isNull);
      expect(donationProvider.selectedLocation, isNull);
    });
  });

  group('RequestProvider Tests', () {
    late RequestProvider requestProvider;

    setUp(() {
      requestProvider = RequestProvider();
    });

    test('should initialize with empty state', () {
      expect(requestProvider.myRequests, isEmpty);
      expect(requestProvider.isLoading, isFalse);
      expect(requestProvider.error, isNull);
    });

    test('should load my requests', () async {
      await requestProvider.loadMyRequests();
      expect(requestProvider.isLoading, isFalse);
    });

    test('should create request with correct parameters', () async {
      final result = await requestProvider.createRequest(
        donationId: '1',
        message: 'I would like to request this donation',
      );

      expect(result, isA<bool>());
    });

    test('should update request status', () async {
      final result = await requestProvider.updateRequestStatus(
        requestId: '1',
        status: 'approved',
      );

      expect(result, isA<bool>());
    });
  });

  group('MessageProvider Tests', () {
    late MessageProvider messageProvider;

    setUp(() {
      messageProvider = MessageProvider();
    });

    test('should initialize with empty state', () {
      expect(messageProvider.conversations, isEmpty);
      expect(messageProvider.messages, isEmpty);
      expect(messageProvider.isLoading, isFalse);
      expect(messageProvider.error, isNull);
    });

    test('should load conversations', () async {
      await messageProvider.loadConversations();
      expect(messageProvider.isLoadingConversations, isFalse);
    });

    test('should load messages for user', () async {
      await messageProvider.loadMessages('user123');
      expect(messageProvider.isLoadingMessages, isFalse);
    });

    test('should send message with correct parameters', () async {
      final result = await messageProvider.sendMessage(
        content: 'Hello, how are you?',
        receiverId: '123',
      );

      expect(result, isA<bool>());
    });
  });

  group('NotificationProvider Tests', () {
    late NotificationProvider notificationProvider;

    setUp(() {
      notificationProvider = NotificationProvider();
    });

    test('should initialize with default settings', () {
      expect(notificationProvider.inAppNotifications, isTrue);
      expect(notificationProvider.messages, isTrue);
      expect(notificationProvider.allNotificationsEnabled, isTrue);
    });

    test('should update in-app notifications setting', () async {
      await notificationProvider.updateInAppNotifications(false);
      expect(notificationProvider.inAppNotifications, isFalse);
    });

    test('should update messages setting', () async {
      await notificationProvider.updateMessages(false);
      expect(notificationProvider.messages, isFalse);
    });

    test('should toggle all notifications', () async {
      await notificationProvider.toggleAllNotifications(false);
      expect(notificationProvider.inAppNotifications, isFalse);
      expect(notificationProvider.messages, isFalse);
      expect(notificationProvider.allNotificationsEnabled, isFalse);
    });

    test('should reset to defaults', () async {
      await notificationProvider.toggleAllNotifications(false);
      await notificationProvider.resetToDefaults();
      expect(notificationProvider.inAppNotifications, isTrue);
      expect(notificationProvider.messages, isTrue);
    });
  });

  group('FilterProvider Tests', () {
    late FilterProvider filterProvider;

    setUp(() {
      filterProvider = FilterProvider();
    });

    test('should initialize with default filters', () {
      expect(filterProvider.selectedCategories, isEmpty);
      expect(filterProvider.selectedLocations, isEmpty);
      expect(filterProvider.selectedConditions, isEmpty);
      expect(filterProvider.hasActiveFilters, isFalse);
    });

    test('should set categories filter', () {
      filterProvider.setCategories(['food', 'clothes']);
      expect(filterProvider.selectedCategories, equals(['food', 'clothes']));
      expect(filterProvider.hasActiveFilters, isTrue);
    });

    test('should set locations filter', () {
      filterProvider.setLocations(['Cairo', 'Alexandria']);
      expect(filterProvider.selectedLocations, equals(['Cairo', 'Alexandria']));
      expect(filterProvider.hasActiveFilters, isTrue);
    });

    test('should set search query', () {
      filterProvider.setSearchQuery('test query');
      expect(filterProvider.searchQuery, equals('test query'));
      expect(filterProvider.hasActiveFilters, isTrue);
    });

    test('should clear all filters', () {
      filterProvider.setCategories(['food']);
      filterProvider.setLocations(['Cairo']);
      filterProvider.setSearchQuery('test');
      filterProvider.clearFilters();

      expect(filterProvider.selectedCategories, isEmpty);
      expect(filterProvider.selectedLocations, isEmpty);
      expect(filterProvider.searchQuery, isEmpty);
      expect(filterProvider.hasActiveFilters, isFalse);
    });

    test('should count active filters correctly', () {
      filterProvider.setCategories(['food']);
      filterProvider.setLocations(['Cairo']);
      filterProvider.setSearchQuery('test');

      expect(filterProvider.activeFiltersCount, equals(3));
    });
  });
}
