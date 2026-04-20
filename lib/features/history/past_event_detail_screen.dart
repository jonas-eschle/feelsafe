/// Placeholder for a single past-session detail screen.
library;

import 'package:flutter/material.dart';

/// Displays the full event log for one past session.
class PastEventDetailScreen extends StatelessWidget {
  /// Creates the past-event-detail placeholder.
  const PastEventDetailScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Event Detail')),
        body: const Center(
          child: Text('PastEventDetailScreen — TODO Phase 12'),
        ),
      );
}
