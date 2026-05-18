/// `PermissionServiceProtocol` — abstract contract for runtime
/// permission requests (audit Q5).
///
/// Pure Dart. The real implementation delegates to
/// `lib/core/utils/permission_utils.dart`; the fake records calls so
/// tests can assert on permission flows without touching the
/// platform plugin.
library;

import 'package:guardianangela/core/utils/permission_utils.dart'
    show LocationPermissionLevel;

export 'package:guardianangela/core/utils/permission_utils.dart'
    show LocationPermissionLevel;

/// Abstract contract for the permission service.
///
/// Each `ensure…` method requests the underlying permission (showing
/// the system dialog if needed) and returns whether the permission
/// is granted after the request flow settles.
abstract class PermissionServiceProtocol {
  /// Ensures the notification-post permission. Always granted on
  /// older Android and iOS; gated on Android 13+.
  Future<bool> ensureNotification();

  /// Ensures location permission at the requested [level].
  Future<bool> ensureLocation({
    LocationPermissionLevel level = LocationPermissionLevel.whenInUse,
  });

  /// Ensures the CALL_PHONE permission (Android). Always `true` on
  /// iOS because `tel:` URIs are unprompted.
  Future<bool> ensureCallPhone();

  /// Ensures the SEND_SMS permission (Android). Always `true` on
  /// iOS — the system Messages compose sheet doesn't require it.
  Future<bool> ensureSendSms();

  /// Ensures battery-optimization exemption (Android Doze ignore).
  /// Always `true` on iOS.
  Future<bool> ensureBatteryOptimizationExempt();

  /// Opens the app's settings page so the user can grant a
  /// permanently-denied permission.
  Future<void> openAppSettings();
}
