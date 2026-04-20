/// Placeholder for the top-level settings screen.
library;

import 'package:flutter/material.dart';

/// Settings hub; links out to Security, Stealth, Defaults etc.
class SettingsScreen extends StatelessWidget {
  /// Creates the settings-screen placeholder.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: const Center(
          child: Text('SettingsScreen — TODO Phase 12'),
        ),
      );
}
