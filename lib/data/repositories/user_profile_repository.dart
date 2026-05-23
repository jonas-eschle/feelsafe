import 'dart:math';

import 'package:guardianangela/data/repositories/json_singleton_repository.dart';
import 'package:guardianangela/data/seed_data.dart';
import 'package:guardianangela/domain/models/user_profile.dart';

/// JSON-backed singleton repository for [UserProfile].
///
/// Lazy default: when the on-disk file is missing,
/// [SeedData.defaultUserProfile] (empty profile) is returned.
class UserProfileRepository {
  /// Creates a [UserProfileRepository] backed by `user_profile.json`.
  UserProfileRepository({
    required KeyProvider keyProvider,
    DirectoryResolver? resolveDir,
    Random? random,
  }) : _store = JsonSingletonRepository<UserProfile>(
         fileName: 'user_profile.json',
         fromJson: UserProfile.fromJson,
         toJson: (p) => p.toJson(),
         keyProvider: keyProvider,
         resolveDir: resolveDir,
         random: random,
       );

  final JsonSingletonRepository<UserProfile> _store;

  /// Loads the stored profile, or an empty [UserProfile] if no file
  /// exists yet.
  Future<UserProfile> load() async =>
      await _store.load() ?? SeedData.defaultUserProfile();

  /// Returns the stored value verbatim, or null if no file exists.
  Future<UserProfile?> loadOrNull() => _store.load();

  /// Encrypts and writes [value] to disk.
  Future<void> save(UserProfile value) => _store.save(value);

  /// Deletes the on-disk file. No-op if missing.
  Future<void> delete() => _store.delete();
}
