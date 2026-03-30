import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

/// Centralized permission handling for the app.
///
/// Required permissions:
/// - Location (fine) — GPS tracking during session
/// - SMS — sending emergency SMS on Android
/// - Phone — making emergency calls
class PermissionService {
  /// Check if all essential permissions are granted.
  Future<bool> hasEssentialPermissions() async {
    final location = await Permission.locationWhenInUse.isGranted;
    final phone = await Permission.phone.isGranted;

    if (Platform.isAndroid) {
      final sms = await Permission.sms.isGranted;
      return location && phone && sms;
    }

    return location && phone;
  }

  /// Request all essential permissions.
  /// Returns a map of permission → granted status.
  Future<Map<String, bool>> requestEssentialPermissions() async {
    final results = <String, bool>{};

    // Location
    final locationStatus = await Permission.locationWhenInUse.request();
    results['location'] = locationStatus.isGranted;

    // Phone
    final phoneStatus = await Permission.phone.request();
    results['phone'] = phoneStatus.isGranted;

    // SMS (Android only)
    if (Platform.isAndroid) {
      final smsStatus = await Permission.sms.request();
      results['sms'] = smsStatus.isGranted;
    }

    return results;
  }

  /// Check and request a specific permission.
  /// Returns true if granted after the request.
  Future<bool> ensurePermission(Permission permission) async {
    if (await permission.isGranted) return true;
    final status = await permission.request();
    return status.isGranted;
  }

  /// Check if location permission is granted.
  Future<bool> hasLocationPermission() async {
    return Permission.locationWhenInUse.isGranted;
  }

  /// Check if any permission is permanently denied (user must go to settings).
  Future<List<String>> getPermanentlyDenied() async {
    final denied = <String>[];

    if (await Permission.locationWhenInUse.isPermanentlyDenied) {
      denied.add('location');
    }
    if (await Permission.phone.isPermanentlyDenied) {
      denied.add('phone');
    }
    if (Platform.isAndroid && await Permission.sms.isPermanentlyDenied) {
      denied.add('sms');
    }

    return denied;
  }

  /// Open the system app settings page so the user can grant permissions.
  Future<bool> openSettings() {
    return openAppSettings();
  }
}
