/// Placeholder for the evidence-export screen.
library;

import 'package:flutter/material.dart';

/// Exports a session log as shareable text / JSON.
class EvidenceExportScreen extends StatelessWidget {
  /// Creates the evidence-export placeholder.
  const EvidenceExportScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Evidence Export')),
        body: const Center(
          child: Text('EvidenceExportScreen — TODO Phase 12'),
        ),
      );
}
