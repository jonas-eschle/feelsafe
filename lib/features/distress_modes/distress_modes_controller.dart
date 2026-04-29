/// Distress-modes feature controller.
///
/// Per Q52 / pivot 3, distress chains are conceptually unified into
/// Mode in the spec, but the codebase still ships a dedicated
/// `DistressChain` aggregate (with its own repository / DAO) — this
/// controller wraps that legacy storage while presenting the
/// "distress modes" terminology to the UI.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/distress_chain.dart';

/// Async controller exposing every persisted distress chain (the
/// underlying storage). The UI surfaces them as "distress modes" per
/// the project's renamed terminology (Q52).
class DistressModesController extends AsyncNotifier<List<DistressChain>> {
  @override
  Future<List<DistressChain>> build() async {
    final repo = ref.read(distressChainsRepositoryProvider);
    return repo.getAll();
  }

  /// Upserts [chain] and refreshes [state].
  ///
  /// Throws [ArgumentError] when the chain has no steps — empty
  /// distress modes would leave distress triggers toothless
  /// (D-SAFETY-17).
  Future<void> save(DistressChain chain) async {
    if (chain.steps.isEmpty) {
      throw ArgumentError.value(
        chain,
        'chain',
        'distress mode must not be empty',
      );
    }
    final repo = ref.read(distressChainsRepositoryProvider);
    await repo.save(chain);
    state = AsyncValue.data(await repo.getAll());
  }

  /// Deletes the distress mode with [id] and refreshes [state].
  Future<void> delete(String id) async {
    final repo = ref.read(distressChainsRepositoryProvider);
    await repo.delete(id);
    state = AsyncValue.data(await repo.getAll());
  }

  /// Forces a reload from the repository.
  Future<void> reload() async {
    state = const AsyncValue.loading();
    final repo = ref.read(distressChainsRepositoryProvider);
    state = AsyncValue.data(await repo.getAll());
  }
}

/// Provider for `DistressModesController`.
final AsyncNotifierProvider<DistressModesController, List<DistressChain>>
distressModesControllerProvider =
    AsyncNotifierProvider<DistressModesController, List<DistressChain>>(
      DistressModesController.new,
    );
