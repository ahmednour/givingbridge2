import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/notification_preference.dart';

/// Provider for managing notification preferences
class NotificationPreferenceProvider extends ChangeNotifier {
  NotificationPreference? _preferences;
  bool _isLoading = false;
  String? _error;

  // Getters
  NotificationPreference? get preferences => _preferences;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasPreferences => _preferences != null;

  /// Load notification preferences
  Future<void> loadPreferences() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getNotificationPreferences();

      if (response.success && response.data != null) {
        _preferences = response.data;
      } else {
        _error = response.error ?? 'Failed to load notification preferences';
      }
    } catch (e) {
      _error = 'Error loading notification preferences: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update notification preferences
  Future<bool> updatePreferences(Map<String, bool> updates) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.updateNotificationPreferences(updates);

      if (response.success && response.data != null) {
        _preferences = response.data;
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Failed to update notification preferences';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error updating notification preferences: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Reset notification preferences to defaults
  Future<bool> resetPreferences() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.resetNotificationPreferences();

      if (response.success && response.data != null) {
        _preferences = response.data;
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Failed to reset notification preferences';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error resetting notification preferences: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Update a single preference
  Future<bool> updatePreference(String key, bool value) async {
    final updates = {key: value};
    return await updatePreferences(updates);
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _preferences = null;
    _error = null;
    notifyListeners();
  }
}
