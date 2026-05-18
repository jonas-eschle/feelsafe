/// `StealthIconServiceProtocol` — abstract contract for switching
/// the launcher icon to a stealth preset (fake app appearance).
///
/// Pure Dart. The concrete implementation uses activity-alias swaps
/// on Android and no-ops on iOS (iOS cannot change the launcher icon
/// without going through `UIApplication.setAlternateIconName`) in
/// Phase 9.
library;

import 'package:guardianangela/domain/models/stealth_config.dart';

/// Abstract contract for the stealth-icon service.
abstract class StealthIconServiceProtocol {
  /// Switches the launcher icon to [preset].
  Future<void> setPreset(StealthIconPreset preset);

  /// Returns the currently active [StealthIconPreset].
  Future<StealthIconPreset> getCurrentPreset();
}
