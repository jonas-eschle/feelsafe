import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Identifies one of the three PIN types managed in the security
/// submenu.
enum PinType {
  /// App-lock PIN.
  app,

  /// Session-end PIN.
  sessionEnd,

  /// Duress PIN.
  duress,
}

/// Immutable state for the security submenu.
@immutable
class SettingsSecurityState {
  /// Creates a [SettingsSecurityState].
  const SettingsSecurityState({
    required this.appPinSet,
    required this.sessionEndPinSet,
    required this.duressPinSet,
    required this.pinTimeoutSeconds,
    required this.wrongPinThreshold,
    required this.deceptiveDialogEnabled,
    required this.sessionEndBiometricEnabled,
  });

  /// Whether an App PIN is configured.
  final bool appPinSet;

  /// Whether a Session End PIN is configured.
  final bool sessionEndPinSet;

  /// Whether a Duress PIN is configured.
  final bool duressPinSet;

  /// PIN-prompt timeout in seconds (5–120).
  final int pinTimeoutSeconds;

  /// Wrong-PIN threshold before distress (2–10).
  final int wrongPinThreshold;

  /// Whether the deceptive "Old PIN entered" dialog is enabled.
  final bool deceptiveDialogEnabled;

  /// Whether biometric is allowed to substitute for the Session End PIN.
  final bool sessionEndBiometricEnabled;
}

/// Controller for the security submenu.
class SettingsSecurityController extends AsyncNotifier<SettingsSecurityState> {
  @override
  Future<SettingsSecurityState> build() async {
    final settings = await ref.read(appSettingsRepositoryProvider).load();
    return SettingsSecurityState(
      appPinSet: settings.appPinHash != null,
      sessionEndPinSet: settings.sessionEndPinHash != null,
      duressPinSet: settings.duressPinHash != null,
      pinTimeoutSeconds: settings.pinTimeoutSeconds,
      wrongPinThreshold: settings.wrongPinThreshold,
      deceptiveDialogEnabled: settings.deceptivePinDialogEnabled,
      sessionEndBiometricEnabled: settings.sessionEndPinBiometricEnabled,
    );
  }

  /// Clears the stored hash for [type] (UI "Off" action).
  ///
  /// `AppSettings.copyWith` uses null-coalescing, so it cannot clear a
  /// nullable field. We reconstruct the settings via [AppSettings]'s
  /// constructor with the relevant hash explicitly omitted.
  Future<void> clearPin(PinType type) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    final s = await repo.load();
    final next = AppSettings(
      themeMode: s.themeMode,
      languageCode: s.languageCode,
      isFirstLaunch: s.isFirstLaunch,
      selectedModeId: s.selectedModeId,
      appPinHash: type == PinType.app ? null : s.appPinHash,
      sessionEndPinHash:
          type == PinType.sessionEnd ? null : s.sessionEndPinHash,
      duressPinHash: type == PinType.duress ? null : s.duressPinHash,
      pinTimeoutSeconds: s.pinTimeoutSeconds,
      wrongPinThreshold: s.wrongPinThreshold,
      deceptivePinDialogEnabled: s.deceptivePinDialogEnabled,
      appPinBiometricEnabled: s.appPinBiometricEnabled,
      sessionEndPinBiometricEnabled: s.sessionEndPinBiometricEnabled,
      distressCancelBiometricEnabled: s.distressCancelBiometricEnabled,
      requireLaunchAuth: s.requireLaunchAuth,
      launchAuthBiometric: s.launchAuthBiometric,
      emergencyCallNumber: s.emergencyCallNumber,
      alarmDndOverride: s.alarmDndOverride,
      alarmGradualVolume: s.alarmGradualVolume,
      alarmGradualVolumeDurationSeconds: s.alarmGradualVolumeDurationSeconds,
      sessionLogRetentionDays: s.sessionLogRetentionDays,
      trashRetentionDays: s.trashRetentionDays,
      telemetryOptOut: s.telemetryOptOut,
      sentryEnabled: s.sentryEnabled,
      defaults: s.defaults,
    );
    await repo.save(next);
    ref.invalidateSelf();
  }

  /// Toggles the biometric substitute for the Session End PIN.
  Future<void> setSessionEndBiometric(bool enabled) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    final settings = await repo.load();
    await repo.save(
      settings.copyWith(sessionEndPinBiometricEnabled: enabled),
    );
    ref.invalidateSelf();
  }

  /// Updates [wrongPinThreshold].
  Future<void> setWrongPinThreshold(int v) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    final settings = await repo.load();
    await repo.save(settings.copyWith(wrongPinThreshold: v));
    ref.invalidateSelf();
  }

  /// Updates the PIN prompt timeout.
  Future<void> setPinTimeout(int seconds) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    final settings = await repo.load();
    await repo.save(settings.copyWith(pinTimeoutSeconds: seconds));
    ref.invalidateSelf();
  }

  /// Toggles the deceptive dialog (R-42).
  Future<void> setDeceptiveDialog(bool enabled) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    final settings = await repo.load();
    await repo.save(settings.copyWith(deceptivePinDialogEnabled: enabled));
    ref.invalidateSelf();
  }
}

/// Provides [SettingsSecurityController].
final settingsSecurityControllerProvider =
    AsyncNotifierProvider<SettingsSecurityController, SettingsSecurityState>(
      SettingsSecurityController.new,
    );
