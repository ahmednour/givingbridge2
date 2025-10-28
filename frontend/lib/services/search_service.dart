import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'cache_service.dart';
import '../core/config/api_config.dart';

/// Service for handling search functionality including suggestions and history
class SearchService {
  static final SearchService _instance = SearchService._internal();
  factory SearchService() => _instance;
  SearchService._internal();

  final CacheService _cacheService = CacheService();
  
  // Cache keys
  static const String _searchHistoryCacheKey = 'search_history';
  static const String _popularTermsCacheKey = 'popular_search_terms';
  static const String _suggestionsCacheKey = 'search_suggestions';
  
  // Debounce timer for suggestions
  Timer? _suggestionDebounceTimer;
  
  // In-memory cache for suggestions
  final Map<String, List<SearchSuggestion>> _suggestionsCache = {};
  
  /// Get search suggestions based on partial input
  Future<List<SearchSuggestion>> getSearchSuggestions(
    String partialTerm, {
    String type = 'all',
    int limit = 10,
  }) async {
    if (partialTerm.length < 2) {
      return [];
    }

    final cacheKey = '${partialTerm.toLowerCase()}_${type}_$limit';
    
    // Check in-memory cache first
    if (_suggestionsCache.containsKey(cacheKey)) {
      return _suggestionsCache[cacheKey]!;
    }

    try {
      final token = await ApiService.getToken();
      final uri = Uri.parse('${ApiConfig.baseUrl}/search/suggestions').replace(
        queryParameters: {
          'q': partialTerm,
          'type': type,
          'limit': limit.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final suggestions = (data['suggestions'] as List)
            .map((item) => SearchSuggestion.fromJson(item))
            .toList();
        
        // Cache suggestions for 5 minutes
        _suggestionsCache[cacheKey] = suggestions;
        Timer(const Duration(minutes: 5), () {
          _suggestionsCache.remove(cacheKey);
        });
        
        return suggestions;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting search suggestions: $e');
      }
    }

    return [];
  }

  /// Get search suggestions with debouncing
  Future<List<SearchSuggestion>> getSearchSuggestionsDebounced(
    String partialTerm, {
    String type = 'all',
    int limit = 10,
    Duration debounceDelay = const Duration(milliseconds: 300),
  }) async {
    final completer = Completer<List<SearchSuggestion>>();
    
    _suggestionDebounceTimer?.cancel();
    _suggestionDebounceTimer = Timer(debounceDelay, () async {
      try {
        final suggestions = await getSearchSuggestions(
          partialTerm,
          type: type,
          limit: limit,
        );
        completer.complete(suggestions);
      } catch (e) {
        completer.completeError(e);
      }
    });
    
    return completer.future;
  }

  /// Get user's search history
  Future<List<SearchHistoryItem>> getSearchHistory({int limit = 20}) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        // Return cached data if no token
        try {
          final cachedData = await _cacheService.retrieve<List<dynamic>>(_searchHistoryCacheKey);
          if (cachedData != null) {
            return cachedData
                .map((item) => SearchHistoryItem.fromJson(item))
                .toList();
          }
        } catch (cacheError) {
          if (kDebugMode) {
            print('Error getting cached search history: $cacheError');
          }
        }
        return [];
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/search/history').replace(
        queryParameters: {'limit': limit.toString()},
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final history = (data['history'] as List)
            .map((item) => SearchHistoryItem.fromJson(item))
            .toList();
        
        // Cache history for 1 hour
        await _cacheService.store(
          _searchHistoryCacheKey,
          history.map((item) => item.toJson()).toList(),
          expiry: const Duration(hours: 1),
        );
        
        return history;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting search history: $e');
      }
      
