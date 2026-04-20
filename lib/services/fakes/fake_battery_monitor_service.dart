/// Deterministic fake implementation of
/// [BatteryMonitorServiceProtocol] for tests. Every call is recorded
/// to [calls]; low-battery events are broadcast via a controller.
library;

import 'dart:async';

import 'package:guardianangela/services/protocols/battery_monitor_service_protocol.dart';

/// Test double for [BatteryMonitorServiceProtocol].
final class FakeBatteryMonitorService
    implements BatteryMonitorServiceProtocol {
  /// Creates a fake battery-monitor service.
  FakeBatteryMonitorService();

  /// Invocation log: one entry per method call.
  final List<String> calls = [];

  bool _active = false;
  final StreamController<int> _lowBatteryController =
      StreamController<int>.broadcast();

  @override
  Stream<int> get onLowBattery => _lowBatteryController.stream;

  @override
  Future<void> startMonitoring({required int thresholdPercent}) async {
    calls.add('startMonitoring:$thresholdPercent');
    _active = true;
  }

  @override
  Future<void> stopMonitoring() async {
    calls.add('stopMonitoring');
    _active = false;
  }

  @override
  bool get isActive => _active;

  /// Test helper: synthesize a low-battery crossing on the stream.
  void injectLowBattery(int percent) {
    _lowBatteryController.add(percent);
  }

  /// Closes the low-battery stream controller.
  void dispose() {
    _lowBatteryController.close();
  }
}
