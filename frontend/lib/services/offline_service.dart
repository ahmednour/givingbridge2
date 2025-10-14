import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Offline operation types
enum OfflineOperationType {
  createDonation,
  updateDonation,
  deleteDonation,
  createRequest,
  updateRequest,
  deleteRequest,
  sendMessage,
  updateProfile,
  uploadImage,
}

/// Offline operation data structure
class OfflineOperation {
  final String id;
  final OfflineOperationType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int retryCount;
  final String? error;

  OfflineOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
      'error': error,
    };
  }

  factory OfflineOperation.fromJson(Map<String, dynamic> json) {
    return OfflineOperation(
      id: json['id'],
      type: OfflineOperationType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
      retryCount: json['retryCount'] ?? 0,
      error: json['error'],
    );
  }

  OfflineOperation copyWith({
    String? id,
    OfflineOperationType? type,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    int? retryCount,
    String? error,
  }) {
    return OfflineOperation(
      id: id ?? this.id,
      type: type ?? this.type,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
      error: error ?? this.error,
    );
  }
}

/// Offline data cache for storing data locally
class OfflineDataCache {
  final String key;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final Duration? expiry;

  OfflineDataCache({
    required this.key,
    required this.data,
    required this.timestamp,
    this.expiry,
  });

  bool get isExpired {
    if (expiry == null) return false;
    return DateTime.now().difference(timestamp) > expiry!;
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'expiry': expiry?.inMilliseconds,
    };
  }

  factory OfflineDataCache.fromJson(Map<String, dynamic> json) {
    return OfflineDataCache(
      key: json['key'],
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
      expiry: json['expiry'] != null
          ? Duration(milliseconds: json['expiry'])
          : null,
    );
  }
}

/// Comprehensive offline support service
class OfflineService {
  static const String _operationsKey = 'offline_operations';
  static const String _cacheKey = 'offline_cache';
  static const String _lastSyncKey = 'last_sync';

  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  final List<OfflineOperation> _pendingOperations = [];
  final Map<String, OfflineDataCache> _cache = {};
  bool _isOnline = true;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  /// Initialize the offline service
  Future<void> initialize() async {
    await _loadPendingOperations();
    await _loadCache();
    _startConnectivityMonitoring();
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
  }

  /// Check if device is online
  bool get isOnline => _isOnline;

  /// Get pending operations count
  int get pendingOperationsCount => _pendingOperations.length;

  /// Get cache size
  int get cacheSize => _cache.length;

