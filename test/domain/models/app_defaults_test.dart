/// Unit tests for `AppDefaults` — nested defaults round-trip.
library;

import 'package:checks/checks.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:test/test.dart';

void main() {
  group('AppDefaults', () {
    test('defaults populated', () {
      const d = AppDefaults();
      check(d.gpsLogging).isA<GpsLoggingConfig>();
      check(d.stealth).isA<StealthConfig>();
      check(d.templates).isEmpty();
      check(d.eventDefaults).isA<EventDefaults>();
    });

    test('round-trip defaults', () {
      const d = AppDefaults();
      check(AppDefaults.fromJson(d.toJson())).equals(d);
    });

    test('round-trip customized', () {
      const d = AppDefaults(
        gpsLogging: GpsLoggingConfig(intervalSeconds: 15),
        stealth: StealthConfig(enabled: true),
        templates: [
          ReminderTemplate(
            id: 't1',
            name: 'n',
            title: 'T',
            body: 'B',
            confirmationType: ConfirmationType.tapButton,
            displayStyle: ReminderDisplayStyle.subtle,
            isGlobal: true,
          ),
        ],
      );
      check(AppDefaults.fromJson(d.toJson())).equals(d);
    });

    test('copyWith preserves other fields', () {
      const d = AppDefaults();
      final d2 = d.copyWith(stealth: const StealthConfig(enabled: true));
      check(d2.stealth.enabled).isTrue();
      check(d2.gpsLogging).equals(d.gpsLogging);
    });

    test('fromJson tolerates missing fields', () {
      final d = AppDefaults.fromJson(const <String, Object?>{});
      check(d.gpsLogging).isA<GpsLoggingConfig>();
      check(d.templates).isEmpty();
    });
  });
}
