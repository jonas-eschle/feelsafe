import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/db/dao/session_logs_dao.dart';
import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/models/session_log.dart';
import 'package:guardianangela/domain/models/session_log_event.dart';

void main() {
  late GuardianAngelaDatabase db;
  final t0 = DateTime.utc(2026, 1, 1, 12);

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
  });

  tearDown(() async {
    await db.close();
  });

  group('SessionLogsDao', () {
    test('round-trips a log with events', () async {
      // Arrange
      final log = SessionLog(
        id: 'log-1',
        modeId: 'walk',
        modeName: 'Walk Mode',
        startedAt: t0,
        endedAt: t0.add(const Duration(minutes: 5)),
        endReason: EndReason.disarm,
        isSimulation: false,
        hadMedicalInfo: true,
        events: [
          SessionLogEvent(
            timestamp: t0,
            eventType: 'started',
            stepIndex: 0,
            description: 'Session started',
          ),
          SessionLogEvent(
            timestamp: t0.add(const Duration(minutes: 1)),
            eventType: 'step_started',
            stepType: ChainStepType.smsContact.name,
            stepIndex: 2,
            description: 'SMS sent',
            latitude: 37.7749,
            longitude: -122.4194,
            deliveryStatus: 'sent',
          ),
        ],
      );
      // Act
      await db.sessionLogsDao.upsert(log);
      final fetched = await db.sessionLogsDao.getById('log-1');
      // Assert
      check(fetched).isNotNull().equals(log);
    });

    test('getAllOrderedByStartDesc returns logs newest first', () async {
      // Arrange — insert in arbitrary order.
      await db.sessionLogsDao.upsert(_log('a', t0));
      await db.sessionLogsDao.upsert(
        _log('c', t0.add(const Duration(hours: 2))),
      );
      await db.sessionLogsDao.upsert(
        _log('b', t0.add(const Duration(hours: 1))),
      );
      // Act
      final ordered = await db.sessionLogsDao.getAllOrderedByStartDesc();
      // Assert
      check(ordered.map((l) => l.id).toList()).deepEquals(['c', 'b', 'a']);
    });

    test(
      'softDeleteOlderThan keeps critical logs live even when older than '
      'cutoff, and TRASHES (not hard-deletes) the stale mundane one',
      () async {
        // Arrange
        await db.sessionLogsDao.upsert(
          _log('old-critical', t0, critical: true),
        );
        await db.sessionLogsDao.upsert(_log('old-mundane', t0));
        await db.sessionLogsDao.upsert(
          _log(
            'recent-critical',
            t0.add(const Duration(days: 30)),
            critical: true,
          ),
        );
        await db.sessionLogsDao.upsert(
          _log('recent-mundane', t0.add(const Duration(days: 30))),
        );
        // Act — cutoff is 5 days after t0, so old logs are stale.
        final cutoff = t0.add(const Duration(days: 5));
        final trashed = await db.sessionLogsDao.softDeleteOlderThan(
          cutoff,
          nowMs: cutoff.millisecondsSinceEpoch,
        );
        // Assert — only `old-mundane` left the live list…
        check(trashed).equals(1);
        final remaining = (await db.sessionLogsDao.getAll())
            .map((l) => l.id)
            .toSet();
        check(
          remaining,
        ).deepEquals({'old-critical', 'recent-critical', 'recent-mundane'});
        // …but it still exists, recoverable in the trash with the stamp.
        final mundane = await db.sessionLogsDao.getById('old-mundane');
        check(mundane).isNotNull();
        check(mundane!.deletedAt).equals(cutoff);
        check(
          (await db.sessionLogsDao.getTrashed()).map((l) => l.id).toList(),
        ).deepEquals(['old-mundane']);
      },
    );

    test(
      'softDeleteOlderThan with keepCritical=false trashes every stale log',
      () async {
        // Arrange
        await db.sessionLogsDao.upsert(
          _log('old-critical', t0, critical: true),
        );
        await db.sessionLogsDao.upsert(_log('old-mundane', t0));
        // Act
        final trashed = await db.sessionLogsDao.softDeleteOlderThan(
          t0.add(const Duration(days: 1)),
          nowMs: t0.add(const Duration(days: 1)).millisecondsSinceEpoch,
          keepCritical: false,
        );
        // Assert — both gone from live, both still in the table (trash).
        check(trashed).equals(2);
        check(await db.sessionLogsDao.getAll()).isEmpty();
        check(
          await db.sessionLogsDao.getAll(includeTrashed: true),
        ).length.equals(2);
      },
    );

    test('softDeleteOlderThan uses startedAt when endedAt is null', () async {
      // Arrange — never-finished log started long ago.
      await db.sessionLogsDao.upsert(
        SessionLog(
          id: 'never-ended',
          modeId: 'm',
          modeName: 'm',
          startedAt: t0,
          isSimulation: false,
          events: [
            SessionLogEvent(
              timestamp: t0,
              eventType: 'started',
              stepIndex: 0,
              description: 'started',
            ),
          ],
        ),
      );
      // Act
      final trashed = await db.sessionLogsDao.softDeleteOlderThan(
        t0.add(const Duration(hours: 1)),
        nowMs: t0.add(const Duration(hours: 1)).millisecondsSinceEpoch,
      );
      // Assert
      check(trashed).equals(1);
    });

    test('softDeleteOlderThan never re-stamps an already-trashed row (its '
        'trash clock is preserved)', () async {
      // Arrange — stale row already trashed at a known earlier stamp.
      await db.sessionLogsDao.upsert(_log('stale-trashed', t0));
      final originalStamp = t0.add(const Duration(days: 2));
      await db.sessionLogsDao.softDelete(
        'stale-trashed',
        originalStamp.millisecondsSinceEpoch,
      );
      // Act — age pass at a much later now.
      final trashed = await db.sessionLogsDao.softDeleteOlderThan(
        t0.add(const Duration(days: 30)),
        nowMs: t0.add(const Duration(days: 30)).millisecondsSinceEpoch,
      );
      // Assert — untouched: count 0, original stamp intact.
      check(trashed).equals(0);
      final row = await db.sessionLogsDao.getById('stale-trashed');
      check(row).isNotNull();
      check(row!.deletedAt).equals(originalStamp);
    });

    test('isCritical predicate flags destructive event types', () {
      // Critical: a smsContact step actually fired with delivery=sent.
      final critical = SessionLog(
        id: 'c',
        modeId: 'm',
        modeName: 'm',
        startedAt: t0,
        isSimulation: false,
        events: [
          SessionLogEvent(
            timestamp: t0,
            eventType: 'step_started',
            stepType: ChainStepType.smsContact.name,
            stepIndex: 0,
            description: 'sms',
            deliveryStatus: 'sent',
          ),
        ],
      );
      // Not critical: only hold-button events.
      final mundane = SessionLog(
        id: 'm',
        modeId: 'm',
        modeName: 'm',
        startedAt: t0,
        isSimulation: false,
        events: [
          SessionLogEvent(
            timestamp: t0,
            eventType: 'step_started',
            stepType: ChainStepType.holdButton.name,
            stepIndex: 0,
            description: 'hold',
          ),
        ],
      );
      check(SessionLogsDao.isCritical(critical)).isTrue();
      check(SessionLogsDao.isCritical(mundane)).isFalse();
    });

    test('deleteById removes the log', () async {
      await db.sessionLogsDao.upsert(_log('log-1', t0));
      await db.sessionLogsDao.deleteById('log-1');
      check(await db.sessionLogsDao.getById('log-1')).isNull();
    });

    test('watchAll emits the current list newest first', () async {
      // Arrange
      await db.sessionLogsDao.upsert(_log('a', t0));
      await db.sessionLogsDao.upsert(
        _log('b', t0.add(const Duration(hours: 1))),
      );
      // Act
      final first = await db.sessionLogsDao.watchAll().first;
      // Assert
      check(first.map((l) => l.id).toList()).deepEquals(['b', 'a']);
    });
  });

  // ---------------------------------------------------------------------
  // Soft-delete / restore / trash purge (spec 04:2455–2459 / spec 03:970)
  // ---------------------------------------------------------------------
  group('SessionLogsDao trash flow', () {
    test(
      'softDelete marks deletedAtMs and removes the row from getAll()',
      () async {
        // Arrange
        await db.sessionLogsDao.upsert(_log('a', t0));
        // Act
        final touched = await db.sessionLogsDao.softDelete(
          'a',
          t0.add(const Duration(days: 1)).millisecondsSinceEpoch,
        );
        // Assert — row remains in the table but is filtered out by default.
        check(touched).equals(1);
        check(await db.sessionLogsDao.getAll()).isEmpty();
        check(
          (await db.sessionLogsDao.getAll(includeTrashed: true)).single.id,
        ).equals('a');
      },
    );

    test('softDelete returns 0 when id is unknown', () async {
      final touched = await db.sessionLogsDao.softDelete(
        'missing',
        t0.millisecondsSinceEpoch,
      );
      check(touched).equals(0);
    });

    test('getTrashed returns trashed rows newest-deleted first', () async {
      // Arrange — three live logs, trash two at distinct times.
      await db.sessionLogsDao.upsert(_log('a', t0));
      await db.sessionLogsDao.upsert(
        _log('b', t0.add(const Duration(hours: 1))),
      );
      await db.sessionLogsDao.upsert(
        _log('c', t0.add(const Duration(hours: 2))),
      );
      await db.sessionLogsDao.softDelete(
        'a',
        t0.add(const Duration(days: 1)).millisecondsSinceEpoch,
      );
      await db.sessionLogsDao.softDelete(
        'b',
        t0.add(const Duration(days: 2)).millisecondsSinceEpoch,
      );
      // Act
      final trashed = await db.sessionLogsDao.getTrashed();
      // Assert — newest-deleted ('b') first.
      check(trashed.map((l) => l.id).toList()).deepEquals(['b', 'a']);
      // Live list now only contains 'c'.
      final live = await db.sessionLogsDao.getAll();
      check(live.map((l) => l.id).toList()).deepEquals(['c']);
    });

    test('getAllOrderedByStartDesc excludes trashed rows by default', () async {
      // Arrange
      await db.sessionLogsDao.upsert(_log('a', t0));
      await db.sessionLogsDao.upsert(
        _log('b', t0.add(const Duration(hours: 1))),
      );
      await db.sessionLogsDao.softDelete(
        'a',
        t0.add(const Duration(days: 1)).millisecondsSinceEpoch,
      );
      // Act
      final live = await db.sessionLogsDao.getAllOrderedByStartDesc();
      final all = await db.sessionLogsDao.getAllOrderedByStartDesc(
        includeTrashed: true,
      );
      // Assert
      check(live.map((l) => l.id).toList()).deepEquals(['b']);
      check(all.map((l) => l.id).toList()).deepEquals(['b', 'a']);
    });

    test('restore clears deletedAtMs and re-surfaces the row', () async {
      // Arrange
      await db.sessionLogsDao.upsert(_log('a', t0));
      await db.sessionLogsDao.softDelete(
        'a',
        t0.add(const Duration(days: 1)).millisecondsSinceEpoch,
      );
      check(await db.sessionLogsDao.getAll()).isEmpty();
      // Act
      final touched = await db.sessionLogsDao.restore('a');
      // Assert
      check(touched).equals(1);
      check((await db.sessionLogsDao.getAll()).single.id).equals('a');
      check((await db.sessionLogsDao.getById('a'))!.deletedAt).isNull();
    });

    test(
      'hardDeleteTrashedOlderThan deletes only trashed rows past cutoff',
      () async {
        // Arrange — three trashed rows at distinct deletion times.
        await db.sessionLogsDao.upsert(_log('a', t0));
        await db.sessionLogsDao.upsert(_log('b', t0));
        await db.sessionLogsDao.upsert(_log('c', t0));
        await db.sessionLogsDao.upsert(_log('live', t0));
        await db.sessionLogsDao.softDelete(
          'a',
          t0.subtract(const Duration(days: 30)).millisecondsSinceEpoch,
        );
        await db.sessionLogsDao.softDelete(
          'b',
          t0.subtract(const Duration(days: 10)).millisecondsSinceEpoch,
        );
        await db.sessionLogsDao.softDelete(
          'c',
          t0.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        );
        // Act — purge everything trashed before t0 - 7 days.
        final purged = await db.sessionLogsDao.hardDeleteTrashedOlderThan(
          t0.subtract(const Duration(days: 7)),
        );
        // Assert — 'a' and 'b' purged, 'c' survives, 'live' untouched.
        check(purged).equals(2);
        final remainingIds = (await db.sessionLogsDao.getAll(
          includeTrashed: true,
        )).map((l) => l.id).toSet();
        check(remainingIds).deepEquals({'c', 'live'});
      },
    );

    test('hardDeleteTrashedOlderThan never touches live rows', () async {
      // Arrange — live (non-trashed) row way past the cutoff.
      await db.sessionLogsDao.upsert(
        _log('old-live', t0.subtract(const Duration(days: 100))),
      );
      // Act
      final purged = await db.sessionLogsDao.hardDeleteTrashedOlderThan(t0);
      // Assert
      check(purged).equals(0);
      check((await db.sessionLogsDao.getAll()).single.id).equals('old-live');
    });
  });
}

SessionLog _log(String id, DateTime startedAt, {bool critical = false}) =>
    SessionLog(
      id: id,
      modeId: 'mode',
      modeName: 'Mode',
      startedAt: startedAt,
      endedAt: startedAt.add(const Duration(minutes: 5)),
      endReason: EndReason.disarm,
      isSimulation: false,
      events: [
        SessionLogEvent(
          timestamp: startedAt,
          eventType: 'started',
          stepIndex: 0,
          description: 'started',
        ),
        if (critical)
          SessionLogEvent(
            timestamp: startedAt,
            eventType: 'step_started',
            stepType: ChainStepType.smsContact.name,
            stepIndex: 1,
            description: 'sms sent',
            deliveryStatus: 'sent',
          ),
      ],
    );
