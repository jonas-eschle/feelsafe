/// Real geofence-service implementation stub. Phase 9 fills bodies.
library;

import 'package:guardianangela/domain/models/location_point.dart';
import 'package:guardianangela/services/protocols/geofence_service_protocol.dart';

/// Real platform-backed implementation of [GeofenceServiceProtocol].
final class GeofenceService implements GeofenceServiceProtocol {
  /// Creates the real geofence service.
  GeofenceService();

  @override
  Stream<LocationPoint> get arrivals =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> registerGeofence({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) async => throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> removeGeofence() async =>
      throw UnimplementedError('TODO: Phase 9 real impl');
}
