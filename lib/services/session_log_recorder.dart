import 'dart:developer';

import 'package:uuid/uuid.dart';

import 'package:guardianangela/data/repositories/session_log_repository.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/engine/chain_event.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/models/session_context.dart';
import 'package:guardianangela/domain/models/session_log.dart';
import 'package:guardianangela/domain/models/session_log_event.dart';
import 'package:guardianangela/services/protocols/session_log_recorder_protocol.dart';

/// Factory typedef for per-session [SessionLogRecorder] construction.
///
/// The provider returns a factory rather than a singleton because
/// [SessionLogRecorder] is a short-lived per-session object.
typedef SessionLogRecorderFactory =
    SessionLogRecorder Function(SessionContext context);

const _uuid = Uuid();

/// Maps a [ChainEvent] to a human-readable event-type string compatible with
/// the spec 03 §SessionLogEvent "Event types" table.
String _mapEventType(ChainEvent event) => switch (event) {
  ChainEvent.sessionStarted => 'started',
  ChainEvent.stepStarted => 'step_fired',
  ChainEvent.stepAdvancing => 'escalated',
  ChainEvent.graceExpired => 'missed',
  ChainEvent.repeatMissed => 'missed',
  ChainEvent.reminderFired => 'step_fired',
  ChainEvent.pauseExpired => 'step_fired',
  ChainEvent.stepExecutionFailed => 'error',
  ChainEvent.distressTriggered => 'step_fired',
  ChainEvent.distressCompleted => 'completed',
  ChainEvent.sessionPaused => 'step_fired',
  ChainEvent.sessionResumed => 'step_fired',
  ChainEvent.userDisarmed => 'disarmed',
  ChainEvent.deceptiveOldPinShown => 'step_fired',
  ChainEvent.sessionEnded => 'completed',
};

/// Production [SessionLogRecorderProtocol].
///
/// One recorder is constructed per session by the `SessionController`
/// (not as a Riverpod singleton). The `sessionLogRecorderProvider` in
/// `service_providers.dart` exposes a [SessionLogRecorderFactory] so the
/// session controller can call `factory(context)` at session start.
///
/// **Event accumulation:** [onEvent] appends one [SessionLogEvent] per
/// received [ChainEventData] in memory. No disk writes occur during the
/// session (per the no-session-restore policy).
///
/// **hadMedicalInfo stamp (spec 05:1136, Extra 47):** computed at
/// [finalise] time: `true` iff the user profile has any medical field AND
/// at least one `smsContact` step in the chain has
/// `SmsContactConfig.includeMedicalInfo = true`.
///
/// **Single atomic write:** [finalise] calls
/// `SessionLogRepository.upsert(log)` exactly once with the fully
/// assembled [SessionLog]. If the process is killed mid-session the log
/// is lost (no-session-restore policy).
///
/// **Single constructor location rule:** no `SessionLogRecorder()`
/// call may appear outside `lib/services/service_providers.dart`
/// (CI grep enforces for `Real*Service`; this class does not have the
/// `Real*` prefix because it has no platform dependency — the name comes
/// from the spec).
class SessionLogRecorder implements SessionLogRecorderProtocol {
  /// Creates a [SessionLogRecorder].
  ///
  /// [context] is the session context resolved at session start.
  /// [repo] is the repository that will receive the single atomic write on
  /// [finalise].
  SessionLogRecorder({
    required SessionContext context,
    required SessionLogRepository repo,
  }) : _context = context,
       _repo = repo,
       _id = _uuid.v4(),
       _startedAt = DateTime.now().toUtc();

  /// Protected access to the session context (visible to subclasses).
  final SessionContext _context;

  /// Protected access to the repository (visible to subclasses).
  final SessionLogRepository _repo;

  /// Session UUID generated at construction.
  final String _id;

  /// UTC timestamp at recorder creation (= session start).
  final DateTime _startedAt;

  final List<SessionLogEvent> _events = [];

  /// Whether [finalise] has already been called on this recorder.
  ///
  /// Visible to subclasses so the sim variant can enforce the same guard.
  // ignore: library_private_types_in_public_api
  bool finalised = false;

  // -------------------------------------------------------------------------
  // SessionLogRecorderProtocol implementation
  // -------------------------------------------------------------------------

  @override
  void onEvent(ChainEventData event) {
    final ts = (event.timestamp ?? DateTime.now()).toUtc();
    _events.add(
      SessionLogEvent(
        timestamp: ts,
        eventType: _mapEventType(event.event),
        stepType: event.stepType?.name,
        stepIndex: event.stepIndex ?? 0,
        description: _describeEvent(event),
      ),
    );
    log(
      'onEvent: ${event.event.name} step=${event.stepIndex}',
      name: 'SessionLogRecorder',
    );
  }

