import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/app_settings.dart';
import '../../data/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider((_) => SettingsRepository());

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

/// Convenience providers for reactive reads.
final isDarkThemeProvider = Provider<AsyncValue<bool>>((ref) {
  return ref.watch(settingsControllerProvider).whenData((s) => s.isDarkTheme);
});

final languageCodeProvider = Provider<AsyncValue<String>>((ref) {
  return ref.watch(settingsControllerProvider).whenData((s) => s.languageCode);
});

class SettingsController extends AsyncNotifier<AppSettings> {
  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  @override
  Future<AppSettings> build() => _repo.getSettings();

  Future<void> toggleTheme() async {
    final current = await future;
    final updated = current.copyWith(isDarkTheme: !current.isDarkTheme);
    await _repo.saveSettings(updated);
    state = AsyncData(updated);
  }

  Future<void> setLanguage(String code) async {
    final current = await future;
    final updated = current.copyWith(languageCode: code);
    await _repo.saveSettings(updated);
    state = AsyncData(updated);
  }

  Future<void> setEmergencyNumber(String number) async {
    final current = await future;
    final updated = current.copyWith(emergencyNumber: number);
    await _repo.saveSettings(updated);
    state = AsyncData(updated);
  }

  Future<void> setSelectedModeId(String? modeId) async {
    final current = await future;
    final updated = current.copyWith(selectedModeId: modeId);
    await _repo.saveSettings(updated);
    state = AsyncData(updated);
  }

  Future<void> markOnboardingComplete() async {
    final current = await future;
    final updated = current.copyWith(isFirstLaunch: false);
    await _repo.saveSettings(updated);
    state = AsyncData(updated);
  }
}
