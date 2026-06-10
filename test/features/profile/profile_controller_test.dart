/// Unit tests for [ProfileController]'s real `patch` path.
///
/// The screen tests fake the controller; these drive the REAL one
/// against a round-tripping in-memory [UserProfileRepository], proving
/// `patch` persists exactly the supplied fields and republishes state.
///
/// Spec ref: `docs/spec/04-screens-navigation.md §Profile Editor`.
library;

import 'dart:io';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:test/test.dart';

import 'package:guardianangela/data/repositories/user_profile_repository.dart';
import 'package:guardianangela/domain/models/user_profile.dart';
import 'package:guardianangela/features/profile/profile_controller.dart';
import 'package:guardianangela/services/service_providers.dart';

/// In-memory [UserProfileRepository] that round-trips through save/load.
class _RoundTripProfileRepo extends UserProfileRepository {
  _RoundTripProfileRepo([UserProfile? initial])
    : _current = initial ?? const UserProfile(),
      super(
        keyProvider: () async =>
            '0102030405060708090a0b0c0d0e0f'
            '101112131415161718191a1b1c1d1e1f20',
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('profile_ctrl_test_'),
      );

  UserProfile _current;
  int saveCalls = 0;

  @override
  Future<UserProfile> load() async => _current;

  @override
  Future<void> save(UserProfile value) async {
    saveCalls++;
    _current = value;
  }
}

Future<ProviderContainer> _container(_RoundTripProfileRepo repo) async {
  final container = ProviderContainer(
    overrides: <Override>[
      userProfileRepositoryProvider.overrideWithValue(repo),
    ],
  );
  addTearDown(container.dispose);
  await container.read(profileControllerProvider.future);
  return container;
}

void main() {
  group('ProfileController', () {
    test('build() exposes the stored profile', () async {
      final repo = _RoundTripProfileRepo(
        const UserProfile(name: 'Alice', bloodType: 'O+'),
      );
      final container = await _container(repo);

      final state = await container.read(profileControllerProvider.future);
      check(state.profile.name).equals('Alice');
      check(state.profile.bloodType).equals('O+');
    });

    test('patch() persists the supplied fields and keeps the rest', () async {
      final repo = _RoundTripProfileRepo(
        const UserProfile(
          name: 'Alice',
          age: 30,
          phoneNumber: '+15550100',
          physicalDescription: 'Tall, red hair',
          bloodType: 'O+',
          allergies: 'Peanuts',
          medications: 'Ibuprofen',
          medicalConditions: 'Asthma',
          emergencyInstructions: 'Call Bob first',
        ),
      );
      final container = await _container(repo);

      await container
          .read(profileControllerProvider.notifier)
          .patch(name: 'Beatrice', age: 31, allergies: 'None');

      // Persisted: patched fields changed, untouched fields preserved —
      // emergency responders must never see a partially wiped profile.
      check(repo.saveCalls).equals(1);
      final saved = await repo.load();
      check(saved.name).equals('Beatrice');
      check(saved.age).equals(31);
      check(saved.allergies).equals('None');
      check(saved.phoneNumber).equals('+15550100');
      check(saved.physicalDescription).equals('Tall, red hair');
      check(saved.bloodType).equals('O+');
      check(saved.medications).equals('Ibuprofen');
      check(saved.medicalConditions).equals('Asthma');
      check(saved.emergencyInstructions).equals('Call Bob first');
    });

    test('patch() republishes the updated state without a reload', () async {
      final repo = _RoundTripProfileRepo(const UserProfile(name: 'Alice'));
      final container = await _container(repo);

      await container
          .read(profileControllerProvider.notifier)
          .patch(physicalDescription: 'Buzz cut');

      final state = container.read(profileControllerProvider).value;
      check(state).isNotNull();
      check(state!.profile.physicalDescription).equals('Buzz cut');
      check(state.profile.name).equals('Alice');
    });
  });
}
