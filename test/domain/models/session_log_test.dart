/// Unit tests for `SessionLog` + `SessionLogEvent` — events, endedAt
/// null, round-trip.
library;

import 'package:checks/checks.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:test/test.dart';

void main() {
  group('SessionLogEvent', () {
    test('minimal round-trip', () {
      final e = SessionLogEvent(
        timestamp: DateTime.utc(2026, 4, 1, 12),
        event: ChainEvent.sessionStarted,
      );
      check(SessionLogEvent.fromJson(e.toJson())).equals(e);
    });

    test('round-trip with all fields', () {
      final e = SessionLogEvent(
        timestamp: DateTime.utc(2026, 4, 1, 12),
        event: ChainEvent.stepStarted,
        stepIndex: 2,
        stepType: ChainStepType.smsContact,
        deliveryStatus: const ActionDeliveryStatus.sent(),
        message: 'sms sent to Alice',
      );
      check(SessionLogEvent.fromJson(e.toJson())).equals(e);
    });

    test('copyWith', () {
      final e = SessionLogEvent(
        timestamp: DateTime.utc(2026, 4, 1),
        event: ChainEvent.stepStarted,
      );
      check(e.copyWith(stepIndex: 5).stepIndex).equals(5);
    });

    test('fromJson unknown event throws', () {
      check(() => SessionLogEvent.fromJson(const {
            'timestamp': '2026-04-01T12:00:00Z',
            'event': 'bogus',
          })).throws<ArgumentError>();
    });
  });

  group('SessionLog', () {
    test('endedAt null by default', () {
      final log = SessionLog(
        id: 'log1',
        modeId: 'm1',
        modeName: 'Walk',
        startedAt: DateTime.utc(2026, 4, 1),
        isSimulation: false,
      );
      check(log.endedAt).isNull();
      check(log.endReason).isNull();
      check(log.events).isEmpty();
    });

    test('round-trip running log', () {
      final log = SessionLog(
        id: 'log1',
        modeId: 'm1',
        modeName: 'Walk',
        startedAt: DateTime.utc(2026, 4, 1),
        isSimulation: false,
      );
      check(SessionLog.fromJson(log.toJson())).equals(log);
    });

    test('round-trip finished log with reason', () {
      final log = SessionLog(
        id: 'log1',
        modeId: 'm1',
        modeName: 'Walk',
        startedAt: DateTime.utc(2026, 4, 1),
        endedAt: DateTime.utc(2026, 4, 1, 1),
        endReason: EndReason.disarm,
        isSimulation: false,
      );
      check(SessionLog.fromJson(log.toJson())).equals(log);
    });

    test('round-trip with events list', () {
      final log = SessionLog(
        id: 'log1',
        modeId: 'm1',
        modeName: 'Walk',
        startedAt: DateTime.utc(2026, 4, 1),
        isSimulation: true,
        events: [
          SessionLogEvent(
            timestamp: DateTime.utc(2026, 4, 1, 0, 0, 1),
            event: ChainEvent.sessionStarted,
          ),
          SessionLogEvent(
            timestamp: DateTime.utc(2026, 4, 1, 0, 0, 2),
            event: ChainEvent.stepStarted,
            stepIndex: 0,
            stepType: ChainStepType.holdButton,
          ),
          SessionLogEvent(
            timestamp: DateTime.utc(2026, 4, 1, 0, 1),
            event: ChainEvent.sessionEnded,
          ),
        ],
      );
      check(SessionLog.fromJson(log.toJson())).equals(log);
    });

    test('copyWith replaces field', () {
      final log = SessionLog(
        id: 'log1',
        modeId: 'm1',
        modeName: 'Walk',
        startedAt: DateTime.utc(2026, 4, 1),
        isSimulation: false,
      );
      final log2 = log.copyWith(modeName: 'Date');
      check(log2.modeName).equals('Date');
      check(log2.id).equals(log.id);
    });

    test('fromJson unknown endReason throws', () {
      check(() => SessionLog.fromJson(const {
            'id': 'x',
            'modeId': 'm',
            'modeName': 'n',
            'startedAt': '2026-04-01T00:00:00Z',
            'endReason': 'bogus',
            'isSimulation': false,
          })).throws<ArgumentError>();
    });

    test('isSimulation round-trip', () {
      final log = SessionLog(
        id: 'x',
        modeId: 'm',
        modeName: 'n',
        startedAt: DateTime.utc(2026),
        isSimulation: true,
      );
      check(SessionLog.fromJson(log.toJson()).isSimulation).isTrue();
    });

    test('every EndReason round-trips', () {
      for (final reason in EndReason.values) {
        final log = SessionLog(
          id: 'x',
          modeId: 'm',
          modeName: 'n',
          startedAt: DateTime.utc(2026),
          endedAt: DateTime.utc(2026, 1, 2),
          endReason: reason,
          isSimulation: false,
        );
        check(SessionLog.fromJson(log.toJson()).endReason).equals(reason);
      }
    });
  });
}
