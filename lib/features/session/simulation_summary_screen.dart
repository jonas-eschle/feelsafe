/// Placeholder for the simulation-run summary screen.
library;

import 'package:flutter/material.dart';

/// Shown after a simulation run; recaps planned events.
class SimulationSummaryScreen extends StatelessWidget {
  /// Creates the simulation-summary placeholder.
  const SimulationSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Simulation Summary')),
        body: const Center(
          child: Text('SimulationSummaryScreen — TODO Phase 12'),
        ),
      );
}
