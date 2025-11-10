import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for caching data locally with expiration support
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const String _expiryPrefix = '_expiry_';

  /// Store data in cache with optional expiration
  Future<bool> store<T>(
    String key,
    T data, {
    Duration? expiry,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = json.encode(data);

      await prefs.setString(key, jsonData);

      if (expiry != null) {
        final expiryTime = DateTime.now().add(expiry).millisecondsSinceEpoch;
        await prefs.setInt('$_expiryPrefix$key', expiryTime);
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error storing cache for key $key: $e');
      }
      return false;
    }
  }

  /// Retrieve data from cache
  Future<T?> retrieve<T>(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if data has expired
      final expiryKey = '$_expiryPrefix$key';
      if (prefs.containsKey(expiryKey)) {
        final expiryTime = prefs.getInt(expiryKey);
        if (expiryTime != null &&
            DateTime.now().millisecondsSinceEpoch > expiryTime) {
          // Data has expired, remove it
          await remove(key);
          return null;
        }
      }

      final jsonData = prefs.getString(key);
      if (jsonData == null) return null;

      return json.decode(jsonData) as T;
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving cache for key $key: $e');
      }
      return null;
    }
  }

  /// Remove data from cache
  Future<bool> remove(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
      await prefs.remove('$_expiryPrefix$key');
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error removing cache for key $key: $e');
      }
      return false;
    }
  }

  /// Clear all cached data
  Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing all cache: $e');
      }
      return false;
    }
  }

  /// Check if a key exists in cache and is not expired
  Future<bool> has(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!prefs.containsKey(key)) return false;

      // Check expiry
      final expiryKey = '$_expiryPrefix$key';
      if (prefs.containsKey(expiryKey)) {
        final expiryTime = prefs.getInt(expiryKey);
        if (expiryTime != null &&
            DateTime.now().millisecondsSinceEpoch > expiryTime) {
          await remove(key);
          return false;
        }
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking cache for key $key: $e');
      }
      return false;
    }
  }

  /// Get all cache keys
  Future<Set<String>> getAllKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs
          .getKeys()
          .where((key) => !key.startsWith(_expiryPrefix))
          .toSet();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting all cache keys: $e');
      }
      return {};
    }
  }

  /// Remove expired cache entries
  Future<void> cleanExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final now = DateTime.now().millisecondsSinceEpoch;

      for (final key in keys) {
        if (key.startsWith(_expiryPrefix)) {
          final expiryTime = prefs.getInt(key);
          if (expiryTime != null && now > expiryTime) {
            final dataKey = key.substring(_expiryPrefix.length);
            await remove(dataKey);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cleaning expired cache: $e');
      }
    }
  }
}
