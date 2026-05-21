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
      check(o.distressModeId).isNull();
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

    test('round-trip with distressModeId', () {
      const o = ModeOverrides(distressModeId: 'dc-1');
      check(ModeOverrides.fromJson(o.toJson())).equals(o);
    });

    test('copyWith replaces targeted fields', () {
      const o = ModeOverrides();
      final o2 = o.copyWith(distressModeId: 'x');
      check(o2.distressModeId).equals('x');
    });

    test('copyWith replaces every field', () {
      const o = ModeOverrides();
      const tpl = ReminderTemplate(
        id: 't1',
        name: 'n',
        title: 'T',
        body: 'B',
        confirmationType: ConfirmationType.dismiss,
        displayStyle: ReminderDisplayStyle.subtle,
        isGlobal: false,
      );
      final o2 = o.copyWith(
        distressModeId: 'x',
        gpsLogging: const GpsLoggingConfig(enabled: false),
        stealth: const StealthConfig(enabled: true),
        localTemplates: const [tpl],
        eventDefaults: const EventDefaults(),
      );
      check(o2.distressModeId).equals('x');
      check(o2.gpsLogging).isNotNull();
      check(o2.stealth).isNotNull();
      check(o2.localTemplates).deepEquals(const [tpl]);
      check(o2.eventDefaults).isNotNull();
    });

    test('equality identical', () {
      const o = ModeOverrides();
      check(o == o).isTrue();
    });

    test('equality cross-type unequal', () {
      // ignore: unrelated_type_equality_checks
      check(const ModeOverrides() == 'x').isFalse();
    });

    test('equal values equal', () {
      const a = ModeOverrides(distressModeId: 'x');
      const b = ModeOverrides(distressModeId: 'x');
      check(a).equals(b);
      check(a.hashCode).equals(b.hashCode);
    });

    test('differ by distressModeId unequal', () {
      check(
        const ModeOverrides() == const ModeOverrides(distressModeId: 'x'),
      ).isFalse();
    });

    test('differ by gpsLogging unequal', () {
      check(
        const ModeOverrides() ==
            const ModeOverrides(gpsLogging: GpsLoggingConfig()),
      ).isFalse();
    });

    test('differ by stealth unequal', () {
      check(
        const ModeOverrides() ==
            const ModeOverrides(stealth: StealthConfig()),
      ).isFalse();
    });

    test('differ by eventDefaults unequal', () {
      check(
        const ModeOverrides() ==
            const ModeOverrides(eventDefaults: EventDefaults()),
      ).isFalse();
    });

    test('differ by localTemplates length unequal', () {
      const tpl = ReminderTemplate(
        id: 't1',
        name: 'n',
        title: 'T',
        body: 'B',
        confirmationType: ConfirmationType.dismiss,
        displayStyle: ReminderDisplayStyle.subtle,
        isGlobal: false,
      );
      check(
        const ModeOverrides() == const ModeOverrides(localTemplates: [tpl]),
      ).isFalse();
    });

    test('differ by localTemplates at index unequal', () {
      const a = ReminderTemplate(
        id: 't1',
        name: 'n',
        title: 'T',
        body: 'B',
        confirmationType: ConfirmationType.dismiss,
        displayStyle: ReminderDisplayStyle.subtle,
        isGlobal: false,
      );
      const b = ReminderTemplate(
        id: 't2',
        name: 'n',
        title: 'T',
        body: 'B',
        confirmationType: ConfirmationType.dismiss,
        displayStyle: ReminderDisplayStyle.subtle,
        isGlobal: false,
      );
      check(
        const ModeOverrides(localTemplates: [a]) ==
            const ModeOverrides(localTemplates: [b]),
      ).isFalse();
    });

    test('toString includes distressModeId', () {
      check(const ModeOverrides(distressModeId: 'abc').toString())
          .contains('abc');
    });
  });
}
