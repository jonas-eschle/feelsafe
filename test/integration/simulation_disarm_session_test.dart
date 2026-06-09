/// Host integration scenarios INT-009 / INT-010 — simulation leap & disarm.
///
/// INT-009 drives the **real** [SessionController] simulation `leap()` (the
/// "skip to next event" time-compression, decision D2) under `fakeAsync`,
/// proving the engine collapses the current phase timer and transitions cleanly
/// without leaking a stale remaining time.
///
/// INT-010 drives the **real** A5 SMS-cancel-on-disarm wiring end-to-end: a
/// `smsContact` step enqueues an SMS whose `FakeMessagingService` returns a
/// deterministic WorkManager id; the controller accumulates it
/// (`_dispatchStep` → `_smsWorkIds`) and, when the user signals safety, passes
/// it to `MessagingServiceProtocol.cancelPending`. Three cases:
///   - **disarm** (the "I'm safe" slider, `controller.disarm()`) cancels the
///     queued id immediately (and the chain re-arms to step 0, never escalates);
///   - a **clean end** (`endSession(reason: userQuit)`) cancels it;
///   - a **distress / escalation end** (`chainExhausted`) does NOT cancel — the
///     distress SMS must still go out.
///
/// **A5 is now BUILT (this milestone, m5-A5).** Earlier (C2) INT-010 documented
/// the gap: `MessagingServiceProtocol` declared only `sendMessage`,
/// `EventStrategy.executeReal` returned `Future<void>` (discarding the work-id),
/// and `SessionController.disarm()` was a bare `engine.disarm()`. That gap is
/// closed: `cancelPending` is on the protocol, `executeReal` returns the SMS
/// work-ids, and the controller accumulates + cancels them on disarm/clean-end.
/// This test is the RED proof — remove the `_cancelPendingSms()` call from
/// `disarm()` (or `_finaliseLog`) and the relevant assertion fails.
///
/// **Orchestrator-API reconciliations (Hard Rule 6):**
/// - INT-009's bare `engine.leap()` → the wired entry point is
///   `controller.leap()` (→ `engine.leap()`); `leap()` throws on a non-sim
///   engine, so the session is started with `simulate: true`. In a simulation
///   session `SessionController._dispatchStep` is a Layer-1 no-op, so the fake
///   services record nothing — INT-009 asserts the engine *state*/*phase*
///   transition, exactly what decision D2 specifies.
/// - The spec sketch's `SessionOrchestrator.cleanDisarm()` + `registerSmsWorkId`
///   map to the real `SessionController`: work-id capture is automatic in
///   `_dispatchStep` (the strategy return), and the cancel fires from
///   `disarm()` + the safe-end branch of `_finaliseLog` (there is no separate
///   `cleanDisarm`/`registerSmsWorkId` method).
library;

import 'dart:async';

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart' hide EnginePhase;

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/engine/chain_event.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/services/protocols/messaging_service_protocol.dart';
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

/// The deterministic WorkManager id the fake `sendMessage` returns for the SMS.
const _kSmsWorkId = 'wm-sms-job-1';

