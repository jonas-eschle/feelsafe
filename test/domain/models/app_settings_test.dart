/// Unit tests for `AppSettings` — PIN null-safety, defaults, JSON
/// round-trip.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/models.dart';

void main() {
  group('AppSettings', () {
    test('defaults', () {
      const s = AppSettings(defaults: AppDefaults());
      check(s.appPinHash).isNull();
      check(s.sessionEndPinHash).isNull();
      check(s.duressPinHash).isNull();
      check(s.pinTimeoutSeconds).equals(15);
      check(s.themeMode).equals(AppThemeMode.system);
      check(s.languageCode).equals('en');
      check(s.emergencyCallNumber).equals('112');
      check(s.alarmDndOverride).isFalse();
      check(s.isFirstLaunch).isTrue();
      check(s.selectedModeId).isNull();
    });

    test('all three PIN hashes default to null', () {
      const s = AppSettings(defaults: AppDefaults());
      check(s.appPinHash).isNull();
      check(s.sessionEndPinHash).isNull();
      check(s.duressPinHash).isNull();
    });

    test('can set each PIN hash independently', () {
      const s = AppSettings(
        defaults: AppDefaults(),
        appPinHash: 'app',
        sessionEndPinHash: 'sess',
        duressPinHash: 'duress',
      );
      check(s.appPinHash).equals('app');
      check(s.sessionEndPinHash).equals('sess');
      check(s.duressPinHash).equals('duress');
    });

    test('copyWith replaces field', () {
      const s = AppSettings(defaults: AppDefaults());
      final s2 = s.copyWith(languageCode: 'de');
      check(s2.languageCode).equals('de');
      check(s2.themeMode).equals(AppThemeMode.system);
    });

    test('copyWith preserves other PIN hashes', () {
      const s = AppSettings(
        defaults: AppDefaults(),
        appPinHash: 'a',
        duressPinHash: 'd',
      );
      final s2 = s.copyWith(sessionEndPinHash: 's');
      check(s2.appPinHash).equals('a');
      check(s2.sessionEndPinHash).equals('s');
      check(s2.duressPinHash).equals('d');
    });

    test('JSON round-trip with defaults', () {
      const s = AppSettings(defaults: AppDefaults());
      check(AppSettings.fromJson(s.toJson())).equals(s);
    });

    test('JSON round-trip preserves PIN hashes', () {
      const s = AppSettings(
        defaults: AppDefaults(),
        appPinHash: 'h1',
        sessionEndPinHash: 'h2',
        duressPinHash: 'h3',
      );
      final r = AppSettings.fromJson(s.toJson());
      check(r.appPinHash).equals('h1');
      check(r.sessionEndPinHash).equals('h2');
      check(r.duressPinHash).equals('h3');
    });

    test('JSON round-trip preserves themeMode', () {
      for (final mode in AppThemeMode.values) {
        final s = const AppSettings(
          defaults: AppDefaults(),
        ).copyWith(themeMode: mode);
        check(AppSettings.fromJson(s.toJson()).themeMode).equals(mode);
      }
    });

    test('JSON round-trip preserves languageCode', () {
      const s = AppSettings(defaults: AppDefaults(), languageCode: 'zh_TW');
      check(AppSettings.fromJson(s.toJson()).languageCode).equals('zh_TW');
    });

    test('JSON round-trip preserves emergencyCallNumber', () {
      const s = AppSettings(
        defaults: AppDefaults(),
        emergencyCallNumber: '911',
      );
      check(AppSettings.fromJson(s.toJson()).emergencyCallNumber).equals('911');
    });

    test('JSON round-trip preserves alarmDndOverride', () {
      const s = AppSettings(defaults: AppDefaults(), alarmDndOverride: true);
      check(AppSettings.fromJson(s.toJson()).alarmDndOverride).isTrue();
    });

    test('JSON round-trip preserves pinTimeoutSeconds', () {
      const s = AppSettings(defaults: AppDefaults(), pinTimeoutSeconds: 60);
      check(AppSettings.fromJson(s.toJson()).pinTimeoutSeconds).equals(60);
    });

    test('JSON round-trip preserves isFirstLaunch', () {
      const s = AppSettings(defaults: AppDefaults(), isFirstLaunch: false);
      check(AppSettings.fromJson(s.toJson()).isFirstLaunch).isFalse();
    });

    test('JSON round-trip preserves selectedModeId', () {
      const s = AppSettings(defaults: AppDefaults(), selectedModeId: 'm1');
      check(AppSettings.fromJson(s.toJson()).selectedModeId).equals('m1');
    });

    test('JSON round-trip preserves nested AppDefaults', () {
      const s = AppSettings(
        defaults: AppDefaults(
          gpsLogging: GpsLoggingConfig(intervalSeconds: 120),
        ),
      );
      check(
        AppSettings.fromJson(s.toJson()).defaults.gpsLogging.intervalSeconds,
      ).equals(120);
    });

    test('fromJson unknown themeMode throws', () {
      check(
        () => AppSettings.fromJson(const {'themeMode': 'bogus'}),
      ).throws<ArgumentError>();
    });

    test('equality', () {
      const a = AppSettings(defaults: AppDefaults());
      const b = AppSettings(defaults: AppDefaults());
      check(a).equals(b);
      check(a.hashCode).equals(b.hashCode);
    });

    test('inequality when PIN hash differs', () {
      const a = AppSettings(defaults: AppDefaults(), appPinHash: 'x');
      const b = AppSettings(defaults: AppDefaults(), appPinHash: 'y');
      check(a).not((it) => it.equals(b));
    });

    test('fromJson tolerates missing fields', () {
      final s = AppSettings.fromJson(const <String, Object?>{});
      check(s.appPinHash).isNull();
      check(s.themeMode).equals(AppThemeMode.system);
      check(s.languageCode).equals('en');
      check(s.emergencyCallNumber).equals('112');
      check(s.pinTimeoutSeconds).equals(15);
    });

    test('toString includes language and theme', () {
      const s = AppSettings(defaults: AppDefaults());
      final str = s.toString();
      check(str).contains('en');
      check(str).contains('system');
    });

    test('defaults property holds AppDefaults', () {
      const s = AppSettings(defaults: AppDefaults());
      check(s.defaults).isA<AppDefaults>();
    });

    test('copyWith preserves defaults when not provided', () {
      const s = AppSettings(
        defaults: AppDefaults(
          templates: [
            ReminderTemplate(
              id: 't1',
              name: 'N',
              title: 'T',
              body: 'B',
              confirmationType: ConfirmationType.dismiss,
              displayStyle: ReminderDisplayStyle.subtle,
              isGlobal: true,
            ),
          ],
        ),
      );
      final s2 = s.copyWith(languageCode: 'fr');
      check(s2.defaults.templates.length).equals(1);
    });

    test('round-trip across all three PINs disabled', () {
      const s = AppSettings(defaults: AppDefaults());
      final r = AppSettings.fromJson(s.toJson());
      check(r.appPinHash).isNull();
      check(r.sessionEndPinHash).isNull();
      check(r.duressPinHash).isNull();
    });
  });
}
