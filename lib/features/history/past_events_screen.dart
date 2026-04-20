/// Placeholder for the past-sessions list.
library;

import 'package:flutter/material.dart';

/// Lists every persisted `SessionLog`.
class PastEventsScreen extends StatelessWidget {
  /// Creates the past-events-list placeholder.
  const PastEventsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Past Events')),
        body: const Center(
          child: Text('PastEventsScreen — TODO Phase 12'),
        ),
      );
}
