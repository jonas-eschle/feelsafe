/// Session-history retention-policy screen.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/domain/models/app_defaults.dart';
import 'package:guardianangela/domain/models/gps_logging_config.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// History retention screen.
class HistoryRetentionScreen extends ConsumerWidget {
  /// Creates the history-retention screen.
  const HistoryRetentionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider).value;
    final gps = settings?.defaults.gpsLogging ?? const GpsLoggingConfig();
    return Scaffold(
      appBar: AppBar(title: Text(l.historyRetentionTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l.historyRetentionBody),
          const SizedBox(height: 16),
          Text(l.historyRetentionDays(gps.historyRetentionDays)),
          Slider(
            min: 1,
            max: 365,
            value: gps.historyRetentionDays.toDouble(),
            onChanged: (v) {
              final defaults = (settings?.defaults ?? const AppDefaults())
                  .copyWith(
                    gpsLogging: gps.copyWith(historyRetentionDays: v.round()),
                  );
              ref
                  .read(settingsControllerProvider.notifier)
                  .setDefaults(defaults);
            },
          ),
        ],
      ),
    );
  }
}
