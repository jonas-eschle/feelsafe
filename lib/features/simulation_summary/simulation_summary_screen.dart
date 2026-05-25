import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Shown after a simulation ends.
///
/// Lists the steps that would have fired. Tapping "Done" returns to the
/// home screen. There is no "Start Real Session" button — see spec 04
/// §Simulation Summary.
class SimulationSummaryScreen extends StatelessWidget {
  /// Creates a [SimulationSummaryScreen].
  const SimulationSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.simulationSummaryTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Icon(
                Icons.play_circle_outline,
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.simulationSummaryTitle,
                style: textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(child: Center(child: Text(l10n.simulationSummaryEmpty))),
              FilledButton(
                onPressed: () => context.goNamed(RouteNames.home),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(l10n.simulationSummaryReturn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
