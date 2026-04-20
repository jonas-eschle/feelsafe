/// Distress-chains feature controller.
///
/// Exposes the top-level `List<DistressChain>` repository. The first
/// entry is the default chain used when `SessionMode.distressChainId`
/// is null.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';

/// Async controller exposing the list of global distress chains.
class DistressChainsController extends AsyncNotifier<List<DistressChain>> {
  @override
  Future<List<DistressChain>> build() async {
    final repo = ref.read(distressChainsRepositoryProvider);
    return repo.getAll();
  }

  /// Upserts [chain] and refreshes [state].
  ///
  /// Throws [ArgumentError] when the chain has no steps —
  /// empty distress chains would leave distress triggers toothless
  /// (D-SAFETY-17).
  Future<void> save(DistressChain chain) async {
    if (chain.steps.isEmpty) {
      throw ArgumentError.value(
        chain,
        'chain',
        'distress chain must not be empty',
      );
    }
    final repo = ref.read(distressChainsRepositoryProvider);
    await repo.save(chain);
    state = AsyncValue.data(await repo.getAll());
  }

  /// Deletes the distress chain with [id] and refreshes [state].
  ///
  /// Throws [StateError] when deleting would leave the repository
  /// empty; the app requires at least one distress chain to be able
  /// to handle distress triggers.
  Future<void> delete(String id) async {
    final repo = ref.read(distressChainsRepositoryProvider);
    final current = await repo.getAll();
    final remaining = current.where((c) => c.id != id).toList();
    if (remaining.isEmpty) {
      throw StateError(
        'Refusing to delete the last distress chain: at least one '
        'chain must remain to handle distress triggers.',
      );
    }
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

/// Provider for `DistressChainsController`.
final AsyncNotifierProvider<DistressChainsController, List<DistressChain>>
    distressChainsControllerProvider =
    AsyncNotifierProvider<DistressChainsController, List<DistressChain>>(
  DistressChainsController.new,
);
