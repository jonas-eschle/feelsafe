import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/models/session_log_event.dart';

SessionLogEvent _event({
  DateTime? timestamp,
  String eventType = 'unset_default',
  String? stepType = 'fakeCall',
  int stepIndex = 1,
  String description = 'Fake call from Angela',
  double? latitude,
  double? longitude,
  String? deliveryStatus,
}) => SessionLogEvent(
  timestamp: timestamp ?? DateTime.utc(2026, 5, 21, 10),
  eventType: eventType,
  stepType: stepType,
  stepIndex: stepIndex,
  description: description,
  latitude: latitude,
  longitude: longitude,
  deliveryStatus: deliveryStatus,
);

void main() {
  group('SessionLogEvent', () {
    group('construction', () {
      test('all required fields are populated', () {
        // Given: a step-fired event.
        // When: constructed with all required fields.
        // Then: each field round-trips.
        final ev = _event(eventType: 'step_fired');
        check(ev.timestamp).equals(DateTime.utc(2026, 5, 21, 10));
        check(ev.eventType).equals('step_fired');
        check(ev.stepType).equals('fakeCall');
        check(ev.stepIndex).equals(1);
        check(ev.description).equals('Fake call from Angela');
      });

      test('optional fields default to null when omitted', () {
        // Given: an event without GPS or delivery info.
        // When: constructed with only required fields.
        // Then: latitude, longitude, deliveryStatus, stepType are null.
        final ev = SessionLogEvent(
          timestamp: DateTime.utc(2026, 5, 21),
          eventType: 'started',
          stepIndex: 0,
          description: 'Session start',
        );
        check(ev.latitude).isNull();
        check(ev.longitude).isNull();
        check(ev.deliveryStatus).isNull();
        check(ev.stepType).isNull();
      });

      test('stepType nullable for non-step events (e.g., "started")', () {
        // Given: a top-level lifecycle event.
        // When: stepType omitted.
        // Then: the field is null and round-trips through JSON.
        final ev = SessionLogEvent(
          timestamp: DateTime.utc(2026, 5, 21),
          eventType: 'started',
          stepIndex: 0,
          description: 'Session initialised',
        );
        final restored = SessionLogEvent.fromJson(ev.toJson());
        check(restored.stepType).isNull();
      });
    });

    group('JSON round-trip — timestamp', () {
      test('UTC timestamp survives round-trip exactly', () {
        // Given: a UTC ISO 8601 timestamp.
        // When: serialised and restored.
        // Then: equality holds.
        final ts = DateTime.utc(2026, 5, 21, 14, 25, 30, 123);
        final ev = _event(timestamp: ts);
        final restored = SessionLogEvent.fromJson(ev.toJson());
        check(restored.timestamp).equals(ts);
        check(restored.timestamp.isUtc).isTrue();
      });

      test('non-UTC timestamp is normalised to UTC on parse', () {
        // Given: a local timestamp.
        // When: round-tripped.
        // Then: restored value is UTC equivalent.
        final local = DateTime(2026, 5, 21, 14, 25, 30);
        final ev = _event(timestamp: local);
        final restored = SessionLogEvent.fromJson(ev.toJson());
        check(restored.timestamp.isUtc).isTrue();
        check(restored.timestamp).equals(local.toUtc());
      });

      test('timestamp serialised in ISO 8601', () {
        // Given: a known UTC moment.
        // When: serialised.
        // Then: the JSON value matches ISO 8601 toIso8601String format.
        final ts = DateTime.utc(2026, 4, 2, 14, 25, 30, 123);
        final json = _event(timestamp: ts).toJson();
        check(json['timestamp']).equals('2026-04-02T14:25:30.123Z');
      });
    });

    group('JSON round-trip — GPS coordinates', () {
      test('non-null latitude/longitude survive round-trip', () {
        final ev = _event(latitude: 37.7749, longitude: -122.4194);
        final restored = SessionLogEvent.fromJson(ev.toJson());
        check(restored.latitude).equals(37.7749);
        check(restored.longitude).equals(-122.4194);
      });

      test('null GPS is omitted from JSON (key absent)', () {
        // Given: an event without GPS logging.
        // When: serialised.
        // Then: latitude/longitude keys are absent (not null).
        final ev = _event();
        final json = ev.toJson();
        check(json.containsKey('latitude')).isFalse();
        check(json.containsKey('longitude')).isFalse();
      });

      test('null GPS round-trips as null', () {
        final ev = _event();
        final restored = SessionLogEvent.fromJson(ev.toJson());
        check(restored.latitude).isNull();
        check(restored.longitude).isNull();
      });

      test('integer-valued GPS coords parse as doubles', () {
        // Given: a JSON map with integer-valued lat/lng (legitimate JSON num).
        // When: deserialised.
        // Then: parsed as double via (num).toDouble().
        final json = {
          'timestamp': '2026-05-21T10:00:00.000Z',
          'eventType': 'step_fired',
          'stepIndex': 1,
          'description': 'GPS log',
          'latitude': 37,
          'longitude': -122,
        };
        final ev = SessionLogEvent.fromJson(json);
        check(ev.latitude).equals(37.0);
        check(ev.longitude).equals(-122.0);
      });
    });

    group('JSON round-trip — eventType', () {
      test('round-trip preserves "started"', () {
        final restored = SessionLogEvent.fromJson(
          _event(eventType: 'started').toJson(),
        );
        check(restored.eventType).equals('started');
      });

      test('round-trip preserves "step_fired"', () {
        final restored = SessionLogEvent.fromJson(
          _event(eventType: 'step_fired').toJson(),
        );
        check(restored.eventType).equals('step_fired');
      });

      test('round-trip preserves "disarmed"', () {
        final restored = SessionLogEvent.fromJson(
          _event(eventType: 'disarmed').toJson(),
        );
        check(restored.eventType).equals('disarmed');
      });

      test('round-trip preserves "missed"', () {
        final restored = SessionLogEvent.fromJson(
          _event(eventType: 'missed').toJson(),
        );
        check(restored.eventType).equals('missed');
      });

      test('round-trip preserves "escalated"', () {
        final restored = SessionLogEvent.fromJson(
          _event(eventType: 'escalated').toJson(),
        );
        check(restored.eventType).equals('escalated');
      });

      test('round-trip preserves "completed"', () {
        final restored = SessionLogEvent.fromJson(
          _event(eventType: 'completed').toJson(),
        );
        check(restored.eventType).equals('completed');
      });

      test('round-trip preserves "error"', () {
        final restored = SessionLogEvent.fromJson(
          _event(eventType: 'error').toJson(),
        );
        check(restored.eventType).equals('error');
      });
    });

    group('JSON round-trip — deliveryStatus', () {
      test('deliveryStatus "sent" round-trips', () {
        final restored = SessionLogEvent.fromJson(
          _event(deliveryStatus: 'sent').toJson(),
        );
        check(restored.deliveryStatus).equals('sent');
      });

      test('deliveryStatus "queued" round-trips', () {
        final restored = SessionLogEvent.fromJson(
          _event(deliveryStatus: 'queued').toJson(),
        );
        check(restored.deliveryStatus).equals('queued');
      });

      test('deliveryStatus "failed" round-trips', () {
        final restored = SessionLogEvent.fromJson(
          _event(deliveryStatus: 'failed').toJson(),
        );
        check(restored.deliveryStatus).equals('failed');
      });

      test('deliveryStatus "simBlocked" round-trips', () {
        final restored = SessionLogEvent.fromJson(
          _event(deliveryStatus: 'simBlocked').toJson(),
        );
        check(restored.deliveryStatus).equals('simBlocked');
      });

      test('null deliveryStatus omitted from JSON', () {
        // Given: a non-message event.
        // When: serialised.
        // Then: deliveryStatus key is absent.
        final json = _event().toJson();
        check(json.containsKey('deliveryStatus')).isFalse();
      });

      test('null deliveryStatus survives round-trip as null', () {
        final restored = SessionLogEvent.fromJson(_event().toJson());
        check(restored.deliveryStatus).isNull();
      });
    });

    group('JSON round-trip — stepType / stepIndex / description', () {
      test('stepType preserved verbatim (ChainStepType.name string)', () {
        final restored = SessionLogEvent.fromJson(
          _event(stepType: 'smsContact').toJson(),
        );
        check(restored.stepType).equals('smsContact');
      });

      test('null stepType omitted from JSON', () {
        // Given: a top-level "started" event.
        // When: serialised with no stepType.
        // Then: the key is absent.
        final ev = SessionLogEvent(
          timestamp: DateTime.utc(2026, 5, 21),
          eventType: 'started',
          stepIndex: 0,
          description: 'Session start',
        );
        check(ev.toJson().containsKey('stepType')).isFalse();
      });

      test('stepIndex 0 round-trips', () {
        final restored = SessionLogEvent.fromJson(
          _event(stepIndex: 0).toJson(),
        );
        check(restored.stepIndex).equals(0);
      });

      test('large stepIndex round-trips', () {
        final restored = SessionLogEvent.fromJson(
          _event(stepIndex: 9999).toJson(),
        );
        check(restored.stepIndex).equals(9999);
      });

      test('description with special characters round-trips', () {
        final restored = SessionLogEvent.fromJson(
          _event(
            description: 'Fake call from Angela (ring 30s)\nstep #1',
          ).toJson(),
        );
        check(
          restored.description,
        ).equals('Fake call from Angela (ring 30s)\nstep #1');
      });
    });

    group('equality and hashCode', () {
      test('two events with same fields are equal', () {
        // Given: two events with identical timestamp/eventType/stepType/etc.
        // When: compared.
        // Then: equal and share hashCode.
        final ts = DateTime.utc(2026, 5, 21, 10);
        final a = _event(timestamp: ts, eventType: 'disarmed', stepIndex: 2);
        final b = _event(timestamp: ts, eventType: 'disarmed', stepIndex: 2);
        check(a).equals(b);
        check(a.hashCode).equals(b.hashCode);
      });

      test('differing timestamp breaks equality', () {
        final a = _event(timestamp: DateTime.utc(2026, 5, 21, 10));
        final b = _event(timestamp: DateTime.utc(2026, 5, 21, 10, 0, 1));
        check(a).not((it) => it.equals(b));
      });

      test('differing eventType breaks equality', () {
        final a = _event(eventType: 'step_fired');
        final b = _event(eventType: 'disarmed');
        check(a).not((it) => it.equals(b));
      });

      test('differing stepType breaks equality', () {
        final a = _event(stepType: 'smsContact');
        final b = _event(stepType: 'holdButton');
        check(a).not((it) => it.equals(b));
      });

      test('differing stepIndex breaks equality', () {
        final a = _event(stepIndex: 2);
        final b = _event(stepIndex: 3);
        check(a).not((it) => it.equals(b));
      });

      test('differing description breaks equality', () {
        final a = _event(description: 'A');
        final b = _event(description: 'B');
        check(a).not((it) => it.equals(b));
      });

      test('differing latitude breaks equality', () {
        final a = _event(latitude: 1.0, longitude: 2.0);
        final b = _event(latitude: 1.5, longitude: 2.0);
        check(a).not((it) => it.equals(b));
      });

      test('differing deliveryStatus breaks equality', () {
        final a = _event(deliveryStatus: 'sent');
        final b = _event(deliveryStatus: 'failed');
        check(a).not((it) => it.equals(b));
      });

      test('not equal to unrelated type', () {
        final SessionLogEvent ev = _event();
        const Object notAnEvent = 'not an event';
        check(ev == notAnEvent).isFalse();
      });
    });

    group('copyWith', () {
      test('copyWith with no args returns equal event', () {
        final original = _event(deliveryStatus: 'sent');
        check(original.copyWith()).equals(original);
      });

      test('copyWith replaces eventType only', () {
        final original = _event();
        final copy = original.copyWith(eventType: 'disarmed');
        check(copy.eventType).equals('disarmed');
        check(copy.stepIndex).equals(original.stepIndex);
        check(copy.description).equals(original.description);
      });

      test('copyWith preserves timestamp by default', () {
        final original = _event();
        final copy = original.copyWith(description: 'New text');
        check(copy.timestamp).equals(original.timestamp);
      });
    });
  });
}
