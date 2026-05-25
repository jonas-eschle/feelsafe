import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import 'package:guardianangela/services/service_providers.dart';

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
    );
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
