/// Real device-state-service implementation.
///
/// Uses a platform method channel for Android DND / silent-mode
/// queries; iOS does not expose these to apps so both queries return
/// false there. The native Android side (`com.guardianangela.app/
/// device_state`) is wired in Phase 10.
library;

import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:flutter/services.dart';

import 'package:guardianangela/services/protocols/device_state_service_protocol.dart';

/// Real platform-backed implementation of
/// [DeviceStateServiceProtocol].
final class DeviceStateService implements DeviceStateServiceProtocol {
  /// Creates the real device-state service.
  DeviceStateService();

  /// Method channel name. Native side lands in Phase 10.
  static const MethodChannel _channel = MethodChannel(
    'com.guardianangela.app/device_state',
  );

  @override
  Future<bool> isDndOn() async {
    if (!Platform.isAndroid) return false;
    try {
      final res = await _channel.invokeMethod<bool>('isDndOn');
      return res ?? false;
    } on MissingPluginException {
      developer.log('device_state.isDndOn not wired — Phase 10');
      return false;
    } on PlatformException catch (e, s) {
      developer.log(
        'device_state.isDndOn platform error',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  @override
  Future<bool> isSilent() async {
    if (!Platform.isAndroid) return false;
    try {
      final res = await _channel.invokeMethod<bool>('isSilent');
      return res ?? false;
    } on MissingPluginException {
      developer.log('device_state.isSilent not wired — Phase 10');
      return false;
    } on PlatformException catch (e, s) {
      developer.log(
        'device_state.isSilent platform error',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }
}
