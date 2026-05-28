import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/db/tables/contacts_table.dart';
import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';

part 'contacts_dao.g.dart';

/// DAO for the [Contacts] table.
///
/// Provides CRUD and a watch stream for [EmergencyContact] rows. Channel
/// lists are stored as JSON strings of `MessageChannel.name` values.
@DriftAccessor(tables: [Contacts])
class ContactsDao extends DatabaseAccessor<GuardianAngelaDatabase>
    with _$ContactsDaoMixin {
  /// Creates a DAO bound to [db].
  ContactsDao(super.db);

  /// Returns all contacts ordered by [EmergencyContact.sortOrder] ascending.
  Future<List<EmergencyContact>> getAll() async {
    final rows = await (select(
      contacts,
    )..orderBy([(c) => OrderingTerm.asc(c.sortOrder)])).get();
    return rows.map(_rowToModel).toList();
  }

  /// Returns the contact with [id], or null if not found.
  Future<EmergencyContact?> getById(String id) async {
    final row = await (select(
      contacts,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
    return row == null ? null : _rowToModel(row);
  }

  /// Inserts or replaces [contact] (upsert keyed by [EmergencyContact.id]).
  Future<void> upsert(EmergencyContact contact) async {
    await into(contacts).insertOnConflictUpdate(_modelToCompanion(contact));
  }

  /// Deletes the contact with [id]. No-op if not found.
  Future<void> deleteById(String id) async {
    await (delete(contacts)..where((c) => c.id.equals(id))).go();
  }

  /// Streams all contacts (re-emitting on every change), ordered by
  /// [EmergencyContact.sortOrder] ascending.
  Stream<List<EmergencyContact>> watchAll() {
    final query = select(contacts)
      ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]);
    return query.watch().map((rows) => rows.map(_rowToModel).toList());
  }

  /// Replaces every contact in [items] inside a single transaction.
  ///
  /// Useful for batch operations such as reordering.
  Future<void> bulkUpdate(List<EmergencyContact> items) =>
      transaction(() async {
        for (final c in items) {
          await into(contacts).insertOnConflictUpdate(_modelToCompanion(c));
        }
      });

  /// Removes every contact row.
  Future<void> deleteAll() => delete(contacts).go();

  static EmergencyContact _rowToModel(ContactRow row) => EmergencyContact(
    id: row.id,
    name: row.name,
    phoneNumber: row.phoneNumber,
    relationship: row.relationship,
    sortOrder: row.sortOrder,
    channels: _decodeChannels(row.channelsJson),
    languageCode: row.languageCode,
  );

  static ContactsCompanion _modelToCompanion(EmergencyContact c) =>
      ContactsCompanion(
        id: Value(c.id),
        name: Value(c.name),
        phoneNumber: Value(c.phoneNumber),
        relationship: Value(c.relationship),
        sortOrder: Value(c.sortOrder),
        channelsJson: Value(_encodeChannels(c.channels)),
        languageCode: Value(c.languageCode),
      );

  static String _encodeChannels(List<MessageChannel> channels) =>
      jsonEncode(channels.map((c) => c.name).toList());

  static List<MessageChannel> _decodeChannels(String json) {
    final decoded = jsonDecode(json) as List<dynamic>;
    return decoded
        .map((e) => MessageChannel.values.byName(e as String))
        .toList();
  }
}
