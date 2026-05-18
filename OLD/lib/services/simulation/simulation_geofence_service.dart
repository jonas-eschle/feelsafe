/// Simulation implementation of [GeofenceServiceProtocol]. All
/// methods log via `dart:developer` and return a no-op.
library;

import 'dart:async';
import 'dart:developer' as developer;

import 'package:guardianangela/domain/models/location_point.dart';
import 'package:guardianangela/services/protocols/geofence_service_protocol.dart';

/// Simulation double for [GeofenceServiceProtocol].
final class SimulationGeofenceService implements GeofenceServiceProtocol {
  /// Creates the simulation geofence service.
  SimulationGeofenceService();

  final StreamController<LocationPoint> _arrivalsController =
      StreamController<LocationPoint>.broadcast();

  @override
  Stream<LocationPoint> get arrivals => _arrivalsController.stream;

  @override
  Future<void> registerGeofence({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) async {
    developer.log(
      '[SIM] geofence.registerGeofence $latitude,$longitude '
      '/$radiusMeters',
    );
  }

  @override
  Future<void> removeGeofence() async {
    developer.log('[SIM] geofence.removeGeofence');
  }

  /// Closes the arrivals stream controller.
  void dispose() {
    _arrivalsController.close();
  }
}
