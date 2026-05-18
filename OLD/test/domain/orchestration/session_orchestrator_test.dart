/// Tests for [SessionOrchestrator].
///
/// Covers:
/// - stepStarted dispatch into `executeReal` with live services;
/// - Layer 1 of the 4-layer simulation defense: `isSimulation` =>
///   `simulationDescription` is surfaced via
///   `onSimulationDescription` and `executeReal` is NEVER called;
/// - error isolation (D-STRATEGY-2 "continue"): thrown errors from
///   strategies are routed to `onStepExecutionFailed` and the chain
///   is not interrupted;
/// - SMS-work-id registration and cancellation on `cancelPendingWork`;
/// - ignore-list: events other than `stepStarted` are passed through
///   without side-effects.
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/chain_event.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/session_context.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';
import 'package:guardianangela/domain/orchestration/session_orchestrator.dart';
import 'package:guardianangela/services/fakes/fake_audio_service.dart';
import 'package:guardianangela/services/fakes/fake_messaging_service.dart';
import 'package:guardianangela/services/fakes/fake_notification_service.dart';
import 'package:guardianangela/services/fakes/fake_phone_service.dart';
import 'package:guardianangela/services/fakes/fake_vibration_service.dart';
import 'package:guardianangela/services/protocols/messaging_service_protocol.dart';
import '../../helpers/test_helpers.dart';

/// Builds a [ChainEventData] for tests.
ChainEventData _event({
  required ChainEvent event,
  int? stepIndex,
  ChainStepType? stepType,
  DateTime? timestamp,
}) => ChainEventData(
  event: event,
  timestamp: timestamp ?? DateTime.utc(2026, 4, 20),
  stepIndex: stepIndex,
  stepType: stepType,
);

class _OrchHarness {
  _OrchHarness({
    this.isSimulation = false,
    List<ChainStep>? steps,
    List<String>? contactIds,
  }) : _steps = steps ?? const [],
       _contactIds = contactIds;

  List<ChainStep> _steps;

  // ignore: unused_field
  final List<String>? _contactIds;

  final FakeAudioService audio = FakeAudioService();
  final FakeMessagingService messaging = FakeMessagingService();
  final FakePhoneService phone = FakePhoneService();
  final FakeNotificationService notification = FakeNotificationService();
  final FakeVibrationService vibration = FakeVibrationService();

  final List<SimulationDescription> simulationDescriptions =
      <SimulationDescription>[];
  final List<({ChainStep step, Object error})> failures =
      <({ChainStep step, Object error})>[];

  final bool isSimulation;

  void updateSteps(List<ChainStep> newSteps) {
    _steps = newSteps;
  }

  SessionOrchestrator build({MessagingServiceProtocol? messagingOverride}) =>
      SessionOrchestrator(
        isSimulation: isSimulation,
        servicesBuilder: (isCancelled, register) => EventServices(
          audio: audio,
          messaging: messaging,
          phone: phone,
          notification: notification,
          vibration: vibration,
          context: SessionContext(isSimulation: isSimulation),
          isCancelled: isCancelled,
          registerSmsWorkId: register,
        ),
        chainStepsResolver: () => _steps,
        messagingService: messagingOverride ?? messaging,
        onSimulationDescription: simulationDescriptions.add,
        onStepExecutionFailed:
            ({required step, required error, required stack}) {
              failures.add((step: step, error: error));
            },
      );

  void dispose() {
    audio.dispose();
    messaging.dispose();
    phone.dispose();
    notification.dispose();
    vibration.dispose();
  }
}

/// A messaging service that always throws from `sendToAll` — used
/// to verify error isolation inside `handleEvent`.
final class _ExplodingMessagingService implements MessagingServiceProtocol {
  final StreamController<MessageDeliveryUpdate> _delivery =
      StreamController<MessageDeliveryUpdate>.broadcast();
  final StreamController<SmsRetryExhaustedEvent> _retry =
      StreamController<SmsRetryExhaustedEvent>.broadcast();

  final List<String> calls = [];

  @override
  Future<bool> canAutoSend(MessageChannel channel) async => true;

