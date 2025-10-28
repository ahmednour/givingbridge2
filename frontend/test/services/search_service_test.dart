import 'package:flutter_test/flutter_test.dart';
import '../../lib/services/search_service.dart';

void main() {
  group('SearchService', () {
    late SearchService searchService;

    setUp(() {
      searchService = SearchService();
    });

    group('SearchSuggestion', () {
      test('should create SearchSuggestion from JSON', () {
        final json = {
          'text': 'Winter Clothes',
          'type': 'donation_title',
          'category': 'donations',
          'location': 'New York'
        };

        final suggestion = SearchSuggestion.fromJson(json);

        expect(suggestion.text, equals('Winter Clothes'));
        expect(suggestion.type, equals('donation_title'));
        expect(suggestion.category, equals('donations'));
        expect(suggestion.location, equals('New York'));
      });

      test('should convert SearchSuggestion to JSON', () {
        final suggestion = SearchSuggestion(
          text: 'Winter Clothes',
          type: 'donation_title',
          category: 'donations',
          location: 'New York',
        );

        final json = suggestion.toJson();

        expect(json['text'], equals('Winter Clothes'));
        expect(json['type'], equals('donation_title'));
        expect(json['category'], equals('donations'));
        expect(json['location'], equals('New York'));
      });

      test('should handle equality correctly', () {
        final suggestion1 = SearchSuggestion(
          text: 'Winter Clothes',
          type: 'donation_title',
          category: 'donations',
        );

        final suggestion2 = SearchSuggestion(
          text: 'Winter Clothes',
          type: 'donation_title',
          category: 'donations',
        );

        final suggestion3 = SearchSuggestion(
          text: 'Summer Clothes',
          type: 'donation_title',
          category: 'donations',
        );

        expect(suggestion1, equals(suggestion2));
        expect(suggestion1, isNot(equals(suggestion3)));
      });
    });

    group('SearchHistoryItem', () {
      test('should create SearchHistoryItem from JSON', () {
        final json = {
          'term': 'winter clothes',
          'lastSearched': '2023-10-01T12:00:00.000Z'
        };

        final historyItem = SearchHistoryItem.fromJson(json);

        expect(historyItem.term, equals('winter clothes'));
        expect(historyItem.lastSearched, equals(DateTime.parse('2023-10-01T12:00:00.000Z')));
      });

      test('should convert SearchHistoryItem to JSON', () {
        final historyItem = SearchHistoryItem(
          term: 'winter clothes',
          lastSearched: DateTime.parse('2023-10-01T12:00:00.000Z'),
        );

        final json = historyItem.toJson();

        expect(json['term'], equals('winter clothes'));
        expect(json['lastSearched'], equals('2023-10-01T12:00:00.000Z'));
      });

      test('should handle equality correctly', () {
        final historyItem1 = SearchHistoryItem(
          term: 'winter clothes',
          lastSearched: DateTime.now(),
        );

        final historyItem2 = SearchHistoryItem(
          term: 'winter clothes',
          lastSearched: DateTime.now(),
        );

        final historyItem3 = SearchHistoryItem(
          term: 'summer clothes',
          lastSearched: DateTime.now(),
        );

        expect(historyItem1, equals(historyItem2));
        expect(historyItem1, isNot(equals(historyItem3)));
      });
    });

    group('PopularSearchTerm', () {
      test('should create PopularSearchTerm from JSON', () {
        final json = {
          'search_term': 'clothes',
          'search_count': 10
        };

        final popularTerm = PopularSearchTerm.fromJson(json);

        expect(popularTerm.searchTerm, equals('clothes'));
        expect(popularTerm.searchCount, equals(10));
      });

      test('should convert PopularSearchTerm to JSON', () {
        final popularTerm = PopularSearchTerm(
          searchTerm: 'clothes',
          searchCount: 10,
        );

        final json = popularTerm.toJson();

        expect(json['search_term'], equals('clothes'));
        expect(json['search_count'], equals(10));
      });
    });

    group('SearchAnalytics', () {
      test('should create SearchAnalytics from JSON', () {
        final json = {
          'totalSearches': 100,
          'uniqueUsers': 25,
          'topTerms': [
            {'search_term': 'clothes', 'search_count': 10}
          ],
          'searchTrends': [
            {
              'search_date': '2023-10-01T00:00:00.000Z',
              'search_count': 5,
              'unique_users': 3
            }
          ],
          'averageSearchesPerUser': 4.0
        };

        final analytics = SearchAnalytics.fromJson(json);

        expect(analytics.totalSearches, equals(100));
        expect(analytics.uniqueUsers, equals(25));
        expect(analytics.topTerms, hasLength(1));
        expect(analytics.topTerms.first.searchTerm, equals('clothes'));
        expect(analytics.searchTrends, hasLength(1));
        expect(analytics.averageSearchesPerUser, equals(4.0));
      });
    });

    group('SearchTrend', () {
      test('should create SearchTrend from JSON', () {
        final json = {
          'search_date': '2023-10-01T00:00:00.000Z',
          'search_count': 5,
          'unique_users': 3
        };

        final trend = SearchTrend.fromJson(json);

        expect(trend.searchDate, equals(DateTime.parse('2023-10-01T00:00:00.000Z')));
        expect(trend.searchCount, equals(5));
        expect(trend.uniqueUsers, equals(3));
      });
    });

    test('should return empty suggestions for short terms', () async {
      final suggestions = await searchService.getSearchSuggestions('a');
      expect(suggestions, isEmpty);
    });

    test('should handle empty search term', () async {
      final suggestions = await searchService.getSearchSuggestions('');
      expect(suggestions, isEmpty);
    });

    test('should dispose resources correctly', () {
      // Test that dispose doesn't throw errors
      expect(() => searchService.dispose(), returnsNormally);
    });
  });
}