/// All `cancelPending` work-id lists recorded by the messaging fake, flattened.
List<MessageWorkId> _allCancelled(FakeMessagingService messaging) =>
    messaging.cancelledWorkIds.expand((ids) => ids).toList();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GuardianAngelaDatabase db;

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
  });

  tearDown(() async {
    await closeIntegrationDb(db);
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

  test('INT-010 disarm cancels the queued distress SMS (A5) and re-arms to '
      'step 0 without escalating', () {
    fakeAsync((async) {
      final messaging = FakeMessagingService(workIds: [_kSmsWorkId]);
      final fakes = RecordingFakes(contacts: [_bob()], messaging: messaging);
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
      // returns _kSmsWorkId, which the controller accumulates in _smsWorkIds.
      async.elapse(const Duration(seconds: 1));
      check(driver.currentStepIndex).equals(0);
      final sendCalls = messaging.calls.where(
        (c) => c['method'] == 'sendMessage',
      );
      check(sendCalls).isNotEmpty();
      check(sendCalls.first['workId']).equals(_kSmsWorkId);
      // Nothing cancelled yet — the user has not signalled safety.
      check(messaging.cancelledWorkIds).isEmpty();

      // User checks in (the "I'm safe" slider). disarm() retracts the queued
      // SMS via cancelPending BEFORE re-arming the engine to step 0 (A5).
      driver.controller.disarm();
      async.flushMicrotasks();

      // A5 proof: the accumulated work-id reached cancelPending.
      check(messaging.cancelledWorkIds).isNotEmpty();
      check(_allCancelled(messaging)).contains(_kSmsWorkId);

      // Honest disarm behaviour (carried from the prior INT-010): exactly one
      // userDisarmed, the chain re-armed at step 0, never advanced to the
      // callEmergency step.
      check(driver.count(ChainEvent.userDisarmed)).equals(1);
      check(driver.currentStepIndex).equals(0);
      check(driver.count(ChainEvent.stepAdvancing)).equals(0);
      final emergencyCalls = fakes.phone.calls.where(
        (c) => c['method'] == 'callEmergency',
      );
      check(emergencyCalls).isEmpty();

      driver.stop(async);
    });
  });

  test('INT-010 a clean end (correct End-PIN → disarm) cancels the queued '
      'distress SMS (A5)', () {
    fakeAsync((async) {
      final messaging = FakeMessagingService(workIds: [_kSmsWorkId]);
      final fakes = RecordingFakes(contacts: [_bob()], messaging: messaging);
      final container = buildIntegrationContainer(db: db, fakes: fakes);
      final mode = SessionMode(
        id: 'cleanend-sms',
        name: 'Walk Mode',
        chainSteps: [_smsStep(dur: 30, grace: 10), _emergencyStep()],
      );

      final driver = SessionDriver.start(
        async,
        container: container,
        mode: mode,
      );

      // SMS fires and its work-id is accumulated.
      async.elapse(const Duration(seconds: 1));
      check(
        messaging.calls.where((c) => c['method'] == 'sendMessage'),
      ).isNotEmpty();
      check(messaging.cancelledWorkIds).isEmpty();

      // The user ends the session via the correct End-PIN (a safe end) — the
      // queued SMS is cancelled via the safe-end branch of _finaliseLog.
      unawaited(driver.controller.endSession(reason: EndReason.disarm));
      async.flushMicrotasks();

      check(driver.endReason).equals(EndReason.disarm);
      check(_allCancelled(messaging)).contains(_kSmsWorkId);

      driver.stop(async);
    });
  });

  test('INT-010 a distress end (chainExhausted) does NOT cancel the SMS (A5 — '
      'the message must still go out)', () {
    fakeAsync((async) {
      final messaging = FakeMessagingService(workIds: [_kSmsWorkId]);
      final fakes = RecordingFakes(contacts: [_bob()], messaging: messaging);
      final container = buildIntegrationContainer(db: db, fakes: fakes);
      // A short single-step SMS chain that exhausts (escalates) on its own when
      // the user never checks in — the user is NOT safe, so the queued distress
      // SMS must NOT be cancelled.
      final mode = SessionMode(
        id: 'exhaust-sms',
        name: 'Walk Mode',
        chainSteps: [_smsStep(dur: 1, grace: 1)],
      );

      final driver = SessionDriver.start(
        async,
        container: container,
        mode: mode,
      );

      // Run past the duration + grace so the lone step exhausts the chain.
      async.elapse(const Duration(seconds: 5));

      check(driver.endReason).equals(EndReason.chainExhausted);
      check(
        messaging.calls.where((c) => c['method'] == 'sendMessage'),
      ).isNotEmpty();
      // A5 gating: an escalation end never cancels — the distress SMS stands.
      check(messaging.cancelledWorkIds).isEmpty();

      driver.stop(async);
    });
  });
}
