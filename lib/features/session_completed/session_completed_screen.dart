import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Shown after a session completes normally.
///
/// Renders the duration row, the simulation banner (when applicable),
/// and the two CTAs. Suppressed entirely in stealth mode (spec 04
/// §Chain Exhausted Screen — stealth path silently routes home).
class SessionCompletedScreen extends StatelessWidget {
  /// Creates a [SessionCompletedScreen].
  ///
  /// [logId] is the session log id used by the "View Event Log" CTA
  /// when navigating to the per-session detail screen. When null the
  /// CTA falls back to the past-events list.
  const SessionCompletedScreen({
    super.key,
    this.durationSeconds,
    this.logId,
    this.isSimulation = false,
  });

  /// Total duration of the completed session in seconds.
  final int? durationSeconds;

  /// Session log id passed via the `?id=` route parameter.
  final String? logId;

  /// Whether the completed session was a simulation.
  final bool isSimulation;

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (isSimulation)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(
                        Icons.play_circle_outline,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.sessionCompletedSimulationBanner,
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              Icon(
                Icons.check_circle,
                size: 96,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(l10n.sessionCompletedTitle, style: textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                l10n.sessionCompletedBody,
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              if (durationSeconds != null) ...<Widget>[
                const SizedBox(height: 16),
                Text(
                  _formatDuration(durationSeconds!),
                  style: textTheme.titleMedium,
                ),
              ],
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => context.goNamed(RouteNames.home),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(l10n.sessionCompletedReturnHome),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  final id = logId;
                  if (id != null && id.isNotEmpty) {
                    context.pushNamed(
                      RouteNames.pastEventDetail,
                      queryParameters: <String, String>{'id': id},
                    );
                  } else {
                    context.pushNamed(RouteNames.pastEvents);
                  }
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(l10n.sessionCompletedViewEventLog),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
