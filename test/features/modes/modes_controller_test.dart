/// Tests for [ModesController] — CRUD happy paths, reorder, and
/// reload semantics against an in-memory fake repository.
library;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/modes/modes_controller.dart';

import '../../helpers/test_helpers.dart';
import '../fake_repositories.dart';

ProviderContainer _makeContainer({List<SessionMode> seed = const []}) {
  final repo = FakeModesRepository(seed);
  return ProviderContainer(
    overrides: [modesRepositoryProvider.overrideWithValue(repo)],
  );
}

void main() {
  group('ModesController.build', () {
    test('returns empty list when none stored', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final list = await container.read(modesControllerProvider.future);
      check(list).isEmpty();
    });

    test('hydrates persisted modes', () async {
      final container = _makeContainer(
        seed: [
          makeMode(id: 'm1', name: 'One'),
          makeMode(id: 'm2', name: 'Two'),
        ],
      );
      addTearDown(container.dispose);
      final list = await container.read(modesControllerProvider.future);
      check(list.length).equals(2);
    });
  });

  group('ModesController.save', () {
    test('inserts a new mode', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(modesControllerProvider.notifier);
      await container.read(modesControllerProvider.future);
      await notifier.save(makeMode(id: 'm-new', name: 'New'));
      final list = container.read(modesControllerProvider).value!;
      check(list.length).equals(1);
      check(list.single.id).equals('m-new');
    });

    test('updates an existing mode in place', () async {
      final container = _makeContainer(
        seed: [makeMode(id: 'm1', name: 'Old')],
      );
      addTearDown(container.dispose);
      final notifier = container.read(modesControllerProvider.notifier);
      await container.read(modesControllerProvider.future);
      await notifier.save(makeMode(id: 'm1', name: 'Renamed'));
      final list = container.read(modesControllerProvider).value!;
      check(list.length).equals(1);
      check(list.single.name).equals('Renamed');
    });
  });

  group('ModesController.delete', () {
    test('drops mode by id', () async {
      final container = _makeContainer(
        seed: [
          makeMode(id: 'a', name: 'A'),
          makeMode(id: 'b', name: 'B'),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(modesControllerProvider.notifier);
      await container.read(modesControllerProvider.future);
      await notifier.delete('a');
      final list = container.read(modesControllerProvider).value!;
      check(list.length).equals(1);
      check(list.single.id).equals('b');
    });
  });

  group('ModesController.reorder', () {
    test('persists new order via saveAll', () async {
      final container = _makeContainer(
        seed: [
          makeMode(id: 'a', name: 'A'),
          makeMode(id: 'b', name: 'B'),
          makeMode(id: 'c', name: 'C'),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(modesControllerProvider.notifier);
      await container.read(modesControllerProvider.future);
      await notifier.reorder(0, 3);
      final list = container.read(modesControllerProvider).value!;
      check(list.map((m) => m.id).toList()).deepEquals(['b', 'c', 'a']);
    });

    test('throws RangeError on negative oldIndex', () async {
      final container = _makeContainer(
        seed: [makeMode(id: 'a')],
      );
      addTearDown(container.dispose);
      final notifier = container.read(modesControllerProvider.notifier);
      await container.read(modesControllerProvider.future);
      await check(notifier.reorder(-1, 0)).throws<RangeError>();
    });

    test('throws RangeError on oldIndex >= length', () async {
      final container = _makeContainer(
        seed: [makeMode(id: 'a')],
      );
      addTearDown(container.dispose);
      final notifier = container.read(modesControllerProvider.notifier);
      await container.read(modesControllerProvider.future);
      await check(notifier.reorder(1, 0)).throws<RangeError>();
    });
  });

  group('ModesController.reload', () {
    test('resets to loading then re-reads', () async {
      final repo = FakeModesRepository([makeMode(id: 'a')]);
      final container = ProviderContainer(
        overrides: [modesRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      final notifier = container.read(modesControllerProvider.notifier);
      await container.read(modesControllerProvider.future);
      await repo.save(makeMode(id: 'b'));
      await notifier.reload();
      final list = container.read(modesControllerProvider).value!;
      check(list.length).equals(2);
    });
  });
}
