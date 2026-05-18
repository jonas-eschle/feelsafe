/// Singleton repository for [UserProfile], backed by Drift.
library;

import 'package:meta/meta.dart';

import 'package:guardianangela/data/db/daos/user_profile_dao.dart';
import 'package:guardianangela/domain/models/user_profile.dart';

/// Singleton repository for the user profile.
class UserProfileRepository {
  /// Creates a user-profile repository backed by [dao].
  UserProfileRepository(UserProfileDao dao) : _dao = dao;

  /// Test-only constructor; subclasses must override every method.
  @visibleForTesting
  UserProfileRepository.forTesting() : _dao = null;

  final UserProfileDao? _dao;

  /// Returns the saved [UserProfile], or null if none exists yet.
  Future<UserProfile?> get() => _dao!.get();

  /// Overwrites the persisted [UserProfile] with [value].
  Future<void> save(UserProfile value) => _dao!.save(value);
}
