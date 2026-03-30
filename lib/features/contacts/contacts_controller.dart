import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/emergency_contact.dart';
import '../../data/repositories/contacts_repository.dart';

final contactsRepositoryProvider = Provider<ContactsRepository>((ref) {
  return ContactsRepository();
});

final contactsControllerProvider =
    AsyncNotifierProvider<ContactsController, List<EmergencyContact>>(
  ContactsController.new,
);

class ContactsController extends AsyncNotifier<List<EmergencyContact>> {
  static const _uuid = Uuid();

  ContactsRepository get _repository => ref.read(contactsRepositoryProvider);

  @override
  Future<List<EmergencyContact>> build() => _repository.getAll();

  Future<void> addContact({
    required String name,
    required String phoneNumber,
    String? relationship,
    MessageChannel preferredChannel = MessageChannel.sms,
  }) async {
    final contacts = await future;
    final contact = EmergencyContact(
      id: _uuid.v4(),
      name: name,
      phoneNumber: phoneNumber,
      relationship: relationship,
      sortOrder: contacts.length,
      preferredChannel: preferredChannel,
    );
    await _repository.save(contact);
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateContact({
    required String id,
    required String name,
    required String phoneNumber,
    String? relationship,
    required MessageChannel preferredChannel,
  }) async {
    final existing = await _repository.getById(id);
    if (existing == null) {
      throw StateError('Contact with id $id not found');
    }
    final updated = existing.copyWith(
      name: name,
      phoneNumber: phoneNumber,
      relationship: relationship,
      preferredChannel: preferredChannel,
    );
    await _repository.save(updated);
    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteContact(String id) async {
    await _repository.delete(id);
    ref.invalidateSelf();
    await future;
  }

  Future<void> reorderContacts(int oldIndex, int newIndex) async {
    final contacts = List<EmergencyContact>.of(await future);
    if (newIndex > oldIndex) newIndex--;
    final item = contacts.removeAt(oldIndex);
    contacts.insert(newIndex, item);
    for (var i = 0; i < contacts.length; i++) {
      contacts[i].sortOrder = i;
      await _repository.save(contacts[i]);
    }
    ref.invalidateSelf();
    await future;
  }
}
