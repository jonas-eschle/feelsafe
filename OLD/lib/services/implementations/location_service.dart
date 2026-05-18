/// Real location-service implementation.
///
/// Wraps the `geolocator` package for permission handling, continuous
/// tracking with a 20m distance filter, and an in-memory FIFO history
/// capped at 200 points.
library;

import 'dart:async';
import 'dart:developer' as developer;

import 'package:geolocator/geolocator.dart';

import 'package:guardianangela/domain/models/location_point.dart';
import 'package:guardianangela/services/protocols/location_service_protocol.dart';

/// Real platform-backed implementation of [LocationServiceProtocol].
final class LocationService implements LocationServiceProtocol {
  /// Creates the real location service.
  LocationService();

  /// Maximum number of points retained in the FIFO history.
  static const int _historyCap = 200;

  final List<LocationPoint> _history = <LocationPoint>[];
  StreamSubscription<Position>? _subscription;

  @override
  Future<bool> requestPermission() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse;
  }

  @override
  Future<void> startTracking({
    Duration interval = const Duration(seconds: 60),
  }) async {
    await _subscription?.cancel();
    final settings = LocationSettings(
      accuracy: LocationAccuracy.medium,
      distanceFilter: 20,
      timeLimit: interval * 4,
    );
    _subscription = Geolocator.getPositionStream(locationSettings: settings)
        .listen(
          _onPosition,
          onError: (Object error, StackTrace stack) {
            developer.log(
              'location stream error',
              error: error,
              stackTrace: stack,
            );
          },
        );
  }

  @override
  Future<void> stopTracking() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  @override
  String? getLastLocationUrl() => getLastLocationPoint()?.toMapsUrl();

  @override
  LocationPoint? getLastLocationPoint() =>
      _history.isEmpty ? null : _history.last;

  @override
  Future<LocationPoint?> getCurrentPosition() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      final point = LocationPoint(
        latitude: pos.latitude,
        longitude: pos.longitude,
        timestamp: pos.timestamp.toUtc(),
        accuracy: pos.accuracy,
      );
      _history.add(point);
      while (_history.length > _historyCap) {
        _history.removeAt(0);
      }
      return point;
    } on Object catch (error, stack) {
      developer.log(
        'getCurrentPosition error',
        error: error,
        stackTrace: stack,
      );
      return null;
    }
  }

  @override
  List<LocationPoint> get history => List.unmodifiable(_history);

  @override
  void clearHistory() => _history.clear();

  void _onPosition(Position pos) {
    final point = LocationPoint(
      latitude: pos.latitude,
      longitude: pos.longitude,
      timestamp: pos.timestamp.toUtc(),
      accuracy: pos.accuracy,
    );
    _history.add(point);
    while (_history.length > _historyCap) {
      _history.removeAt(0);
    }
  }
}
