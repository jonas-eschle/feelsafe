// Tests for SessionLogRecorder (production) and SimulationSessionLogRecorder.

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/session_log_repository.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/engine/chain_event.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/models/session_context.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/user_profile.dart';
import 'package:guardianangela/services/session_log_recorder.dart';
import '../helpers/test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// In-memory database + repository for tests.
GuardianAngelaDatabase _openDb() => GuardianAngelaDatabase.memory();
SessionLogRepository _repo(GuardianAngelaDatabase db) =>
    SessionLogRepository(db.sessionLogsDao);

UserProfile _profileWithMedical() => const UserProfile(bloodType: 'O+');

UserProfile _profileNoMedical() => const UserProfile();

ChainEventData _event(
  ChainEvent event, {
  int? stepIndex,
  ChainStepType? stepType,
  DateTime? timestamp,
}) => ChainEventData(
  event,
  stepIndex: stepIndex,
  stepType: stepType,
  timestamp: timestamp ?? DateTime.now().toUtc(),
);

SessionContext _context({SessionMode? mode, UserProfile? profile}) =>
    SessionContext(mode: mode ?? makeMode(), profile: profile);

// ---------------------------------------------------------------------------
// SessionLogRecorder tests
// ---------------------------------------------------------------------------

void main() {
  group('SessionLogRecorder', () {
    late GuardianAngelaDatabase db;
    late SessionLogRepository repo;

    setUp(() {
      db = _openDb();
      repo = _repo(db);
    });

    tearDown(() => db.close());

    // ---- onEvent accumulation ----

    test('onEvent appends one entry per call', () async {
      final recorder = SessionLogRecorder(context: _context(), repo: repo);
      recorder.onEvent(_event(ChainEvent.sessionStarted));
      recorder.onEvent(_event(ChainEvent.stepStarted, stepIndex: 0));
      check(recorder.accumulatedEvents).length.equals(2);
    });

    test('onEvent maps sessionStarted to "started" eventType', () async {
      final recorder = SessionLogRecorder(context: _context(), repo: repo);
      recorder.onEvent(_event(ChainEvent.sessionStarted));
      check(recorder.accumulatedEvents.first.eventType).equals('started');
    });

    test('onEvent maps stepStarted to "step_fired"', () async {
      final recorder = SessionLogRecorder(context: _context(), repo: repo);
      recorder.onEvent(_event(ChainEvent.stepStarted, stepIndex: 0));
      check(recorder.accumulatedEvents.first.eventType).equals('step_fired');
    });

    test('onEvent maps userDisarmed to "disarmed"', () async {
      final recorder = SessionLogRecorder(context: _context(), repo: repo);
      recorder.onEvent(_event(ChainEvent.userDisarmed));
      check(recorder.accumulatedEvents.first.eventType).equals('disarmed');
    });

    test('onEvent maps stepAdvancing to "escalated"', () async {
      final recorder = SessionLogRecorder(context: _context(), repo: repo);
      recorder.onEvent(_event(ChainEvent.stepAdvancing));
      check(recorder.accumulatedEvents.first.eventType).equals('escalated');
    });

    test('onEvent maps graceExpired to "missed"', () async {
      final recorder = SessionLogRecorder(context: _context(), repo: repo);
      recorder.onEvent(_event(ChainEvent.graceExpired));
      check(recorder.accumulatedEvents.first.eventType).equals('missed');
    });

    test('onEvent maps stepExecutionFailed to "error"', () async {
      final recorder = SessionLogRecorder(context: _context(), repo: repo);
      recorder.onEvent(_event(ChainEvent.stepExecutionFailed));
      check(recorder.accumulatedEvents.first.eventType).equals('error');
    });

    test('onEvent maps sessionEnded to "completed"', () async {
      final recorder = SessionLogRecorder(context: _context(), repo: repo);
      recorder.onEvent(_event(ChainEvent.sessionEnded));
      check(recorder.accumulatedEvents.first.eventType).equals('completed');
    });

    test('onEvent records stepType name when present', () async {
      final recorder = SessionLogRecorder(context: _context(), repo: repo);
      recorder.onEvent(
        _event(ChainEvent.stepStarted, stepType: ChainStepType.smsContact),
      );
      check(
        recorder.accumulatedEvents.first.stepType,
      ).equals(ChainStepType.smsContact.name);
    });

    test('onEvent records null stepType when absent', () async {
      final recorder = SessionLogRecorder(context: _context(), repo: repo);
      recorder.onEvent(_event(ChainEvent.sessionStarted));
      check(recorder.accumulatedEvents.first.stepType).isNull();
    });

    test('onEvent uses event timestamp when provided', () async {
      final ts = DateTime.utc(2026, 5, 1, 12);
      final recorder = SessionLogRecorder(context: _context(), repo: repo);
      recorder.onEvent(_event(ChainEvent.sessionStarted, timestamp: ts));
      check(recorder.accumulatedEvents.first.timestamp).equals(ts);
    });

    test('events are ordered in insertion sequence', () async {
      final recorder = SessionLogRecorder(context: _context(), repo: repo);
      recorder.onEvent(_event(ChainEvent.sessionStarted));
      recorder.onEvent(_event(ChainEvent.stepStarted, stepIndex: 0));
      recorder.onEvent(_event(ChainEvent.userDisarmed));
      final events = recorder.accumulatedEvents;
      check(events[0].eventType).equals('started');
      check(events[1].eventType).equals('step_fired');
      check(events[2].eventType).equals('disarmed');
    });

    // ---- finalise — persistence ----

    test('finalise writes SessionLog to repository', () async {
      final ctx = _context(
        mode: makeMode(id: 'mode-1', name: 'Walk'),
      );
      final recorder = SessionLogRecorder(context: ctx, repo: repo);
      recorder.onEvent(_event(ChainEvent.sessionStarted));
      await recorder.finalise(EndReason.disarm);

      // Check the log was written by fetching directly.
      final all = await db.sessionLogsDao.getAll();
      check(all).length.equals(1);
      check(all.first.modeId).equals('mode-1');
      check(all.first.endReason).equals(EndReason.disarm);
      check(all.first.isSimulation).isFalse();
    });

    test('finalise stamps correct modeName', () async {
      final ctx = _context(mode: makeMode(name: 'Night Walk'));
      final recorder = SessionLogRecorder(context: ctx, repo: repo);
      await recorder.finalise(EndReason.disarm);

      final all = await db.sessionLogsDao.getAll();
      check(all.first.modeName).equals('Night Walk');
    });

    test('finalise persists all accumulated events', () async {
      final recorder = SessionLogRecorder(context: _context(), repo: repo);
      recorder.onEvent(_event(ChainEvent.sessionStarted));
      recorder.onEvent(_event(ChainEvent.stepStarted, stepIndex: 0));
      await recorder.finalise(EndReason.chainExhausted);

      final all = await db.sessionLogsDao.getAll();
      check(all.first.events).length.equals(2);
    });

    // ---- hadMedicalInfo ----

    test('hadMedicalInfo is false when profile has no medical info', () async {
      final mode = makeMode(
        steps: [
          step(
            type: ChainStepType.smsContact,
            config: const SmsContactConfig(includeMedicalInfo: true),
          ),
        ],
      );
      final ctx = _context(mode: mode, profile: _profileNoMedical());
      final recorder = SessionLogRecorder(context: ctx, repo: repo);
      await recorder.finalise(EndReason.disarm);

      final all = await db.sessionLogsDao.getAll();
      check(all.first.hadMedicalInfo).isFalse();
    });

    test(
      'hadMedicalInfo is false when no step has includeMedicalInfo=true',
      () async {
        final mode = makeMode(steps: [step(type: ChainStepType.smsContact)]);
        final ctx = _context(mode: mode, profile: _profileWithMedical());
        final recorder = SessionLogRecorder(context: ctx, repo: repo);
        await recorder.finalise(EndReason.disarm);

        final all = await db.sessionLogsDao.getAll();
        check(all.first.hadMedicalInfo).isFalse();
      },
    );

    test('hadMedicalInfo is true when profile has medical info AND step has '
        'includeMedicalInfo=true', () async {
      final mode = makeMode(
        steps: [
          step(
            type: ChainStepType.smsContact,
            config: const SmsContactConfig(includeMedicalInfo: true),
          ),
        ],
      );
      final ctx = _context(mode: mode, profile: _profileWithMedical());
      final recorder = SessionLogRecorder(context: ctx, repo: repo);
      await recorder.finalise(EndReason.disarm);

      final all = await db.sessionLogsDao.getAll();
      check(all.first.hadMedicalInfo).isTrue();
    });

    test('hadMedicalInfo is false when profile is null', () async {
      final mode = makeMode(
        steps: [
          step(
            type: ChainStepType.smsContact,
            config: const SmsContactConfig(includeMedicalInfo: true),
          ),
        ],
      );
      final ctx = SessionContext(mode: mode, profile: null);
      final recorder = SessionLogRecorder(context: ctx, repo: repo);
      await recorder.finalise(EndReason.disarm);

      final all = await db.sessionLogsDao.getAll();
      check(all.first.hadMedicalInfo).isFalse();
    });
  });

  // -------------------------------------------------------------------------
  // SimulationSessionLogRecorder tests
  // -------------------------------------------------------------------------

  group('SimulationSessionLogRecorder', () {
    late GuardianAngelaDatabase db;
    late SessionLogRepository repo;

    setUp(() {
      db = _openDb();
      repo = _repo(db);
    });

    tearDown(() => db.close());

    test('onEvent accumulates events (same as real recorder)', () {
      final recorder = SimulationSessionLogRecorder(
        context: _context(),
        repo: repo,
      );
      recorder.onEvent(_event(ChainEvent.sessionStarted));
      recorder.onEvent(_event(ChainEvent.stepStarted, stepIndex: 0));
      check(recorder.accumulatedEvents).length.equals(2);
    });

    test('finalise does NOT write to repository', () async {
      final recorder = SimulationSessionLogRecorder(
        context: _context(),
        repo: repo,
      );
      recorder.onEvent(_event(ChainEvent.sessionStarted));
      await recorder.finalise(EndReason.disarm);

      final all = await db.sessionLogsDao.getAll();
      check(all).isEmpty();
    });

    test('finalise sets finalisedLog with isSimulation=true', () async {
      final recorder = SimulationSessionLogRecorder(
        context: _context(),
        repo: repo,
      );
      await recorder.finalise(EndReason.disarm);
      check(recorder.finalisedLog).isNotNull();
      check(recorder.finalisedLog!.isSimulation).isTrue();
    });

    test('finalisedLog contains accumulated events', () async {
      final recorder = SimulationSessionLogRecorder(
        context: _context(),
        repo: repo,
      );
      recorder.onEvent(_event(ChainEvent.sessionStarted));
      await recorder.finalise(EndReason.disarm);
      check(recorder.finalisedLog!.events).length.equals(1);
    });

    test('finalisedLog has correct endReason', () async {
      final recorder = SimulationSessionLogRecorder(
        context: _context(),
        repo: repo,
      );
      await recorder.finalise(EndReason.chainExhausted);
      check(recorder.finalisedLog!.endReason).equals(EndReason.chainExhausted);
    });

    test('finalisedLog.hadMedicalInfo true when conditions met', () async {
      final mode = makeMode(
        steps: [
          step(
            type: ChainStepType.smsContact,
            config: const SmsContactConfig(includeMedicalInfo: true),
          ),
        ],
      );
      final ctx = _context(mode: mode, profile: _profileWithMedical());
      final recorder = SimulationSessionLogRecorder(context: ctx, repo: repo);
      await recorder.finalise(EndReason.disarm);
      check(recorder.finalisedLog!.hadMedicalInfo).isTrue();
    });

    test('finalisedLog is null before finalise', () {
      final recorder = SimulationSessionLogRecorder(
        context: _context(),
        repo: repo,
      );
      check(recorder.finalisedLog).isNull();
    });
  });
}
