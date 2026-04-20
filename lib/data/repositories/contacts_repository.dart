/// CRUD repository for [EmergencyContact] aggregates. Phase 6 fills
/// the bodies against Drift; until then every method throws
/// [UnimplementedError].
library;

import 'package:guardianangela/domain/models/emergency_contact.dart';

/// Repository for `EmergencyContact` aggregates.
final class ContactsRepository {
  /// Creates a contacts repository.
  ContactsRepository();

  /// Returns every saved emergency contact.
  Future<List<EmergencyContact>> getAll() async =>
      throw UnimplementedError('TODO: Phase 6 fills this in');

  /// Returns the contact with [id], or null if not found.
  Future<EmergencyContact?> getById(String id) async =>
      throw UnimplementedError('TODO: Phase 6 fills this in');

  /// Upserts [value] by its `id`.
  Future<void> save(EmergencyContact value) async =>
      throw UnimplementedError('TODO: Phase 6 fills this in');

  /// Deletes the contact with [id].
  Future<void> delete(String id) async =>
      throw UnimplementedError('TODO: Phase 6 fills this in');
}
