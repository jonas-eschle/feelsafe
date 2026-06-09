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
    test('returns zero counts when no logs exist', () async {
      final result = await repo.purgeExpiredLogs(retentionDays: 30, now: now);
      check(result).equals((movedToTrash: 0, hardDeleted: 0));
    });

    test('SOFT-deletes a non-critical log whose endedAt is older than cutoff '
        'into the recoverable trash (B8 step 5)', () async {
      // Arrange — 60-day-old non-critical session.
      await db.sessionLogsDao.upsert(
        _nonCriticalLog(
          id: 'old',
          startedAt: now.subtract(const Duration(days: 60)),
          endedAt: now.subtract(const Duration(days: 60)),
        ),
      );
      // Act — retentionDays=30 → cutoff is 30 days before now.
      final result = await repo.purgeExpiredLogs(retentionDays: 30, now: now);
      // Assert — hidden from live, but recoverable: still in the table
      // with deletedAt stamped at the purge time.
      check(result).equals((movedToTrash: 1, hardDeleted: 0));
      check(await db.sessionLogsDao.getAll()).isEmpty();
      final trashed = await db.sessionLogsDao.getTrashed();
      check(trashed.map((l) => l.id).toList()).deepEquals(['old']);
      check(trashed.single.deletedAt).equals(now);
    });

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
      final result = await repo.purgeExpiredLogs(retentionDays: 30, now: now);
      // Assert — untouched: still live, never trashed.
      check(result).equals((movedToTrash: 0, hardDeleted: 0));
      check((await db.sessionLogsDao.getAll()).single.id).equals('recent');
      check(await db.sessionLogsDao.getTrashed()).isEmpty();
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
      final result = await repo.purgeExpiredLogs(retentionDays: 30, now: now);
      // Assert — critical survives LIVE (not even trashed).
      check(result).equals((movedToTrash: 0, hardDeleted: 0));
      check((await db.sessionLogsDao.getAll()).single.id).equals('crit');
      check(await db.sessionLogsDao.getTrashed()).isEmpty();
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
      final result = await repo.purgeExpiredLogs(retentionDays: 30, now: now);
      // Assert — only noncrit-old left the live list, into the trash.
      check(result).equals((movedToTrash: 1, hardDeleted: 0));
      check(
        (await db.sessionLogsDao.getAll()).map((l) => l.id).toSet(),
      ).deepEquals({'noncrit-recent', 'crit-old', 'crit-recent'});
      check(
        (await db.sessionLogsDao.getTrashed()).map((l) => l.id).toList(),
      ).deepEquals(['noncrit-old']);
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
      final result = await repo.purgeExpiredLogs(retentionDays: 30, now: now);
      // Assert
      check(result).equals((movedToTrash: 1, hardDeleted: 0));
    });

    test('retentionDays is honoured: shorter window trashes more', () async {
      // Arrange — 10-day-old non-critical log.
      await db.sessionLogsDao.upsert(
        _nonCriticalLog(
          id: 'mid',
          startedAt: now.subtract(const Duration(days: 10)),
          endedAt: now.subtract(const Duration(days: 10)),
        ),
      );
      // Act — wide window first, narrow window second.
      final kept = await repo.purgeExpiredLogs(retentionDays: 30, now: now);
      check(kept).equals((movedToTrash: 0, hardDeleted: 0));
      final trashedNow = await repo.purgeExpiredLogs(
        retentionDays: 7,
        now: now,
      );
      // Assert — narrower window moves the 10-day-old log to the trash.
      check(trashedNow).equals((movedToTrash: 1, hardDeleted: 0));
    });
  });

  group('SessionLogRepository trash flow (spec 04:2455-2459 / 03:970)', () {
    test('softDelete + restore round-trip', () async {
      // Arrange — one live, non-critical log.
      await db.sessionLogsDao.upsert(
        _nonCriticalLog(
          id: 'log-1',
          startedAt: now.subtract(const Duration(days: 1)),
          endedAt: now.subtract(const Duration(days: 1)),
        ),
      );
      check(await repo.getAll()).length.equals(1);
      check(await repo.getTrashed()).isEmpty();

      // Act — soft-delete, then assert it moved to the trash.
      await repo.softDelete('log-1', now: now);
      check(await repo.getAll()).isEmpty();
      final trashed = await repo.getTrashed();
      check(trashed).length.equals(1);
      check(trashed.single.deletedAt).isNotNull().equals(now);

      // Act — restore.
      await repo.restore('log-1');
      check(await repo.getAll()).length.equals(1);
      check(await repo.getTrashed()).isEmpty();
    });

    test(
      'purgeExpiredLogs also hard-deletes trashed rows past trashRetentionDays',
      () async {
        // Arrange — two trashed rows: one 10 days old (past 7-day
        // window), one 2 days old (inside window).
        await db.sessionLogsDao.upsert(
          _nonCriticalLog(
            id: 'old-trash',
            startedAt: now.subtract(const Duration(days: 1)),
            endedAt: now.subtract(const Duration(days: 1)),
          ),
        );
        await db.sessionLogsDao.upsert(
          _nonCriticalLog(
            id: 'recent-trash',
            startedAt: now.subtract(const Duration(days: 1)),
            endedAt: now.subtract(const Duration(days: 1)),
          ),
        );
        await repo.softDelete(
          'old-trash',
          now: now.subtract(const Duration(days: 10)),
        );
        await repo.softDelete(
          'recent-trash',
          now: now.subtract(const Duration(days: 2)),
        );

        // Act — wide age-based retention so the live cutoff doesn't
        // touch anything; trash cutoff = 7 days (default).
        final result = await repo.purgeExpiredLogs(
          retentionDays: 365,
          now: now,
        );

        // Assert — only 'old-trash' was hard-deleted; 'recent-trash'
        // is still in the trash.
        check(result).equals((movedToTrash: 0, hardDeleted: 1));
        final remaining = (await db.sessionLogsDao.getAll(
          includeTrashed: true,
        )).map((l) => l.id).toSet();
        check(remaining).deepEquals({'recent-trash'});
      },
    );

    test(
      'purgeExpiredLogs hard-deletes trash regardless of criticality',
      () async {
        // Arrange — a critical log moved to the trash 30 days ago.
        await db.sessionLogsDao.upsert(
          _criticalLog(
            id: 'critical-old-trash',
            startedAt: now.subtract(const Duration(days: 5)),
            endedAt: now.subtract(const Duration(days: 5)),
          ),
        );
        await repo.softDelete(
          'critical-old-trash',
          now: now.subtract(const Duration(days: 30)),
        );

        // Act — trashRetentionDays default is 7 days.
        final result = await repo.purgeExpiredLogs(
          retentionDays: 365,
          now: now,
        );

        // Assert — critical-ness does NOT save trashed rows once the
        // retention window has elapsed.
        check(result).equals((movedToTrash: 0, hardDeleted: 1));
        check(await db.sessionLogsDao.getAll(includeTrashed: true)).isEmpty();
      },
    );

    test('getAllOrderedByStartDesc excludes trashed rows', () async {
      await db.sessionLogsDao.upsert(
        _nonCriticalLog(
          id: 'live',
          startedAt: now.subtract(const Duration(hours: 1)),
          endedAt: now.subtract(const Duration(hours: 1)),
        ),
      );
      await db.sessionLogsDao.upsert(
        _nonCriticalLog(
          id: 'trashed',
          startedAt: now.subtract(const Duration(hours: 2)),
          endedAt: now.subtract(const Duration(hours: 2)),
        ),
      );
      await repo.softDelete('trashed', now: now);
      final live = await repo.getAllOrderedByStartDesc();
      check(live.map((l) => l.id).toList()).deepEquals(['live']);
      final all = await repo.getAllOrderedByStartDesc(includeTrashed: true);
      check(all.map((l) => l.id).toSet()).deepEquals({'live', 'trashed'});
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
