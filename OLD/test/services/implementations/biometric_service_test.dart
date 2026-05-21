/// Tests for [BiometricService].
///
/// [LocalAuthentication] is injected via the DI seam so all branches
/// can be exercised on the Linux test host without a real biometric
/// hardware stack.
library;

import 'package:checks/checks.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';

import 'package:guardianangela/services/implementations/biometric_service.dart';
import 'package:guardianangela/services/protocols/biometric_service_protocol.dart';

class _MockLocalAuthentication extends Mock implements LocalAuthentication {}

/// Configures a fully-available mock: device supported, can check,
/// has enrolled biometrics.
_MockLocalAuthentication _makeAvailableMock() {
  final m = _MockLocalAuthentication();
  when(m.isDeviceSupported).thenAnswer((_) async => true);
  when(() => m.canCheckBiometrics).thenAnswer((_) async => true);
  when(
    m.getAvailableBiometrics,
  ).thenAnswer((_) async => <BiometricType>[BiometricType.fingerprint]);
  return m;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BiometricService.isAvailable', () {
    test('returns false when device is not supported', () async {
      final mock = _MockLocalAuthentication();
      when(mock.isDeviceSupported).thenAnswer((_) async => false);

      final service = BiometricService(auth: mock);
      final result = await service.isAvailable();

      check(result).isFalse();
      // canCheckBiometrics and getAvailableBiometrics should not be
      // called once device support is ruled out.
      verifyNever(() => mock.canCheckBiometrics); // getter — closure form
      verifyNever(mock.getAvailableBiometrics);
    });

    test('returns false when canCheckBiometrics is false', () async {
      final mock = _MockLocalAuthentication();
      when(mock.isDeviceSupported).thenAnswer((_) async => true);
      when(() => mock.canCheckBiometrics).thenAnswer((_) async => false);

      final service = BiometricService(auth: mock);
      final result = await service.isAvailable();

      check(result).isFalse();
      verifyNever(mock.getAvailableBiometrics);
    });

    test('returns false when no biometrics are enrolled', () async {
      final mock = _MockLocalAuthentication();
      when(mock.isDeviceSupported).thenAnswer((_) async => true);
      when(() => mock.canCheckBiometrics).thenAnswer((_) async => true);
      when(
        mock.getAvailableBiometrics,
      ).thenAnswer((_) async => <BiometricType>[]);

      final service = BiometricService(auth: mock);
      final result = await service.isAvailable();

      check(result).isFalse();
    });

    test(
      'returns true when device supported, can check, and enrolled',
      () async {
        final mock = _makeAvailableMock();
        final service = BiometricService(auth: mock);
        final result = await service.isAvailable();

        check(result).isTrue();
      },
    );

    test('returns false and logs when plugin throws', () async {
      final mock = _MockLocalAuthentication();
      when(mock.isDeviceSupported).thenThrow(PlatformException(code: 'no_hw'));

      final service = BiometricService(auth: mock);
      // Must NOT throw — falls back to false gracefully.
      final result = await service.isAvailable();

      check(result).isFalse();
    });
  });

  group('BiometricService.authenticate', () {
    test('returns unavailable when isAvailable is false (no hw)', () async {
      final mock = _MockLocalAuthentication();
      when(mock.isDeviceSupported).thenAnswer((_) async => false);

      final service = BiometricService(auth: mock);
      final result = await service.authenticate(reason: 'test');

      check(result).equals(BiometricResult.unavailable);
      // authenticate itself should never be called when unavailable.
      verifyNever(
        () => mock.authenticate(
          localizedReason: any(named: 'localizedReason'),
          biometricOnly: any(named: 'biometricOnly'),
          persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
        ),
      );
    });

    test('returns success when authentication succeeds', () async {
      final mock = _makeAvailableMock();
      when(
        () => mock.authenticate(
          localizedReason: any(named: 'localizedReason'),
          biometricOnly: any(named: 'biometricOnly'),
          persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
        ),
      ).thenAnswer((_) async => true);

      final service = BiometricService(auth: mock);
      final result = await service.authenticate(reason: 'Unlock session');

      check(result).equals(BiometricResult.success);
      verify(
        () => mock.authenticate(
          localizedReason: 'Unlock session',
          biometricOnly: true,
          persistAcrossBackgrounding: true,
        ),
      ).called(1);
    });

    test('returns cancelled when user cancels the prompt', () async {
      final mock = _makeAvailableMock();
      when(
        () => mock.authenticate(
          localizedReason: any(named: 'localizedReason'),
          biometricOnly: any(named: 'biometricOnly'),
          persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
        ),
      ).thenAnswer((_) async => false);

      final service = BiometricService(auth: mock);
      final result = await service.authenticate(reason: 'Check-in');

      check(result).equals(BiometricResult.cancelled);
    });

    test(
      'returns unavailable and logs when plugin throws during auth',
      () async {
        final mock = _makeAvailableMock();
        when(
          () => mock.authenticate(
            localizedReason: any(named: 'localizedReason'),
            biometricOnly: any(named: 'biometricOnly'),
            persistAcrossBackgrounding: any(
              named: 'persistAcrossBackgrounding',
            ),
          ),
        ).thenThrow(PlatformException(code: 'locked_out'));

        final service = BiometricService(auth: mock);
        // Must NOT rethrow — callers treat unavailable as "show PIN".
        final result = await service.authenticate(reason: 'Check');

        check(result).equals(BiometricResult.unavailable);
      },
    );
  });

  group('BiometricService default constructor', () {
    test('zero-arg constructor uses real LocalAuthentication', () {
      // This exercises the `auth ?? LocalAuthentication()` branch (line 17).
      // We only verify construction does not throw; we do not call methods
      // because the real plugin has no Linux binding.
      check(() => BiometricService()).returnsNormally();
    });
  });
}
