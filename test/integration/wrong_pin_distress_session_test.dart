/// Host integration scenario INT-011 — wrong Session-End PIN threshold fires
/// the distress chain (decision A3; spec 07 scenarios 70/71, 30d).
///
/// Drives the **real** [SessionController] wrong-PIN path end-to-end under
/// `fakeAsync`: each wrong attempt increments the in-memory counter and emits
/// `deceptiveOldPinShown`, and reaching `AppSettings.wrongPinThreshold`
/// triggers `confirmDistress(reason: wrongPinExhausted)` → the engine swaps in
/// the distress chain, which fires its smsContact + callEmergency and ends the
/// session with `wrongPinExhausted`. A second test proves the spec-30d
/// simulation carve-out: a simulation session's wrong-PIN counter never feeds
/// the real distress path (the controller-level distress trigger is gated on a
/// configured distress mode + an explicit `confirmDistress`, and the
/// session-screen UI never calls the controller in simulation — see the
/// reconciliation note below).
///
/// **Orchestrator/spec-API reconciliations (Hard Rule 6 — drive the real
/// methods):**
/// - Spec 07 scenarios 70/71 describe the *behaviour* ("enter wrong PIN 5×",
///   "distress chain fired") without naming the wired API. The real wiring
///   (`session_screen.dart:1020-1028`, `launch_pin_screen.dart:167-170`,
///   `end_session_overlay.dart:354-357`) is:
///     1. `controller.notifyWrongPinAttempt()` → increments
///        `SessionController._wrongPinAttempts`, calls
///        `engine.notifyWrongPin(count)` (which emits
///        `ChainEvent.deceptiveOldPinShown` with `metadata['attemptCount']`),
///        and returns the post-increment count.
///     2. the caller compares the returned count against
///        `settings.wrongPinThreshold` (default 5, spec 06) and, on reaching
///        it, calls `controller.confirmDistress(reason:
///        EndReason.wrongPinExhausted)`.
///   The terminal `EndReason` is **`wrongPinExhausted`** (NOT a
///   `wrongPinThreshold` value — that enum case does not exist). This test
///   reproduces that exact wired sequence against the real controller.
/// - Spec 30d "simulation wrong PIN does NOT fire distress chain": the
///   *controller* itself has no `isSimulation` guard inside
///   `notifyWrongPinAttempt`/`confirmDistress`; the carve-out lives in the
///   session-screen UI (`session_screen.dart:990` — a simulation session uses a
///   local `_simWrongAttempts` counter, shows the educational SnackBar, and
///   **never** calls the controller). The faithful controller-level invariant
///   is therefore: in a simulation session the distress chain only ever fires
///   if `confirmDistress` is explicitly called — the wrong-PIN counter alone
///   never escalates. This test asserts that real invariant (the UI gate is
///   covered separately by the session_screen widget tests).
library;

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart' hide EnginePhase;

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/engine/chain_event.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
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

/// A holdButton main-chain step the user holds to keep the session active.
ChainStep _holdStep() => ChainStep(
  id: 'main-hold',
  type: ChainStepType.holdButton,
  order: 0,
  waitSeconds: 0,
  durationSeconds: 30,
  gracePeriodSeconds: 5,
  retryCount: 0,
  randomize: false,
  config: const HoldButtonConfig(releaseSensitivity: 0.3),
);

ChainStep _distressSmsStep() => ChainStep(
  id: 'distress-sms',
  type: ChainStepType.smsContact,
  order: 0,
  waitSeconds: 0,
  durationSeconds: 2,
  gracePeriodSeconds: 1,
  retryCount: 0,
  randomize: false,
  config: const SmsContactConfig(),
);

ChainStep _distressEmergencyStep() => ChainStep(
  id: 'distress-emergency',
  type: ChainStepType.callEmergency,
  order: 1,
  waitSeconds: 0,
  durationSeconds: 2,
  gracePeriodSeconds: 1,
  retryCount: 0,
  randomize: false,
  config: const CallEmergencyConfig(),
);

