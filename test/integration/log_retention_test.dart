/// Host integration scenario INT-013 — smart log retention (decision B8).
///
/// Drives the **real** [SessionLogRepository] over a real in-memory
/// [GuardianAngelaDatabase] (no mocks, no fakes) with the reference clock
/// injected via [SessionLogRepository.purgeExpiredLogs]'s `now` parameter — so
/// "advancing the clock" is a pure value, no `package:clock` / `fake_async`
/// needed. It proves the B8 smart-retention contract, which is TWO-STAGE
/// (spec 03:966–967):
///   - a NON-critical log older than the retention window is SOFT-deleted
///     into the recoverable trash (stage 1), and hard-deleted only after a
///     further `trashRetentionDays` elapses (stage 2, Extra-11);
///   - a CRITICAL log (one that recorded a destructive action — an SMS/phone/
///     emergency/loud-alarm step that actually fired, by event-type or by a
///     `sent`/`queued` delivery status) is kept LIVE indefinitely regardless
///     of age;
///   - a log inside the retention window is kept;
///   - the reference time is `endedAt ?? startedAt` (an old-start but
///     recently-ended session is judged by `endedAt`);
///   - an already-trashed row is never re-stamped by the age pass (its trash
///     clock keeps running) and is governed by the trash pass alone;
///   - `purgeExpiredLogs` returns a per-stage `PurgeResult`
///     (`movedToTrash` / `hardDeleted`).
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

    final result = await repo.purgeExpiredLogs(retentionDays: 30, now: now);

    // Exactly the one non-critical stale log was moved to the trash.
    check(result).equals((movedToTrash: 1, hardDeleted: 0));
    final remaining = await repo.getAll();
    check(remaining.map((l) => l.id).toList()).deepEquals(['critical-old']);
    check(
      (await repo.getTrashed()).map((l) => l.id).toList(),
    ).deepEquals(['benign-old']);
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

    final result = await repo.purgeExpiredLogs(retentionDays: 30, now: now);

    check(result).equals((movedToTrash: 0, hardDeleted: 0));
    check(
      (await repo.getAll()).map((l) => l.id).toList(),
    ).deepEquals(['recent-benign']);
    check(await repo.getTrashed()).isEmpty();
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

    final result = await repo.purgeExpiredLogs(retentionDays: 30, now: now);

    check(result).equals((movedToTrash: 0, hardDeleted: 0));
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

      final result = await repo.purgeExpiredLogs(retentionDays: 30, now: now);

      check(result).equals((movedToTrash: 1, hardDeleted: 0));
      check(await repo.getAll()).isEmpty();
      // Stage 1 only: the orphan is in the trash, not destroyed.
      check(
        (await repo.getTrashed()).map((l) => l.id).toList(),
      ).deepEquals(['old-orphan']);
    },
  );

  test('INT-013 two-stage retention (B8 step 5 + Extra-11): an aged benign '
      'live log is SOFT-deleted into the trash (recoverable), hard-deleted '
      'only after trashRetentionDays; an aged CRITICAL live log stays '
      'live', () async {
    final fortyDaysAgo = now.subtract(const Duration(days: 40));
    final benign = _log(
      id: 'aged-benign',
      startedAt: fortyDaysAgo,
      endedAt: fortyDaysAgo.add(const Duration(minutes: 10)),
      events: [_benignEvent(fortyDaysAgo)],
    );
    final critical = _log(
      id: 'aged-critical',
      startedAt: fortyDaysAgo,
      endedAt: fortyDaysAgo.add(const Duration(minutes: 10)),
      events: [_smsSentEvent(fortyDaysAgo)],
    );
    await repo.upsert(benign);
    await repo.upsert(critical);
    check(SessionLogsDao.isCritical(benign)).isFalse();
    check(SessionLogsDao.isCritical(critical)).isTrue();

    // FIRST purge — stage 1: the aged benign log is moved to the trash,
    // NOT destroyed (spec 03:966 "soft-delete the log into the trash box").
    final first = await repo.purgeExpiredLogs(retentionDays: 30, now: now);
    check(first).equals((movedToTrash: 1, hardDeleted: 0));

    final afterFirst = await repo.getById('aged-benign');
    check(afterFirst).isNotNull(); // the row still exists…
    check(afterFirst!.deletedAt).equals(now); // …stamped with the purge time,
    check(
      (await repo.getTrashed()).map((l) => l.id).toList(),
    ).deepEquals(['aged-benign']); // …recoverable from the Trash screen,
    check(
      (await repo.getAll()).map((l) => l.id).toList(),
    ).deepEquals(['aged-critical']); // …hidden from live; CRITICAL stays live.

    // SECOND purge with now advanced past the default 7-day trash window —
    // stage 2: the trashed row is hard-deleted; the critical log is STILL
    // live and was never trashed.
    final later = now.add(const Duration(days: 8));
    final second = await repo.purgeExpiredLogs(retentionDays: 30, now: later);
    check(second).equals((movedToTrash: 0, hardDeleted: 1));
    check(await repo.getById('aged-benign')).isNull();
    check(await repo.getTrashed()).isEmpty();
    check(
      (await repo.getAll()).map((l) => l.id).toList(),
    ).deepEquals(['aged-critical']);
  });

  test('INT-013 the age pass never re-stamps an already-trashed row: its '
      'trash clock keeps running and it survives the purge inside the trash '
      'window even when its reference time is past the age cutoff', () async {
    // Benign log whose reference time is way past the 30-day age cutoff…
    final fortyDaysAgo = now.subtract(const Duration(days: 40));
    await repo.upsert(
      _log(
        id: 'aged-trashed',
        startedAt: fortyDaysAgo,
        endedAt: fortyDaysAgo,
        events: [_benignEvent(fortyDaysAgo)],
      ),
    );
    // …that the user trashed 5 days ago — INSIDE the 7-day trash window.
    final fiveDaysAgo = now.subtract(const Duration(days: 5));
    await repo.softDelete('aged-trashed', now: fiveDaysAgo);

    final result = await repo.purgeExpiredLogs(retentionDays: 30, now: now);
    check(result).equals((movedToTrash: 0, hardDeleted: 0));

    // Still recoverable, with the ORIGINAL trash stamp (no clock reset).
    final trashed = await repo.getTrashed();
    check(trashed.map((l) => l.id).toList()).deepEquals(['aged-trashed']);
    check(trashed.single.deletedAt).equals(fiveDaysAgo);

    // Its trash clock kept running: 3 more days (5 + 3 = 8 > 7) → gone.
    final second = await repo.purgeExpiredLogs(
      retentionDays: 30,
      now: now.add(const Duration(days: 3)),
    );
    check(second).equals((movedToTrash: 0, hardDeleted: 1));
    check(await repo.getById('aged-trashed')).isNull();
  });

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

    final result = await repo.purgeExpiredLogs(retentionDays: 30, now: now);

    // Only the stale non-critical log leaves the live list — into trash.
    check(result).equals((movedToTrash: 1, hardDeleted: 0));
    final surviving = (await repo.getAll()).map((l) => l.id).toList()..sort();
    check(surviving).deepEquals(['b-stale-critical', 'c-recent-benign']);
    check(
      (await repo.getTrashed()).map((l) => l.id).toList(),
    ).deepEquals(['a-stale-benign']);
  });
}
