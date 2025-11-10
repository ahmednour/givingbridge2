import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _messageNotifications = true;
  bool _donationUpdates = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.notificationSettings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.pushNotifications),
            subtitle: Text(AppLocalizations.of(context)!.pushNotificationsDesc),
            value: _pushNotifications,
            onChanged: (value) {
              setState(() {
                _pushNotifications = value;
              });
            },
          ),
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.emailNotifications),
            subtitle: Text(AppLocalizations.of(context)!.emailNotificationsDesc),
            value: _emailNotifications,
            onChanged: (value) {
              setState(() {
                _emailNotifications = value;
              });
            },
          ),
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.messageNotifications),
            subtitle: Text(AppLocalizations.of(context)!.messageNotificationsDesc),
            value: _messageNotifications,
            onChanged: (value) {
              setState(() {
                _messageNotifications = value;
              });
            },
          ),
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.donationUpdates),
            subtitle: Text(AppLocalizations.of(context)!.donationUpdatesDesc),
            value: _donationUpdates,
            onChanged: (value) {
              setState(() {
                _donationUpdates = value;
              });
            },
          ),
        ],
      ),
    );
  }
}