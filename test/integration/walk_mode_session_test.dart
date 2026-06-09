/// Host integration scenarios INT-001 / INT-002 — Walk Mode end-to-end.
///
/// These drive the **real** [SessionController] + [SessionEngine] through a full
/// Walk Mode session under `fakeAsync`, asserting the engine event chain, the
/// strategy side-effects recorded by the fake services, and the terminal state.
/// They are the proof that the wired hold-button → smsContact → callEmergency
/// chain actually composes into a working session (spec 07 §Integration Test
/// Scenarios INT-001/INT-002; spec 01 §Hold button lifecycle, §Chain exhaustion).
///
/// **Orchestrator-API reconciliations (the spec prose has drifted; these tests
/// drive the real methods — Hard Rule 6):**
/// - `engine.state` → real getter is `engine.snapshot` (exposed as
///   [SessionDriver.snapshot]).
/// - INT-001's "orchestrator `cleanDisarm` invoked once" → there is no
///   `cleanDisarm` method; the real disarm path is `controller.disarm()` →
///   `engine.disarm()`, which emits exactly one `userDisarmed` and re-arms the
///   chain at step 0. Asserted via the event log + `currentStepIndex`.
/// - INT-002's "hold-wait times out, all steps advance" contradicts the real
///   engine: a `holdButton` step in the `holdWait` phase has **no timeout timer**
///   (spec 02:46 — "Engine waits for first `holdStart()`. Does NOT assume user is
///   holding."). A never-touched hold step sits forever and never exhausts. The
///   faithful worst case is therefore: the user *holds to start*, then
///   *releases and stops responding* — the sensitivity→duration→grace timers run
///   and, with `retryCount=0`, the chain advances through smsContact +
///   callEmergency to exhaustion. That real miss→advance→exhaust path is what
///   INT-002 drives here.
/// - INT-002's "repeatMissed per step" → `repeatMissed` is emitted **only** for
///   disguisedReminder steps (engine `_onGraceExpired`); for holdButton /
///   smsContact / callEmergency the missed-check signal is `graceExpired` +
///   `stepAdvancing`, which these tests assert instead.
library;

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart' hide EnginePhase;

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/engine/chain_event.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import '_session_harness.dart';

/// A Walk Mode contact used as the smsContact recipient.
EmergencyContact _bob() => EmergencyContact(
  id: 'contact-bob',
  name: 'Bob',
  phoneNumber: '+15551112222',
  sortOrder: 0,
);

ChainStep _holdStep({int dur = 5, int grace = 3}) => ChainStep(
  id: 'walk-hold',
  type: ChainStepType.holdButton,
  order: 0,
  waitSeconds: 0,
  durationSeconds: dur,
  gracePeriodSeconds: grace,
  retryCount: 0,
  randomize: false,
  config: const HoldButtonConfig(releaseSensitivity: 0.3),
);

ChainStep _smsStep({int dur = 2, int grace = 1}) => ChainStep(
  id: 'walk-sms',
  type: ChainStepType.smsContact,
  order: 1,
  waitSeconds: 0,
  durationSeconds: dur,
  gracePeriodSeconds: grace,
  retryCount: 0,
  randomize: false,
  config: const SmsContactConfig(),
);

ChainStep _emergencyStep({int dur = 2, int grace = 1}) => ChainStep(
  id: 'walk-emergency',
  type: ChainStepType.callEmergency,
  order: 2,
  waitSeconds: 0,
  durationSeconds: dur,
  gracePeriodSeconds: grace,
  retryCount: 0,
  randomize: false,
  config: const CallEmergencyConfig(),
);

void main() {
  // startSession registers a WidgetsBindingObserver (G-013 background clamp),
  // which needs an initialised binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  late GuardianAngelaDatabase db;

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
  });

  tearDown(() async {
    await db.close();
  });

  test('INT-001 Walk Mode happy path: hold to begin, check in, chain re-arms '
      'at step 0 and no SMS fires', () {
    fakeAsync((async) {
      final fakes = RecordingFakes(contacts: [_bob()]);
      final container = buildIntegrationContainer(db: db, fakes: fakes);
      final mode = SessionMode(
        id: 'walk-happy',
        name: 'Walk Mode',
        chainSteps: [_holdStep(), _smsStep()],
      );

      final driver = SessionDriver.start(
        async,
        container: container,
        mode: mode,
      );

      // Initial stepStarted(0) is proven by the engine state at start: the
      // session is on the holdButton step, awaiting the first hold.
      check(driver.currentStepIndex).equals(0);
      check(driver.snapshot).isA<EngineRunning>();
      check(
        (driver.snapshot as EngineRunning).phase,
      ).equals(EnginePhase.holdWait);

      // User holds the button (session "begins"), holds for 1s.
      driver.controller.holdPressed();
      async.elapse(const Duration(seconds: 1));
      check((driver.snapshot as EngineRunning).isHolding).isTrue();

      // User checks in ("I'm safe") — the real disarm path.
      driver.controller.disarm();
      async.flushMicrotasks();

      // Exactly one userDisarmed, and the chain re-armed at step 0 (a
      // disarm-replayed stepStarted follows). This is the real equivalent of
      // the spec's "stepStarted(0), userDisarmed, stepStarted(0)" sequence.
      check(driver.count(ChainEvent.userDisarmed)).equals(1);
      check(driver.events).contains(ChainEvent.stepStarted);
      check(driver.currentStepIndex).equals(0);

      // The smsContact step (index 1) was never reached → no SMS fired.
      check(fakes.messaging.calls).isEmpty();
      // The session is still alive (a check-in does not end it).
      check(driver.isEnded).isFalse();

      driver.stop(async);
    });
  });

  test('INT-002 Walk Mode worst case: hold then stop responding → chain '
      'advances through SMS + emergency to chainExhausted', () {
    fakeAsync((async) {
      final fakes = RecordingFakes(contacts: [_bob()]);
      final settings = const AppSettings().copyWith(emergencyCallNumber: '112');
      final container = buildIntegrationContainer(
        db: db,
        fakes: fakes,
        settings: settings,
      );
      final mode = SessionMode(
        id: 'walk-worst',
        name: 'Walk Mode',
        chainSteps: [_holdStep(), _smsStep(), _emergencyStep()],
      );

      final driver = SessionDriver.start(
        async,
        container: container,
        mode: mode,
      );
      check(driver.currentStepIndex).equals(0);

      // User holds to start, then releases and never re-engages. After release
      // the sensitivity→duration→grace timers run; with retryCount=0 the miss
      // advances the chain (a never-touched holdWait would instead sit forever
      // — spec 02:46, the reconciliation above).
      driver.controller.holdPressed();
      async.elapse(const Duration(seconds: 1));
      driver.controller.holdReleased();

      // Long enough that every step's duration + grace expires and the chain
      // walks 0 → 1 → 2 → exhausted.
      async.elapse(const Duration(seconds: 40));

      // Three stepAdvancing: 0→1, 1→2, then the terminal exhaustion advance
      // off the last step (2→end) which fires sessionEnded.
      check(driver.count(ChainEvent.stepAdvancing)).equals(3);
      check(driver.count(ChainEvent.graceExpired)).equals(3);

      // Terminal state: chain exhausted.
      check(driver.isEnded).isTrue();
      check(driver.endReason).equals(EndReason.chainExhausted);

      // The smsContact and callEmergency strategies actually executed end-to-end
      // (recording fakes captured the side-effects).
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
}
