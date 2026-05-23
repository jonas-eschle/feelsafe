import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/session_log_repository.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/session_log.dart';
import 'package:guardianangela/domain/models/session_log_event.dart';

void main() {
  late GuardianAngelaDatabase db;
  late SessionLogRepository repo;
  final now = DateTime.utc(2026, 6, 1, 12);

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
    repo = SessionLogRepository(db.sessionLogsDao);
  });

  tearDown(() async {
    await db.close();
  });

  group('SessionLogRepository.purgeExpiredLogs', () {
    test('returns 0 when no logs exist', () async {
      final deleted = await repo.purgeExpiredLogs(retentionDays: 30, now: now);
      check(deleted).equals(0);
    });

    test(
      'deletes a non-critical log whose endedAt is older than cutoff',
      () async {
        // Arrange — 60-day-old non-critical session.
        await db.sessionLogsDao.upsert(
          _nonCriticalLog(
            id: 'old',
            startedAt: now.subtract(const Duration(days: 60)),
            endedAt: now.subtract(const Duration(days: 60)),
          ),
        );
        // Act — retentionDays=30 → cutoff is 30 days before now.
        final deleted = await repo.purgeExpiredLogs(
          retentionDays: 30,
          now: now,
        );
        // Assert
        check(deleted).equals(1);
        check(await db.sessionLogsDao.getAll()).isEmpty();
      },
    );

    test('keeps a non-critical log inside the retention window', () async {
      // Arrange — log ended 1 day ago, retentionDays=30.
      await db.sessionLogsDao.upsert(
        _nonCriticalLog(
          id: 'recent',
          startedAt: now.subtract(const Duration(days: 1)),
          endedAt: now.subtract(const Duration(days: 1)),
        ),
      );
      // Act
      final deleted = await repo.purgeExpiredLogs(retentionDays: 30, now: now);
      // Assert
      check(deleted).equals(0);
      check((await db.sessionLogsDao.getAll()).single.id).equals('recent');
    });

    test('keeps a critical log even when older than cutoff', () async {
      // Arrange — 365-day-old log that actually fired an SMS.
      await db.sessionLogsDao.upsert(
        _criticalLog(
          id: 'crit',
          startedAt: now.subtract(const Duration(days: 365)),
          endedAt: now.subtract(const Duration(days: 365)),
        ),
      );
      // Act
      final deleted = await repo.purgeExpiredLogs(retentionDays: 30, now: now);
      // Assert — critical survives.
      check(deleted).equals(0);
      check((await db.sessionLogsDao.getAll()).single.id).equals('crit');
    });

    test('mixed batch: deletes only non-critical past-cutoff logs', () async {
      // Arrange — 4 logs spanning the criticality x age quadrants.
      await db.sessionLogsDao.upsert(
        _nonCriticalLog(
          id: 'noncrit-old',
          startedAt: now.subtract(const Duration(days: 100)),
          endedAt: now.subtract(const Duration(days: 100)),
        ),
      );
      await db.sessionLogsDao.upsert(
        _nonCriticalLog(
          id: 'noncrit-recent',
          startedAt: now.subtract(const Duration(days: 5)),
          endedAt: now.subtract(const Duration(days: 5)),
        ),
      );
      await db.sessionLogsDao.upsert(
        _criticalLog(
          id: 'crit-old',
          startedAt: now.subtract(const Duration(days: 100)),
          endedAt: now.subtract(const Duration(days: 100)),
        ),
      );
      await db.sessionLogsDao.upsert(
        _criticalLog(
          id: 'crit-recent',
          startedAt: now.subtract(const Duration(days: 5)),
          endedAt: now.subtract(const Duration(days: 5)),
        ),
      );
      // Act
      final deleted = await repo.purgeExpiredLogs(retentionDays: 30, now: now);
      // Assert — only noncrit-old removed.
      check(deleted).equals(1);
      check(
        (await db.sessionLogsDao.getAll()).map((l) => l.id).toSet(),
      ).deepEquals({'noncrit-recent', 'crit-old', 'crit-recent'});
    });

    test('uses startedAt as the reference time when endedAt is null', () async {
      // Arrange — ongoing log started 90 days ago (no endedAt).
      await db.sessionLogsDao.upsert(
        _nonCriticalLog(
          id: 'ongoing-old',
          startedAt: now.subtract(const Duration(days: 90)),
          endedAt: null,
        ),
      );
      // Act
      final deleted = await repo.purgeExpiredLogs(retentionDays: 30, now: now);
      // Assert
      check(deleted).equals(1);
    });

    test('retentionDays is honoured: shorter window deletes more', () async {
      // Arrange — 10-day-old non-critical log.
      await db.sessionLogsDao.upsert(
        _nonCriticalLog(
          id: 'mid',
          startedAt: now.subtract(const Duration(days: 10)),
          endedAt: now.subtract(const Duration(days: 10)),
        ),
      );
      // Act — wide window first, narrow window second.
      final keptCount = await repo.purgeExpiredLogs(
        retentionDays: 30,
        now: now,
      );
      check(keptCount).equals(0);
      final deletedCount = await repo.purgeExpiredLogs(
        retentionDays: 7,
        now: now,
      );
      // Assert — narrower window deletes the 10-day-old log.
      check(deletedCount).equals(1);
    });
  });
}

/// A non-critical log: one cosmetic `started` event, no destructive step.
SessionLog _nonCriticalLog({
  required String id,
  required DateTime startedAt,
  required DateTime? endedAt,
}) => SessionLog(
  id: id,
  modeId: 'walk',
  modeName: 'Walk Mode',
  startedAt: startedAt,
  endedAt: endedAt,
  isSimulation: false,
  events: [
    SessionLogEvent(
      timestamp: startedAt,
      eventType: 'started',
      stepIndex: 0,
      description: 'Session started',
    ),
  ],
);

/// A critical log: contains a `step_started` event for `smsContact` with
/// `deliveryStatus: 'sent'` — fires the B8 criticality predicate.
SessionLog _criticalLog({
  required String id,
  required DateTime startedAt,
  required DateTime? endedAt,
}) => SessionLog(
  id: id,
  modeId: 'walk',
  modeName: 'Walk Mode',
  startedAt: startedAt,
  endedAt: endedAt,
  isSimulation: false,
  events: [
    SessionLogEvent(
      timestamp: startedAt,
      eventType: 'step_started',
      stepType: ChainStepType.smsContact.name,
      stepIndex: 1,
      description: 'SMS sent',
      deliveryStatus: 'sent',
    ),
  ],
);
