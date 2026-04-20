/// `LocationServiceProtocol` — abstract contract for GPS tracking,
/// permission handling, and location history used during a session.
///
/// Pure Dart. The concrete implementation bridges to `geolocator` in
/// Phase 9; the simulation implementation never touches real GPS.
library;

import 'package:guardianangela/domain/models/location_point.dart';

/// Abstract contract for the location-tracking service.
abstract class LocationServiceProtocol {
  /// Requests foreground location permission from the user.
  ///
  /// Returns true iff the permission is granted after the request.
  Future<bool> requestPermission();

  /// Starts periodic location tracking.
  ///
  /// [interval] — sampling interval; defaults to 60 seconds.
  Future<void> startTracking({
    Duration interval = const Duration(seconds: 60),
  });

  /// Stops periodic location tracking.
  Future<void> stopTracking();

  /// Returns a shareable Google Maps URL for the most recent fix, or
  /// null if no fix has been recorded yet.
  String? getLastLocationUrl();

  /// Returns the most recent [LocationPoint], or null if no fix has
  /// been recorded yet.
  LocationPoint? getLastLocationPoint();

  /// All [LocationPoint]s captured in the current session, ordered
  /// oldest-first.
  List<LocationPoint> get history;

  /// Clears the in-memory [history].
  void clearHistory();
}
