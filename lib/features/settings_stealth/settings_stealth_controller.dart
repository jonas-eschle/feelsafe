import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import 'package:guardianangela/domain/enums/stealth_timer_display.dart';
import 'package:guardianangela/domain/models/stealth_config.dart';
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
    ref.invalidateSelf();
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
}

/// Provides [SettingsStealthController].
final settingsStealthControllerProvider =
    AsyncNotifierProvider<SettingsStealthController, SettingsStealthState>(
      SettingsStealthController.new,
    );
