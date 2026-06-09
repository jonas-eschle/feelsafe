// Unit tests for [AppSettings].
//
// Verifies the constructor invariants (five `assert(...)` range
// checks), the default values stamped on a freshly installed app,
// JSON round-trip stability, copyWith semantics, and the equality /
// hashCode contract per docs/spec/03-data-models.md §AppSettings and
// docs/spec/06-settings.md.
//
// ignore_for_file: prefer_const_constructors
// Each `check(() => AppSettings(...)).throws<AssertionError>()` test
// MUST defer the constructor call into a closure so the assert fires
// at runtime; using `const` would resolve the assert at compile time
// and the test would fail to compile rather than catching the error
// at runtime.

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/enums/app_theme_mode.dart';
import 'package:guardianangela/domain/models/app_defaults.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/gps_logging_config.dart';

void main() {
  group('AppSettings', () {
    group('defaults', () {
      test('default constructor matches spec 03 §AppSettings', () {
        // Arrange + Act
        const settings = AppSettings();

        // Assert — display
        check(settings.themeMode).equals(AppThemeMode.system);
        check(settings.languageCode).equals('en');
        check(settings.isFirstLaunch).isTrue();
        check(settings.selectedModeId).isNull();
      });

      test('all three PIN hashes default to null (no PIN set)', () {
        // Arrange + Act
        const settings = AppSettings();

        // Assert
        check(settings.appPinHash).isNull();
        check(settings.sessionEndPinHash).isNull();
        check(settings.duressPinHash).isNull();
      });

      test('PIN timing defaults follow spec 06 §Security', () {
        // Arrange + Act
        const settings = AppSettings();

        // Assert
        check(settings.pinTimeoutSeconds).equals(15);
        check(settings.wrongPinThreshold).equals(5);
      });

      test('deceptivePinDialogEnabled defaults true (R-42)', () {
        // R-42 requires the deceptive "Old PIN entered" dialog UX by
        // default so the wrong-PIN counter is masked from a casual
        // attacker.
        const settings = AppSettings();

        check(settings.deceptivePinDialogEnabled).isTrue();
      });

      test('biometric toggles default false (opt-in)', () {
        // Arrange + Act
        const settings = AppSettings();

        // Assert — Q14 biometrics are opt-in.
        check(settings.appPinBiometricEnabled).isFalse();
        check(settings.sessionEndPinBiometricEnabled).isFalse();
        check(settings.distressCancelBiometricEnabled).isFalse();
      });

      test('emergencyCallNumber defaults to 112 (GSM international)', () {
        const settings = AppSettings();

        check(settings.emergencyCallNumber).equals('112');
      });

      test('alarm-related defaults match spec 06 §Loud Alarm', () {
        // Arrange + Act
        const settings = AppSettings();

        // Assert — Q19: DND override is opt-in; gradual volume opt-in.
        check(settings.alarmDndOverride).isFalse();
        check(settings.alarmGradualVolume).isFalse();
        check(settings.alarmGradualVolumeDurationSeconds).equals(5);
      });

      test('log retention defaults match spec 06 §History & Retention', () {
        const settings = AppSettings();

        check(settings.sessionLogRetentionDays).equals(180);
        check(settings.trashRetentionDays).equals(7);
      });

      test('telemetry defaults: telemetryOptOut false, sentryEnabled false '
          '(D-TELEMETRY-1, opt-in)', () {
        // sentryEnabled MUST default to false — Sentry is opt-in per Q42.
        const settings = AppSettings();

        check(settings.telemetryOptOut).isFalse();
        check(settings.sentryEnabled).isFalse();
      });

      test('defaults field is a const AppDefaults instance', () {
        // Arrange + Act
        const settings = AppSettings();

        // Assert
        check(settings.defaults).equals(const AppDefaults());
      });
    });

    group('range validation (assertions)', () {
      test('pinTimeoutSeconds accepts 5 (lower bound)', () {
        check(() => AppSettings(pinTimeoutSeconds: 5)).returnsNormally();
      });

      test('pinTimeoutSeconds accepts 120 (upper bound)', () {
        check(() => AppSettings(pinTimeoutSeconds: 120)).returnsNormally();
      });

      test('pinTimeoutSeconds rejects 4 (below lower bound)', () {
        check(() => AppSettings(pinTimeoutSeconds: 4)).throws<AssertionError>();
      });

      test('pinTimeoutSeconds rejects 121 (above upper bound)', () {
        check(
          () => AppSettings(pinTimeoutSeconds: 121),
        ).throws<AssertionError>();
      });

      test('wrongPinThreshold accepts 2 (lower bound)', () {
        check(() => AppSettings(wrongPinThreshold: 2)).returnsNormally();
      });

      test('wrongPinThreshold accepts 10 (upper bound)', () {
        check(() => AppSettings(wrongPinThreshold: 10)).returnsNormally();
      });

      test('wrongPinThreshold rejects 1 (below lower bound)', () {
        check(() => AppSettings(wrongPinThreshold: 1)).throws<AssertionError>();
      });

      test('wrongPinThreshold rejects 11 (above upper bound)', () {
        check(
          () => AppSettings(wrongPinThreshold: 11),
        ).throws<AssertionError>();
      });

      test('sessionLogRetentionDays accepts 1 (lower bound)', () {
        check(() => AppSettings(sessionLogRetentionDays: 1)).returnsNormally();
      });

      test('sessionLogRetentionDays accepts 365 (upper bound)', () {
        check(
          () => AppSettings(sessionLogRetentionDays: 365),
        ).returnsNormally();
      });

      test('sessionLogRetentionDays rejects 0 (below lower bound)', () {
        check(
          () => AppSettings(sessionLogRetentionDays: 0),
        ).throws<AssertionError>();
      });

      test('sessionLogRetentionDays rejects 366 (above upper bound)', () {
        check(
          () => AppSettings(sessionLogRetentionDays: 366),
        ).throws<AssertionError>();
      });

      test('trashRetentionDays accepts 1 (lower bound)', () {
        check(() => AppSettings(trashRetentionDays: 1)).returnsNormally();
      });

      test('trashRetentionDays accepts 90 (upper bound)', () {
        check(() => AppSettings(trashRetentionDays: 90)).returnsNormally();
      });

      test('trashRetentionDays rejects 0 (below lower bound)', () {
        check(
          () => AppSettings(trashRetentionDays: 0),
        ).throws<AssertionError>();
      });

      test('trashRetentionDays rejects 91 (above upper bound)', () {
        check(
          () => AppSettings(trashRetentionDays: 91),
        ).throws<AssertionError>();
      });

      test('alarmGradualVolumeDurationSeconds accepts 1 (lower bound)', () {
        check(
          () => AppSettings(alarmGradualVolumeDurationSeconds: 1),
        ).returnsNormally();
      });

      test('alarmGradualVolumeDurationSeconds accepts 60 (upper bound)', () {
        check(
          () => AppSettings(alarmGradualVolumeDurationSeconds: 60),
        ).returnsNormally();
      });

      test('alarmGradualVolumeDurationSeconds rejects 0 '
          '(below lower bound)', () {
        check(
          () => AppSettings(alarmGradualVolumeDurationSeconds: 0),
        ).throws<AssertionError>();
      });

      test('alarmGradualVolumeDurationSeconds rejects 61 '
          '(above upper bound)', () {
        check(
          () => AppSettings(alarmGradualVolumeDurationSeconds: 61),
        ).throws<AssertionError>();
      });
    });

    group('JSON round-trip', () {
      test('default instance round-trips with stable JSON shape', () {
        // Arrange
        const original = AppSettings();

        // Act
        final json = original.toJson();
        final restored = AppSettings.fromJson(json);

        // Assert
        check(restored).equals(original);
      });

      test('themeMode serialises by name (not index)', () {
        // Arrange
        const settings = AppSettings(themeMode: AppThemeMode.dark);

        // Act
        final json = settings.toJson();

        // Assert — enums are stored as string names, not ordinals.
        check(json['themeMode']).equals('dark');
      });

      test('themeMode round-trips for every enum value', () {
        for (final mode in AppThemeMode.values) {
          // Arrange
          final settings = AppSettings(themeMode: mode);

          // Act
          final restored = AppSettings.fromJson(settings.toJson());

          // Assert
          check(restored.themeMode).equals(mode);
        }
      });

      test('non-default values for every field round-trip', () {
        // Arrange — every field different from its default.
        final settings = AppSettings(
          themeMode: AppThemeMode.dark,
          languageCode: 'de',
          isFirstLaunch: false,
          selectedModeId: 'mode-abc',
          appPinHash: 'app-hash',
          sessionEndPinHash: 'end-hash',
          duressPinHash: 'duress-hash',
          pinTimeoutSeconds: 30,
          wrongPinThreshold: 3,
          deceptivePinDialogEnabled: false,
          appPinBiometricEnabled: true,
          sessionEndPinBiometricEnabled: true,
          distressCancelBiometricEnabled: true,
          emergencyCallNumber: '911',
          alarmDndOverride: true,
          alarmGradualVolume: true,
          alarmGradualVolumeDurationSeconds: 10,
          sessionLogRetentionDays: 90,
          trashRetentionDays: 14,
          telemetryOptOut: true,
          sentryEnabled: true,
          defaults: const AppDefaults(
            gpsLogging: GpsLoggingConfig(enabled: false),
          ),
        );

        // Act
        final restored = AppSettings.fromJson(settings.toJson());

        // Assert
        check(restored).equals(settings);
      });

      test('nullable PIN hashes preserved when present', () {
        // Arrange
        const settings = AppSettings(
          appPinHash: 'hash-app',
          sessionEndPinHash: 'hash-end',
          duressPinHash: 'hash-duress',
        );

        // Act
        final restored = AppSettings.fromJson(settings.toJson());

        // Assert
        check(restored.appPinHash).equals('hash-app');
        check(restored.sessionEndPinHash).equals('hash-end');
        check(restored.duressPinHash).equals('hash-duress');
      });

      test('nullable PIN hashes preserved as null when absent', () {
        // Arrange
        const settings = AppSettings();

        // Act
        final restored = AppSettings.fromJson(settings.toJson());

        // Assert
        check(restored.appPinHash).isNull();
        check(restored.sessionEndPinHash).isNull();
        check(restored.duressPinHash).isNull();
      });

      test('selectedModeId round-trips when set', () {
        // Arrange
        const settings = AppSettings(selectedModeId: 'mode-walking');

        // Act
        final restored = AppSettings.fromJson(settings.toJson());

        // Assert
        check(restored.selectedModeId).equals('mode-walking');
      });

      test('fromJson on empty map fills in all defaults', () {
        // Arrange — empty JSON simulates a brand-new install file.
        final Map<String, dynamic> json = {};

        // Act
        final restored = AppSettings.fromJson(json);

        // Assert
        check(restored).equals(const AppSettings());
      });

      test('AppDefaults nested object round-trips', () {
        // Arrange
        const settings = AppSettings(
          defaults: AppDefaults(defaultDistressModeId: 'distress-1'),
        );

        // Act
        final restored = AppSettings.fromJson(settings.toJson());

        // Assert
        check(restored.defaults.defaultDistressModeId).equals('distress-1');
      });
    });

    group('copyWith', () {
      test('copyWith() with no args returns an equivalent instance', () {
        // Arrange
        const original = AppSettings();

        // Act
        final copy = original.copyWith();

        // Assert
        check(copy).equals(original);
      });

      test('copyWith can replace themeMode independently', () {
        // Arrange
        const original = AppSettings();

        // Act
        final copy = original.copyWith(themeMode: AppThemeMode.dark);

        // Assert
        check(copy.themeMode).equals(AppThemeMode.dark);
        check(copy.languageCode).equals(original.languageCode);
      });

      test('copyWith can replace languageCode', () {
        // Arrange
        const original = AppSettings();

        // Act
        final copy = original.copyWith(languageCode: 'fr');

        // Assert
        check(copy.languageCode).equals('fr');
      });

      test('copyWith can replace pinTimeoutSeconds within range', () {
        // Arrange
        const original = AppSettings();

        // Act
        final copy = original.copyWith(pinTimeoutSeconds: 60);

        // Assert
        check(copy.pinTimeoutSeconds).equals(60);
      });

      test('copyWith preserves nested AppDefaults identity when not '
          'replaced', () {
        // Arrange — non-default defaults instance.
        const customDefaults = AppDefaults(defaultDistressModeId: 'd-1');
        const original = AppSettings(defaults: customDefaults);

        // Act
        final copy = original.copyWith(languageCode: 'es');

        // Assert — the same AppDefaults instance is preserved.
        check(identical(copy.defaults, customDefaults)).isTrue();
      });

      test('copyWith can replace defaults with a new AppDefaults', () {
        // Arrange
        const original = AppSettings();
        const newDefaults = AppDefaults(defaultDistressModeId: 'd-2');

        // Act
        final copy = original.copyWith(defaults: newDefaults);

        // Assert
        check(copy.defaults).equals(newDefaults);
      });

      test('copyWith can replace deceptivePinDialogEnabled to false', () {
        // Arrange
        const original = AppSettings();

        // Act
        final copy = original.copyWith(deceptivePinDialogEnabled: false);

        // Assert
        check(copy.deceptivePinDialogEnabled).isFalse();
      });

      test('copyWith can replace sentryEnabled to true (opt-in)', () {
        // Arrange
        const original = AppSettings();

        // Act
        final copy = original.copyWith(sentryEnabled: true);

        // Assert
        check(copy.sentryEnabled).isTrue();
      });

      test('copyWith respects ranges via the underlying constructor', () {
        // Arrange
        const original = AppSettings();

        // Act + Assert — invalid range still fires the assert.
        check(
          () => original.copyWith(pinTimeoutSeconds: 4),
        ).throws<AssertionError>();
      });
    });

    group('equality and hashCode', () {
      test('two default instances are equal', () {
        // Arrange + Act
        const a = AppSettings();
        const b = AppSettings();

        // Assert
        check(a).equals(b);
        check(a.hashCode).equals(b.hashCode);
      });

      test('reflexive: instance equals itself', () {
        // Arrange + Act
        const settings = AppSettings();

        // Assert
        check(settings).equals(settings);
      });

      test('symmetric: a == b implies b == a', () {
        // Arrange
        const a = AppSettings(languageCode: 'de');
        const b = AppSettings(languageCode: 'de');

        // Assert
        check(a == b).isTrue();
        check(b == a).isTrue();
      });

      test('differing languageCode breaks equality', () {
        // Arrange
        const a = AppSettings();
        const b = AppSettings(languageCode: 'de');

        // Assert
        check(a == b).isFalse();
      });

      test('differing themeMode breaks equality', () {
        // Arrange
        const a = AppSettings();
        const b = AppSettings(themeMode: AppThemeMode.dark);

        // Assert
        check(a == b).isFalse();
      });

      test('differing appPinHash breaks equality', () {
        // Arrange
        const a = AppSettings();
        const b = AppSettings(appPinHash: 'h');

        // Assert
        check(a == b).isFalse();
      });

      test('differing pinTimeoutSeconds breaks equality', () {
        // Arrange
        const a = AppSettings();
        const b = AppSettings(pinTimeoutSeconds: 30);

        // Assert
        check(a == b).isFalse();
      });

      test('differing defaults breaks equality', () {
        // Arrange
        const a = AppSettings();
        const b = AppSettings(
          defaults: AppDefaults(defaultDistressModeId: 'x'),
        );

        // Assert
        check(a == b).isFalse();
      });

      test('hashCode consistent across calls', () {
        // Arrange
        const settings = AppSettings(languageCode: 'zh', pinTimeoutSeconds: 20);

        // Assert
        check(settings.hashCode).equals(settings.hashCode);
      });

      test('hashCode equal for equal instances with non-default fields', () {
        // Arrange
        const a = AppSettings(
          themeMode: AppThemeMode.dark,
          sentryEnabled: true,
          pinTimeoutSeconds: 30,
        );
        const b = AppSettings(
          themeMode: AppThemeMode.dark,
          sentryEnabled: true,
          pinTimeoutSeconds: 30,
        );

        // Assert
        check(a.hashCode).equals(b.hashCode);
      });
    });
  });
}
