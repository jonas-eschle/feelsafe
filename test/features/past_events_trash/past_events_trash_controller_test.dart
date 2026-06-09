/// Unit tests for [PastEventsTrashController] against the REAL in-memory
/// Drift DB and a recording fake [AppSettingsRepository].
///
/// Each test builds a fresh [ProviderContainer] whose `databaseProvider`
/// resolves to an isolated [GuardianAngelaDatabase.memory] (no seed), then
/// drives the real controller methods and asserts both the returned state
/// and the persisted rows. Plain `test()` (no widget pump) so
/// `ref.invalidateSelf()` re-runs `build()` without leaking timers.
///
/// SAFETY-CRITICAL invariants pinned in BOTH directions:
///   - restore really un-trashes: the restored log survives a purge that
///     hard-deletes its still-trashed sibling;
///   - Empty trash hard-deletes regardless of criticality, but never
///     touches live logs;
///   - the on-open purge honours `AppSettings.trashRetentionDays` (an
///     age that is fatal under the default window is kept under a
///     longer configured one).
///
/// The repository-layer purge/soft-delete semantics themselves are
/// proven by INT-013/INT-014 (`test/integration/log_retention_test.dart`
/// and `log_soft_delete_test.dart`); this file pins what the controller
/// ADDS on top: settings wiring, state shaping, and invalidations.
///
/// Spec ref: `docs/spec/04-screens-navigation.md §Past Events Trash`
/// (lines 2455–2459).
library;

import 'dart:io';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/dao/session_logs_dao.dart';
import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/data/repositories/session_log_repository.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/session_log.dart';
import 'package:guardianangela/domain/models/session_log_event.dart';
import 'package:guardianangela/features/past_events/past_events_controller.dart';
import 'package:guardianangela/features/past_events_trash/past_events_trash_controller.dart';
import 'package:guardianangela/services/service_providers.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeAppSettingsRepository extends AppSettingsRepository {
  _FakeAppSettingsRepository(this._current)
    : super(
        keyProvider: () async => '00' * 32,
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('past_events_trash_ctl_'),
      );

  final AppSettings _current;

  @override
  Future<AppSettings> load() async => _current;
}

/// Repository whose purge always throws — exercises the controller's
/// non-fatal catch path (build must still list the surviving rows).
class _ThrowingPurgeRepository extends SessionLogRepository {
  const _ThrowingPurgeRepository(super.dao);

  @override
  Future<int> purgeExpiredLogs({
    required int retentionDays,
    required DateTime now,
    int trashRetentionDays = 7,
  }) async => throw StateError('purge boom');
}

// ---------------------------------------------------------------------------
// Data factories — relative to the wall clock because the controller
// calls `DateTime.now().toUtc()` internally (no clock injection).
// ---------------------------------------------------------------------------

final DateTime _now = DateTime.now().toUtc();

/// A benign lifecycle event (does NOT make the log critical).
SessionLogEvent _benignEvent() => SessionLogEvent(
  timestamp: _now.subtract(const Duration(hours: 2)),
  eventType: 'started',
  stepType: 'holdButton',
  stepIndex: 0,
  description: 'session started',
);

/// A destructive-delivery event (makes the log CRITICAL per B8).
SessionLogEvent _smsSentEvent() => SessionLogEvent(
  timestamp: _now.subtract(const Duration(hours: 2)),
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
  DateTime? endedAt,
  bool ended = true,
  bool critical = false,
  bool isSimulation = false,
}) {
  final started = startedAt ?? _now.subtract(const Duration(hours: 2));
  return SessionLog(
    id: id,
    modeId: 'walk-mode',
    modeName: modeName,
    startedAt: started,
    endedAt: ended
        ? (endedAt ?? started.add(const Duration(minutes: 5)))
        : null,
    endReason: ended ? EndReason.userQuit : null,
    isSimulation: isSimulation,
    events: <SessionLogEvent>[
      if (critical) _smsSentEvent() else _benignEvent(),
    ],
  );
}

