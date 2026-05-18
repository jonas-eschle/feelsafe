/// Deterministic fake implementation of
/// [DeviceStateServiceProtocol] for tests. Every call is recorded to
/// [calls]; tests script return values via [dndOn] / [silent].
library;

import 'package:guardianangela/services/protocols/device_state_service_protocol.dart';

/// Test double for [DeviceStateServiceProtocol].
final class FakeDeviceStateService implements DeviceStateServiceProtocol {
  /// Creates a fake device-state service.
  FakeDeviceStateService();

  /// Invocation log: one entry per method call.
  final List<String> calls = [];

  /// Scripted return value for [isDndOn]. Defaults to false.
  bool dndOn = false;

  /// Scripted return value for [isSilent]. Defaults to false.
  bool silent = false;

  @override
  Future<bool> isDndOn() async {
    calls.add('isDndOn');
    return dndOn;
  }

  @override
  Future<bool> isSilent() async {
    calls.add('isSilent');
    return silent;
  }

  /// Tears down any held state (no-op here; provided for symmetry).
  void dispose() {}
}
