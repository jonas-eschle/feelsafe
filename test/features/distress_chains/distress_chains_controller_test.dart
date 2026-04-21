/// Tests for [DistressChainsController] — CRUD plus the two safety
/// invariants: cannot save an empty chain (D-SAFETY-17) and cannot
/// delete the last remaining chain.
library;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/distress_chains/distress_chains_controller.dart';

import '../../helpers/test_helpers.dart';
import '../fake_repositories.dart';

ProviderContainer _makeContainer({List<DistressChain> seed = const []}) {
  final repo = FakeDistressChainsRepository(seed);
  return ProviderContainer(
    overrides: [distressChainsRepositoryProvider.overrideWithValue(repo)],
  );
}

void main() {
  group('DistressChainsController.build', () {
    test('returns empty list when nothing stored', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final list =
          await container.read(distressChainsControllerProvider.future);
      check(list).isEmpty();
    });

    test('hydrates persisted chains', () async {
      final container = _makeContainer(
        seed: [
          makeDistressChain(id: 'd1'),
          makeDistressChain(id: 'd2', name: 'Second'),
        ],
      );
      addTearDown(container.dispose);
      final list =
          await container.read(distressChainsControllerProvider.future);
      check(list.length).equals(2);
    });
  });

  group('DistressChainsController.save', () {
    test('persists a non-empty chain', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier =
          container.read(distressChainsControllerProvider.notifier);
      await container.read(distressChainsControllerProvider.future);
      await notifier.save(makeDistressChain(id: 'new'));
      final list = container.read(distressChainsControllerProvider).value!;
      check(list.length).equals(1);
    });

    test('rejects chain with empty steps (D-SAFETY-17)', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier =
          container.read(distressChainsControllerProvider.notifier);
      await container.read(distressChainsControllerProvider.future);
      await check(
        notifier.save(const DistressChain(id: 'x', name: 'X', steps: [])),
      ).throws<ArgumentError>();
    });

    test('overwrites chain on upsert', () async {
      final container = _makeContainer(
        seed: [makeDistressChain(id: 'd1', name: 'Old')],
      );
      addTearDown(container.dispose);
      final notifier =
          container.read(distressChainsControllerProvider.notifier);
      await container.read(distressChainsControllerProvider.future);
      await notifier.save(makeDistressChain(id: 'd1', name: 'New'));
      final list = container.read(distressChainsControllerProvider).value!;
      check(list.length).equals(1);
      check(list.single.name).equals('New');
    });
  });

  group('DistressChainsController.delete', () {
    test('refuses to delete the last remaining chain', () async {
      final container = _makeContainer(
        seed: [makeDistressChain(id: 'only')],
      );
      addTearDown(container.dispose);
      final notifier =
          container.read(distressChainsControllerProvider.notifier);
      await container.read(distressChainsControllerProvider.future);
      await check(notifier.delete('only')).throws<StateError>();
    });

    test('deletes when another chain remains', () async {
      final container = _makeContainer(
        seed: [
          makeDistressChain(id: 'a'),
          makeDistressChain(id: 'b', name: 'B'),
        ],
      );
      addTearDown(container.dispose);
      final notifier =
          container.read(distressChainsControllerProvider.notifier);
      await container.read(distressChainsControllerProvider.future);
      await notifier.delete('a');
      final list = container.read(distressChainsControllerProvider).value!;
      check(list.single.id).equals('b');
    });
  });

  group('DistressChainsController.reload', () {
    test('picks up external changes', () async {
      final repo = FakeDistressChainsRepository([
        makeDistressChain(id: 'a'),
      ]);
      final container = ProviderContainer(
        overrides: [
          distressChainsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      final notifier =
          container.read(distressChainsControllerProvider.notifier);
      await container.read(distressChainsControllerProvider.future);
      await repo.save(makeDistressChain(id: 'b'));
      await notifier.reload();
      final list = container.read(distressChainsControllerProvider).value!;
      check(list.length).equals(2);
    });
  });
}
