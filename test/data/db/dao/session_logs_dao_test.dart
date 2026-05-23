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
      'deleteOlderThan keeps critical logs even when older than cutoff',
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
        final removed = await db.sessionLogsDao.deleteOlderThan(
          t0.add(const Duration(days: 5)),
        );
        // Assert — only `old-mundane` is purged.
        check(removed).equals(1);
        final remaining = (await db.sessionLogsDao.getAll())
            .map((l) => l.id)
            .toSet();
        check(
          remaining,
        ).deepEquals({'old-critical', 'recent-critical', 'recent-mundane'});
      },
    );

    test(
      'deleteOlderThan with keepCritical=false purges every stale log',
      () async {
        // Arrange
        await db.sessionLogsDao.upsert(
          _log('old-critical', t0, critical: true),
        );
        await db.sessionLogsDao.upsert(_log('old-mundane', t0));
        // Act
        final removed = await db.sessionLogsDao.deleteOlderThan(
          t0.add(const Duration(days: 1)),
          keepCritical: false,
        );
        // Assert
        check(removed).equals(2);
        check(await db.sessionLogsDao.getAll()).isEmpty();
      },
    );

    test('deleteOlderThan uses startedAt when endedAt is null', () async {
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
      final removed = await db.sessionLogsDao.deleteOlderThan(
        t0.add(const Duration(hours: 1)),
      );
      // Assert
      check(removed).equals(1);
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
