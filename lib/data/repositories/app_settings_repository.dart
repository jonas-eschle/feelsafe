import 'dart:math';

import 'package:guardianangela/data/repositories/json_singleton_repository.dart';
import 'package:guardianangela/data/seed_data.dart';
import 'package:guardianangela/domain/models/app_settings.dart';

/// JSON-backed singleton repository for [AppSettings].
///
/// Lazy default: when the on-disk file is missing,
/// [SeedData.defaultAppSettings] is returned.
class AppSettingsRepository {
  /// Creates an [AppSettingsRepository] backed by `app_settings.json`.
  ///
  /// [keyProvider] is the same `flutter_secure_storage`-backed callback
  /// used by [GuardianAngelaDatabase] (Phase 5 wiring). [resolveDir]
  /// defaults to `<app-documents>/json_store`; tests override it. The
  /// optional [random] argument lets tests substitute a deterministic
  /// nonce source for the AES-GCM envelope.
  AppSettingsRepository({
    required KeyProvider keyProvider,
    DirectoryResolver? resolveDir,
    Random? random,
  }) : _store = JsonSingletonRepository<AppSettings>(
         fileName: 'app_settings.json',
         fromJson: AppSettings.fromJson,
         toJson: (s) => s.toJson(),
         keyProvider: keyProvider,
         resolveDir: resolveDir,
         random: random,
       );

  final JsonSingletonRepository<AppSettings> _store;

  /// Loads the stored [AppSettings], or [SeedData.defaultAppSettings] if
  /// no file exists yet.
  Future<AppSettings> load() async =>
      await _store.load() ?? SeedData.defaultAppSettings();

  /// Returns the stored value verbatim, or null if no file exists. Used
  /// by tests that want to distinguish "first launch" from
  /// "seeded defaults".
  Future<AppSettings?> loadOrNull() => _store.load();

  /// Encrypts and writes [value] to disk.
  Future<void> save(AppSettings value) => _store.save(value);

  /// Deletes the on-disk file. No-op if missing.
  Future<void> delete() => _store.delete();
}
