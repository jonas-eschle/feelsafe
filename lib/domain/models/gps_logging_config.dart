import 'package:guardianangela/domain/enums/gps_accuracy.dart';
import 'package:guardianangela/domain/enums/gps_format.dart';

/// Configures GPS logging during safety sessions.
///
/// The global config lives in [AppDefaults.gpsLogging]; modes can override
/// via [ModeOverrides.gpsLogging]. See spec 03 §GpsLoggingConfig and Q21.
final class GpsLoggingConfig {
  /// Creates a GPS logging config with the given values.
  ///
  /// Defaults: [enabled] = true, [intervalSeconds] = 30,
  /// [accuracy] = [GpsAccuracy.high], [format] = [GpsFormat.decimal],
  /// [includeInSms] = true, [historyRetentionDays] = 30.
  const GpsLoggingConfig({
    this.enabled = true,
    this.intervalSeconds = 30,
    this.accuracy = GpsAccuracy.high,
    this.format = GpsFormat.decimal,
    this.includeInSms = true,
    this.historyRetentionDays = 30,
  });

  /// Deserialises a [GpsLoggingConfig] from [json].
  factory GpsLoggingConfig.fromJson(Map<String, dynamic> json) =>
      GpsLoggingConfig(
        enabled: (json['enabled'] as bool?) ?? true,
        intervalSeconds: (json['intervalSeconds'] as num?)?.toInt() ?? 30,
        accuracy: GpsAccuracy.values.byName(
          (json['accuracy'] as String?) ?? GpsAccuracy.high.name,
        ),
        format: GpsFormat.values.byName(
          (json['format'] as String?) ?? GpsFormat.decimal.name,
        ),
        includeInSms: (json['includeInSms'] as bool?) ?? true,
        historyRetentionDays:
            (json['historyRetentionDays'] as num?)?.toInt() ?? 30,
      );

  /// Master toggle for GPS logging during sessions.
  final bool enabled;

  /// How often (in seconds) GPS coordinates are recorded.
  final int intervalSeconds;

  /// Desired GPS accuracy level.
  final GpsAccuracy accuracy;

  /// Coordinate format used in session logs and SMS messages.
  final GpsFormat format;

  /// Whether to append the current location to SMS steps.
  final bool includeInSms;

  /// How many days of GPS history to retain.
  final int historyRetentionDays;

  /// Returns a copy with the specified fields replaced.
  GpsLoggingConfig copyWith({
    bool? enabled,
    int? intervalSeconds,
    GpsAccuracy? accuracy,
    GpsFormat? format,
    bool? includeInSms,
    int? historyRetentionDays,
  }) => GpsLoggingConfig(
    enabled: enabled ?? this.enabled,
    intervalSeconds: intervalSeconds ?? this.intervalSeconds,
    accuracy: accuracy ?? this.accuracy,
    format: format ?? this.format,
    includeInSms: includeInSms ?? this.includeInSms,
    historyRetentionDays: historyRetentionDays ?? this.historyRetentionDays,
  );

  /// Serialises this config to a JSON map.
  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'intervalSeconds': intervalSeconds,
    'accuracy': accuracy.name,
    'format': format.name,
    'includeInSms': includeInSms,
    'historyRetentionDays': historyRetentionDays,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GpsLoggingConfig &&
          enabled == other.enabled &&
          intervalSeconds == other.intervalSeconds &&
          accuracy == other.accuracy &&
          format == other.format &&
          includeInSms == other.includeInSms &&
          historyRetentionDays == other.historyRetentionDays);

  @override
  int get hashCode => Object.hash(
    enabled,
    intervalSeconds,
    accuracy,
    format,
    includeInSms,
    historyRetentionDays,
  );
}
