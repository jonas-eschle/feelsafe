import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/escalation_chain.dart';
import '../../data/models/session_mode.dart';
import '../../data/models/walk_session.dart';
import '../../services/service_providers.dart';
import '../contacts/contacts_controller.dart';
import '../settings/settings_controller.dart';
import 'session_engine.dart';

final sessionControllerProvider =
    NotifierProvider<SessionController, WalkSession?>(
  SessionController.new,
);

class SessionController extends Notifier<WalkSession?> {
  SessionEngine? _engine;
  StreamSubscription<SessionEvent>? _subscription;

  SessionEngine? get engine => _engine;

  @override
  WalkSession? build() => null;

  Future<void> startSession(SessionMode mode) async {
    // End any existing session first
    if (_engine != null) {
      _dispose();
    }

    final chain = EscalationChain(steps: mode.escalationSteps);

    _engine = SessionEngine(
      escalationChain: chain,
      mechanism: mode.checkInMechanism,
      checkInInterval: mode.checkInInterval,
      missedTolerance: mode.missedTolerance,
    );

    state = WalkSession(
      startTime: DateTime.now(),
      modeId: mode.id,
      state: SessionState.active,
    );

    // Enable wakelock to keep screen on
    await ref.read(wakelockServiceProvider).enable();

    // Start location tracking
    final locationService = ref.read(locationServiceProvider);
    await locationService.requestPermission();
    await locationService.startTracking();

    _subscription = _engine!.events.listen(_onEvent);
    _engine!.start();
  }

  void holdStart() {
    _engine?.holdStart();
    if (state != null) {
      state = state!.copyWith(
        state: SessionState.active,
        lastCheckIn: DateTime.now(),
      );
    }
  }

  void holdRelease() {
    _engine?.holdRelease();
    if (state != null) {
      state = state!.copyWith(state: SessionState.checkInPrompt);
    }
  }

  void checkIn() {
    _engine?.checkIn();
    if (state != null) {
      state = state!.copyWith(
        state: SessionState.active,
        missedCheckIns: 0,
        currentEscalationIndex: -1,
        lastCheckIn: DateTime.now(),
      );
    }
    // Stop any active audio/vibration on check-in
    ref.read(audioServiceProvider).stop();
    ref.read(vibrationServiceProvider).cancel();
  }

  void endSession() {
    _engine?.endSession();
    _stopServices();
    _dispose();
    state = null;
  }

  void _onEvent(SessionEvent event) {
    if (state == null) return;

    // Update location history
    final locationService = ref.read(locationServiceProvider);
    final locationHistory = locationService.history;

    switch (event) {
      case SessionEvent.checkInRequired:
        state = state!.copyWith(
          state: SessionState.checkInPrompt,
          locationHistory: locationHistory,
        );
      case SessionEvent.warningStarted:
        ref.read(vibrationServiceProvider).warningPattern();
        state = state!.copyWith(
          state: SessionState.warning,
          currentEscalationIndex: _engine!.currentStepIndex,
          locationHistory: locationHistory,
        );
      case SessionEvent.disguisedReminderFired:
        state = state!.copyWith(
          state: SessionState.checkInPrompt,
          currentEscalationIndex: _engine!.currentStepIndex,
          locationHistory: locationHistory,
        );
      case SessionEvent.fakeCallStarted:
        state = state!.copyWith(
          state: SessionState.fakeCall,
          currentEscalationIndex: _engine!.currentStepIndex,
          locationHistory: locationHistory,
        );
      case SessionEvent.smsSending:
        _sendEmergencyMessages();
        state = state!.copyWith(
          state: SessionState.smsSent,
          currentEscalationIndex: _engine!.currentStepIndex,
          locationHistory: locationHistory,
        );
      case SessionEvent.alarmStarted:
        ref.read(audioServiceProvider).playAlarm();
        ref.read(vibrationServiceProvider).alarmPattern();
        state = state!.copyWith(
          state: SessionState.alarm,
          currentEscalationIndex: _engine!.currentStepIndex,
          locationHistory: locationHistory,
        );
      case SessionEvent.emergencyCallStarted:
        _callEmergency();
        state = state!.copyWith(
          state: SessionState.emergencyCall,
          currentEscalationIndex: _engine!.currentStepIndex,
          locationHistory: locationHistory,
        );
      case SessionEvent.userCheckedIn:
        ref.read(audioServiceProvider).stop();
        ref.read(vibrationServiceProvider).cancel();
        state = state!.copyWith(
          state: SessionState.active,
          missedCheckIns: 0,
          currentEscalationIndex: -1,
          lastCheckIn: DateTime.now(),
          locationHistory: locationHistory,
        );
      case SessionEvent.sessionEnded:
        state = state!.copyWith(state: SessionState.completed);
    }
  }

  Future<void> _sendEmergencyMessages() async {
    final contacts = ref.read(contactsControllerProvider).valueOrNull ?? [];
    if (contacts.isEmpty) return;

    final locationService = ref.read(locationServiceProvider);
    final locationUrl =
        locationService.getLastLocationUrl() ?? 'Location unavailable';
    final time = DateTime.now().toIso8601String();

    // Build the message with location
    final message =
        'EMERGENCY: I may need help.\n'
        'Last known location: $locationUrl\n'
        'Time: $time';

    await ref.read(messagingServiceProvider).sendToAll(
          contacts: contacts,
          message: message,
        );
  }

  Future<void> _callEmergency() async {
    final settings = ref.read(settingsControllerProvider).valueOrNull;
    final emergencyNumber = settings?.emergencyNumber ?? '112';
    await ref.read(phoneServiceProvider).callEmergency(emergencyNumber);
  }

  Future<void> _stopServices() async {
    await ref.read(audioServiceProvider).stop();
    await ref.read(vibrationServiceProvider).cancel();
    await ref.read(wakelockServiceProvider).disable();
    ref.read(locationServiceProvider).stopTracking();
  }

  void _dispose() {
    _subscription?.cancel();
    _subscription = null;
    _engine = null;
  }
}
