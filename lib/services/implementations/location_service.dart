/// Real location-service implementation stub. Phase 9 fills bodies.
library;

import 'package:guardianangela/domain/models/location_point.dart';
import 'package:guardianangela/services/protocols/location_service_protocol.dart';

/// Real platform-backed implementation of [LocationServiceProtocol].
final class LocationService implements LocationServiceProtocol {
  /// Creates the real location service.
  LocationService();

  @override
  Future<bool> requestPermission() async =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> startTracking({
    Duration interval = const Duration(seconds: 60),
  }) async => throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> stopTracking() async =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  String? getLastLocationUrl() =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  LocationPoint? getLastLocationPoint() =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  List<LocationPoint> get history =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  void clearHistory() =>
      throw UnimplementedError('TODO: Phase 9 real impl');
}
