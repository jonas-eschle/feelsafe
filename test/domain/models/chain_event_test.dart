/// Unit tests for `ChainEventData` / `ChainEvent` / `ActionDeliveryStatus`.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/models.dart';

void main() {
  group('ChainEvent', () {
    test('enum contains all expected values', () {
      check(ChainEvent.values.map((e) => e.name).toList()).unorderedEquals([
        'sessionStarted',
        'stepStarted',
        'stepAdvancing',
        'graceExpired',
        'repeatMissed',
        'distressTriggered',
        'distressCompleted',
        'sessionPaused',
        'sessionResumed',
        'sessionEnded',
      ]);
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
      check(ActionDeliveryStatus.fromJson('queued')).equals(
        const ActionDeliveryStatus.queued(),
      );
      check(ActionDeliveryStatus.fromJson('sent')).equals(
        const ActionDeliveryStatus.sent(),
      );
      check(ActionDeliveryStatus.fromJson('failed')).equals(
        const ActionDeliveryStatus.failed(),
      );
      check(ActionDeliveryStatus.fromJson('simBlocked')).equals(
        const ActionDeliveryStatus.simBlocked(),
      );
    });

    test('fromJson unknown throws', () {
      check(() => ActionDeliveryStatus.fromJson('bogus'))
          .throws<ArgumentError>();
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
      check(() => ChainEventData.fromJson(const {
            'event': 'bogus',
            'timestamp': '2026-04-01T00:00:00Z',
          })).throws<ArgumentError>();
    });
  });
}
