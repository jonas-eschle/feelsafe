import 'dart:async';

import '../../data/models/escalation_chain.dart';
import '../../data/models/escalation_step.dart';
import '../../data/models/session_mode.dart';

/// Events emitted by the session engine during its lifecycle.
enum SessionEvent {
  checkInRequired,
  warningStarted,
  disguisedReminderFired,
  fakeCallStarted,
  smsSending,
  alarmStarted,
  emergencyCallStarted,
  userCheckedIn,
  sessionEnded,
}

/// Pure Dart timer-driven state machine. NO Flutter imports.
///
/// Supports two check-in mechanisms:
/// - **holdButton**: The hold IS the check-in. Releasing starts a countdown
///   of [checkInInterval]. If the user doesn't re-hold within that time,
///   escalation begins immediately (tolerance is 0).
/// - **disguisedReminder**: Timer fires every [checkInInterval]. Each fire is
///   a check-in prompt. If the user doesn't respond, [missedCheckIns] increments.
///   When missedCheckIns exceeds [missedTolerance], escalation begins.
class SessionEngine {
  final EscalationChain escalationChain;
  final CheckInMechanism mechanism;
  final Duration checkInInterval;
  final int missedTolerance;

  final _controller = StreamController<SessionEvent>.broadcast();

  Timer? _checkInTimer;
  Timer? _stepTimer;
  int _missedCheckIns = 0;
  int _currentStepIndex = -1;
  bool _isEscalating = false;
  bool _isHolding = false;
  bool _ended = false;

  /// The event stream. Listen to this for state transitions.
  Stream<SessionEvent> get events => _controller.stream;

  int get missedCheckIns => _missedCheckIns;
  int get currentStepIndex => _currentStepIndex;
  bool get isEscalating => _isEscalating;
  bool get isHolding => _isHolding;

  SessionEngine({
    required this.escalationChain,
    required this.mechanism,
    required this.checkInInterval,
    required this.missedTolerance,
  });

  /// Start the session. For holdButton mode, the user is expected to
  /// immediately hold the button (call [holdStart]).
  /// For disguisedReminder mode, the check-in timer starts immediately.
  void start() {
    if (_ended) {
      throw StateError('Cannot start an ended session');
    }
    if (mechanism == CheckInMechanism.holdButton) {
      // In walk mode, we wait for the first hold. If the user doesn't hold,
      // the countdown starts immediately as a "release" state.
      _startCheckInTimer();
    } else {
      _startCheckInTimer();
    }
  }

  /// User holds the button (walk mode only).
  void holdStart() {
    if (_ended) return;
    _isHolding = true;
    _cancelCheckInTimer();
    if (_isEscalating) {
      // Holding during escalation = check-in
      _resetEscalation();
      _controller.add(SessionEvent.userCheckedIn);
    }
  }

  /// User releases the button (walk mode only).
  /// Starts the countdown timer.
  void holdRelease() {
    if (_ended) return;
    _isHolding = false;
    if (!_isEscalating) {
      _startCheckInTimer();
    }
  }

  /// User explicitly checks in (date mode "I'm OK" button, or any mode).
  void checkIn() {
    if (_ended) return;
    _resetEscalation();
    _controller.add(SessionEvent.userCheckedIn);
    _startCheckInTimer();
  }

  /// End the session. Cancels all timers, emits [SessionEvent.sessionEnded],
  /// and closes the stream.
  void endSession() {
    if (_ended) return;
    _ended = true;
    _cancelCheckInTimer();
    _cancelStepTimer();
    _isEscalating = false;
    _controller.add(SessionEvent.sessionEnded);
    _controller.close();
  }

  // -- Private implementation --

  void _startCheckInTimer() {
    _cancelCheckInTimer();
    _checkInTimer = Timer(checkInInterval, _onCheckInTimerFired);
  }

  void _cancelCheckInTimer() {
    _checkInTimer?.cancel();
    _checkInTimer = null;
  }

  void _cancelStepTimer() {
    _stepTimer?.cancel();
    _stepTimer = null;
  }

  void _onCheckInTimerFired() {
    if (_ended) return;

    _controller.add(SessionEvent.checkInRequired);

    if (mechanism == CheckInMechanism.holdButton) {
      // Walk mode: tolerance is typically 0, so escalate immediately.
      _missedCheckIns++;
      if (_missedCheckIns > missedTolerance) {
        _beginEscalation();
      } else {
        _startCheckInTimer();
      }
    } else {
      // Date mode: increment missed, check tolerance.
      _missedCheckIns++;
      if (_missedCheckIns > missedTolerance) {
        _beginEscalation();
      } else {
        _startCheckInTimer();
      }
    }
  }

  void _resetEscalation() {
    _cancelCheckInTimer();
    _cancelStepTimer();
    _missedCheckIns = 0;
    _currentStepIndex = -1;
    _isEscalating = false;
  }

  void _beginEscalation() {
    _isEscalating = true;
    _currentStepIndex = -1;
    _advanceStep();
  }

  void _advanceStep() {
    if (_ended) return;

    final activeSteps = escalationChain.activeSteps;
    _currentStepIndex++;

    if (_currentStepIndex >= activeSteps.length) {
      // All steps exhausted — session stays in last state.
      return;
    }

    final step = activeSteps[_currentStepIndex];
    _emitStepEvent(step);

    _cancelStepTimer();
    _stepTimer = Timer(step.timeout, _advanceStep);
  }

  void _emitStepEvent(EscalationStep step) {
    final event = switch (step.type) {
      EscalationStepType.countdownWarning => SessionEvent.warningStarted,
      EscalationStepType.disguisedReminder =>
        SessionEvent.disguisedReminderFired,
      EscalationStepType.fakeCall => SessionEvent.fakeCallStarted,
      EscalationStepType.smsContacts => SessionEvent.smsSending,
      EscalationStepType.loudAlarm => SessionEvent.alarmStarted,
      EscalationStepType.callEmergencyServices =>
        SessionEvent.emergencyCallStarted,
    };
    _controller.add(event);
  }
}
