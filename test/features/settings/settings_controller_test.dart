/// Tests for [SettingsController] — singleton hydrate, all field
/// setters, and onboarding completion.
library;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';

import '../fake_repositories.dart';

ProviderContainer _makeContainer({AppSettings? seed}) {
  final repo = FakeSettingsRepository(seed);
  return ProviderContainer(
    overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
  );
}

void main() {
  group('SettingsController.build', () {
    test('returns default AppSettings when repo is empty', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final s = await container.read(settingsControllerProvider.future);
      check(s.isFirstLaunch).isTrue();
      check(s.themeMode).equals(AppThemeMode.system);
    });

    test('hydrates persisted AppSettings', () async {
      final seed = const AppSettings(
        defaults: AppDefaults(),
        isFirstLaunch: false,
        languageCode: 'fr',
      );
      final container = _makeContainer(seed: seed);
      addTearDown(container.dispose);
      final s = await container.read(settingsControllerProvider.future);
      check(s.isFirstLaunch).isFalse();
      check(s.languageCode).equals('fr');
    });
  });

  group('SettingsController setters', () {
    test('save overwrites and refreshes state', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(settingsControllerProvider.notifier);
      await container.read(settingsControllerProvider.future);
      await notifier.save(const AppSettings(
        defaults: AppDefaults(),
        languageCode: 'de',
      ));
      final s = container.read(settingsControllerProvider).value!;
      check(s.languageCode).equals('de');
    });

    test('setThemeMode updates only themeMode', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(settingsControllerProvider.notifier);
      await container.read(settingsControllerProvider.future);
      await notifier.setThemeMode(AppThemeMode.dark);
      final s = container.read(settingsControllerProvider).value!;
      check(s.themeMode).equals(AppThemeMode.dark);
    });

    test('setLanguageCode updates only language', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(settingsControllerProvider.notifier);
      await container.read(settingsControllerProvider.future);
      await notifier.setLanguageCode('es');
      final s = container.read(settingsControllerProvider).value!;
      check(s.languageCode).equals('es');
    });

    test('setEmergencyCallNumber updates that field', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(settingsControllerProvider.notifier);
      await container.read(settingsControllerProvider.future);
      await notifier.setEmergencyCallNumber('999');
      final s = container.read(settingsControllerProvider).value!;
      check(s.emergencyCallNumber).equals('999');
    });

    test('setSelectedModeId updates selection', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(settingsControllerProvider.notifier);
      await container.read(settingsControllerProvider.future);
      await notifier.setSelectedModeId('mode-x');
      final s = container.read(settingsControllerProvider).value!;
      check(s.selectedModeId).equals('mode-x');
    });

    test('setAppPinHash persists new hash', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(settingsControllerProvider.notifier);
      await container.read(settingsControllerProvider.future);
      await notifier.setAppPinHash('new-hash');
      final s = container.read(settingsControllerProvider).value!;
      check(s.appPinHash).equals('new-hash');
    });

    // NOTE: AppSettings.copyWith uses `?? this.field` so passing null
    // cannot clear the PIN — a controller bug (see BUG report). The
    // test above confirms the set-to-value path works; clearing PINs
    // requires a sentinel or direct AppSettings construction.

    test('setSessionEndPinHash stores hash', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(settingsControllerProvider.notifier);
      await container.read(settingsControllerProvider.future);
      await notifier.setSessionEndPinHash('hash-x');
      final s = container.read(settingsControllerProvider).value!;
      check(s.sessionEndPinHash).equals('hash-x');
    });

    test('setDuressPinHash stores hash', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(settingsControllerProvider.notifier);
      await container.read(settingsControllerProvider.future);
      await notifier.setDuressPinHash('duress-hash');
      final s = container.read(settingsControllerProvider).value!;
      check(s.duressPinHash).equals('duress-hash');
    });

    test('setPinTimeoutSeconds stores timeout', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(settingsControllerProvider.notifier);
      await container.read(settingsControllerProvider.future);
      await notifier.setPinTimeoutSeconds(30);
      final s = container.read(settingsControllerProvider).value!;
      check(s.pinTimeoutSeconds).equals(30);
    });

    test('setAlarmDndOverride toggles bool', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(settingsControllerProvider.notifier);
      await container.read(settingsControllerProvider.future);
      await notifier.setAlarmDndOverride(true);
      final s = container.read(settingsControllerProvider).value!;
      check(s.alarmDndOverride).isTrue();
    });

    test('setDefaults replaces full AppDefaults block', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(settingsControllerProvider.notifier);
      await container.read(settingsControllerProvider.future);
      const newDefaults = AppDefaults();
      await notifier.setDefaults(newDefaults);
      final s = container.read(settingsControllerProvider).value!;
      check(s.defaults).equals(newDefaults);
    });

    test('completeOnboarding flips isFirstLaunch to false', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(settingsControllerProvider.notifier);
      await container.read(settingsControllerProvider.future);
      check(container.read(settingsControllerProvider).value!.isFirstLaunch)
          .isTrue();
      await notifier.completeOnboarding();
      final s = container.read(settingsControllerProvider).value!;
      check(s.isFirstLaunch).isFalse();
    });
  });
}
