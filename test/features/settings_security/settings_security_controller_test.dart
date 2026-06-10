import 'dart:io';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:test/test.dart';

import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/domain/enums/app_theme_mode.dart';
import 'package:guardianangela/domain/models/app_defaults.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/stealth_config.dart';
import 'package:guardianangela/features/settings_security/settings_security_controller.dart';
import 'package:guardianangela/services/service_providers.dart';

/// In-memory [AppSettingsRepository] that round-trips through [save]/[load]
/// so a controller setter can be proven to persist (not just mutate state).
class _RoundTripRepo extends AppSettingsRepository {
  _RoundTripRepo([AppSettings? initial])
    : _current = initial ?? const AppSettings(),
      super(
        keyProvider: () async =>
            '0102030405060708090a0b0c0d0e0f'
            '101112131415161718191a1b1c1d1e1f20',
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('sec_ctrl_test_'),
      );

  AppSettings _current;

  @override
  Future<AppSettings> load() async => _current;

  @override
  Future<void> save(AppSettings value) async => _current = value;
}

/// An [AppSettings] in which EVERY field deviates from its default, so a
/// `clearPin` that drops or resets any sibling field is caught (the method
/// hand-reconstructs the settings because `copyWith` cannot null a hash).
AppSettings _fullSettings() => AppSettings(
  themeMode: AppThemeMode.dark,
  languageCode: 'de',
  isFirstLaunch: false,
  selectedModeId: 'mode-7',
  appPinHash: 'hash-app',
  sessionEndPinHash: 'hash-end',
  duressPinHash: 'hash-duress',
  pinTimeoutSeconds: 30,
  wrongPinThreshold: 4,
  deceptivePinDialogEnabled: false,
  appPinBiometricEnabled: true,
  sessionEndPinBiometricEnabled: true,
  distressCancelBiometricEnabled: true,
  emergencyCallNumber: '911',
  alarmDndOverride: true,
  alarmGradualVolume: true,
  alarmGradualVolumeDurationSeconds: 12,
  sessionLogRetentionDays: 99,
  trashRetentionDays: 30,
  telemetryOptOut: true,
  sentryEnabled: true,
  lastBackupAt: DateTime.utc(2026, 6, 2),
  defaults: const AppDefaults().copyWith(
    stealth: const StealthConfig(enabled: true, fakeName: 'Notes'),
  ),
);

/// Builds a container with [repo] injected and the controller materialised.
Future<ProviderContainer> _container(_RoundTripRepo repo) async {
  final container = ProviderContainer(
    overrides: <Override>[
      appSettingsRepositoryProvider.overrideWithValue(repo),
    ],
  );
  addTearDown(container.dispose);
  await container.read(settingsSecurityControllerProvider.future);
  return container;
}

