/// Placeholder for the security settings (three PINs) submenu.
library;

import 'package:flutter/material.dart';

/// Groups the App PIN, Session End PIN, and Duress PIN controls.
class SecurityScreen extends StatelessWidget {
  /// Creates the security-screen placeholder.
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Security')),
        body: const Center(
          child: Text('SecurityScreen — TODO Phase 12'),
        ),
      );
}
