/// Simulation implementation of [BatteryMonitorServiceProtocol]. All
/// methods log via `dart:developer` and return a no-op.
library;

import 'dart:async';
import 'dart:developer' as developer;

import 'package:guardianangela/services/protocols/battery_monitor_service_protocol.dart';

/// Simulation double for [BatteryMonitorServiceProtocol].
final class SimulationBatteryMonitorService
    implements BatteryMonitorServiceProtocol {
  /// Creates the simulation battery-monitor service.
  SimulationBatteryMonitorService();

  bool _active = false;
  final StreamController<int> _lowBatteryController =
      StreamController<int>.broadcast();

  @override
  Stream<int> get onLowBattery => _lowBatteryController.stream;

  @override
  Future<void> startMonitoring({required int thresholdPercent}) async {
    developer.log(
      '[SIM] batteryMonitor.startMonitoring threshold=$thresholdPercent',
    );
    _active = true;
  }

  @override
  Future<void> stopMonitoring() async {
    developer.log('[SIM] batteryMonitor.stopMonitoring');
    _active = false;
  }

  @override
  bool get isActive => _active;

  /// Closes the low-battery stream controller.
  void dispose() {
    _lowBatteryController.close();
  }
}
