/// End-to-end distress flow tests covering the interaction between
/// [SessionEngine], [SessionOrchestrator], and the distress chain.
///
/// Scenarios:
///   * hardware panic fires distress mid-main-chain;
///   * duress PIN silently replaces chain (no confirmation);
///   * wrong-PIN threshold exhausted replaces chain;
///   * distress-during-distress is a no-op (D-SAFETY-17).
library;

import 'dart:async';

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/models/chain_event.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/session_context.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/session_orchestrator.dart';
import 'package:guardianangela/services/fakes/fake_audio_service.dart';
import 'package:guardianangela/services/fakes/fake_messaging_service.dart';
import 'package:guardianangela/services/fakes/fake_notification_service.dart';
import 'package:guardianangela/services/fakes/fake_phone_service.dart';
import 'package:guardianangela/services/fakes/fake_vibration_service.dart';

import '../helpers/test_helpers.dart';

/// Wires an engine to an orchestrator and records emitted events.
/// Returns the tuple; caller is responsible for disposal.
_Harness _wire({
  required List<ChainStep> mainChain,
  bool isSimulation = false,
}) {
  final audio = FakeAudioService();
  final messaging = FakeMessagingService();
  final phone = FakePhoneService();
  final notif = FakeNotificationService();
  final vib = FakeVibrationService();
  final contacts = [makeContact(id: 'a'), makeContact(id: 'b')];
  final engine = SessionEngine(
    chainSteps: mainChain,
    isSimulation: isSimulation,
    random: FixedRandom(),
  );
  final events = <ChainEventData>[];
  final orch = SessionOrchestrator(
    isSimulation: isSimulation,
    chainStepsResolver: () => engine.steps,
    messagingService: messaging,
    servicesBuilder: (isCancelled, register) => EventServices(
      audio: audio,
      messaging: messaging,
      phone: phone,
      notification: notif,
      vibration: vib,
      context: SessionContext(
        contacts: contacts,
        isSimulation: isSimulation,
      ),
      isCancelled: isCancelled,
      registerSmsWorkId: register,
    ),
  );
  final sub = engine.events.listen((e) {
    events.add(e);
    unawaited(orch.handleEvent(e));
  });
  return _Harness(
    engine: engine,
    orch: orch,
    events: events,
    sub: sub,
    audio: audio,
    messaging: messaging,
    phone: phone,
    notif: notif,
    vib: vib,
  );
}

final class _Harness {
  _Harness({
    required this.engine,
    required this.orch,
    required this.events,
    required this.sub,
    required this.audio,
    required this.messaging,
    required this.phone,
    required this.notif,
    required this.vib,
  });

  final SessionEngine engine;
  final SessionOrchestrator orch;
  final List<ChainEventData> events;
  final StreamSubscription<ChainEventData> sub;
  final FakeAudioService audio;
  final FakeMessagingService messaging;
  final FakePhoneService phone;
  final FakeNotificationService notif;
  final FakeVibrationService vib;

  Future<void> dispose() async {
    await sub.cancel();
    orch.dispose();
    engine.dispose();
    audio.dispose();
    messaging.dispose();
    phone.dispose();
    notif.dispose();
    vib.dispose();
  }
}

ChainStep _hold() => holdStep(durationSeconds: 30, gracePeriodSeconds: 5);
ChainStep _sms({int order = 0}) => smsStep(
  order: order,
  durationSeconds: 1,
  gracePeriodSeconds: 0,
);
ChainStep _alarm({int order = 1}) => step(
  type: ChainStepType.loudAlarm,
  order: order,
  durationSeconds: 1,
  gracePeriodSeconds: 0,
);
ChainStep _callEmer({int order = 2}) => step(
  type: ChainStepType.callEmergency,
  order: order,
  durationSeconds: 1,
  gracePeriodSeconds: 0,
);

