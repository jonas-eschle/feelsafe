/// Placeholder for the active safety session screen.
library;

import 'package:flutter/material.dart';

/// Shown while a safety session is running.
class SessionScreen extends StatelessWidget {
  /// Creates the session placeholder.
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Session')),
        body: const Center(
          child: Text('SessionScreen — TODO Phase 12'),
        ),
      );
}
