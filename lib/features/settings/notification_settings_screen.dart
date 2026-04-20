/// Notifications configuration screen.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Notifications screen.
class NotificationSettingsScreen extends ConsumerWidget {
  /// Creates the notifications screen.
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(l.notificationSettingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l.notificationSettingsBody),
          const SizedBox(height: 24),
          SwitchListTile(
            title: Text(l.settingsAlarmDnd),
            value: settings?.alarmDndOverride ?? false,
            onChanged: (v) => ref
                .read(settingsControllerProvider.notifier)
                .setAlarmDndOverride(v),
          ),
        ],
      ),
    );
  }
}
