/// Real system-ui-service implementation.
///
/// Dart-side only. Android uses a method channel
/// (`com.guardianangela.app/system_ui`) for `finishAndRemoveTask` and
/// battery-optimization exemption. iOS returns no-ops / false (Apple
/// does not allow programmatic termination or battery-exemption
/// prompts). Phase 10 writes the native backend.
library;

import 'dart:developer' as developer;

import 'package:flutter/services.dart';

import 'package:guardianangela/core/platform/platform_info.dart';
import 'package:guardianangela/services/protocols/system_ui_service_protocol.dart';

/// Real platform-backed implementation of [SystemUiServiceProtocol].
final class SystemUiService implements SystemUiServiceProtocol {
  /// Creates the real system-UI service.
  ///
  /// [platform] defaults to the const production [PlatformInfo()];
  /// tests inject a [FakePlatformInfo] to exercise the Android path.
  SystemUiService({PlatformInfo platform = const PlatformInfo()})
    : _platform = platform;

  static const MethodChannel _channel = MethodChannel(
    'com.guardianangela.app/system_ui',
  );

  final PlatformInfo _platform;

  @override
  Future<void> quickExit() async {
    if (!_platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('quickExit');
    } on MissingPluginException {
      return Future.error('Not wired — Phase 10');
    } on PlatformException catch (e, s) {
      developer.log(
        'system_ui.quickExit platform error',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  @override
  Future<void> requestBatteryOptimizationExemption() async {
    if (!_platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('requestBatteryOptimizationExemption');
    } on MissingPluginException {
      return Future.error('Not wired — Phase 10');
    } on PlatformException catch (e, s) {
      developer.log(
        'system_ui.requestBatteryOptimizationExemption error',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  @override
  Future<bool> isBatteryOptimized() async {
    if (!_platform.isAndroid) return false;
    try {
      final res = await _channel.invokeMethod<bool>('isBatteryOptimized');
      return res ?? false;
    } on MissingPluginException {
      developer.log('system_ui.isBatteryOptimized not wired — Phase 10');
      return false;
    } on PlatformException catch (e, s) {
      developer.log(
        'system_ui.isBatteryOptimized platform error',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }
}
