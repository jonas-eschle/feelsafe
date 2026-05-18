/// `DeviceStateServiceProtocol` — abstract contract for querying
/// transient device state (DND, ringer / silent mode).
///
/// Pure Dart. The concrete implementation reads system settings in
/// Phase 4b; used by strategies that decide whether to override
/// Do Not Disturb.
library;

/// Abstract contract for the device-state service.
abstract class DeviceStateServiceProtocol {
  /// True if Do Not Disturb is currently on.
  Future<bool> isDndOn();

  /// True if the ringer is currently in silent / vibrate mode.
  Future<bool> isSilent();
}
