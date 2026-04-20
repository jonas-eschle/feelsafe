/// Singleton repository for [AppSettings]. Phase 6 fills the bodies
/// against Drift; until then every method throws
/// [UnimplementedError].
library;

import 'package:guardianangela/domain/models/app_settings.dart';

/// Singleton repository for app-wide settings.
final class SettingsRepository {
  /// Creates a settings repository.
  SettingsRepository();

  /// Returns the current [AppSettings], or null if none is stored
  /// yet (first launch).
  Future<AppSettings?> get() async =>
      throw UnimplementedError('TODO: Phase 6 fills this in');

  /// Overwrites the persisted [AppSettings] with [value].
  Future<void> save(AppSettings value) async =>
      throw UnimplementedError('TODO: Phase 6 fills this in');
}
