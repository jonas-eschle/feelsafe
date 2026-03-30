import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:safewayhome/data/models/app_settings.dart';
import 'package:safewayhome/data/models/fake_call_config.dart';
import 'package:safewayhome/data/repositories/settings_repository.dart';

void main() {
  late Directory tempDir;
  late SettingsRepository repository;

  setUpAll(() {
    Hive.registerAdapter(AppSettingsAdapter());
    Hive.registerAdapter(FakeCallConfigAdapter());
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('settings_repo_test_');
    Hive.init(tempDir.path);
    repository = SettingsRepository();
  });

  tearDown(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  group('SettingsRepository — AppSettings', () {
    test('getSettings returns defaults when nothing saved', () async {
      final settings = await repository.getSettings();

      expect(settings.isDarkTheme, isTrue);
      expect(settings.languageCode, 'en');
      expect(settings.isFirstLaunch, isTrue);
      expect(settings.selectedModeId, isNull);
      expect(settings.emergencyNumber, '112');
    });

    test('saveSettings and getSettings roundtrip', () async {
      final settings = AppSettings(
        isDarkTheme: false,
        languageCode: 'de',
        isFirstLaunch: false,
        selectedModeId: 'walk_mode',
        emergencyNumber: '911',
      );

      await repository.saveSettings(settings);
      final loaded = await repository.getSettings();

      expect(loaded.isDarkTheme, isFalse);
      expect(loaded.languageCode, 'de');
      expect(loaded.isFirstLaunch, isFalse);
      expect(loaded.selectedModeId, 'walk_mode');
      expect(loaded.emergencyNumber, '911');
    });

    test('saveSettings overwrites previous settings', () async {
      await repository.saveSettings(AppSettings(languageCode: 'de'));
      await repository.saveSettings(AppSettings(languageCode: 'ru'));

      final loaded = await repository.getSettings();
      expect(loaded.languageCode, 'ru');
    });

    test('preserves nullable selectedModeId when null', () async {
      final settings = AppSettings(selectedModeId: null);
      await repository.saveSettings(settings);

      final loaded = await repository.getSettings();
      expect(loaded.selectedModeId, isNull);
    });

    test('preserves nullable selectedModeId when set', () async {
      final settings = AppSettings(selectedModeId: 'date_mode');
      await repository.saveSettings(settings);

      final loaded = await repository.getSettings();
      expect(loaded.selectedModeId, 'date_mode');
    });
  });

  group('SettingsRepository — FakeCallConfig', () {
    test('getFakeCallConfig returns defaults when nothing saved', () async {
      final config = await repository.getFakeCallConfig();

      expect(config.callerName, 'Mom');
      expect(config.photoPath, isNull);
      expect(config.voiceRecordingPath, isNull);
      expect(config.ringDurationSeconds, 30);
    });

    test('saveFakeCallConfig and getFakeCallConfig roundtrip', () async {
      final config = FakeCallConfig(
        callerName: 'Dad',
        photoPath: '/path/to/photo.jpg',
        voiceRecordingPath: '/path/to/voice.m4a',
        ringDurationSeconds: 15,
      );

      await repository.saveFakeCallConfig(config);
      final loaded = await repository.getFakeCallConfig();

      expect(loaded.callerName, 'Dad');
      expect(loaded.photoPath, '/path/to/photo.jpg');
      expect(loaded.voiceRecordingPath, '/path/to/voice.m4a');
      expect(loaded.ringDurationSeconds, 15);
    });

    test('saveFakeCallConfig overwrites previous config', () async {
      await repository.saveFakeCallConfig(
        FakeCallConfig(callerName: 'Mom'),
      );
      await repository.saveFakeCallConfig(
        FakeCallConfig(callerName: 'Dad'),
      );

      final loaded = await repository.getFakeCallConfig();
      expect(loaded.callerName, 'Dad');
    });

    test('preserves null photo and voice paths', () async {
      final config = FakeCallConfig(
        callerName: 'Test',
        photoPath: null,
        voiceRecordingPath: null,
      );

      await repository.saveFakeCallConfig(config);
      final loaded = await repository.getFakeCallConfig();

      expect(loaded.photoPath, isNull);
      expect(loaded.voiceRecordingPath, isNull);
    });
  });
}
