// Unit tests for [UserProfile].
//
// Verifies constructor defaults (all-null), JSON round-trip, copyWith
// behaviour, equality / hashCode contract, and [UserProfile.hasMedicalInfo]
// semantics per docs/spec/03-data-models.md §UserProfile and Q15 / Q22.

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/models/user_profile.dart';

void main() {
  group('UserProfile', () {
    group('defaults', () {
      test('all fields default to null', () {
        // Arrange + Act
        const profile = UserProfile();

        // Assert
        check(profile.name).isNull();
        check(profile.age).isNull();
        check(profile.phoneNumber).isNull();
        check(profile.photoPath).isNull();
        check(profile.physicalDescription).isNull();
        check(profile.bloodType).isNull();
        check(profile.allergies).isNull();
        check(profile.medications).isNull();
        check(profile.medicalConditions).isNull();
        check(profile.emergencyInstructions).isNull();
      });

      test('values are stored unchanged when provided', () {
        // Arrange + Act
        const profile = UserProfile(
          name: 'Alice',
          age: 28,
          phoneNumber: '+15551234567',
          photoPath: 'documents/profile.jpg',
          physicalDescription: '175cm, brown hair',
          bloodType: 'O+',
          allergies: 'Peanuts',
          medications: 'Aspirin',
          medicalConditions: 'Asthma',
          emergencyInstructions: 'Inhaler in left pocket',
        );

        // Assert
        check(profile.name).equals('Alice');
        check(profile.age).equals(28);
        check(profile.phoneNumber).equals('+15551234567');
        check(profile.photoPath).equals('documents/profile.jpg');
        check(profile.physicalDescription).equals('175cm, brown hair');
        check(profile.bloodType).equals('O+');
        check(profile.allergies).equals('Peanuts');
        check(profile.medications).equals('Aspirin');
        check(profile.medicalConditions).equals('Asthma');
        check(profile.emergencyInstructions).equals('Inhaler in left pocket');
      });
    });

    group('hasMedicalInfo', () {
      test('returns false when all medical fields are null', () {
        // Arrange + Act
        const profile = UserProfile(name: 'Alice', age: 30);

        // Assert
        check(profile.hasMedicalInfo).isFalse();
      });

      test('returns true when bloodType is non-null', () {
        // Arrange + Act
        const profile = UserProfile(bloodType: 'A-');

        // Assert
        check(profile.hasMedicalInfo).isTrue();
      });

      test('returns true when allergies is non-null', () {
        // Arrange + Act
        const profile = UserProfile(allergies: 'Bees');

        // Assert
        check(profile.hasMedicalInfo).isTrue();
      });

      test('returns true when medications is non-null', () {
        // Arrange + Act
        const profile = UserProfile(medications: 'Insulin');

        // Assert
        check(profile.hasMedicalInfo).isTrue();
      });

      test('returns true when medicalConditions is non-null', () {
        // Arrange + Act
        const profile = UserProfile(medicalConditions: 'Diabetes');

        // Assert
        check(profile.hasMedicalInfo).isTrue();
      });

      test('returns true when emergencyInstructions is non-null', () {
        // Arrange + Act
        const profile = UserProfile(emergencyInstructions: 'Call sister first');

        // Assert
        check(profile.hasMedicalInfo).isTrue();
      });

      test('returns false when only non-medical fields are set', () {
        // Identity fields (name, age, phone, photo, physical description)
        // do not count as medical info per spec 03 §UserProfile.
        // Arrange + Act
        const profile = UserProfile(
          name: 'Alice',
          age: 28,
          phoneNumber: '+15551234567',
          photoPath: 'p.jpg',
          physicalDescription: '175cm',
        );

        // Assert
        check(profile.hasMedicalInfo).isFalse();
      });

      test('returns true when any one medical field carries content', () {
        // Arrange + Act
        const profile = UserProfile(
          name: 'Alice',
          medicalConditions: 'Migraines',
        );

        // Assert
        check(profile.hasMedicalInfo).isTrue();
      });

      test('returns true even with empty string (non-null counts)', () {
        // The getter checks `!= null`, so even an empty string returns true.
        // This codifies current lib behaviour per spec 03 §UserProfile.
        // Arrange + Act
        const profile = UserProfile(bloodType: '');

        // Assert
        check(profile.hasMedicalInfo).isTrue();
      });
    });

    group('JSON round-trip', () {
      test('toJson omits null fields entirely', () {
        // Arrange
        const profile = UserProfile();

        // Act
        final json = profile.toJson();

        // Assert — empty profile produces empty map.
        check(json).isEmpty();
      });

      test('toJson includes only non-null fields', () {
        // Arrange
        const profile = UserProfile(name: 'Alice', allergies: 'Latex');

        // Act
        final json = profile.toJson();

        // Assert
        check(json).containsKey('name');
        check(json).containsKey('allergies');
        check(json.containsKey('age')).isFalse();
        check(json.containsKey('bloodType')).isFalse();
      });

      test('fromJson(toJson) round-trips empty profile', () {
        // Arrange
        const original = UserProfile();

        // Act
        final restored = UserProfile.fromJson(original.toJson());

        // Assert
        check(restored).equals(original);
      });

      test('fromJson(toJson) round-trips fully populated profile', () {
        // Arrange
        const original = UserProfile(
          name: 'Bob',
          age: 45,
          phoneNumber: '+447700900000',
          photoPath: '/data/p.jpg',
          physicalDescription: 'Tall, beard',
          bloodType: 'B+',
          allergies: 'Penicillin',
          medications: 'Statins',
          medicalConditions: 'Hypertension',
          emergencyInstructions: 'Refer to my GP',
        );

        // Act
        final restored = UserProfile.fromJson(original.toJson());

        // Assert
        check(restored).equals(original);
      });

      test('fromJson preserves null medical fields when subset is set', () {
        // Arrange
        const original = UserProfile(name: 'Alice');

        // Act
        final restored = UserProfile.fromJson(original.toJson());

        // Assert
        check(restored.name).equals('Alice');
        check(restored.bloodType).isNull();
        check(restored.allergies).isNull();
        check(restored.medications).isNull();
        check(restored.medicalConditions).isNull();
        check(restored.emergencyInstructions).isNull();
      });

      test('fromJson handles age encoded as double', () {
        // Arrange — some JSON encoders return num.
        final json = <String, dynamic>{'age': 30.0};

        // Act
        final profile = UserProfile.fromJson(json);

        // Assert
        check(profile.age).equals(30);
      });

      test('fromJson treats absent age as null', () {
        // Arrange + Act
        final profile = UserProfile.fromJson(const <String, dynamic>{});

        // Assert
        check(profile.age).isNull();
      });

      test('round-trip preserves hasMedicalInfo getter result', () {
        // Arrange
        const original = UserProfile(allergies: 'Wasps');

        // Act
        final restored = UserProfile.fromJson(original.toJson());

        // Assert
        check(restored.hasMedicalInfo).equals(original.hasMedicalInfo);
        check(restored.hasMedicalInfo).isTrue();
      });
    });

    group('copyWith', () {
      test('with no arguments returns equal object', () {
        // Arrange
        const base = UserProfile(name: 'Alice', age: 30);

        // Act
        final copy = base.copyWith();

        // Assert
        check(copy).equals(base);
      });

      test('replaces name only', () {
        // Arrange
        const base = UserProfile(name: 'Alice');

        // Act
        final next = base.copyWith(name: 'Bob');

        // Assert
        check(next.name).equals('Bob');
      });

      test('replaces age only', () {
        // Arrange
        const base = UserProfile(age: 20);

        // Act
        final next = base.copyWith(age: 35);

        // Assert
        check(next.age).equals(35);
      });

      test('replaces phoneNumber only', () {
        // Arrange
        const base = UserProfile();

        // Act
        final next = base.copyWith(phoneNumber: '+15555550000');

        // Assert
        check(next.phoneNumber).equals('+15555550000');
        check(next.name).isNull();
      });

      test('replaces photoPath only', () {
        // Arrange
        const base = UserProfile();

        // Act
        final next = base.copyWith(photoPath: '/tmp/p.jpg');

        // Assert
        check(next.photoPath).equals('/tmp/p.jpg');
      });

      test('replaces physicalDescription only', () {
        // Arrange
        const base = UserProfile();

        // Act
        final next = base.copyWith(physicalDescription: '180cm');

        // Assert
        check(next.physicalDescription).equals('180cm');
      });

      test('replaces bloodType only', () {
        // Arrange
        const base = UserProfile();

        // Act
        final next = base.copyWith(bloodType: 'AB+');

        // Assert
        check(next.bloodType).equals('AB+');
      });

      test('replaces allergies only', () {
        // Arrange
        const base = UserProfile();

        // Act
        final next = base.copyWith(allergies: 'Shellfish');

        // Assert
        check(next.allergies).equals('Shellfish');
      });

      test('replaces medications only', () {
        // Arrange
        const base = UserProfile();

        // Act
        final next = base.copyWith(medications: 'Aspirin');

        // Assert
        check(next.medications).equals('Aspirin');
      });

      test('replaces medicalConditions only', () {
        // Arrange
        const base = UserProfile();

        // Act
        final next = base.copyWith(medicalConditions: 'Asthma');

        // Assert
        check(next.medicalConditions).equals('Asthma');
      });

      test('replaces emergencyInstructions only', () {
        // Arrange
        const base = UserProfile();

        // Act
        final next = base.copyWith(emergencyInstructions: 'See note');

        // Assert
        check(next.emergencyInstructions).equals('See note');
      });

      test('replaces all fields together', () {
        // Arrange
        const base = UserProfile();

        // Act
        final next = base.copyWith(
          name: 'C',
          age: 18,
          phoneNumber: '+1',
          photoPath: 'p',
          physicalDescription: 'd',
          bloodType: 'O-',
          allergies: 'a',
          medications: 'm',
          medicalConditions: 'mc',
          emergencyInstructions: 'ei',
        );

        // Assert
        check(next.name).equals('C');
        check(next.age).equals(18);
        check(next.phoneNumber).equals('+1');
        check(next.photoPath).equals('p');
        check(next.physicalDescription).equals('d');
        check(next.bloodType).equals('O-');
        check(next.allergies).equals('a');
        check(next.medications).equals('m');
        check(next.medicalConditions).equals('mc');
        check(next.emergencyInstructions).equals('ei');
      });
    });

    group('equality + hashCode', () {
      test('two identically-constructed profiles are equal', () {
        // Arrange
        const a = UserProfile(name: 'X');
        const b = UserProfile(name: 'X');

        // Act + Assert
        check(a).equals(b);
        check(a.hashCode).equals(b.hashCode);
      });

      test('equality is reflexive', () {
        // Arrange
        const profile = UserProfile(name: 'A');

        // Act + Assert
        check(profile).equals(profile);
      });

      test('two empty profiles are equal', () {
        // Arrange
        const a = UserProfile();
        const b = UserProfile();

        // Assert
        check(a).equals(b);
        check(a.hashCode).equals(b.hashCode);
      });

      test('equality is symmetric and transitive', () {
        // Arrange
        const a = UserProfile(name: 'X', age: 20);
        const b = UserProfile(name: 'X', age: 20);
        const c = UserProfile(name: 'X', age: 20);

        // Assert
        check(a == b).isTrue();
        check(b == a).isTrue();
        check(b == c).isTrue();
        check(a == c).isTrue();
      });

      test('different name breaks equality', () {
        // Arrange
        const a = UserProfile(name: 'A');
        const b = UserProfile(name: 'B');

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different age breaks equality', () {
        // Arrange
        const a = UserProfile(age: 20);
        const b = UserProfile(age: 21);

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different phoneNumber breaks equality', () {
        // Arrange
        const a = UserProfile(phoneNumber: '+1');
        const b = UserProfile(phoneNumber: '+2');

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different photoPath breaks equality', () {
        // Arrange
        const a = UserProfile(photoPath: 'a');
        const b = UserProfile(photoPath: 'b');

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different physicalDescription breaks equality', () {
        // Arrange
        const a = UserProfile(physicalDescription: 'tall');
        const b = UserProfile(physicalDescription: 'short');

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different bloodType breaks equality', () {
        // Arrange
        const a = UserProfile(bloodType: 'O+');
        const b = UserProfile(bloodType: 'O-');

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different allergies breaks equality', () {
        // Arrange
        const a = UserProfile(allergies: 'X');
        const b = UserProfile(allergies: 'Y');

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different medications breaks equality', () {
        // Arrange
        const a = UserProfile(medications: 'X');
        const b = UserProfile(medications: 'Y');

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different medicalConditions breaks equality', () {
        // Arrange
        const a = UserProfile(medicalConditions: 'X');
        const b = UserProfile(medicalConditions: 'Y');

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different emergencyInstructions breaks equality', () {
        // Arrange
        const a = UserProfile(emergencyInstructions: 'X');
        const b = UserProfile(emergencyInstructions: 'Y');

        // Act + Assert
        check(a == b).isFalse();
      });

      test('null vs non-null on a single field breaks equality', () {
        // Arrange
        const a = UserProfile();
        const b = UserProfile(name: '');

        // Act + Assert
        check(a == b).isFalse();
      });

      test('not equal to object of different type', () {
        // Arrange
        const profile = UserProfile();

        // Act + Assert
        check(profile == const Object()).isFalse();
      });
    });
  });
}
