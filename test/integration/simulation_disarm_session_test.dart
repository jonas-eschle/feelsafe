/// Host integration scenarios INT-009 / INT-010 — simulation leap & disarm.
///
/// INT-009 drives the **real** [SessionController] simulation `leap()` (the
/// "skip to next event" time-compression, decision D2) under `fakeAsync`,
/// proving the engine collapses the current phase timer and transitions cleanly
/// without leaking a stale remaining time. INT-010 drives the **real** disarm
/// path against a chain that has already queued an SMS, asserting the genuine
/// disarm behavior — and documenting a real spec/code divergence for the C8
/// spec-07 reconciliation (decision A5).
///
/// **Orchestrator-API reconciliations (Hard Rule 6):**
/// - INT-009's bare `engine.leap()` → the wired entry point is
///   `controller.leap()` (→ `engine.leap()`); `leap()` throws on a non-sim
///   engine, so the session is started with `simulate: true`. In a simulation
///   session `SessionController._dispatchStep` is a Layer-1 no-op, so the fake
///   services record nothing — INT-009 asserts the engine *state*/*phase*
///   transition, exactly what decision D2 specifies.
///
/// - **INT-010 is a genuine spec-vs-code divergence (REAL FINDING, reconciled —
///   not vacuous; flagged for C8).** The spec sketch has the orchestrator
///   capture the `MessageWorkId` returned by `sendMessage` via
///   `registerSmsWorkId`, then on disarm call an orchestrator `cleanDisarm()`
///   that invokes `MessagingServiceProtocol.cancelPending(workIds)`. In the
///   real code **none of that wiring exists**:
///     * `MessagingServiceProtocol` declares ONLY `sendMessage`; `cancelPending`
///       lives only on the concrete `RealMessagingService` /
///       `SimulationMessagingService`, NOT on the interface the orchestrator
///       holds.
///     * `EventStrategy.executeReal` returns `Future<void>`, so the
///       `MessageWorkId` from `sendMessage` is **discarded at the strategy
///       boundary** — the controller never sees or stores it.
///     * `SessionController.disarm()` is just `engine.disarm()`; there is no
///       `cleanDisarm` / `registerSmsWorkId` / `cancelPending` call anywhere in
///       the session flow (grep of `lib/features/` = 0).
///   So a queued Android SMS WorkManager job is **not** cancelled on disarm
///   today. This test therefore asserts the *faithful* real disarm behavior
///   (the SMS genuinely fired; disarm re-arms to step 0 and emits exactly one
///   `userDisarmed`; the chain does not advance to callEmergency) and proves no
///   `cancelPending` mechanism is reachable from the controller. The A5
///   SMS-cancel-on-disarm feature is unbuilt — carried to the C8 spec-07
///   reconciliation list.
library;

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart' hide EnginePhase;

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/engine/chain_event.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import '_session_harness.dart';

EmergencyContact _bob() => EmergencyContact(
  id: 'contact-bob',
  name: 'Bob',
  phoneNumber: '+15551112222',
  sortOrder: 0,
);

ChainStep _smsStep({required int dur, required int grace}) => ChainStep(
  id: 'sms',
  type: ChainStepType.smsContact,
  order: 0,
  waitSeconds: 0,
  durationSeconds: dur,
  gracePeriodSeconds: grace,
  retryCount: 0,
  randomize: false,
  config: const SmsContactConfig(),
);

ChainStep _emergencyStep() => ChainStep(
  id: 'emergency',
  type: ChainStepType.callEmergency,
  order: 1,
  waitSeconds: 0,
  durationSeconds: 5,
  gracePeriodSeconds: 1,
  retryCount: 0,
  randomize: false,
  config: const CallEmergencyConfig(),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GuardianAngelaDatabase db;

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
  });

  tearDown(() async {
    await db.close();
  });

  test('INT-009 simulation leap collapses the duration timer and transitions '
      'to grace with no stale remaining', () {
    fakeAsync((async) {
      final fakes = RecordingFakes(contacts: [_bob()]);
      final container = buildIntegrationContainer(db: db, fakes: fakes);
      final mode = SessionMode(
        id: 'sim-leap',
        name: 'Walk Mode',
        chainSteps: [_smsStep(dur: 30, grace: 10), _emergencyStep()],
      );

      final driver = SessionDriver.start(
        async,
        container: container,
        mode: mode,
        simulate: true,
      );

      // The smsContact (waitSeconds=0) is already in its 30s duration phase.
      async.elapse(const Duration(milliseconds: 100));
      check(driver.currentStepIndex).equals(0);
      final running = driver.snapshot as EngineRunning;
      check(running.phase).equals(EnginePhase.duration);
      // The remaining is the full ~30s duration (no compression yet).
      check(running.remaining.inSeconds).isGreaterOrEqual(29);

      // Leap → collapse the 30s duration timer immediately.
      driver.controller.leap();
      async.flushMicrotasks();

      // The duration phase fired within ~0s real time → now in grace, and the
      // remaining reflects the 10s grace, NOT a stale 30s.
      final afterLeap = driver.snapshot as EngineRunning;
      check(afterLeap.phase).equals(EnginePhase.grace);
      check(afterLeap.currentStepIndex).equals(0);
      check(afterLeap.remaining.inSeconds).isLessThan(30);
      check(afterLeap.remaining.inSeconds).isGreaterThan(0);
      // The chain has not advanced off step 0 by the leap alone.
      check(driver.count(ChainEvent.stepAdvancing)).equals(0);

      driver.stop(async);
    });
  });

  test('INT-010 disarm after a queued SMS re-arms to step 0 and does not '
      'escalate (A5 cancel-on-disarm is unimplemented — see header)', () {
    fakeAsync((async) {
      final fakes = RecordingFakes(contacts: [_bob()]);
      final container = buildIntegrationContainer(db: db, fakes: fakes);
      final mode = SessionMode(
        id: 'disarm-sms',
        name: 'Walk Mode',
        chainSteps: [_smsStep(dur: 30, grace: 10), _emergencyStep()],
      );

      final driver = SessionDriver.start(
        async,
        container: container,
        mode: mode,
      );

      // The smsContact step (index 0) executes immediately — its sendMessage
      // returns a (discarded) MessageWorkId.
      async.elapse(const Duration(seconds: 1));
      check(driver.currentStepIndex).equals(0);
      check(fakes.messaging.calls).isNotEmpty();
      check(fakes.messaging.calls.first['method']).equals('sendMessage');
      final smsBeforeDisarm = fakes.messaging.calls.length;

      // User checks in (disarm). The real disarm only re-arms the engine to
      // step 0 — it does NOT cancel the queued SMS WorkManager job (no
      // cancelPending is reachable from the controller; see the header).
      driver.controller.disarm();
      async.flushMicrotasks();

      // Exactly one userDisarmed, the chain is re-armed at step 0, and it never
      // advanced to the callEmergency step.
      check(driver.count(ChainEvent.userDisarmed)).equals(1);
      check(driver.currentStepIndex).equals(0);
      check(driver.count(ChainEvent.stepAdvancing)).equals(0);
      final emergencyCalls = fakes.phone.calls.where(
        (c) => c['method'] == 'callEmergency',
      );
      check(emergencyCalls).isEmpty();

      // The disarm re-executed step 0, so the smsContact fires again (the
      // re-armed step genuinely re-sends — there is no cancellation). This
      // documents the real behavior: disarm re-arms, it does not retract a
      // sent/queued SMS.
      check(fakes.messaging.calls.length).isGreaterThan(smsBeforeDisarm);

      driver.stop(async);
    });
  });
}
