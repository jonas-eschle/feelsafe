/// Deterministic fake implementation of [SystemUiServiceProtocol]
/// for tests. Every call is recorded to [calls].
library;

import 'package:guardianangela/services/protocols/system_ui_service_protocol.dart';

/// Test double for [SystemUiServiceProtocol].
final class FakeSystemUiService implements SystemUiServiceProtocol {
  /// Creates a fake system-ui service.
  FakeSystemUiService();

  /// Invocation log: one entry per method call.
  final List<String> calls = [];

  /// Scripted return value for [isBatteryOptimized]. Defaults to
  /// false (i.e., app is NOT battery-optimized).
  bool batteryOptimized = false;

  @override
  Future<void> quickExit() async {
    calls.add('quickExit');
  }

  @override
  Future<void> requestBatteryOptimizationExemption() async {
    calls.add('requestBatteryOptimizationExemption');
  }

  @override
  Future<bool> isBatteryOptimized() async {
    calls.add('isBatteryOptimized');
    return batteryOptimized;
  }

  /// Tears down any held state (no-op here; provided for symmetry).
  void dispose() {}
}
