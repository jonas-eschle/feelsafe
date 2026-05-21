/// Tests for [DistressModesController].
///
/// Covers build (filters to isDistressMode=true), save (flags mode,
/// rejects empty chain), delete, and reload.
library;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/features/distress_modes/distress_modes_controller.dart';

import '../../features/fake_repositories.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('DistressModesController', () {
    FakeModesRepository makeRepo({
      bool includeDistress = false,
      bool includeRegular = false,
    }) {
      final modes = <dynamic>[];
      if (includeRegular) modes.add(makeMode(id: 'r1', name: 'Regular'));
      if (includeDistress) {
        modes.add(makeDistressMode(id: 'd1', name: 'Distress'));
      }
      return FakeModesRepository(List.from(modes));
    }

    ProviderContainer makeContainer(FakeModesRepository repo) {
      final container = ProviderContainer(
        overrides: [modesRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('build returns only distress-flagged modes', () async {
      final repo = makeRepo(includeDistress: true, includeRegular: true);
      final container = makeContainer(repo);
      final modes = await container.read(
        distressModesControllerProvider.future,
      );
      check(modes.length).equals(1);
      check(modes.first.id).equals('d1');
      check(modes.first.isDistressMode).isTrue();
    });

    test('build returns empty list when no distress modes exist', () async {
      final repo = makeRepo(includeRegular: true);
      final container = makeContainer(repo);
      final modes = await container.read(
        distressModesControllerProvider.future,
      );
      check(modes).isEmpty();
    });

    test('save persists a mode with isDistressMode forced to true', () async {
      final repo = makeRepo();
      final container = makeContainer(repo);

      // Build controller first.
      await container.read(distressModesControllerProvider.future);

      final notifier = container.read(distressModesControllerProvider.notifier);

      // Pass a regular mode — controller must flag it as distress.
      final mode = makeMode(
        id: 'new',
        name: 'New',
      ).copyWith(chainSteps: [smsStep()]);
      await notifier.save(mode);

      final saved = await repo.getById('new');
      check(saved).isNotNull();
      check(saved!.isDistressMode).isTrue();

      final state = await container.read(
        distressModesControllerProvider.future,
      );
      check(state.any((m) => m.id == 'new')).isTrue();
    });

    test('save does not double-flag a mode already isDistressMode', () async {
      final repo = makeRepo();
      final container = makeContainer(repo);
      await container.read(distressModesControllerProvider.future);

      final notifier = container.read(distressModesControllerProvider.notifier);
      final mode = makeDistressMode(id: 'dm', name: 'DM');
      await notifier.save(mode);

      final saved = await repo.getById('dm');
      check(saved!.isDistressMode).isTrue();
    });

    test('save throws ArgumentError when chain is empty', () async {
      final repo = makeRepo();
      final container = makeContainer(repo);
      await container.read(distressModesControllerProvider.future);

      final notifier = container.read(distressModesControllerProvider.notifier);
      // makeMode defaults to one holdStep; clear it.
      final emptyMode = makeMode(id: 'bad', name: 'Bad', steps: []);
      await check(notifier.save(emptyMode)).throws<ArgumentError>();
    });

    test('delete removes the mode and updates state', () async {
      final repo = FakeModesRepository([
        makeDistressMode(id: 'd1', name: 'D1'),
        makeDistressMode(id: 'd2', name: 'D2'),
      ]);
      final container = makeContainer(repo);
      await container.read(distressModesControllerProvider.future);

      final notifier = container.read(distressModesControllerProvider.notifier);
      await notifier.delete('d1');

      final state = await container.read(
        distressModesControllerProvider.future,
      );
      check(state.map((m) => m.id).toList()).not((it) => it.contains('d1'));
      check(state.any((m) => m.id == 'd2')).isTrue();
    });

    test('reload refreshes state from the repository', () async {
      final repo = makeRepo(includeDistress: true);
      final container = makeContainer(repo);

      // Prime state.
      await container.read(distressModesControllerProvider.future);

      // Inject a new distress mode directly into the fake repo.
      await repo.save(makeDistressMode(id: 'd2', name: 'D2'));

      // Reload should pick it up.
      final notifier = container.read(distressModesControllerProvider.notifier);
      await notifier.reload();

      final state = await container.read(
        distressModesControllerProvider.future,
      );
      check(state.length).equals(2);
    });
  });
}
