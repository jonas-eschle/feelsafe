/// Tests for the three biometric toggles on [AppSettings]:
/// `appPinBiometricEnabled`, `sessionEndPinBiometricEnabled`, and
/// `distressCancelBiometricEnabled`.
///
/// Spec 06 §Biometric toggles.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/models/app_defaults.dart';
import 'package:guardianangela/domain/models/app_settings.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const AppSettings _base = AppSettings(defaults: AppDefaults());

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AppSettings biometric defaults', () {
    test('appPinBiometricEnabled defaults to false', () {
      check(_base.appPinBiometricEnabled).isFalse();
    });

    test('sessionEndPinBiometricEnabled defaults to false', () {
      check(_base.sessionEndPinBiometricEnabled).isFalse();
    });

    test('distressCancelBiometricEnabled defaults to false', () {
      check(_base.distressCancelBiometricEnabled).isFalse();
    });
  });

  group('AppSettings biometric JSON round-trip', () {
    test('all three true survive toJson/fromJson', () {
      // Arrange
      const s = AppSettings(
        defaults: AppDefaults(),
        appPinBiometricEnabled: true,
        sessionEndPinBiometricEnabled: true,
        distressCancelBiometricEnabled: true,
      );
      // Act
      final rt = AppSettings.fromJson(s.toJson());
      // Assert
      check(rt.appPinBiometricEnabled).isTrue();
      check(rt.sessionEndPinBiometricEnabled).isTrue();
      check(rt.distressCancelBiometricEnabled).isTrue();
    });

    test('all three false survive toJson/fromJson', () {
      const s = AppSettings(
        defaults: AppDefaults(),
        appPinBiometricEnabled: false,
        sessionEndPinBiometricEnabled: false,
        distressCancelBiometricEnabled: false,
      );
      final rt = AppSettings.fromJson(s.toJson());
      check(rt.appPinBiometricEnabled).isFalse();
      check(rt.sessionEndPinBiometricEnabled).isFalse();
      check(rt.distressCancelBiometricEnabled).isFalse();
    });

    test('each toggle survives independently: only appPin=true', () {
      const s = AppSettings(
        defaults: AppDefaults(),
        appPinBiometricEnabled: true,
      );
      final rt = AppSettings.fromJson(s.toJson());
      check(rt.appPinBiometricEnabled).isTrue();
      check(rt.sessionEndPinBiometricEnabled).isFalse();
      check(rt.distressCancelBiometricEnabled).isFalse();
    });

    test('each toggle survives independently: only sessionEnd=true', () {
      const s = AppSettings(
        defaults: AppDefaults(),
        sessionEndPinBiometricEnabled: true,
      );
      final rt = AppSettings.fromJson(s.toJson());
      check(rt.appPinBiometricEnabled).isFalse();
      check(rt.sessionEndPinBiometricEnabled).isTrue();
      check(rt.distressCancelBiometricEnabled).isFalse();
    });

    test('each toggle survives independently: only distressCancel=true', () {
      const s = AppSettings(
        defaults: AppDefaults(),
        distressCancelBiometricEnabled: true,
      );
      final rt = AppSettings.fromJson(s.toJson());
      check(rt.appPinBiometricEnabled).isFalse();
      check(rt.sessionEndPinBiometricEnabled).isFalse();
      check(rt.distressCancelBiometricEnabled).isTrue();
    });

    test('legacy JSON without biometric keys deserializes to false', () {
      // Arrange — omit all three keys.
      final raw = <String, Object?>{'defaults': const AppDefaults().toJson()};
      // Act
      final s = AppSettings.fromJson(raw);
      // Assert
      check(s.appPinBiometricEnabled).isFalse();
      check(s.sessionEndPinBiometricEnabled).isFalse();
      check(s.distressCancelBiometricEnabled).isFalse();
    });
  });

  group('AppSettings.copyWith biometric toggles', () {
    test('copyWith(appPinBiometricEnabled: true) sets only that toggle', () {
      // Arrange
      final copy = _base.copyWith(appPinBiometricEnabled: true);
      // Assert
      check(copy.appPinBiometricEnabled).isTrue();
      check(copy.sessionEndPinBiometricEnabled).isFalse();
      check(copy.distressCancelBiometricEnabled).isFalse();
    });

    test(
      'copyWith(sessionEndPinBiometricEnabled: true) sets only that toggle',
      () {
        final copy = _base.copyWith(sessionEndPinBiometricEnabled: true);
        check(copy.appPinBiometricEnabled).isFalse();
        check(copy.sessionEndPinBiometricEnabled).isTrue();
        check(copy.distressCancelBiometricEnabled).isFalse();
      },
    );

    test(
      'copyWith(distressCancelBiometricEnabled: true) sets only that toggle',
      () {
        final copy = _base.copyWith(distressCancelBiometricEnabled: true);
        check(copy.appPinBiometricEnabled).isFalse();
        check(copy.sessionEndPinBiometricEnabled).isFalse();
        check(copy.distressCancelBiometricEnabled).isTrue();
      },
    );

    test('original is unmodified after copyWith', () {
      _base.copyWith(appPinBiometricEnabled: true);
      check(_base.appPinBiometricEnabled).isFalse();
    });
  });

  group('AppSettings equality accounts for biometric toggles', () {
    test('settings differing only in appPinBiometricEnabled are NOT equal', () {
      const a = AppSettings(defaults: AppDefaults());
      const b = AppSettings(
        defaults: AppDefaults(),
        appPinBiometricEnabled: true,
      );
      check(a).not((m) => m.equals(b));
    });

    test(
      'settings differing only in sessionEndPinBiometricEnabled are NOT equal',
      () {
        const a = AppSettings(defaults: AppDefaults());
        const b = AppSettings(
          defaults: AppDefaults(),
          sessionEndPinBiometricEnabled: true,
        );
        check(a).not((m) => m.equals(b));
      },
    );

    test(
      'settings differing only in distressCancelBiometricEnabled are NOT equal',
      () {
        const a = AppSettings(defaults: AppDefaults());
        const b = AppSettings(
          defaults: AppDefaults(),
          distressCancelBiometricEnabled: true,
        );
        check(a).not((m) => m.equals(b));
      },
    );

    test('identical biometric toggles yield equal settings', () {
      const a = AppSettings(
        defaults: AppDefaults(),
        appPinBiometricEnabled: true,
        sessionEndPinBiometricEnabled: true,
        distressCancelBiometricEnabled: true,
      );
      const b = AppSettings(
        defaults: AppDefaults(),
        appPinBiometricEnabled: true,
        sessionEndPinBiometricEnabled: true,
        distressCancelBiometricEnabled: true,
      );
      check(a).equals(b);
      check(a.hashCode).equals(b.hashCode);
    });
  });
}
