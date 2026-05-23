import 'package:drift/drift.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/db/tables/sms_retry_jobs_table.dart';

part 'sms_retry_jobs_dao.g.dart';

/// A pending SMS retry job mirrored from the native WorkManager queue.
///
/// See spec 05 §SMS Retry Queue. The Dart-side metadata lets the
/// orchestrator enumerate and cancel pending jobs on disarm (A5).
final class SmsRetryJob {
  /// Creates an [SmsRetryJob] instance.
  const SmsRetryJob({
    required this.workId,
    this.contactId,
    required this.phoneNumber,
    required this.message,
    required this.attemptCount,
    required this.enqueuedAt,
    this.lastError,
  });

  /// WorkManager job ID (primary key).
  final String workId;

  /// Source contact ID, when the job originated from a known contact.
  final String? contactId;

  /// Destination phone number.
  final String phoneNumber;

  /// Message body queued for delivery.
  final String message;

  /// Attempts so far; 0 means no attempt has been made yet.
  final int attemptCount;

  /// Enqueue time in UTC.
  final DateTime enqueuedAt;

  /// Most recent error message (truncated by the worker); null on success
  /// or first try.
  final String? lastError;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SmsRetryJob &&
          workId == other.workId &&
          contactId == other.contactId &&
          phoneNumber == other.phoneNumber &&
          message == other.message &&
          attemptCount == other.attemptCount &&
          enqueuedAt == other.enqueuedAt &&
          lastError == other.lastError);

  @override
  int get hashCode => Object.hash(
    workId,
    contactId,
    phoneNumber,
    message,
    enqueuedAt,
    attemptCount,
    lastError,
  );
}

/// DAO for the [SmsRetryJobs] table.
///
/// This is metadata only — the actual job lifecycle lives in WorkManager.
@DriftAccessor(tables: [SmsRetryJobs])
class SmsRetryJobsDao extends DatabaseAccessor<GuardianAngelaDatabase>
    with _$SmsRetryJobsDaoMixin {
  /// Creates a DAO bound to [db].
  SmsRetryJobsDao(super.db);

  /// Returns every pending job, oldest first.
  Future<List<SmsRetryJob>> getAll() async {
    final rows = await (select(
      smsRetryJobs,
    )..orderBy([(j) => OrderingTerm.asc(j.enqueuedAtMs)])).get();
    return rows.map(_rowToModel).toList();
  }

  /// Returns just the WorkManager IDs of all pending jobs.
  Future<List<String>> getAllWorkIds() async {
    final rows =
        await (selectOnly(smsRetryJobs)
              ..addColumns([smsRetryJobs.workId])
              ..orderBy([OrderingTerm.asc(smsRetryJobs.enqueuedAtMs)]))
            .get();
    return rows.map((row) => row.read(smsRetryJobs.workId)!).toList();
  }

  /// Returns the job with [workId], or null if not found.
  Future<SmsRetryJob?> getByWorkId(String workId) async {
    final row = await (select(
      smsRetryJobs,
    )..where((j) => j.workId.equals(workId))).getSingleOrNull();
    return row == null ? null : _rowToModel(row);
  }

  /// Inserts or replaces [job] (upsert keyed by [SmsRetryJob.workId]).
  Future<void> upsert(SmsRetryJob job) async {
    await into(smsRetryJobs).insertOnConflictUpdate(_modelToCompanion(job));
  }

  /// Deletes the job with [workId]. No-op if not found.
  Future<void> deleteByWorkId(String workId) async {
    await (delete(smsRetryJobs)..where((j) => j.workId.equals(workId))).go();
  }

  /// Streams all pending jobs (re-emitting on every change), oldest first.
  Stream<List<SmsRetryJob>> watchAll() =>
      (select(smsRetryJobs)..orderBy([(j) => OrderingTerm.asc(j.enqueuedAtMs)]))
          .watch()
          .map((rows) => rows.map(_rowToModel).toList());

  static SmsRetryJob _rowToModel(SmsRetryJobRow row) => SmsRetryJob(
    workId: row.workId,
    contactId: row.contactId,
    phoneNumber: row.phoneNumber,
    message: row.message,
    attemptCount: row.attemptCount,
    enqueuedAt: DateTime.fromMillisecondsSinceEpoch(
      row.enqueuedAtMs,
      isUtc: true,
    ),
    lastError: row.lastError,
  );

  static SmsRetryJobsCompanion _modelToCompanion(SmsRetryJob j) =>
      SmsRetryJobsCompanion(
        workId: Value(j.workId),
        contactId: Value(j.contactId),
        phoneNumber: Value(j.phoneNumber),
        message: Value(j.message),
        attemptCount: Value(j.attemptCount),
        enqueuedAtMs: Value(j.enqueuedAt.toUtc().millisecondsSinceEpoch),
        lastError: Value(j.lastError),
      );
}
