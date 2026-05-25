import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Notification permission re-ask screen.
///
/// Shows current notification permission status and lets the user
/// request the prompt again or deep-link to system settings. See spec
/// 04 §Notifications.
class NotificationsSettingsScreen extends StatefulWidget {
  /// Creates a [NotificationsSettingsScreen].
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  PermissionStatus? _status;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final s = await Permission.notification.status;
    if (mounted) setState(() => _status = s);
  }

  Future<void> _request() async {
    final s = await Permission.notification.request();
    if (mounted) setState(() => _status = s);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = _status;
    final label = status == null
        ? l10n.notificationsStatusUnknown
        : status.isGranted
        ? l10n.notificationsStatusGranted
        : status.isPermanentlyDenied
        ? l10n.notificationsStatusDenied
        : l10n.notificationsStatusUnknown;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.notifications_active),
              title: Text(l10n.homePermissionsNotification),
              subtitle: Text(label),
            ),
            FilledButton(
              onPressed: _request,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(l10n.notificationsRequest),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: openAppSettings,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(l10n.notificationsOpenSettings),
            ),
          ],
        ),
      ),
    );
  }
}
