/// Host integration scenarios INT-007 / INT-008 — real incoming-call handling.
///
/// These drive the **real** [SessionController] + [SessionEngine] through the
/// real-incoming-call pause/resume wiring under `fakeAsync`, by injecting a
/// controllable [SimulationCallStateService] and pushing `CallState` changes
/// (the same path a native `CallStateChannel` event would take). They prove the
/// HOST-level behavior of decisions A2 / Extra-24/25/30/31 (spec 07
/// §Integration Test Scenarios INT-007/INT-008; spec 01 §Real Phone Call
/// Detection, §Real Phone Call During Fake Call). The on-device adb-gsm proof
/// of #11/#12 is a separate emulator chunk (C4) — this is the deterministic
/// host proof.
///
/// **Orchestrator-API reconciliations (Hard Rule 6):**
/// - INT-007/008's "wire `FakeIncomingCallService` or drive
///   `engine.pause(incomingCall)` directly" → these tests drive the **fully
///   wired** path: `SimulationCallStateService.setState(CallState.ringing)` →
///   the controller's `_onCallStateChanged` subscriber → `_onRealCallStarted`
///   → `engine.pause(reason: PauseReason.incomingCall)`; and
///   `setState(CallState.idle)` → `_onRealCallEnded` → `engine.resume()` (and,
///   over a fakeCall step, the follow-up `engine.disarm()`). This exercises the
///   real subscription set up inside `startSession`, not a bare engine call.
/// - INT-007's "Real engine, `FixedRandom`" → `SessionController` builds its
///   engine with the real `Random()`; jitter is instead disabled at the source
///   (`randomize: false` on every step) per the harness contract, which yields
///   the identical no-jitter timing the spec assumes.
/// - INT-007's chain "step index 1 is a smsContact with durationSeconds=30":
///   step 0 is a short auto-advancing smsContact (waitSeconds=0, grace=0) that
///   walks the chain into step 1 deterministically, so the pause lands squarely
///   in step 1's 30s duration phase.
/// - INT-008's chain "holdButton → fakeCall" is used verbatim: the user holds
///   then releases-and-misses the leading holdButton (sensitivity → duration →
///   grace → miss → advance) to reach the fakeCall step. A holdButton lead
///   (vs an smsContact) also keeps `FakeMessagingService.calls` genuinely empty
///   — the disarm-to-step-0 replay re-executes step 0, and a re-armed
///   smsContact would re-send, confounding the "no escalation" assertion.
///   `engine.isHolding` is asserted `false` after the resume+disarm.
/// - INT-008's "`FakeMessagingService.sentMessages` is empty" → the real
///   recorder is `FakeMessagingService.calls`; asserted empty (no escalation
///   while paused / during the fakeCall).
library;

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart' hide EnginePhase;

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/engine/chain_event.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/enums/call_state.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/pause_reason.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/services/sim/call_state_service_sim.dart';
import '_session_harness.dart';

EmergencyContact _bob() => EmergencyContact(
  id: 'contact-bob',
  name: 'Bob',
  phoneNumber: '+15551112222',
  sortOrder: 0,
);

/// A short smsContact that auto-advances (no wait, no grace) — used as the
/// leading step so the chain walks deterministically into the next step.
ChainStep _leadStep() => ChainStep(
  id: 'lead-sms',
  type: ChainStepType.smsContact,
  order: 0,
  waitSeconds: 0,
  durationSeconds: 2,
  gracePeriodSeconds: 0,
  retryCount: 0,
  randomize: false,
  config: const SmsContactConfig(),
);

ChainStep _longSmsStep() => ChainStep(
  id: 'long-sms',
  type: ChainStepType.smsContact,
  order: 1,
  waitSeconds: 0,
  durationSeconds: 30,
  gracePeriodSeconds: 0,
  retryCount: 0,
  randomize: false,
  config: const SmsContactConfig(),
);

ChainStep _fakeCallStep() => ChainStep(
  id: 'fake-call',
  type: ChainStepType.fakeCall,
  order: 1,
  waitSeconds: 0,
  durationSeconds: 30,
  gracePeriodSeconds: 0,
  retryCount: 0,
  randomize: false,
  config: const FakeCallConfig(declineIsSafe: false),
);

