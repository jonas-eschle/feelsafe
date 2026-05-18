/// Deterministic fake implementation of [GeofenceServiceProtocol]
/// for tests. Every call is recorded to [calls]; arrivals are
/// broadcast via a controller.
library;

import 'dart:async';

import 'package:guardianangela/domain/models/location_point.dart';
import 'package:guardianangela/services/protocols/geofence_service_protocol.dart';

/// Test double for [GeofenceServiceProtocol].
final class FakeGeofenceService implements GeofenceServiceProtocol {
  /// Creates a fake geofence service.
  FakeGeofenceService();

  /// Invocation log: one entry per method call.
  final List<String> calls = [];

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
    calls.add('registerGeofence:$latitude,$longitude/$radiusMeters');
  }

  @override
  Future<void> removeGeofence() async {
    calls.add('removeGeofence');
  }

  /// Test helper: synthesize an arrival on the stream.
  void injectArrival(LocationPoint point) {
    _arrivalsController.add(point);
  }

  /// Closes the arrivals stream controller.
  void dispose() {
    _arrivalsController.close();
  }
}
