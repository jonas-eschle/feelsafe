/// Placeholder for the About / credits screen.
library;

import 'package:flutter/material.dart';

/// Shows version, legal info, and credits.
class AboutScreen extends StatelessWidget {
  /// Creates the about-screen placeholder.
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('About')),
        body: const Center(
          child: Text('AboutScreen — TODO Phase 12'),
        ),
      );
}
