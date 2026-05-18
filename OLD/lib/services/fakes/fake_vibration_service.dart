/// Deterministic fake implementation of [VibrationServiceProtocol]
/// for tests. Every call is recorded to [calls].
library;

import 'package:guardianangela/services/protocols/vibration_service_protocol.dart';

/// Test double for [VibrationServiceProtocol].
final class FakeVibrationService implements VibrationServiceProtocol {
  /// Creates a fake vibration service.
  FakeVibrationService();

  /// Invocation log: one entry per method call.
  final List<String> calls = [];

  @override
  Future<void> alarmPattern({bool isSimulation = false}) async {
    calls.add('alarmPattern');
  }

  @override
  Future<void> warningPattern({bool isSimulation = false}) async {
    calls.add('warningPattern');
  }

  @override
  Future<void> fakeCallPattern({bool isSimulation = false}) async {
    calls.add('fakeCallPattern');
  }

  @override
  Future<void> stop() async {
    calls.add('stop');
  }

  /// Tears down any held state (no-op here; provided for symmetry).
  void dispose() {}
}
