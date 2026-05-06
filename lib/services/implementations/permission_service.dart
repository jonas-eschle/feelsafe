/// Real implementation of [PermissionServiceProtocol].
///
/// Delegates to the helpers in `lib/core/utils/permission_utils.dart`
/// so the underlying `permission_handler` calls live in exactly one
/// place. Tests substitute a fake via `permissionServiceProvider`.
library;

import 'package:guardianangela/core/utils/permission_utils.dart' as utils;
import 'package:guardianangela/services/protocols/permission_service_protocol.dart';

/// Real implementation of [PermissionServiceProtocol].
final class PermissionService implements PermissionServiceProtocol {
  /// Creates the service.
  const PermissionService();

  @override
  Future<bool> ensureNotification() => utils.ensureNotificationPermission();

  @override
  Future<bool> ensureLocation({
    LocationPermissionLevel level = LocationPermissionLevel.whenInUse,
  }) => utils.ensureLocationPermission(level);

  @override
  Future<bool> ensureCallPhone() => utils.ensureCallPhonePermission();

  @override
  Future<bool> ensureSendSms() => utils.ensureSendSmsPermission();

  @override
  Future<bool> ensureBatteryOptimizationExempt() =>
      utils.ensureBatteryOptimizationExempt();

  @override
  Future<void> openAppSettings() async {
    await utils.openPermissionSettings();
  }
}
