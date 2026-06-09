import 'package:guardianangela/data/db/dao/session_logs_dao.dart';
import 'package:guardianangela/domain/models/session_log.dart';

/// Outcome of [SessionLogRepository.purgeExpiredLogs].
///
/// The two stages of the retention policy are reported separately
/// because they are NOT interchangeable: [movedToTrash] rows still
/// exist and are recoverable from the Trash screen, while
/// [hardDeleted] rows are gone for good. Callers needing a single
/// "rows the purge affected" figure (e.g. the Purge-now snackbar)
/// sum the two.
typedef PurgeResult = ({int movedToTrash, int hardDeleted});

/// Policy-layer wrapper around [SessionLogsDao].
///
/// Translates the app-level retention contract into the DAO-level cutoff
/// queries. See spec 03 §SessionLog "Storage & retention (B8)" — the
/// data layer calls [purgeExpiredLogs] at app startup with the user's
/// configured `AppSettings.sessionLogRetentionDays` and
/// `AppSettings.trashRetentionDays`. Critical logs (sessions that
/// actually fired a destructive step) survive the age-based purge
/// indefinitely; trashed logs are governed by the trash-retention
/// window only.
class SessionLogRepository {
  /// Creates a repository that delegates to [dao].
  const SessionLogRepository(this._dao);

  final SessionLogsDao _dao;

  /// Inserts or replaces [log] in the Drift `session_logs` table.
  ///
  /// Called by [SessionLogRecorder.finalise] to perform the single
  /// atomic write at session end.
  Future<void> upsert(SessionLog log) => _dao.upsert(log);

  /// Returns every live (non-trashed) session log.
  ///
  /// Pass `includeTrashed: true` to also include rows whose
  /// [SessionLog.deletedAt] is set — backup / export uses this to
  /// guarantee full fidelity.
  Future<List<SessionLog>> getAll({bool includeTrashed = false}) =>
      _dao.getAll(includeTrashed: includeTrashed);

  /// Returns every live (non-trashed) session log ordered by
  /// [SessionLog.startedAt] descending (most recent first).
  ///
  /// Pass `includeTrashed: true` to bypass the soft-delete filter.
  Future<List<SessionLog>> getAllOrderedByStartDesc({
    bool includeTrashed = false,
  }) => _dao.getAllOrderedByStartDesc(includeTrashed: includeTrashed);

  /// Returns every trashed session log (rows with non-null
  /// [SessionLog.deletedAt]), most-recently trashed first.
  Future<List<SessionLog>> getTrashed() => _dao.getTrashed();

  /// Returns the log with [id], or null when no such log exists.
  ///
  /// Returns trashed rows as well — callers wanting only live rows
  /// must filter on [SessionLog.deletedAt].
  Future<SessionLog?> getById(String id) => _dao.getById(id);

  /// Hard-deletes the log with [id]. No-op if missing.
  Future<void> deleteById(String id) => _dao.deleteById(id);

  /// Soft-deletes the log with [id], moving it into the trash.
  ///
  /// The row stays in the table with [SessionLog.deletedAt] set so
  /// the user can restore it from the Trash screen for the next
  /// `AppSettings.trashRetentionDays` (default 7) days. After the
  /// window elapses, [purgeExpiredLogs] hard-deletes the row.
  ///
  /// [now] defaults to `DateTime.now().toUtc()`.
  Future<void> softDelete(String id, {DateTime? now}) async {
    final ts = (now ?? DateTime.now().toUtc()).toUtc();
    await _dao.softDelete(id, ts.millisecondsSinceEpoch);
  }

  /// Restores a previously soft-deleted log by clearing
  /// [SessionLog.deletedAt]. No-op if [id] is missing or the log is
  /// not in the trash.
  Future<void> restore(String id) async {
    await _dao.restore(id);
  }

  /// Hard-deletes every trashed row. Used by the Past Events Trash
  /// "Empty trash" action (spec 04 §Past Events Trash). Returns the
  /// number of rows deleted.
  Future<int> hardDeleteAllTrashed() => _dao.hardDeleteAllTrashed();

  /// Runs the two-stage retention purge (B8 step 5 + Extra 11).
  ///
  /// Stage 1 (age pass): every non-critical LIVE log whose reference
  /// time (`endedAt` if set, else `startedAt`) is strictly older than
  /// `now - Duration(days: retentionDays)` is SOFT-deleted into the
  /// trash ([SessionLog.deletedAt] stamped with [now]), where it stays
  /// recoverable for `trashRetentionDays` (spec 03:966–967).
  /// Already-trashed rows are never re-stamped.
  ///
  /// Stage 2 (trash pass): every trashed log whose
  /// [SessionLog.deletedAt] is older than
  /// `now - Duration(days: trashRetentionDays)` is hard-deleted.
  ///
  /// Critical logs (B8: at least one event that fired a destructive
  /// step — sms/phone/emergency/loud-alarm with delivery `sent`/`queued`
  /// or a `step_started`/`step_fired`/`stepAdvancing` event on a
  /// destructive step type) are preserved by the age-based pass
  /// indefinitely. The trash pass ignores criticality — once the
  /// user (or the age pass) has trashed a log and the retention
  /// window has elapsed, the row is hard-deleted regardless
  /// (spec 03:970, spec 04:2455–2459).
  ///
  /// [trashRetentionDays] defaults to 7 (spec 04:2459); pass a custom
  /// value to honour the user's configured override from
  /// `AppSettings.trashRetentionDays`.
  ///
  /// Returns a [PurgeResult] with both per-stage counts.
  Future<PurgeResult> purgeExpiredLogs({
    required int retentionDays,
    required DateTime now,
    int trashRetentionDays = 7,
  }) async {
    final cutoff = now.subtract(Duration(days: retentionDays));
    // The DAO defaults `keepCritical` to true; B8 requires it, so we
    // rely on the default rather than re-stating it (lint).
    final movedToTrash = await _dao.softDeleteOlderThan(
      cutoff,
      nowMs: now.toUtc().millisecondsSinceEpoch,
    );
    final trashCutoff = now.subtract(Duration(days: trashRetentionDays));
    final hardDeleted = await _dao.hardDeleteTrashedOlderThan(trashCutoff);
    return (movedToTrash: movedToTrash, hardDeleted: hardDeleted);
  }
}
