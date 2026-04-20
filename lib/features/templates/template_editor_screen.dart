/// Placeholder for the reminder-template editor.
library;

import 'package:flutter/material.dart';

/// Form for creating or editing a `ReminderTemplate`.
class TemplateEditorScreen extends StatelessWidget {
  /// Creates the template-editor placeholder.
  const TemplateEditorScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Edit Template')),
        body: const Center(
          child: Text('TemplateEditorScreen — TODO Phase 12'),
        ),
      );
}
