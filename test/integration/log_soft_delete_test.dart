/// Host integration scenario INT-014 — soft-delete log restore + hard-purge
/// transitions (Extra-11; spec 04 §Past Events Trash, spec 03:970).
///
/// Drives the **real** [SessionLogRepository] over a real in-memory
/// [GuardianAngelaDatabase] through the full trash lifecycle:
///   live → softDelete (→ trash, `deletedAt` set, hidden from the live list) →
///   restore (→ live again, `deletedAt` cleared) → softDelete again →
///   hard-purge (either the timed `purgeExpiredLogs` trash window or the
///   explicit "Empty trash" `hardDeleteAllTrashed`).
///
/// The reference clock is injected (`softDelete(now:)` +
/// `purgeExpiredLogs(now:)`), so the trash-retention window is exercised as
/// pure values — no `package:clock` / `fake_async`.
///
/// **Key Extra-11 invariant proven:** the trash purge IGNORES criticality —
/// once the user has trashed a log and the `trashRetentionDays` window elapses
/// it is hard-deleted even though the same log would survive the age-based
/// retention purge indefinitely (spec 03:970, spec 04:2455–2459). A trashed
/// CRITICAL log is therefore deletable, unlike a live critical log.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/dao/session_logs_dao.dart';
import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/session_log_repository.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/models/session_log.dart';
import 'package:guardianangela/domain/models/session_log_event.dart';

SessionLogEvent _smsSentEvent(DateTime ts) => SessionLogEvent(
  timestamp: ts,
  eventType: 'step_fired',
  stepType: 'smsContact',
  stepIndex: 1,
  description: 'SMS sent',
  deliveryStatus: 'sent',
);

SessionLog _log({
  required String id,
  required DateTime startedAt,
  List<SessionLogEvent> events = const [],
}) => SessionLog(
  id: id,
  modeId: 'walk-mode',
  modeName: 'Walk Mode',
  startedAt: startedAt,
  endedAt: startedAt.add(const Duration(minutes: 5)),
  endReason: EndReason.userQuit,
  isSimulation: false,
  events: events,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GuardianAngelaDatabase db;
  late SessionLogRepository repo;

  final now = DateTime.utc(2026, 6, 9, 12);

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
    repo = SessionLogRepository(db.sessionLogsDao);
  });

  tearDown(() async {
    await db.close();
  });

  test('INT-014 softDelete moves a live log to the trash: hidden from the live '
      'list, present in getTrashed with deletedAt set', () async {
    await repo.upsert(_log(id: 'log-1', startedAt: now));
    check(
      (await repo.getAll()).map((l) => l.id).toList(),
    ).deepEquals(['log-1']);
    check(await repo.getTrashed()).isEmpty();

    await repo.softDelete('log-1', now: now);

    // Gone from the live list, present in the trash, deletedAt stamped.
    check(await repo.getAll()).isEmpty();
    final trashed = await repo.getTrashed();
    check(trashed.map((l) => l.id).toList()).deepEquals(['log-1']);
    check(trashed.first.deletedAt).equals(now);
    // The row still exists (getById returns trashed rows too).
    check((await repo.getById('log-1'))?.deletedAt).equals(now);
  });

  test(
    'INT-014 restore brings a trashed log back to live (deletedAt cleared)',
    () async {
      await repo.upsert(_log(id: 'log-1', startedAt: now));
      await repo.softDelete('log-1', now: now);
      check(await repo.getAll()).isEmpty();

      await repo.restore('log-1');

      // Back in the live list, out of the trash, deletedAt null.
      check(
        (await repo.getAll()).map((l) => l.id).toList(),
      ).deepEquals(['log-1']);
      check(await repo.getTrashed()).isEmpty();
      check((await repo.getById('log-1'))?.deletedAt).isNull();
    },
  );

  test('INT-014 a restored log survives a subsequent age-based retention purge '
      '(restore truly returns it to the live pool)', () async {
    await repo.upsert(_log(id: 'log-1', startedAt: now));
    await repo.softDelete('log-1', now: now);
    await repo.restore('log-1');

    // A live, recent log is not touched by the age purge.
    final deleted = await repo.purgeExpiredLogs(retentionDays: 30, now: now);
    check(deleted).equals(0);
    check(
      (await repo.getAll()).map((l) => l.id).toList(),
    ).deepEquals(['log-1']);
  });

  test('INT-014 the trash-retention window hard-purges a log trashed longer '
      'than trashRetentionDays ago, but keeps one trashed recently', () async {
    // Two logs, both trashed; one trashed 10 days ago, one trashed today.
    await repo.upsert(_log(id: 'old-trash', startedAt: now));
    await repo.upsert(_log(id: 'fresh-trash', startedAt: now));
    final tenDaysAgo = now.subtract(const Duration(days: 10));
    await repo.softDelete('old-trash', now: tenDaysAgo);
    await repo.softDelete('fresh-trash', now: now);
    check((await repo.getTrashed()).length).equals(2);

    // The default trash window is 7 days → the 10-day-old trash is purged,
    // the fresh one survives.
    final deleted = await repo.purgeExpiredLogs(retentionDays: 365, now: now);

    check(deleted).equals(1);
    final trashedNow = await repo.getTrashed();
    check(trashedNow.map((l) => l.id).toList()).deepEquals(['fresh-trash']);
  });

  test('INT-014 the trash purge IGNORES criticality: a trashed CRITICAL log '
      'past the window is hard-deleted (unlike a live critical log)', () async {
    // A critical log that would survive the age purge forever, but is trashed.
    final critical = _log(
      id: 'critical-trashed',
      startedAt: now,
      events: [_smsSentEvent(now)],
    );
    check(SessionLogsDao.isCritical(critical)).isTrue();
    await repo.upsert(critical);

    final tenDaysAgo = now.subtract(const Duration(days: 10));
    await repo.softDelete('critical-trashed', now: tenDaysAgo);

    // Even with an effectively-infinite age window, the elapsed default 7-day
    // trash window hard-deletes the trashed critical log.
    final deleted = await repo.purgeExpiredLogs(
      retentionDays: 100000,
      now: now,
    );

    check(deleted).equals(1);
    check(await repo.getTrashed()).isEmpty();
    check(await repo.getById('critical-trashed')).isNull();
  });

  test('INT-014 "Empty trash" (hardDeleteAllTrashed) removes every trashed row '
      'regardless of age while leaving live logs intact', () async {
    await repo.upsert(_log(id: 'live-1', startedAt: now));
    await repo.upsert(_log(id: 'trash-a', startedAt: now));
    await repo.upsert(_log(id: 'trash-b', startedAt: now));
    await repo.softDelete('trash-a', now: now);
    await repo.softDelete('trash-b', now: now);

    final removed = await repo.hardDeleteAllTrashed();

    check(removed).equals(2);
    check(await repo.getTrashed()).isEmpty();
    // The live log is untouched.
    check(
      (await repo.getAll()).map((l) => l.id).toList(),
    ).deepEquals(['live-1']);
  });
}
