/// Extended coverage tests for [SettingsController].
///
/// Covers the session-locked error paths and the biometric setter
/// methods that are not exercised in settings_controller_test.dart.
library;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import 'package:guardianangela/core/utils/session_locked_error.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';

import '../fake_repositories.dart';

// ---------------------------------------------------------------------------
// Fake SessionController that returns isSessionActive == true or false
// ---------------------------------------------------------------------------

class _ActiveSessionController extends SessionController {
  @override
  Future<WalkSession?> build() async => WalkSession(
    id: 'active',
    modeId: 'mode',
    isSimulation: false,
    startedAt: DateTime.utc(2025),
    phase: const SessionPhaseActive(),
    currentStepIndex: 0,
  );

  @override
  bool get isSessionActive => true;
}

class _NoSessionController extends SessionController {
  @override
  Future<WalkSession?> build() async => null;

  @override
  bool get isSessionActive => false;
}

// ---------------------------------------------------------------------------
// Helper: build a ProviderContainer with optional session-active fake
// ---------------------------------------------------------------------------

ProviderContainer _makeContainer({
  AppSettings? seed,
  bool sessionActive = false,
}) {
  final repo = FakeSettingsRepository(seed);
  return ProviderContainer(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(repo),
      if (sessionActive)
        sessionControllerProvider.overrideWith(() => _ActiveSessionController())
      else
        sessionControllerProvider.overrideWith(() => _NoSessionController()),
    ],
  );
}

