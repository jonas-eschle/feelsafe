import 'package:guardianangela/domain/enums/gps_destination_source.dart';

/// Base class for all disarm triggers.
///
/// Disarm triggers run in parallel with the main chain and end the current
/// session when their condition is met. See spec 03 §DisarmTrigger. Each
/// subclass serialises to/from JSON via a `type` discriminator field.
///
/// All triggers require the standard disarm confirmation (PIN / biometric
/// per [AppSettings]) before taking effect.
sealed class DisarmTrigger {
  /// Constant constructor for subclasses.
  const DisarmTrigger();

  /// Serialises this trigger to a JSON map with a `type` discriminator.
  Map<String, dynamic> toJson();

  /// Deserialises a [DisarmTrigger] from [json].
  ///
  /// Dispatches on the `type` field:
  /// - `'gps_arrival'` → [GpsArrivalDisarmTrigger]
  /// - `'timer'`       → [TimerDisarmTrigger]
  factory DisarmTrigger.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'gps_arrival' => GpsArrivalDisarmTrigger.fromJson(json),
      'timer' => TimerDisarmTrigger.fromJson(json),
      _ => throw ArgumentError('Unknown DisarmTrigger type: $type'),
    };
  }
}

/// Session ends automatically when the user arrives within [radiusMeters]
/// of the destination coordinate.
///
/// Validation blocks saving with [destinationSource] = [GpsDestinationSource.fixed]
/// unless both [lat] and [lng] are non-null.
final class GpsArrivalDisarmTrigger extends DisarmTrigger {
  /// Creates a GPS-arrival disarm trigger.
  ///
  /// Defaults: [radiusMeters] = 200,
  /// [destinationSource] = [GpsDestinationSource.promptAtStart].
  const GpsArrivalDisarmTrigger({
    this.radiusMeters = 200,
    this.destinationSource = GpsDestinationSource.promptAtStart,
    this.lat,
    this.lng,
  });

  /// Deserialises from a JSON map produced by [toJson].
  factory GpsArrivalDisarmTrigger.fromJson(Map<String, dynamic> json) =>
      GpsArrivalDisarmTrigger(
        radiusMeters: (json['radiusMeters'] as num).toInt(),
        destinationSource: GpsDestinationSource.values.byName(
          json['destinationSource'] as String,
        ),
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
      );

  /// How close the user must be to the destination to trigger disarm.
  final int radiusMeters;

  /// Where the destination coordinate comes from.
  final GpsDestinationSource destinationSource;

  /// Latitude of the fixed destination. Required when
  /// [destinationSource] is [GpsDestinationSource.fixed].
  final double? lat;

  /// Longitude of the fixed destination. Required when
  /// [destinationSource] is [GpsDestinationSource.fixed].
  final double? lng;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'gps_arrival',
    'radiusMeters': radiusMeters,
    'destinationSource': destinationSource.name,
    if (lat != null) 'lat': lat,
    if (lng != null) 'lng': lng,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GpsArrivalDisarmTrigger &&
          radiusMeters == other.radiusMeters &&
          destinationSource == other.destinationSource &&
          lat == other.lat &&
          lng == other.lng);

  @override
  int get hashCode => Object.hash(radiusMeters, destinationSource, lat, lng);
}

/// Session ends automatically after [durationSeconds], regardless of
/// escalation progress.
final class TimerDisarmTrigger extends DisarmTrigger {
  /// Creates a timer-based disarm trigger.
  const TimerDisarmTrigger({required this.durationSeconds});

  /// Deserialises from a JSON map produced by [toJson].
  factory TimerDisarmTrigger.fromJson(Map<String, dynamic> json) =>
      TimerDisarmTrigger(
        durationSeconds: (json['durationSeconds'] as num).toInt(),
      );

  /// How many seconds after session start the trigger fires.
  final int durationSeconds;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'timer',
    'durationSeconds': durationSeconds,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimerDisarmTrigger && durationSeconds == other.durationSeconds);

  @override
  int get hashCode => durationSeconds.hashCode;
}