/// A holdButton lead step for INT-008 — matches the spec's `holdButton →
/// fakeCall` chain and (unlike an smsContact lead) fires no SMS, so the
/// disarm-to-step-0 replay never confounds the "no escalation" assertion.
ChainStep _holdLeadStep() => ChainStep(
  id: 'lead-hold',
  type: ChainStepType.holdButton,
  order: 0,
  waitSeconds: 0,
  durationSeconds: 1,
  gracePeriodSeconds: 0,
  retryCount: 0,
  randomize: false,
  config: const HoldButtonConfig(releaseSensitivity: 0.3),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GuardianAngelaDatabase db;
  late SimulationCallStateService callState;

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
    callState = SimulationCallStateService();
  });

  tearDown(() async {
    callState.dispose();
    await closeIntegrationDb(db);
  });

  test('INT-007 real call during a countdown pauses the engine and resumes '
      'with the exact remaining time preserved', () {
    fakeAsync((async) {
      final fakes = RecordingFakes(contacts: [_bob()]);
      final container = buildIntegrationContainer(
        db: db,
        fakes: fakes,
        callState: callState,
      );
      final mode = SessionMode(
        id: 'walk-call-pause',
        name: 'Walk Mode',
        chainSteps: [_leadStep(), _longSmsStep()],
      );

      final driver = SessionDriver.start(
        async,
        container: container,
        mode: mode,
      );

      // Walk the chain into step 1 (the 30s smsContact). The 2s lead step's
      // duration + zero grace advance it deterministically.
      async.elapse(const Duration(seconds: 2));
      check(driver.currentStepIndex).equals(1);
      check(
        (driver.snapshot as EngineRunning).phase,
      ).equals(EnginePhase.duration);

      // 10s into the 30s duration → 20s remain.
      async.elapse(const Duration(seconds: 10));
      check(driver.count(ChainEvent.stepAdvancing)).equals(1); // only 0→1

      // A real call arrives → the controller pauses the engine.
      callState.setState(CallState.ringing);
      async.flushMicrotasks();
      check(driver.count(ChainEvent.sessionPaused)).equals(1);
      check(driver.snapshot).isA<EnginePaused>();
      check(
        (driver.snapshot as EnginePaused).reason,
      ).equals(PauseReason.incomingCall);
      check(driver.state.isPaused).isTrue();
      final pausedRemaining =
          (driver.snapshot as EnginePaused).snapshot.remaining;

      // A long (60s) call — while paused the chain must NOT advance.
      async.elapse(const Duration(seconds: 60));
      check(driver.snapshot).isA<EnginePaused>();
      check(driver.currentStepIndex).equals(1);
      check(driver.count(ChainEvent.stepAdvancing)).equals(1);

      // Call ends → resume. The saved remaining (~20s) is restored exactly.
      callState.setState(CallState.idle);
      async.flushMicrotasks();
      check(driver.count(ChainEvent.sessionResumed)).equals(1);
      check(driver.snapshot).isA<EngineRunning>();
      check(pausedRemaining).equals(const Duration(seconds: 20));

      // 19s after resume: 1s should still be left, same step, not advanced.
      async.elapse(const Duration(seconds: 19));
      check(driver.snapshot).isA<EngineRunning>();
      check(driver.currentStepIndex).equals(1);
      check(driver.count(ChainEvent.stepAdvancing)).equals(1);

      // The final ~1s elapses → the preserved timer fires and the chain
      // advances off step 1 (proving the remaining time survived the pause).
      async.elapse(const Duration(seconds: 2));
      check(driver.count(ChainEvent.stepAdvancing)).equals(2);

      driver.stop(async);
    });
  });

  test('INT-008 real call over a fakeCall step pauses, cancels the fake call, '
      'and on call-end resumes then disarms to step 0', () {
    fakeAsync((async) {
      final fakes = RecordingFakes(contacts: [_bob()]);
      final container = buildIntegrationContainer(
        db: db,
        fakes: fakes,
        callState: callState,
      );
      final mode = SessionMode(
        id: 'walk-call-fakecall',
        name: 'Walk Mode',
        chainSteps: [_holdLeadStep(), _fakeCallStep()],
      );

      final driver = SessionDriver.start(
        async,
        container: container,
        mode: mode,
      );

      // Hold then release-and-miss the leading holdButton so the chain advances
      // into the fakeCall step (index 1): sensitivity(0.3s) → duration(1s) →
      // grace(0) → miss → advance.
      driver.controller.holdPressed();
      async.elapse(const Duration(seconds: 1));
      driver.controller.holdReleased();
      async.elapse(const Duration(seconds: 3));
      check(driver.currentStepIndex).equals(1);
      check(driver.snapshot).isA<EngineRunning>();
      final nonceBefore = driver.state.fakeCallCancelNonce;

      // A real call arrives before the user answers the fake call.
      callState.setState(CallState.ringing);
      async.flushMicrotasks();

      // The engine paused with the incomingCall reason …
      check(driver.count(ChainEvent.sessionPaused)).equals(1);
      check(
        (driver.snapshot as EnginePaused).reason,
      ).equals(PauseReason.incomingCall);
      // … and the fake call was cancelled (audio stopped + dismiss nonce bumped).
      check(driver.state.fakeCallCancelNonce).equals(nonceBefore + 1);
      check(fakes.audio.calls.where((c) => c['method'] == 'stop')).isNotEmpty();

      async.elapse(const Duration(seconds: 5));
      check(driver.snapshot).isA<EnginePaused>();

      // The real call ends → resume, then auto-disarm back to step 0.
      callState.setState(CallState.idle);
      async.flushMicrotasks();
      check(driver.count(ChainEvent.sessionResumed)).equals(1);
      check(driver.count(ChainEvent.userDisarmed)).equals(1);
      check(driver.snapshot).isA<EngineRunning>();
      check(driver.currentStepIndex).equals(0);
      check(driver.engine!.isHolding).isFalse();

      // No SMS escalation fired at any point (the chain is holdButton →
      // fakeCall; neither sends an SMS, and the disarm reset to step 0 fires
      // no escalation).
      check(fakes.messaging.calls).isEmpty();

      driver.stop(async);
    });
  });
}
