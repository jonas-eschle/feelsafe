/// Real battery-monitor-service implementation stub. Phase 9 fills
/// bodies.
library;

import 'package:guardianangela/services/protocols/battery_monitor_service_protocol.dart';

/// Real platform-backed implementation of
/// [BatteryMonitorServiceProtocol].
final class BatteryMonitorService implements BatteryMonitorServiceProtocol {
  /// Creates the real battery-monitor service.
  BatteryMonitorService();

  @override
  Stream<int> get onLowBattery =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> startMonitoring({required int thresholdPercent}) async =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> stopMonitoring() async =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  bool get isActive =>
      throw UnimplementedError('TODO: Phase 9 real impl');
}
