/// Unit tests for the biometric service triplet.
///
/// [SimulationBiometricService] is the test double used by every gate test;
/// [RealBiometricService] is exercised through a mocked `LocalAuthentication`
/// to lock in the fail-soft contract (any platform error resolves to `false`
/// so the user is never locked out of the PIN fallback).
///
/// Spec ref: `docs/spec/06-settings.md §App PIN` (biometric is opt-in and
/// substitutes for the App PIN when enabled).
library;

import 'package:flutter/services.dart' show PlatformException;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';

import 'package:guardianangela/services/biometric_service.dart';
import 'package:guardianangela/services/sim/biometric_service_sim.dart';

class _MockLocalAuthentication extends Mock implements LocalAuthentication {}

void main() {
  group('SimulationBiometricService', () {
    test(
      'isAvailable returns the configured value and records the call',
      () async {
        final sim = SimulationBiometricService(available: true);
        check(await sim.isAvailable()).isTrue();
        check(sim.calls).deepEquals(<String>['isAvailable']);
      },
    );

    test(
      'authenticate returns the configured value and records the call',
      () async {
        final sim = SimulationBiometricService(authenticateResult: true);
        check(await sim.authenticate(reason: 'unlock')).isTrue();
        check(sim.calls).deepEquals(<String>['authenticate']);
      },
    );

    test('defaults to no biometric and a declined prompt', () async {
      final sim = SimulationBiometricService();
      check(await sim.isAvailable()).isFalse();
      check(await sim.authenticate(reason: 'x')).isFalse();
    });
  });

  group('RealBiometricService.isAvailable', () {
    late _MockLocalAuthentication auth;
    late RealBiometricService service;

    setUp(() {
      auth = _MockLocalAuthentication();
      service = RealBiometricService(auth: auth);
    });

    test(
      'true when supported, checkable, and a biometric is enrolled',
      () async {
        when(() => auth.isDeviceSupported()).thenAnswer((_) async => true);
        when(() => auth.canCheckBiometrics).thenAnswer((_) async => true);
        when(
          auth.getAvailableBiometrics,
        ).thenAnswer((_) async => <BiometricType>[BiometricType.fingerprint]);
        check(await service.isAvailable()).isTrue();
      },
    );

    test('false when the device is not supported', () async {
      when(() => auth.isDeviceSupported()).thenAnswer((_) async => false);
      check(await service.isAvailable()).isFalse();
    });

    test('false when biometrics cannot be checked', () async {
      when(() => auth.isDeviceSupported()).thenAnswer((_) async => true);
      when(() => auth.canCheckBiometrics).thenAnswer((_) async => false);
      check(await service.isAvailable()).isFalse();
    });

    test('false when no biometric is enrolled', () async {
      when(() => auth.isDeviceSupported()).thenAnswer((_) async => true);
      when(() => auth.canCheckBiometrics).thenAnswer((_) async => true);
      when(
        auth.getAvailableBiometrics,
      ).thenAnswer((_) async => <BiometricType>[]);
      check(await service.isAvailable()).isFalse();
    });

    test('false (fail-soft) when the platform throws', () async {
      when(
        () => auth.isDeviceSupported(),
      ).thenThrow(PlatformException(code: 'err'));
      check(await service.isAvailable()).isFalse();
    });
  });

  group('RealBiometricService.authenticate', () {
    late _MockLocalAuthentication auth;
    late RealBiometricService service;

    setUp(() {
      auth = _MockLocalAuthentication();
      service = RealBiometricService(auth: auth);
    });

    void stubAuthenticate({required bool result}) {
      when(
        () => auth.authenticate(
          localizedReason: any(named: 'localizedReason'),
          biometricOnly: any(named: 'biometricOnly'),
          persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
        ),
      ).thenAnswer((_) async => result);
    }

    test('true when local_auth authenticates', () async {
      stubAuthenticate(result: true);
      check(await service.authenticate(reason: 'unlock')).isTrue();
    });

    test('false when local_auth declines', () async {
      stubAuthenticate(result: false);
      check(await service.authenticate(reason: 'unlock')).isFalse();
    });

    test('false (fail-soft) when authenticate throws', () async {
      when(
        () => auth.authenticate(
          localizedReason: any(named: 'localizedReason'),
          biometricOnly: any(named: 'biometricOnly'),
          persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
        ),
      ).thenThrow(PlatformException(code: 'lockout'));
      check(await service.authenticate(reason: 'unlock')).isFalse();
    });

    test(
      'requests a biometric-only, persistent prompt with the reason',
      () async {
        stubAuthenticate(result: true);
        await service.authenticate(reason: 'unlock');
        verify(
          () => auth.authenticate(
            localizedReason: 'unlock',
            biometricOnly: true,
            persistAcrossBackgrounding: true,
          ),
        ).called(1);
      },
    );
  });
}
