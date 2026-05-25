import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Shown after a session completes normally.
///
/// Suppressed entirely in stealth mode (spec 04 §Chain Exhausted —
/// stealth path silently routes home).
class SessionCompletedScreen extends StatelessWidget {
  /// Creates a [SessionCompletedScreen].
  const SessionCompletedScreen({super.key, this.durationSeconds});

  /// Total duration of the completed session in seconds.
  final int? durationSeconds;

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
                onPressed: () => context.pushNamed(RouteNames.pastEvents),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(l10n.homeMenuHistory),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
