/// Unit tests for [SettingsController]'s persistence setters.
///
/// Drives the REAL controller against a round-tripping in-memory
/// [AppSettingsRepository], proving each setter persists (not just
/// mutates state) and that the rebuilt state surfaces the new value.
/// The alarm setters are covered by `settings_alarm_section_test.dart`.
///
/// Spec ref: `docs/spec/06-settings.md` (theme, emergency number,
/// redo onboarding).
library;

import 'dart:io';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:test/test.dart';

import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/domain/enums/app_theme_mode.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/services/service_providers.dart';

/// In-memory [AppSettingsRepository] that round-trips through [save]/[load]
/// so a controller setter can be proven to persist.
class _RoundTripRepo extends AppSettingsRepository {
  _RoundTripRepo([AppSettings? initial])
    : _current = initial ?? const AppSettings(),
      super(
        keyProvider: () async =>
            '0102030405060708090a0b0c0d0e0f'
            '101112131415161718191a1b1c1d1e1f20',
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('settings_ctrl_test_'),
      );

  AppSettings _current;

  @override
  Future<AppSettings> load() async => _current;

  @override
  Future<void> save(AppSettings value) async => _current = value;
}

/// Builds a container with [repo] injected and the controller materialised.
Future<ProviderContainer> _container(_RoundTripRepo repo) async {
  final container = ProviderContainer(
    overrides: <Override>[
      appSettingsRepositoryProvider.overrideWithValue(repo),
    ],
  );
  addTearDown(container.dispose);
  await container.read(settingsControllerProvider.future);
  return container;
}

void main() {
  group('SettingsController — emergency call number', () {
    test(
      'setEmergencyCallNumber persists and surfaces the new number',
      () async {
        final repo = _RoundTripRepo();
        final container = await _container(repo);

        await container
            .read(settingsControllerProvider.notifier)
            .setEmergencyCallNumber('999');

        check((await repo.load()).emergencyCallNumber).equals('999');
        final state = await container.read(settingsControllerProvider.future);
        check(state.emergencyCallNumber).equals('999');
      },
    );

    test('setEmergencyCallNumber leaves unrelated fields untouched', () async {
      final repo = _RoundTripRepo(
        const AppSettings(languageCode: 'fr', alarmDndOverride: true),
      );
      final container = await _container(repo);

      await container
          .read(settingsControllerProvider.notifier)
          .setEmergencyCallNumber('17');

      final saved = await repo.load();
      check(saved.languageCode).equals('fr');
      check(saved.alarmDndOverride).isTrue();
    });
  });

  group('SettingsController — theme mode', () {
    test('setThemeMode persists and surfaces both directions', () async {
      final repo = _RoundTripRepo();
      final container = await _container(repo);
      final notifier = container.read(settingsControllerProvider.notifier);

      await notifier.setThemeMode(AppThemeMode.dark);
      check((await repo.load()).themeMode).equals(AppThemeMode.dark);
      var state = await container.read(settingsControllerProvider.future);
      check(state.themeMode).equals(AppThemeMode.dark);

      await notifier.setThemeMode(AppThemeMode.light);
      check((await repo.load()).themeMode).equals(AppThemeMode.light);
      state = await container.read(settingsControllerProvider.future);
      check(state.themeMode).equals(AppThemeMode.light);
    });
  });

  group('SettingsController — redo onboarding', () {
    test(
      'resetOnboarding raises the first-launch flag and keeps the rest',
      () async {
        final repo = _RoundTripRepo(
          const AppSettings(
            isFirstLaunch: false,
            languageCode: 'de',
            emergencyCallNumber: '911',
          ),
        );
        final container = await _container(repo);

        await container
            .read(settingsControllerProvider.notifier)
            .resetOnboarding();

        final saved = await repo.load();
        check(saved.isFirstLaunch).isTrue();
        // Re-running onboarding must not wipe the user's configuration.
        check(saved.languageCode).equals('de');
        check(saved.emergencyCallNumber).equals('911');
      },
    );
  });
}
