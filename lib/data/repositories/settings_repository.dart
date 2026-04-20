/// Singleton repository for [AppSettings], backed by Drift.
library;

import 'package:meta/meta.dart';

import 'package:guardianangela/data/db/daos/settings_dao.dart';
import 'package:guardianangela/domain/models/app_settings.dart';

/// Singleton repository for app-wide settings.
class SettingsRepository {
  /// Creates a settings repository backed by [dao].
  SettingsRepository(SettingsDao dao) : _dao = dao;

  /// Test-only constructor; subclasses must override every method.
  @visibleForTesting
  SettingsRepository.forTesting() : _dao = null;

  final SettingsDao? _dao;

  /// Returns the current [AppSettings], or null if none is stored
  /// yet (first launch before seeding).
  Future<AppSettings?> get() => _dao!.get();

  /// Overwrites the persisted [AppSettings] with [value].
  Future<void> save(AppSettings value) => _dao!.save(value);
}
