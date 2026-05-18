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
  Future<void> startTracking({Duration interval = const Duration(seconds: 60)});

  /// Stops periodic location tracking.
  Future<void> stopTracking();

  /// Returns a shareable Google Maps URL for the most recent fix, or
  /// null if no fix has been recorded yet.
  String? getLastLocationUrl();

  /// Returns the most recent [LocationPoint], or null if no fix has
  /// been recorded yet.
  LocationPoint? getLastLocationPoint();

  /// Requests a single, fresh GPS fix. Returns null when permission is
  /// denied or the platform fails to acquire a fix within its internal
  /// timeout.
  ///
  /// Used by the spec 11 §DE-3 interval-based tracker, which calls
  /// this on every Timer tick rather than relying on a continuous
  /// position stream — a periodic single-shot pattern keeps the
  /// platform's location stack idle between samples and avoids the
  /// `distanceFilter` drop-outs that the streaming API exhibits when
  /// the user is stationary.
  Future<LocationPoint?> getCurrentPosition();

  /// All [LocationPoint]s captured in the current session, ordered
  /// oldest-first.
  List<LocationPoint> get history;

  /// Clears the in-memory [history].
  void clearHistory();
}
