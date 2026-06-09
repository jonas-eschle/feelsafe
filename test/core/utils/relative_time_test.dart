import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/core/utils/relative_time.dart';

void main() {
  final now = DateTime.utc(2026, 6, 9, 12);

  group('RelativeTime.between — bucketing', () {
    test('under a minute → justNow with value 0', () {
      final r = RelativeTime.between(
        now.subtract(const Duration(seconds: 30)),
        now: now,
      );
      check(r.unit).equals(RelativeTimeUnit.justNow);
      check(r.value).equals(0);
    });

    test('exactly at now → justNow', () {
      final r = RelativeTime.between(now, now: now);
      check(r.unit).equals(RelativeTimeUnit.justNow);
    });

    test('a future time (clock skew) clamps to justNow', () {
      final r = RelativeTime.between(
        now.add(const Duration(minutes: 5)),
        now: now,
      );
      check(r.unit).equals(RelativeTimeUnit.justNow);
    });

    test('1 minute → minutes/1', () {
      final r = RelativeTime.between(
        now.subtract(const Duration(minutes: 1)),
        now: now,
      );
      check(r.unit).equals(RelativeTimeUnit.minutes);
      check(r.value).equals(1);
    });

    test('59 minutes → minutes/59', () {
      final r = RelativeTime.between(
        now.subtract(const Duration(minutes: 59)),
        now: now,
      );
      check(r.unit).equals(RelativeTimeUnit.minutes);
      check(r.value).equals(59);
    });

    test('60 minutes → hours/1', () {
      final r = RelativeTime.between(
        now.subtract(const Duration(minutes: 60)),
        now: now,
      );
      check(r.unit).equals(RelativeTimeUnit.hours);
      check(r.value).equals(1);
    });

    test('23 hours → hours/23', () {
      final r = RelativeTime.between(
        now.subtract(const Duration(hours: 23)),
        now: now,
      );
      check(r.unit).equals(RelativeTimeUnit.hours);
      check(r.value).equals(23);
    });

    test('24 hours → days/1', () {
      final r = RelativeTime.between(
        now.subtract(const Duration(hours: 24)),
        now: now,
      );
      check(r.unit).equals(RelativeTimeUnit.days);
      check(r.value).equals(1);
    });

    test('10 days → days/10', () {
      final r = RelativeTime.between(
        now.subtract(const Duration(days: 10)),
        now: now,
      );
      check(r.unit).equals(RelativeTimeUnit.days);
      check(r.value).equals(10);
    });
  });
}
