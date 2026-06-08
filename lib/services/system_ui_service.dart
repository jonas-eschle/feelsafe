// Native channel handlers are registered in MainActivity.kt
// (Android: SystemUiChannel.kt — 'com.guardianangela.app/system_ui'
//           StealthIconChannel.kt — 'com.guardianangela.app/stealth_icon';
//  iOS: no-op — component toggling and lock-task are unavailable on iOS).

import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';

import 'package:guardianangela/domain/enums/stealth_icon_preset.dart';
import 'package:guardianangela/services/protocols/system_ui_service_protocol.dart';

// ---------------------------------------------------------------------------
// Channel identifiers
// ---------------------------------------------------------------------------

const MethodChannel _kSystemUiChannel = MethodChannel(
  'com.guardianangela.app/system_ui',
);
const MethodChannel _kStealthIconChannel = MethodChannel(
  'com.guardianangela.app/stealth_icon',
);

/// Production [SystemUiServiceProtocol].
///
/// **Android** routes each call to the appropriate Kotlin MethodChannel:
/// - [setStealthIcon]: `StealthIconChannel.kt` enables the one
///   `<activity-alias>` matching the preset (and disables the rest) so
///   the launcher icon/label is disguised.
/// - [toggleLockTaskMode]: `SystemUiChannel.kt` pins or unpins the
///   activity in Android Task Locking (pinned-app mode).
///
/// **iOS** all methods are no-ops — component toggling and lock-task
/// pinning have no iOS equivalent (spec 10 §Platform-Specific
/// Limitations).
///
/// On a host without the native handler (e.g. a unit-test or desktop
/// build) calls receive a [MissingPluginException] which is caught and
/// logged so the absence is non-fatal.
///
/// **Single constructor location rule:** no `RealSystemUiService()`
/// call may appear outside `lib/services/service_providers.dart`
/// (CI grep enforces).
class RealSystemUiService implements SystemUiServiceProtocol {
  /// Creates a [RealSystemUiService].
  RealSystemUiService();

  // ---------------------------------------------------------------------------
  // SystemUiServiceProtocol implementation
  // ---------------------------------------------------------------------------

  @override
  Future<void> setStealthIcon(StealthIconPreset preset) async {
    if (!Platform.isAndroid) {
      log(
        'setStealthIcon(${preset.name}) — no-op on iOS',
        name: 'SystemUiService',
      );
      return;
    }

    log('setStealthIcon(${preset.name})', name: 'SystemUiService');
    try {
      await _kStealthIconChannel.invokeMethod<void>('setStealthIcon', {
        'preset': preset.name,
      });
    } catch (e) {
      log('setStealthIcon error: $e', name: 'SystemUiService');
    }
  }

  @override
  Future<void> toggleLockTaskMode(bool enabled) async {
    if (!Platform.isAndroid) {
      log(
        'toggleLockTaskMode($enabled) — no-op on iOS',
        name: 'SystemUiService',
      );
      return;
    }

    log('toggleLockTaskMode($enabled)', name: 'SystemUiService');
    try {
      await _kSystemUiChannel.invokeMethod<void>('toggleLockTaskMode', {
        'enabled': enabled,
      });
    } catch (e) {
      log('toggleLockTaskMode error: $e', name: 'SystemUiService');
    }
  }
}
