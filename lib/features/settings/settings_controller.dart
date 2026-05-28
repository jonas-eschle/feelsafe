import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import 'package:guardianangela/domain/enums/app_theme_mode.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Immutable state for the settings hub.
@immutable
class SettingsHubState {
  /// Creates a [SettingsHubState].
  const SettingsHubState({
    required this.themeMode,
    required this.languageCode,
    required this.stealthEnabled,
    required this.emergencyCallNumber,
  });

  /// Selected theme mode.
  final AppThemeMode themeMode;

  /// Selected language code (BCP 47).
  final String languageCode;

  /// Whether stealth mode is currently enabled.
  final bool stealthEnabled;

  /// Active emergency-call number (default `'112'`).
  final String emergencyCallNumber;
}

/// Controller for the settings hub.
class SettingsController extends AsyncNotifier<SettingsHubState> {
  @override
  Future<SettingsHubState> build() async {
    final settings = await ref.read(appSettingsRepositoryProvider).load();
    return SettingsHubState(
      themeMode: settings.themeMode,
      languageCode: settings.languageCode,
      stealthEnabled: settings.defaults.stealth.enabled,
      emergencyCallNumber: settings.emergencyCallNumber,
    );
  }

  /// Updates the emergency-call number and persists.
  Future<void> setEmergencyCallNumber(String number) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    final settings = await repo.load();
    await repo.save(settings.copyWith(emergencyCallNumber: number));
    ref.invalidateSelf();
  }

  /// Updates the theme mode and persists.
  Future<void> setThemeMode(AppThemeMode mode) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    final settings = await repo.load();
    await repo.save(settings.copyWith(themeMode: mode));
    ref.invalidateSelf();
  }

  /// Updates the language code and persists.
  Future<void> setLanguage(String code) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    final settings = await repo.load();
    await repo.save(settings.copyWith(languageCode: code));
    ref.invalidateSelf();
  }

  /// Resets the first-launch flag so the user is routed to onboarding.
  Future<void> resetOnboarding() async {
    final repo = ref.read(appSettingsRepositoryProvider);
    final settings = await repo.load();
    await repo.save(settings.copyWith(isFirstLaunch: true));
    ref.invalidateSelf();
  }
}

/// Provides [SettingsController].
final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, SettingsHubState>(
      SettingsController.new,
    );
