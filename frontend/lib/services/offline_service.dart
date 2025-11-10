import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'network_status_service.dart';

/// Service for managing offline operations and data synchronization
class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  static const String _operationsKey = 'offline_operations';
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const int _maxRetries = 3;

  final List<Map<String, dynamic>> _pendingOperations = [];
  bool _isSyncing = false;
  Timer? _syncTimer;

  /// Initialize the offline service
  Future<void> initialize() async {
    await _loadPendingOperations();
    _startAutoSync();
  }

  /// Load pending operations from storage
  Future<void> _loadPendingOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final operationsJson = prefs.getString(_operationsKey);

      if (operationsJson != null) {
        final List<dynamic> operations = json.decode(operationsJson);
        _pendingOperations.clear();
        _pendingOperations.addAll(
          operations.map((op) => Map<String, dynamic>.from(op)).toList(),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading pending operations: $e');
      }
    }
  }

  /// Save pending operations to storage
  Future<void> _savePendingOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final operationsJson = json.encode(_pendingOperations);
      await prefs.setString(_operationsKey, operationsJson);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving pending operations: $e');
      }
    }
  }

  /// Add an operation to the queue
  Future<void> addOperation({
    required String type,
    required Map<String, dynamic> data,
    String? endpoint,
  }) async {
    final operation = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': type,
      'data': data,
      'endpoint': endpoint,
      'timestamp': DateTime.now().toIso8601String(),
      'retryCount': 0,
      'error': null,
    };

    _pendingOperations.add(operation);
    await _savePendingOperations();

    // Try to sync immediately if online
    if (NetworkStatusService().isOnline) {
      unawaited(_syncOperations());
    }
  }

  /// Get current offline status
  Map<String, dynamic> getStatus() {
    return {
      'pendingOperations': _pendingOperations.length,
      'operations': List<Map<String, dynamic>>.from(_pendingOperations),
      'isSyncing': _isSyncing,
      'lastSync': _getLastSyncTime(),
      'cacheSize': 0, // Placeholder for cache size
    };
  }

  /// Get pending operations count
  int get pendingOperationsCount => _pendingOperations.length;

  /// Get last sync timestamp
  Future<DateTime?> _getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_lastSyncKey);
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting last sync time: $e');
      }
    }
    return null;
  }

  /// Update last sync timestamp
  Future<void> _updateLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating last sync time: $e');
      }
    }
  }

  /// Start automatic sync timer
  void _startAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (NetworkStatusService().isOnline && !_isSyncing) {
        unawaited(_syncOperations());
      }
    });
  }

  /// Sync all pending operations
  Future<void> _syncOperations() async {
    if (_isSyncing || _pendingOperations.isEmpty) return;

    _isSyncing = true;

    try {
      final operationsToSync =
          List<Map<String, dynamic>>.from(_pendingOperations);

      for (final operation in operationsToSync) {
        try {
          // Attempt to sync the operation
          final success = await _syncOperation(operation);

          if (success) {
            _pendingOperations.remove(operation);
          } else {
            // Increment retry count
            operation['retryCount'] = (operation['retryCount'] as int) + 1;

            // Remove if max retries exceeded
            if (operation['retryCount'] >= _maxRetries) {
              operation['error'] = 'Max retries exceeded';
              if (kDebugMode) {
                print(
                    'Operation failed after max retries: ${operation['type']}');
              }
              // Optionally remove or keep for manual retry
              // _pendingOperations.remove(operation);
            }
          }
        } catch (e) {
          operation['error'] = e.toString();
          if (kDebugMode) {
            print('Error syncing operation: $e');
          }
        }
      }

      await _savePendingOperations();
      await _updateLastSyncTime();
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync a single operation
  Future<bool> _syncOperation(Map<String, dynamic> operation) async {
    // This is a placeholder - implement actual API calls based on operation type
    final type = operation['type'] as String;
    final data = operation['data'] as Map<String, dynamic>;

    if (kDebugMode) {
      print('Syncing operation: $type with data: $data');
    }

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    // Return true if successful, false otherwise
    // In a real implementation, you would make actual API calls here
    return true;
  }

  /// Force sync all pending operations
  Future<void> forceSync() async {
    if (!NetworkStatusService().isOnline) {
      throw Exception('Cannot sync while offline');
    }

    await _syncOperations();
  }

  /// Clear all pending operations
  Future<void> clearPendingOperations() async {
    _pendingOperations.clear();
    await _savePendingOperations();
  }

  /// Remove a specific operation
  Future<void> removeOperation(String operationId) async {
    _pendingOperations.removeWhere((op) => op['id'] == operationId);
    await _savePendingOperations();
  }

  /// Clear cache
  Future<void> clearCache() async {
    // Placeholder for cache clearing logic
    if (kDebugMode) {
      print('Cache cleared');
    }
  }

  /// Dispose resources
  void dispose() {
    _syncTimer?.cancel();
  }
}

/// Helper function to avoid unawaited_futures warnings
void unawaited(Future<void> future) {
  // Intentionally not awaiting
}
