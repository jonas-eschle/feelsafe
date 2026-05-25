import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import 'package:guardianangela/data/repositories/contacts_repository.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Immutable state for the contacts list.
@immutable
class ContactsState {
  /// Creates a [ContactsState].
  const ContactsState({required this.contacts});

  /// All emergency contacts in display order.
  final List<EmergencyContact> contacts;
}

/// Controller for the contacts list screen.
class ContactsController extends AsyncNotifier<ContactsState> {
  @override
  Future<ContactsState> build() async {
    final db = await ref.watch(databaseProvider.future);
    final repo = ContactsRepository(db.contactsDao);
    final all = await repo.getAll();
    return ContactsState(contacts: all);
  }

  /// Deletes [id] and refreshes the list.
  Future<void> delete(String id) async {
    final db = await ref.read(databaseProvider.future);
    final repo = ContactsRepository(db.contactsDao);
    await repo.deleteById(id);
    ref.invalidateSelf();
  }
}

/// Provides [ContactsController].
final contactsControllerProvider =
    AsyncNotifierProvider<ContactsController, ContactsState>(
      ContactsController.new,
    );
