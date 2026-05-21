import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/models/session_log.dart';
import 'package:guardianangela/domain/models/session_log_event.dart';

SessionLogEvent _event({
  DateTime? timestamp,
  String eventType = 'started',
  String? stepType,
  int stepIndex = 0,
  String description = 'Session initialised',
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

SessionLog _log({
  String id = 'log-1',
  String modeId = 'mode-walk',
  String modeName = 'Walk Mode',
  DateTime? startedAt,
  DateTime? endedAt,
  EndReason? endReason,
  bool isSimulation = false,
  bool hadMedicalInfo = false,
  List<SessionLogEvent>? events,
}) => SessionLog(
  id: id,
  modeId: modeId,
  modeName: modeName,
  startedAt: startedAt ?? DateTime.utc(2026, 5, 21, 10),
  endedAt: endedAt,
  endReason: endReason,
  isSimulation: isSimulation,
  hadMedicalInfo: hadMedicalInfo,
  events: events ?? const [],
);

void main() {
  group('SessionLog', () {
    group('construction defaults', () {
      test('hadMedicalInfo defaults to false (Extra 47 / Q15)', () {
        // Given: a session log built without hadMedicalInfo.
        // When: the log is constructed.
        // Then: the default flag is false — medical info is opt-in
        //       and stamped by SessionLogRecorder at session start.
        final log = SessionLog(
          id: 'log-1',
          modeId: 'mode-1',
          modeName: 'Walk Mode',
          startedAt: DateTime.utc(2026, 5, 21),
          isSimulation: false,
          events: const [],
        );
        check(log.hadMedicalInfo).isFalse();
      });

      test('endedAt and endReason are nullable for in-progress sessions', () {
        // Given: a session that is still running.
        // When: built without endedAt/endReason.
        // Then: both fields are null.
        final log = _log();
        check(log.endedAt).isNull();
        check(log.endReason).isNull();
      });

      test('events list is required (no implicit empty)', () {
        // Given: a session that has not yet emitted any events.
        // When: events is provided as an empty list.
        // Then: the list is empty (not null).
        final log = _log(events: const []);
        check(log.events).isEmpty();
      });

      test('isSimulation must be set explicitly (required)', () {
        // Given: a real session.
        // When: isSimulation false is provided.
        // Then: the field round-trips as false.
        final log = _log();
        check(log.isSimulation).isFalse();
      });

      test('modeName is cached at session start (preserved as-is)', () {
        // Given: a mode named at session start.
        // When: the log is constructed.
        // Then: modeName is retained for display when the mode is
        //       later deleted.
        final log = _log(modeName: 'Cached Mode Name');
        check(log.modeName).equals('Cached Mode Name');
      });
    });

    group('EndReason coverage', () {
      test('appTermination is NOT a valid EndReason (lessons §5.2)', () {
        // Given: the EndReason enum.
        // When: we try to look up 'appTermination'.
        // Then: byName throws ArgumentError — app death leaves NO log.
        check(
          () => EndReason.values.byName('appTermination'),
        ).throws<ArgumentError>();
      });

      test('EndReason has exactly the six spec-defined values', () {
        // Given: spec §EndReason names six values.
        // When: collected by name.
        // Then: the set matches exactly — no additions or removals.
        final names = EndReason.values.map((e) => e.name).toSet();
        check(names).deepEquals({
          'disarm',
          'chainExhausted',
          'hardwarePanic',
          'duressPin',
          'wrongPinExhausted',
          'userQuit',
        });
      });

      test('round-trip preserves disarm by name (not index)', () {
        final original = _log(
          endedAt: DateTime.utc(2026, 5, 21, 10, 30),
          endReason: EndReason.disarm,
        );
        final json = original.toJson();
        check(json['endReason']).equals('disarm');
        final restored = SessionLog.fromJson(json);
        check(restored.endReason).equals(EndReason.disarm);
      });

      test('round-trip preserves chainExhausted by name', () {
        final original = _log(
          endedAt: DateTime.utc(2026, 5, 21, 10, 30),
          endReason: EndReason.chainExhausted,
        );
        final json = original.toJson();
        check(json['endReason']).equals('chainExhausted');
        check(
          SessionLog.fromJson(json).endReason,
        ).equals(EndReason.chainExhausted);
      });

      test('round-trip preserves hardwarePanic by name', () {
        final original = _log(
          endedAt: DateTime.utc(2026, 5, 21, 10, 30),
          endReason: EndReason.hardwarePanic,
        );
        final json = original.toJson();
        check(json['endReason']).equals('hardwarePanic');
        check(
          SessionLog.fromJson(json).endReason,
        ).equals(EndReason.hardwarePanic);
      });

      test('round-trip preserves duressPin by name', () {
        final original = _log(
          endedAt: DateTime.utc(2026, 5, 21, 10, 30),
          endReason: EndReason.duressPin,
        );
        final json = original.toJson();
        check(json['endReason']).equals('duressPin');
        check(SessionLog.fromJson(json).endReason).equals(EndReason.duressPin);
      });

      test('round-trip preserves wrongPinExhausted by name', () {
        final original = _log(
          endedAt: DateTime.utc(2026, 5, 21, 10, 30),
          endReason: EndReason.wrongPinExhausted,
        );
        final json = original.toJson();
        check(json['endReason']).equals('wrongPinExhausted');
        check(
          SessionLog.fromJson(json).endReason,
        ).equals(EndReason.wrongPinExhausted);
      });

      test('round-trip preserves userQuit by name', () {
        final original = _log(
          endedAt: DateTime.utc(2026, 5, 21, 10, 30),
          endReason: EndReason.userQuit,
        );
        final json = original.toJson();
        check(json['endReason']).equals('userQuit');
        check(SessionLog.fromJson(json).endReason).equals(EndReason.userQuit);
      });

      test('endReason omitted from JSON when null (still running)', () {
        // Given: a still-running session with no endReason.
        // When: serialised.
        // Then: the key is absent from JSON (not "null").
        final log = _log();
        final json = log.toJson();
        check(json.containsKey('endReason')).isFalse();
      });
    });

    group('JSON round-trip', () {
      test('round-trip preserves timestamps in UTC ISO 8601', () {
        // Given: a session with UTC start and end.
        // When: serialised and restored.
        // Then: both timestamps survive round-trip exactly.
        final original = _log(
          startedAt: DateTime.utc(2026, 5, 21, 10),
          endedAt: DateTime.utc(2026, 5, 21, 11, 30, 15, 250),
          endReason: EndReason.disarm,
        );
        final restored = SessionLog.fromJson(original.toJson());
        check(restored.startedAt).equals(original.startedAt);
        check(restored.endedAt).equals(original.endedAt);
      });

      test('round-trip normalises non-UTC startedAt to UTC', () {
        // Given: a local-time startedAt.
        // When: round-tripped.
        // Then: the restored DateTime is UTC.
        final local = DateTime(2026, 5, 21, 10);
        final restored = SessionLog.fromJson(
          _log(startedAt: local, endReason: EndReason.disarm).toJson(),
        );
        check(restored.startedAt.isUtc).isTrue();
        check(restored.startedAt).equals(local.toUtc());
      });

      test('round-trip preserves isSimulation = true', () {
        final original = _log(isSimulation: true);
        final restored = SessionLog.fromJson(original.toJson());
        check(restored.isSimulation).isTrue();
      });

      test('round-trip preserves isSimulation = false', () {
        final original = _log();
        final restored = SessionLog.fromJson(original.toJson());
        check(restored.isSimulation).isFalse();
      });

      test('round-trip preserves hadMedicalInfo = true', () {
        final original = _log(hadMedicalInfo: true);
        final restored = SessionLog.fromJson(original.toJson());
        check(restored.hadMedicalInfo).isTrue();
      });

      test('hadMedicalInfo missing from legacy JSON defaults to false', () {
        // Given: a JSON map without the hadMedicalInfo key.
        // When: deserialised.
        // Then: the field defaults to false (defensive parse).
        final json = {
          'id': 'log-x',
          'modeId': 'mode-x',
          'modeName': 'Old Mode',
          'startedAt': '2026-05-21T10:00:00.000Z',
          'isSimulation': false,
          'events': <Map<String, dynamic>>[],
        };
        final restored = SessionLog.fromJson(json);
        check(restored.hadMedicalInfo).isFalse();
      });

      test('events list ORDER is preserved through round-trip', () {
        // Given: three events with distinct stepIndex.
        // When: round-tripped.
        // Then: the order matches the original list.
        final events = [
          _event(description: 'a'),
          _event(eventType: 'step_fired', stepIndex: 1, description: 'b'),
          _event(eventType: 'disarmed', stepIndex: 2, description: 'c'),
        ];
        final original = _log(events: events);
        final restored = SessionLog.fromJson(original.toJson());
        check(restored.events.length).equals(3);
        check(restored.events[0].description).equals('a');
        check(restored.events[1].description).equals('b');
        check(restored.events[2].description).equals('c');
      });

      test('empty events list round-trips as empty list (not null)', () {
        final original = _log();
        final restored = SessionLog.fromJson(original.toJson());
        check(restored.events).isEmpty();
      });

      test('round-trip preserves id and modeId verbatim', () {
        final original = _log(id: 'uuid-abc-123', modeId: 'mode-uuid-xyz');
        final restored = SessionLog.fromJson(original.toJson());
        check(restored.id).equals('uuid-abc-123');
        check(restored.modeId).equals('mode-uuid-xyz');
      });

      test('events serialise as JSON list (not string-encoded)', () {
        // Given: a log with one event.
        // When: serialised.
        // Then: events JSON is a List<dynamic> of maps.
        final log = _log(events: [_event()]);
        final json = log.toJson();
        check(json['events']).isA<List<dynamic>>();
        check((json['events']! as List<dynamic>).length).equals(1);
        check(
          (json['events']! as List<dynamic>)[0],
        ).isA<Map<String, dynamic>>();
      });
    });

    group('equality and hashCode', () {
      test('two identical logs are equal', () {
        // Given: two logs built with the same field values.
        // When: compared.
        // Then: they are equal AND share a hashCode.
        final a = _log(endReason: EndReason.disarm);
        final b = _log(endReason: EndReason.disarm);
        check(a).equals(b);
        check(a.hashCode).equals(b.hashCode);
      });

      test('differing id breaks equality', () {
        final a = _log();
        final b = _log(id: 'log-2');
        check(a).not((it) => it.equals(b));
      });

      test('differing endReason breaks equality', () {
        final a = _log(endReason: EndReason.disarm);
        final b = _log(endReason: EndReason.userQuit);
        check(a).not((it) => it.equals(b));
      });

      test('differing modeName breaks equality', () {
        final a = _log(modeName: 'A');
        final b = _log(modeName: 'B');
        check(a).not((it) => it.equals(b));
      });

      test('differing isSimulation breaks equality', () {
        final a = _log();
        final b = _log(isSimulation: true);
        check(a).not((it) => it.equals(b));
      });

      test('differing hadMedicalInfo breaks equality', () {
        final a = _log();
        final b = _log(hadMedicalInfo: true);
        check(a).not((it) => it.equals(b));
      });

      test('differing events list element breaks equality', () {
        final a = _log(events: [_event(description: 'a')]);
        final b = _log(events: [_event(description: 'b')]);
        check(a).not((it) => it.equals(b));
      });

      test('differing events list length breaks equality', () {
        final a = _log(events: [_event()]);
        final b = _log(
          events: [
            _event(),
            _event(eventType: 'completed'),
          ],
        );
        check(a).not((it) => it.equals(b));
      });

      test('not equal to a non-SessionLog object', () {
        // Given: a SessionLog.
        // When: compared with an unrelated object.
        // Then: equality returns false.
        final SessionLog log = _log();
        const Object notALog = 'not a session log';
        check(log == notALog).isFalse();
      });

      test('identical instance is equal to itself', () {
        // Given: a single session log.
        // When: compared to itself.
        // Then: identity short-circuit returns true.
        final log = _log();
        // ignore: unrelated_type_equality_checks
        check(log == log).isTrue();
      });
    });

    group('copyWith', () {
      test('copyWith without args returns equal log', () {
        final original = _log(endReason: EndReason.userQuit);
        final copy = original.copyWith();
        check(copy).equals(original);
      });

      test('copyWith replaces individual fields without touching others', () {
        final original = _log(modeName: 'Walk');
        final copy = original.copyWith(modeName: 'Renamed');
        check(copy.modeName).equals('Renamed');
        check(copy.id).equals(original.id);
        check(copy.modeId).equals(original.modeId);
      });
    });
  });
}
