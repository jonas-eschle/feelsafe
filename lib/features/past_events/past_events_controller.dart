import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import 'package:guardianangela/domain/models/session_log.dart';
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
///
/// Implements the soft-delete-with-undo semantics from spec 04
/// §Past Events Screen: deleting a log removes it from the repository
/// but keeps a copy in [_tombstones] until [undoDelete] re-inserts it.
/// The screen displays a 5-second snackbar with an UNDO action; if the
/// snackbar is dismissed without undo, [finalizeDelete] removes the
/// tombstone permanently.
class PastEventsController extends AsyncNotifier<PastEventsState> {
  /// In-memory tombstones keyed by log id. Populated by [softDelete] and
  /// cleared by [undoDelete] or [finalizeDelete].
  final Map<String, SessionLog> _tombstones = <String, SessionLog>{};

  @override
  Future<PastEventsState> build() async {
    final repo = await ref.watch(sessionLogRepositoryProvider.future);
    final raw = await repo.getAll();
    final logs = <PastEventsLog>[];
    for (final l in raw) {
      // In-progress marker rows (endedAt == null) are not shown in the
      // history — they only exist to drive the Session-Interrupted Prompt.
      if (l.endedAt == null) continue;
      final ended = l.endedAt!;
      final duration = ended.difference(l.startedAt).inSeconds;
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

  /// Soft-deletes the log with [id]: keeps a tombstone copy in memory and
  /// removes the row from the repository so it disappears from the list.
  ///
  /// Call [undoDelete] within the snackbar window to restore the row, or
  /// [finalizeDelete] after the snackbar dismisses to drop the tombstone.
  Future<void> softDelete(String id) async {
    final repo = await ref.read(sessionLogRepositoryProvider.future);
    final log = await repo.getById(id);
    if (log == null) return;
    _tombstones[id] = log;
    await repo.deleteById(id);
    ref.invalidateSelf();
  }

  /// Restores a previously soft-deleted log by re-inserting it.
  Future<void> undoDelete(String id) async {
    final log = _tombstones.remove(id);
    if (log == null) return;
    final repo = await ref.read(sessionLogRepositoryProvider.future);
    await repo.upsert(log);
    ref.invalidateSelf();
  }

  /// Removes the tombstone for [id] without restoring it.
  ///
  /// Called by the screen when the undo snackbar dismisses without the
  /// user tapping UNDO. After this call the deletion is irreversible.
  void finalizeDelete(String id) {
    _tombstones.remove(id);
    log('finalised delete: $id', name: 'PastEventsController');
  }

  /// Returns true if a tombstone exists for [id] (visible to tests).
  @visibleForTesting
  bool hasTombstone(String id) => _tombstones.containsKey(id);
}

/// Provides [PastEventsController].
final pastEventsControllerProvider =
    AsyncNotifierProvider<PastEventsController, PastEventsState>(
      PastEventsController.new,
    );
