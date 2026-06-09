/// Unit tests for [SimulationSummaryController] against the REAL
/// in-memory Drift DB.
///
/// The log under summary is persisted through the real
/// [SessionLogRepository] (the default provider derives it from the
/// overridden `databaseProvider`), so [SimulationSummaryController.build]
/// round-trips actual Drift serialisation rather than a canned in-memory
/// blob. PIN gating runs against a recording fake
/// [AppSettingsRepository] holding a real sha256 hash. Plain `test()` +
/// bare [ProviderContainer] so `ref.invalidateSelf()` re-runs `build()`
/// without leaking timers.
///
/// Spec ref: `docs/spec/04-screens-navigation.md §Simulation Summary
/// Screen` (lines 1202–1288: load by route id, PIN prompt, skip).
library;

import 'dart:convert' show utf8;
import 'dart:io';

import 'package:checks/checks.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/session_log.dart';
import 'package:guardianangela/domain/models/session_log_event.dart';
import 'package:guardianangela/features/simulation_summary/simulation_summary_controller.dart';
import 'package:guardianangela/services/service_providers.dart';

class _FakeAppSettingsRepository extends AppSettingsRepository {
  _FakeAppSettingsRepository(this._current)
    : super(
        keyProvider: () async => '00' * 32,
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('sim_summary_ctl_'),
      );

  final AppSettings _current;

  @override
  Future<AppSettings> load() async => _current;
}

String _hash(String pin) => sha256.convert(utf8.encode(pin)).toString();

/// A realistic simulation log shaped like the recorder output: a start
/// marker, two fired steps (one distress), and one missed check-in.
SessionLog _recordedLog({String id = 'log-1'}) {
  final start = DateTime.utc(2026, 1, 1, 12);
  return SessionLog(
    id: id,
    modeId: 'walk',
    modeName: 'Walk Mode',
    startedAt: start,
    endedAt: start.add(const Duration(minutes: 5, seconds: 23)),
    endReason: EndReason.chainExhausted,
    isSimulation: true,
    events: <SessionLogEvent>[
      SessionLogEvent(
        timestamp: start,
        eventType: 'started',
        stepIndex: 0,
        description: 'Session started',
      ),
      SessionLogEvent(
        timestamp: start.add(const Duration(minutes: 1)),
        eventType: 'missed',
        stepIndex: 0,
        description: 'Check-in missed',
      ),
      SessionLogEvent(
        timestamp: start.add(const Duration(minutes: 2)),
        eventType: 'step_fired',
        stepIndex: 1,
        description: 'SMS sent to contact',
      ),
      SessionLogEvent(
        timestamp: start.add(const Duration(minutes: 3)),
        eventType: 'step_fired',
        stepIndex: 2,
        description: 'distress chain escalation',
      ),
    ],
  );
}

