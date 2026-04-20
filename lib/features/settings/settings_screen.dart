/// Top-level settings hub.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Settings hub.
class SettingsScreen extends ConsumerWidget {
  /// Creates the settings screen.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        children: [
          _NavTile(label: l.settingsSectionProfile, route: RouteNames.profile),
          _NavTile(label: l.settingsSectionContacts, route: RouteNames.contacts),
          _NavTile(label: l.settingsSectionModes, route: RouteNames.modes),
          _NavTile(
              label: l.settingsSectionDistressChains,
              route: RouteNames.distressChains),
          const Divider(),
          _NavTile(
              label: l.settingsSectionSecurity,
              route: RouteNames.settingsSecurity),
          _NavTile(
              label: l.settingsSectionStealth,
              route: RouteNames.settingsStealth),
          const Divider(),
          ListTile(
            title: Text(l.settingsSectionDefaults),
            subtitle: Text(l.commonNone),
            enabled: false,
          ),
          _NavTile(
              label: l.settingsSectionEventDefaults,
              route: RouteNames.eventDefaults),
          _NavTile(
              label: l.settingsSectionGpsLogging,
              route: RouteNames.gpsLogging),
          _NavTile(
              label: l.settingsSectionReminderTemplates,
              route: RouteNames.reminderTemplates),
          _NavTile(
              label: l.settingsSectionBatteryAlert,
              route: RouteNames.batteryAlert),
          _NavTile(
              label: l.settingsSectionNotifications,
              route: RouteNames.notificationSettings),
          _NavTile(
              label: l.settingsSectionHistoryRetention,
              route: RouteNames.historyRetention),
          const Divider(),
          _NavTile(label: l.settingsSectionBackup, route: RouteNames.backup),
          _NavTile(label: l.settingsSectionAbout, route: RouteNames.about),
          _NavTile(label: l.settingsSectionFeedback, route: RouteNames.feedback),
          const Divider(),
          _ThemeDropdown(current: settings?.themeMode ?? AppThemeMode.system),
          ListTile(
            title: Text(l.settingsAlarmDnd),
            trailing: Switch(
              value: settings?.alarmDndOverride ?? false,
              onChanged: (v) => ref
                  .read(settingsControllerProvider.notifier)
                  .setAlarmDndOverride(v),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.label, required this.route});

  final String label;
  final String route;

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(route),
      );
}

class _ThemeDropdown extends ConsumerWidget {
  const _ThemeDropdown({required this.current});

  final AppThemeMode current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return ListTile(
      title: Text(l.settingsThemeMode),
      trailing: DropdownButton<AppThemeMode>(
        value: current,
        items: [
          DropdownMenuItem(
              value: AppThemeMode.system, child: Text(l.settingsThemeSystem)),
          DropdownMenuItem(
              value: AppThemeMode.light, child: Text(l.settingsThemeLight)),
          DropdownMenuItem(
              value: AppThemeMode.dark, child: Text(l.settingsThemeDark)),
        ],
        onChanged: (v) {
          if (v != null) {
            ref
                .read(settingsControllerProvider.notifier)
                .setThemeMode(v);
          }
        },
      ),
    );
  }
}