      // Try to get from cache if API fails
      try {
        final cachedData = await _cacheService.retrieve<List<dynamic>>(_searchHistoryCacheKey);
        if (cachedData != null) {
          return cachedData
              .map((item) => SearchHistoryItem.fromJson(item))
              .toList();
        }
      } catch (cacheError) {
        if (kDebugMode) {
          print('Error getting cached search history: $cacheError');
        }
      }
    }

    return [];
  }

  /// Clear user's search history
  Future<bool> clearSearchHistory() async {
    try {
      final token = await ApiService.getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/search/history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Clear local cache as well
        await _cacheService.remove(_searchHistoryCacheKey);
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing search history: $e');
      }
    }

    return false;
  }

  /// Get popular search terms
  Future<List<PopularSearchTerm>> getPopularSearchTerms({
    int limit = 10,
    int days = 30,
  }) async {
    try {
      final token = await ApiService.getToken();
      final uri = Uri.parse('${ApiConfig.baseUrl}/search/popular').replace(
        queryParameters: {
          'limit': limit.toString(),
          'days': days.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final terms = (data['popularTerms'] as List)
            .map((item) => PopularSearchTerm.fromJson(item))
            .toList();
        
        // Cache popular terms for 1 hour
        await _cacheService.store(
          _popularTermsCacheKey,
          terms.map((term) => term.toJson()).toList(),
          expiry: const Duration(hours: 1),
        );
        
        return terms;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting popular search terms: $e');
      }
      
      // Try to get from cache if API fails
      try {
        final cachedData = await _cacheService.retrieve<List<dynamic>>(_popularTermsCacheKey);
        if (cachedData != null) {
          return cachedData
              .map((item) => PopularSearchTerm.fromJson(item))
              .toList();
        }
      } catch (cacheError) {
        if (kDebugMode) {
          print('Error getting cached popular terms: $cacheError');
        }
      }
    }

    return [];
  }

  /// Get search analytics (admin only)
  Future<SearchAnalytics?> getSearchAnalytics({int days = 30}) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) return null;

      final uri = Uri.parse('${ApiConfig.baseUrl}/search/analytics').replace(
        queryParameters: {'days': days.toString()},
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SearchAnalytics.fromJson(data['analytics']);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting search analytics: $e');
      }
    }

    return null;
  }

  /// Add a search term to local history (for offline support)
  Future<void> addToLocalHistory(String searchTerm) async {
    if (searchTerm.trim().isEmpty) return;

    try {
      final history = await getSearchHistory();
      final existingIndex = history.indexWhere((item) => item.term == searchTerm);
      
      if (existingIndex != -1) {
        // Move existing term to top
        history.removeAt(existingIndex);
      }
      
      // Add to beginning
      history.insert(0, SearchHistoryItem(
        term: searchTerm,
        lastSearched: DateTime.now(),
      ));
      
      // Keep only last 50 items
      if (history.length > 50) {
        history.removeRange(50, history.length);
      }
      
      // Save to cache
      await _cacheService.store(
        _searchHistoryCacheKey,
        history.map((item) => item.toJson()).toList(),
        expiry: const Duration(days: 30),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error adding to local search history: $e');
      }
    }
  }

  /// Clear all caches
  Future<void> clearCaches() async {
    _suggestionsCache.clear();
    await _cacheService.remove(_searchHistoryCacheKey);
    await _cacheService.remove(_popularTermsCacheKey);
    await _cacheService.remove(_suggestionsCacheKey);
  }

  /// Dispose resources
  void dispose() {
    _suggestionDebounceTimer?.cancel();
    _suggestionsCache.clear();
  }
}

/// Model for search suggestions
class SearchSuggestion {
  final String text;
  final String type;
  final String category;
  final String? location;

  SearchSuggestion({
    required this.text,
    required this.type,
    required this.category,
    this.location,
  });

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) {
    return SearchSuggestion(
      text: json['text'] ?? '',
      type: json['type'] ?? '',
      category: json['category'] ?? '',
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'type': type,
      'category': category,
      'location': location,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchSuggestion &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          type == other.type &&
          category == other.category;

  @override
  int get hashCode => text.hashCode ^ type.hashCode ^ category.hashCode;
}

/// Model for search history items
class SearchHistoryItem {
  final String term;
  final DateTime lastSearched;

  SearchHistoryItem({
    required this.term,
    required this.lastSearched,
  });

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) {
    return SearchHistoryItem(
      term: json['term'] ?? '',
      lastSearched: DateTime.parse(json['lastSearched'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'term': term,
      'lastSearched': lastSearched.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchHistoryItem &&
          runtimeType == other.runtimeType &&
          term == other.term;

  @override
  int get hashCode => term.hashCode;
}

/// Model for popular search terms
class PopularSearchTerm {
  final String searchTerm;
  final int searchCount;

  PopularSearchTerm({
    required this.searchTerm,
    required this.searchCount,
  });

  factory PopularSearchTerm.fromJson(Map<String, dynamic> json) {
    return PopularSearchTerm(
      searchTerm: json['search_term'] ?? '',
      searchCount: json['search_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'search_term': searchTerm,
      'search_count': searchCount,
    };
  }
}

/// Model for search analytics
class SearchAnalytics {
  final int totalSearches;
  final int uniqueUsers;
  final List<PopularSearchTerm> topTerms;
  final List<SearchTrend> searchTrends;
  final double averageSearchesPerUser;

  SearchAnalytics({
    required this.totalSearches,
    required this.uniqueUsers,
    required this.topTerms,
    required this.searchTrends,
    required this.averageSearchesPerUser,
  });

  factory SearchAnalytics.fromJson(Map<String, dynamic> json) {
    return SearchAnalytics(
      totalSearches: json['totalSearches'] ?? 0,
      uniqueUsers: json['uniqueUsers'] ?? 0,
      topTerms: (json['topTerms'] as List? ?? [])
          .map((item) => PopularSearchTerm.fromJson(item))
          .toList(),
      searchTrends: (json['searchTrends'] as List? ?? [])
          .map((item) => SearchTrend.fromJson(item))
          .toList(),
      averageSearchesPerUser: (json['averageSearchesPerUser'] ?? 0).toDouble(),
    );
  }
}

/// Model for search trends
class SearchTrend {
  final DateTime searchDate;
  final int searchCount;
  final int uniqueUsers;

  SearchTrend({
    required this.searchDate,
    required this.searchCount,
    required this.uniqueUsers,
  });

  factory SearchTrend.fromJson(Map<String, dynamic> json) {
    return SearchTrend(
      searchDate: DateTime.parse(json['search_date']),
      searchCount: json['search_count'] ?? 0,
      uniqueUsers: json['unique_users'] ?? 0,
    );
  }
}