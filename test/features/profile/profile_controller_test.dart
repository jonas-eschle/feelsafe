/// Tests for [ProfileController] — singleton hydrate, save, reload.
library;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/profile/profile_controller.dart';

import '../fake_repositories.dart';

ProviderContainer _makeContainer({UserProfile? seed}) {
  final repo = FakeUserProfileRepository(seed);
  return ProviderContainer(
    overrides: [userProfileRepositoryProvider.overrideWithValue(repo)],
  );
}

void main() {
  group('ProfileController.build', () {
    test('returns null when no profile stored', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final profile = await container.read(profileControllerProvider.future);
      check(profile).isNull();
    });

    test('hydrates persisted profile', () async {
      final seed = const UserProfile(name: 'Alice', age: 30);
      final container = _makeContainer(seed: seed);
      addTearDown(container.dispose);
      final profile = await container.read(profileControllerProvider.future);
      check(profile).isNotNull();
      check(profile!.name).equals('Alice');
      check(profile.age).equals(30);
    });
  });

  group('ProfileController.save', () {
    test('persists the profile and updates state', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(profileControllerProvider.notifier);
      await container.read(profileControllerProvider.future);
      await notifier.save(const UserProfile(name: 'Bob'));
      final profile = container.read(profileControllerProvider).value;
      check(profile).isNotNull();
      check(profile!.name).equals('Bob');
    });

    test('save overwrites existing profile', () async {
      final container = _makeContainer(
        seed: const UserProfile(name: 'Old'),
      );
      addTearDown(container.dispose);
      final notifier = container.read(profileControllerProvider.notifier);
      await container.read(profileControllerProvider.future);
      await notifier.save(const UserProfile(name: 'New'));
      final profile = container.read(profileControllerProvider).value;
      check(profile!.name).equals('New');
    });
  });

  group('ProfileController.reload', () {
    test('re-reads repository', () async {
      final repo = FakeUserProfileRepository();
      final container = ProviderContainer(
        overrides: [userProfileRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      final notifier = container.read(profileControllerProvider.notifier);
      await container.read(profileControllerProvider.future);
      await repo.save(const UserProfile(name: 'Carol'));
      await notifier.reload();
      final profile = container.read(profileControllerProvider).value;
      check(profile!.name).equals('Carol');
    });
  });
}