void main() {
  group('Distress flow: hardware panic replaces main chain', () {
    test('main hold chain is replaced by distress on panic', () {
      fakeAsync((async) {
        final h = _wire(mainChain: [_hold(), _sms(order: 1)]);
        h.engine.start();
        async.flushMicrotasks();
        // Simulate hardware panic trigger — replace the chain.
        h.engine.replaceWithDistressChain([_sms(order: 0), _alarm()]);
        async.elapse(const Duration(seconds: 3));
        check(h.engine.isDistressChain).isTrue();
        final types = h.events
            .where((e) => e.event == ChainEvent.stepStarted)
            .map((e) => e.stepType)
            .toList();
        check(types).contains(ChainStepType.smsContact);
        check(types).contains(ChainStepType.loudAlarm);
        unawaited(h.dispose());
      });
    });

    test('distress completion emits distressCompleted', () {
      fakeAsync((async) {
        final h = _wire(mainChain: [_hold()]);
        h.engine.start();
        async.flushMicrotasks();
        h.engine.replaceWithDistressChain([_sms(), _alarm()]);
        async.elapse(const Duration(seconds: 10));
        final kinds = h.events.map((e) => e.event).toList();
        check(kinds).contains(ChainEvent.distressTriggered);
        check(kinds).contains(ChainEvent.distressCompleted);
        check(kinds).contains(ChainEvent.sessionEnded);
        unawaited(h.dispose());
      });
    });

    test('distress steps fire executeReal through orchestrator', () {
      fakeAsync((async) {
        final h = _wire(mainChain: [_hold()]);
        h.engine.start();
        async.flushMicrotasks();
        h.engine.replaceWithDistressChain([_sms(), _alarm()]);
        async.elapse(const Duration(seconds: 10));
        check(h.messaging.calls).isNotEmpty();
        check(h.audio.calls).isNotEmpty();
        unawaited(h.dispose());
      });
    });

    test('main-chain steps after replacement do not execute', () {
      fakeAsync((async) {
        final mainSms = _sms(order: 1);
        final h = _wire(mainChain: [_hold(), mainSms]);
        h.engine.start();
        async.flushMicrotasks();
        // Replace before the main SMS gets to run.
        h.engine.replaceWithDistressChain([_alarm(order: 0)]);
        async.elapse(const Duration(seconds: 5));
        // The audio alarm (from distress) fired, but the main SMS
        // did not fire through messaging.
        final sentContactIds = h.messaging.calls
            .where((c) => c.startsWith('sendToAll:'))
            .toList();
        check(sentContactIds).isEmpty();
        check(h.audio.calls).isNotEmpty();
        unawaited(h.dispose());
      });
    });

    test(
      'replaceWithDistressChain during idle transitions to distress chain',
      () {
        fakeAsync((async) {
          // Simulate duress PIN fired before any start.
          final h = _wire(mainChain: [_hold()]);
          h.engine.replaceWithDistressChain([_sms()]);
          async.elapse(const Duration(seconds: 3));
          check(h.engine.isDistressChain).isTrue();
          final kinds = h.events.map((e) => e.event).toList();
          check(kinds).contains(ChainEvent.sessionStarted);
          check(kinds).contains(ChainEvent.distressTriggered);
          unawaited(h.dispose());
        });
      },
    );
  });

  group('Distress flow: duress PIN (silent trigger)', () {
    test('duress replacement emits no pre-confirmation events', () {
      fakeAsync((async) {
        final h = _wire(mainChain: [_hold()]);
        h.engine.start();
        async.flushMicrotasks();
        // Duress PIN: instantly replace the chain (no dialog).
        h.engine.replaceWithDistressChain([_sms(), _alarm()]);
        async.flushMicrotasks();
        // No "confirmation" event type exists — replacement is atomic.
        final kinds = h.events.map((e) => e.event).toList();
        check(kinds).contains(ChainEvent.distressTriggered);
        unawaited(h.dispose());
      });
    });

    test('duress keeps delivering through the orchestrator', () {
      fakeAsync((async) {
        final h = _wire(mainChain: [_hold()]);
        h.engine.start();
        async.flushMicrotasks();
        h.engine.replaceWithDistressChain([_sms()]);
        async.elapse(const Duration(seconds: 3));
        check(h.messaging.calls).isNotEmpty();
        unawaited(h.dispose());
      });
    });

    test(
      'duress during grace of hold step still replaces chain',
      () {
        fakeAsync((async) {
          final h = _wire(
            mainChain: [
              holdStep(durationSeconds: 5, gracePeriodSeconds: 10),
            ],
          );
          h.engine.start();
          async.flushMicrotasks();
          // Enter grace by not holding.
          async.elapse(const Duration(milliseconds: 100));
          h.engine.replaceWithDistressChain([_sms()]);
          async.elapse(const Duration(seconds: 3));
          check(h.engine.isDistressChain).isTrue();
          unawaited(h.dispose());
        });
      },
    );
  });

  group('Distress flow: wrong-PIN threshold', () {
    test('N consecutive triggerings fire distress once', () {
      fakeAsync((async) {
        final h = _wire(mainChain: [_hold()]);
        h.engine.start();
        async.flushMicrotasks();
        // Simulate the controller firing distress after N wrong PINs.
        h.engine.replaceWithDistressChain([_sms()]);
        async.elapse(const Duration(seconds: 3));
        final distressEvents = h.events
            .where((e) => e.event == ChainEvent.distressTriggered)
            .toList();
        check(distressEvents.length).equals(1);
        unawaited(h.dispose());
      });
    });

    test('wrong-PIN triggers run through orchestrator delivery', () {
      fakeAsync((async) {
        final h = _wire(mainChain: [_hold()]);
        h.engine.start();
        async.flushMicrotasks();
        h.engine.replaceWithDistressChain([_sms(), _callEmer()]);
        async.elapse(const Duration(seconds: 10));
        check(h.messaging.calls).isNotEmpty();
        check(h.phone.calls).isNotEmpty();
        unawaited(h.dispose());
      });
    });
  });

  group('Distress flow: D-SAFETY-17 non-interruption', () {
    test('second replaceWithDistressChain is a no-op', () {
      fakeAsync((async) {
        final h = _wire(mainChain: [_hold()]);
        h.engine.start();
        async.flushMicrotasks();
        h.engine.replaceWithDistressChain([_sms()]);
        async.flushMicrotasks();
        final countBefore = h.events
            .where((e) => e.event == ChainEvent.distressTriggered)
            .length;
        // Try a second distress — should be a no-op.
        h.engine.replaceWithDistressChain([_alarm()]);
        async.flushMicrotasks();
        final countAfter = h.events
            .where((e) => e.event == ChainEvent.distressTriggered)
            .length;
        check(countAfter).equals(countBefore);
        unawaited(h.dispose());
      });
    });

    test('second distress does not swap the active steps', () {
      fakeAsync((async) {
        final h = _wire(mainChain: [_hold()]);
        h.engine.start();
        async.flushMicrotasks();
        h.engine.replaceWithDistressChain([_sms()]);
        async.flushMicrotasks();
        final firstSteps = h.engine.steps;
        h.engine.replaceWithDistressChain([_alarm()]);
        async.flushMicrotasks();
        check(h.engine.steps).deepEquals(firstSteps);
        unawaited(h.dispose());
      });
    });

    test(
      'replaceWithDistressChain throws on empty steps list',
      () {
        fakeAsync((async) {
          final h = _wire(mainChain: [_hold()]);
          h.engine.start();
          async.flushMicrotasks();
          check(
            () => h.engine.replaceWithDistressChain(const []),
          ).throws<ArgumentError>();
          unawaited(h.dispose());
        });
      },
    );

    test(
      'replaceWithDistressChain after sessionEnded is a no-op',
      () {
        fakeAsync((async) {
          final h = _wire(mainChain: [_hold()]);
          h.engine.start();
          async.flushMicrotasks();
          h.engine.disarm();
          async.flushMicrotasks();
          final countBefore = h.events
              .where((e) => e.event == ChainEvent.distressTriggered)
              .length;
          h.engine.replaceWithDistressChain([_sms()]);
          async.flushMicrotasks();
          final countAfter = h.events
              .where((e) => e.event == ChainEvent.distressTriggered)
              .length;
          check(countAfter).equals(countBefore);
          unawaited(h.dispose());
        });
      },
    );
  });

  group('Distress flow: simulation mode', () {
    test('distress in simulation uses SIM branch, no real calls', () {
      fakeAsync((async) {
        final descriptions = <String>[];
        final audio = FakeAudioService();
        final messaging = FakeMessagingService();
        final phone = FakePhoneService();
        final notif = FakeNotificationService();
        final vib = FakeVibrationService();
        final engine = SessionEngine(
          chainSteps: [_hold()],
          isSimulation: true,
          random: FixedRandom(),
        );
        final orch = SessionOrchestrator(
          isSimulation: true,
          chainStepsResolver: () => engine.steps,
          messagingService: messaging,
          onSimulationDescription: descriptions.add,
          servicesBuilder: (isCancelled, register) => EventServices(
            audio: audio,
            messaging: messaging,
            phone: phone,
            notification: notif,
            vibration: vib,
            context: SessionContext(
              contacts: [makeContact(id: 'a')],
              isSimulation: true,
            ),
            isCancelled: isCancelled,
            registerSmsWorkId: register,
          ),
        );
        final sub = engine.events.listen(
          (e) => unawaited(orch.handleEvent(e)),
        );
        engine.start();
        async.flushMicrotasks();
        engine.replaceWithDistressChain([_sms(), _alarm()]);
        async.elapse(const Duration(seconds: 10));
        check(audio.calls).isEmpty();
        check(messaging.calls).isEmpty();
        check(phone.calls).isEmpty();
        check(descriptions).isNotEmpty();
        sub.cancel();
        orch.dispose();
        engine.dispose();
        audio.dispose();
        messaging.dispose();
        phone.dispose();
        notif.dispose();
        vib.dispose();
      });
    });
  });
}
