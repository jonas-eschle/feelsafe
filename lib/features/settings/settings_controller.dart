/// Settings-feature controller.
///
/// The `AppSettings` singleton is loaded once from the settings
/// repository on first build. Every mutator awaits that load so a
/// user action fired before the async hydrate completes cannot race
/// with and clobber freshly-loaded state (L7 mitigation).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';

/// Async controller exposing the singleton `AppSettings`.
///
/// `build()` returns the persisted settings (or the default
/// `AppSettings` when no row exists yet). Mutators persist through
/// [settingsRepositoryProvider] and then mirror the change into
/// [state].
class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    final stored = await repo.get();
    return stored ?? const AppSettings(defaults: AppDefaults());
  }

  /// Overwrites the current settings with [value] and persists it.
  Future<void> save(AppSettings value) async {
    // Await the pending hydrate so `state.value` reflects the most
    // recent persisted settings before this mutation runs.
    await future;
    final repo = ref.read(settingsRepositoryProvider);
    await repo.save(value);
    state = AsyncValue.data(value);
  }

  /// Updates just the theme mode.
  Future<void> setThemeMode(AppThemeMode mode) async {
    final current = await future;
    await save(current.copyWith(themeMode: mode));
  }

  /// Updates just the language code.
  Future<void> setLanguageCode(String code) async {
    final current = await future;
    await save(current.copyWith(languageCode: code));
  }

  /// Updates just the emergency-call number.
  Future<void> setEmergencyCallNumber(String number) async {
    final current = await future;
    await save(current.copyWith(emergencyCallNumber: number));
  }

  /// Updates just the selected mode id.
  Future<void> setSelectedModeId(String? modeId) async {
    final current = await future;
    await save(current.copyWith(selectedModeId: modeId));
  }

  /// Updates the app-unlock PIN hash (null disables the lock).
  Future<void> setAppPinHash(String? hash) async {
    final current = await future;
    await save(
      hash == null
          ? current.copyWith(clearAppPinHash: true)
          : current.copyWith(appPinHash: hash),
    );
  }

  /// Updates the session-end PIN hash (null disables the lock).
  Future<void> setSessionEndPinHash(String? hash) async {
    final current = await future;
    await save(
      hash == null
          ? current.copyWith(clearSessionEndPinHash: true)
          : current.copyWith(sessionEndPinHash: hash),
    );
  }

  /// Updates the duress PIN hash (null disables the lock).
  Future<void> setDuressPinHash(String? hash) async {
    final current = await future;
    await save(
      hash == null
          ? current.copyWith(clearDuressPinHash: true)
          : current.copyWith(duressPinHash: hash),
    );
  }

  /// Updates the PIN-entry lockout timeout in seconds.
  Future<void> setPinTimeoutSeconds(int seconds) async {
    final current = await future;
    await save(current.copyWith(pinTimeoutSeconds: seconds));
  }

  /// Updates the alarm DND override flag.
  Future<void> setAlarmDndOverride(bool enabled) async {
    final current = await future;
    await save(current.copyWith(alarmDndOverride: enabled));
  }

  /// Replaces the `AppDefaults` block (GPS logging, stealth,
  /// templates, event defaults).
  Future<void> setDefaults(AppDefaults defaults) async {
    final current = await future;
    await save(current.copyWith(defaults: defaults));
  }

  /// Marks onboarding complete (`isFirstLaunch = false`).
  Future<void> completeOnboarding() async {
    final current = await future;
    await save(current.copyWith(isFirstLaunch: false));
  }
}

/// Provider for `SettingsController`.
final AsyncNotifierProvider<SettingsController, AppSettings>
settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, AppSettings>(
      SettingsController.new,
    );
