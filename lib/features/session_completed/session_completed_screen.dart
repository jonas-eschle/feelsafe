import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Shown after a session completes normally.
///
/// Renders the duration row, the simulation banner (when applicable),
/// the two CTAs, and — only when [showFeedbackPrompt] — the optional,
/// dismissible post-session feedback prompt (spec 04 §Chain Exhausted —
/// Tier-F F5). Suppressed entirely in stealth mode (spec 04 §Chain
/// Exhausted Screen — stealth path silently routes home).
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
    this.showFeedbackPrompt = false,
  });

  /// Total duration of the completed session in seconds.
  final int? durationSeconds;

  /// Session log id passed via the `?id=` route parameter.
  final String? logId;

  /// Whether the completed session was a simulation.
  final bool isSimulation;

  /// Whether to render the optional post-session feedback prompt
  /// (spec 04 §Chain Exhausted — Tier-F F5).
  ///
  /// Set by the session-end flow only for clean **real** completions once
  /// the user has finished at least [FeedbackPromptRepository.promptThreshold]
  /// sessions, and never under stealth. The prompt is dismissible and never
  /// blocks the Return-Home / View-Log actions. Defaults to false.
  final bool showFeedbackPrompt;

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
              if (showFeedbackPrompt) ...<Widget>[
                const SizedBox(height: 24),
                const _FeedbackPrompt(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Optional, dismissible "How was your experience?" card on the completion
/// screen (spec 04 §Chain Exhausted — Tier-F F5).
///
/// `[Send feedback]` pushes the existing `/settings/feedback` form (which
/// persists to the local `feedback_history` Drift table — there is no remote
/// backend); `[Skip]` hides the card for the remainder of this visit. Local
/// dismiss state lives here so the screen above stays stateless. The card is
/// never shown under stealth or for simulations (the parent gates that).
class _FeedbackPrompt extends StatefulWidget {
  const _FeedbackPrompt();

  @override
  State<_FeedbackPrompt> createState() => _FeedbackPromptState();
}

class _FeedbackPromptState extends State<_FeedbackPrompt> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              l10n.sessionCompletedFeedbackPrompt,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  onPressed: () => setState(() => _dismissed = true),
                  child: Text(l10n.sessionCompletedFeedbackSkip),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () =>
                      context.pushNamed(RouteNames.settingsFeedback),
                  child: Text(l10n.sessionCompletedFeedbackSend),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
