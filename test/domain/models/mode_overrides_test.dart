/// Unit tests for `ModeOverrides` — null-field inheritance and
/// round-trip.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/models.dart';

void main() {
  group('ModeOverrides', () {
    test('all fields null by default', () {
      const o = ModeOverrides();
      check(o.distressChainId).isNull();
      check(o.gpsLogging).isNull();
      check(o.stealth).isNull();
      check(o.localTemplates).isEmpty();
      check(o.eventDefaults).isNull();
    });

    test('round-trip empty', () {
      const o = ModeOverrides();
      check(ModeOverrides.fromJson(o.toJson())).equals(o);
    });

    test('round-trip with gpsLogging override', () {
      const o = ModeOverrides(
        gpsLogging: GpsLoggingConfig(enabled: false, intervalSeconds: 30),
      );
      check(ModeOverrides.fromJson(o.toJson())).equals(o);
    });

    test('round-trip with stealth override', () {
      const o = ModeOverrides(stealth: StealthConfig(enabled: true));
      check(ModeOverrides.fromJson(o.toJson())).equals(o);
    });

    test('round-trip with localTemplates', () {
      const o = ModeOverrides(
        localTemplates: [
          ReminderTemplate(
            id: 't1',
            name: 'n',
            title: 'T',
            body: 'B',
            confirmationType: ConfirmationType.dismiss,
            displayStyle: ReminderDisplayStyle.subtle,
            isGlobal: false,
          ),
        ],
      );
      check(ModeOverrides.fromJson(o.toJson())).equals(o);
    });

    test('round-trip with eventDefaults override', () {
      const o = ModeOverrides(eventDefaults: EventDefaults());
      check(ModeOverrides.fromJson(o.toJson())).equals(o);
    });

    test('round-trip with distressChainId', () {
      const o = ModeOverrides(distressChainId: 'dc-1');
      check(ModeOverrides.fromJson(o.toJson())).equals(o);
    });

    test('copyWith replaces targeted fields', () {
      const o = ModeOverrides();
      final o2 = o.copyWith(distressChainId: 'x');
      check(o2.distressChainId).equals('x');
    });
  });
}
