import 'package:guardianangela/domain/models/location_point.dart';
import 'package:guardianangela/services/protocols/location_service_protocol.dart'
    show LocationFallbackResult, LocationServiceProtocol;

/// Simulation [LocationServiceProtocol] for tests.
///
/// Accepts an optional [Iterable<LocationPoint>] at construction time to
/// seed the in-memory history, enabling deterministic test scenarios.
/// Never calls `geolocator` or any platform code.
///
/// Additional controller-facing methods mirror [RealLocationService] so tests
/// that cast to this type can call [startTracking] / [stopTracking] etc.
class SimulationLocationService implements LocationServiceProtocol {
  /// Creates a [SimulationLocationService].
  ///
  /// [initialPoints] — seed points added to [history] immediately. Defaults
  /// to an empty list.
  SimulationLocationService({Iterable<LocationPoint>? initialPoints}) {
    if (initialPoints != null) {
      _history.addAll(initialPoints);
    }
  }

  final List<LocationPoint> _history = [];

  /// Whether [startTracking] has been called without a subsequent
  /// [stopTracking].
  bool get isTracking => _tracking;
  bool _tracking = false;

  /// Whether [requestPermission] has been called.
  bool get permissionRequested => _permissionRequested;
  bool _permissionRequested = false;

  /// Simulated permission result returned by [requestPermission].
  ///
  /// Defaults to `true`. Tests can set this to `false` to simulate denial.
  bool simulatedPermissionGranted = true;

  /// When `true` (default), [getLastLocationWithFallback] returns a fresh
  /// result. Set to `false` to simulate a stale-cache fallback path.
  bool simulatedFreshFix = true;

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

  /// Simulates requesting location permission.
  ///
  /// Returns [simulatedPermissionGranted]. Marks [permissionRequested].
  @override
  Future<bool> requestPermission() async {
    _permissionRequested = true;
    return simulatedPermissionGranted;
  }

  /// Marks [isTracking] as `true`.
  @override
  Future<void> startTracking({
    Duration interval = const Duration(seconds: 30),
  }) async {
    _tracking = true;
  }

  /// Marks [isTracking] as `false`.
  @override
  void stopTracking() {
    _tracking = false;
  }

  /// Returns the last [LocationPoint] in [history], or `null`.
  @override
  LocationPoint? getLastLocationPoint() =>
      _history.isEmpty ? null : _history.last;

  /// Returns the last [LocationPoint] wrapped in a [LocationFallbackResult].
  ///
  /// For simulation there is no distinction between current and stale; returns
  /// a fresh result when [simulatedFreshFix] is `true` (default), or a stale
  /// result when `false`. Returns `null` if [history] is empty.
  @override
  Future<LocationFallbackResult?> getLastLocationWithFallback() async {
    final pt = getLastLocationPoint();
    if (pt == null) return null;
    if (simulatedFreshFix) {
      return LocationFallbackResult(point: pt);
    }
    final note = 'Last known location at ${pt.timestamp.toIso8601String()}';
    return LocationFallbackResult(point: pt, staleNote: note);
  }

  /// All tracked points (unmodifiable view).
  @override
  List<LocationPoint> get history => List.unmodifiable(_history);

  /// Clears [history].
  @override
  void clearHistory() => _history.clear();

  /// Injects a point into [history] as if it came from a GPS fix.
  ///
  /// Enforces the 1000-point bound (spec 05:433): when the limit is reached
  /// the oldest point is discarded.
  void injectPoint(LocationPoint point) {
    if (_history.length >= 1000) {
      _history.removeAt(0);
    }
    _history.add(point);
  }
}
