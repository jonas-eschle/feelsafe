import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Outcome badge bucket displayed in the past-events list.
enum PastEventOutcome {
  /// Session ended cleanly (disarm or null end reason).
  completed,

  /// Session escalated to distress (chain exhaustion, duress PIN,
  /// hardware panic, wrong-PIN exhaustion).
  distress,

  /// User aborted before completion (explicit quit).
  interrupted,
}

/// Maps an [EndReason] to the corresponding [PastEventOutcome] bucket.
PastEventOutcome outcomeFromEndReason(EndReason? r) => switch (r) {
  null || EndReason.disarm => PastEventOutcome.completed,
  EndReason.chainExhausted ||
  EndReason.duressPin ||
  EndReason.hardwarePanic ||
  EndReason.wrongPinExhausted => PastEventOutcome.distress,
  EndReason.userQuit => PastEventOutcome.interrupted,
};

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
    required this.outcome,
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

  /// Outcome bucket derived from [SessionLog.endReason].
  final PastEventOutcome outcome;
}

/// Immutable state for the past-events screen.
@immutable
class PastEventsState {
  /// Creates a [PastEventsState].
  const PastEventsState({required this.logs});

  /// All live session logs (real + simulated), newest-first. Trashed
  /// logs are filtered out at the DAO layer.
  final List<PastEventsLog> logs;
}

/// Controller for the past-events list.
///
/// Implements the spec 04:2455–2459 / spec 03:970 trash flow: deleting a
/// log calls [SessionLogRepository.softDelete], which marks the row's
/// `deletedAtMs` column. The row stays in the trash for the
/// `AppSettings.trashRetentionDays` window (default 7 days) and is
/// hard-deleted by the startup `purgeExpiredLogs` after the window
/// elapses. The screen still surfaces a SnackBar with an UNDO action
/// for the convenience of immediate restore; UNDO simply clears
/// `deletedAtMs` via [undoSoftDelete]. Drift is the single source of
/// truth — there is no in-memory tombstone map.
class PastEventsController extends AsyncNotifier<PastEventsState> {
  @override
  Future<PastEventsState> build() async {
    final repo = await ref.watch(sessionLogRepositoryProvider.future);
    // Live list — getAllOrderedByStartDesc filters trashed rows by
    // default at the DAO layer.
    final raw = await repo.getAllOrderedByStartDesc();
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
          outcome: outcomeFromEndReason(l.endReason),
        ),
      );
    }
    return PastEventsState(logs: logs);
  }

  /// Soft-deletes the log with [id] by marking it as trashed in Drift.
  ///
  /// The row disappears from the live list but remains restorable for
  /// the next `AppSettings.trashRetentionDays` days.
  Future<void> softDelete(String id) async {
    final repo = await ref.read(sessionLogRepositoryProvider.future);
    await repo.softDelete(id);
    ref.invalidateSelf();
  }

  /// Undoes a soft-delete by restoring the log (clears `deletedAtMs`).
  ///
  /// Used by the post-delete SnackBar UNDO action.
  Future<void> undoSoftDelete(String id) async {
    final repo = await ref.read(sessionLogRepositoryProvider.future);
    await repo.restore(id);
    ref.invalidateSelf();
  }

  /// Hard-deletes the log with [id], bypassing the trash.
  ///
  /// Used by "Delete all" / detail-view "Delete" actions where the
  /// user has explicitly opted out of the trash flow.
  Future<void> hardDelete(String id) async {
    final repo = await ref.read(sessionLogRepositoryProvider.future);
    await repo.deleteById(id);
    ref.invalidateSelf();
  }
}

/// Provides [PastEventsController].
final pastEventsControllerProvider =
    AsyncNotifierProvider<PastEventsController, PastEventsState>(
      PastEventsController.new,
    );