/// The distress mode swapped in on the wrong-PIN threshold — smsContact →
/// callEmergency (mirrors the distress chain used by INT-005/006).
SessionMode _distressMode() => SessionMode(
  id: 'distress-mode',
  name: 'Distress',
  chainSteps: [_distressSmsStep(), _distressEmergencyStep()],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GuardianAngelaDatabase db;

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
  });

  tearDown(() async {
    await closeIntegrationDb(db);
  });

  test('INT-011 reaching the wrong Session-End PIN threshold fires the '
      'distress chain (A3): N deceptiveOldPinShown then wrongPinExhausted', () {
    fakeAsync((async) {
      final fakes = RecordingFakes(contacts: [_bob()]);
      // Threshold 5 is the default; assert it explicitly so the loop count is
      // grounded in the real setting rather than a magic number.
      final settings = const AppSettings().copyWith(emergencyCallNumber: '112');
      check(settings.wrongPinThreshold).equals(5);

      final container = buildIntegrationContainer(
        db: db,
        fakes: fakes,
        settings: settings,
      );
      final mode = SessionMode(
        id: 'walk-wrongpin',
        name: 'Walk Mode',
        chainSteps: [_holdStep()],
      );

      final driver = SessionDriver.start(
        async,
        container: container,
        mode: mode,
        distressMode: _distressMode(),
      );

      // Session is live on the main holdButton step; the user holds to keep it
      // active while someone fumbles the Session-End PIN.
      driver.controller.holdPressed();
      async.elapse(const Duration(seconds: 1));
      check(driver.isDistressChain).isFalse();

      final threshold = settings.wrongPinThreshold;

      // The first (threshold - 1) wrong attempts only tick the counter + emit
      // the deceptive-PIN forensic event; no distress yet.
      for (var attempt = 1; attempt < threshold; attempt++) {
        final count = driver.controller.notifyWrongPinAttempt();
        check(count).equals(attempt);
        check(driver.controller.wrongPinAttempts).equals(attempt);
        async.flushMicrotasks();
        // Still the main chain — below threshold never escalates.
        check(driver.isDistressChain).isFalse();
      }
      // deceptiveOldPinShown fired once per wrong attempt so far.
      check(
        driver.count(ChainEvent.deceptiveOldPinShown),
      ).equals(threshold - 1);

      // The threshold-th wrong attempt: the counter reaches the threshold and
      // the wired caller fires the distress chain with wrongPinExhausted.
      final reached = driver.controller.notifyWrongPinAttempt();
      check(reached).equals(threshold);
      check(reached >= settings.wrongPinThreshold).isTrue();
      driver.controller.confirmDistress(reason: EndReason.wrongPinExhausted);
      async.flushMicrotasks();

      // The engine is now running the distress chain (replaced the main chain).
      check(driver.isDistressChain).isTrue();
      check(driver.currentStepIndex).equals(0);
      check(driver.count(ChainEvent.distressTriggered)).equals(1);
      // The final (threshold-th) wrong attempt also emitted its forensic event.
      check(driver.count(ChainEvent.deceptiveOldPinShown)).equals(threshold);

      // Let the distress chain walk smsContact → callEmergency → exhaust.
      async.elapse(const Duration(seconds: 15));

      // Terminal chain: distressCompleted then sessionEnded(wrongPinExhausted).
      check(driver.count(ChainEvent.distressCompleted)).equals(1);
      check(driver.isEnded).isTrue();
      check(driver.endReason).equals(EndReason.wrongPinExhausted);

      // The distress chain's smsContact + callEmergency actually executed.
      check(fakes.messaging.calls).isNotEmpty();
      check(fakes.messaging.calls.first['method']).equals('sendMessage');
      final emergencyCalls = fakes.phone.calls.where(
        (c) => c['method'] == 'callEmergency',
      );
      check(emergencyCalls).isNotEmpty();
      check(emergencyCalls.first['emergencyNumber']).equals('112');

      driver.stop(async);
    });
  });

  test('INT-011 (30d) a SIMULATION session never escalates from the wrong-PIN '
      'counter alone — distress only fires on an explicit confirmDistress', () {
    fakeAsync((async) {
      final fakes = RecordingFakes(contacts: [_bob()]);
      final settings = const AppSettings().copyWith(emergencyCallNumber: '112');
      final container = buildIntegrationContainer(
        db: db,
        fakes: fakes,
        settings: settings,
      );
      final mode = SessionMode(
        id: 'sim-wrongpin',
        name: 'Walk Mode',
        chainSteps: [_holdStep()],
      );

      final driver = SessionDriver.start(
        async,
        container: container,
        mode: mode,
        simulate: true,
        distressMode: _distressMode(),
      );

      driver.controller.holdPressed();
      async.elapse(const Duration(seconds: 1));

      // Drive the controller's wrong-PIN counter WELL past the threshold. The
      // controller exposes no isSimulation gate here (the UI gates it), so the
      // counter increments — but incrementing the counter is NOT what triggers
      // distress. Without the explicit confirmDistress the wired caller makes,
      // the chain never escalates: this is the faithful controller-level
      // expression of spec-30d (a simulation's wrong-PIN entries do not fire
      // the distress chain).
      for (var i = 0; i < settings.wrongPinThreshold + 2; i++) {
        driver.controller.notifyWrongPinAttempt();
        async.flushMicrotasks();
      }

      // No distress chain, no escalation, no destructive side-effects — the
      // session is still the live simulated main chain.
      check(driver.isDistressChain).isFalse();
      check(driver.count(ChainEvent.distressTriggered)).equals(0);
      check(driver.isEnded).isFalse();
      // Simulation never dispatches real strategies, so nothing was sent/dialed.
      check(fakes.messaging.calls).isEmpty();
      check(fakes.phone.calls).isEmpty();

      driver.stop(async);
    });
  });
}
