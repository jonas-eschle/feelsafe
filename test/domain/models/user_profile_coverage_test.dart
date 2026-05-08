/// Additional coverage for [UserProfile.copyWith] — exercises all fields.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/models/user_profile.dart';

void main() {
  group('UserProfile.copyWith all branches', () {
    test('copyWith(age: ...) covers the age field path', () {
      const base = UserProfile(name: 'Alice');
      final updated = base.copyWith(age: 25);
      check(updated.age).equals(25);
      check(updated.name).equals('Alice');
    });

    test('copyWith with no args preserves all fields', () {
      const base = UserProfile(
        name: 'Bob',
        age: 30,
        phoneNumber: '+49123',
        photoPath: '/img.jpg',
        physicalDescription: 'Tall, blonde',
        bloodType: 'B+',
        allergies: 'dust',
        medications: 'ibuprofen',
        medicalConditions: 'hypertension',
        emergencyInstructions: 'Call 911',
      );
      final copy = base.copyWith();
      check(copy.name).equals('Bob');
      check(copy.age).equals(30);
      check(copy.phoneNumber).equals('+49123');
      check(copy.photoPath).equals('/img.jpg');
      check(copy.physicalDescription).equals('Tall, blonde');
      check(copy.bloodType).equals('B+');
      check(copy.allergies).equals('dust');
      check(copy.medications).equals('ibuprofen');
      check(copy.medicalConditions).equals('hypertension');
      check(copy.emergencyInstructions).equals('Call 911');
    });
  });
}
