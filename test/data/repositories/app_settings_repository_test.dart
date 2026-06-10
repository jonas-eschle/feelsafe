import 'dart:io';

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/data/seed_data.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/app_theme_mode.dart';
import 'package:guardianangela/domain/models/app_defaults.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/event_defaults.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('app_settings_repo_test_');
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  AppSettingsRepository newRepo() => AppSettingsRepository(
    keyProvider: () async =>
        '0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20',
    resolveDir: () async => tempDir,
  );

  group('AppSettingsRepository', () {
    test('load returns seed defaults when no file exists yet', () async {
      // Act
      final loaded = await newRepo().load();
      // Assert — equal to the seeded defaults.
      check(loaded).equals(SeedData.defaultAppSettings());
    });

    test('loadOrNull returns null when no file exists yet', () async {
      check(await newRepo().loadOrNull()).isNull();
    });

    test('round-trips the seed default unchanged', () async {
      // Arrange
      final repo = newRepo();
      final defaults = SeedData.defaultAppSettings();
      // Act
      await repo.save(defaults);
      final loaded = await repo.load();
      // Assert
      check(loaded).equals(defaults);
    });

    test('round-trips a customised settings instance', () async {
      // Arrange
      final repo = newRepo();
      const custom = AppSettings(
        themeMode: AppThemeMode.dark,
        languageCode: 'de',
        isFirstLaunch: false,
        selectedModeId: 'walk',
        appPinHash: 'app-pin-hash',
        sessionEndPinHash: 'end-pin-hash',
        duressPinHash: 'duress-pin-hash',
        pinTimeoutSeconds: 30,
        wrongPinThreshold: 7,
        appPinBiometricEnabled: true,
        sessionEndPinBiometricEnabled: true,
        distressCancelBiometricEnabled: true,
        emergencyCallNumber: '911',
        alarmDndOverride: true,
        alarmGradualVolume: true,
        alarmGradualVolumeDurationSeconds: 12,
        sessionLogRetentionDays: 30,
        sentryEnabled: true,
        defaults: AppDefaults(
          eventDefaults: EventDefaults(
            loudAlarm: LoudAlarmConfig(volume: 0.6, flashLight: false),
          ),
          defaultDistressModeId: SeedData.defaultDistressModeId,
        ),
      );
      // Act
      await repo.save(custom);
      final loaded = await repo.load();
      // Assert
      check(loaded).equals(custom);
    });

    test('delete removes the stored file', () async {
      // Arrange
      final repo = newRepo();
      await repo.save(SeedData.defaultAppSettings());
      check(await repo.loadOrNull()).isNotNull();
      // Act
      await repo.delete();
      // Assert
      check(await repo.loadOrNull()).isNull();
      // load() falls back to seed defaults again.
      check(await repo.load()).equals(SeedData.defaultAppSettings());
    });
  });
}
