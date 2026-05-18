/// Deterministic fake implementation of [WakelockServiceProtocol]
/// for tests. Every call is recorded to [calls].
library;

import 'package:guardianangela/services/protocols/wakelock_service_protocol.dart';

/// Test double for [WakelockServiceProtocol].
final class FakeWakelockService implements WakelockServiceProtocol {
  /// Creates a fake wakelock service.
  FakeWakelockService();

  /// Invocation log: one entry per method call.
  final List<String> calls = [];

  bool _enabled = false;

  @override
  Future<void> enable() async {
    calls.add('enable');
    _enabled = true;
  }

  @override
  Future<void> disable() async {
    calls.add('disable');
    _enabled = false;
  }

  @override
  Future<bool> get isEnabled async {
    calls.add('isEnabled');
    return _enabled;
  }

  /// Tears down any held state (no-op here; provided for symmetry).
  void dispose() {}
}
