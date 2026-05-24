// Native channel handler lands in Phase 7
// (Android: SystemUiChannel.kt — 'com.guardianangela.app/system_ui'
//           StealthIconChannel.kt — 'com.guardianangela.app/stealth_icon';
//  iOS: no-op — component toggling and lock-task are unavailable on iOS).

import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';

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
/// - [setStealthIconEnabled]: `StealthIconChannel.kt` toggles the
///   package manager component alias so the app icon disappears from
///   the device launcher and recent-apps list.
/// - [toggleLockTaskMode]: `SystemUiChannel.kt` pins or unpins the
///   activity in Android Task Locking (pinned-app mode).
///
/// **iOS** all methods are no-ops — component toggling and lock-task
/// pinning have no iOS equivalent (spec 10 §Platform-Specific
/// Limitations).
///
/// When the native handler is missing (Phase 7 not yet landed), calls
/// will receive a [MissingPluginException] which is caught and logged.
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
  Future<void> setStealthIconEnabled(bool enabled) async {
    if (!Platform.isAndroid) {
      log(
        'setStealthIconEnabled($enabled) — no-op on iOS',
        name: 'SystemUiService',
      );
      return;
    }

    log('setStealthIconEnabled($enabled)', name: 'SystemUiService');
    try {
      await _kStealthIconChannel.invokeMethod<void>(
        'setStealthIconEnabled',
        {'enabled': enabled},
      );
    } catch (e) {
      log('setStealthIconEnabled error: $e', name: 'SystemUiService');
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
      await _kSystemUiChannel.invokeMethod<void>(
        'toggleLockTaskMode',
        {'enabled': enabled},
      );
    } catch (e) {
      log('toggleLockTaskMode error: $e', name: 'SystemUiService');
    }
  }
}
