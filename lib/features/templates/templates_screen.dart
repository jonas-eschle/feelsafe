/// Placeholder for the disguised-reminder templates list.
library;

import 'package:flutter/material.dart';

/// Lists every configured reminder template.
class TemplatesScreen extends StatelessWidget {
  /// Creates the templates-list placeholder.
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Templates')),
        body: const Center(
          child: Text('TemplatesScreen — TODO Phase 12'),
        ),
      );
}
