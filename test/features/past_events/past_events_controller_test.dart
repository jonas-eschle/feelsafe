/// Unit tests for [PastEventsController] and [outcomeFromEndReason]
/// against the REAL in-memory Drift DB.
///
/// Each test builds a fresh [ProviderContainer] whose `databaseProvider`
/// resolves to an isolated [GuardianAngelaDatabase.memory] (no seed), then
/// drives the real controller methods and asserts both the returned state
/// and the persisted rows. Plain `test()` (no widget pump) so
/// `ref.invalidateSelf()` re-runs `build()` without leaking timers.
///
/// SAFETY-CRITICAL invariant pinned in BOTH directions: the user-facing
/// list delete is a SOFT delete — even a CRITICAL log (recorded SMS
/// dispatch) stays in the database and is restorable; only the explicit
/// [PastEventsController.hardDelete] opt-out destroys the row.
///
/// Spec refs: `docs/spec/04-screens-navigation.md §Past Events`
/// (lines 2455–2459), `docs/spec/03-data-models.md` line 970 (trash flow).
library;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/dao/session_logs_dao.dart';
import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/session_log_repository.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/models/session_log.dart';
import 'package:guardianangela/domain/models/session_log_event.dart';
import 'package:guardianangela/features/past_events/past_events_controller.dart';
import 'package:guardianangela/services/service_providers.dart';

// ---------------------------------------------------------------------------
// Data factories
// ---------------------------------------------------------------------------

final DateTime _base = DateTime.utc(2026, 6, 1, 12);

/// A destructive-delivery event (makes the log CRITICAL per B8).
SessionLogEvent _smsSentEvent() => SessionLogEvent(
  timestamp: _base,
  eventType: 'step_fired',
  stepType: 'smsContact',
  stepIndex: 1,
  description: 'SMS sent to Bob',
  deliveryStatus: 'sent',
);

SessionLog _log({
  required String id,
  String modeName = 'Walk Mode',
  DateTime? startedAt,
  bool ended = true,
  EndReason endReason = EndReason.disarm,
  bool critical = false,
  bool isSimulation = false,
}) {
  final started = startedAt ?? _base;
  return SessionLog(
    id: id,
    modeId: 'walk-mode',
    modeName: modeName,
    startedAt: started,
    endedAt: ended ? started.add(const Duration(minutes: 7)) : null,
    endReason: ended ? endReason : null,
    isSimulation: isSimulation,
    events: <SessionLogEvent>[if (critical) _smsSentEvent()],
  );
}

void main() {
  group('outcomeFromEndReason', () {
    test('null and disarm map to completed', () {
      check(outcomeFromEndReason(null)).equals(PastEventOutcome.completed);
      check(
        outcomeFromEndReason(EndReason.disarm),
      ).equals(PastEventOutcome.completed);
    });

    test('every escalation reason maps to distress', () {
      for (final r in <EndReason>[
        EndReason.chainExhausted,
        EndReason.duressPin,
        EndReason.hardwarePanic,
        EndReason.wrongPinExhausted,
        EndReason.distressConfirmTimeout,
      ]) {
        check(
          because: '$r must badge as distress',
          outcomeFromEndReason(r),
        ).equals(PastEventOutcome.distress);
      }
    });

    test('userQuit maps to interrupted', () {
      check(
        outcomeFromEndReason(EndReason.userQuit),
      ).equals(PastEventOutcome.interrupted);
    });
  });

  group('PastEventsController', () {
    late GuardianAngelaDatabase db;
    late SessionLogRepository repo;
    late ProviderContainer container;

    setUp(() {
      db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
      repo = SessionLogRepository(db.sessionLogsDao);
      container = ProviderContainer(
        overrides: <Override>[databaseProvider.overrideWith((_) async => db)],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    Future<PastEventsState> state() =>
        container.read(pastEventsControllerProvider.future);

    group('build', () {
      test('maps ended logs to list rows newest-first', () async {
        await repo.upsert(
          _log(id: 'old', startedAt: _base, endReason: EndReason.userQuit),
        );
        await repo.upsert(
          _log(
            id: 'new',
            modeName: 'Date Mode',
            startedAt: _base.add(const Duration(hours: 3)),
            isSimulation: true,
          ),
        );

        final PastEventsState s = await state();

        check(s.logs.map((l) => l.id)).deepEquals(<String>['new', 'old']);
        final PastEventsLog newest = s.logs.first;
        check(newest.modeName).equals('Date Mode');
        check(newest.durationSeconds).equals(420);
        check(newest.isSimulation).isTrue();
        check(newest.outcome).equals(PastEventOutcome.completed);
        check(s.logs.last.outcome).equals(PastEventOutcome.interrupted);
      });

      test('hides in-progress marker rows (endedAt == null)', () async {
        await repo.upsert(_log(id: 'running', ended: false));
        await repo.upsert(_log(id: 'done'));

        final PastEventsState s = await state();

        check(s.logs.map((l) => l.id)).deepEquals(<String>['done']);
      });

      test('hides trashed rows', () async {
        await repo.upsert(_log(id: 'a'));
        await repo.softDelete('a', now: _base.add(const Duration(days: 1)));

        check((await state()).logs).isEmpty();
      });

      test('returns an empty list on an empty database', () async {
        check((await state()).logs).isEmpty();
      });
    });

    group('softDelete', () {
      test('moves a CRITICAL log to the trash without destroying it', () async {
        final critical = _log(id: 'a', critical: true);
        // Ground the fixture in the real B8 predicate, not a guess.
        check(SessionLogsDao.isCritical(critical)).isTrue();
        await repo.upsert(critical);
        final controller = container.read(
          pastEventsControllerProvider.notifier,
        );
        check((await state()).logs.length).equals(1);

        await controller.softDelete('a');

        // Gone from the live list (state was invalidated)…
        check((await state()).logs).isEmpty();
        // …but the evidence row still exists and sits in the trash.
        check(await repo.getById('a')).isNotNull();
        check(
          (await repo.getTrashed()).map((l) => l.id),
        ).deepEquals(<String>['a']);
      });
    });

    group('undoSoftDelete', () {
      test('restores the trashed log into the live list', () async {
        await repo.upsert(_log(id: 'a'));
        final controller = container.read(
          pastEventsControllerProvider.notifier,
        );
        await state();
        await controller.softDelete('a');
        check((await state()).logs).isEmpty();

        await controller.undoSoftDelete('a');

        check((await state()).logs.map((l) => l.id)).deepEquals(<String>['a']);
        check(await repo.getTrashed()).isEmpty();
      });
    });

    group('hardDelete', () {
      test('destroys the row entirely — not in list, not in trash', () async {
        await repo.upsert(_log(id: 'a'));
        final controller = container.read(
          pastEventsControllerProvider.notifier,
        );
        check((await state()).logs.length).equals(1);

        await controller.hardDelete('a');

        check((await state()).logs).isEmpty();
        check(await repo.getById('a')).isNull();
        check(await repo.getTrashed()).isEmpty();
      });
    });
  });
}
