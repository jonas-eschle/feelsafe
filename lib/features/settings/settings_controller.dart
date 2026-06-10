import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import 'package:guardianangela/domain/enums/app_theme_mode.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/main.dart';
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
    required this.alarmDndOverride,
    required this.alarmGradualVolume,
    required this.alarmGradualVolumeDurationSeconds,
  });

  /// Selected theme mode.
  final AppThemeMode themeMode;

  /// Selected language code (BCP 47).
  final String languageCode;

  /// Whether stealth mode is currently enabled.
  final bool stealthEnabled;

  /// Active emergency-call number (default `'112'`).
  final String emergencyCallNumber;

  /// Whether loud-alarm steps may override silent / Do Not Disturb.
  ///
  /// Mirrors [AppSettings.alarmDndOverride] (default `false`, opt-in).
  final bool alarmDndOverride;

  /// Whether the alarm volume ramps from zero to the configured level.
  ///
  /// Mirrors [AppSettings.alarmGradualVolume] (default `false`). Acts as
  /// the app-wide master gate; a loudAlarm step ramps only when this and
  /// the step's `LoudAlarmConfig.gradualVolume` are both on.
  final bool alarmGradualVolume;

  /// Ramp duration in seconds when [alarmGradualVolume] is on.
  ///
  /// Mirrors [AppSettings.alarmGradualVolumeDurationSeconds] (default 5,
  /// range 1–60).
  final int alarmGradualVolumeDurationSeconds;
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
      alarmDndOverride: settings.alarmDndOverride,
      alarmGradualVolume: settings.alarmGradualVolume,
      alarmGradualVolumeDurationSeconds:
          settings.alarmGradualVolumeDurationSeconds,
    );
  }

  /// Updates the emergency-call number and persists.
  Future<void> setEmergencyCallNumber(String number) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    final settings = await repo.load();
    await repo.save(settings.copyWith(emergencyCallNumber: number));
    ref.invalidateSelf();
  }

  /// Toggles whether loud-alarm steps may override silent / DND and
  /// persists. Spec 06 §Alarm — Override Silent Mode / Do Not Disturb.
  Future<void> setAlarmDndOverride(bool enabled) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    final settings = await repo.load();
    await repo.save(settings.copyWith(alarmDndOverride: enabled));
    ref.invalidateSelf();
  }

  /// Toggles the app-wide gradual-volume master and persists. Spec 06
  /// §Alarm — Gradual Volume Increase (Q33).
  Future<void> setAlarmGradualVolume(bool enabled) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    final settings = await repo.load();
    await repo.save(settings.copyWith(alarmGradualVolume: enabled));
    ref.invalidateSelf();
  }

  /// Updates the alarm ramp duration (seconds) and persists. Spec 06
  /// §Alarm — Gradual Volume Duration. Value is clamped to the valid
  /// 1–60s range before saving (the model asserts this range).
  Future<void> setAlarmGradualVolumeDurationSeconds(int seconds) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    final settings = await repo.load();
    await repo.save(
      settings.copyWith(
        alarmGradualVolumeDurationSeconds: seconds.clamp(1, 60),
      ),
    );
    ref.invalidateSelf();
  }

  /// Updates the theme mode and persists.
  Future<void> setThemeMode(AppThemeMode mode) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    final settings = await repo.load();
    await repo.save(settings.copyWith(themeMode: mode));
    // The root MaterialApp's themeMode is driven by the keep-alive
    // [appSettingsLiveProvider]; without this re-read the picked theme
    // would not apply until the next cold start.
    ref.invalidate(appSettingsLiveProvider);
    ref.invalidateSelf();
  }

  /// Updates the language code and persists.
  Future<void> setLanguage(String code) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    final settings = await repo.load();
    await repo.save(settings.copyWith(languageCode: code));
    // The root MaterialApp's locale is driven by the keep-alive
    // [appSettingsLiveProvider]; without this re-read the picked language
    // would not apply until the next cold start.
    ref.invalidate(appSettingsLiveProvider);
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
