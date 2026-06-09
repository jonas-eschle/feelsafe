/// Host integration scenarios INT-005 / INT-006 — distress-chain end-to-end.
///
/// These drive the **real** [SessionController] + [SessionEngine] through a
/// distress-chain replacement under `fakeAsync`, asserting the distress event
/// chain, the strategy side-effects recorded by the fake services, and the
/// terminal `hardwarePanic` state (spec 07 §Integration Test Scenarios
/// INT-005/INT-006; spec 01 §Distress replacement; decisions A3/A4/B1/64).
///
/// **Orchestrator-API reconciliations (the spec prose has drifted; these tests
/// drive the real methods — Hard Rule 6):**
/// - INT-005's `hw.simulatePanic()` + a hand-written "on panic, call
///   `engine.replaceWithDistressChain(...)`" subscriber is the *engine-level*
///   sketch. The real, wired panic→distress path is the controller's
///   `confirmDistress(reason: hardwarePanic)` (the 5s-window confirmation the
///   `HardwareButtonDistressTrigger` flow ends in), which resolves the session's
///   distress mode and calls `engine.replaceWithDistressChain(chain:
///   distressMode.chainSteps, triggerReason: hardwarePanic)`. These tests drive
///   that real controller method (the distress mode is supplied via
///   `SessionDriver.start(distressMode:)`, exactly how `startSession` receives
///   it in production).
/// - INT-005's `engine.chainSteps` "is now the distress chain" → the live read
///   is `engine.currentStepIndex == 0` on the distress chain plus
///   `engine.isDistressChain == true`; the distress chain's own smsContact +
///   callEmergency firing (recorded by the fakes) proves the swap end-to-end.
/// - INT-005's "`sendToAll`" → the real `MessagingServiceProtocol` method is
///   `sendMessage` (recorded in `FakeMessagingService.calls`); `callEmergency`
///   is recorded in `FakePhoneService.calls`.
/// - INT-006's "duress PIN fires while distress is already active" → the real
///   A4 debounce lives in `SessionEngine.replaceWithDistressChain` itself
///   (`if (_isDistressChain) return`), so a second `confirmDistress` is a no-op:
///   no second `distressTriggered`, no re-armed step-0, the original distress
///   chain keeps progressing. (The controller has no separate duress-PIN entry
///   point that bypasses this guard — the duress PIN routes through the same
///   distress replacement, so the engine guard is the single source of truth.)
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

/// The distress mode swapped in on a panic — smsContact → callEmergency.
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

  test('INT-005 distress fired via hardware panic: main chain replaced, '
      'distress SMS + emergency fire, session ends hardwarePanic', () {
    fakeAsync((async) {
      final fakes = RecordingFakes(contacts: [_bob()]);
      final settings = const AppSettings().copyWith(emergencyCallNumber: '112');
      final container = buildIntegrationContainer(
        db: db,
        fakes: fakes,
        settings: settings,
      );
      final mode = SessionMode(
        id: 'walk-distress',
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
      // active (mirrors the spec's "user holds button so the session is
      // active").
      driver.controller.holdPressed();
      async.elapse(const Duration(seconds: 1));
      check(driver.isDistressChain).isFalse();

      // Panic confirmed → the real distress path replaces the main chain
      // (confirmDistress defaults to EndReason.hardwarePanic).
      driver.controller.confirmDistress();
      async.flushMicrotasks();

      // Immediately after panic the engine is running the distress chain.
      check(driver.isDistressChain).isTrue();
      check(driver.currentStepIndex).equals(0);
      // distressTriggered fired exactly once on the replacement.
      check(driver.count(ChainEvent.distressTriggered)).equals(1);

      // Let the distress chain walk smsContact → callEmergency → exhaust.
      async.elapse(const Duration(seconds: 15));

      // Terminal event chain: distressCompleted then sessionEnded(hardwarePanic).
      check(driver.count(ChainEvent.distressCompleted)).equals(1);
      check(driver.isEnded).isTrue();
      check(driver.endReason).equals(EndReason.hardwarePanic);

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

  test('INT-006 duress PIN during an active distress chain is a no-op: second '
      'trigger does not re-arm or duplicate escalation (A4)', () {
    fakeAsync((async) {
      final fakes = RecordingFakes(contacts: [_bob()]);
      final settings = const AppSettings().copyWith(emergencyCallNumber: '112');
      final container = buildIntegrationContainer(
        db: db,
        fakes: fakes,
        settings: settings,
      );
      final mode = SessionMode(
        id: 'walk-duress',
        name: 'Walk Mode',
        chainSteps: [_holdStep()],
      );

      final driver = SessionDriver.start(
        async,
        container: container,
        mode: mode,
        distressMode: _distressMode(),
      );

      driver.controller.holdPressed();
      async.elapse(const Duration(seconds: 1));

      // First distress trigger replaces the chain (default reason
      // hardwarePanic); let the first step begin.
      driver.controller.confirmDistress();
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 1));
      check(driver.isDistressChain).isTrue();
      final smsAfterFirst = fakes.messaging.calls.length;
      check(smsAfterFirst).isGreaterThan(0);

      // A second distress trigger (the duress PIN firing while distress is
      // already active). The engine's A4 guard makes this a no-op.
      driver.controller.confirmDistress(reason: EndReason.duressPin);
      async.flushMicrotasks();

      // Still the SAME distress chain — no second distressTriggered, no
      // re-arm to step 0, and no extra SMS fired by the duplicate trigger.
      check(driver.isDistressChain).isTrue();
      check(driver.count(ChainEvent.distressTriggered)).equals(1);
      check(fakes.messaging.calls.length).equals(smsAfterFirst);

      // The original distress chain keeps progressing to completion, ending
      // with the FIRST trigger's reason (hardwarePanic), not the duress reason
      // — proving the second trigger never took effect.
      async.elapse(const Duration(seconds: 15));
      check(driver.isEnded).isTrue();
      check(driver.endReason).equals(EndReason.hardwarePanic);

      driver.stop(async);
    });
  });
}
