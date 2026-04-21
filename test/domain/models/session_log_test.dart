/// Unit tests for `SessionLog` + `SessionLogEvent` — events, endedAt
/// null, round-trip.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/models/models.dart';

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
      check(
        () => SessionLogEvent.fromJson(const {
          'timestamp': '2026-04-01T12:00:00Z',
          'event': 'bogus',
        }),
      ).throws<ArgumentError>();
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
      check(
        () => SessionLog.fromJson(const {
          'id': 'x',
          'modeId': 'm',
          'modeName': 'n',
          'startedAt': '2026-04-01T00:00:00Z',
          'endReason': 'bogus',
          'isSimulation': false,
        }),
      ).throws<ArgumentError>();
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

  group('SessionLog append-via-copyWith flow', () {
    test('append events through copyWith', () {
      final start = DateTime.utc(2026, 4, 1);
      var log = SessionLog(
        id: 'log1',
        modeId: 'm1',
        modeName: 'Walk',
        startedAt: start,
        isSimulation: false,
      );
      check(log.events).isEmpty();
      check(log.endedAt).isNull();

      // Append started.
      log = log.copyWith(
        events: [
          ...log.events,
          SessionLogEvent(
            timestamp: start,
            event: ChainEvent.sessionStarted,
          ),
        ],
      );
      check(log.events.length).equals(1);
      check(log.events[0].event).equals(ChainEvent.sessionStarted);

      // Append stepStarted.
      log = log.copyWith(
        events: [
          ...log.events,
          SessionLogEvent(
            timestamp: start.add(const Duration(seconds: 1)),
            event: ChainEvent.stepStarted,
            stepIndex: 0,
            stepType: ChainStepType.holdButton,
          ),
        ],
      );
      check(log.events.length).equals(2);

      // Update delivery status of index 1 via per-event copyWith.
      final prev = log.events[1];
      final updated = prev.copyWith(
        deliveryStatus: const ActionDeliveryStatus.sent(),
      );
      final newEvents = [...log.events]..[1] = updated;
      log = log.copyWith(events: newEvents);
      check(log.events[1].deliveryStatus)
          .equals(const ActionDeliveryStatus.sent());

      // Finish: endedAt null -> set via sessionEnded flow.
      final endTs = start.add(const Duration(minutes: 5));
      log = log.copyWith(
        endedAt: endTs,
        endReason: EndReason.disarm,
        events: [
          ...log.events,
          SessionLogEvent(
            timestamp: endTs,
            event: ChainEvent.sessionEnded,
          ),
        ],
      );
      check(log.endedAt).equals(endTs);
      check(log.endReason).equals(EndReason.disarm);
      check(log.events.last.event).equals(ChainEvent.sessionEnded);
    });
  });

  group('SessionLog equality / hashCode / toString', () {
    SessionLog base() => SessionLog(
          id: 'log1',
          modeId: 'm1',
          modeName: 'Walk',
          startedAt: DateTime.utc(2026, 4, 1),
          isSimulation: false,
        );

    test('identical equals', () {
      final a = base();
      check(a == a).isTrue();
    });

    test('cross type unequal', () {
      // ignore: unrelated_type_equality_checks
      check(base() == 'x').isFalse();
    });

    test('equal values equal', () {
      check(base()).equals(base());
      check(base().hashCode).equals(base().hashCode);
    });

    test('different id unequal', () {
      check(base() == base().copyWith(id: 'other')).isFalse();
    });

    test('different modeId unequal', () {
      check(base() == base().copyWith(modeId: 'other')).isFalse();
    });

    test('different modeName unequal', () {
      check(base() == base().copyWith(modeName: 'Other')).isFalse();
    });

    test('different startedAt unequal', () {
      check(
        base() == base().copyWith(startedAt: DateTime.utc(2027)),
      ).isFalse();
    });

    test('different endedAt unequal', () {
      check(
        base() == base().copyWith(endedAt: DateTime.utc(2027)),
      ).isFalse();
    });

    test('different endReason unequal', () {
      check(
        base() == base().copyWith(endReason: EndReason.userQuit),
      ).isFalse();
    });

    test('different isSimulation unequal', () {
      check(base() == base().copyWith(isSimulation: true)).isFalse();
    });

    test('different events length unequal', () {
      final ev = SessionLogEvent(
        timestamp: DateTime.utc(2026, 4, 1),
        event: ChainEvent.sessionStarted,
      );
      check(base() == base().copyWith(events: [ev])).isFalse();
    });

    test('different events at index unequal', () {
      final a = SessionLogEvent(
        timestamp: DateTime.utc(2026, 4, 1),
        event: ChainEvent.sessionStarted,
      );
      final b = SessionLogEvent(
        timestamp: DateTime.utc(2026, 4, 1),
        event: ChainEvent.stepStarted,
      );
      final la = base().copyWith(events: [a]);
      final lb = base().copyWith(events: [b]);
      check(la == lb).isFalse();
    });

    test('toString exposes id / modeId / events count', () {
      final str = base().toString();
      check(str).contains('log1');
      check(str).contains('m1');
      check(str).contains('0');
    });
  });

  group('SessionLogEvent equality / hashCode / toString', () {
    final ts = DateTime.utc(2026, 4, 1, 12);

    SessionLogEvent base() => SessionLogEvent(
          timestamp: ts,
          event: ChainEvent.stepStarted,
        );

    test('identical equals', () {
      final e = base();
      check(e == e).isTrue();
    });

    test('cross type unequal', () {
      // ignore: unrelated_type_equality_checks
      check(base() == 'x').isFalse();
    });

    test('equal values equal', () {
      check(base()).equals(base());
      check(base().hashCode).equals(base().hashCode);
    });

    test('differ by timestamp', () {
      final b = SessionLogEvent(
        timestamp: ts.add(const Duration(seconds: 1)),
        event: ChainEvent.stepStarted,
      );
      check(base() == b).isFalse();
    });

    test('differ by event', () {
      final b = SessionLogEvent(
        timestamp: ts,
        event: ChainEvent.stepAdvancing,
      );
      check(base() == b).isFalse();
    });

    test('differ by stepIndex', () {
      final a = base().copyWith(stepIndex: 1);
      final b = base().copyWith(stepIndex: 2);
      check(a == b).isFalse();
    });

    test('differ by stepType', () {
      final a = base().copyWith(stepType: ChainStepType.holdButton);
      final b = base().copyWith(stepType: ChainStepType.smsContact);
      check(a == b).isFalse();
    });

    test('differ by deliveryStatus', () {
      final a = base().copyWith(
        deliveryStatus: const ActionDeliveryStatus.sent(),
      );
      final b = base().copyWith(
        deliveryStatus: const ActionDeliveryStatus.failed(),
      );
      check(a == b).isFalse();
    });

    test('differ by message', () {
      final a = base().copyWith(message: 'a');
      final b = base().copyWith(message: 'b');
      check(a == b).isFalse();
    });

    test('toString exposes event + stepIndex + stepType', () {
      final e = base().copyWith(
        stepIndex: 3,
        stepType: ChainStepType.fakeCall,
      );
      final str = e.toString();
      check(str).contains('stepStarted');
      check(str).contains('3');
      check(str).contains('fakeCall');
    });

    test('fromJson unknown stepType throws', () {
      check(
        () => SessionLogEvent.fromJson(const {
          'timestamp': '2026-04-01T12:00:00Z',
          'event': 'stepStarted',
          'stepType': 'bogus',
        }),
      ).throws<ArgumentError>();
    });

    test('every ActionDeliveryStatus round-trips', () {
      const statuses = <ActionDeliveryStatus>[
        ActionDeliveryStatus.queued(),
        ActionDeliveryStatus.sent(),
        ActionDeliveryStatus.failed(),
        ActionDeliveryStatus.simBlocked(),
      ];
      for (final s in statuses) {
        final e = base().copyWith(deliveryStatus: s);
        check(SessionLogEvent.fromJson(e.toJson()).deliveryStatus).equals(s);
      }
    });
  });
}
