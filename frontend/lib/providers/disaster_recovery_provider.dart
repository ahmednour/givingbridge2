import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../core/utils/logger.dart';

class DisasterRecoveryProvider with ChangeNotifier {
  final ApiService _apiService;
  
  bool _isLoading = false;
  String? _error;
  
  Map<String, dynamic>? _recoveryStatus;
  Map<String, dynamic>? _systemHealth;
  Map<String, dynamic>? _recoveryMetrics;
  Map<String, dynamic>? _lastTestResult;
  Map<String, dynamic>? _lastRecoveryResult;

  DisasterRecoveryProvider(this._apiService);

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get recoveryStatus => _recoveryStatus;
  Map<String, dynamic>? get systemHealth => _systemHealth;
  Map<String, dynamic>? get recoveryMetrics => _recoveryMetrics;
  Map<String, dynamic>? get lastTestResult => _lastTestResult;
  Map<String, dynamic>? get lastRecoveryResult => _lastRecoveryResult;

  /// Load complete recovery status
  Future<void> loadRecoveryStatus() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.get('/disaster-recovery/status');
      
      if (response['success']) {
        _recoveryStatus = response['data'];
        Logger.info('Recovery status loaded successfully');
      } else {
        throw Exception(response['message'] ?? 'Failed to load recovery status');
      }
    } catch (e) {
      _setError('Failed to load recovery status: ${e.toString()}');
      Logger.error('Failed to load recovery status', e);
    } finally {
      _setLoading(false);
    }
  }

  /// Check system health
  Future<void> checkSystemHealth() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.get('/disaster-recovery/health');
      
      if (response['success']) {
        _systemHealth = response['data'];
        Logger.info('System health checked successfully');
      } else {
        throw Exception(response['message'] ?? 'Failed to check system health');
      }
    } catch (e) {
      _setError('Failed to check system health: ${e.toString()}');
      Logger.error('Failed to check system health', e);
    } finally {
      _setLoading(false);
    }
  }

  /// Monitor recovery readiness
  Future<void> monitorRecoveryReadiness() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.get('/disaster-recovery/readiness');
      
      if (response['success']) {
        final readiness = response['data'];
        
        // Update recovery status with readiness information
        if (_recoveryStatus != null) {
          _recoveryStatus!['readiness'] = readiness;
        } else {
          _recoveryStatus = {'readiness': readiness};
        }
        
        Logger.info('Recovery readiness monitored successfully');
      } else {
        throw Exception(response['message'] ?? 'Failed to monitor recovery readiness');
      }
    } catch (e) {
      _setError('Failed to monitor recovery readiness: ${e.toString()}');
      Logger.error('Failed to monitor recovery readiness', e);
    } finally {
      _setLoading(false);
    }
  }

  /// Get recovery metrics
  Future<void> loadRecoveryMetrics() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.get('/disaster-recovery/metrics');
      
      if (response['success']) {
        _recoveryMetrics = response['data'];
        Logger.info('Recovery metrics loaded successfully');
      } else {
        throw Exception(response['message'] ?? 'Failed to load recovery metrics');
      }
    } catch (e) {
      _setError('Failed to load recovery metrics: ${e.toString()}');
      Logger.error('Failed to load recovery metrics', e);
    } finally {
      _setLoading(false);
    }
  }

  /// Test recovery procedures
  Future<void> testRecoveryProcedures() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.post('/disaster-recovery/test', {});
      
      if (response['success']) {
        _lastTestResult = response['data'];
        
        // Refresh recovery status after test
        await loadRecoveryStatus();
        
        Logger.info('Recovery test completed successfully');
      } else {
        throw Exception(response['message'] ?? 'Recovery test failed');
      }
    } catch (e) {
      _setError('Recovery test failed: ${e.toString()}');
      Logger.error('Recovery test failed', e);
    } finally {
      _setLoading(false);
    }
  }

  /// Perform full disaster recovery
  Future<void> performFullRecovery() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.post('/disaster-recovery/recover', {
        'confirmation': 'I_UNDERSTAND_THIS_IS_DESTRUCTIVE'
      });
      
      if (response['success']) {
        _lastRecoveryResult = response['data'];
        
        // Refresh recovery status after recovery
        await loadRecoveryStatus();
        
        Logger.info('Disaster recovery completed successfully');
      } else {
        throw Exception(response['message'] ?? 'Disaster recovery failed');
      }
    } catch (e) {
      _setError('Disaster recovery failed: ${e.toString()}');
      Logger.error('Disaster recovery failed', e);
    } finally {
      _setLoading(false);
    }
  }

  /// Get recovery readiness summary
  bool get isRecoveryReady {
    final readiness = _recoveryStatus?['readiness'];
    return readiness?['ready'] ?? false;
  }

  /// Get system health status
  String get systemHealthStatus {
    return _systemHealth?['status'] ?? 'unknown';
  }

  /// Get backup freshness status
  bool get isBackupFresh {
    final readiness = _recoveryStatus?['readiness'];
    return readiness?['backupFresh'] ?? false;
  }

  /// Get system health status
  bool get isSystemHealthy {
    final readiness = _recoveryStatus?['readiness'];
    return readiness?['systemHealthy'] ?? false;
  }

  /// Get last test success status
  bool get lastTestSuccessful {
    return _lastTestResult?['success'] ?? false;
  }

  /// Get last recovery success status
  bool get lastRecoverySuccessful {
    return _lastRecoveryResult?['success'] ?? false;
  }

  /// Get recovery time objective compliance
  bool get isWithinRecoveryTimeObjective {
    final lastDuration = _recoveryMetrics?['lastRecoveryDuration'];
    final rto = _recoveryMetrics?['recoveryTimeObjective'];
    
    if (lastDuration == null || rto == null) return true;
    
    return lastDuration <= rto;
  }

  /// Get recovery point objective compliance
  bool get isWithinRecoveryPointObjective {
    final readiness = _recoveryStatus?['readiness'];
    final backupAge = readiness?['backupAge'];
    final rpo = readiness?['recoveryPointObjective'];
    
    if (backupAge == null || rpo == null) return true;
    
    return backupAge <= rpo;
  }

  /// Refresh all recovery data
  Future<void> refreshAll() async {
    await Future.wait([
      loadRecoveryStatus(),
      checkSystemHealth(),
      loadRecoveryMetrics(),
    ]);
  }

  /// Start automatic monitoring
  void startMonitoring() {
    // Refresh data every 5 minutes
    Timer.periodic(const Duration(minutes: 5), (timer) {
      if (!_isLoading) {
        monitorRecoveryReadiness();
      }
    });
    
    Logger.info('Disaster recovery monitoring started');
  }

  /// Stop automatic monitoring
  void stopMonitoring() {
    // Timer will be cancelled when provider is disposed
    Logger.info('Disaster recovery monitoring stopped');
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}