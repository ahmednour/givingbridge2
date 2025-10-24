import 'package:flutter/material.dart';
import '../models/notification_preference.dart';
import '../services/api_service.dart';
import '../core/theme/design_system.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  NotificationPreference? _preferences;
  bool _isLoading = true;
  bool _isSaving = false;

  // Temporary state for toggle changes
  late Map<String, bool> _currentSettings;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.getNotificationPreferences();

      if (response.success && response.data != null) {
        setState(() {
          _preferences = response.data;
          _initializeCurrentSettings();
          _isLoading = false;
        });
      } else {
        if (mounted) {
          _showErrorSnackbar(response.error ?? 'Failed to load preferences');
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Error loading preferences: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  void _initializeCurrentSettings() {
    if (_preferences == null) return;

    _currentSettings = {
      // Email
      'emailEnabled': _preferences!.emailEnabled,
      'emailNewMessage': _preferences!.emailNewMessage,
      'emailDonationRequest': _preferences!.emailDonationRequest,
      'emailRequestUpdate': _preferences!.emailRequestUpdate,
      'emailDonationUpdate': _preferences!.emailDonationUpdate,
      // Push
      'pushEnabled': _preferences!.pushEnabled,
      'pushNewMessage': _preferences!.pushNewMessage,
      'pushDonationRequest': _preferences!.pushDonationRequest,
      'pushRequestUpdate': _preferences!.pushRequestUpdate,
      'pushDonationUpdate': _preferences!.pushDonationUpdate,
      // In-App
      'inAppEnabled': _preferences!.inAppEnabled,
      'inAppNewMessage': _preferences!.inAppNewMessage,
      'inAppDonationRequest': _preferences!.inAppDonationRequest,
      'inAppRequestUpdate': _preferences!.inAppRequestUpdate,
      'inAppDonationUpdate': _preferences!.inAppDonationUpdate,
      // Additional
      'soundEnabled': _preferences!.soundEnabled,
      'vibrationEnabled': _preferences!.vibrationEnabled,
    };
  }

  Future<void> _updatePreference(String key, bool value) async {
    setState(() {
      _currentSettings[key] = value;
      _isSaving = true;
    });

    try {
      final response =
          await ApiService.updateNotificationPreferences({key: value});

      if (response.success && response.data != null) {
        setState(() {
          _preferences = response.data;
          _isSaving = false;
        });
      } else {
        // Revert on error
        setState(() {
          _currentSettings[key] = !value;
          _isSaving = false;
        });
        if (mounted) {
          _showErrorSnackbar(response.error ?? 'Failed to update preference');
        }
      }
    } catch (e) {
      // Revert on error
      setState(() {
        _currentSettings[key] = !value;
        _isSaving = false;
      });
      if (mounted) {
        _showErrorSnackbar('Error updating preference: $e');
      }
    }
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await _showResetConfirmation();
    if (!confirmed) return;

    setState(() => _isSaving = true);

    try {
      final response = await ApiService.resetNotificationPreferences();

      if (response.success && response.data != null) {
        setState(() {
          _preferences = response.data;
          _initializeCurrentSettings();
          _isSaving = false;
        });
        if (mounted) {
          _showSuccessSnackbar('Notification preferences reset to defaults');
        }
      } else {
        setState(() => _isSaving = false);
        if (mounted) {
          _showErrorSnackbar(response.error ?? 'Failed to reset preferences');
        }
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        _showErrorSnackbar('Error resetting preferences: $e');
      }
    }
  }

  Future<bool> _showResetConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Reset to Defaults'),
            content: const Text(
              'Are you sure you want to reset all notification preferences to their default values? This will enable all notifications.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignSystem.primaryBlue,
                ),
                child: const Text('Reset'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: DesignSystem.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: DesignSystem.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notification Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: DesignSystem.backgroundLight,
        elevation: 0,
        actions: [
          if (!_isLoading)
            TextButton.icon(
              onPressed: _isSaving ? null : _resetToDefaults,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Reset'),
              style: TextButton.styleFrom(
                foregroundColor: DesignSystem.primaryBlue,
              ),
            ),
        ],
      ),
      backgroundColor: DesignSystem.backgroundLight,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildSettingsList(),
    );
  }

  Widget _buildSettingsList() {
    if (_preferences == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 64, color: DesignSystem.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Failed to load notification preferences',
              style: TextStyle(
                fontSize: 16,
                color: DesignSystem.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPreferences,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.primaryBlue,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Email Notifications Section
        _buildSectionHeader('Email Notifications', Icons.email_outlined),
        const SizedBox(height: 8),
        _buildSettingsCard([
          _buildToggleTile(
            'Email Notifications',
            'Receive notifications via email',
            'emailEnabled',
            _currentSettings['emailEnabled']!,
            isMaster: true,
          ),
          if (_currentSettings['emailEnabled']!) ...[
            const Divider(height: 1),
            _buildToggleTile(
              'New Messages',
              'Get notified about new messages',
              'emailNewMessage',
              _currentSettings['emailNewMessage']!,
            ),
            const Divider(height: 1),
            _buildToggleTile(
              'Donation Requests',
              'When someone requests your donation',
              'emailDonationRequest',
              _currentSettings['emailDonationRequest']!,
            ),
            const Divider(height: 1),
            _buildToggleTile(
              'Request Updates',
              'Updates on your donation requests',
              'emailRequestUpdate',
              _currentSettings['emailRequestUpdate']!,
            ),
            const Divider(height: 1),
            _buildToggleTile(
              'Donation Updates',
              'Updates on donations you\'ve made',
              'emailDonationUpdate',
              _currentSettings['emailDonationUpdate']!,
            ),
          ],
        ]),

        const SizedBox(height: 24),

        // Push Notifications Section
        _buildSectionHeader('Push Notifications', Icons.notifications_outlined),
        const SizedBox(height: 8),
        _buildSettingsCard([
          _buildToggleTile(
            'Push Notifications',
            'Receive push notifications on your device',
            'pushEnabled',
            _currentSettings['pushEnabled']!,
            isMaster: true,
          ),
          if (_currentSettings['pushEnabled']!) ...[
            const Divider(height: 1),
            _buildToggleTile(
              'New Messages',
              'Get notified about new messages',
              'pushNewMessage',
              _currentSettings['pushNewMessage']!,
            ),
            const Divider(height: 1),
            _buildToggleTile(
              'Donation Requests',
              'When someone requests your donation',
              'pushDonationRequest',
              _currentSettings['pushDonationRequest']!,
            ),
            const Divider(height: 1),
            _buildToggleTile(
              'Request Updates',
              'Updates on your donation requests',
              'pushRequestUpdate',
              _currentSettings['pushRequestUpdate']!,
            ),
            const Divider(height: 1),
            _buildToggleTile(
              'Donation Updates',
              'Updates on donations you\'ve made',
              'pushDonationUpdate',
              _currentSettings['pushDonationUpdate']!,
            ),
          ],
        ]),

        const SizedBox(height: 24),

        // In-App Notifications Section
        _buildSectionHeader(
            'In-App Notifications', Icons.notifications_active_outlined),
        const SizedBox(height: 8),
        _buildSettingsCard([
          _buildToggleTile(
            'In-App Notifications',
            'Show notifications while using the app',
            'inAppEnabled',
            _currentSettings['inAppEnabled']!,
            isMaster: true,
          ),
          if (_currentSettings['inAppEnabled']!) ...[
            const Divider(height: 1),
            _buildToggleTile(
              'New Messages',
              'Get notified about new messages',
              'inAppNewMessage',
              _currentSettings['inAppNewMessage']!,
            ),
            const Divider(height: 1),
            _buildToggleTile(
              'Donation Requests',
              'When someone requests your donation',
              'inAppDonationRequest',
              _currentSettings['inAppDonationRequest']!,
            ),
            const Divider(height: 1),
            _buildToggleTile(
              'Request Updates',
              'Updates on your donation requests',
              'inAppRequestUpdate',
              _currentSettings['inAppRequestUpdate']!,
            ),
            const Divider(height: 1),
            _buildToggleTile(
              'Donation Updates',
              'Updates on donations you\'ve made',
              'inAppDonationUpdate',
              _currentSettings['inAppDonationUpdate']!,
            ),
          ],
        ]),

        const SizedBox(height: 24),

        // Additional Settings Section
        _buildSectionHeader('Additional Settings', Icons.settings_outlined),
        const SizedBox(height: 8),
        _buildSettingsCard([
          _buildToggleTile(
            'Sound',
            'Play sound for notifications',
            'soundEnabled',
            _currentSettings['soundEnabled']!,
          ),
          const Divider(height: 1),
          _buildToggleTile(
            'Vibration',
            'Vibrate for notifications',
            'vibrationEnabled',
            _currentSettings['vibrationEnabled']!,
          ),
        ]),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: DesignSystem.primaryBlue),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: DesignSystem.primaryBlue,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildToggleTile(
    String title,
    String subtitle,
    String key,
    bool value, {
    bool isMaster = false,
  }) {
    return SwitchListTile(
      value: value,
      onChanged:
          _isSaving ? null : (newValue) => _updatePreference(key, newValue),
      title: Text(
        title,
        style: TextStyle(
          fontSize: isMaster ? 16 : 15,
          fontWeight: isMaster ? FontWeight.w600 : FontWeight.w500,
          color: DesignSystem.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: DesignSystem.textSecondary,
        ),
      ),
      activeThumbColor: DesignSystem.primaryBlue,
      contentPadding: EdgeInsets.symmetric(
        horizontal: isMaster ? 16 : 24,
        vertical: 4,
      ),
    );
  }
}
