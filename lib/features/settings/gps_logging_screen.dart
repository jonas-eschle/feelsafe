/// GPS logging configuration.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/domain/models/app_defaults.dart';
import 'package:guardianangela/domain/models/gps_logging_config.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// GPS logging screen.
class GpsLoggingScreen extends ConsumerWidget {
  /// Creates the GPS-logging screen.
  const GpsLoggingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider).value;
    final gps = settings?.defaults.gpsLogging ?? const GpsLoggingConfig();

    Future<void> save(GpsLoggingConfig next) async {
      final defaults =
          (settings?.defaults ?? const AppDefaults()).copyWith(gpsLogging: next);
      await ref
          .read(settingsControllerProvider.notifier)
          .setDefaults(defaults);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.gpsLoggingTitle)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(l.gpsLoggingEnable),
            value: gps.enabled,
            onChanged: (v) => save(gps.copyWith(enabled: v)),
          ),
          ListTile(
            title: Text(l.gpsLoggingInterval),
            subtitle: Text('${gps.intervalSeconds}s'),
          ),
          Slider(
            min: 10,
            max: 600,
            divisions: 59,
            value: gps.intervalSeconds.toDouble(),
            label: '${gps.intervalSeconds}s',
            onChanged: (v) =>
                save(gps.copyWith(intervalSeconds: v.round())),
          ),
          ListTile(
            title: Text(l.gpsLoggingAccuracy),
            trailing: DropdownButton<GpsAccuracy>(
              value: gps.accuracy,
              items: [
                DropdownMenuItem(
                  value: GpsAccuracy.low,
                  child: Text(l.gpsAccuracyLow),
                ),
                DropdownMenuItem(
                  value: GpsAccuracy.medium,
                  child: Text(l.gpsAccuracyMedium),
                ),
                DropdownMenuItem(
                  value: GpsAccuracy.high,
                  child: Text(l.gpsAccuracyHigh),
                ),
              ],
              onChanged: (v) {
                if (v != null) save(gps.copyWith(accuracy: v));
              },
            ),
          ),
          SwitchListTile(
            title: Text(l.gpsLoggingIncludeSms),
            value: gps.includeInSms,
            onChanged: (v) => save(gps.copyWith(includeInSms: v)),
          ),
          ListTile(
            title: Text(l.gpsLoggingHistoryDays),
            subtitle: Text('${gps.historyRetentionDays}'),
          ),
          Slider(
            min: 1,
            max: 365,
            value: gps.historyRetentionDays.toDouble(),
            onChanged: (v) =>
                save(gps.copyWith(historyRetentionDays: v.round())),
          ),
        ],
      ),
    );
  }
}
