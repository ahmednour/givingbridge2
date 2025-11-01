import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Simplified notification provider for MVP - only basic in-app notifications for messages
class NotificationProvider extends ChangeNotifier {
  // Default notification settings - only in-app message notifications
  bool _inAppNotifications = true;
  bool _messages = true;

  // Getters
  bool get inAppNotifications => _inAppNotifications;
  bool get messages => _messages;

  // Check if notifications are enabled
  bool get allNotificationsEnabled => _inAppNotifications && _messages;

  // Initialize notification settings from SharedPreferences
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _inAppNotifications = prefs.getBool('in_app_notifications') ?? true;
      _messages = prefs.getBool('messages') ?? true;

      notifyListeners();
    } catch (e) {
      print('Error initializing notification settings: $e');
    }
  }

  // Update in-app notifications setting
  Future<void> updateInAppNotifications(bool value) async {
    _inAppNotifications = value;
    await _saveToPreferences('in_app_notifications', value);
    notifyListeners();
  }

  // Update messages setting
  Future<void> updateMessages(bool value) async {
    _messages = value;
    await _saveToPreferences('messages', value);
    notifyListeners();
  }

  // Toggle all notifications
  Future<void> toggleAllNotifications(bool value) async {
    _inAppNotifications = value;
    _messages = value;

    // Save all settings
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('in_app_notifications', value);
    await prefs.setBool('messages', value);

    notifyListeners();
  }

  // Save setting to SharedPreferences
  Future<void> _saveToPreferences(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      print('Error saving notification setting $key: $e');
    }
  }

  // Reset to default settings
  Future<void> resetToDefaults() async {
    await toggleAllNotifications(true);
  }
}
