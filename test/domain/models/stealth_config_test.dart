/// Unit tests for `StealthConfig` — preset enum, round-trip.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/models/models.dart';

void main() {
  group('StealthConfig', () {
    test('defaults', () {
      const c = StealthConfig();
      check(c.enabled).isFalse();
      check(c.fakeName).equals('Music');
      check(c.fakeIcon).equals(StealthIconPreset.music);
      check(c.notificationDisguise).isTrue();
      check(c.timerDisplay).equals(StealthTimerDisplay.normal);
      check(c.sessionScreenStealth).isTrue();
    });

    test('copyWith replaces fields', () {
      const c = StealthConfig();
      final c2 = c.copyWith(
        enabled: true,
        fakeName: 'Weather',
        fakeIcon: StealthIconPreset.weather,
      );
      check(c2.enabled).isTrue();
      check(c2.fakeName).equals('Weather');
      check(c2.fakeIcon).equals(StealthIconPreset.weather);
    });

    test('round-trip defaults', () {
      const c = StealthConfig();
      check(StealthConfig.fromJson(c.toJson())).equals(c);
    });

    test('round-trip customized', () {
      const c = StealthConfig(
        enabled: true,
        fakeName: 'News',
        fakeIcon: StealthIconPreset.news,
        notificationDisguise: false,
        timerDisplay: StealthTimerDisplay.small,
        sessionScreenStealth: false,
      );
      check(StealthConfig.fromJson(c.toJson())).equals(c);
    });

    test('every preset round-trips', () {
      for (final icon in StealthIconPreset.values) {
        final c = StealthConfig(fakeIcon: icon);
        check(StealthConfig.fromJson(c.toJson()).fakeIcon).equals(icon);
      }
    });

    test('fromJson unknown icon throws', () {
      check(
        () => StealthConfig.fromJson(const {'fakeIcon': 'bogus'}),
      ).throws<ArgumentError>();
    });

    test('equality', () {
      const a = StealthConfig();
      const b = StealthConfig();
      check(a).equals(b);
      check(a.hashCode).equals(b.hashCode);
    });

    test('inequality on enabled', () {
      const a = StealthConfig();
      const b = StealthConfig(enabled: true);
      check(a).not((it) => it.equals(b));
    });
  });
}
