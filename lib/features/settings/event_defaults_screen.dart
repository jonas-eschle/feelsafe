/// Placeholder for the per-step-type event defaults screen.
library;

import 'package:flutter/material.dart';

/// Edits the global `EventDefaults` for every chain-step type.
class EventDefaultsScreen extends StatelessWidget {
  /// Creates the event-defaults placeholder.
  const EventDefaultsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Event Defaults')),
        body: const Center(
          child: Text('EventDefaultsScreen — TODO Phase 12'),
        ),
      );
}
