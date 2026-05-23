import 'dart:io';

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/repositories/user_profile_repository.dart';
import 'package:guardianangela/data/seed_data.dart';
import 'package:guardianangela/domain/models/user_profile.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('user_profile_repo_test_');
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  UserProfileRepository newRepo() => UserProfileRepository(
    keyProvider: () async =>
        '0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20',
    resolveDir: () async => tempDir,
  );

  group('UserProfileRepository', () {
    test('load returns an empty profile when no file exists', () async {
      check(await newRepo().load()).equals(SeedData.defaultUserProfile());
    });

    test('loadOrNull returns null when no file exists', () async {
      check(await newRepo().loadOrNull()).isNull();
    });

    test('round-trips an empty profile', () async {
      // Arrange
      final repo = newRepo();
      final empty = SeedData.defaultUserProfile();
      // Act
      await repo.save(empty);
      // Assert
      check(await repo.load()).equals(empty);
    });

    test(
      'round-trips a fully populated profile (all medical fields)',
      () async {
        // Arrange
        final repo = newRepo();
        const full = UserProfile(
          name: 'Alice Doe',
          age: 28,
          phoneNumber: '+15551234567',
          photoPath: '/data/photo.png',
          physicalDescription: '170cm, brown hair, blue jacket',
          bloodType: 'O+',
          allergies: 'Penicillin, peanuts',
          medications: 'Levothyroxine 50mcg daily',
          medicalConditions: 'Hypothyroidism',
          emergencyInstructions: 'Call my brother first: +15559999999',
        );
        // Act
        await repo.save(full);
        final loaded = await repo.load();
        // Assert
        check(loaded).equals(full);
        check(loaded.hasMedicalInfo).isTrue();
      },
    );

    test('delete removes the file and load falls back to default', () async {
      // Arrange
      final repo = newRepo();
      await repo.save(const UserProfile(name: 'Bob'));
      // Act
      await repo.delete();
      // Assert
      check(await repo.loadOrNull()).isNull();
      check(await repo.load()).equals(SeedData.defaultUserProfile());
    });
  });
}
