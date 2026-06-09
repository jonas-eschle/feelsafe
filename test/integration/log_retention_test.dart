/// Host integration scenario INT-013 — smart log retention (decision B8).
///
/// Drives the **real** [SessionLogRepository] over a real in-memory
/// [GuardianAngelaDatabase] (no mocks, no fakes) with the reference clock
/// injected via [SessionLogRepository.purgeExpiredLogs]'s `now` parameter — so
/// "advancing the clock" is a pure value, no `package:clock` / `fake_async`
/// needed. It proves the B8 smart-retention contract:
///   - a NON-critical log older than the retention window is purged;
///   - a CRITICAL log (one that recorded a destructive action — an SMS/phone/
///     emergency/loud-alarm step that actually fired, by event-type or by a
///     `sent`/`queued` delivery status) is kept indefinitely regardless of age;
///   - a log inside the retention window is kept;
///   - the reference time is `endedAt ?? startedAt` (an old-start but
///     recently-ended session is judged by `endedAt`);
///   - `purgeExpiredLogs` returns the number of rows actually deleted.
///
/// Criticality matches the real DAO predicate
/// (`SessionLogsDao._eventIndicatesDestructiveAction`): destructive step types
/// are `{smsContact, phoneCallContact, callEmergency, loudAlarm}`; "fired"
/// event types are `{step_started, stepAdvancing, step_fired}`; and ANY event
/// with delivery status in `{sent, queued}` is destructive on its own. The
/// public `SessionLogsDao.isCritical` predicate is asserted alongside the
/// purge so the fixtures are grounded in the real rule, not a guess.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/dao/session_logs_dao.dart';
import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/session_log_repository.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/models/session_log.dart';
import 'package:guardianangela/domain/models/session_log_event.dart';

/// A non-critical event: a benign lifecycle marker on a non-destructive step.
SessionLogEvent _benignEvent(DateTime ts) => SessionLogEvent(
  timestamp: ts,
  eventType: 'started',
  stepType: 'holdButton',
  stepIndex: 0,
  description: 'session started',
);

/// A critical event by DESTRUCTIVE delivery: an SMS that was actually sent.
SessionLogEvent _smsSentEvent(DateTime ts) => SessionLogEvent(
  timestamp: ts,
  eventType: 'step_fired',
  stepType: 'smsContact',
  stepIndex: 1,
  description: 'SMS sent to Bob',
  deliveryStatus: 'sent',
);

SessionLog _log({
  required String id,
  required DateTime startedAt,
  DateTime? endedAt,
  required List<SessionLogEvent> events,
  bool isSimulation = false,
}) => SessionLog(
  id: id,
  modeId: 'walk-mode',
  modeName: 'Walk Mode',
  startedAt: startedAt,
  endedAt: endedAt,
  endReason: endedAt == null ? null : EndReason.userQuit,
  isSimulation: isSimulation,
  events: events,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GuardianAngelaDatabase db;
  late SessionLogRepository repo;

  // A fixed "now" — purge is judged against (now - retentionDays).
  final now = DateTime.utc(2026, 6, 9, 12);

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
    repo = SessionLogRepository(db.sessionLogsDao);
  });

  tearDown(() async {
    await db.close();
  });

  test('INT-013 retention purges a stale NON-critical log but keeps a CRITICAL '
      'one of the same age (B8 smart retention)', () async {
    // Both ended 40 days ago — well past a 30-day window.
    final fortyDaysAgo = now.subtract(const Duration(days: 40));
    final benign = _log(
      id: 'benign-old',
      startedAt: fortyDaysAgo,
      endedAt: fortyDaysAgo.add(const Duration(minutes: 10)),
      events: [_benignEvent(fortyDaysAgo)],
    );
    final critical = _log(
      id: 'critical-old',
      startedAt: fortyDaysAgo,
      endedAt: fortyDaysAgo.add(const Duration(minutes: 10)),
      events: [_benignEvent(fortyDaysAgo), _smsSentEvent(fortyDaysAgo)],
    );
    await repo.upsert(benign);
    await repo.upsert(critical);

    // Ground the fixtures in the REAL criticality predicate.
    check(SessionLogsDao.isCritical(benign)).isFalse();
    check(SessionLogsDao.isCritical(critical)).isTrue();

    final deleted = await repo.purgeExpiredLogs(retentionDays: 30, now: now);

    // Exactly the one non-critical stale log was deleted.
    check(deleted).equals(1);
    final remaining = await repo.getAll();
    check(remaining.map((l) => l.id).toList()).deepEquals(['critical-old']);
  });

  test('INT-013 a log INSIDE the retention window is kept even when '
      'non-critical', () async {
    final tenDaysAgo = now.subtract(const Duration(days: 10));
    await repo.upsert(
      _log(
        id: 'recent-benign',
        startedAt: tenDaysAgo,
        endedAt: tenDaysAgo.add(const Duration(minutes: 5)),
        events: [_benignEvent(tenDaysAgo)],
      ),
    );

    final deleted = await repo.purgeExpiredLogs(retentionDays: 30, now: now);

    check(deleted).equals(0);
    check(
      (await repo.getAll()).map((l) => l.id).toList(),
    ).deepEquals(['recent-benign']);
  });

  test('INT-013 the retention reference time is endedAt (not startedAt): an '
      'old-start session that ended recently is kept', () async {
    // Started 40 days ago but only ended yesterday → judged by endedAt, inside
    // a 30-day window.
    final start = now.subtract(const Duration(days: 40));
    final end = now.subtract(const Duration(days: 1));
    await repo.upsert(
      _log(
        id: 'long-running',
        startedAt: start,
        endedAt: end,
        events: [_benignEvent(start)],
      ),
    );

    final deleted = await repo.purgeExpiredLogs(retentionDays: 30, now: now);

    check(deleted).equals(0);
    check(
      (await repo.getAll()).map((l) => l.id).toList(),
    ).deepEquals(['long-running']);
  });

  test(
    'INT-013 an orphan (no endedAt) is judged by startedAt for retention',
    () async {
      // No endedAt → reference time falls back to startedAt (40 days ago).
      final start = now.subtract(const Duration(days: 40));
      await repo.upsert(
        _log(id: 'old-orphan', startedAt: start, events: [_benignEvent(start)]),
      );

      final deleted = await repo.purgeExpiredLogs(retentionDays: 30, now: now);

      check(deleted).equals(1);
      check(await repo.getAll()).isEmpty();
    },
  );

  test('INT-013 a mixed cohort: stale non-critical purged, stale critical + '
      'recent both survive, with the correct delete count', () async {
    final stale = now.subtract(const Duration(days: 45));
    final recent = now.subtract(const Duration(days: 3));

    await repo.upsert(
      _log(
        id: 'a-stale-benign',
        startedAt: stale,
        endedAt: stale,
        events: [_benignEvent(stale)],
      ),
    );
    await repo.upsert(
      _log(
        id: 'b-stale-critical',
        startedAt: stale,
        endedAt: stale,
        events: [_smsSentEvent(stale)],
      ),
    );
    await repo.upsert(
      _log(
        id: 'c-recent-benign',
        startedAt: recent,
        endedAt: recent,
        events: [_benignEvent(recent)],
      ),
    );

    final deleted = await repo.purgeExpiredLogs(retentionDays: 30, now: now);

    // Only the stale non-critical log goes.
    check(deleted).equals(1);
    final surviving = (await repo.getAll()).map((l) => l.id).toList()..sort();
    check(surviving).deepEquals(['b-stale-critical', 'c-recent-benign']);
  });
}
