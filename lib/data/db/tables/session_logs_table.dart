import 'package:drift/drift.dart';

/// Drift table backing the [SessionLog] domain model.
///
/// See spec 03 §SessionLog. Timestamps are stored as UTC milliseconds
/// (`IntColumn`) to preserve millisecond precision (Drift's
/// `DateTimeColumn` truncates to seconds). The [eventsJson] column stores
/// the `List<SessionLogEvent>` as a JSON array.
@DataClassName('SessionLogRow')
class SessionLogs extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// UUID of the SessionMode that ran.
  TextColumn get modeId => text()();

  /// Mode name cached at session start (preserved even if mode is later
  /// deleted).
  TextColumn get modeName => text()();

  /// Session start time in UTC milliseconds since epoch.
  IntColumn get startedAtMs => integer()();

  /// Session end time in UTC milliseconds since epoch; null while active.
  IntColumn get endedAtMs => integer().nullable()();

  /// `EndReason.name`; null if session still running.
  TextColumn get endReason => text().nullable()();

  /// Whether this was a simulation session.
  BoolColumn get isSimulation => boolean()();

  /// True iff the session captured medical info (Extra 47).
  BoolColumn get hadMedicalInfo => boolean()();

  /// JSON-encoded list of `SessionLogEvent.toJson()` maps.
  TextColumn get eventsJson => text()();

  /// Soft-delete timestamp in UTC milliseconds since epoch; null when the
  /// row is "live" (visible in the past-events list).
  ///
  /// Used by the spec 04:2455–2459 / spec 03:970 trash retention flow:
  /// the user swipes a log into the trash; the row stays in the table
  /// with [deletedAtMs] set so it remains restorable for
  /// `AppSettings.trashRetentionDays` (default 7) before the next
  /// `purgeExpiredLogs` hard-deletes it.
  IntColumn get deletedAtMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
