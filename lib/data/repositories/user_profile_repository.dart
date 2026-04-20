/// Singleton repository for [UserProfile]. Phase 6 fills the bodies
/// against Drift; until then every method throws
/// [UnimplementedError].
library;

import 'package:guardianangela/domain/models/user_profile.dart';

/// Singleton repository for the user profile.
final class UserProfileRepository {
  /// Creates a user-profile repository.
  UserProfileRepository();

  /// Returns the saved [UserProfile], or null if none exists yet.
  Future<UserProfile?> get() async =>
      throw UnimplementedError('TODO: Phase 6 fills this in');

  /// Overwrites the persisted [UserProfile] with [value].
  Future<void> save(UserProfile value) async =>
      throw UnimplementedError('TODO: Phase 6 fills this in');
}
