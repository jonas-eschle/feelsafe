/// Placeholder for the create / edit contact form.
library;

import 'package:flutter/material.dart';

/// Form for creating or editing a single emergency contact.
class ContactFormScreen extends StatelessWidget {
  /// Creates the contact-form placeholder.
  const ContactFormScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Edit Contact')),
        body: const Center(
          child: Text('ContactFormScreen — TODO Phase 12'),
        ),
      );
}
