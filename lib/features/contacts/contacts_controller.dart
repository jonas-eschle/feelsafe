/// Contacts-feature controller stub.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/domain/models/models.dart';

/// Stub AsyncNotifier exposing the list of emergency contacts.
class ContactsController extends AsyncNotifier<List<EmergencyContact>> {
  @override
  Future<List<EmergencyContact>> build() async => const <EmergencyContact>[];
}

/// Provider for `ContactsController`.
final AsyncNotifierProvider<ContactsController, List<EmergencyContact>>
    contactsControllerProvider =
    AsyncNotifierProvider<ContactsController, List<EmergencyContact>>(
  ContactsController.new,
);
