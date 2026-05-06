/// Utility helpers wrapping the `permission_handler` plugin.
///
/// These functions are the lowest-level wrapper — they take a
/// [Permission] (or category) and return a `bool` reflecting whether
/// the permission ended up granted after the request flow. They are
/// kept for callers that want a one-line check without going through
/// Riverpod (e.g. tests, scripts), but new screens should depend on
/// [PermissionServiceProtocol] via `permissionServiceProvider` so the
/// behaviour can be faked in tests.
///
/// Audit Q5: This file used to be the only entry-point. The new
/// [PermissionService] delegates here so the helpers stay a single
/// source of truth.
library;

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:permission_handler/permission_handler.dart' as ph;

/// Levels of location-permission accuracy a caller can request.
///
/// Spec 05 §LocationService allows session GPS to fall back to coarse
/// when fine is denied; reminders never need fine.
enum LocationPermissionLevel {
  /// `Permission.locationWhenInUse` — coarse + fine while the app
  /// is in the foreground.
  whenInUse,

  /// `Permission.locationAlways` — background + foreground.
  always,
}

/// Requests notification permission and returns whether it ended up
/// granted. Android 13+ requires this; older platforms grant by
/// default.
Future<bool> ensureNotificationPermission() async {
  final status = await ph.Permission.notification.request();
  return status.isGranted;
}

/// Requests location permission at the given [level] and returns
/// whether it ended up granted.
Future<bool> ensureLocationPermission(LocationPermissionLevel level) async {
  final permission = switch (level) {
    LocationPermissionLevel.whenInUse => ph.Permission.locationWhenInUse,
    LocationPermissionLevel.always => ph.Permission.locationAlways,
  };
  final status = await permission.request();
  return status.isGranted;
}

/// Requests permission to place phone calls. Android only; iOS does
/// not gate `tel:` URIs behind a runtime permission so this returns
/// `true` on iOS.
Future<bool> ensureCallPhonePermission() async {
  if (defaultTargetPlatform == TargetPlatform.iOS) return true;
  final status = await ph.Permission.phone.request();
  return status.isGranted;
}

/// Requests permission to send SMS. Android only; iOS uses the
/// system Messages compose sheet which does not require a runtime
/// permission, so this returns `true` on iOS.
Future<bool> ensureSendSmsPermission() async {
  if (defaultTargetPlatform == TargetPlatform.iOS) return true;
  final status = await ph.Permission.sms.request();
  return status.isGranted;
}

/// Requests battery-optimization exemption (Android `Doze` ignore).
/// On iOS this is not applicable and always returns `true`.
Future<bool> ensureBatteryOptimizationExempt() async {
  if (defaultTargetPlatform == TargetPlatform.iOS) return true;
  final status = await ph.Permission.ignoreBatteryOptimizations.request();
  return status.isGranted;
}

/// Opens the app's settings page so the user can grant a permission
/// that was previously permanently denied. Returns whether the page
/// could be opened.
Future<bool> openPermissionSettings() => ph.openAppSettings();
