import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/protocols/notification_service_protocol.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Notification settings screen.
///
/// Combines the legacy permission re-ask block (top) with per-channel
/// toggles for the three user-facing channels (AlarmEscalation,
/// DisguisedReminder, FakeCall). Tapping a toggle opens the system
/// settings page for that channel; the displayed enabled / disabled
/// status reflects the OS-level state at screen open.
class NotificationsSettingsScreen extends ConsumerStatefulWidget {
  /// Creates a [NotificationsSettingsScreen].
  const NotificationsSettingsScreen({super.key});

  @override
  ConsumerState<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends ConsumerState<NotificationsSettingsScreen> {
  PermissionStatus? _status;
  final Map<NotificationChannelKey, bool> _channelEnabled =
      <NotificationChannelKey, bool>{};

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final s = await Permission.notification.status;
    final notifService = ref.read(notificationServiceProvider);
    final results = <NotificationChannelKey, bool>{};
    for (final c in NotificationChannelKey.values) {
      results[c] = await notifService.isChannelEnabled(c);
    }
    if (!mounted) return;
    setState(() {
      _status = s;
      _channelEnabled
        ..clear()
        ..addAll(results);
    });
  }

  Future<void> _request() async {
    final s = await Permission.notification.request();
    if (!mounted) return;
    setState(() => _status = s);
  }

  Future<void> _openChannel(NotificationChannelKey channel) async {
    final notifService = ref.read(notificationServiceProvider);
    await notifService.openChannelSettings(channel);
    await openAppSettings();
    await _refresh();
  }

  String _statusLabel(AppLocalizations l10n) {
    final s = _status;
    if (s == null) return l10n.notificationsStatusUnknown;
    if (s.isGranted) return l10n.notificationsStatusGranted;
    if (s.isPermanentlyDenied) return l10n.notificationsStatusDenied;
    return l10n.notificationsStatusUnknown;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.notifications_active),
              title: Text(l10n.homePermissionsNotification),
              subtitle: Text(_statusLabel(l10n)),
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
            const SizedBox(height: 24),
            Text(
              l10n.notificationsChannelsHeader,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final c in NotificationChannelKey.values)
              _ChannelTile(
                channel: c,
                enabled: _channelEnabled[c],
                onTap: () => _openChannel(c),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChannelTile extends StatelessWidget {
  const _ChannelTile({
    required this.channel,
    required this.enabled,
    required this.onTap,
  });

  final NotificationChannelKey channel;
  final bool? enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = switch (channel) {
      NotificationChannelKey.alarm => l10n.notificationsChannelAlarm,
      NotificationChannelKey.reminder => l10n.notificationsChannelReminder,
      NotificationChannelKey.fakeCall => l10n.notificationsChannelFakeCall,
    };
    final subtitle = switch (channel) {
      NotificationChannelKey.alarm => l10n.notificationsChannelAlarmDescription,
      NotificationChannelKey.reminder =>
        l10n.notificationsChannelReminderDescription,
      NotificationChannelKey.fakeCall =>
        l10n.notificationsChannelFakeCallDescription,
    };
    final scheme = Theme.of(context).colorScheme;
    final on = enabled ?? true;
    return Card(
      child: ListTile(
        leading: Icon(
          on ? Icons.notifications_active : Icons.notifications_off,
          color: on ? scheme.primary : scheme.outline,
        ),
        title: Text(title),
        subtitle: Text(
          '$subtitle\n${on ? l10n.notificationsChannelEnabled : l10n.notificationsChannelDisabled}',
        ),
        trailing: const Icon(Icons.open_in_new),
        isThreeLine: true,
        onTap: onTap,
      ),
    );
  }
}
