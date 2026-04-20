/// Placeholder for the post-session success screen.
library;

import 'package:flutter/material.dart';

/// Shown after a session ends normally.
class SessionCompletedScreen extends StatelessWidget {
  /// Creates the session-completed placeholder.
  const SessionCompletedScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Session Completed')),
        body: const Center(
          child: Text('SessionCompletedScreen — TODO Phase 12'),
        ),
      );
}
