import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../data/models/walk_session.dart';

class LocationService {
  StreamSubscription<Position>? _positionSubscription;
  final List<LocationPoint> _history = [];
  Position? _lastPosition;

  List<LocationPoint> get history => List.unmodifiable(_history);
  Position? get lastPosition => _lastPosition;

  /// Request location permission. Returns true if granted.
  Future<bool> requestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  /// Start tracking GPS position at the given interval.
  /// Default: every 30 seconds.
  Future<void> startTracking({Duration? interval}) async {
    interval ??= const Duration(seconds: 30);

    // Get initial position
    try {
      _lastPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (_lastPosition != null) {
        _addToHistory(_lastPosition!);
      }
    } catch (_) {
      // Location may not be available yet — continue with stream
    }

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Minimum 10m movement
        timeLimit: interval,
      ),
    ).listen(
      (position) {
        _lastPosition = position;
        _addToHistory(position);
      },
      onError: (_) {
        // Silently handle stream errors — location may be temporarily unavailable
      },
    );
  }

  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// Get the last known location as a Google Maps URL.
  /// Returns null if no position is available.
  String? getLastLocationUrl() {
    final pos = _lastPosition;
    if (pos == null) return null;
    return 'https://maps.google.com/?q=${pos.latitude},${pos.longitude}';
  }

  /// Get the last known position as a LocationPoint.
  LocationPoint? getLastLocationPoint() {
    final pos = _lastPosition;
    if (pos == null) return null;
    return LocationPoint(
      latitude: pos.latitude,
      longitude: pos.longitude,
      timestamp: pos.timestamp,
    );
  }

  void clearHistory() {
    _history.clear();
  }

  void _addToHistory(Position position) {
    _history.add(LocationPoint(
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: position.timestamp,
    ));
  }
}
