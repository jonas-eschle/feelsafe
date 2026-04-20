/// Placeholder for the fake incoming-call overlay.
library;

import 'package:flutter/material.dart';

/// Simulated incoming call; presents a safety pretext to the user.
class FakeCallScreen extends StatelessWidget {
  /// Creates the fake-call placeholder.
  const FakeCallScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Incoming Call')),
        body: const Center(
          child: Text('FakeCallScreen — TODO Phase 12'),
        ),
      );
}
