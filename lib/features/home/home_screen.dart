/// Placeholder for the home landing screen.
///
/// Phase 12 will replace this with the real start-session UI.
library;

import 'package:flutter/material.dart';

/// Landing screen; shown to returning users.
class HomeScreen extends StatelessWidget {
  /// Creates the home-screen placeholder.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Home')),
        body: const Center(
          child: Text('HomeScreen — TODO Phase 12'),
        ),
      );
}
