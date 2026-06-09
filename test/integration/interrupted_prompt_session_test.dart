/// Host integration scenario INT-012 — cold-launch Session-Interrupted prompt
/// (spec 04 §Session-Interrupted Prompt, Extra-13; the M4-C4 feature proven
/// end-to-end).
///
/// This is the e2e proof of the interrupted-session detection that M4-C4 built.
/// It seeds an **orphan** [SessionLog] (a marker row written at `startSession`
/// that never received an `endedAt` — i.e. the app was force-killed mid-session)
/// directly into a real in-memory [GuardianAngelaDatabase], then builds the
/// **real** [SessionController] over that DB and asserts:
///   1. `SessionController.build()` detects the orphan and surfaces it via
///      `SessionState.priorInterrupted` + `priorModeId` / `priorModeName` /
///      `priorStartedAt` (the exact fields the home screen's `InterruptedPrompt`
///      renders at cold launch);
///   2. detection **deletes** the orphan so the prompt fires exactly once
///      (a second controller build over the same DB sees no prior session);
///   3. the **Acknowledge** path (`acknowledgeInterruptedPrompt`) clears the
///      in-memory flags.
///
/// **Spec reconciliation (Hard Rule 6 — carried for C8):** spec 07's INT-012
/// row says "seed an in-progress (orphan) `SessionLog` row (no `endedAt`)" —
/// that wording was already reconciled in C5 from the stale
/// `active_session_marker.json` to the real SessionLog marker. This test drives
/// that real marker: the orphan is a `SessionLog` with `endedAt == null`,
/// written through the same [SessionLogRepository.upsert] that `startSession`
/// uses (`session_controller.dart:652`). No separate JSON file exists.
///
/// **Duress-PIN carve-out (documented, not exercised here):** a cold-start
/// Duress-PIN distress run starts its session with `writeInterruptMarker:
/// false` (`session_controller.dart:1036`), so it never leaves an orphan and
/// never surfaces this prompt — a deliberate security exemption (revealing a
/// covert distress run to an attacker who force-stopped the app would defeat
/// the Duress PIN). That path writes no marker, so there is nothing to assert
/// against here; the carve-out is verified by the controller unit tests.
library;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/session_log_repository.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/models/session_log.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import '_session_harness.dart';

/// An orphan (in-progress) marker row: written at session start, never
/// finalised (`endedAt == null`) — the force-kill signature.
SessionLog _orphan({
  required String id,
  required String modeId,
  required String modeName,
  required DateTime startedAt,
}) => SessionLog(
  id: id,
  modeId: modeId,
  modeName: modeName,
  startedAt: startedAt,
  isSimulation: false,
  events: const [],
);