  @override
  Future<MessageWorkId> sendMessage({
    required EmergencyContact contact,
    required String message,
    required MessageChannel channel,
    bool isSimulation = false,
  }) async {
    throw StateError('boom');
  }

  @override
  Future<List<MessageWorkId>> sendToAll({
    required List<EmergencyContact> contacts,
    required String message,
    bool isSimulation = false,
  }) async {
    throw StateError('boom');
  }

  @override
  Future<void> cancelPending(List<MessageWorkId> workIds) async {
    calls.add('cancelPending:${workIds.length}');
  }

  @override
  Stream<MessageDeliveryUpdate> get deliveryUpdates => _delivery.stream;

  @override
  Stream<SmsRetryExhaustedEvent> get smsRetryExhausted => _retry.stream;

  @override
  Future<void> retryExhaustedSms(String workId) async {}

  void dispose() {
    _delivery.close();
    _retry.close();
  }
}

void main() {
  group('SessionOrchestrator.handleEvent', () {
    test('ignores events other than stepStarted', () async {
      final harness = _OrchHarness(
        steps: [step(type: ChainStepType.loudAlarm)],
      );
      addTearDown(harness.dispose);
      final orch = harness.build();
      await orch.handleEvent(
        _event(event: ChainEvent.sessionStarted, stepIndex: 0),
      );
      await orch.handleEvent(
        _event(event: ChainEvent.stepAdvancing, stepIndex: 0),
      );
      await orch.handleEvent(_event(event: ChainEvent.sessionEnded));
      expect(harness.audio.calls, isEmpty);
      expect(harness.vibration.calls, isEmpty);
    });

    test('dispatches stepStarted to executeReal', () async {
      final harness = _OrchHarness(
        steps: [step(type: ChainStepType.loudAlarm)],
      );
      addTearDown(harness.dispose);
      final orch = harness.build();
      await orch.handleEvent(
        _event(event: ChainEvent.stepStarted, stepIndex: 0),
      );
      expect(harness.audio.calls, contains('playAlarm:maxVolume=true'));
    });

    test('ignores stepStarted with null stepIndex', () async {
      final harness = _OrchHarness(
        steps: [step(type: ChainStepType.loudAlarm)],
      );
      addTearDown(harness.dispose);
      final orch = harness.build();
      await orch.handleEvent(_event(event: ChainEvent.stepStarted));
      expect(harness.audio.calls, isEmpty);
    });

    test('ignores stepStarted with out-of-range stepIndex', () async {
      final harness = _OrchHarness(
        steps: [step(type: ChainStepType.loudAlarm)],
      );
      addTearDown(harness.dispose);
      final orch = harness.build();
      await orch.handleEvent(
        _event(event: ChainEvent.stepStarted, stepIndex: 7),
      );
      expect(harness.audio.calls, isEmpty);
    });

    test('ignores negative stepIndex', () async {
      final harness = _OrchHarness(
        steps: [step(type: ChainStepType.loudAlarm)],
      );
      addTearDown(harness.dispose);
      final orch = harness.build();
      await orch.handleEvent(
        _event(event: ChainEvent.stepStarted, stepIndex: -1),
      );
      expect(harness.audio.calls, isEmpty);
    });

    test('dispatches to correct step when multiple defined', () async {
      final harness = _OrchHarness(
        steps: [
          step(type: ChainStepType.countdownWarning),
          step(type: ChainStepType.loudAlarm),
          step(type: ChainStepType.callEmergency),
        ],
      );
      addTearDown(harness.dispose);
      final orch = harness.build();
      await orch.handleEvent(
        _event(event: ChainEvent.stepStarted, stepIndex: 1),
      );
      expect(harness.audio.calls, contains('playAlarm:maxVolume=true'));
      expect(harness.phone.calls, isEmpty);
    });

    test('resolves updated chain steps on each call', () async {
      final harness = _OrchHarness(
        steps: [step(type: ChainStepType.loudAlarm)],
      );
      addTearDown(harness.dispose);
      final orch = harness.build();
      await orch.handleEvent(
        _event(event: ChainEvent.stepStarted, stepIndex: 0),
      );
      expect(harness.audio.calls, hasLength(1));
      harness.updateSteps([step(type: ChainStepType.callEmergency)]);
      await orch.handleEvent(
        _event(event: ChainEvent.stepStarted, stepIndex: 0),
      );
      expect(harness.phone.calls, contains('callEmergency:112'));
    });
  });

  group('SessionOrchestrator simulation mode (Layer 1)', () {
    test('does NOT invoke executeReal in simulation mode', () async {
      final harness = _OrchHarness(
        isSimulation: true,
        steps: [step(type: ChainStepType.loudAlarm)],
      );
      addTearDown(harness.dispose);
      final orch = harness.build();
      await orch.handleEvent(
        _event(event: ChainEvent.stepStarted, stepIndex: 0),
      );
      // No service calls at all.
      expect(harness.audio.calls, isEmpty);
      expect(harness.vibration.calls, isEmpty);
      expect(harness.messaging.calls, isEmpty);
      expect(harness.phone.calls, isEmpty);
      expect(harness.notification.calls, isEmpty);
    });

    test('surfaces simulationDescription via callback', () async {
      final harness = _OrchHarness(
        isSimulation: true,
        steps: [step(type: ChainStepType.loudAlarm)],
      );
      addTearDown(harness.dispose);
      final orch = harness.build();
      await orch.handleEvent(
        _event(event: ChainEvent.stepStarted, stepIndex: 0),
      );
      expect(harness.simulationDescriptions, isNotEmpty);
      expect(harness.simulationDescriptions.first.templateKey, isNotEmpty);
    });

    test('simulation mode does not register SMS work ids', () async {
      final harness = _OrchHarness(
        isSimulation: true,
        steps: [step(type: ChainStepType.smsContact)],
      );
      addTearDown(harness.dispose);
      final orch = harness.build();
      await orch.handleEvent(
        _event(event: ChainEvent.stepStarted, stepIndex: 0),
      );
      expect(orch.pendingWorkIds, isEmpty);
    });

    test('simulation mode emits one description per stepStarted', () async {
      final harness = _OrchHarness(
        isSimulation: true,
        steps: [
          step(type: ChainStepType.loudAlarm),
          step(type: ChainStepType.callEmergency),
        ],
      );
      addTearDown(harness.dispose);
      final orch = harness.build();
      await orch.handleEvent(
        _event(event: ChainEvent.stepStarted, stepIndex: 0),
      );
      await orch.handleEvent(
        _event(event: ChainEvent.stepStarted, stepIndex: 1),
      );
      expect(harness.simulationDescriptions.length, 2);
    });

    test('simulation mode does not call onStepExecutionFailed', () async {
      final harness = _OrchHarness(
        isSimulation: true,
        steps: [step(type: ChainStepType.loudAlarm)],
      );
      addTearDown(harness.dispose);
      final orch = harness.build();
      await orch.handleEvent(
        _event(event: ChainEvent.stepStarted, stepIndex: 0),
      );
      expect(harness.failures, isEmpty);
    });

    test('simulation mode still ignores non-stepStarted events', () async {
      final harness = _OrchHarness(
        isSimulation: true,
        steps: [step(type: ChainStepType.loudAlarm)],
      );
      addTearDown(harness.dispose);
      final orch = harness.build();
      await orch.handleEvent(_event(event: ChainEvent.sessionStarted));
      expect(harness.simulationDescriptions, isEmpty);
    });
  });

  group('SessionOrchestrator error isolation (D-STRATEGY-2)', () {
    test('routes executeReal error to onStepExecutionFailed', () async {
      final harness = _OrchHarness(
        steps: [
          smsStep(contactIds: const ['does-not-exist']),
        ],
      );
      addTearDown(harness.dispose);
      // Use the exploding messaging service to force a throw inside
      // the smsContact strategy's executeReal path.
      final exploding = _ExplodingMessagingService();
      addTearDown(exploding.dispose);
      // We need context.contacts to include 'does-not-exist' so the
      // strategy attempts to send. Override the services builder
      // directly via a tailored orchestrator.
      final orch = SessionOrchestrator(
        isSimulation: false,
        chainStepsResolver: () => [
          step(
            type: ChainStepType.smsContact,
            config: const SmsContactConfig(),
          ),
        ],
        messagingService: exploding,
        onStepExecutionFailed:
            ({required step, required error, required stack}) {
              harness.failures.add((step: step, error: error));
            },
        onSimulationDescription: harness.simulationDescriptions.add,
        servicesBuilder: (isCancelled, register) => EventServices(
          audio: harness.audio,
          messaging: exploding,
          phone: harness.phone,
          notification: harness.notification,
          vibration: harness.vibration,
          context: SessionContext(contacts: [makeContact(id: 'a')]),
          isCancelled: isCancelled,
          registerSmsWorkId: register,
        ),
      );
      await orch.handleEvent(
        _event(event: ChainEvent.stepStarted, stepIndex: 0),
      );
      expect(harness.failures, hasLength(1));
      expect(harness.failures.first.error, isA<StateError>());
    });

    test('error in one step does not interrupt subsequent steps', () async {
      final exploding = _ExplodingMessagingService();
      addTearDown(exploding.dispose);
      final harness = _OrchHarness(
        steps: [
          step(type: ChainStepType.smsContact),
          step(type: ChainStepType.loudAlarm),
        ],
      );
      addTearDown(harness.dispose);
      final orch = SessionOrchestrator(
        isSimulation: false,
        chainStepsResolver: () => [
          step(type: ChainStepType.smsContact),
          step(type: ChainStepType.loudAlarm),
        ],
        servicesBuilder: (isCancelled, register) => EventServices(
          audio: harness.audio,
          messaging: exploding,
          phone: harness.phone,
          notification: harness.notification,
          vibration: harness.vibration,
          context: SessionContext(contacts: [makeContact(id: 'a')]),
          isCancelled: isCancelled,
          registerSmsWorkId: register,
        ),
        messagingService: exploding,
        onStepExecutionFailed:
            ({required step, required error, required stack}) {
              harness.failures.add((step: step, error: error));
            },
      );
      await orch.handleEvent(
        _event(event: ChainEvent.stepStarted, stepIndex: 0),
      );
      await orch.handleEvent(
        _event(event: ChainEvent.stepStarted, stepIndex: 1),
      );
      // Step 0 (SMS) failed via error hook.
      expect(harness.failures, hasLength(1));
      // Step 1 (loudAlarm) still executed.
      expect(harness.audio.calls, contains('playAlarm:maxVolume=true'));
    });

    test('no failure hook still swallows errors silently', () async {
      final exploding = _ExplodingMessagingService();
      addTearDown(exploding.dispose);
      final harness = _OrchHarness(
        steps: [step(type: ChainStepType.smsContact)],
      );
      addTearDown(harness.dispose);
      final orch = SessionOrchestrator(
        isSimulation: false,
        chainStepsResolver: () => [step(type: ChainStepType.smsContact)],
        servicesBuilder: (isCancelled, register) => EventServices(
          audio: harness.audio,
          messaging: exploding,
          phone: harness.phone,
          notification: harness.notification,
          vibration: harness.vibration,
          context: SessionContext(contacts: [makeContact(id: 'a')]),
          isCancelled: isCancelled,
          registerSmsWorkId: register,
        ),
        messagingService: exploding,
      );
      // Must not throw.
      await orch.handleEvent(
        _event(event: ChainEvent.stepStarted, stepIndex: 0),
      );
    });
  });

  group('SessionOrchestrator.cancelPendingWork', () {
    test('clears registered ids and calls cancelPending', () async {
      final harness = _OrchHarness(
        steps: [step(type: ChainStepType.smsContact)],
      );
      addTearDown(harness.dispose);
      // Pre-populate the context with a contact so the SMS strategy
      // enqueues something and registers the work id.
      final orch = SessionOrchestrator(
        isSimulation: false,
        chainStepsResolver: () => [step(type: ChainStepType.smsContact)],
        messagingService: harness.messaging,
        servicesBuilder: (isCancelled, register) => EventServices(
          audio: harness.audio,
          messaging: harness.messaging,
          phone: harness.phone,
          notification: harness.notification,
          vibration: harness.vibration,
          context: SessionContext(contacts: [makeContact(id: 'a')]),
          isCancelled: isCancelled,
          registerSmsWorkId: register,
        ),
      );
      await orch.handleEvent(
        _event(event: ChainEvent.stepStarted, stepIndex: 0),
      );
      expect(orch.pendingWorkIds.length, 1);
      await orch.cancelPendingWork();
      expect(orch.pendingWorkIds, isEmpty);
      expect(harness.messaging.calls, contains('cancelPending:1'));
    });

    test('is idempotent when no work registered', () async {
      final harness = _OrchHarness();
      addTearDown(harness.dispose);
      final orch = harness.build();
      await orch.cancelPendingWork();
      expect(harness.messaging.calls, isEmpty);
      expect(orch.pendingWorkIds, isEmpty);
    });

    test('handles null messagingService gracefully', () async {
      final harness = _OrchHarness();
      addTearDown(harness.dispose);
      final orch = SessionOrchestrator(
        isSimulation: false,
        chainStepsResolver: () => const [],
        servicesBuilder: (isCancelled, register) => EventServices(
          audio: harness.audio,
          messaging: harness.messaging,
          phone: harness.phone,
          notification: harness.notification,
          vibration: harness.vibration,
          context: const SessionContext(),
          isCancelled: isCancelled,
          registerSmsWorkId: register,
        ),
      );
      await orch.cancelPendingWork();
      expect(orch.pendingWorkIds, isEmpty);
    });
  });

  group('SessionOrchestrator.dispose', () {
    test('ignores events after dispose', () async {
      final harness = _OrchHarness(
        steps: [step(type: ChainStepType.loudAlarm)],
      );
      addTearDown(harness.dispose);
      final orch = harness.build();
      orch.dispose();
      await orch.handleEvent(
        _event(event: ChainEvent.stepStarted, stepIndex: 0),
      );
      expect(harness.audio.calls, isEmpty);
    });

    test('clears pending work ids', () async {
      final harness = _OrchHarness(
        steps: [step(type: ChainStepType.smsContact)],
      );
      addTearDown(harness.dispose);
      final orch = SessionOrchestrator(
        isSimulation: false,
        chainStepsResolver: () => [step(type: ChainStepType.smsContact)],
        messagingService: harness.messaging,
        servicesBuilder: (isCancelled, register) => EventServices(
          audio: harness.audio,
          messaging: harness.messaging,
          phone: harness.phone,
          notification: harness.notification,
          vibration: harness.vibration,
          context: SessionContext(contacts: [makeContact(id: 'a')]),
          isCancelled: isCancelled,
          registerSmsWorkId: register,
        ),
      );
      await orch.handleEvent(
        _event(event: ChainEvent.stepStarted, stepIndex: 0),
      );
      expect(orch.pendingWorkIds, isNotEmpty);
      orch.dispose();
      expect(orch.pendingWorkIds, isEmpty);
    });
  });

  group('SessionOrchestrator.pendingWorkIds', () {
    test('exposes the registered ids as unmodifiable view', () async {
      final harness = _OrchHarness(
        steps: [step(type: ChainStepType.smsContact)],
      );
      addTearDown(harness.dispose);
      final orch = SessionOrchestrator(
        isSimulation: false,
        chainStepsResolver: () => [step(type: ChainStepType.smsContact)],
        messagingService: harness.messaging,
        servicesBuilder: (isCancelled, register) => EventServices(
          audio: harness.audio,
          messaging: harness.messaging,
          phone: harness.phone,
          notification: harness.notification,
          vibration: harness.vibration,
          context: SessionContext(contacts: [makeContact(id: 'a')]),
          isCancelled: isCancelled,
          registerSmsWorkId: register,
        ),
      );
      await orch.handleEvent(
        _event(event: ChainEvent.stepStarted, stepIndex: 0),
      );
      final snapshot = orch.pendingWorkIds;
      expect(snapshot.length, 1);
      expect(
        () => snapshot.add(const MessageWorkId('x')),
        throwsUnsupportedError,
      );
    });

    test('returns an empty snapshot by default', () {
      final harness = _OrchHarness();
      addTearDown(harness.dispose);
      final orch = harness.build();
      expect(orch.pendingWorkIds, isEmpty);
    });
  });

  group('SessionOrchestrator isCancelled predicate', () {
    test(
      'predicate returns false during normal dispatch, true after dispose',
      () async {
        bool? sawValueDuring;
        bool Function()? predicate;
        final harness = _OrchHarness(
          steps: [step(type: ChainStepType.loudAlarm)],
        );
        addTearDown(harness.dispose);
        final orch = SessionOrchestrator(
          isSimulation: false,
          chainStepsResolver: () => [step(type: ChainStepType.loudAlarm)],
          messagingService: harness.messaging,
          servicesBuilder: (isCancelled, register) {
            // Capture the predicate so we can invoke it before and
            // after dispose.
            sawValueDuring ??= isCancelled();
            predicate ??= isCancelled;
            return EventServices(
              audio: harness.audio,
              messaging: harness.messaging,
              phone: harness.phone,
              notification: harness.notification,
              vibration: harness.vibration,
              context: const SessionContext(),
              isCancelled: isCancelled,
              registerSmsWorkId: register,
            );
          },
        );
        await orch.handleEvent(
          _event(event: ChainEvent.stepStarted, stepIndex: 0),
        );
        expect(sawValueDuring, isFalse);
        expect(predicate, isNotNull);
        orch.dispose();
        expect(predicate!(), isTrue);
      },
    );
  });

  group('SessionOrchestrator onStepExecutionFailedEvent', () {
    test('emits a stepExecutionFailedEvent when executeReal throws',
        () async {
      final exploding = _ExplodingMessagingService();
      addTearDown(exploding.dispose);
      final harness = _OrchHarness(
        steps: [step(type: ChainStepType.smsContact)],
      );
      addTearDown(harness.dispose);
      ChainStep? capturedStep;
      int? capturedIndex;
      final orch = SessionOrchestrator(
        isSimulation: false,
        chainStepsResolver: () => [step(type: ChainStepType.smsContact)],
        messagingService: exploding,
        servicesBuilder: (isCancelled, register) => EventServices(
          audio: harness.audio,
          messaging: exploding,
          phone: harness.phone,
          notification: harness.notification,
          vibration: harness.vibration,
          context: SessionContext(contacts: [makeContact(id: 'a')]),
          isCancelled: isCancelled,
          registerSmsWorkId: register,
        ),
        onStepExecutionFailedEvent: ({required step, required stepIndex}) {
          capturedStep = step;
          capturedIndex = stepIndex;
        },
      );
      await orch.handleEvent(
        _event(event: ChainEvent.stepStarted, stepIndex: 0),
      );
      expect(capturedStep, isNotNull);
      expect(capturedIndex, 0);
    });
  });

  group('SessionOrchestrator onStepExecutionFailed contract', () {
    test('provides step, error, and stack', () async {
      final exploding = _ExplodingMessagingService();
      addTearDown(exploding.dispose);
      final harness = _OrchHarness(
        steps: [step(type: ChainStepType.smsContact)],
      );
      addTearDown(harness.dispose);
      ChainStep? capturedStep;
      Object? capturedError;
      StackTrace? capturedStack;
      final orch = SessionOrchestrator(
        isSimulation: false,
        chainStepsResolver: () => [step(type: ChainStepType.smsContact)],
        messagingService: exploding,
        servicesBuilder: (isCancelled, register) => EventServices(
          audio: harness.audio,
          messaging: exploding,
          phone: harness.phone,
          notification: harness.notification,
          vibration: harness.vibration,
          context: SessionContext(contacts: [makeContact(id: 'a')]),
          isCancelled: isCancelled,
          registerSmsWorkId: register,
        ),
        onStepExecutionFailed:
            ({required step, required error, required stack}) {
              capturedStep = step;
              capturedError = error;
              capturedStack = stack;
            },
      );
      await orch.handleEvent(
        _event(event: ChainEvent.stepStarted, stepIndex: 0),
      );
      expect(capturedStep, isNotNull);
      expect(capturedError, isA<StateError>());
      expect(capturedStack, isNotNull);
    });
  });
}
