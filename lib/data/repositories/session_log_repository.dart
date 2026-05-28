import 'package:guardianangela/data/db/dao/session_logs_dao.dart';
import 'package:guardianangela/domain/models/session_log.dart';

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

  /// Deletes every non-critical log whose reference time
  /// (`endedAt` if set, else `startedAt`) is strictly older than
  /// `now - Duration(days: retentionDays)`, AND every trashed log
  /// whose [SessionLog.deletedAt] is older than
  /// `now - Duration(days: trashRetentionDays)`.
  ///
  /// Critical logs (B8: at least one event that fired a destructive
  /// step — sms/phone/emergency/loud-alarm with delivery `sent`/`queued`
  /// or a `step_started`/`step_fired`/`stepAdvancing` event on a
  /// destructive step type) are preserved by the age-based purge
  /// indefinitely. The trash purge ignores criticality — once the
  /// user has trashed a log and the retention window has elapsed,
  /// the row is hard-deleted regardless (spec 03:970,
  /// spec 04:2455–2459).
  ///
  /// [trashRetentionDays] defaults to 7 (spec 04:2459); pass a custom
  /// value to honour the user's configured override from
  /// `AppSettings.trashRetentionDays`.
  ///
  /// Returns the total number of rows deleted (age-based + trash).
  Future<int> purgeExpiredLogs({
    required int retentionDays,
    required DateTime now,
    int trashRetentionDays = 7,
  }) async {
    final cutoff = now.subtract(Duration(days: retentionDays));
    // The DAO defaults `keepCritical` to true; B8 requires it, so we
    // rely on the default rather than re-stating it (lint).
    final aged = await _dao.deleteOlderThan(cutoff);
    final trashCutoff = now.subtract(Duration(days: trashRetentionDays));
    final trashed = await _dao.hardDeleteTrashedOlderThan(trashCutoff);
    return aged + trashed;
  }
}
