/// Modes-feature controller.
///
/// Exposes the list of [SessionMode]s backed by
/// [modesRepositoryProvider] and mediates every CRUD operation so
/// UI layers never touch the repository directly.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';

/// Async controller exposing the list of session modes.
class ModesController extends AsyncNotifier<List<SessionMode>> {
  @override
  Future<List<SessionMode>> build() async {
    final repo = ref.read(modesRepositoryProvider);
    return repo.getAll();
  }

  /// Upserts [mode] and refreshes [state].
  Future<void> save(SessionMode mode) async {
    final repo = ref.read(modesRepositoryProvider);
    await repo.save(mode);
    state = AsyncValue.data(await repo.getAll());
  }

  /// Deletes the mode with [id] and refreshes [state].
  Future<void> delete(String id) async {
    final repo = ref.read(modesRepositoryProvider);
    await repo.delete(id);
    state = AsyncValue.data(await repo.getAll());
  }

  /// Reorders modes in-place, moving the mode at [oldIndex] to
  /// [newIndex]. Persists the new ordering via `saveAll`.
  Future<void> reorder(int oldIndex, int newIndex) async {
    final current = state.value ?? const <SessionMode>[];
    if (oldIndex < 0 || oldIndex >= current.length) {
      throw RangeError.range(oldIndex, 0, current.length - 1, 'oldIndex');
    }
    final reordered = List<SessionMode>.of(current);
    final moved = reordered.removeAt(oldIndex);
    final insertAt = newIndex > oldIndex ? newIndex - 1 : newIndex;
    reordered.insert(insertAt.clamp(0, reordered.length), moved);
    final repo = ref.read(modesRepositoryProvider);
    await repo.saveAll(reordered);
    state = AsyncValue.data(reordered);
  }

  /// Forces a reload from the repository.
  Future<void> reload() async {
    state = const AsyncValue.loading();
    final repo = ref.read(modesRepositoryProvider);
    state = AsyncValue.data(await repo.getAll());
  }
}

/// Provider for `ModesController`.
final AsyncNotifierProvider<ModesController, List<SessionMode>>
    modesControllerProvider =
    AsyncNotifierProvider<ModesController, List<SessionMode>>(
  ModesController.new,
);
