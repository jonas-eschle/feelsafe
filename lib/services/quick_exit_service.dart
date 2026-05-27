// Phase 7 native dependency: MethodChannel
// `com.guardianangela.app/quick_exit` (Android invokes
// `finishAndRemoveTask()`, iOS invokes `exit(0)`).
// Until that lands, the Dart side falls back to
// `SystemNavigator.pop(animated: false)` so the gesture has a visible
// effect even on a build without the native channel.

import 'dart:developer';

import 'package:flutter/services.dart';

import 'package:guardianangela/services/protocols/quick_exit_service_protocol.dart';

/// Production [QuickExitServiceProtocol] backed by a single
/// MethodChannel call.
///
/// The channel name is `com.guardianangela.app/quick_exit` and the
/// invoked method is `quickExit`. The native handler (Phase 7) maps
/// this to `Activity.finishAndRemoveTask()` on Android and to `exit(0)`
/// on iOS — see spec 04:1020–1027.
///
/// **Fallback:** when the native channel is not yet installed
/// (development builds, web, desktop) a
/// `MissingPluginException` or `PlatformException` triggers a
/// fall-through to `SystemNavigator.pop(animated: false)`. The pop call
/// is also wrapped in a guard so a thrown error does not bubble to the
/// caller — the user-facing intent is "exit", and there is no value in
/// surfacing an error after the user has already confirmed.
///
/// **Single constructor location rule:** no `RealQuickExitService()`
/// call may appear outside `lib/services/service_providers.dart` (CI
/// grep enforces).
class RealQuickExitService implements QuickExitServiceProtocol {
  /// Creates a [RealQuickExitService] using the canonical
  /// `com.guardianangela.app/quick_exit` platform channel.
  ///
  /// Tests intercept the channel via
  /// `TestDefaultBinaryMessenger.setMockMethodCallHandler` instead of
  /// swapping the channel instance — this keeps production wiring
  /// honest about the channel name (single source of truth, no
  /// per-test override fan-out).
  RealQuickExitService()
    : _channel = const MethodChannel('com.guardianangela.app/quick_exit');

  final MethodChannel _channel;

  @override
  Future<void> quickExit() async {
    try {
      await _channel.invokeMethod<void>('quickExit');
      return;
    } on MissingPluginException catch (e) {
      log(
        'native quick-exit channel missing — falling back to '
        'SystemNavigator.pop ($e)',
        name: 'QuickExitService',
      );
    } on PlatformException catch (e) {
      log(
        'native quick-exit channel error — falling back to '
        'SystemNavigator.pop ($e)',
        name: 'QuickExitService',
      );
    }
    // Fallback path. SystemNavigator.pop returns the app to the
    // launcher; on Android it does not remove the task from recents,
    // and on iOS it is a no-op (documented Flutter behaviour). Errors
    // here are logged and swallowed because the user has already
    // confirmed the exit intent.
    try {
      await SystemNavigator.pop(animated: false);
    } catch (e, st) {
      log(
        'SystemNavigator.pop fallback failed',
        name: 'QuickExitService',
        error: e,
        stackTrace: st,
      );
    }
  }
}
