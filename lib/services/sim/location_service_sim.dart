import 'package:guardianangela/domain/models/location_point.dart';
import 'package:guardianangela/services/protocols/location_service_protocol.dart';

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

  // ---------------------------------------------------------------------------
  // Controller-facing methods (mirror RealLocationService)
  // ---------------------------------------------------------------------------

  /// Simulates requesting location permission.
  ///
  /// Returns [simulatedPermissionGranted]. Marks [permissionRequested].
  Future<bool> requestPermission() async {
    _permissionRequested = true;
    return simulatedPermissionGranted;
  }

  /// Marks [isTracking] as `true`.
  Future<void> startTracking({
    Duration interval = const Duration(seconds: 30),
  }) async {
    _tracking = true;
  }

  /// Marks [isTracking] as `false`.
  void stopTracking() {
    _tracking = false;
  }

  /// Returns the last [LocationPoint] in [history], or `null`.
  LocationPoint? getLastLocationPoint() =>
      _history.isEmpty ? null : _history.last;

  /// Returns the last [LocationPoint] in [history], or `null`.
  ///
  /// The "fallback" behaviour is identical to [getLastLocationPoint] for
  /// the simulation — there is no distinction between current and stale.
  LocationPoint? getLastLocationWithFallback() => getLastLocationPoint();

  /// All tracked points (unmodifiable view).
  List<LocationPoint> get history => List.unmodifiable(_history);

  /// Clears [history].
  void clearHistory() => _history.clear();

  /// Injects a point into [history] as if it came from a GPS fix.
  void injectPoint(LocationPoint point) {
    _history.add(point);
  }
}
