/// DAO for the `contacts` table.
library;

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:guardianangela/data/db/app_database.dart';
import 'package:guardianangela/data/db/schema/tables.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';

part 'contacts_dao.g.dart';

/// Data-access object for [EmergencyContact] aggregates.
@DriftAccessor(tables: [ContactsTable])
class ContactsDao extends DatabaseAccessor<AppDatabase>
    with _$ContactsDaoMixin {
  /// Creates a contacts DAO.
  ContactsDao(super.db);

  /// Returns every contact, ordered by `sortOrder` ascending and id
  /// as a tie-breaker.
  Future<List<EmergencyContact>> getAll() async {
    final rows = await (select(contactsTable)
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .get();
    return [for (final row in rows) _decode(row.jsonPayload)];
  }

  /// Returns the contact with [id], or null if none exists.
  Future<EmergencyContact?> getById(String id) async {
    final row = await (select(contactsTable)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;
    return _decode(row.jsonPayload);
  }

  /// Upserts [value] by its `id`. The `sortOrder` column mirrors
  /// `EmergencyContact.sortOrder` so the `getAll()` query can order
  /// without parsing the JSON payload.
  Future<void> save(EmergencyContact value) async {
    await into(contactsTable).insertOnConflictUpdate(
      ContactsTableCompanion.insert(
        id: value.id,
        jsonPayload: jsonEncode(value.toJson()),
        sortOrder: Value(value.sortOrder),
      ),
    );
  }

  /// Deletes the contact with [id]. No-op if it does not exist.
  Future<void> deleteById(String id) async {
    await (delete(contactsTable)..where((t) => t.id.equals(id))).go();
  }

  /// Deletes every row.
  Future<void> deleteAll() async {
    await delete(contactsTable).go();
  }

  EmergencyContact _decode(String payload) =>
      EmergencyContact.fromJson(jsonDecode(payload) as Map<String, Object?>);
}
