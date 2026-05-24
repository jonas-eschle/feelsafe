// Native platform integration: geolocator (cross-platform).
// No custom channel needed — geolocator handles both Android and iOS.

import 'dart:async';
import 'dart:developer';

import 'package:geolocator/geolocator.dart';

import 'package:guardianangela/domain/models/location_point.dart';

import 'package:guardianangela/services/protocols/location_service_protocol.dart'
    show LocationFallbackResult, LocationServiceProtocol;

/// Maximum number of [LocationPoint] entries kept in [history].
///
/// When the limit is reached the oldest point is dropped.
const int _kMaxHistorySize = 1000;

/// Production [LocationServiceProtocol] backed by `package:geolocator`.
///
/// Tracking starts a [Position] stream with [LocationAccuracy.high] and a
/// 10-metre distance filter. Points are appended to [_history] (bounded at
/// [_kMaxHistorySize]). All public methods are safe to call before
/// [startTracking]; they return `null`/`false`/empty as appropriate.
///
/// **Single constructor location rule:** no `RealLocationService()`
/// call may appear outside `lib/services/service_providers.dart`
/// (CI grep enforces).
class RealLocationService implements LocationServiceProtocol {
  /// Creates a [RealLocationService].
  RealLocationService();

  final List<LocationPoint> _history = [];
  StreamSubscription<Position>? _sub;

  // ---------------------------------------------------------------------------
  // LocationServiceProtocol implementation
  // ---------------------------------------------------------------------------

  @override
  String? getLastLocationUrl() =>
      _history.isEmpty ? null : _history.last.toMapsUrl();

  @override
  String? getLastLocationDescription() {
    if (_history.isEmpty) return null;
    final pt = _history.last;
    final url = pt.toMapsUrl();
    final ts = pt.timestamp.toIso8601String();
    final accuracyPart = pt.accuracy != null
        ? ', accuracy=${pt.accuracy!.toStringAsFixed(0)}m'
        : '';
    return 'Last known location at $ts$accuracyPart: $url';
  }

  /// Checks and requests location permission.
  ///
  /// Returns `true` if permission is granted or was already granted. Returns
  /// `false` on denial or when location services are disabled. Never throws.
  @override
  Future<bool> requestPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        log('Location services disabled', name: 'LocationService');
        return false;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        log('Location permission denied: $permission', name: 'LocationService');
        return false;
      }

      log('Location permission granted: $permission', name: 'LocationService');
      return true;
    } catch (e) {
      log('requestPermission error: $e', name: 'LocationService');
      return false;
    }
  }

  /// Starts polling GPS location at [interval] (default 30 s).
  ///
  /// Uses [LocationAccuracy.high] and a 10-metre distance filter.
  /// Captures an initial fix immediately on start.
  @override
  Future<void> startTracking({
    Duration interval = const Duration(seconds: 30),
  }) async {
    if (_sub != null) {
      log(
        'startTracking called while already tracking',
        name: 'LocationService',
      );
      return;
    }

    log(
      'startTracking — interval=${interval.inSeconds}s',
      name: 'LocationService',
    );

    // Capture an initial fix immediately.
    try {
      final initial = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _appendPosition(initial);
    } catch (e) {
      log('Initial position error: $e', name: 'LocationService');
    }

    // Subscribe to ongoing updates.
    final settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
      timeLimit: interval,
    );

    _sub = Geolocator.getPositionStream(locationSettings: settings).listen(
      _appendPosition,
      onError: (Object e) {
        log('Position stream error: $e', name: 'LocationService');
      },
    );
  }

  /// Cancels the location stream subscription.
  @override
  void stopTracking() {
    _sub?.cancel();
    _sub = null;
    log('stopTracking', name: 'LocationService');
  }

  /// Returns the last known [LocationPoint], or `null` if unavailable.
  @override
  LocationPoint? getLastLocationPoint() =>
      _history.isEmpty ? null : _history.last;

  /// Returns the last known location wrapped in a [LocationFallbackResult].
  ///
  /// Tries `Geolocator.getCurrentPosition` with a 5-second timeout. On
  /// success, returns a fresh result (`staleNote == null`). On timeout or any
  /// error, falls back to the last cached point and attaches a
  /// "Last known location at {ISO-8601}" note per spec 05:417-419.
  ///
  /// Returns `null` only when no cached point exists.
  @override
  Future<LocationFallbackResult?> getLastLocationWithFallback() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
      final pt = LocationPoint(
        latitude: pos.latitude,
        longitude: pos.longitude,
        timestamp: pos.timestamp.toUtc(),
        accuracy: pos.accuracy > 0 ? pos.accuracy : null,
      );
      _appendPosition(pos);
      log(
        'getLastLocationWithFallback — fresh fix obtained',
        name: 'LocationService',
      );
      return LocationFallbackResult(point: pt);
    } catch (e) {
      log(
        'getLastLocationWithFallback — fresh fix failed ($e), '
        'falling back to cache',
        name: 'LocationService',
      );
      final cached = getLastLocationPoint();
      if (cached == null) return null;
      final note =
          'Last known location at ${cached.timestamp.toIso8601String()}';
      return LocationFallbackResult(point: cached, staleNote: note);
    }
  }

  /// Unmodifiable list of all tracked positions during this session.
  ///
  /// Bounded at [_kMaxHistorySize] points; oldest are discarded.
  @override
  List<LocationPoint> get history => List.unmodifiable(_history);

  /// Wipes all logged positions.
  @override
  void clearHistory() {
    _history.clear();
    log('clearHistory', name: 'LocationService');
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _appendPosition(Position pos) {
    final pt = LocationPoint(
      latitude: pos.latitude,
      longitude: pos.longitude,
      timestamp: pos.timestamp.toUtc(),
      accuracy: pos.accuracy > 0 ? pos.accuracy : null,
    );
    if (_history.length >= _kMaxHistorySize) {
      _history.removeAt(0);
    }
    _history.add(pt);
    log('Position: ${pt.latitude},${pt.longitude}', name: 'LocationService');
  }
}
