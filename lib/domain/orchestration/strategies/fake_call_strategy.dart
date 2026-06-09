import 'dart:developer';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';
import 'package:guardianangela/services/protocols/messaging_service_protocol.dart';

/// Unique notification ID for the fake-call alarm escalation.
///
/// Must not collide with [kForegroundNotificationId] (1) or the
/// disguised-reminder base (100+).
const int _kFakeCallNotificationId = 50;

/// Strategy for [ChainStepType.fakeCall] steps.
///
/// **Pivot 2 / R-1 — fakeCall is an event, not a pause.** The engine timer
/// continues running while the fake call UI is shown. [FakeCallScreen] is a
/// route push, not a pause-and-overlay. `engine.answerFakeCall()` is a no-op
/// at the engine level. `engine.hangUp()` fires disarm. The rationale:
/// pausing on every fake call would create gaps that an attacker could
/// exploit by repeatedly declining/answering to delay the chain.
///
/// Real mode: fires [AudioServiceProtocol.playRingtone] to start the
/// ringtone, [VibrationServiceProtocol.fakeCallPattern] for the incoming-call
/// vibration, and [NotificationServiceProtocol.showAlarmEscalation] so the
/// fake call surfaces when the device is locked (spec 05:880-886). The
/// [SessionScreen] also pushes [FakeCallScreen] in response to the engine's
/// `stepFired` event (Phase 6 wiring).
///
/// Simulation: all three actions (ringtone, vibration, escalation
/// notification) fire normally — local-only actions safe in sim per spec 02
/// §Simulation behavior summary. This strategy returns `null` from
/// [simulationDescription].
///
/// See spec 02 §5 fakeCall and §Answer / Hang-up Semantics (Pivot 2 / R-1).
final class FakeCallStrategy implements EventStrategy {
  /// Creates a [FakeCallStrategy].
  const FakeCallStrategy();

  @override
  Future<List<MessageWorkId>> executeReal(
    ChainStep step,
    EventServices services,
  ) async {
    final config = step.config is FakeCallConfig
        ? step.config! as FakeCallConfig
        : const FakeCallConfig();

    log(
      'FakeCallStrategy: caller="${config.callerName}" '
      'isSimulation=${services.isSimulation}',
      name: 'FakeCallStrategy',
    );

    // Vibration: realistic incoming-call pattern. Fires in sim (local only).
    await services.vibration.fakeCallPattern();

    // Ringtone: loop until FakeCallScreen answers/declines or the step ends.
    // `customRingtonePath` (Tier-F F3) is the user's own imported ringtone,
    // stored in app-internal storage; null = the bundled default ring. A
    // missing/unreadable custom file degrades to the default inside
    // [RealAudioService.playRingtone] (a broken file must never break the
    // disguise). `voiceRecordingPath` is the *voice* clip that plays on
    // answer (SessionController.answerFakeCall), NOT the ringtone.
    await services.audio.playRingtone(config.customRingtonePath);

    // Alarm escalation notification: ensures the fake call surfaces on the
    // lock screen (spec 05:880-886). Uses the alarm channel with criticalAlert
    // on iOS.
    await services.notification.showAlarmEscalation(
      id: _kFakeCallNotificationId,
      title: 'Incoming call from ${config.callerName}',
      body: 'Guardian Angela fake call.',
    );
    // No SMS enqueued — nothing for the orchestrator to cancel (A5).
    return const [];
  }

  /// Returns `null` — the call screen and ringtone fire normally in
  /// simulation; no `[SIM]` card is needed.
  ///
  /// See spec 02 §5 fakeCall "Simulation: Call screen + ringtone fire
  /// normally."
  @override
  String? simulationDescription(ChainStep step, EventServices services) => null;
}
