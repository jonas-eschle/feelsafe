/// `TrackingPoint` — a single GPS sample captured by the
/// interval-based session tracker (DE-3).
///
/// Distinct from [LocationPoint] because tracking carries richer
/// metadata (altitude, speed) and lives in an ephemeral, in-memory
/// circular buffer for the session's lifetime — never persisted to
/// disk per pivot 1 (no session restore).
library;

/// A timestamped GPS sample with optional altitude and speed.
final class TrackingPoint {
  /// Creates a tracking point.
  ///
  /// [timestamp] — when the fix was taken (UTC recommended).
  /// [latitude] — WGS84 latitude.
  /// [longitude] — WGS84 longitude.
  /// [accuracy] — horizontal accuracy in meters; optional.
  /// [altitude] — altitude in meters; optional.
  /// [speed] — speed in m/s; optional.
  const TrackingPoint({
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
  });

  /// Deserializes a `TrackingPoint` from JSON.
  factory TrackingPoint.fromJson(Map<String, Object?> json) => TrackingPoint(
    timestamp: DateTime.parse(json['timestamp']! as String),
    latitude: (json['latitude']! as num).toDouble(),
    longitude: (json['longitude']! as num).toDouble(),
    accuracy: (json['accuracy'] as num?)?.toDouble(),
    altitude: (json['altitude'] as num?)?.toDouble(),
    speed: (json['speed'] as num?)?.toDouble(),
  );

  /// When the fix was taken.
  final DateTime timestamp;

  /// WGS84 latitude.
  final double latitude;

  /// WGS84 longitude.
  final double longitude;

  /// Horizontal accuracy in meters; null when unknown.
  final double? accuracy;

  /// Altitude in meters; null when unknown.
  final double? altitude;

  /// Speed in m/s; null when unknown.
  final double? speed;

  /// Returns a Google Maps URL for this point.
  String toMapsUrl() => 'https://maps.google.com/?q=$latitude,$longitude';

  /// Returns a new point with the given fields replaced.
  TrackingPoint copyWith({
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    double? accuracy,
    double? altitude,
    double? speed,
  }) => TrackingPoint(
    timestamp: timestamp ?? this.timestamp,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    accuracy: accuracy ?? this.accuracy,
    altitude: altitude ?? this.altitude,
    speed: speed ?? this.speed,
  );

  /// Serializes to JSON (timestamp in ISO 8601).
  ///
  /// *Why JSON at all if it is never persisted?* For symmetry with
  /// other domain models — round-trip equality is the only safety
  /// net for storage correctness — and so tracking points can be
  /// serialized into ad-hoc payloads (e.g., session-log exports per
  /// the spec's "session log integration" hook) without inventing a
  /// second encoder.
  Map<String, Object?> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
    'accuracy': accuracy,
    'altitude': altitude,
    'speed': speed,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackingPoint &&
          other.timestamp == timestamp &&
          other.latitude == latitude &&
          other.longitude == longitude &&
          other.accuracy == accuracy &&
          other.altitude == altitude &&
          other.speed == speed;

  @override
  int get hashCode =>
      Object.hash(timestamp, latitude, longitude, accuracy, altitude, speed);

  @override
  String toString() => 'TrackingPoint($latitude,$longitude @ $timestamp)';
}
