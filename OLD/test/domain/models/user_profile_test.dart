/// Unit tests for `UserProfile` — string fields, defaults null, round-trip.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/models/models.dart';

void main() {
  group('UserProfile', () {
    test('defaults all null', () {
      const p = UserProfile();
      check(p.name).isNull();
      check(p.age).isNull();
      check(p.phoneNumber).isNull();
      check(p.photoPath).isNull();
      check(p.physicalDescription).isNull();
      check(p.bloodType).isNull();
      check(p.allergies).isNull();
      check(p.medications).isNull();
      check(p.medicalConditions).isNull();
      check(p.emergencyInstructions).isNull();
    });

    test('hasMedicalInfo false when empty', () {
      const p = UserProfile();
      check(p.hasMedicalInfo).isFalse();
    });

    test('hasMedicalInfo true with bloodType', () {
      const p = UserProfile(bloodType: 'O+');
      check(p.hasMedicalInfo).isTrue();
    });

    test('hasMedicalInfo true with allergies', () {
      const p = UserProfile(allergies: 'peanut');
      check(p.hasMedicalInfo).isTrue();
    });

    test('hasMedicalInfo true with medications', () {
      const p = UserProfile(medications: 'aspirin');
      check(p.hasMedicalInfo).isTrue();
    });

    test('hasMedicalInfo true with conditions', () {
      const p = UserProfile(medicalConditions: 'asthma');
      check(p.hasMedicalInfo).isTrue();
    });

    test('hasMedicalInfo ignores blank instructions', () {
      const p = UserProfile(emergencyInstructions: '   ');
      check(p.hasMedicalInfo).isFalse();
    });

    test('hasMedicalInfo true with instructions text', () {
      const p = UserProfile(emergencyInstructions: 'Call husband');
      check(p.hasMedicalInfo).isTrue();
    });

    test('hasMedicalInfo ignores blank allergies', () {
      const p = UserProfile(allergies: '  ');
      check(p.hasMedicalInfo).isFalse();
    });

    test('round-trip (empty)', () {
      const p = UserProfile();
      check(UserProfile.fromJson(p.toJson())).equals(p);
    });

    test('round-trip (full)', () {
      const p = UserProfile(
        name: 'Alice',
        age: 30,
        phoneNumber: '+1234',
        photoPath: '/photos/a.jpg',
        physicalDescription: 'Brown hair, 170 cm',
        bloodType: 'O+',
        allergies: 'peanut, dust',
        medications: 'aspirin',
        medicalConditions: 'asthma',
        emergencyInstructions: 'Call husband',
      );
      check(UserProfile.fromJson(p.toJson())).equals(p);
    });

    test('copyWith', () {
      const p = UserProfile();
      check(p.copyWith(age: 30).age).equals(30);
    });

    test('copyWith replaces every field', () {
      const p = UserProfile();
      final p2 = p.copyWith(
        name: 'Alice',
        age: 30,
        phoneNumber: '+1',
        photoPath: '/p.jpg',
        physicalDescription: 'tall',
        bloodType: 'A-',
        allergies: 'x',
        medications: 'm',
        medicalConditions: 'c',
        emergencyInstructions: 'i',
      );
      check(p2.name).equals('Alice');
      check(p2.age).equals(30);
      check(p2.phoneNumber).equals('+1');
      check(p2.photoPath).equals('/p.jpg');
      check(p2.physicalDescription).equals('tall');
      check(p2.bloodType).equals('A-');
      check(p2.allergies).equals('x');
      check(p2.medications).equals('m');
      check(p2.medicalConditions).equals('c');
      check(p2.emergencyInstructions).equals('i');
    });

    test('equality identical', () {
      const p = UserProfile(name: 'A');
      check(p == p).isTrue();
    });

    test('equality cross-type unequal', () {
      // ignore: unrelated_type_equality_checks
      check(const UserProfile() == 'x').isFalse();
    });

    test('equal values equal', () {
      const a = UserProfile(name: 'A', allergies: 'x');
      const b = UserProfile(name: 'A', allergies: 'x');
      check(a).equals(b);
      check(a.hashCode).equals(b.hashCode);
    });

    test('differ by name unequal', () {
      const a = UserProfile(name: 'A');
      const b = UserProfile(name: 'B');
      check(a == b).isFalse();
    });

    test('differ by age unequal', () {
      check(const UserProfile(age: 1) == const UserProfile(age: 2)).isFalse();
    });

    test('differ by bloodType unequal', () {
      check(
        const UserProfile(bloodType: 'A') == const UserProfile(bloodType: 'B'),
      ).isFalse();
    });

    test('differ by allergies unequal', () {
      check(
        const UserProfile(allergies: 'a') == const UserProfile(allergies: 'b'),
      ).isFalse();
    });

    test('differ by medications unequal', () {
      check(
        const UserProfile(medications: 'a') ==
            const UserProfile(medications: 'b'),
      ).isFalse();
    });

    test('differ by medicalConditions unequal', () {
      check(
        const UserProfile(medicalConditions: 'a') ==
            const UserProfile(medicalConditions: 'b'),
      ).isFalse();
    });

    test('differ by emergencyInstructions unequal', () {
      check(
        const UserProfile(emergencyInstructions: 'a') ==
            const UserProfile(emergencyInstructions: 'b'),
      ).isFalse();
    });

    test('toString includes name', () {
      check(const UserProfile(name: 'Alice').toString()).contains('Alice');
    });
  });
}
