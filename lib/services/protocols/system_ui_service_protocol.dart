/// `SystemUiServiceProtocol` — abstract contract for OS-level UX
/// affordances: quick-exit from Recents and battery-optimization
/// exemption requests.
///
/// Pure Dart. The concrete implementation bridges to native
/// `finishAndRemoveTask` on Android and no-ops on iOS in Phase 9.
library;

/// Abstract contract for OS-level UI / lifecycle affordances.
abstract class SystemUiServiceProtocol {
  /// Clears the app from Recents and terminates the process.
  ///
  /// On Android this calls `finishAndRemoveTask`; on iOS it is a
  /// no-op (Apple does not allow programmatic app termination).
  Future<void> quickExit();

  /// Requests the user to add Guardian Angela to the battery-
  /// optimization exemption list so background work is not killed.
  Future<void> requestBatteryOptimizationExemption();

  /// True iff the OS currently reports this app as battery-
  /// optimized (i.e., NOT exempt).
  Future<bool> isBatteryOptimized();
}
