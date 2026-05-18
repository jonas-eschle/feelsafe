/// Simulation implementation of [LocationServiceProtocol].
///
/// CRITICAL: this file MUST NOT import `geolocator` or declare any
/// [MethodChannel] — simulation layer 2 guarantees no real GPS fix
/// can be recorded during a simulated session.
library;

import 'dart:developer' as developer;

import 'package:guardianangela/domain/models/location_point.dart';
import 'package:guardianangela/services/protocols/location_service_protocol.dart';

/// Simulation double for [LocationServiceProtocol]. All methods are
/// structural no-ops logged via `dart:developer`.
final class SimulationLocationService implements LocationServiceProtocol {
  /// Creates the simulation location service.
  SimulationLocationService();

  @override
  Future<bool> requestPermission() async {
    developer.log('[SIM] location.requestPermission');
    return true;
  }

  @override
  Future<void> startTracking({
    Duration interval = const Duration(seconds: 60),
  }) async {
    developer.log('[SIM] location.startTracking interval=$interval');
  }

  @override
  Future<void> stopTracking() async {
    developer.log('[SIM] location.stopTracking');
  }

  @override
  String? getLastLocationUrl() {
    developer.log('[SIM] location.getLastLocationUrl');
    return null;
  }

  @override
  LocationPoint? getLastLocationPoint() {
    developer.log('[SIM] location.getLastLocationPoint');
    return null;
  }

  @override
  Future<LocationPoint?> getCurrentPosition() async {
    developer.log('[SIM] location.getCurrentPosition');
    return null;
  }

  @override
  List<LocationPoint> get history {
    developer.log('[SIM] location.history');
    return const [];
  }

  @override
  void clearHistory() {
    developer.log('[SIM] location.clearHistory');
  }
}
