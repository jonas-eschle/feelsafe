/// Tests for [FakeBiometricService].
///
/// Verifies default values, scripted `isAvailable`/`authenticate`
/// results, the prompts recording list, and mutable control fields.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/services/fakes/fake_biometric_service.dart';
import 'package:guardianangela/services/protocols/biometric_service_protocol.dart';

void main() {
  group('FakeBiometricService defaults', () {
    test('available defaults to false', () async {
      // Arrange & Act
      final s = FakeBiometricService();
      // Assert
      check(await s.isAvailable()).isFalse();
    });

    test('nextResult defaults to BiometricResult.unavailable', () async {
      // Arrange & Act
      final s = FakeBiometricService();
      // Assert
      final result = await s.authenticate(reason: 'test');
      check(result).equals(BiometricResult.unavailable);
    });

    test('prompts list starts empty', () {
      final s = FakeBiometricService();
      check(s.prompts).isEmpty();
    });
  });

  group('FakeBiometricService.isAvailable', () {
    test('returns true when available=true', () async {
      final s = FakeBiometricService(available: true);
      check(await s.isAvailable()).isTrue();
    });

    test('returns false when available=false', () async {
      final s = FakeBiometricService(available: false);
      check(await s.isAvailable()).isFalse();
    });

    test('mutable available field can be toggled', () async {
      final s = FakeBiometricService(available: false);
      check(await s.isAvailable()).isFalse();
      s.available = true;
      check(await s.isAvailable()).isTrue();
    });
  });

  group('FakeBiometricService.authenticate', () {
    test('returns BiometricResult.success when scripted', () async {
      // Arrange
      final s = FakeBiometricService(nextResult: BiometricResult.success);
      // Act
      final result = await s.authenticate(reason: 'unlock');
      // Assert
      check(result).equals(BiometricResult.success);
    });

    test('returns BiometricResult.cancelled when scripted', () async {
      final s = FakeBiometricService(nextResult: BiometricResult.cancelled);
      final result = await s.authenticate(reason: 'cancel-test');
      check(result).equals(BiometricResult.cancelled);
    });

    test('records the reason string in prompts', () async {
      // Arrange
      final s = FakeBiometricService();
      // Act
      await s.authenticate(reason: 'Please verify your identity');
      // Assert
      check(s.prompts).deepEquals(['Please verify your identity']);
    });

    test('prompts accumulates across multiple calls', () async {
      // Arrange
      final s = FakeBiometricService();
      // Act
      await s.authenticate(reason: 'first');
      await s.authenticate(reason: 'second');
      // Assert
      check(s.prompts).deepEquals(['first', 'second']);
    });

    test('nextResult can be updated between calls', () async {
      // Arrange
      final s = FakeBiometricService(nextResult: BiometricResult.success);
      check(await s.authenticate(reason: 'r1')).equals(BiometricResult.success);
      // Update
      s.nextResult = BiometricResult.cancelled;
      // Assert — new result takes effect immediately.
      check(
        await s.authenticate(reason: 'r2'),
      ).equals(BiometricResult.cancelled);
    });
  });
}
