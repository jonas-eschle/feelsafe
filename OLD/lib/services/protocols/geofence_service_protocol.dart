/// `GeofenceServiceProtocol` — abstract contract for the arrival
/// geofence service used by `DisarmTrigger.gpsArrival`.
///
/// Pure Dart. The concrete implementation bridges to the platform
/// location/geofence APIs in Phase 4b.
library;

import 'package:guardianangela/domain/models/location_point.dart';

/// Abstract contract for the arrival-geofence service.
abstract class GeofenceServiceProtocol {
  /// Broadcast stream of arrival events (one [LocationPoint] per
  /// geofence entry).
  Stream<LocationPoint> get arrivals;

  /// Registers a circular geofence.
  ///
  /// [latitude], [longitude] — geofence center in WGS84.
  /// [radiusMeters] — radius in meters; arrival fires when the
  /// device enters the circle.
  Future<void> registerGeofence({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  });

  /// Removes the currently registered geofence (if any).
  Future<void> removeGeofence();
}
