/// Placeholder for the session-mode editor.
library;

import 'package:flutter/material.dart';

/// Form for creating or editing a `SessionMode`.
class ModeEditorScreen extends StatelessWidget {
  /// Creates the mode-editor placeholder.
  const ModeEditorScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Edit Mode')),
        body: const Center(
          child: Text('ModeEditorScreen — TODO Phase 12'),
        ),
      );
}
