/// A single GPS fix recorded during a safety session.
///
/// Used by [LocationServiceProtocol] history, last-known-location
/// accessors, and as the payload embedded in session-log events.
/// See spec 05 §LocationService and the architecture sketch
/// §LocationPoint.
final class LocationPoint {
  /// Creates a location point.
  const LocationPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracy,
  });

  /// Decimal-degree latitude (WGS-84).
  final double latitude;

  /// Decimal-degree longitude (WGS-84).
  final double longitude;

  /// UTC timestamp of the fix.
  final DateTime timestamp;

  /// Horizontal accuracy radius in metres, if reported by the OS.
  final double? accuracy;

  /// Returns a Google Maps URL for this location.
  ///
  /// Format: `https://maps.google.com/?q=lat,lng`.
  String toMapsUrl() => 'https://maps.google.com/?q=$latitude,$longitude';

  /// Serialises to a JSON map.
  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'timestamp': timestamp.toUtc().toIso8601String(),
    if (accuracy != null) 'accuracy': accuracy,
  };

  /// Deserialises from a JSON map.
  ///
  /// Throws [ArgumentError] if a required field is missing or malformed.
  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    final lat = (json['latitude'] as num?)?.toDouble() ??
        (throw ArgumentError('latitude required in LocationPoint JSON'));
    final lon = (json['longitude'] as num?)?.toDouble() ??
        (throw ArgumentError('longitude required in LocationPoint JSON'));
    final ts = json['timestamp'] as String? ??
        (throw ArgumentError('timestamp required in LocationPoint JSON'));
    return LocationPoint(
      latitude: lat,
      longitude: lon,
      timestamp: DateTime.parse(ts).toUtc(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocationPoint &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          timestamp == other.timestamp &&
          accuracy == other.accuracy);

  @override
  int get hashCode =>
      Object.hash(latitude, longitude, timestamp, accuracy);

  @override
  String toString() =>
      'LocationPoint(lat=$latitude, lon=$longitude, '
      'ts=$timestamp, accuracy=$accuracy)';
}
