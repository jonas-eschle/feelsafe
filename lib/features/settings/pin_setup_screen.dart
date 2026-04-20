/// Placeholder for the PIN setup flow (one of the three PINs).
library;

import 'package:flutter/material.dart';

/// Create / change a single PIN; reused for App, Session End, and
/// Duress PINs.
class PinSetupScreen extends StatelessWidget {
  /// Creates the PIN-setup placeholder.
  const PinSetupScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('PIN Setup')),
        body: const Center(
          child: Text('PinSetupScreen — TODO Phase 12'),
        ),
      );
}
