// Native channel handler: Android DeviceInfoChannel.kt
// ('com.guardianangela.app/device_info', registered in MainActivity.kt).
// iOS / web / desktop: no platform support — the protocol returns
// SimNumberUnsupported without ever invoking the channel.

import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

import 'package:guardianangela/services/protocols/device_info_service_protocol.dart';

const MethodChannel _kDeviceInfoChannel = MethodChannel(
  'com.guardianangela.app/device_info',
);

/// Production [DeviceInfoServiceProtocol].
///
/// **Android** invokes `getSimPhoneNumber` on the device-info channel
/// and translates the result into a [SimNumberResult] variant.
///
/// **Every other platform** (iOS, web, Linux, macOS, Windows) returns
/// [SimNumberUnsupported] immediately without touching the channel —
/// the matching Kotlin handler does not exist on these targets.
///
/// **Single constructor location rule:** no `RealDeviceInfoService()`
/// call may appear outside `lib/services/service_providers.dart`
/// (CI grep enforces).
class RealDeviceInfoService implements DeviceInfoServiceProtocol {
  /// Creates a [RealDeviceInfoService].
  RealDeviceInfoService();

  @override
  Future<SimNumberResult> getSimPhoneNumber() async {
    if (kIsWeb || !Platform.isAndroid) {
      log('getSimPhoneNumber — unsupported platform', name: 'DeviceInfo');
      return const SimNumberUnsupported();
    }
    // LCOV_EXCL_START — device-only (Platform.isAndroid): SIM-number query via DeviceInfoChannel.kt; the host guard above returns SimNumberUnsupported before the channel (CI build-android)
    try {
      final String? number = await _kDeviceInfoChannel.invokeMethod<String>(
        'getSimPhoneNumber',
      );
      if (number == null || number.isEmpty) {
        return const SimNumberUnavailable();
      }
      return SimNumberAvailable(number);
    } on PlatformException catch (e) {
      log('getSimPhoneNumber PlatformException: ${e.code}', name: 'DeviceInfo');
      if (e.code == 'permissionDenied') {
        return const SimNumberPermissionDenied();
      }
      if (e.code == 'unavailable') {
        return SimNumberUnavailable(e.message);
      }
      return SimNumberUnavailable(e.message);
    } on MissingPluginException catch (_) {
      // Defensive: the native handler is unavailable (e.g. an older build).
      return const SimNumberUnsupported();
    }
    // LCOV_EXCL_STOP
  }
}
