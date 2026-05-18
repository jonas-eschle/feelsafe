/// History-feature controller.
///
/// Exposes every persisted [SessionLog], newest-first. The list is
/// read-only; session logs are written by the session pipeline and
/// only ever deleted explicitly by the user.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';

/// Async controller exposing the list of completed session logs.
class HistoryController extends AsyncNotifier<List<SessionLog>> {
  @override
  Future<List<SessionLog>> build() async {
    final repo = ref.read(sessionLogsRepositoryProvider);
    return repo.getAll();
  }

  /// Forces a reload from the repository.
  Future<void> reload() async {
    state = const AsyncValue.loading();
    final repo = ref.read(sessionLogsRepositoryProvider);
    state = AsyncValue.data(await repo.getAll());
  }

  /// Deletes the session log with [id] and refreshes [state].
  Future<void> delete(String id) async {
    final repo = ref.read(sessionLogsRepositoryProvider);
    await repo.delete(id);
    state = AsyncValue.data(await repo.getAll());
  }

  /// Deletes every persisted session log.
  Future<void> deleteAll() async {
    final repo = ref.read(sessionLogsRepositoryProvider);
    await repo.deleteAll();
    state = const AsyncValue.data(<SessionLog>[]);
  }
}

/// Provider for `HistoryController`.
final AsyncNotifierProvider<HistoryController, List<SessionLog>>
historyControllerProvider =
    AsyncNotifierProvider<HistoryController, List<SessionLog>>(
      HistoryController.new,
    );
