/// Unit tests for `GpsLoggingConfig` — defaults and round-trip.
library;

import 'package:checks/checks.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:test/test.dart';

void main() {
  group('GpsLoggingConfig', () {
    test('defaults', () {
      const c = GpsLoggingConfig();
      check(c.enabled).isTrue();
      check(c.intervalSeconds).equals(60);
      check(c.accuracy).equals(GpsAccuracy.medium);
      check(c.format).equals(GpsFormat.dms);
      check(c.includeInSms).isTrue();
      check(c.historyRetentionDays).equals(30);
    });

    test('copyWith', () {
      const c = GpsLoggingConfig();
      final c2 = c.copyWith(
        enabled: false,
        intervalSeconds: 10,
        accuracy: GpsAccuracy.high,
        format: GpsFormat.decimal,
        includeInSms: false,
        historyRetentionDays: 7,
      );
      check(c2.enabled).isFalse();
      check(c2.intervalSeconds).equals(10);
      check(c2.accuracy).equals(GpsAccuracy.high);
      check(c2.format).equals(GpsFormat.decimal);
      check(c2.includeInSms).isFalse();
      check(c2.historyRetentionDays).equals(7);
    });

    test('round-trip preserves every field', () {
      const c = GpsLoggingConfig(
        enabled: false,
        intervalSeconds: 10,
        accuracy: GpsAccuracy.low,
        format: GpsFormat.openLocationCode,
        includeInSms: false,
        historyRetentionDays: 14,
      );
      check(GpsLoggingConfig.fromJson(c.toJson())).equals(c);
    });

    test('fromJson unknown accuracy throws', () {
      check(() => GpsLoggingConfig.fromJson(const {'accuracy': 'bogus'}))
          .throws<ArgumentError>();
    });

    test('fromJson unknown format throws', () {
      check(() => GpsLoggingConfig.fromJson(const {'format': 'bogus'}))
          .throws<ArgumentError>();
    });
  });
}
