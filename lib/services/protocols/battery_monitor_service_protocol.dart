/// `BatteryMonitorServiceProtocol` — abstract contract for the
/// low-battery one-shot alert monitor.
///
/// Pure Dart. The concrete implementation bridges to native battery
/// APIs in Phase 4b.
library;

/// Abstract contract for the battery-monitor service.
abstract class BatteryMonitorServiceProtocol {
  /// Broadcast stream that emits once per low-battery crossing,
  /// carrying the current battery percentage (0-100).
  Stream<int> get onLowBattery;

  /// Starts monitoring for a crossing below [thresholdPercent].
  ///
  /// [thresholdPercent] — percentage (0-100) that triggers the
  /// one-shot alert when crossed from above.
  Future<void> startMonitoring({required int thresholdPercent});

  /// Stops monitoring.
  Future<void> stopMonitoring();

  /// True iff the service is currently monitoring.
  bool get isActive;
}
