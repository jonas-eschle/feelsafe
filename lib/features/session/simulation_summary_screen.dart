/// Simulation-run summary screen.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Shown after a simulation run.
class SimulationSummaryScreen extends ConsumerWidget {
  /// Creates the simulation-summary screen.
  const SimulationSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider).value;
    final fired = session?.firedStepDescriptions ?? const <String>[];
    return Scaffold(
      appBar: AppBar(title: Text(l.simulationSummaryTitle)),
      body: fired.isEmpty
          ? Center(child: Text(l.simulationSummaryEmpty))
          : ListView.builder(
              itemCount: fired.length,
              itemBuilder: (context, i) => ListTile(
                leading: CircleAvatar(child: Text('${i + 1}')),
                title: Text(fired[i]),
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: () => context.go(RouteNames.home),
          child: Text(l.simulationSummaryReturn),
        ),
      ),
    );
  }
}
