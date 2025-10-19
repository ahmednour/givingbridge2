import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider extends ChangeNotifier {
  // Default notification settings
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _donationRequests = true;
  bool _donationApprovals = true;
  bool _messages = true;
  bool _systemUpdates = true;

  // Getters
  bool get pushNotifications => _pushNotifications;
  bool get emailNotifications => _emailNotifications;
  bool get donationRequests => _donationRequests;
  bool get donationApprovals => _donationApprovals;
  bool get messages => _messages;
  bool get systemUpdates => _systemUpdates;

  // Check if all notifications are enabled
  bool get allNotificationsEnabled =>
      _pushNotifications &&
      _emailNotifications &&
      _donationRequests &&
      _donationApprovals &&
      _messages &&
      _systemUpdates;

  // Initialize notification settings from SharedPreferences
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _emailNotifications = prefs.getBool('email_notifications') ?? true;
      _donationRequests = prefs.getBool('donation_requests') ?? true;
      _donationApprovals = prefs.getBool('donation_approvals') ?? true;
      _messages = prefs.getBool('messages') ?? true;
      _systemUpdates = prefs.getBool('system_updates') ?? true;

      notifyListeners();
    } catch (e) {
      print('Error initializing notification settings: $e');
    }
  }

  // Update push notifications setting
  Future<void> updatePushNotifications(bool value) async {
    _pushNotifications = value;
    await _saveToPreferences('push_notifications', value);
    notifyListeners();
  }

  // Update email notifications setting
  Future<void> updateEmailNotifications(bool value) async {
    _emailNotifications = value;
    await _saveToPreferences('email_notifications', value);
    notifyListeners();
  }

  // Update donation requests setting
  Future<void> updateDonationRequests(bool value) async {
    _donationRequests = value;
    await _saveToPreferences('donation_requests', value);
    notifyListeners();
  }

  // Update donation approvals setting
  Future<void> updateDonationApprovals(bool value) async {
    _donationApprovals = value;
    await _saveToPreferences('donation_approvals', value);
    notifyListeners();
  }

  // Update messages setting
  Future<void> updateMessages(bool value) async {
    _messages = value;
    await _saveToPreferences('messages', value);
    notifyListeners();
  }

  // Update system updates setting
  Future<void> updateSystemUpdates(bool value) async {
    _systemUpdates = value;
    await _saveToPreferences('system_updates', value);
    notifyListeners();
  }

  // Toggle all notifications
  Future<void> toggleAllNotifications(bool value) async {
    _pushNotifications = value;
    _emailNotifications = value;
    _donationRequests = value;
    _donationApprovals = value;
    _messages = value;
    _systemUpdates = value;

    // Save all settings
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_notifications', value);
    await prefs.setBool('email_notifications', value);
    await prefs.setBool('donation_requests', value);
    await prefs.setBool('donation_approvals', value);
    await prefs.setBool('messages', value);
    await prefs.setBool('system_updates', value);

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
