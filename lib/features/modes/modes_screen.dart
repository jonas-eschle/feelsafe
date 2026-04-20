/// Placeholder for the session-modes list.
library;

import 'package:flutter/material.dart';

/// Lists every configured session mode.
class ModesScreen extends StatelessWidget {
  /// Creates the modes-list placeholder.
  const ModesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Modes')),
        body: const Center(
          child: Text('ModesScreen — TODO Phase 12'),
        ),
      );
}
