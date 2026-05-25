import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import 'package:guardianangela/services/service_providers.dart';

/// Lightweight view of a session log for the list screen.
@immutable
class PastEventsLog {
  /// Creates a [PastEventsLog].
  const PastEventsLog({
    required this.id,
    required this.modeName,
    required this.startedAt,
    required this.durationSeconds,
    required this.isSimulation,
  });

  /// Session log id.
  final String id;

  /// Resolved mode display name.
  final String modeName;

  /// Session start wall-clock time.
  final DateTime startedAt;

  /// Total duration in seconds.
  final int durationSeconds;

  /// Whether this was a simulation.
  final bool isSimulation;
}

/// Immutable state for the past-events screen.
@immutable
class PastEventsState {
  /// Creates a [PastEventsState].
  const PastEventsState({required this.logs});

  /// All session logs (real + simulated), newest-first.
  final List<PastEventsLog> logs;
}

/// Controller for the past-events list.
class PastEventsController extends AsyncNotifier<PastEventsState> {
  @override
  Future<PastEventsState> build() async {
    final repo = await ref.watch(sessionLogRepositoryProvider.future);
    final raw = await repo.getAll();
    final logs = <PastEventsLog>[];
    for (final l in raw) {
      final ended = l.endedAt;
      final duration = ended == null
          ? 0
          : ended.difference(l.startedAt).inSeconds;
      logs.add(
        PastEventsLog(
          id: l.id,
          modeName: l.modeName,
          startedAt: l.startedAt,
          durationSeconds: duration,
          isSimulation: l.isSimulation,
        ),
      );
    }
    logs.sort(
      (PastEventsLog a, PastEventsLog b) => b.startedAt.compareTo(a.startedAt),
    );
    return PastEventsState(logs: logs);
  }

  /// Soft-deletes [id] from the list (Phase 7 hooks up the tombstone
  /// store).
  Future<void> softDelete(String id) async {
    final repo = await ref.read(sessionLogRepositoryProvider.future);
    await repo.deleteById(id);
    ref.invalidateSelf();
  }

  /// Undoes a soft-delete. Phase 6 just re-invalidates so the list
  /// refreshes; Phase 7 will restore from the tombstone store.
  Future<void> undo(String id) async {
    ref.invalidateSelf();
  }
}

/// Provides [PastEventsController].
final pastEventsControllerProvider =
    AsyncNotifierProvider<PastEventsController, PastEventsState>(
      PastEventsController.new,
    );
