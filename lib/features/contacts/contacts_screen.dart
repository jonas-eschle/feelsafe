/// Placeholder for the emergency contacts list.
library;

import 'package:flutter/material.dart';

/// Lists every configured emergency contact.
class ContactsScreen extends StatelessWidget {
  /// Creates the contacts-list placeholder.
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Contacts')),
        body: const Center(
          child: Text('ContactsScreen — TODO Phase 12'),
        ),
      );
}
