/// Real implementation of [BiometricServiceProtocol] backed by the
/// `local_auth` plugin. Falls back gracefully to `unavailable` on
/// any plugin exception (platform missing, no enrolled biometrics,
/// etc.) — callers MUST treat `unavailable` as "show PIN".
library;

import 'dart:developer' as developer;

import 'package:local_auth/local_auth.dart';

import 'package:guardianangela/services/protocols/biometric_service_protocol.dart';

/// Real local-auth-backed biometric service.
final class BiometricService implements BiometricServiceProtocol {
  /// Creates a biometric service. [auth] is injectable for tests.
  BiometricService({LocalAuthentication? auth})
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return false;
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return false;
      final enrolled = await _auth.getAvailableBiometrics();
      return enrolled.isNotEmpty;
    } on Object catch (error, stack) {
      developer.log(
        'biometric.isAvailable failed',
        error: error,
        stackTrace: stack,
      );
      return false;
    }
  }

  @override
  Future<BiometricResult> authenticate({required String reason}) async {
    try {
      if (!await isAvailable()) return BiometricResult.unavailable;
      final ok = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
      return ok ? BiometricResult.success : BiometricResult.cancelled;
    } on Object catch (error, stack) {
      developer.log(
        'biometric.authenticate failed',
        error: error,
        stackTrace: stack,
      );
      return BiometricResult.unavailable;
    }
  }
}
