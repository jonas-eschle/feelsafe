/// Unit tests for `UserProfile` — list fields default empty, round-trip.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/models/models.dart';

void main() {
  group('UserProfile', () {
    test('defaults all empty', () {
      const p = UserProfile();
      check(p.name).isNull();
      check(p.age).isNull();
      check(p.bloodType).isNull();
      check(p.allergies).isEmpty();
      check(p.medications).isEmpty();
      check(p.medicalConditions).isEmpty();
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
      const p = UserProfile(allergies: ['peanut']);
      check(p.hasMedicalInfo).isTrue();
    });

    test('hasMedicalInfo true with medications', () {
      const p = UserProfile(medications: ['aspirin']);
      check(p.hasMedicalInfo).isTrue();
    });

    test('hasMedicalInfo true with conditions', () {
      const p = UserProfile(medicalConditions: ['asthma']);
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

    test('round-trip (empty)', () {
      const p = UserProfile();
      check(UserProfile.fromJson(p.toJson())).equals(p);
    });

    test('round-trip (full)', () {
      const p = UserProfile(
        name: 'Alice',
        age: 30,
        bloodType: 'O+',
        allergies: ['peanut', 'dust'],
        medications: ['aspirin'],
        medicalConditions: ['asthma'],
        emergencyInstructions: 'Call husband',
      );
      check(UserProfile.fromJson(p.toJson())).equals(p);
    });

    test('copyWith', () {
      const p = UserProfile();
      check(p.copyWith(age: 30).age).equals(30);
    });
  });
}