void main() {
  group('SettingsSecurityController — distress-cancel biometric (#9)', () {
    test(
      'build() reflects the persisted distressCancelBiometricEnabled flag',
      () async {
        final repo = _RoundTripRepo(
          const AppSettings(distressCancelBiometricEnabled: true),
        );
        final container = ProviderContainer(
          overrides: <Override>[
            appSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        );
        addTearDown(container.dispose);

        final state = await container.read(
          settingsSecurityControllerProvider.future,
        );
        check(state.distressCancelBiometricEnabled).isTrue();
      },
    );

    test(
      'setDistressCancelBiometric(true) persists to the repository',
      () async {
        final repo = _RoundTripRepo();
        final container = ProviderContainer(
          overrides: <Override>[
            appSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        );
        addTearDown(container.dispose);

        // Materialise the controller first.
        await container.read(settingsSecurityControllerProvider.future);
        await container
            .read(settingsSecurityControllerProvider.notifier)
            .setDistressCancelBiometric(true);

        // Persisted to the encrypted singleton …
        check((await repo.load()).distressCancelBiometricEnabled).isTrue();
        // … and surfaced through a rebuilt state.
        final state = await container.read(
          settingsSecurityControllerProvider.future,
        );
        check(state.distressCancelBiometricEnabled).isTrue();
      },
    );

    test(
      'toggling distress-cancel biometric leaves sibling flags untouched',
      () async {
        final repo = _RoundTripRepo(
          const AppSettings(
            sessionEndPinBiometricEnabled: true,
            appPinBiometricEnabled: true,
          ),
        );
        final container = ProviderContainer(
          overrides: <Override>[
            appSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        );
        addTearDown(container.dispose);

        await container.read(settingsSecurityControllerProvider.future);
        await container
            .read(settingsSecurityControllerProvider.notifier)
            .setDistressCancelBiometric(true);

        final saved = await repo.load();
        check(saved.distressCancelBiometricEnabled).isTrue();
        check(saved.sessionEndPinBiometricEnabled).isTrue();
        check(saved.appPinBiometricEnabled).isTrue();
      },
    );
  });

  group('SettingsSecurityController — clearPin', () {
    for (final type in PinType.values) {
      test('clearPin($type) clears exactly that hash and flips only '
          'its flag', () async {
        final repo = _RoundTripRepo(_fullSettings());
        final container = await _container(repo);

        await container
            .read(settingsSecurityControllerProvider.notifier)
            .clearPin(type);

        final saved = await repo.load();
        // Exactly the requested hash is nulled …
        check(
          because: 'app hash nulled iff type==app',
          saved.appPinHash == null,
        ).equals(type == PinType.app);
        check(
          because: 'session-end hash nulled iff type==sessionEnd',
          saved.sessionEndPinHash == null,
        ).equals(type == PinType.sessionEnd);
        check(
          because: 'duress hash nulled iff type==duress',
          saved.duressPinHash == null,
        ).equals(type == PinType.duress);
        // … and the survivors keep their exact values.
        if (type != PinType.app) check(saved.appPinHash).equals('hash-app');
        if (type != PinType.sessionEnd) {
          check(saved.sessionEndPinHash).equals('hash-end');
        }
        if (type != PinType.duress) {
          check(saved.duressPinHash).equals('hash-duress');
        }

        // The rebuilt state reports the same picture to the UI.
        final state = await container.read(
          settingsSecurityControllerProvider.future,
        );
        check(state.appPinSet).equals(type != PinType.app);
        check(state.sessionEndPinSet).equals(type != PinType.sessionEnd);
        check(state.duressPinSet).equals(type != PinType.duress);
      });
    }

    test('clearPin(PinType.app) keeps the duress PIN armed', () async {
      // Safety guard: removing the App PIN must never silently disarm the
      // duress PIN — the user would believe distress protection is still
      // in place when it is not.
      final repo = _RoundTripRepo(_fullSettings());
      final container = await _container(repo);

      await container
          .read(settingsSecurityControllerProvider.notifier)
          .clearPin(PinType.app);

      final saved = await repo.load();
      check(saved.duressPinHash).equals('hash-duress');
      final state = await container.read(
        settingsSecurityControllerProvider.future,
      );
      check(state.duressPinSet).isTrue();
    });

    test('clearPin preserves every non-PIN field verbatim', () async {
      // Regression net for the hand-rolled reconstruction in clearPin: a
      // field added to AppSettings but forgotten there would silently
      // reset to its default on the next PIN removal.
      final repo = _RoundTripRepo(_fullSettings());
      final container = await _container(repo);

      await container
          .read(settingsSecurityControllerProvider.notifier)
          .clearPin(PinType.app);

      final s = await repo.load();
      check(s.themeMode).equals(AppThemeMode.dark);
      check(s.languageCode).equals('de');
      check(s.isFirstLaunch).isFalse();
      check(s.selectedModeId).equals('mode-7');
      check(s.pinTimeoutSeconds).equals(30);
      check(s.wrongPinThreshold).equals(4);
      check(s.deceptivePinDialogEnabled).isFalse();
      check(s.appPinBiometricEnabled).isTrue();
      check(s.sessionEndPinBiometricEnabled).isTrue();
      check(s.distressCancelBiometricEnabled).isTrue();
      check(s.emergencyCallNumber).equals('911');
      check(s.alarmDndOverride).isTrue();
      check(s.alarmGradualVolume).isTrue();
      check(s.alarmGradualVolumeDurationSeconds).equals(12);
      check(s.sessionLogRetentionDays).equals(99);
      check(s.trashRetentionDays).equals(30);
      check(s.telemetryOptOut).isTrue();
      check(s.sentryEnabled).isTrue();
      check(s.lastBackupAt).equals(DateTime.utc(2026, 6, 2));
      check(s.defaults.stealth.enabled).isTrue();
      check(s.defaults.stealth.fakeName).equals('Notes');
    });
  });

  group('SettingsSecurityController — biometric toggles', () {
    test('setAppBiometric persists both directions', () async {
      final repo = _RoundTripRepo();
      final container = await _container(repo);
      final notifier = container.read(
        settingsSecurityControllerProvider.notifier,
      );

      await notifier.setAppBiometric(true);
      check((await repo.load()).appPinBiometricEnabled).isTrue();
      final on = await container.read(
        settingsSecurityControllerProvider.future,
      );
      check(on.appBiometricEnabled).isTrue();

      await notifier.setAppBiometric(false);
      check((await repo.load()).appPinBiometricEnabled).isFalse();
      final off = await container.read(
        settingsSecurityControllerProvider.future,
      );
      check(off.appBiometricEnabled).isFalse();
    });

    test('setSessionEndBiometric persists both directions and leaves '
        'siblings untouched', () async {
      final repo = _RoundTripRepo(
        const AppSettings(
          appPinBiometricEnabled: true,
          distressCancelBiometricEnabled: true,
        ),
      );
      final container = await _container(repo);
      final notifier = container.read(
        settingsSecurityControllerProvider.notifier,
      );

      await notifier.setSessionEndBiometric(true);
      var saved = await repo.load();
      check(saved.sessionEndPinBiometricEnabled).isTrue();
      check(saved.appPinBiometricEnabled).isTrue();
      check(saved.distressCancelBiometricEnabled).isTrue();
      final on = await container.read(
        settingsSecurityControllerProvider.future,
      );
      check(on.sessionEndBiometricEnabled).isTrue();

      await notifier.setSessionEndBiometric(false);
      saved = await repo.load();
      check(saved.sessionEndPinBiometricEnabled).isFalse();
      check(saved.appPinBiometricEnabled).isTrue();
    });
  });

  group('SettingsSecurityController — wrong-PIN threshold', () {
    test('persists both legal bounds (2 and 10)', () async {
      final repo = _RoundTripRepo();
      final container = await _container(repo);
      final notifier = container.read(
        settingsSecurityControllerProvider.notifier,
      );

      await notifier.setWrongPinThreshold(2);
      check((await repo.load()).wrongPinThreshold).equals(2);
      var state = await container.read(
        settingsSecurityControllerProvider.future,
      );
      check(state.wrongPinThreshold).equals(2);

      await notifier.setWrongPinThreshold(10);
      check((await repo.load()).wrongPinThreshold).equals(10);
      state = await container.read(settingsSecurityControllerProvider.future);
      check(state.wrongPinThreshold).equals(10);
    });

    test('rejects out-of-range values and persists nothing', () async {
      // Both failure directions matter: 1 would fire distress on a single
      // typo; a silently clamped 11 would hide a programming error on a
      // safety-critical bound (spec 06 §Duress PIN, G-010).
      final repo = _RoundTripRepo(_fullSettings());
      final container = await _container(repo);
      final notifier = container.read(
        settingsSecurityControllerProvider.notifier,
      );

      await expectLater(
        notifier.setWrongPinThreshold(1),
        throwsA(isA<AssertionError>()),
      );
      check((await repo.load()).wrongPinThreshold).equals(4);

      await expectLater(
        notifier.setWrongPinThreshold(11),
        throwsA(isA<AssertionError>()),
      );
      check((await repo.load()).wrongPinThreshold).equals(4);
    });
  });

  group('SettingsSecurityController — PIN prompt timeout', () {
    test('persists both legal bounds (5 and 120)', () async {
      final repo = _RoundTripRepo();
      final container = await _container(repo);
      final notifier = container.read(
        settingsSecurityControllerProvider.notifier,
      );

      await notifier.setPinTimeout(5);
      check((await repo.load()).pinTimeoutSeconds).equals(5);
      var state = await container.read(
        settingsSecurityControllerProvider.future,
      );
      check(state.pinTimeoutSeconds).equals(5);

      await notifier.setPinTimeout(120);
      check((await repo.load()).pinTimeoutSeconds).equals(120);
      state = await container.read(settingsSecurityControllerProvider.future);
      check(state.pinTimeoutSeconds).equals(120);
    });

    test('rejects out-of-range values and persists nothing', () async {
      final repo = _RoundTripRepo(_fullSettings());
      final container = await _container(repo);
      final notifier = container.read(
        settingsSecurityControllerProvider.notifier,
      );

      await expectLater(
        notifier.setPinTimeout(4),
        throwsA(isA<AssertionError>()),
      );
      check((await repo.load()).pinTimeoutSeconds).equals(30);

      await expectLater(
        notifier.setPinTimeout(121),
        throwsA(isA<AssertionError>()),
      );
      check((await repo.load()).pinTimeoutSeconds).equals(30);
    });
  });

  group('SettingsSecurityController — deceptive dialog (R-42)', () {
    test('setDeceptiveDialog persists both directions', () async {
      final repo = _RoundTripRepo(
        const AppSettings(deceptivePinDialogEnabled: false),
      );
      final container = await _container(repo);
      final notifier = container.read(
        settingsSecurityControllerProvider.notifier,
      );

      await notifier.setDeceptiveDialog(true);
      check((await repo.load()).deceptivePinDialogEnabled).isTrue();
      final on = await container.read(
        settingsSecurityControllerProvider.future,
      );
      check(on.deceptiveDialogEnabled).isTrue();

      await notifier.setDeceptiveDialog(false);
      check((await repo.load()).deceptivePinDialogEnabled).isFalse();
      final off = await container.read(
        settingsSecurityControllerProvider.future,
      );
      check(off.deceptiveDialogEnabled).isFalse();
    });
  });
}
