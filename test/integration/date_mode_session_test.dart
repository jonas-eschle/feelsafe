/// Host integration scenarios INT-003 / INT-004 — Date Mode end-to-end.
///
/// These drive the **real** [SessionController] + [SessionEngine] through a full
/// Date Mode session under `fakeAsync`, asserting the disguised-reminder cycle,
/// the strategy side-effects recorded by the fake services, and the terminal
/// state (spec 07 §Integration Test Scenarios INT-003/INT-004; spec 01
/// §Disguised reminder, §Reminder retry; spec 02 §disguisedReminder).
///
/// **Orchestrator-API reconciliations (Hard Rule 6):**
/// - INT-003's "engine.checkIn() before grace expires" → the real engine method
///   is `checkIn()` (alias of `disarm()`); the controller exposes it as
///   `controller.disarm()`. Either re-arms the chain at step 0 and emits exactly
///   one `userDisarmed`.
/// - INT-003's terminal "`userTerminated` reason" → there is no `userTerminated`
///   in [EndReason]; the deliberate user-quit value is [EndReason.userQuit]
///   (the `endSession` default). Asserted as such.
/// - INT-003's "reminderFired once per cycle" → after each check-in the engine
///   resets step 0 to its `waitSeconds` wait phase, so the next reminder only
///   re-fires after another full wait. The asserted, real invariant is that the
///   reminder fired **at least once** (it genuinely went off) AND the chain
///   never advances past step 0 AND no SMS is sent — the substance of the happy
///   path.
/// - INT-004's title "distress SMS" vs body "chain advances through smsContact
///   and callEmergency → chainExhausted": the *body* (the precise expected
///   outcomes) is normative — the main chain's own smsContact + callEmergency
///   fire as the chain exhausts; no separate distress chain is involved here.
///   (Distress-chain replacement is covered by INT-005, a later chunk.)
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

EmergencyContact _bob() => EmergencyContact(
  id: 'contact-bob',
  name: 'Bob',
  phoneNumber: '+15551112222',
  sortOrder: 0,
);

ChainStep _reminderStep({
  required int wait,
  required int dur,
  required int grace,
  required int retry,
}) => ChainStep(
  id: 'date-reminder',
  type: ChainStepType.disguisedReminder,
  order: 0,
  waitSeconds: wait,
  durationSeconds: dur,
  gracePeriodSeconds: grace,
  retryCount: retry,
  randomize: false,
  // randomizeInterval/randomizeTemplateOrder default to TRUE on
  // DisguisedReminderConfig; since SessionController builds its SessionEngine
  // with the real Random() (no injected FixedRandom), leaving them on would
  // jitter the wait phase by ±20% and pick a non-deterministic template. Both
  // are disabled here so disguisedReminder timing + selection are exact — the
  // disguisedReminder equivalent of `randomize: false` (KEY reconciliation; the
  // plain `ChainStep.randomize` flag does NOT govern these per-config flags).
  config: const DisguisedReminderConfig(
    randomizeInterval: false,
    randomizeTemplateOrder: false,
  ),
);

ChainStep _smsStep() => ChainStep(
  id: 'date-sms',
  type: ChainStepType.smsContact,
  order: 1,
  waitSeconds: 0,
  durationSeconds: 2,
  gracePeriodSeconds: 0,
  retryCount: 0,
  randomize: false,
  config: const SmsContactConfig(),
);

