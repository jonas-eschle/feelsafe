/// Tests for [SessionLogRecorder].
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_log_recorder.dart';
import 'package:guardianangela/domain/models/chain_event.dart';
import 'package:guardianangela/domain/models/session_log.dart';

SessionLog _emptyLog({
  bool isSimulation = false,
}) => SessionLog(
  id: 'log-1',
  modeId: 'mode-1',
  modeName: 'Walk Mode',
  startedAt: DateTime.utc(2026, 4, 1),
  isSimulation: isSimulation,
);

ChainEventData _ev(
  ChainEvent event, {
  DateTime? ts,
  int? stepIndex,
  ChainStepType? stepType,
  Map<String, Object?>? metadata,
}) => ChainEventData(
  event: event,
  timestamp: ts ?? DateTime.utc(2026, 4, 1),
  stepIndex: stepIndex,
  stepType: stepType,
  metadata: metadata ?? const {},
);

void main() {
  group('recordEvent', () {
    test('empty log has no events', () {
      final r = SessionLogRecorder(log: _emptyLog());
      check(r.log.events).isEmpty();
    });

    test('recordEvent appends a SessionLogEvent', () {
      final r = SessionLogRecorder(log: _emptyLog());
      r.recordEvent(_ev(ChainEvent.stepStarted, stepIndex: 0,
          stepType: ChainStepType.holdButton));
      check(r.log.events.length).equals(1);
      check(r.log.events.first.event).equals(ChainEvent.stepStarted);
      check(r.log.events.first.stepIndex).equals(0);
      check(r.log.events.first.stepType).equals(ChainStepType.holdButton);
    });

    test('multiple recordEvent calls append in order', () {
      final r = SessionLogRecorder(log: _emptyLog());
      r.recordEvent(_ev(ChainEvent.sessionStarted));
      r.recordEvent(_ev(ChainEvent.stepStarted, stepIndex: 0));
      r.recordEvent(
        _ev(ChainEvent.graceExpired, stepIndex: 0, metadata: {'missCount': 1}),
      );
      check(r.log.events.length).equals(3);
      check(r.log.events[0].event).equals(ChainEvent.sessionStarted);
      check(r.log.events[1].event).equals(ChainEvent.stepStarted);
      check(r.log.events[2].event).equals(ChainEvent.graceExpired);
    });

    test('recordEvent preserves timestamp', () {
      final r = SessionLogRecorder(log: _emptyLog());
      final t = DateTime.utc(2026, 4, 15, 10, 30);
      r.recordEvent(_ev(ChainEvent.stepStarted, ts: t));
      check(r.log.events.first.timestamp).equals(t);
    });

    test('sessionEnded sets endedAt + endReason from metadata', () {
      final r = SessionLogRecorder(log: _emptyLog());
      final t = DateTime.utc(2026, 4, 1, 12);
      r.recordEvent(
        _ev(ChainEvent.sessionEnded, ts: t, metadata: {'reason': 'disarm'}),
      );
      check(r.log.endedAt).equals(t);
      check(r.log.endReason).equals(EndReason.disarm);
    });

    test('sessionEnded without reason metadata leaves endReason null', () {
      final r = SessionLogRecorder(log: _emptyLog());
      r.recordEvent(_ev(ChainEvent.sessionEnded));
      check(r.log.endReason).isNull();
      check(r.log.endedAt).isNotNull();
    });

    test('metadata reason strings each produce matching EndReason', () {
      for (final (raw, expected) in const [
        ('disarm', EndReason.disarm),
        ('chainExhausted', EndReason.chainExhausted),
        ('hardwarePanic', EndReason.hardwarePanic),
        ('duressPin', EndReason.duressPin),
        ('wrongPinExhausted', EndReason.wrongPinExhausted),
        ('userQuit', EndReason.userQuit),
        ('appTermination', EndReason.appTermination),
      ]) {
        final r = SessionLogRecorder(log: _emptyLog());
        r.recordEvent(
          _ev(ChainEvent.sessionEnded, metadata: {'reason': raw}),
        );
        check(r.log.endReason).equals(expected);
      }
    });

    test('unknown reason string leaves endReason null', () {
      final r = SessionLogRecorder(log: _emptyLog());
      r.recordEvent(
        _ev(ChainEvent.sessionEnded, metadata: {'reason': 'unknown'}),
      );
      check(r.log.endReason).isNull();
    });

    test('missCount metadata recorded as message', () {
      final r = SessionLogRecorder(log: _emptyLog());
      r.recordEvent(
        _ev(
          ChainEvent.graceExpired,
          stepIndex: 0,
          metadata: {'missCount': 2},
        ),
      );
      check(r.log.events.first.message).equals('missCount=2');
    });

    test('log is immutable between calls', () {
      final r = SessionLogRecorder(log: _emptyLog());
      r.recordEvent(_ev(ChainEvent.stepStarted));
      final snapshot = r.log;
      r.recordEvent(_ev(ChainEvent.stepAdvancing));
      check(snapshot.events.length).equals(1);
      check(r.log.events.length).equals(2);
    });
  });

  group('updateDeliveryStatus', () {
    test('sets deliveryStatus on targeted event', () {
      final r = SessionLogRecorder(log: _emptyLog());
      r.recordEvent(_ev(ChainEvent.stepStarted, stepIndex: 0));
      r.updateDeliveryStatus(
        eventIndex: 0,
        status: const ActionDeliveryStatus.sent(),
      );
      check(r.log.events.first.deliveryStatus).equals(
        const ActionDeliveryStatus.sent(),
      );
    });

    test('updating does not duplicate events', () {
      final r = SessionLogRecorder(log: _emptyLog());
      r.recordEvent(_ev(ChainEvent.stepStarted));
      r.updateDeliveryStatus(
        eventIndex: 0,
        status: const ActionDeliveryStatus.queued(),
      );
      check(r.log.events.length).equals(1);
    });

    test('supports all four delivery statuses', () {
      for (final status in const [
        ActionDeliveryStatus.queued(),
        ActionDeliveryStatus.sent(),
        ActionDeliveryStatus.failed(),
        ActionDeliveryStatus.simBlocked(),
      ]) {
        final r = SessionLogRecorder(log: _emptyLog());
        r.recordEvent(_ev(ChainEvent.stepStarted));
        r.updateDeliveryStatus(eventIndex: 0, status: status);
        check(r.log.events.first.deliveryStatus).equals(status);
      }
    });

    test('throws RangeError on negative index', () {
      final r = SessionLogRecorder(log: _emptyLog());
      r.recordEvent(_ev(ChainEvent.stepStarted));
      check(
        () => r.updateDeliveryStatus(
          eventIndex: -1,
          status: const ActionDeliveryStatus.sent(),
        ),
      ).throws<RangeError>();
    });

    test('throws RangeError on out-of-bounds index', () {
      final r = SessionLogRecorder(log: _emptyLog());
      r.recordEvent(_ev(ChainEvent.stepStarted));
      check(
        () => r.updateDeliveryStatus(
          eventIndex: 5,
          status: const ActionDeliveryStatus.sent(),
        ),
      ).throws<RangeError>();
    });

    test('updating preserves other events untouched', () {
      final r = SessionLogRecorder(log: _emptyLog());
      r.recordEvent(_ev(ChainEvent.stepStarted, stepIndex: 0));
      r.recordEvent(_ev(ChainEvent.stepAdvancing, stepIndex: 0));
      r.updateDeliveryStatus(
        eventIndex: 0,
        status: const ActionDeliveryStatus.sent(),
      );
      check(r.log.events[1].deliveryStatus).isNull();
      check(r.log.events[1].event).equals(ChainEvent.stepAdvancing);
    });
  });

  group('log constructor', () {
    test('recorder preserves provided log id / modeId / modeName', () {
      final log = SessionLog(
        id: 'unique-log-id',
        modeId: 'walk-1',
        modeName: 'Walk Mode',
        startedAt: DateTime.utc(2026, 1, 1),
        isSimulation: true,
      );
      final r = SessionLogRecorder(log: log);
      check(r.log.id).equals('unique-log-id');
      check(r.log.modeId).equals('walk-1');
      check(r.log.modeName).equals('Walk Mode');
      check(r.log.isSimulation).isTrue();
    });
  });
}
