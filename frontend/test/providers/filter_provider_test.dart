import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:giving_bridge_frontend/providers/filter_provider.dart';
import 'package:giving_bridge_frontend/services/cache_service.dart';

// Mock classes
class MockCacheService extends Mock implements CacheService {}

void main() {
  group('FilterProvider Tests', () {
    late FilterProvider filterProvider;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      filterProvider = FilterProvider();
    });

    group('Basic Filter Operations', () {
      test('should initialize with default values', () {
        expect(filterProvider.searchQuery, '');
        expect(filterProvider.selectedCategories, isEmpty);
        expect(filterProvider.selectedLocations, isEmpty);
        expect(filterProvider.selectedConditions, isEmpty);
        expect(filterProvider.selectedStatuses, isEmpty);
        expect(filterProvider.sortBy, 'createdAt');
        expect(filterProvider.sortOrder, 'desc');
        expect(filterProvider.pageSize, 20);
        expect(filterProvider.hasActiveFilters, false);
        expect(filterProvider.activeFiltersCount, 0);
      });

      test('should set search query correctly', () {
        const testQuery = 'test search';
        filterProvider.setSearchQuery(testQuery);

        expect(filterProvider.searchQuery, testQuery);
        expect(filterProvider.hasActiveFilters, true);
        expect(filterProvider.activeFiltersCount, 1);
      });

      test('should manage categories correctly', () {
        const categories = ['food', 'clothes'];

        // Test setting multiple categories
        filterProvider.setCategories(categories);
        expect(filterProvider.selectedCategories, categories);
        expect(filterProvider.hasActiveFilters, true);
        expect(filterProvider.activeFiltersCount, 1);
      });

      test('should manage date range correctly', () {
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 12, 31);

        filterProvider.setDateRange(startDate, endDate);

        expect(filterProvider.startDate, startDate);
        expect(filterProvider.endDate, endDate);
        expect(filterProvider.hasActiveFilters, true);
        expect(filterProvider.activeFiltersCount, 1);

        filterProvider.clearDateRange();
        expect(filterProvider.startDate, isNull);
        expect(filterProvider.endDate, isNull);
      });

      test('should manage amount range correctly', () {
        const minAmount = 10.0;
        const maxAmount = 100.0;

        filterProvider.setAmountRange(minAmount, maxAmount);

        expect(filterProvider.minAmount, minAmount);
        expect(filterProvider.maxAmount, maxAmount);
        expect(filterProvider.hasActiveFilters, true);
        expect(filterProvider.activeFiltersCount, 1);

        filterProvider.clearAmountRange();
        expect(filterProvider.minAmount, isNull);
        expect(filterProvider.maxAmount, isNull);
      });
    });

    group('Advanced Filter Operations', () {
      test('should manage advanced filters correctly', () {
        filterProvider.setVerifiedOnly(true);
        filterProvider.setUrgentOnly(true);
        filterProvider.setDistance('10');

        expect(filterProvider.verifiedOnly, true);
        expect(filterProvider.urgentOnly, true);
        expect(filterProvider.selectedDistance, '10');
        expect(filterProvider.hasActiveFilters, true);
        expect(filterProvider.activeFiltersCount, 3);
      });
    });

    group('Filter Summary and State', () {
      test('should provide correct filter summary', () {
        filterProvider.setSearchQuery('test');
        filterProvider.setCategories(['food']);
        filterProvider.setVerifiedOnly(true);

        final summary = filterProvider.filterSummary;

        expect(summary['searchQuery'], 'test');
        expect(summary['categories'], ['food']);
        expect(summary['verifiedOnly'], true);
        expect(summary['hasActiveFilters'], true);
        expect(summary['activeFiltersCount'], 3);
      });
    });

    group('Clear Operations', () {
      test('should clear all filters correctly', () {
        // Set up some filters
        filterProvider.setSearchQuery('test');
        filterProvider.setCategories(['food']);
        filterProvider.setStatuses(['available']);
        filterProvider.setVerifiedOnly(true);
        filterProvider.setDateRange(DateTime.now(), DateTime.now());

        expect(filterProvider.hasActiveFilters, true);

        // Clear all filters
        filterProvider.clearFilters();

        expect(filterProvider.searchQuery, '');
        expect(filterProvider.selectedCategories, isEmpty);
        expect(filterProvider.selectedStatuses, isEmpty);
        expect(filterProvider.verifiedOnly, false);
        expect(filterProvider.startDate, isNull);
        expect(filterProvider.endDate, isNull);
        expect(filterProvider.hasActiveFilters, false);
        expect(filterProvider.activeFiltersCount, 0);
      });
    });
  });
}
