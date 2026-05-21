/// Unit tests for `ChainEventData` / `ChainEvent` / `ActionDeliveryStatus`.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/models.dart';

void main() {
  group('ChainEvent', () {
    test('enum contains all expected values', () {
      // Spec 01 §Events Emitted plus userDisarmed introduced by the
      // disarm-as-rearm change (spec 01 §Disarm/Check-in).
      check(ChainEvent.values.map((e) => e.name).toList()).unorderedEquals([
        'sessionStarted',
        'stepStarted',
        'stepAdvancing',
        'graceExpired',
        'repeatMissed',
        'reminderFired',
        'pauseExpired',
        'stepExecutionFailed',
        'distressTriggered',
        'distressCompleted',
        'sessionPaused',
        'sessionResumed',
        'userDisarmed',
        'sessionEnded',
      ]);
    });

    test('spec 01 §Events Emitted values are present', () {
      // Spec-driven set: all 3 newly-introduced events must be
      // round-trippable.
      for (final name in [
        'reminderFired',
        'pauseExpired',
        'stepExecutionFailed',
      ]) {
        check(ChainEvent.values.map((e) => e.name).toList()).contains(name);
      }
    });
  });

  group('ActionDeliveryStatus', () {
    test('queued tag', () {
      const s = ActionDeliveryStatus.queued();
      check(s.tag).equals('queued');
      check(s.toJson()).equals('queued');
    });

    test('sent tag', () {
      const s = ActionDeliveryStatus.sent();
      check(s.tag).equals('sent');
    });

    test('failed tag', () {
      const s = ActionDeliveryStatus.failed();
      check(s.tag).equals('failed');
    });

    test('simBlocked tag', () {
      const s = ActionDeliveryStatus.simBlocked();
      check(s.tag).equals('simBlocked');
    });

    test('fromJson dispatches', () {
      check(
        ActionDeliveryStatus.fromJson('queued'),
      ).equals(const ActionDeliveryStatus.queued());
      check(
        ActionDeliveryStatus.fromJson('sent'),
      ).equals(const ActionDeliveryStatus.sent());
      check(
        ActionDeliveryStatus.fromJson('failed'),
      ).equals(const ActionDeliveryStatus.failed());
      check(
        ActionDeliveryStatus.fromJson('simBlocked'),
      ).equals(const ActionDeliveryStatus.simBlocked());
    });

    test('fromJson unknown throws', () {
      check(
        () => ActionDeliveryStatus.fromJson('bogus'),
      ).throws<ArgumentError>();
    });
  });

  group('ChainEventData', () {
    final ts = DateTime.utc(2026, 4, 1);

    test('minimal round-trip', () {
      final e = ChainEventData(event: ChainEvent.stepStarted, timestamp: ts);
      check(ChainEventData.fromJson(e.toJson())).equals(e);
    });

    test('round-trip with stepIndex + stepType', () {
      final e = ChainEventData(
        event: ChainEvent.stepStarted,
        timestamp: ts,
        stepIndex: 2,
        stepType: ChainStepType.holdButton,
      );
      check(ChainEventData.fromJson(e.toJson())).equals(e);
    });

    test('round-trip with metadata', () {
      final e = ChainEventData(
        event: ChainEvent.distressTriggered,
        timestamp: ts,
        metadata: const {'source': 'hardware', 'count': 5},
      );
      check(ChainEventData.fromJson(e.toJson())).equals(e);
    });

    test('copyWith', () {
      final e = ChainEventData(event: ChainEvent.stepStarted, timestamp: ts);
      check(e.copyWith(stepIndex: 3).stepIndex).equals(3);
    });

    test('fromJson unknown event throws', () {
      check(
        () => ChainEventData.fromJson(const {
          'event': 'bogus',
          'timestamp': '2026-04-01T00:00:00Z',
        }),
      ).throws<ArgumentError>();
    });

    test('fromJson unknown stepType throws', () {
      check(
        () => ChainEventData.fromJson(const {
          'event': 'stepStarted',
          'timestamp': '2026-04-01T00:00:00Z',
          'stepType': 'bogus',
        }),
      ).throws<ArgumentError>();
    });

    test('every ChainEvent round-trips', () {
      for (final e in ChainEvent.values) {
        final ed = ChainEventData(event: e, timestamp: ts);
        check(ChainEventData.fromJson(ed.toJson())).equals(ed);
      }
    });

    test('every ChainStepType round-trips', () {
      for (final st in ChainStepType.values) {
        final ed = ChainEventData(
          event: ChainEvent.stepStarted,
          timestamp: ts,
          stepType: st,
        );
        check(ChainEventData.fromJson(ed.toJson())).equals(ed);
      }
    });

    test('equality identical instance', () {
      final e = ChainEventData(event: ChainEvent.stepStarted, timestamp: ts);
      check(e == e).isTrue();
    });

    test('equality different type unequal', () {
      final e = ChainEventData(event: ChainEvent.stepStarted, timestamp: ts);
      // ignore: unrelated_type_equality_checks
      check(e == 'not-an-event').isFalse();
    });

    test('equality - differ by event', () {
      final a = ChainEventData(event: ChainEvent.stepStarted, timestamp: ts);
      final b = ChainEventData(event: ChainEvent.stepAdvancing, timestamp: ts);
      check(a == b).isFalse();
    });

    test('equality - differ by timestamp', () {
      final a = ChainEventData(event: ChainEvent.stepStarted, timestamp: ts);
      final b = ChainEventData(
        event: ChainEvent.stepStarted,
        timestamp: ts.add(const Duration(seconds: 1)),
      );
      check(a == b).isFalse();
    });

    test('equality - differ by stepIndex', () {
      final a = ChainEventData(
        event: ChainEvent.stepStarted,
        timestamp: ts,
        stepIndex: 1,
      );
      final b = ChainEventData(
        event: ChainEvent.stepStarted,
        timestamp: ts,
        stepIndex: 2,
      );
      check(a == b).isFalse();
    });

    test('equality - differ by stepType', () {
      final a = ChainEventData(
        event: ChainEvent.stepStarted,
        timestamp: ts,
        stepType: ChainStepType.holdButton,
      );
      final b = ChainEventData(
        event: ChainEvent.stepStarted,
        timestamp: ts,
        stepType: ChainStepType.smsContact,
      );
      check(a == b).isFalse();
    });

    test('equality - differ by metadata length', () {
      final a = ChainEventData(event: ChainEvent.stepStarted, timestamp: ts);
      final b = ChainEventData(
        event: ChainEvent.stepStarted,
        timestamp: ts,
        metadata: const {'k': 'v'},
      );
      check(a == b).isFalse();
    });

    test('equality - differ by metadata value', () {
      final a = ChainEventData(
        event: ChainEvent.stepStarted,
        timestamp: ts,
        metadata: const {'k': 'a'},
      );
      final b = ChainEventData(
        event: ChainEvent.stepStarted,
        timestamp: ts,
        metadata: const {'k': 'b'},
      );
      check(a == b).isFalse();
    });

    test('hashCode stable for equal values', () {
      final a = ChainEventData(
        event: ChainEvent.stepStarted,
        timestamp: ts,
        metadata: const {'x': 1},
      );
      final b = ChainEventData(
        event: ChainEvent.stepStarted,
        timestamp: ts,
        metadata: const {'x': 1},
      );
      check(a.hashCode).equals(b.hashCode);
    });

    test('toString includes event + stepType', () {
      final e = ChainEventData(
        event: ChainEvent.stepStarted,
        timestamp: ts,
        stepIndex: 3,
        stepType: ChainStepType.holdButton,
      );
      final str = e.toString();
      check(str).contains('stepStarted');
      check(str).contains('holdButton');
      check(str).contains('3');
    });
  });

  group('ActionDeliveryStatus equality / hashCode / toString', () {
    test('queued equals queued', () {
      check(
        const ActionDeliveryStatus.queued(),
      ).equals(const ActionDeliveryStatus.queued());
      check(
        const ActionDeliveryStatus.queued().hashCode,
      ).equals(const ActionDeliveryStatus.queued().hashCode);
    });

    test('sent equals sent', () {
      check(
        const ActionDeliveryStatus.sent(),
      ).equals(const ActionDeliveryStatus.sent());
      check(
        const ActionDeliveryStatus.sent().hashCode,
      ).equals(const ActionDeliveryStatus.sent().hashCode);
    });

    test('failed equals failed', () {
      check(
        const ActionDeliveryStatus.failed(),
      ).equals(const ActionDeliveryStatus.failed());
      check(
        const ActionDeliveryStatus.failed().hashCode,
      ).equals(const ActionDeliveryStatus.failed().hashCode);
    });

    test('simBlocked equals simBlocked', () {
      check(
        const ActionDeliveryStatus.simBlocked(),
      ).equals(const ActionDeliveryStatus.simBlocked());
      check(
        const ActionDeliveryStatus.simBlocked().hashCode,
      ).equals(const ActionDeliveryStatus.simBlocked().hashCode);
    });

    test('queued != sent', () {
      check(
        const ActionDeliveryStatus.queued() ==
            const ActionDeliveryStatus.sent(),
      ).isFalse();
    });

    test('toString for every status', () {
      check(
        const ActionDeliveryStatus.queued().toString(),
      ).equals('ActionDeliveryStatus.queued');
      check(
        const ActionDeliveryStatus.sent().toString(),
      ).equals('ActionDeliveryStatus.sent');
      check(
        const ActionDeliveryStatus.failed().toString(),
      ).equals('ActionDeliveryStatus.failed');
      check(
        const ActionDeliveryStatus.simBlocked().toString(),
      ).equals('ActionDeliveryStatus.simBlocked');
    });

    test('cross-type != literal', () {
      // ignore: unrelated_type_equality_checks
      check(const ActionDeliveryStatus.queued() == 'queued').isFalse();
    });
  });

  group('ChainEventData.copyWith all fields', () {
    final ts = DateTime.utc(2026, 4, 1);

    test('replaces event', () {
      final e = ChainEventData(event: ChainEvent.stepStarted, timestamp: ts);
      check(
        e.copyWith(event: ChainEvent.graceExpired).event,
      ).equals(ChainEvent.graceExpired);
    });

    test('replaces timestamp', () {
      final e = ChainEventData(event: ChainEvent.stepStarted, timestamp: ts);
      final ts2 = ts.add(const Duration(hours: 1));
      check(e.copyWith(timestamp: ts2).timestamp).equals(ts2);
    });

    test('replaces stepType', () {
      final e = ChainEventData(event: ChainEvent.stepStarted, timestamp: ts);
      check(
        e.copyWith(stepType: ChainStepType.loudAlarm).stepType,
      ).equals(ChainStepType.loudAlarm);
    });

    test('replaces metadata', () {
      final e = ChainEventData(event: ChainEvent.stepStarted, timestamp: ts);
      final e2 = e.copyWith(metadata: const {'a': 1});
      check(e2.metadata).deepEquals({'a': 1});
    });
  });
}
