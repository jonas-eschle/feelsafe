/// Contacts-feature controller.
///
/// Exposes every saved emergency contact and mediates CRUD on the
/// backing [contactsRepositoryProvider].
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';

/// Async controller exposing the list of emergency contacts.
class ContactsController extends AsyncNotifier<List<EmergencyContact>> {
  @override
  Future<List<EmergencyContact>> build() async {
    final repo = ref.read(contactsRepositoryProvider);
    return repo.getAll();
  }

  /// Upserts [contact] by id and refreshes [state].
  Future<void> save(EmergencyContact contact) async {
    final repo = ref.read(contactsRepositoryProvider);
    await repo.save(contact);
    state = AsyncValue.data(await repo.getAll());
  }

  /// Deletes the contact with [id] and refreshes [state].
  Future<void> delete(String id) async {
    final repo = ref.read(contactsRepositoryProvider);
    await repo.delete(id);
    state = AsyncValue.data(await repo.getAll());
  }

  /// Reorders the list of contacts by moving the item at [oldIndex]
  /// to [newIndex]. Persists the new ordering by rewriting
  /// `sortOrder` across every entry.
  Future<void> reorder(int oldIndex, int newIndex) async {
    final current = state.value ?? const <EmergencyContact>[];
    if (oldIndex < 0 || oldIndex >= current.length) {
      throw RangeError.range(oldIndex, 0, current.length - 1, 'oldIndex');
    }
    final reordered = List<EmergencyContact>.of(current);
    final moved = reordered.removeAt(oldIndex);
    final insertAt = newIndex > oldIndex ? newIndex - 1 : newIndex;
    reordered.insert(insertAt.clamp(0, reordered.length), moved);
    final repo = ref.read(contactsRepositoryProvider);
    final updated = <EmergencyContact>[];
    for (var i = 0; i < reordered.length; i++) {
      final next = reordered[i].copyWith(sortOrder: i);
      await repo.save(next);
      updated.add(next);
    }
    state = AsyncValue.data(updated);
  }

  /// Forces a reload from the repository.
  Future<void> reload() async {
    state = const AsyncValue.loading();
    final repo = ref.read(contactsRepositoryProvider);
    state = AsyncValue.data(await repo.getAll());
  }
}

/// Provider for `ContactsController`.
final AsyncNotifierProvider<ContactsController, List<EmergencyContact>>
    contactsControllerProvider =
    AsyncNotifierProvider<ContactsController, List<EmergencyContact>>(
  ContactsController.new,
);
