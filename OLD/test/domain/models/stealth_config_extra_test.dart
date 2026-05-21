/// Supplemental tests for [StealthConfig] covering the
/// `_timerDisplayFromJson` branches not exercised by the round-trip
/// tests: `'none'`, legacy `true`/`false` booleans, and the
/// unknown-value `ArgumentError` path.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/models/models.dart';

void main() {
  group('StealthConfig._timerDisplayFromJson', () {
    StealthConfig fromRaw(Object? timerDisplayValue) => StealthConfig.fromJson({
      'enabled': false,
      'fakeName': 'Test',
      'fakeIcon': 'calendar',
      'notificationDisguise': true,
      'timerDisplay': timerDisplayValue,
      'sessionScreenStealth': true,
    });

    test('string "none" maps to StealthTimerDisplay.none', () {
      final c = fromRaw('none');
      check(c.timerDisplay).equals(StealthTimerDisplay.none);
    });

    test('bool true maps to StealthTimerDisplay.normal (legacy)', () {
      final c = fromRaw(true);
      check(c.timerDisplay).equals(StealthTimerDisplay.normal);
    });

    test('bool false maps to StealthTimerDisplay.none (legacy)', () {
      final c = fromRaw(false);
      check(c.timerDisplay).equals(StealthTimerDisplay.none);
    });

    test('null maps to StealthTimerDisplay.normal (default)', () {
      final c = fromRaw(null);
      check(c.timerDisplay).equals(StealthTimerDisplay.normal);
    });

    test('unknown string throws ArgumentError', () {
      check(() => fromRaw('bogus_value')).throws<ArgumentError>();
    });

    test('round-trip StealthTimerDisplay.none via toJson preserves value', () {
      const c = StealthConfig(timerDisplay: StealthTimerDisplay.none);
      check(
        StealthConfig.fromJson(c.toJson()).timerDisplay,
      ).equals(StealthTimerDisplay.none);
    });
  });
}
