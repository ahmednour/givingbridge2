import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Cache service for storing and retrieving data locally
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const String _cachePrefix = 'givingbridge_cache_';
  static const Duration _defaultExpiry = Duration(hours: 24);

  SharedPreferences? _prefs;

  /// Initialize the cache service
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Store data in cache with optional expiry
  Future<void> store<T>(String key, T data, {Duration? expiry}) async {
    await initialize();

    final cacheKey = '$_cachePrefix$key';
    final expiryKey = '${cacheKey}_expiry';

    try {
      String jsonString;
      if (T == String) {
        jsonString = data as String;
      } else if (T == Map<String, dynamic>) {
        jsonString = jsonEncode(data);
      } else if (T == List) {
        jsonString = jsonEncode(data);
      } else {
        jsonString = jsonEncode(data);
      }

      await _prefs!.setString(cacheKey, jsonString);

      // Store expiry time
      final expiryTime = DateTime.now().add(expiry ?? _defaultExpiry);
      await _prefs!.setString(expiryKey, expiryTime.toIso8601String());

      if (kDebugMode) {
        print('Cached data for key: $key');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error caching data for key $key: $e');
      }
    }
  }

  /// Retrieve data from cache
  Future<T?> retrieve<T>(String key) async {
    await initialize();

    final cacheKey = '$_cachePrefix$key';
    final expiryKey = '${cacheKey}_expiry';

    try {
      // Check if data exists
      if (!_prefs!.containsKey(cacheKey)) {
        return null;
      }

      // Check expiry
      final expiryString = _prefs!.getString(expiryKey);
      if (expiryString != null) {
        final expiryTime = DateTime.parse(expiryString);
        if (DateTime.now().isAfter(expiryTime)) {
          // Data expired, remove it
          await remove(key);
          return null;
        }
      }

      final jsonString = _prefs!.getString(cacheKey);
      if (jsonString == null) return null;

      if (T == String) {
        return jsonString as T;
      } else if (T == Map<String, dynamic>) {
        return jsonDecode(jsonString) as T;
      } else if (T == List) {
        return jsonDecode(jsonString) as T;
      } else {
        return jsonDecode(jsonString) as T;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving cached data for key $key: $e');
      }
      return null;
    }
  }

  /// Remove data from cache
  Future<void> remove(String key) async {
    await initialize();

    final cacheKey = '$_cachePrefix$key';
    final expiryKey = '${cacheKey}_expiry';

    await _prefs!.remove(cacheKey);
    await _prefs!.remove(expiryKey);

    if (kDebugMode) {
      print('Removed cached data for key: $key');
    }
  }

  /// Clear all cached data
  Future<void> clear() async {
    await initialize();

    final keys = _prefs!.getKeys();
    final cacheKeys = keys.where((key) => key.startsWith(_cachePrefix));

    for (final key in cacheKeys) {
      await _prefs!.remove(key);
    }

    if (kDebugMode) {
      print('Cleared all cached data');
    }
  }

  /// Check if data exists in cache and is not expired
  Future<bool> exists(String key) async {
    await initialize();

    final cacheKey = '$_cachePrefix$key';
    final expiryKey = '${cacheKey}_expiry';

    if (!_prefs!.containsKey(cacheKey)) {
      return false;
    }

    final expiryString = _prefs!.getString(expiryKey);
    if (expiryString != null) {
      final expiryTime = DateTime.parse(expiryString);
      if (DateTime.now().isAfter(expiryTime)) {
        await remove(key);
        return false;
      }
    }

    return true;
  }

  /// Get cache size in bytes (approximate)
  Future<int> getCacheSize() async {
    await initialize();

    final keys = _prefs!.getKeys();
    final cacheKeys = keys.where((key) => key.startsWith(_cachePrefix));

    int totalSize = 0;
    for (final key in cacheKeys) {
      final value = _prefs!.getString(key);
      if (value != null) {
        totalSize += value.length * 2; // Approximate UTF-16 size
      }
    }

    return totalSize;
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    await initialize();

    final keys = _prefs!.getKeys();
    final cacheKeys = keys.where((key) => key.startsWith(_cachePrefix));

    int totalKeys = 0;
    int expiredKeys = 0;
    int totalSize = 0;

    for (final key in cacheKeys) {
      if (!key.endsWith('_expiry')) {
        totalKeys++;

        final expiryKey = '${key}_expiry';
        final expiryString = _prefs!.getString(expiryKey);

        if (expiryString != null) {
          final expiryTime = DateTime.parse(expiryString);
          if (DateTime.now().isAfter(expiryTime)) {
            expiredKeys++;
          }
        }

        final value = _prefs!.getString(key);
        if (value != null) {
          totalSize += value.length * 2;
        }
      }
    }

    return {
      'totalKeys': totalKeys,
      'expiredKeys': expiredKeys,
      'activeKeys': totalKeys - expiredKeys,
      'totalSizeBytes': totalSize,
      'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
    };
  }
}

/// Cache keys constants
class CacheKeys {
  static const String userProfile = 'user_profile';
  static const String donations = 'donations';
  static const String requests = 'requests';
  static const String conversations = 'conversations';
  static const String notifications = 'notifications';
  static const String userStats = 'user_stats';
  static const String appSettings = 'app_settings';
  static const String searchHistory = 'search_history';
  static const String favoriteDonations = 'favorite_donations';
  static const String recentSearches = 'recent_searches';
  static const String savedFilters = 'saved_filters';
  static const String activeFilters = 'active_filters';
  static const String filterPresets = 'filter_presets';
}

/// Cache expiry durations
class CacheExpiry {
  static const Duration userProfile = Duration(hours: 24);
  static const Duration donations = Duration(minutes: 30);
  static const Duration requests = Duration(minutes: 30);
  static const Duration conversations = Duration(hours: 1);
  static const Duration notifications = Duration(minutes: 15);
  static const Duration userStats = Duration(hours: 6);
  static const Duration appSettings = Duration(days: 7);
  static const Duration searchHistory = Duration(days: 30);
  static const Duration favoriteDonations = Duration(hours: 12);
  static const Duration recentSearches = Duration(days: 7);
  static const Duration savedFilters = Duration(days: 365);
  static const Duration activeFilters = Duration(days: 7);
  static const Duration filterPresets = Duration(days: 365);
}