void main() {
  // -------------------------------------------------------------------------
  // setAppPinHash — clear path
  // -------------------------------------------------------------------------

  group('SettingsController.setAppPinHash', () {
    test('null hash clears existing appPinHash', () async {
      final container = _makeContainer(
        seed: const AppSettings(defaults: AppDefaults(), appPinHash: 'existing'),
      );
      addTearDown(container.dispose);
      final notifier = container.read(settingsControllerProvider.notifier);
      await container.read(settingsControllerProvider.future);
      await notifier.setAppPinHash(null);
      final s = container.read(settingsControllerProvider).value!;
      check(s.appPinHash).isNull();
    });

    test('non-null hash replaces appPinHash', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(settingsControllerProvider.notifier);
      await container.read(settingsControllerProvider.future);
      await notifier.setAppPinHash('new-hash');
      final s = container.read(settingsControllerProvider).value!;
      check(s.appPinHash).equals('new-hash');
    });

    test('throws SessionLockedError when session is active', () async {
      final container = _makeContainer(sessionActive: true);
      addTearDown(container.dispose);
      await container.read(settingsControllerProvider.future);
      final notifier = container.read(settingsControllerProvider.notifier);
      await check(
        notifier.setAppPinHash('x'),
      ).throws<SessionLockedError>();
    });
  });

  // -------------------------------------------------------------------------
  // setSessionEndPinHash — clear path + session lock
  // -------------------------------------------------------------------------

  group('SettingsController.setSessionEndPinHash', () {
    test('null hash clears existing sessionEndPinHash', () async {
      final container = _makeContainer(
        seed: const AppSettings(
          defaults: AppDefaults(),
          sessionEndPinHash: 'old',
        ),
      );
      addTearDown(container.dispose);
      final notifier = container.read(settingsControllerProvider.notifier);
      await container.read(settingsControllerProvider.future);
      await notifier.setSessionEndPinHash(null);
      final s = container.read(settingsControllerProvider).value!;
      check(s.sessionEndPinHash).isNull();
    });

    test('throws SessionLockedError when session is active', () async {
      final container = _makeContainer(sessionActive: true);
      addTearDown(container.dispose);
      await container.read(settingsControllerProvider.future);
      final notifier = container.read(settingsControllerProvider.notifier);
      await check(
        notifier.setSessionEndPinHash('x'),
      ).throws<SessionLockedError>();
    });
  });

  // -------------------------------------------------------------------------
  // setDuressPinHash — clear path + session lock
  // -------------------------------------------------------------------------

  group('SettingsController.setDuressPinHash', () {
    test('null hash clears existing duressPinHash', () async {
      final container = _makeContainer(
        seed: const AppSettings(
          defaults: AppDefaults(),
          duressPinHash: 'duress-old',
        ),
      );
      addTearDown(container.dispose);
      final notifier = container.read(settingsControllerProvider.notifier);
      await container.read(settingsControllerProvider.future);
      await notifier.setDuressPinHash(null);
      final s = container.read(settingsControllerProvider).value!;
      check(s.duressPinHash).isNull();
    });

    test('non-null hash sets duressPinHash', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(settingsControllerProvider.notifier);
      await container.read(settingsControllerProvider.future);
      await notifier.setDuressPinHash('new-duress');
      final s = container.read(settingsControllerProvider).value!;
      check(s.duressPinHash).equals('new-duress');
    });

    test('throws SessionLockedError when session is active', () async {
      final container = _makeContainer(sessionActive: true);
      addTearDown(container.dispose);
      await container.read(settingsControllerProvider.future);
      final notifier = container.read(settingsControllerProvider.notifier);
      await check(
        notifier.setDuressPinHash('x'),
      ).throws<SessionLockedError>();
    });
  });

  // -------------------------------------------------------------------------
  // Biometric setters
  // -------------------------------------------------------------------------

  group('SettingsController biometric setters', () {
    test('setAppPinBiometricEnabled persists true', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(settingsControllerProvider.notifier);
      await container.read(settingsControllerProvider.future);
      await notifier.setAppPinBiometricEnabled(true);
      final s = container.read(settingsControllerProvider).value!;
      check(s.appPinBiometricEnabled).isTrue();
    });

    test('setAppPinBiometricEnabled persists false', () async {
      final container = _makeContainer(
        seed: const AppSettings(
          defaults: AppDefaults(),
          appPinBiometricEnabled: true,
        ),
      );
      addTearDown(container.dispose);
      final notifier = container.read(settingsControllerProvider.notifier);
      await container.read(settingsControllerProvider.future);
      await notifier.setAppPinBiometricEnabled(false);
      final s = container.read(settingsControllerProvider).value!;
      check(s.appPinBiometricEnabled).isFalse();
    });

    test('setAppPinBiometricEnabled throws when session active', () async {
      final container = _makeContainer(sessionActive: true);
      addTearDown(container.dispose);
      await container.read(settingsControllerProvider.future);
      final notifier = container.read(settingsControllerProvider.notifier);
      await check(
        notifier.setAppPinBiometricEnabled(true),
      ).throws<SessionLockedError>();
    });

    test('setSessionEndPinBiometricEnabled persists true', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(settingsControllerProvider.notifier);
      await container.read(settingsControllerProvider.future);
      await notifier.setSessionEndPinBiometricEnabled(true);
      final s = container.read(settingsControllerProvider).value!;
      check(s.sessionEndPinBiometricEnabled).isTrue();
    });

    test('setSessionEndPinBiometricEnabled persists false', () async {
      final container = _makeContainer(
        seed: const AppSettings(
          defaults: AppDefaults(),
          sessionEndPinBiometricEnabled: true,
        ),
      );
      addTearDown(container.dispose);
      final notifier = container.read(settingsControllerProvider.notifier);
      await container.read(settingsControllerProvider.future);
      await notifier.setSessionEndPinBiometricEnabled(false);
      final s = container.read(settingsControllerProvider).value!;
      check(s.sessionEndPinBiometricEnabled).isFalse();
    });

    test('setSessionEndPinBiometricEnabled throws when session active', () async {
      final container = _makeContainer(sessionActive: true);
      addTearDown(container.dispose);
      await container.read(settingsControllerProvider.future);
      final notifier = container.read(settingsControllerProvider.notifier);
      await check(
        notifier.setSessionEndPinBiometricEnabled(true),
      ).throws<SessionLockedError>();
    });

    test('setDistressCancelBiometricEnabled persists true', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(settingsControllerProvider.notifier);
      await container.read(settingsControllerProvider.future);
      await notifier.setDistressCancelBiometricEnabled(true);
      final s = container.read(settingsControllerProvider).value!;
      check(s.distressCancelBiometricEnabled).isTrue();
    });

    test('setDistressCancelBiometricEnabled persists false', () async {
      final container = _makeContainer(
        seed: const AppSettings(
          defaults: AppDefaults(),
          distressCancelBiometricEnabled: true,
        ),
      );
      addTearDown(container.dispose);
      final notifier = container.read(settingsControllerProvider.notifier);
      await container.read(settingsControllerProvider.future);
      await notifier.setDistressCancelBiometricEnabled(false);
      final s = container.read(settingsControllerProvider).value!;
      check(s.distressCancelBiometricEnabled).isFalse();
    });

    test('setDistressCancelBiometricEnabled throws when session active', () async {
      final container = _makeContainer(sessionActive: true);
      addTearDown(container.dispose);
      await container.read(settingsControllerProvider.future);
      final notifier = container.read(settingsControllerProvider.notifier);
      await check(
        notifier.setDistressCancelBiometricEnabled(true),
      ).throws<SessionLockedError>();
    });
  });

  // -------------------------------------------------------------------------
  // Session-lock guard on the remaining setters
  // -------------------------------------------------------------------------

  group('SettingsController session-lock guards', () {
    test('save throws SessionLockedError when session is active', () async {
      final container = _makeContainer(sessionActive: true);
      addTearDown(container.dispose);
      await container.read(settingsControllerProvider.future);
      final notifier = container.read(settingsControllerProvider.notifier);
      await check(
        notifier.save(const AppSettings(defaults: AppDefaults())),
      ).throws<SessionLockedError>();
    });

    test('setThemeMode throws SessionLockedError when session is active', () async {
      final container = _makeContainer(sessionActive: true);
      addTearDown(container.dispose);
      await container.read(settingsControllerProvider.future);
      final notifier = container.read(settingsControllerProvider.notifier);
      await check(
        notifier.setThemeMode(AppThemeMode.dark),
      ).throws<SessionLockedError>();
    });

    test('setLanguageCode throws SessionLockedError when session is active',
        () async {
      final container = _makeContainer(sessionActive: true);
      addTearDown(container.dispose);
      await container.read(settingsControllerProvider.future);
      final notifier = container.read(settingsControllerProvider.notifier);
      await check(
        notifier.setLanguageCode('de'),
      ).throws<SessionLockedError>();
    });

    test('setEmergencyCallNumber throws SessionLockedError when session active',
        () async {
      final container = _makeContainer(sessionActive: true);
      addTearDown(container.dispose);
      await container.read(settingsControllerProvider.future);
      final notifier = container.read(settingsControllerProvider.notifier);
      await check(
        notifier.setEmergencyCallNumber('911'),
      ).throws<SessionLockedError>();
    });

    test('setPinTimeoutSeconds throws SessionLockedError when session active',
        () async {
      final container = _makeContainer(sessionActive: true);
      addTearDown(container.dispose);
      await container.read(settingsControllerProvider.future);
      final notifier = container.read(settingsControllerProvider.notifier);
      await check(
        notifier.setPinTimeoutSeconds(30),
      ).throws<SessionLockedError>();
    });

    test('setAlarmDndOverride throws SessionLockedError when session active',
        () async {
      final container = _makeContainer(sessionActive: true);
      addTearDown(container.dispose);
      await container.read(settingsControllerProvider.future);
      final notifier = container.read(settingsControllerProvider.notifier);
      await check(
        notifier.setAlarmDndOverride(true),
      ).throws<SessionLockedError>();
    });

    test('setDefaults throws SessionLockedError when session active', () async {
      final container = _makeContainer(sessionActive: true);
      addTearDown(container.dispose);
      await container.read(settingsControllerProvider.future);
      final notifier = container.read(settingsControllerProvider.notifier);
      await check(
        notifier.setDefaults(const AppDefaults()),
      ).throws<SessionLockedError>();
    });

    // setSelectedModeId is the one setter allowed during a session:
    test('setSelectedModeId does NOT throw when session is active', () async {
      final container = _makeContainer(sessionActive: true);
      addTearDown(container.dispose);
      await container.read(settingsControllerProvider.future);
      final notifier = container.read(settingsControllerProvider.notifier);
      // Must complete without throwing.
      await notifier.setSelectedModeId('some-mode');
      final s = container.read(settingsControllerProvider).value!;
      check(s.selectedModeId).equals('some-mode');
    });
  });
}
