import 'package:drift/drift.dart';

/// Drift table mirroring the native Android WorkManager SMS retry queue.
///
/// See spec 05 §SMS Retry Queue (Extra-40/45). This is metadata only —
/// the actual job lifecycle lives in WorkManager. Dart consults this
/// table to enumerate pending jobs (so they can be cancelled on disarm)
/// and to surface retry-exhausted alerts. iOS is a no-op.
@DataClassName('SmsRetryJobRow')
class SmsRetryJobs extends Table {
  /// WorkManager job ID (primary key).
  TextColumn get workId => text()();

  /// Source contact ID, when the job originated from a known contact.
  /// Null for ad-hoc messages (e.g., emergency-number SMS).
  TextColumn get contactId => text().nullable()();

  /// Destination phone number.
  TextColumn get phoneNumber => text()();

  /// Message body queued for delivery.
  TextColumn get message => text()();

  /// Attempts so far; 0 means no attempt has been made yet.
  IntColumn get attemptCount => integer()();

  /// Enqueue time in UTC milliseconds since epoch.
  IntColumn get enqueuedAtMs => integer()();

  /// Most recent error message (truncated by the worker); null on success
  /// or first try.
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {workId};
}
