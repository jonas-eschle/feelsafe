/// Unit tests for [LogGpsOverride] (spec 11 §DE-2): JSON
/// round-tripping, [resolveLogGps] precedence, and the per-subtype
/// `logGps` field on every [StepConfig] subtype.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/models/models.dart';

void main() {
  group('logGpsOverrideFromJson / toJson', () {
    test('round-trips canonical wire shape "default"/"true"/"false"', () {
      for (final v in LogGpsOverride.values) {
        final wire = logGpsOverrideToJson(v);
        check(logGpsOverrideFromJson(wire)).equals(v);
      }
    });

    test('null and missing both decode to useDefault', () {
      check(logGpsOverrideFromJson(null)).equals(LogGpsOverride.useDefault);
    });

    test('legacy "useDefault"/"forceOn"/"forceOff" all decode', () {
      check(
        logGpsOverrideFromJson('useDefault'),
      ).equals(LogGpsOverride.useDefault);
      check(logGpsOverrideFromJson('forceOn')).equals(LogGpsOverride.forceOn);
      check(logGpsOverrideFromJson('forceOff')).equals(LogGpsOverride.forceOff);
    });

    test('canonical wire values "default"/"true"/"false"', () {
      check(logGpsOverrideToJson(LogGpsOverride.useDefault)).equals('default');
      check(logGpsOverrideToJson(LogGpsOverride.forceOn)).equals('true');
      check(logGpsOverrideToJson(LogGpsOverride.forceOff)).equals('false');
    });

    test('unknown raw value throws ArgumentError', () {
      check(() => logGpsOverrideFromJson('bogus')).throws<ArgumentError>();
    });
  });

  group('resolveLogGps precedence', () {
    test('every layer says useDefault → fall through to globalEnabled', () {
      check(
        resolveLogGps(
          LogGpsOverride.useDefault,
          LogGpsOverride.useDefault,
          true,
        ),
      ).isTrue();
      check(
        resolveLogGps(
          LogGpsOverride.useDefault,
          LogGpsOverride.useDefault,
          false,
        ),
      ).isFalse();
    });

    test('null layers behave like useDefault', () {
      check(resolveLogGps(null, null, true)).isTrue();
      check(resolveLogGps(null, null, false)).isFalse();
    });

    test('step.forceOn beats every other layer', () {
      check(
        resolveLogGps(LogGpsOverride.forceOn, LogGpsOverride.forceOff, false),
      ).isTrue();
    });

    test('step.forceOff beats every other layer', () {
      check(
        resolveLogGps(LogGpsOverride.forceOff, LogGpsOverride.forceOn, true),
      ).isFalse();
    });

    test('step.useDefault → defaults layer wins over global', () {
      check(
        resolveLogGps(LogGpsOverride.useDefault, LogGpsOverride.forceOn, false),
      ).isTrue();
      check(
        resolveLogGps(LogGpsOverride.useDefault, LogGpsOverride.forceOff, true),
      ).isFalse();
    });
  });

  group('Per-subtype logGps round-trip (DE-2)', () {
    test('HoldButtonConfig forceOff round-trips', () {
      const c = HoldButtonConfig(logGps: LogGpsOverride.forceOff);
      check(StepConfig.fromJson(c.toJson())).equals(c);
    });

    test('DisguisedReminderConfig forceOn round-trips', () {
      const c = DisguisedReminderConfig(logGps: LogGpsOverride.forceOn);
      check(StepConfig.fromJson(c.toJson())).equals(c);
    });

    test('HardwareButtonConfig forceOff round-trips', () {
      const c = HardwareButtonConfig(logGps: LogGpsOverride.forceOff);
      check(StepConfig.fromJson(c.toJson())).equals(c);
    });

    test('CountdownWarningConfig forceOn round-trips', () {
      const c = CountdownWarningConfig(logGps: LogGpsOverride.forceOn);
      check(StepConfig.fromJson(c.toJson())).equals(c);
    });

    test('FakeCallConfig forceOff round-trips', () {
      const c = FakeCallConfig(logGps: LogGpsOverride.forceOff);
      check(StepConfig.fromJson(c.toJson())).equals(c);
    });

    test('SmsContactConfig forceOn round-trips', () {
      const c = SmsContactConfig(logGps: LogGpsOverride.forceOn);
      check(StepConfig.fromJson(c.toJson())).equals(c);
    });

    test('PhoneCallContactConfig forceOff round-trips', () {
      const c = PhoneCallContactConfig(logGps: LogGpsOverride.forceOff);
      check(StepConfig.fromJson(c.toJson())).equals(c);
    });

    test('LoudAlarmConfig forceOn round-trips', () {
      const c = LoudAlarmConfig(logGps: LogGpsOverride.forceOn);
      check(StepConfig.fromJson(c.toJson())).equals(c);
    });

    test('CallEmergencyConfig forceOff round-trips', () {
      const c = CallEmergencyConfig(logGps: LogGpsOverride.forceOff);
      check(StepConfig.fromJson(c.toJson())).equals(c);
    });

    test('Defaults are useDefault on every subtype', () {
      for (final c in <StepConfig>[
        const HoldButtonConfig(),
        const DisguisedReminderConfig(),
        const HardwareButtonConfig(),
        const CountdownWarningConfig(),
        const FakeCallConfig(),
        const SmsContactConfig(),
        const PhoneCallContactConfig(),
        const LoudAlarmConfig(),
        const CallEmergencyConfig(),
      ]) {
        check(c.logGps).equals(LogGpsOverride.useDefault);
      }
    });

    test('Persisted shape uses canonical "default"/"true"/"false"', () {
      const c = SmsContactConfig(logGps: LogGpsOverride.forceOn);
      check(c.toJson()['logGps']).equals('true');
      const c2 = SmsContactConfig(logGps: LogGpsOverride.forceOff);
      check(c2.toJson()['logGps']).equals('false');
      const c3 = SmsContactConfig();
      check(c3.toJson()['logGps']).equals('default');
    });

    test('Pre-DE-2 JSON (no logGps key) loads as useDefault', () {
      // Strip the logGps field to simulate a v8-era persisted record.
      final json = const SmsContactConfig().toJson()..remove('logGps');
      final loaded = StepConfig.fromJson(json);
      check(loaded).isA<SmsContactConfig>();
      check(loaded.logGps).equals(LogGpsOverride.useDefault);
    });
  });

  group('copyWith preserves logGps', () {
    test('SmsContactConfig copyWith with logGps swaps the field', () {
      const c = SmsContactConfig();
      final c2 = c.copyWith(logGps: LogGpsOverride.forceOff);
      check(c2.logGps).equals(LogGpsOverride.forceOff);
    });

    test('HoldButtonConfig copyWith preserves non-default logGps', () {
      const c = HoldButtonConfig(logGps: LogGpsOverride.forceOn);
      check(c.copyWith().logGps).equals(LogGpsOverride.forceOn);
    });
  });
}
