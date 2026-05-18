/// `LocationPoint` — a single GPS sample captured during a session.
library;

/// A timestamped GPS sample.
final class LocationPoint {
  /// Creates a location point.
  ///
  /// [latitude] — WGS84 latitude.
  /// [longitude] — WGS84 longitude.
  /// [timestamp] — when the fix was taken (UTC recommended).
  /// [accuracy] — horizontal accuracy in meters; optional.
  const LocationPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracy,
  });

  /// Deserializes a `LocationPoint` from JSON.
  factory LocationPoint.fromJson(Map<String, Object?> json) => LocationPoint(
    latitude: (json['latitude']! as num).toDouble(),
    longitude: (json['longitude']! as num).toDouble(),
    timestamp: DateTime.parse(json['timestamp']! as String),
    accuracy: (json['accuracy'] as num?)?.toDouble(),
  );

  /// WGS84 latitude.
  final double latitude;

  /// WGS84 longitude.
  final double longitude;

  /// When the fix was taken.
  final DateTime timestamp;

  /// Horizontal accuracy in meters. Defaults to null.
  final double? accuracy;

  /// Returns a Google Maps URL for this point.
  String toMapsUrl() => 'https://maps.google.com/?q=$latitude,$longitude';

  /// Returns a new point with the given fields replaced.
  LocationPoint copyWith({
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    double? accuracy,
  }) => LocationPoint(
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    timestamp: timestamp ?? this.timestamp,
    accuracy: accuracy ?? this.accuracy,
  );

  /// Serializes to JSON (timestamp in ISO 8601).
  Map<String, Object?> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'timestamp': timestamp.toIso8601String(),
    'accuracy': accuracy,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationPoint &&
          other.latitude == latitude &&
          other.longitude == longitude &&
          other.timestamp == timestamp &&
          other.accuracy == accuracy;

  @override
  int get hashCode => Object.hash(latitude, longitude, timestamp, accuracy);

  @override
  String toString() => 'LocationPoint($latitude,$longitude @ $timestamp)';
}
