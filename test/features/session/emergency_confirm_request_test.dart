/// Tests for [EmergencyConfirmRequest] value-type semantics.
///
/// Spec 04 §EmergencyCallConfirmationScreen.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/features/session/emergency_confirm_request.dart';

void main() {
  group('EmergencyConfirmRequest equality', () {
    test('same number + duration are equal', () {
      // Arrange
      const a = EmergencyConfirmRequest(number: '112', durationSeconds: 5);
      const b = EmergencyConfirmRequest(number: '112', durationSeconds: 5);
      // Assert
      check(a).equals(b);
    });

    test('different number → not equal', () {
      const a = EmergencyConfirmRequest(number: '112', durationSeconds: 5);
      const b = EmergencyConfirmRequest(number: '911', durationSeconds: 5);
      check(a).not((m) => m.equals(b));
    });

    test('different durationSeconds → not equal', () {
      const a = EmergencyConfirmRequest(number: '112', durationSeconds: 5);
      const b = EmergencyConfirmRequest(number: '112', durationSeconds: 10);
      check(a).not((m) => m.equals(b));
    });
  });

  group('EmergencyConfirmRequest hashCode', () {
    test('equal objects have equal hashCode', () {
      const a = EmergencyConfirmRequest(number: '112', durationSeconds: 5);
      const b = EmergencyConfirmRequest(number: '112', durationSeconds: 5);
      check(a.hashCode).equals(b.hashCode);
    });

    test('different objects typically have different hashCodes', () {
      const a = EmergencyConfirmRequest(number: '112', durationSeconds: 5);
      const b = EmergencyConfirmRequest(number: '999', durationSeconds: 30);
      // This is a probabilistic check — collisions are theoretically
      // possible, but the Object.hash implementation makes this
      // practically reliable in a unit test.
      check(a.hashCode).not((m) => m.equals(b.hashCode));
    });
  });

  group('EmergencyConfirmRequest toString', () {
    test('includes number', () {
      const r = EmergencyConfirmRequest(number: '112', durationSeconds: 7);
      check(r.toString()).contains('112');
    });

    test('includes durationSeconds', () {
      const r = EmergencyConfirmRequest(number: '112', durationSeconds: 7);
      check(r.toString()).contains('7');
    });
  });
}