void main() {
  late GuardianAngelaDatabase db;
  late SessionLogRepository repo;
  late ProviderContainer container;

  /// Creates the container; [settings] defaults to `AppSettings()`
  /// (trashRetentionDays 7, sessionLogRetentionDays 180). Pass
  /// [extraOverrides] to swap in e.g. a throwing repository.
  void makeContainer({
    AppSettings settings = const AppSettings(),
    List<Override> extraOverrides = const <Override>[],
  }) {
    container = ProviderContainer(
      overrides: <Override>[
        databaseProvider.overrideWith((_) async => db),
        appSettingsRepositoryProvider.overrideWithValue(
          _FakeAppSettingsRepository(settings),
        ),
        ...extraOverrides,
      ],
    );
    addTearDown(container.dispose);
  }

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
    repo = SessionLogRepository(db.sessionLogsDao);
  });

  tearDown(() async {
    await db.close();
  });

  Future<PastEventsTrashState> state() =>
      container.read(pastEventsTrashControllerProvider.future);

  group('PastEventsTrashController.build', () {
    test('lists trashed rows with deletedAt and duration mapped', () async {
      makeContainer();
      // deletedAt round-trips through an epoch-millis column — pin the
      // fixture to millisecond precision so equality is exact.
      final trashedAt = DateTime.fromMillisecondsSinceEpoch(
        _now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        isUtc: true,
      );
      await repo.upsert(_log(id: 'a', isSimulation: true));
      await repo.softDelete('a', now: trashedAt);

      final PastEventsTrashState s = await state();

      check(s.retentionDays).equals(7);
      check(s.logs.length).equals(1);
      final PastEventsTrashLog row = s.logs.single;
      check(row.id).equals('a');
      check(row.modeName).equals('Walk Mode');
      check(row.durationSeconds).equals(300);
      check(row.isSimulation).isTrue();
      check(row.deletedAt).equals(trashedAt);
    });

    test('purges trash older than the default 7-day window on open', () async {
      makeContainer();
      await repo.upsert(_log(id: 'expired'));
      await repo.softDelete(
        'expired',
        now: _now.subtract(const Duration(days: 10)),
      );
      await repo.upsert(_log(id: 'fresh'));
      await repo.softDelete(
        'fresh',
        now: _now.subtract(const Duration(days: 1)),
      );

      final PastEventsTrashState s = await state();

      check(s.logs.map((l) => l.id)).deepEquals(<String>['fresh']);
      // Hard-deleted, not merely hidden.
      check(await repo.getById('expired')).isNull();
    });

    test(
      'honours a longer configured trashRetentionDays (same age kept)',
      () async {
        // Identical 10-day-old tombstone as the purge test above — under
        // trashRetentionDays=30 it must SURVIVE, pinning the settings
        // wiring in both directions.
        makeContainer(settings: const AppSettings(trashRetentionDays: 30));
        await repo.upsert(_log(id: 'a'));
        await repo.softDelete(
          'a',
          now: _now.subtract(const Duration(days: 10)),
        );

        final PastEventsTrashState s = await state();

        check(s.retentionDays).equals(30);
        check(s.logs.map((l) => l.id)).deepEquals(<String>['a']);
      },
    );

    test('maps an endedAt-null trashed row to durationSeconds 0', () async {
      makeContainer();
      await repo.upsert(_log(id: 'a', ended: false));
      await repo.softDelete('a', now: _now.subtract(const Duration(days: 1)));

      final PastEventsTrashState s = await state();

      check(s.logs.single.durationSeconds).equals(0);
    });

    test('purge failure is non-fatal — trash is still listed', () async {
      makeContainer(
        extraOverrides: <Override>[
          sessionLogRepositoryProvider.overrideWith(
            (_) async => _ThrowingPurgeRepository(db.sessionLogsDao),
          ),
        ],
      );
      await repo.upsert(_log(id: 'a'));
      await repo.softDelete('a', now: _now.subtract(const Duration(days: 1)));

      final PastEventsTrashState s = await state();

      check(s.logs.map((l) => l.id)).deepEquals(<String>['a']);
    });
  });

  group('PastEventsTrashController.restore', () {
    test('un-trashes the row so a later purge no longer deletes it', () async {
      makeContainer();
      // Two siblings trashed 6 days ago; only one is restored. A purge
      // 2 days later (tombstone age 8d > 7d window) hard-deletes the
      // still-trashed sibling — proving the restored row would have
      // died too had restore() not cleared deletedAt.
      final trashedAt = _now.subtract(const Duration(days: 6));
      await repo.upsert(_log(id: 'kept'));
      await repo.softDelete('kept', now: trashedAt);
      await repo.upsert(_log(id: 'doomed'));
      await repo.softDelete('doomed', now: trashedAt);
      final controller = container.read(
        pastEventsTrashControllerProvider.notifier,
      );
      await state();

      await controller.restore('kept');

      check(
        (await state()).logs.map((l) => l.id),
      ).deepEquals(<String>['doomed']);
      await repo.purgeExpiredLogs(
        retentionDays: 180,
        now: _now.add(const Duration(days: 2)),
      );
      check(await repo.getById('kept')).isNotNull();
      check(await repo.getById('doomed')).isNull();
    });

    test('invalidates the past-events list so the log reappears', () async {
      makeContainer();
      await repo.upsert(_log(id: 'a'));
      await repo.softDelete('a', now: _now.subtract(const Duration(days: 1)));
      // Prime the live-list provider BEFORE restoring — without the
      // cross-invalidate it would keep serving this cached empty state.
      final PastEventsState before = await container.read(
        pastEventsControllerProvider.future,
      );
      check(before.logs).isEmpty();
      final controller = container.read(
        pastEventsTrashControllerProvider.notifier,
      );
      await state();

      await controller.restore('a');

      final PastEventsState after = await container.read(
        pastEventsControllerProvider.future,
      );
      check(after.logs.map((l) => l.id)).deepEquals(<String>['a']);
    });
  });

  group('PastEventsTrashController.deletePermanently', () {
    test('hard-deletes only the given row and refreshes state', () async {
      makeContainer();
      await repo.upsert(_log(id: 'a'));
      await repo.softDelete('a', now: _now.subtract(const Duration(days: 1)));
      await repo.upsert(_log(id: 'b'));
      await repo.softDelete('b', now: _now.subtract(const Duration(days: 1)));
      final controller = container.read(
        pastEventsTrashControllerProvider.notifier,
      );
      await state();

      await controller.deletePermanently('a');

      check(await repo.getById('a')).isNull();
      check((await state()).logs.map((l) => l.id)).deepEquals(<String>['b']);
    });
  });

  group('PastEventsTrashController.emptyTrash', () {
    test('hard-deletes ALL trashed rows — critical included — and spares '
        'live ones', () async {
      makeContainer();
      final criticalTrashed = _log(id: 'crit-trash', critical: true);
      // Ground the fixture in the real B8 predicate, not a guess.
      check(SessionLogsDao.isCritical(criticalTrashed)).isTrue();
      await repo.upsert(criticalTrashed);
      await repo.softDelete(
        'crit-trash',
        now: _now.subtract(const Duration(days: 1)),
      );
      await repo.upsert(_log(id: 'benign-trash'));
      await repo.softDelete(
        'benign-trash',
        now: _now.subtract(const Duration(days: 1)),
      );
      await repo.upsert(_log(id: 'live', critical: true));
      final controller = container.read(
        pastEventsTrashControllerProvider.notifier,
      );
      await state();

      final int purged = await controller.emptyTrash();

      check(purged).equals(2);
      check(await repo.getById('crit-trash')).isNull();
      check(await repo.getById('benign-trash')).isNull();
      check(await repo.getById('live')).isNotNull();
      check((await state()).logs).isEmpty();
    });

    test('returns 0 when the trash is already empty', () async {
      makeContainer();
      final controller = container.read(
        pastEventsTrashControllerProvider.notifier,
      );
      await state();

      check(await controller.emptyTrash()).equals(0);
    });
  });
}
