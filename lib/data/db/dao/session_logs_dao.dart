import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/db/tables/session_logs_table.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/models/session_log.dart';
import 'package:guardianangela/domain/models/session_log_event.dart';

part 'session_logs_dao.g.dart';

/// DAO for the [SessionLogs] table.
///
/// Provides CRUD, a watch stream, retention queries, and the B8 smart
/// retention policy (critical logs survive deletion).
@DriftAccessor(tables: [SessionLogs])
class SessionLogsDao extends DatabaseAccessor<GuardianAngelaDatabase>
    with _$SessionLogsDaoMixin {
  /// Creates a DAO bound to [db].
  SessionLogsDao(super.db);

  /// Step types whose presence in a session marks the log as critical
  /// (spec 03 §SessionLog "Storage & retention (B8)").
  static const Set<ChainStepType> _destructiveStepTypes = {
    ChainStepType.smsContact,
    ChainStepType.phoneCallContact,
    ChainStepType.callEmergency,
    ChainStepType.loudAlarm,
  };

  /// Event types associated with a step actually firing (vs. being merely
  /// scheduled). Combined with [_destructiveStepTypes] to compute
  /// criticality.
  static const Set<String> _firedEventTypes = {
    'step_started',
    'stepAdvancing',
    'step_fired',
  };

  /// Delivery statuses that count as a destructive action (an outbound
  /// message was actually sent or queued, not blocked or failed).
  static const Set<String> _firedDeliveryStatuses = {'sent', 'queued'};

  /// Returns all live logs (rows with `deletedAtMs IS NULL`) in
  /// insertion order.
  ///
  /// To inspect trashed rows use [getTrashed]; to ignore the
  /// soft-delete filter (e.g. backup / export) pass `includeTrashed:
  /// true`.
  Future<List<SessionLog>> getAll({bool includeTrashed = false}) async {
    final query = select(sessionLogs);
    if (!includeTrashed) {
      query.where((l) => l.deletedAtMs.isNull());
    }
    final rows = await query.get();
    return rows.map(_rowToModel).toList();
  }

  /// Returns live logs ordered by [SessionLog.startedAt] descending (most
  /// recent first).
  ///
  /// Excludes trashed rows (`deletedAtMs IS NOT NULL`) by default; pass
  /// `includeTrashed: true` to bypass the filter.
  Future<List<SessionLog>> getAllOrderedByStartDesc({
    bool includeTrashed = false,
  }) async {
    final query = select(sessionLogs);
    if (!includeTrashed) {
      query.where((l) => l.deletedAtMs.isNull());
    }
    query.orderBy([(l) => OrderingTerm.desc(l.startedAtMs)]);
    final rows = await query.get();
    return rows.map(_rowToModel).toList();
  }

  /// Returns trashed logs (`deletedAtMs IS NOT NULL`), most-recently
  /// trashed first.
  Future<List<SessionLog>> getTrashed() async {
    final rows =
        await (select(sessionLogs)
              ..where((l) => l.deletedAtMs.isNotNull())
              ..orderBy([(l) => OrderingTerm.desc(l.deletedAtMs)]))
            .get();
    return rows.map(_rowToModel).toList();
  }

  /// Returns the log with [id], or null if not found.
  ///
  /// Returns trashed rows as well — callers wanting only live rows must
  /// filter on the model's [SessionLog.deletedAt] field.
  Future<SessionLog?> getById(String id) async {
    final row = await (select(
      sessionLogs,
    )..where((l) => l.id.equals(id))).getSingleOrNull();
    return row == null ? null : _rowToModel(row);
  }

  /// Inserts or replaces [log] (upsert keyed by [SessionLog.id]).
  Future<void> upsert(SessionLog log) async {
    await into(sessionLogs).insertOnConflictUpdate(_modelToCompanion(log));
  }

  /// Deletes the log with [id]. No-op if not found.
  Future<void> deleteById(String id) async {
    await (delete(sessionLogs)..where((l) => l.id.equals(id))).go();
  }

  /// Soft-deletes the log with [id] by marking [SessionLogs.deletedAtMs]
  /// with [nowMs].
  ///
  /// The row stays in the table so the user can restore it from the
  /// Trash screen. After `AppSettings.trashRetentionDays` days the
  /// startup [SessionLogRepository.purgeExpiredLogs] hard-deletes it
  /// regardless of criticality (spec 03:970, spec 04:2455–2459).
  ///
  /// Returns the number of rows updated (0 if no log with [id] exists).
  Future<int> softDelete(String id, int nowMs) {
    return (update(sessionLogs)..where((l) => l.id.equals(id))).write(
      SessionLogsCompanion(deletedAtMs: Value(nowMs)),
    );
  }

  /// Restores a previously soft-deleted log by clearing
  /// [SessionLogs.deletedAtMs].
  ///
  /// Returns the number of rows updated (0 if no log with [id] exists).
  Future<int> restore(String id) {
    return (update(sessionLogs)..where((l) => l.id.equals(id))).write(
      const SessionLogsCompanion(deletedAtMs: Value(null)),
    );
  }

  /// Hard-deletes trashed rows whose [SessionLogs.deletedAtMs] is older
  /// than [cutoff].
  ///
  /// Used by [SessionLogRepository.purgeExpiredLogs] to enforce the
  /// 7-day trash retention window from spec 04:2458. Critical-log
  /// preservation does NOT apply here — once the user has trashed a
  /// log, the retention timer governs.
  ///
  /// Returns the number of rows deleted.
  Future<int> hardDeleteTrashedOlderThan(DateTime cutoff) async {
    final cutoffMs = cutoff.toUtc().millisecondsSinceEpoch;
    return (delete(sessionLogs)..where(
          (l) =>
              l.deletedAtMs.isNotNull() &
              l.deletedAtMs.isSmallerThanValue(cutoffMs),
        ))
        .go();
  }

  /// Streams live logs (re-emitting on every change), most recent first.
  ///
  /// Excludes trashed rows from the emitted snapshot.
  Stream<List<SessionLog>> watchAll() =>
      (select(sessionLogs)
            ..where((l) => l.deletedAtMs.isNull())
            ..orderBy([(l) => OrderingTerm.desc(l.startedAtMs)]))
          .watch()
          .map((rows) => rows.map(_rowToModel).toList());

  /// Deletes every log whose reference time (`endedAt` if set, else
  /// `startedAt`) is strictly older than [cutoff].
  ///
  /// When [keepCritical] is true (the default for the B8 smart-retention
  /// policy), logs that recorded a destructive action are retained
  /// regardless of age. See spec 03 §SessionLog "Storage & retention (B8)".
  ///
  /// Returns the number of logs deleted.
  Future<int> deleteOlderThan(
    DateTime cutoff, {
    bool keepCritical = true,
  }) async {
    final cutoffMs = cutoff.toUtc().millisecondsSinceEpoch;
    final candidateRows = await select(sessionLogs).get();
    final candidates = candidateRows
        .map((row) {
          final logEndsAt = row.endedAtMs ?? row.startedAtMs;
          if (logEndsAt >= cutoffMs) {
            return null;
          }
          if (keepCritical && _isCriticalRow(row)) {
            return null;
          }
          return row.id;
        })
        .whereType<String>()
        .toList();
    if (candidates.isEmpty) {
      return 0;
    }
    return (delete(sessionLogs)..where((l) => l.id.isIn(candidates))).go();
  }

  /// Returns true if the log carries at least one event indicating a
  /// destructive step actually fired (spec 03 §SessionLog B8).
  ///
  /// Public for tests so the predicate can be exercised directly without
  /// going through SQL.
  static bool isCritical(SessionLog log) {
    for (final event in log.events) {
      if (_eventIndicatesDestructiveAction(
        eventType: event.eventType,
        stepType: event.stepType,
        deliveryStatus: event.deliveryStatus,
      )) {
        return true;
      }
    }
    return false;
  }

  static bool _isCriticalRow(SessionLogRow row) {
    final eventsRaw = jsonDecode(row.eventsJson) as List<dynamic>;
    for (final e in eventsRaw) {
      final map = e as Map<String, dynamic>;
      if (_eventIndicatesDestructiveAction(
        eventType: map['eventType'] as String,
        stepType: map['stepType'] as String?,
        deliveryStatus: map['deliveryStatus'] as String?,
      )) {
        return true;
      }
    }
    return false;
  }

  static bool _eventIndicatesDestructiveAction({
    required String eventType,
    required String? stepType,
    required String? deliveryStatus,
  }) {
    if (deliveryStatus != null &&
        _firedDeliveryStatuses.contains(deliveryStatus)) {
      return true;
    }
    if (!_firedEventTypes.contains(eventType)) {
      return false;
    }
    if (stepType == null) {
      return false;
    }
    final type = ChainStepType.values.firstWhere(
      (t) => t.name == stepType,
      orElse: () => ChainStepType.holdButton,
    );
    return _destructiveStepTypes.contains(type);
  }

  static SessionLog _rowToModel(SessionLogRow row) {
    final eventsRaw = jsonDecode(row.eventsJson) as List<dynamic>;
    return SessionLog(
      id: row.id,
      modeId: row.modeId,
      modeName: row.modeName,
      startedAt: DateTime.fromMillisecondsSinceEpoch(
        row.startedAtMs,
        isUtc: true,
      ),
      endedAt: row.endedAtMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(row.endedAtMs!, isUtc: true),
      endReason: row.endReason == null
          ? null
          : EndReason.values.byName(row.endReason!),
      isSimulation: row.isSimulation,
      hadMedicalInfo: row.hadMedicalInfo,
      events: eventsRaw
          .map((e) => SessionLogEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      deletedAt: row.deletedAtMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(row.deletedAtMs!, isUtc: true),
    );
  }

  static SessionLogsCompanion _modelToCompanion(SessionLog log) =>
      SessionLogsCompanion(
        id: Value(log.id),
        modeId: Value(log.modeId),
        modeName: Value(log.modeName),
        startedAtMs: Value(log.startedAt.toUtc().millisecondsSinceEpoch),
        endedAtMs: Value(log.endedAt?.toUtc().millisecondsSinceEpoch),
        endReason: Value(log.endReason?.name),
        isSimulation: Value(log.isSimulation),
        hadMedicalInfo: Value(log.hadMedicalInfo),
        eventsJson: Value(
          jsonEncode(log.events.map((e) => e.toJson()).toList()),
        ),
        deletedAtMs: Value(log.deletedAt?.toUtc().millisecondsSinceEpoch),
      );
}
