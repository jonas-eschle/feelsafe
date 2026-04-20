/// Placeholder for the GPS-logging defaults screen.
library;

import 'package:flutter/material.dart';

/// Edits the global `GpsLoggingConfig` defaults.
class GpsLoggingScreen extends StatelessWidget {
  /// Creates the GPS-logging placeholder.
  const GpsLoggingScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('GPS Logging')),
        body: const Center(
          child: Text('GpsLoggingScreen — TODO Phase 12'),
        ),
      );
}
