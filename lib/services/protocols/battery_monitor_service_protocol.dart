/// Abstract interface for session-time battery monitoring.
///
/// See spec 05 §BatteryMonitorService. Phase 5 supplies the concrete
/// implementation using `battery_plus`. The monitor fires a one-shot
/// alert per session when the level drops below the configured
/// threshold; the main session chain is never paused or interrupted.
abstract interface class BatteryMonitorServiceProtocol {
  /// Starts polling the battery level.
  ///
  /// When the level first drops at or below [threshold] percent, a
  /// one-shot alert fires via `BatteryAlertConfig.chain` on a
  /// separate engine instance. Subsequent dips below [threshold]
  /// during the same session are ignored.
  ///
  /// [threshold] defaults to 10 (percent). Valid range is 1–100.
  Future<void> startMonitoring({int threshold = 10});

  /// Stops polling and resets the one-shot fired flag.
  ///
  /// Call when the session ends so the next session starts fresh.
  Future<void> stopMonitoring();

  /// Broadcast stream of battery-level readings (0–100).
  ///
  /// Emits the current level at each polling interval. Consumers
  /// may subscribe to display the level in the session UI.
  Stream<int> get batteryLevel;
}
