/// CRUD repository for [EmergencyContact] aggregates, backed by
/// Drift.
library;

import 'package:meta/meta.dart';

import 'package:guardianangela/data/db/daos/contacts_dao.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';

/// Repository for `EmergencyContact` aggregates.
class ContactsRepository {
  /// Creates a contacts repository backed by [dao].
  ContactsRepository(ContactsDao dao) : _dao = dao;

  /// Test-only constructor; subclasses must override every method.
  @visibleForTesting
  ContactsRepository.forTesting() : _dao = null;

  final ContactsDao? _dao;

  /// Returns every saved emergency contact, sorted by
  /// `EmergencyContact.sortOrder` ascending.
  Future<List<EmergencyContact>> getAll() => _dao!.getAll();

  /// Returns the contact with [id], or null if not found.
  Future<EmergencyContact?> getById(String id) => _dao!.getById(id);

  /// Upserts [value] by its `id`.
  Future<void> save(EmergencyContact value) => _dao!.save(value);

  /// Deletes the contact with [id].
  Future<void> delete(String id) => _dao!.deleteById(id);

  /// Deletes every persisted contact.
  Future<void> deleteAll() => _dao!.deleteAll();
}
