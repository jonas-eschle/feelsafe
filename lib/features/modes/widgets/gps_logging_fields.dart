import 'package:flutter/material.dart';

import 'package:guardianangela/core/widgets/timing_slider.dart';
import 'package:guardianangela/domain/enums/gps_accuracy.dart';
import 'package:guardianangela/domain/enums/gps_format.dart';
import 'package:guardianangela/domain/models/gps_logging_config.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Inline editor for every [GpsLoggingConfig] field except the master
/// `enabled` toggle (which the caller exposes as its tri-state selector).
///
/// Stateless and controller-free so it can render inside the mode editor's
/// in-memory draft as well as anywhere a plain config+callback is available.
/// Mirrors the field set of the standalone GPS-logging settings screen.
class GpsLoggingFields extends StatelessWidget {
  /// Creates a [GpsLoggingFields].
  const GpsLoggingFields({
    super.key,
    required this.config,
    required this.onChanged,
  });

  /// The config to edit.
  final GpsLoggingConfig config;

  /// Called with an updated config whenever a field changes.
  final ValueChanged<GpsLoggingConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 8),
        Text(l10n.gpsLoggingIntervalLabel),
        TimingSlider(
          valueSeconds: config.intervalSeconds,
          minSeconds: 10,
          maxSeconds: 3600,
          onChanged: (int v) => onChanged(config.copyWith(intervalSeconds: v)),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.gpsLoggingAccuracyLabel),
          trailing: DropdownButton<GpsAccuracy>(
            value: config.accuracy,
            onChanged: (GpsAccuracy? v) {
              if (v != null) onChanged(config.copyWith(accuracy: v));
            },
            items: <DropdownMenuItem<GpsAccuracy>>[
              DropdownMenuItem<GpsAccuracy>(
                value: GpsAccuracy.high,
                child: Text(l10n.gpsLoggingAccuracyHigh),
              ),
              DropdownMenuItem<GpsAccuracy>(
                value: GpsAccuracy.medium,
                child: Text(l10n.gpsLoggingAccuracyBalanced),
              ),
              DropdownMenuItem<GpsAccuracy>(
                value: GpsAccuracy.low,
                child: Text(l10n.gpsLoggingAccuracyLow),
              ),
            ],
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.gpsLoggingFormatLabel),
          trailing: DropdownButton<GpsFormat>(
            value: config.format,
            onChanged: (GpsFormat? v) {
              if (v != null) onChanged(config.copyWith(format: v));
            },
            items: <DropdownMenuItem<GpsFormat>>[
              DropdownMenuItem<GpsFormat>(
                value: GpsFormat.decimal,
                child: Text(l10n.gpsLoggingFormatDecimal),
              ),
              DropdownMenuItem<GpsFormat>(
                value: GpsFormat.dms,
                child: Text(l10n.gpsLoggingFormatDms),
              ),
              DropdownMenuItem<GpsFormat>(
                value: GpsFormat.openLocationCode,
                child: Text(l10n.gpsLoggingFormatAddress),
              ),
            ],
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.gpsLoggingIncludeInSms),
          value: config.includeInSms,
          onChanged: (bool v) => onChanged(config.copyWith(includeInSms: v)),
        ),
      ],
    );
  }
}
