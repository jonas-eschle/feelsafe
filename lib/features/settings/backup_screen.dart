/// Placeholder for the backup (import / export) screen.
library;

import 'package:flutter/material.dart';

/// Exports or imports a full app backup.
class BackupScreen extends StatelessWidget {
  /// Creates the backup-screen placeholder.
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Backup')),
        body: const Center(
          child: Text('BackupScreen — TODO Phase 12'),
        ),
      );
}
