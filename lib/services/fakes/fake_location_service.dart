/// Deterministic fake implementation of [LocationServiceProtocol]
/// for tests. Every call is recorded to [calls]; test helpers
/// `injectPoint` / `setPermission` let tests script the behavior.
library;

import 'package:guardianangela/domain/models/location_point.dart';
import 'package:guardianangela/services/protocols/location_service_protocol.dart';

/// Test double for [LocationServiceProtocol].
final class FakeLocationService implements LocationServiceProtocol {
  /// Creates a fake location service.
  FakeLocationService();

  /// Invocation log: one entry per method call.
  final List<String> calls = [];

  final List<LocationPoint> _history = [];

  /// Scripted return value for [requestPermission]. Defaults to true.
  bool permissionGranted = true;

  @override
  Future<bool> requestPermission() async {
    calls.add('requestPermission');
    return permissionGranted;
  }

  @override
  Future<void> startTracking({
    Duration interval = const Duration(seconds: 60),
  }) async {
    calls.add('startTracking:${interval.inSeconds}s');
  }

  @override
  Future<void> stopTracking() async {
    calls.add('stopTracking');
  }

  @override
  String? getLastLocationUrl() {
    calls.add('getLastLocationUrl');
    return _history.isEmpty ? null : _history.last.toMapsUrl();
  }

  @override
  LocationPoint? getLastLocationPoint() {
    calls.add('getLastLocationPoint');
    return _history.isEmpty ? null : _history.last;
  }

  @override
  List<LocationPoint> get history => List.unmodifiable(_history);

  @override
  void clearHistory() {
    calls.add('clearHistory');
    _history.clear();
  }

  /// Test helper: append a scripted [point] to the fake history.
  void injectPoint(LocationPoint point) {
    _history.add(point);
  }

  /// Tears down any held state.
  void dispose() {
    _history.clear();
  }
}