  /// Start monitoring connectivity
  void _startConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) {
        final wasOnline = _isOnline;
        _isOnline = result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.ethernet;

        if (!wasOnline && _isOnline) {
          _onConnectionRestored();
        } else if (wasOnline && !_isOnline) {
          _onConnectionLost();
        }
      },
    );
  }

  /// Handle connection restored
  Future<void> _onConnectionRestored() async {
    debugPrint(
        'OfflineService: Connection restored, syncing pending operations');
    await syncPendingOperations();
  }

  /// Handle connection lost
  void _onConnectionLost() {
    debugPrint('OfflineService: Connection lost, operations will be queued');
  }

  /// Queue operation for offline execution
  Future<String> queueOperation({
    required OfflineOperationType type,
    required Map<String, dynamic> data,
  }) async {
    final operation = OfflineOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      data: data,
      timestamp: DateTime.now(),
    );

    _pendingOperations.add(operation);
    await _savePendingOperations();

    // If online, try to execute immediately
    if (_isOnline) {
      await _executeOperation(operation);
    }

    return operation.id;
  }

  /// Execute a single operation
  Future<bool> _executeOperation(OfflineOperation operation) async {
    try {
      // This would be implemented with actual API calls
      // For now, we'll simulate success
      await Future.delayed(const Duration(milliseconds: 500));

      // Remove from pending operations
      _pendingOperations.removeWhere((op) => op.id == operation.id);
      await _savePendingOperations();

      return true;
    } catch (error) {
      // Increment retry count
      final updatedOperation = operation.copyWith(
        retryCount: operation.retryCount + 1,
        error: error.toString(),
      );

      // Update in pending operations
      final index =
          _pendingOperations.indexWhere((op) => op.id == operation.id);
      if (index != -1) {
        _pendingOperations[index] = updatedOperation;
        await _savePendingOperations();
      }

      return false;
    }
  }

  /// Sync all pending operations
  Future<void> syncPendingOperations() async {
    if (!_isOnline || _pendingOperations.isEmpty) return;

    debugPrint(
        'OfflineService: Syncing ${_pendingOperations.length} operations');

    final operationsToSync = List<OfflineOperation>.from(_pendingOperations);

    for (final operation in operationsToSync) {
      if (operation.retryCount >= 3) {
        // Remove operations that have failed too many times
        _pendingOperations.removeWhere((op) => op.id == operation.id);
        continue;
      }

      await _executeOperation(operation);
    }

    await _savePendingOperations();
    await _updateLastSyncTime();
  }

  /// Cache data for offline access
  Future<void> cacheData({
    required String key,
    required Map<String, dynamic> data,
    Duration? expiry,
  }) async {
    final cache = OfflineDataCache(
      key: key,
      data: data,
      timestamp: DateTime.now(),
      expiry: expiry,
    );

    _cache[key] = cache;
    await _saveCache();
  }

  /// Get cached data
  Map<String, dynamic>? getCachedData(String key) {
    final cache = _cache[key];
    if (cache == null || cache.isExpired) {
      _cache.remove(key);
      return null;
    }
    return cache.data;
  }

  /// Remove cached data
  Future<void> removeCachedData(String key) async {
    _cache.remove(key);
    await _saveCache();
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    _cache.clear();
    await _saveCache();
  }

  /// Get pending operations
  List<OfflineOperation> getPendingOperations() {
    return List.unmodifiable(_pendingOperations);
  }

  /// Clear pending operations
  Future<void> clearPendingOperations() async {
    _pendingOperations.clear();
    await _savePendingOperations();
  }

  /// Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getString(_lastSyncKey);
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  /// Update last sync time
  Future<void> _updateLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }

  /// Load pending operations from storage
  Future<void> _loadPendingOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final operationsJson = prefs.getString(_operationsKey);

      if (operationsJson != null) {
        final List<dynamic> operationsList = jsonDecode(operationsJson);
        _pendingOperations.clear();
        _pendingOperations.addAll(
          operationsList.map((json) => OfflineOperation.fromJson(json)),
        );
      }
    } catch (error) {
      debugPrint('OfflineService: Error loading pending operations: $error');
    }
  }

  /// Save pending operations to storage
  Future<void> _savePendingOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final operationsJson = jsonEncode(
        _pendingOperations.map((op) => op.toJson()).toList(),
      );
      await prefs.setString(_operationsKey, operationsJson);
    } catch (error) {
      debugPrint('OfflineService: Error saving pending operations: $error');
    }
  }

  /// Load cache from storage
  Future<void> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheJson = prefs.getString(_cacheKey);

      if (cacheJson != null) {
        final Map<String, dynamic> cacheMap = jsonDecode(cacheJson);
        _cache.clear();

        for (final entry in cacheMap.entries) {
          final cache = OfflineDataCache.fromJson(entry.value);
          if (!cache.isExpired) {
            _cache[entry.key] = cache;
          }
        }
      }
    } catch (error) {
      debugPrint('OfflineService: Error loading cache: $error');
    }
  }

  /// Save cache to storage
  Future<void> _saveCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheMap = <String, dynamic>{};

      for (final entry in _cache.entries) {
        cacheMap[entry.key] = entry.value.toJson();
      }

      await prefs.setString(_cacheKey, jsonEncode(cacheMap));
    } catch (error) {
      debugPrint('OfflineService: Error saving cache: $error');
    }
  }

  /// Get offline status summary
  Map<String, dynamic> getStatus() {
    return {
      'isOnline': _isOnline,
      'pendingOperations': _pendingOperations.length,
      'cacheSize': _cache.length,
      'operations': _pendingOperations
          .map((op) => {
                'id': op.id,
                'type': op.type.name,
                'timestamp': op.timestamp.toIso8601String(),
                'retryCount': op.retryCount,
                'error': op.error,
              })
          .toList(),
    };
  }

  /// Force sync (useful for manual refresh)
  Future<void> forceSync() async {
    if (_isOnline) {
      await syncPendingOperations();
    }
  }

  /// Check if specific data is available offline
  bool isDataAvailableOffline(String key) {
    return _cache.containsKey(key) && !_cache[key]!.isExpired;
  }

  /// Get offline data keys
  List<String> getOfflineDataKeys() {
    return _cache.keys.toList();
  }
}

/// Offline-aware repository mixin
mixin OfflineAwareRepository {
  final OfflineService _offlineService = OfflineService();

  /// Execute operation with offline support
  Future<T?> executeWithOfflineSupport<T>({
    required String cacheKey,
    required Future<T> Function() onlineOperation,
    T? Function()? offlineOperation,
    Duration? cacheExpiry,
  }) async {
    // If online, try online operation first
    if (_offlineService.isOnline) {
      try {
        final result = await onlineOperation();

        // Cache the result
        if (result != null) {
          await _offlineService.cacheData(
            key: cacheKey,
            data: result as Map<String, dynamic>,
            expiry: cacheExpiry,
          );
        }

        return result;
      } catch (error) {
        // If online operation fails, try offline
        debugPrint('Online operation failed, trying offline: $error');
      }
    }

    // Try offline operation
    if (offlineOperation != null) {
      return offlineOperation();
    }

    // Return cached data if available
    return _offlineService.getCachedData(cacheKey) as T?;
  }

  /// Queue operation for offline execution
  Future<String> queueOfflineOperation({
    required OfflineOperationType type,
    required Map<String, dynamic> data,
  }) {
    return _offlineService.queueOperation(type: type, data: data);
  }

  /// Get offline service instance
  OfflineService get offlineService => _offlineService;
}
