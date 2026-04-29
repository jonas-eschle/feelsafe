/// Additional coverage for [UserProfile.copyWith] — targets the `age`
/// field branch (line 79) which appears uncovered in the stale lcov.
/// The `copyWith` with all fields replaced should cover every field
/// explicitly.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/models/user_profile.dart';

void main() {
  group('UserProfile.copyWith all branches', () {
    test('copyWith(age: ...) covers the age field path (line 79)', () {
      const base = UserProfile(name: 'Alice');
      final updated = base.copyWith(age: 25);
      check(updated.age).equals(25);
      check(updated.name).equals('Alice');
    });

    test('copyWith with no args preserves all fields', () {
      const base = UserProfile(
        name: 'Bob',
        age: 30,
        bloodType: 'B+',
        allergies: ['dust'],
        medications: ['ibuprofen'],
        medicalConditions: ['hypertension'],
        emergencyInstructions: 'Call 911',
      );
      final copy = base.copyWith();
      check(copy.name).equals('Bob');
      check(copy.age).equals(30);
      check(copy.bloodType).equals('B+');
      check(copy.allergies).deepEquals(const ['dust']);
      check(copy.medications).deepEquals(const ['ibuprofen']);
      check(copy.medicalConditions).deepEquals(const ['hypertension']);
      check(copy.emergencyInstructions).equals('Call 911');
    });
  });
}
