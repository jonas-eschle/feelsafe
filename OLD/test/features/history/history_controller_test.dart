/// Tests for [HistoryController] — read, delete, deleteAll, reload
/// against an in-memory session-log repository.
library;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/history/history_controller.dart';

import '../fake_repositories.dart';

SessionLog _log(String id) => SessionLog(
  id: id,
  modeId: 'mode-1',
  modeName: 'Walk',
  startedAt: DateTime(2025, 1, 1, 12),
  isSimulation: false,
);

ProviderContainer _makeContainer({List<SessionLog> seed = const []}) {
  final repo = FakeSessionLogsRepository(seed);
  return ProviderContainer(
    overrides: [sessionLogsRepositoryProvider.overrideWithValue(repo)],
  );
}

void main() {
  group('HistoryController.build', () {
    test('empty when no logs persisted', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final list = await container.read(historyControllerProvider.future);
      check(list).isEmpty();
    });

    test('hydrates persisted logs', () async {
      final container = _makeContainer(seed: [_log('a'), _log('b')]);
      addTearDown(container.dispose);
      final list = await container.read(historyControllerProvider.future);
      check(list.length).equals(2);
    });
  });

  group('HistoryController.delete', () {
    test('removes single log', () async {
      final container = _makeContainer(seed: [_log('a'), _log('b'), _log('c')]);
      addTearDown(container.dispose);
      final notifier = container.read(historyControllerProvider.notifier);
      await container.read(historyControllerProvider.future);
      await notifier.delete('b');
      final list = container.read(historyControllerProvider).value!;
      check(list.length).equals(2);
      check(list.any((l) => l.id == 'b')).isFalse();
    });

    test('delete unknown id is harmless', () async {
      final container = _makeContainer(seed: [_log('a')]);
      addTearDown(container.dispose);
      final notifier = container.read(historyControllerProvider.notifier);
      await container.read(historyControllerProvider.future);
      await notifier.delete('nope');
      final list = container.read(historyControllerProvider).value!;
      check(list.length).equals(1);
    });
  });

  group('HistoryController.deleteAll', () {
    test('clears the repository', () async {
      final container = _makeContainer(seed: [_log('a'), _log('b')]);
      addTearDown(container.dispose);
      final notifier = container.read(historyControllerProvider.notifier);
      await container.read(historyControllerProvider.future);
      await notifier.deleteAll();
      final list = container.read(historyControllerProvider).value!;
      check(list).isEmpty();
    });
  });

  group('HistoryController.reload', () {
    test('picks up newly-written logs', () async {
      final repo = FakeSessionLogsRepository([_log('a')]);
      final container = ProviderContainer(
        overrides: [sessionLogsRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      final notifier = container.read(historyControllerProvider.notifier);
      await container.read(historyControllerProvider.future);
      await repo.save(_log('b'));
      await notifier.reload();
      final list = container.read(historyControllerProvider).value!;
      check(list.length).equals(2);
    });
  });
}