  @override
  Future<void> finalise(EndReason reason) async {
    if (finalised) {
      throw StateError(
        'SessionLogRecorder.finalise() called twice on session $_id. '
        'A recorder must not be reused across sessions.',
      );
    }
    finalised = true;
    final endedAt = DateTime.now().toUtc();
    final hadMedical = _computeHadMedicalInfo();
    final sessionLog = SessionLog(
      id: _id,
      modeId: _context.mode.id,
      modeName: _context.mode.name,
      startedAt: _startedAt,
      endedAt: endedAt,
      endReason: reason,
      isSimulation: false,
      hadMedicalInfo: hadMedical,
      events: List.unmodifiable(_events),
    );
    log(
      'finalise: reason=${reason.name} events=${_events.length} '
      'hadMedical=$hadMedical',
      name: 'SessionLogRecorder',
    );
    await _repo.upsert(sessionLog);
  }

  // -------------------------------------------------------------------------
  // Protected helpers (for subclass access)
  // -------------------------------------------------------------------------

  /// Returns a snapshot of the accumulated events (unmodifiable).
  List<SessionLogEvent> get accumulatedEvents => List.unmodifiable(_events);

  /// Returns the session UUID.
  String get sessionId => _id;

  /// Returns the session start timestamp.
  DateTime get sessionStartedAt => _startedAt;

  /// Returns the session context.
  SessionContext get sessionContext => _context;

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  /// Stamps `hadMedicalInfo` per spec 05:1136 (Extra 47).
  ///
  /// True iff the user profile has at least one medical field set AND
  /// at least one `smsContact` step in the session has
  /// `SmsContactConfig.includeMedicalInfo = true`.
  bool _computeHadMedicalInfo() {
    if (!_context.profileHasMedicalInfo) return false;
    return _context.mode.chainSteps.any((step) {
      final cfg = step.config;
      if (cfg is SmsContactConfig) {
        return cfg.includeMedicalInfo;
      }
      return false;
    });
  }

  /// Returns a concise human-readable description for [event].
  String _describeEvent(ChainEventData event) {
    final stepLabel = event.stepIndex != null ? 'step ${event.stepIndex}' : '';
    final typeLabel = event.stepType != null
        ? ' (${event.stepType!.name})'
        : '';
    return '${event.event.name}$typeLabel $stepLabel'.trim();
  }
}

// ---------------------------------------------------------------------------
// SimulationSessionLogRecorder
// ---------------------------------------------------------------------------

/// Simulation variant that skips the persistence call in [finalise].
///
/// Simulation sessions accumulate events identically to [SessionLogRecorder]
/// but the final [SessionLog] is NOT written to the repository (spec 05
/// §Simulation Strategy Pattern — simulation does not write to disk).
///
/// Exposes [finalisedLog] so tests can inspect the assembled log without
/// requiring a database.
class SimulationSessionLogRecorder extends SessionLogRecorder {
  /// Creates a [SimulationSessionLogRecorder].
  SimulationSessionLogRecorder({required super.context, required super.repo});

  /// The [SessionLog] assembled by the last [finalise] call.
  ///
  /// Null before [finalise] has been called.
  SessionLog? finalisedLog;

  @override
  Future<void> finalise(EndReason reason) async {
    // The double-finalise guard in the parent applies here; since we override
    // the whole body we replicate the check using the parent's `finalised` field.
    if (finalised) {
      throw StateError(
        'SimulationSessionLogRecorder.finalise() called twice on session '
        '$sessionId. A recorder must not be reused across sessions.',
      );
    }
    finalised = true;
    final endedAt = DateTime.now().toUtc();
    finalisedLog = SessionLog(
      id: sessionId,
      modeId: sessionContext.mode.id,
      modeName: sessionContext.mode.name,
      startedAt: sessionStartedAt,
      endedAt: endedAt,
      endReason: reason,
      isSimulation: true,
      hadMedicalInfo: _simHadMedicalInfo(),
      events: accumulatedEvents,
    );
    log(
      '[SIM] finalise — log assembled but NOT persisted '
      '(simulation session)',
      name: 'SessionLogRecorder',
    );
  }

  bool _simHadMedicalInfo() {
    if (!sessionContext.profileHasMedicalInfo) return false;
    return sessionContext.mode.chainSteps.any((step) {
      final cfg = step.config;
      if (cfg is SmsContactConfig) {
        return cfg.includeMedicalInfo;
      }
      return false;
    });
  }
}
