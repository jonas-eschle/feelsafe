/// Settings-feature controller stub.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardianangela/domain/models/models.dart';

/// Stub AsyncNotifier exposing the single `AppSettings` document.
///
/// The initial default value is the compiled-in `AppSettings()`;
/// Phase 5 will hydrate this from the settings repository.
class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async =>
      const AppSettings(defaults: AppDefaults());
}

/// Provider for `SettingsController`.
final AsyncNotifierProvider<SettingsController, AppSettings>
    settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);
