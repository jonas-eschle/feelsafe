import 'package:hive/hive.dart';
import '../models/app_settings.dart';
import '../models/fake_call_config.dart';

class SettingsRepository {
  static const _settingsBoxName = 'settings';
  static const _settingsKey = 'app_settings';
  static const _fakeCallBoxName = 'fake_call_config';
  static const _fakeCallKey = 'fake_call';

  Future<Box<AppSettings>> get _settingsBox =>
      Hive.openBox<AppSettings>(_settingsBoxName);

  Future<Box<FakeCallConfig>> get _fakeCallBox =>
      Hive.openBox<FakeCallConfig>(_fakeCallBoxName);

  Future<AppSettings> getSettings() async {
    final box = await _settingsBox;
    return box.get(_settingsKey) ?? AppSettings();
  }

  Future<void> saveSettings(AppSettings settings) async {
    final box = await _settingsBox;
    await box.put(_settingsKey, settings);
  }

  Future<FakeCallConfig> getFakeCallConfig() async {
    final box = await _fakeCallBox;
    return box.get(_fakeCallKey) ?? FakeCallConfig();
  }

  Future<void> saveFakeCallConfig(FakeCallConfig config) async {
    final box = await _fakeCallBox;
    await box.put(_fakeCallKey, config);
  }
}
