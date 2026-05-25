import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/core/widgets/timing_slider.dart';
import 'package:guardianangela/domain/enums/gps_accuracy.dart';
import 'package:guardianangela/domain/enums/gps_format.dart';
import 'package:guardianangela/features/gps_logging/gps_logging_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// GPS logging settings screen.
///
/// Exposes every `GpsLoggingConfig` field. See spec 06 §GPS Logging.
class GpsLoggingScreen extends ConsumerWidget {
  /// Creates a [GpsLoggingScreen].
  const GpsLoggingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stateAsync = ref.watch(gpsLoggingControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsGpsLoggingRow)),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(child: Text('Error: $e')),
        data: (state) {
          final cfg = state.config;
          final notifier = ref.read(gpsLoggingControllerProvider.notifier);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              SwitchListTile(
                title: Text(l10n.gpsLoggingEnabled),
                value: cfg.enabled,
                onChanged: notifier.setEnabled,
              ),
              const SizedBox(height: 8),
              Text(l10n.gpsLoggingIntervalLabel),
              TimingSlider(
                valueSeconds: cfg.intervalSeconds,
                minSeconds: 10,
                maxSeconds: 3600,
                onChanged: notifier.setInterval,
              ),
              ListTile(
                title: Text(l10n.gpsLoggingAccuracyLabel),
                trailing: DropdownButton<GpsAccuracy>(
                  value: cfg.accuracy,
                  onChanged: (GpsAccuracy? v) {
                    if (v != null) notifier.setAccuracy(v);
                  },
                  items: <DropdownMenuItem<GpsAccuracy>>[
                    DropdownMenuItem(
                      value: GpsAccuracy.high,
                      child: Text(l10n.gpsLoggingAccuracyHigh),
                    ),
                    DropdownMenuItem(
                      value: GpsAccuracy.medium,
                      child: Text(l10n.gpsLoggingAccuracyBalanced),
                    ),
                    DropdownMenuItem(
                      value: GpsAccuracy.low,
                      child: Text(l10n.gpsLoggingAccuracyLow),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text(l10n.gpsLoggingFormatLabel),
                trailing: DropdownButton<GpsFormat>(
                  value: cfg.format,
                  onChanged: (GpsFormat? v) {
                    if (v != null) notifier.setFormat(v);
                  },
                  items: <DropdownMenuItem<GpsFormat>>[
                    DropdownMenuItem(
                      value: GpsFormat.decimal,
                      child: Text(l10n.gpsLoggingFormatDecimal),
                    ),
                    DropdownMenuItem(
                      value: GpsFormat.dms,
                      child: Text(l10n.gpsLoggingFormatDms),
                    ),
                    DropdownMenuItem(
                      value: GpsFormat.openLocationCode,
                      child: Text(l10n.gpsLoggingFormatAddress),
                    ),
                  ],
                ),
              ),
              SwitchListTile(
                title: Text(l10n.gpsLoggingIncludeInSms),
                value: cfg.includeInSms,
                onChanged: notifier.setIncludeInSms,
              ),
            ],
          );
        },
      ),
    );
  }
}
