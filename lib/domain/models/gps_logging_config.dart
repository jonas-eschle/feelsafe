import 'package:guardianangela/domain/enums/gps_accuracy.dart';

/// Configures GPS logging during safety sessions.
///
/// The global config lives in [AppDefaults.gpsLogging]; modes can override
/// via [ModeOverrides.gpsLogging]. See spec 03 §GpsLoggingConfig and Q21.
///
/// Deliberately minimal (M6-P5 trim, decisions-log D-DATA-22): location-in-
/// SMS is configured per-step via `SmsContactConfig.includeLocation`; the
/// `{location}` placeholder is always a Google Maps URL (spec 02), so no
/// coordinate-format option can apply; and GPS history is in-memory only
/// (cleared when the session ends), so there is nothing for a retention
/// policy to govern.
final class GpsLoggingConfig {
  /// Creates a GPS logging config with the given values.
  ///
  /// Defaults: [enabled] = true, [intervalSeconds] = 30,
  /// [accuracy] = [GpsAccuracy.high].
  const GpsLoggingConfig({
    this.enabled = true,
    this.intervalSeconds = 30,
    this.accuracy = GpsAccuracy.high,
  });

  /// Deserialises a [GpsLoggingConfig] from [json].
  ///
  /// Lenient: unknown keys — including the legacy `format`,
  /// `includeInSms`, and `historyRetentionDays` keys carried by
  /// old-shape backups — are ignored.
  factory GpsLoggingConfig.fromJson(Map<String, dynamic> json) =>
      GpsLoggingConfig(
        enabled: (json['enabled'] as bool?) ?? true,
        intervalSeconds: (json['intervalSeconds'] as num?)?.toInt() ?? 30,
        accuracy: GpsAccuracy.values.byName(
          (json['accuracy'] as String?) ?? GpsAccuracy.high.name,
        ),
      );

  /// The defaults with [enabled] switched to `false` — the explicit
  /// "logging off" override value (spec 03 §GpsLoggingConfig, Q21).
  static const GpsLoggingConfig off = GpsLoggingConfig(enabled: false);

  /// Master toggle for GPS logging during sessions.
  final bool enabled;

  /// How often (in seconds) GPS coordinates are recorded.
  final int intervalSeconds;

  /// Desired GPS accuracy level.
  final GpsAccuracy accuracy;

  /// Returns a copy with the specified fields replaced.
  GpsLoggingConfig copyWith({
    bool? enabled,
    int? intervalSeconds,
    GpsAccuracy? accuracy,
  }) => GpsLoggingConfig(
    enabled: enabled ?? this.enabled,
    intervalSeconds: intervalSeconds ?? this.intervalSeconds,
    accuracy: accuracy ?? this.accuracy,
  );

  /// Serialises this config to a JSON map.
  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'intervalSeconds': intervalSeconds,
    'accuracy': accuracy.name,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GpsLoggingConfig &&
          enabled == other.enabled &&
          intervalSeconds == other.intervalSeconds &&
          accuracy == other.accuracy);

  @override
  int get hashCode => Object.hash(enabled, intervalSeconds, accuracy);
}
