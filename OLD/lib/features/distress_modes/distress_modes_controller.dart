/// Distress-modes feature controller.
///
/// Phase 2.5: distress modes are stored in the modes table as
/// `SessionMode`s with `isDistressMode = true`. This controller
/// surfaces just that subset to the UI.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/session_mode.dart';

/// Async controller exposing the distress-flagged modes.
class DistressModesController extends AsyncNotifier<List<SessionMode>> {
  @override
  Future<List<SessionMode>> build() async {
    final repo = ref.read(modesRepositoryProvider);
    final all = await repo.getAll();
    return all.where((m) => m.isDistressMode).toList();
  }

  /// Upserts [mode] (forced `isDistressMode = true`) and refreshes
  /// [state].
  ///
  /// Throws [ArgumentError] when the mode has no chain steps — empty
  /// distress modes would leave distress triggers toothless
  /// (D-SAFETY-17).
  Future<void> save(SessionMode mode) async {
    if (mode.chainSteps.isEmpty) {
      throw ArgumentError.value(
        mode,
        'mode',
        'distress mode must not be empty',
      );
    }
    final repo = ref.read(modesRepositoryProvider);
    final flagged = mode.isDistressMode
        ? mode
        : mode.copyWith(isDistressMode: true);
    await repo.save(flagged);
    final all = await repo.getAll();
    state = AsyncValue.data(all.where((m) => m.isDistressMode).toList());
  }

  /// Deletes the distress mode with [id] and refreshes [state].
  Future<void> delete(String id) async {
    final repo = ref.read(modesRepositoryProvider);
    await repo.delete(id);
    final all = await repo.getAll();
    state = AsyncValue.data(all.where((m) => m.isDistressMode).toList());
  }

  /// Forces a reload from the repository.
  Future<void> reload() async {
    state = const AsyncValue.loading();
    final repo = ref.read(modesRepositoryProvider);
    final all = await repo.getAll();
    state = AsyncValue.data(all.where((m) => m.isDistressMode).toList());
  }
}

/// Provider for `DistressModesController`.
final AsyncNotifierProvider<DistressModesController, List<SessionMode>>
distressModesControllerProvider =
    AsyncNotifierProvider<DistressModesController, List<SessionMode>>(
      DistressModesController.new,
    );