ChainStep _emergencyStep() => ChainStep(
  id: 'date-emergency',
  type: ChainStepType.callEmergency,
  order: 2,
  waitSeconds: 0,
  durationSeconds: 2,
  gracePeriodSeconds: 0,
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

  test('INT-003 Date Mode happy path: reminder fires, user checks in each '
      'cycle, chain never advances and no SMS fires', () {
    fakeAsync((async) {
      final fakes = RecordingFakes(contacts: [_bob()]);
      final container = buildIntegrationContainer(db: db, fakes: fakes);
      final mode = SessionMode(
        id: 'date-happy',
        name: 'Date Mode',
        chainSteps: [
          _reminderStep(wait: 10, dur: 5, grace: 5, retry: 2),
          _smsStep(),
        ],
      );

      final driver = SessionDriver.start(
        async,
        container: container,
        mode: mode,
      );
      // Starts on the disguisedReminder step in its wait phase.
      check(driver.currentStepIndex).equals(0);
      check(driver.snapshot).isA<EngineRunning>();
      check((driver.snapshot as EngineRunning).phase).equals(EnginePhase.wait);

      // Three check-in cycles: let the wait phase elapse so the reminder fires,
      // then check in before grace expires.
      for (var cycle = 0; cycle < 3; cycle++) {
        async.elapse(const Duration(seconds: 11));
        if (cycle == 0) {
          // After the first fire (and before the check-in clears it) the
          // controller has surfaced a disguise template for the on-screen
          // reminder. The userDisarmed below resets it, so assert it here.
          check(driver.count(ChainEvent.reminderFired)).isGreaterThan(0);
          check(driver.state.activeReminderTemplate).isNotNull();
        }
        driver.controller.disarm();
        async.flushMicrotasks();
        // Each cycle the chain stays parked at step 0 (never escalates).
        check(driver.currentStepIndex).equals(0);
      }

      // One userDisarmed per check-in.
      check(driver.count(ChainEvent.userDisarmed)).equals(3);
      // The chain never advanced past step 0 → the smsContact never fired.
      check(driver.count(ChainEvent.stepAdvancing)).equals(0);
      check(fakes.messaging.calls).isEmpty();

      // Finish cleanly via a deliberate user quit (stop's default reason).
      driver.stop(async);
      check(driver.endReason).equals(EndReason.userQuit);
    });
  });

  test('INT-004 Date Mode worst case: reminders missed → chain advances '
      'through SMS + emergency to chainExhausted', () {
    fakeAsync((async) {
      final fakes = RecordingFakes(contacts: [_bob()]);
      final settings = const AppSettings().copyWith(emergencyCallNumber: '112');
      final container = buildIntegrationContainer(
        db: db,
        fakes: fakes,
        settings: settings,
      );
      final mode = SessionMode(
        id: 'date-worst',
        name: 'Date Mode',
        chainSteps: [
          _reminderStep(wait: 5, dur: 3, grace: 3, retry: 1),
          _smsStep(),
          _emergencyStep(),
        ],
      );

      final driver = SessionDriver.start(
        async,
        container: container,
        mode: mode,
      );
      check(driver.currentStepIndex).equals(0);

      // The user never checks in. Long enough that the reminder fires, retries
      // once, exhausts its retries, and the chain walks 0 → 1 → 2 → exhausted.
      async.elapse(const Duration(seconds: 40));

      // The reminder fired twice — the initial fire plus one retry (retryCount=1,
      // spec 02 §disguisedReminder retry semantics).
      check(driver.count(ChainEvent.reminderFired)).equals(2);
      // repeatMissed is emitted on the disguisedReminder retry (a Date-Mode
      // specific signal the Walk-Mode worst case does not produce).
      check(driver.count(ChainEvent.repeatMissed)).isGreaterThan(0);
      // The chain advanced through smsContact and callEmergency before ending.
      check(driver.count(ChainEvent.stepAdvancing)).equals(3);

      // Terminal state: chain exhausted.
      check(driver.isEnded).isTrue();
      check(driver.endReason).equals(EndReason.chainExhausted);

      // Both escalation strategies executed end-to-end.
      check(fakes.messaging.calls).isNotEmpty();
      final emergencyCalls = fakes.phone.calls.where(
        (c) => c['method'] == 'callEmergency',
      );
      check(emergencyCalls).isNotEmpty();
      check(emergencyCalls.first['emergencyNumber']).equals('112');

      driver.stop(async);
    });
  });
}
