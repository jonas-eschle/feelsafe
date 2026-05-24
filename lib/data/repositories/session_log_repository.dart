import 'package:guardianangela/data/db/dao/session_logs_dao.dart';
import 'package:guardianangela/domain/models/session_log.dart';

/// Policy-layer wrapper around [SessionLogsDao].
///
/// Translates the app-level retention contract into the DAO-level cutoff
/// query. See spec 03 §SessionLog "Storage & retention (B8)" — the data
/// layer calls [purgeExpiredLogs] at app startup with the user's
/// configured `AppSettings.sessionLogRetentionDays`. Critical logs
/// (sessions that actually fired a destructive step) survive deletion
/// regardless of age.
class SessionLogRepository {
  /// Creates a repository that delegates to [dao].
  const SessionLogRepository(this._dao);

  final SessionLogsDao _dao;

  /// Inserts or replaces [log] in the Drift `session_logs` table.
  ///
  /// Called by [SessionLogRecorder.finalise] to perform the single
  /// atomic write at session end.
  Future<void> upsert(SessionLog log) => _dao.upsert(log);

  /// Deletes every non-critical log whose reference time
  /// (`endedAt` if set, else `startedAt`) is strictly older than
  /// `now - Duration(days: retentionDays)`.
  ///
  /// Critical logs (B8: at least one event that fired a destructive
  /// step — sms/phone/emergency/loud-alarm with delivery `sent`/`queued`
  /// or a `step_started`/`step_fired`/`stepAdvancing` event on a
  /// destructive step type) are preserved indefinitely.
  ///
  /// Returns the number of logs deleted.
  Future<int> purgeExpiredLogs({
    required int retentionDays,
    required DateTime now,
  }) {
    final cutoff = now.subtract(Duration(days: retentionDays));
    // The DAO defaults `keepCritical` to true; B8 requires it, so we
    // rely on the default rather than re-stating it (lint).
    return _dao.deleteOlderThan(cutoff);
  }
}
