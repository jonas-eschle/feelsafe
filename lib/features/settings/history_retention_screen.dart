/// Placeholder for the session-history retention-policy screen.
library;

import 'package:flutter/material.dart';

/// Configures how long past sessions are retained locally.
class HistoryRetentionScreen extends StatelessWidget {
  /// Creates the history-retention placeholder.
  const HistoryRetentionScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('History Retention')),
        body: const Center(
          child: Text('HistoryRetentionScreen — TODO Phase 12'),
        ),
      );
}
