/// Unit tests for `BatteryAlertConfig` — defaults, chain preservation
/// across round-trips.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/models/models.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('BatteryAlertConfig', () {
    test('defaults (Q34/Q35: off at 10%)', () {
      // Q34: enabled defaults to false (privacy-first opt-in since
      // the alert auto-fires SMS).
      // Q35: thresholdPercent defaults to 10 (closer to emergency).
      const c = BatteryAlertConfig();
      check(c.enabled).isFalse();
      check(c.thresholdPercent).equals(10);
      check(c.chain).isEmpty();
    });

    test('round-trip with defaults', () {
      const c = BatteryAlertConfig();
      check(BatteryAlertConfig.fromJson(c.toJson())).equals(c);
    });

    test('round-trip with chain', () {
      final c = BatteryAlertConfig(chain: [smsStep(), fakeCallStep(order: 1)]);
      check(BatteryAlertConfig.fromJson(c.toJson())).equals(c);
    });

    test('round-trip preserves threshold', () {
      const c = BatteryAlertConfig(thresholdPercent: 25);
      check(
        BatteryAlertConfig.fromJson(c.toJson()).thresholdPercent,
      ).equals(25);
    });

    test('round-trip preserves disabled state', () {
      const c = BatteryAlertConfig(enabled: false);
      check(BatteryAlertConfig.fromJson(c.toJson()).enabled).isFalse();
    });

    test('copyWith replaces fields', () {
      const c = BatteryAlertConfig();
      final c2 = c.copyWith(enabled: false, thresholdPercent: 5);
      check(c2.enabled).isFalse();
      check(c2.thresholdPercent).equals(5);
    });

    test('equality', () {
      const a = BatteryAlertConfig();
      const b = BatteryAlertConfig();
      check(a).equals(b);
      check(a.hashCode).equals(b.hashCode);
    });

    test('inequality when chain length differs', () {
      final a = BatteryAlertConfig(chain: [smsStep()]);
      const b = BatteryAlertConfig();
      check(a).not((it) => it.equals(b));
    });
  });
}