void main() {
  late GuardianAngelaDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  void buildContainer({String? pinHash}) {
    container = ProviderContainer(
      overrides: <Override>[
        databaseProvider.overrideWith((_) async => db),
        appSettingsRepositoryProvider.overrideWithValue(
          _FakeAppSettingsRepository(AppSettings(sessionEndPinHash: pinHash)),
        ),
      ],
    );
  }

  Future<SimulationSummaryState> state() =>
      container.read(simulationSummaryControllerProvider.future);

  SimulationSummaryController controller() =>
      container.read(simulationSummaryControllerProvider.notifier);

  group('SimulationSummaryController.build', () {
    test('yields an unlocked null-log state before loadFor', () async {
      buildContainer();

      final SimulationSummaryState s = await state();

      check(s.log).isNull();
      check(s.pinRequired).isFalse();
      check(s.pinUnlocked).isTrue();
    });

    test('loadFor loads the persisted log through the real repo', () async {
      buildContainer();
      final repo = await container.read(sessionLogRepositoryProvider.future);
      await repo.upsert(_recordedLog());
      await state();

      controller().loadFor('log-1');
      final SimulationSummaryState s = await state();

      check(s.log).isNotNull();
      check(s.log!.modeName).equals('Walk Mode');
      check(s.log!.isSimulation).isTrue();
      check(s.log!.events.length).equals(4);
      // No PIN configured: the summary is immediately visible.
      check(s.pinRequired).isFalse();
      check(s.pinUnlocked).isTrue();
      // Derived counters over the recorded events.
      check(s.missedCount).equals(1);
      check(s.stepsFiredCount).equals(2);
      check(s.distressCount).equals(1);
      check(s.durationSeconds).equals(5 * 60 + 23);
    });

    test('loadFor with the same id does not rebuild', () async {
      buildContainer();
      final repo = await container.read(sessionLogRepositoryProvider.future);
      await repo.upsert(_recordedLog());
      controller().loadFor('log-1');
      final SimulationSummaryState s1 = await state();

      controller().loadFor('log-1');
      final SimulationSummaryState s2 = await state();

      // An early return keeps the exact same state instance; a rebuild
      // would re-read the row and produce a fresh object.
      check(identical(s1, s2)).isTrue();
    });

    test('loadFor with an unknown id yields a null log', () async {
      buildContainer();
      await state();

      controller().loadFor('nope');

      check((await state()).log).isNull();
    });

    test('requires the PIN when a session-end PIN hash is set', () async {
      buildContainer(pinHash: _hash('1234'));
      final repo = await container.read(sessionLogRepositoryProvider.future);
      await repo.upsert(_recordedLog());
      await state();

      controller().loadFor('log-1');
      final SimulationSummaryState s = await state();

      check(s.pinRequired).isTrue();
      check(s.pinUnlocked).isFalse();
      check(s.log).isNotNull();
    });
  });

  group('SimulationSummaryController.submitPin', () {
    Future<void> loadLocked() async {
      buildContainer(pinHash: _hash('1234'));
      final repo = await container.read(sessionLogRepositoryProvider.future);
      await repo.upsert(_recordedLog());
      await state();
      controller().loadFor('log-1');
      await state();
    }

    test('a wrong PIN sets pinError and stays locked', () async {
      await loadLocked();

      await controller().submitPin('9999');

      final SimulationSummaryState s = await state();
      check(s.pinError).isTrue();
      check(s.pinUnlocked).isFalse();
    });

    test('clearPinError resets the error flag only', () async {
      await loadLocked();
      await controller().submitPin('9999');

      controller().clearPinError();

      final SimulationSummaryState s = await state();
      check(s.pinError).isFalse();
      check(s.pinUnlocked).isFalse();
    });

    test('the matching PIN unlocks the summary', () async {
      await loadLocked();
      await controller().submitPin('9999');

      await controller().submitPin('1234');

      final SimulationSummaryState s = await state();
      check(s.pinUnlocked).isTrue();
      check(s.pinError).isFalse();
    });
  });

  group('SimulationSummaryState.copyWith', () {
    test('preserves every unspecified field', () {
      const SimulationSummaryState s = SimulationSummaryState(
        log: null,
        pinRequired: true,
        pinUnlocked: false,
        pinError: true,
      );

      final SimulationSummaryState c = s.copyWith(pinUnlocked: true);

      check(c.pinUnlocked).isTrue();
      check(c.pinRequired).isTrue();
      check(c.pinError).isTrue();
      check(c.log).isNull();
    });
  });

  group('SimulationSummaryController.skipPin', () {
    test('reveals the summary without a PIN', () async {
      buildContainer(pinHash: _hash('1234'));
      final repo = await container.read(sessionLogRepositoryProvider.future);
      await repo.upsert(_recordedLog());
      await state();
      controller().loadFor('log-1');
      await state();

      controller().skipPin();

      final SimulationSummaryState s = await state();
      check(s.pinUnlocked).isTrue();
      check(s.pinError).isFalse();
      check(s.log!.modeName).equals('Walk Mode');
    });
  });
}
