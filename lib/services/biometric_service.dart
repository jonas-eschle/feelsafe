import 'dart:developer';

import 'package:local_auth/local_auth.dart';

import 'package:guardianangela/services/protocols/biometric_service_protocol.dart';

/// Production [BiometricServiceProtocol] backed by `package:local_auth`.
///
/// Biometric-only: the prompt never falls back to the device passcode, because
/// the App PIN keypad is the intended fallback (and a coerced device passcode
/// would defeat the gate). The launch gate surfaces this service only when the
/// user has opted in via `AppSettings.appPinBiometricEnabled` (spec 06
/// §App PIN).
///
/// Every method swallows platform errors and resolves to a safe default
/// (`false`) so a misbehaving plugin can never lock the user out of the PIN
/// fallback — fail-soft toward the PIN, never toward an open app.
///
/// **Single constructor location rule:** no `RealBiometricService()` call may
/// appear outside `lib/services/service_providers.dart` (CI grep enforces).
class RealBiometricService implements BiometricServiceProtocol {
  /// Creates a [RealBiometricService].
  ///
  /// [auth] is injectable so tests can supply a fake `LocalAuthentication`;
  /// production passes nothing and a real instance is created.
  RealBiometricService({LocalAuthentication? auth})
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() async {
    try {
      if (!await _auth.isDeviceSupported()) return false;
      if (!await _auth.canCheckBiometrics) return false;
      final enrolled = await _auth.getAvailableBiometrics();
      return enrolled.isNotEmpty;
    } catch (e) {
      log('isAvailable check failed: $e', name: 'BiometricService');
      return false;
    }
  }

  @override
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        // biometricOnly: never fall back to the device passcode — the App PIN
        // keypad is the fallback. persistAcrossBackgrounding: survive a
        // transient backgrounding (e.g. the system biometric sheet) instead of
        // erroring out.
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (e) {
      log('authenticate failed: $e', name: 'BiometricService');
      return false;
    }
  }
}