/// A normally-finalised log (has `endedAt` + `endReason`) — must NOT be
/// mistaken for an interrupted session.
SessionLog _finalised({
  required String id,
  required String modeName,
  required DateTime startedAt,
  required DateTime endedAt,
}) => SessionLog(
  id: id,
  modeId: 'mode-clean',
  modeName: modeName,
  startedAt: startedAt,
  endedAt: endedAt,
  endReason: EndReason.userQuit,
  isSimulation: false,
  events: const [],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GuardianAngelaDatabase db;
  late SessionLogRepository repo;

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
    repo = SessionLogRepository(db.sessionLogsDao);
  });

  tearDown(() async {
    await db.close();
  });

  ProviderContainer container() =>
      buildIntegrationContainer(db: db, fakes: RecordingFakes());

  test('INT-012 a seeded orphan SessionLog surfaces the interrupted-session '
      'prompt at cold launch with the mode name, id, and start time', () async {
    final startedAt = DateTime.utc(2026, 6, 9, 14, 30);
    await repo.upsert(
      _orphan(
        id: 'orphan-1',
        modeId: 'walk-mode-id',
        modeName: 'Walk Mode',
        startedAt: startedAt,
      ),
    );

    final c = container();
    // Building the controller runs build() → orphan detection.
    final state = await c.read(sessionControllerProvider.future);

    check(state.priorInterrupted).isTrue();
    check(state.priorModeId).equals('walk-mode-id');
    check(state.priorModeName).equals('Walk Mode');
    check(state.priorStartedAt).equals(startedAt);
    // No live session is running — the prompt is purely informational (the
    // in-memory-only policy means a killed session is gone; this is NOT a
    // resume, just a notification).
    check(c.read(sessionControllerProvider.notifier).isSessionActive).isFalse();
  });

  test('INT-012 detection deletes the orphan so the prompt fires exactly once '
      '(a second cold launch sees no prior interrupted session)', () async {
    await repo.upsert(
      _orphan(
        id: 'orphan-1',
        modeId: 'walk-mode-id',
        modeName: 'Walk Mode',
        startedAt: DateTime.utc(2026, 6, 9, 14, 30),
      ),
    );

    // First cold launch: prompt surfaces.
    final first = container();
    final firstState = await first.read(sessionControllerProvider.future);
    check(firstState.priorInterrupted).isTrue();

    // The orphan row was hard-deleted by build() so it never re-prompts.
    final remaining = await repo.getAll();
    check(remaining).isEmpty();

    // Second cold launch over the SAME db: no orphan → no prompt.
    final second = container();
    final secondState = await second.read(sessionControllerProvider.future);
    check(secondState.priorInterrupted).isFalse();
    check(secondState.priorModeId).isNull();
    check(secondState.priorModeName).isNull();
  });

  test('INT-012 a cleanly-finalised log (endedAt set) does NOT surface the '
      'prompt — only orphans with a null endedAt count', () async {
    final start = DateTime.utc(2026, 6, 9, 10);
    await repo.upsert(
      _finalised(
        id: 'clean-1',
        modeName: 'Date Mode',
        startedAt: start,
        endedAt: start.add(const Duration(minutes: 20)),
      ),
    );

    final c = container();
    final state = await c.read(sessionControllerProvider.future);

    check(state.priorInterrupted).isFalse();
    check(state.priorModeName).isNull();
    // The finalised log is untouched (only orphans are deleted by detection).
    final all = await repo.getAll();
    check(all.length).equals(1);
    check(all.first.id).equals('clean-1');
  });

  test('INT-012 the newest orphan wins when several are present, and ALL '
      'orphans are cleared (older killed sessions never re-prompt)', () async {
    final older = DateTime.utc(2026, 6, 8, 9);
    final newer = DateTime.utc(2026, 6, 9, 16);
    await repo.upsert(
      _orphan(
        id: 'orphan-old',
        modeId: 'mode-old',
        modeName: 'Old Walk',
        startedAt: older,
      ),
    );
    await repo.upsert(
      _orphan(
        id: 'orphan-new',
        modeId: 'mode-new',
        modeName: 'New Date',
        startedAt: newer,
      ),
    );

    final c = container();
    final state = await c.read(sessionControllerProvider.future);

    // The most-recent orphan is the one surfaced.
    check(state.priorInterrupted).isTrue();
    check(state.priorModeName).equals('New Date');
    check(state.priorModeId).equals('mode-new');
    check(state.priorStartedAt).equals(newer);
    // BOTH orphans were cleared (detection deletes every orphan).
    final remaining = await repo.getAll();
    check(remaining).isEmpty();
  });

  test('INT-012 Acknowledge clears the prompt flags (the orphan was already '
      'deleted at detection, so no second prompt can appear)', () async {
    await repo.upsert(
      _orphan(
        id: 'orphan-1',
        modeId: 'walk-mode-id',
        modeName: 'Walk Mode',
        startedAt: DateTime.utc(2026, 6, 9, 14, 30),
      ),
    );

    final c = container();
    final notifier = c.read(sessionControllerProvider.notifier);
    final before = await c.read(sessionControllerProvider.future);
    check(before.priorInterrupted).isTrue();

    // Acknowledge: dismiss the prompt.
    notifier.acknowledgeInterruptedPrompt();

    final after = c.read(sessionControllerProvider).requireValue;
    check(after.priorInterrupted).isFalse();
    check(after.priorModeId).isNull();
    check(after.priorModeName).isNull();
    check(after.priorStartedAt).isNull();
    // And the DB has no orphan to revive the prompt.
    check(await repo.getAll()).isEmpty();
  });
}
