import 'dart:async';

import 'package:guardianangela/services/protocols/battery_monitor_service_protocol.dart';

/// Simulation [BatteryMonitorServiceProtocol] for tests.
///
/// A broadcast [StreamController] is exposed so tests can inject battery-level
/// readings at will. Never calls `battery_plus` or any platform code.
class SimulationBatteryMonitorService implements BatteryMonitorServiceProtocol {
  /// Creates a [SimulationBatteryMonitorService].
  SimulationBatteryMonitorService();

  final StreamController<int> _controller = StreamController<int>.broadcast();

  /// Whether [startMonitoring] has been called without a subsequent
  /// [stopMonitoring].
  bool get isMonitoring => _monitoring;
  bool _monitoring = false;

  /// The threshold configured in the last [startMonitoring] call.
  int? get lastThreshold => _lastThreshold;
  int? _lastThreshold;

  // ---------------------------------------------------------------------------
  // BatteryMonitorServiceProtocol implementation
  // ---------------------------------------------------------------------------

  @override
  Future<void> startMonitoring({int threshold = 10}) async {
    _lastThreshold = threshold;
    _monitoring = true;
  }

  @override
  Future<void> stopMonitoring() async {
    _monitoring = false;
    _lastThreshold = null;
  }

  @override
  Stream<int> get batteryLevel => _controller.stream;

  // ---------------------------------------------------------------------------
  // Test helpers
  // ---------------------------------------------------------------------------

  /// Injects a battery-level reading into the [batteryLevel] stream.
  void injectLevel(int level) => _controller.add(level);

  /// Closes the underlying stream controller.
  ///
  /// Call after tests to avoid stream leaks.
  Future<void> dispose() => _controller.close();
}
