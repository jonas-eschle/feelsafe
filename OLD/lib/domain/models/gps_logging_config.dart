/// `GpsLoggingConfig` and its two helper enums.
///
/// Configures how location is sampled and formatted during a
/// session. Global defaults live in `AppDefaults.gpsLogging`; a
/// mode may override via `ModeOverrides.gpsLogging`.
library;

/// GPS sampling accuracy presets.
enum GpsAccuracy {
  /// Low power, coarse accuracy.
  low,

  /// Balanced power vs. accuracy. The default.
  medium,

  /// Highest accuracy; more battery.
  high,
}

/// Textual format used when embedding location in messages.
enum GpsFormat {
  /// Degrees / minutes / seconds. Default.
  dms,

  /// Decimal degrees (e.g., `47.3769, 8.5417`).
  decimal,

  /// Google Open Location Code (plus code).
  openLocationCode,
}

/// Configuration for GPS logging during a session.
final class GpsLoggingConfig {
  /// Creates a GPS logging config.
  ///
  /// [enabled] — master toggle; defaults to true.
  /// [intervalSeconds] — sampling interval; defaults to 30.
  /// [accuracy] — sampling accuracy preset; defaults to high.
  /// [format] — textual format for messages; defaults to decimal.
  /// [includeInSms] — append location to SMS messages; defaults to
  /// true.
  /// [historyRetentionDays] — how long samples are kept; defaults
  /// to 30.
  const GpsLoggingConfig({
    this.enabled = true,
    this.intervalSeconds = 30,
    this.accuracy = GpsAccuracy.high,
    this.format = GpsFormat.decimal,
    this.includeInSms = true,
    this.historyRetentionDays = 30,
  });

  /// Deserializes a `GpsLoggingConfig` from JSON.
  factory GpsLoggingConfig.fromJson(Map<String, Object?> json) =>
      GpsLoggingConfig(
        enabled: json['enabled'] as bool? ?? true,
        intervalSeconds: (json['intervalSeconds'] as num?)?.toInt() ?? 30,
        accuracy: _accuracyFromJson(json['accuracy']),
        format: _formatFromJson(json['format']),
        includeInSms: json['includeInSms'] as bool? ?? true,
        historyRetentionDays:
            (json['historyRetentionDays'] as num?)?.toInt() ?? 30,
      );

  /// Master toggle for GPS logging. Defaults to true.
  final bool enabled;

  /// Sampling interval in seconds. Defaults to 30.
  final int intervalSeconds;

  /// Sampling accuracy preset. Defaults to `GpsAccuracy.high`.
  final GpsAccuracy accuracy;

  /// Textual format for embedded coordinates. Defaults to
  /// `GpsFormat.decimal`.
  final GpsFormat format;

  /// Whether to append coordinates to SMS messages. Defaults to true.
  final bool includeInSms;

  /// How many days of location samples are kept. Defaults to 30.
  final int historyRetentionDays;

  /// Returns a new config with the given fields replaced.
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

  /// Serializes to JSON.
  Map<String, Object?> toJson() => {
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
      other is GpsLoggingConfig &&
          other.enabled == enabled &&
          other.intervalSeconds == intervalSeconds &&
          other.accuracy == accuracy &&
          other.format == format &&
          other.includeInSms == includeInSms &&
          other.historyRetentionDays == historyRetentionDays;

  @override
  int get hashCode => Object.hash(
    enabled,
    intervalSeconds,
    accuracy,
    format,
    includeInSms,
    historyRetentionDays,
  );

  @override
  String toString() =>
      'GpsLoggingConfig(enabled: $enabled, '
      'intervalSeconds: $intervalSeconds, accuracy: $accuracy, '
      'format: $format, includeInSms: $includeInSms, '
      'historyRetentionDays: $historyRetentionDays)';
}

GpsAccuracy _accuracyFromJson(Object? raw) => switch (raw) {
  'low' => GpsAccuracy.low,
  'medium' => GpsAccuracy.medium,
  'high' => GpsAccuracy.high,
  null => GpsAccuracy.high,
  _ => throw ArgumentError.value(raw, 'accuracy', 'unknown GpsAccuracy'),
};

GpsFormat _formatFromJson(Object? raw) => switch (raw) {
  'dms' => GpsFormat.dms,
  'decimal' => GpsFormat.decimal,
  'openLocationCode' => GpsFormat.openLocationCode,
  null => GpsFormat.decimal,
  _ => throw ArgumentError.value(raw, 'format', 'unknown GpsFormat'),
};
