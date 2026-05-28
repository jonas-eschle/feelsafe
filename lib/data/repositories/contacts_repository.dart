import 'package:guardianangela/data/db/dao/contacts_dao.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';

/// Repository for [EmergencyContact] persistence.
///
/// Thin wrapper over [ContactsDao] that exposes the domain-level API used
/// by [ContactService] (Phase 5B.1). All reads and writes are delegated
/// to the DAO; this class owns the transaction boundary if future batch
/// operations are needed.
class ContactsRepository {
  /// Creates a [ContactsRepository] backed by [dao].
  ContactsRepository(this._dao);

  final ContactsDao _dao;

  /// Returns all contacts ordered by [EmergencyContact.sortOrder] ascending.
  Future<List<EmergencyContact>> getAll() => _dao.getAll();

  /// Returns the contact with [id], or `null` if not found.
  Future<EmergencyContact?> getById(String id) => _dao.getById(id);

  /// Inserts or replaces [contact].
  Future<void> upsert(EmergencyContact contact) => _dao.upsert(contact);

  /// Deletes the contact with [id]. No-op if not found.
  Future<void> deleteById(String id) => _dao.deleteById(id);

  /// Streams all contacts (re-emitting on every change).
  Stream<List<EmergencyContact>> watchAll() => _dao.watchAll();

  /// Replaces every contact in [contacts] in a single transaction.
  ///
  /// Used by [ContactsController.reorder] to commit a new ordering
  /// without N round-trips.
  Future<void> bulkUpdate(List<EmergencyContact> contacts) =>
      _dao.bulkUpdate(contacts);

  /// Removes every contact (used by the "Delete all" overflow menu).
  Future<void> deleteAll() => _dao.deleteAll();
}
