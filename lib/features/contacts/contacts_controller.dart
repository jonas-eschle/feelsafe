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

  /// Reorders the contact list by moving the row at [oldIndex] to
  /// [newIndex] (`ReorderableListView` semantics) and persisting the
  /// new `sortOrder` of every contact.
  Future<void> reorder(int oldIndex, int newIndex) async {
    final current = state.value;
    if (current == null) return;
    final list = List<EmergencyContact>.from(current.contacts);
    // ReorderableListView passes a newIndex that includes the moved row,
    // so adjust when moving downward (spec-driven semantics).
    final adjusted = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final moved = list.removeAt(oldIndex);
    list.insert(adjusted, moved);
    // Rewrite sortOrder values so they reflect the new positions.
    final reorderedList = <EmergencyContact>[
      for (int i = 0; i < list.length; i++) list[i].copyWith(sortOrder: i),
    ];
    final db = await ref.read(databaseProvider.future);
    final repo = ContactsRepository(db.contactsDao);
    await repo.bulkUpdate(reorderedList);
    state = AsyncData(ContactsState(contacts: reorderedList));
  }

  /// Removes every contact and refreshes the list.
  Future<void> deleteAll() async {
    final db = await ref.read(databaseProvider.future);
    final repo = ContactsRepository(db.contactsDao);
    await repo.deleteAll();
    state = const AsyncData(ContactsState(contacts: <EmergencyContact>[]));
  }
}

/// Provides [ContactsController].
final contactsControllerProvider =
    AsyncNotifierProvider<ContactsController, ContactsState>(
      ContactsController.new,
    );
