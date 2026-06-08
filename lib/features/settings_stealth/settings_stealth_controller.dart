import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import 'package:guardianangela/domain/enums/stealth_icon_preset.dart';
import 'package:guardianangela/domain/enums/stealth_timer_display.dart';
import 'package:guardianangela/domain/models/stealth_config.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Immutable state for the stealth settings screen.
@immutable
class SettingsStealthState {
  /// Creates a [SettingsStealthState].
  const SettingsStealthState({required this.config});

  /// Current global stealth configuration.
  final StealthConfig config;
}

/// Controller for the stealth settings screen.
class SettingsStealthController extends AsyncNotifier<SettingsStealthState> {
  @override
  Future<SettingsStealthState> build() async {
    final settings = await ref.read(appSettingsRepositoryProvider).load();
    return SettingsStealthState(config: settings.defaults.stealth);
  }

  Future<void> _saveStealth(StealthConfig stealth) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    final settings = await repo.load();
    final updated = settings.copyWith(
      defaults: settings.defaults.copyWith(stealth: stealth),
    );
    await repo.save(updated);
    await _applyLauncherIcon(stealth);
    ref.invalidateSelf();
  }

  /// Applies the launcher-icon disguise for the saved global [stealth] config.
  ///
  /// The home-screen icon is a persistent concealment (needed whenever stealth
  /// is enabled, including between sessions), so it is driven from the global
  /// `AppDefaults.stealth` at config-save time — NOT at session start like
  /// lock-task mode. When stealth is on the chosen [StealthConfig.fakeIcon]
  /// preset is applied; when off (or `none`) the real Guardian Angela icon is
  /// restored.
  ///
  /// The native alias swap can kill the process (Android `DONT_KILL_APP`
  /// is a best-effort mitigation, not a guarantee), so the swap is suppressed
  /// while a session is active: stealth settings are immutable during a session
  /// (the config still persists; only the icon flip is deferred). A future save
  /// made with no session running reconciles the launcher to the latest config.
  Future<void> _applyLauncherIcon(StealthConfig stealth) async {
    final sessionActive = ref
        .read(sessionControllerProvider.notifier)
        .isSessionActive;
    if (sessionActive) return;

    final preset = stealth.enabled ? stealth.fakeIcon : StealthIconPreset.none;
    await ref.read(systemUiServiceProvider).setStealthIcon(preset);
  }

  /// Toggle the master stealth flag.
  Future<void> setEnabled(bool v) async {
    final current = state.value;
    if (current == null) return;
    await _saveStealth(current.config.copyWith(enabled: v));
  }

  /// Update the fake app name.
  Future<void> setFakeName(String name) async {
    final current = state.value;
    if (current == null) return;
    await _saveStealth(current.config.copyWith(fakeName: name));
  }

  /// Toggle notification disguise.
  Future<void> setNotificationDisguise(bool v) async {
    final current = state.value;
    if (current == null) return;
    await _saveStealth(current.config.copyWith(notificationDisguise: v));
  }

  /// Toggle session-screen stealth.
  Future<void> setSessionScreenStealth(bool v) async {
    final current = state.value;
    if (current == null) return;
    await _saveStealth(current.config.copyWith(sessionScreenStealth: v));
  }

  /// Update the timer display option.
  Future<void> setTimerDisplay(StealthTimerDisplay d) async {
    final current = state.value;
    if (current == null) return;
    await _saveStealth(current.config.copyWith(timerDisplay: d));
  }

  /// Update the fake-icon preset.
  Future<void> setFakeIcon(StealthIconPreset preset) async {
    final current = state.value;
    if (current == null) return;
    await _saveStealth(current.config.copyWith(fakeIcon: preset));
  }

  /// Toggle lock-task / pinned-app mode.
  ///
  /// The actual platform engagement (calling
  /// `systemUiServiceProvider.toggleLockTaskMode(...)`) is performed by
  /// the session controller when a session starts; this method only
  /// persists the user's preference.
  Future<void> setLockTaskMode(bool v) async {
    final current = state.value;
    if (current == null) return;
    await _saveStealth(current.config.copyWith(lockTaskMode: v));
  }
}

/// Provides [SettingsStealthController].
final settingsStealthControllerProvider =
    AsyncNotifierProvider<SettingsStealthController, SettingsStealthState>(
      SettingsStealthController.new,
    );
