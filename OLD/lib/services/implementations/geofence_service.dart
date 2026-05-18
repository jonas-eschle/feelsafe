/// Real geofence-service implementation.
///
/// Pure-Dart polling geofence built on `geolocator`. On registration,
/// subscribes to the position stream and emits an arrival event the
/// first time the device enters the configured circular region. Only
/// one geofence is active at a time (distress chain replaces the main
/// chain; same applies here).
library;

import 'dart:async';
import 'dart:developer' as developer;

import 'package:geolocator/geolocator.dart';

import 'package:guardianangela/domain/models/location_point.dart';
import 'package:guardianangela/services/protocols/geofence_service_protocol.dart';

/// Real platform-backed implementation of [GeofenceServiceProtocol].
final class GeofenceService implements GeofenceServiceProtocol {
  /// Creates the real geofence service.
  GeofenceService();

  final StreamController<LocationPoint> _controller =
      StreamController<LocationPoint>.broadcast();

  StreamSubscription<Position>? _subscription;
  double? _centerLat;
  double? _centerLng;
  double? _radiusMeters;
  bool _insideRegion = false;

  @override
  Stream<LocationPoint> get arrivals => _controller.stream;

  @override
  Future<void> registerGeofence({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) async {
    await removeGeofence();
    _centerLat = latitude;
    _centerLng = longitude;
    _radiusMeters = radiusMeters;
    _insideRegion = false;

    const settings = LocationSettings(
      accuracy: LocationAccuracy.medium,
      distanceFilter: 10,
    );

    _subscription = Geolocator.getPositionStream(locationSettings: settings)
        .listen(
          _onPosition,
          onError: (Object e, StackTrace s) {
            developer.log('geofence stream error', error: e, stackTrace: s);
          },
        );
  }

  @override
  Future<void> removeGeofence() async {
    await _subscription?.cancel();
    _subscription = null;
    _centerLat = null;
    _centerLng = null;
    _radiusMeters = null;
    _insideRegion = false;
  }

  void _onPosition(Position pos) {
    final lat = _centerLat;
    final lng = _centerLng;
    final radius = _radiusMeters;
    if (lat == null || lng == null || radius == null) return;
    final distance = Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      lat,
      lng,
    );
    final isInside = distance <= radius;
    if (isInside && !_insideRegion) {
      _insideRegion = true;
      _controller.add(
        LocationPoint(
          latitude: pos.latitude,
          longitude: pos.longitude,
          timestamp: pos.timestamp.toUtc(),
          accuracy: pos.accuracy,
        ),
      );
    } else if (!isInside && _insideRegion) {
      // Reset so a subsequent re-entry fires again.
      _insideRegion = false;
    }
  }

  /// Closes the broadcast controller and cancels the position
  /// subscription. Fix for bugs.json Warn (leak — controller never
  /// closed). Idempotent.
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    if (!_controller.isClosed) {
      await _controller.close();
    }
  }
}
