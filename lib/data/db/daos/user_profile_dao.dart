/// DAO for the `user_profile` singleton table.
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:guardianangela/data/db/app_database.dart';
import 'package:guardianangela/data/db/schema/tables.dart';
import 'package:guardianangela/domain/models/user_profile.dart';

part 'user_profile_dao.g.dart';

/// Data-access object for the singleton `UserProfile` row.
@DriftAccessor(tables: [UserProfileTable])
class UserProfileDao extends DatabaseAccessor<AppDatabase>
    with _$UserProfileDaoMixin {
  /// Creates a user-profile DAO.
  UserProfileDao(super.db);

  static const String _singletonId = 'singleton';

  /// Returns the stored [UserProfile], or null if none exists.
  Future<UserProfile?> get() async {
    final row =
        await (select(userProfileTable)
              ..where((t) => t.id.equals(_singletonId))
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return null;
    return UserProfile.fromJson(
      jsonDecode(row.jsonPayload) as Map<String, Object?>,
    );
  }

  /// Overwrites the persisted [UserProfile] with [value].
  Future<void> save(UserProfile value) async {
    await into(userProfileTable).insertOnConflictUpdate(
      UserProfileTableCompanion.insert(
        id: const Value(_singletonId),
        jsonPayload: jsonEncode(value.toJson()),
      ),
    );
  }

  /// Deletes the singleton row.
  Future<void> clear() async {
    await (delete(
      userProfileTable,
    )..where((t) => t.id.equals(_singletonId))).go();
  }
}
