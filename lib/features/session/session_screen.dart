/// Active safety-session screen.
///
/// Renders the current step, remaining seconds, miss count, a
/// hold-to-trigger button (for holdButton steps), and a disarm CTA
/// that routes the entered PIN through
/// [SessionController.handlePinResult].
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/core/widgets/hold_to_trigger_button.dart';
import 'package:guardianangela/core/widgets/pin_entry_dialog.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/walk_session.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Active-session screen.
class SessionScreen extends ConsumerWidget {
  /// Creates the session screen.
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(sessionControllerProvider);
    final settings = ref.watch(settingsControllerProvider).value;
    // Fix for specs.json Block #3 (StealthConfig has no consumers):
    // when stealth.enabled + stealth.sessionScreenStealth, drop the
    // Guardian Angela branding and show a blank AppBar title.
    final stealth = settings?.defaults.stealth;
    final hideBranding = stealth != null &&
        stealth.enabled &&
        stealth.sessionScreenStealth;
    return Scaffold(
      appBar: AppBar(
        title: Text(hideBranding ? '' : l.sessionTitle),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('$err')),
        data: (session) {
          if (session == null) {
            return Center(child: Text(l.sessionPhaseEnded));
          }
          if (session.phase is SessionPhaseEnded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.go(
                  session.isSimulation
                      ? RouteNames.simulationSummary
                      : RouteNames.sessionCompleted,
                );
              }
            });
          }
          return _SessionBody(session: session);
        },
      ),
    );
  }
}

class _SessionBody extends ConsumerWidget {
  const _SessionBody({required this.session});

  final WalkSession session;

  Future<void> _disarm(BuildContext context, WidgetRef ref) async {
    final settings = await ref.read(settingsControllerProvider.future);
    if (!context.mounted) return;
    final result = await showPinEntryDialog(
      context: context,
      sessionEndHash: settings.sessionEndPinHash,
      duressHash: settings.duressPinHash,
      timeout: settings.pinTimeoutSeconds,
    );
    final ok = ref
        .read(sessionControllerProvider.notifier)
        .handlePinResult(result);
    if (ok) {
      await ref.read(sessionControllerProvider.notifier).disarm();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (session.isSimulation)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Theme.of(context).colorScheme.tertiaryContainer,
              child: Text(
                l.sessionSimulationBanner,
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 16),
          Text(
            l.sessionStepLabel(
              session.currentStepIndex + 1,
              session.currentStepIndex + 2,
            ),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (session.remainingSeconds != null)
            Text(
              l.sessionRemaining(session.remainingSeconds!),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          Text(l.sessionMissCount(session.missCount)),
          const SizedBox(height: 24),
          if (session.phase is SessionPhasePaused)
            Chip(label: Text(l.sessionPausedBadge)),
          const Spacer(),
          // Fix for bugs.json Bug #1: wire hold-button events into the
          // engine via SessionController.holdStart/holdRelease. Prior
          // code used empty lambdas, so walk-mode check-in was
          // completely disconnected.
          if (session.currentStepType == ChainStepType.holdButton)
            HoldToTriggerButton(
              semanticLabel: l.sessionHoldSemantic,
              label: l.sessionHoldPrompt,
              onHoldStart: () => ref
                  .read(sessionControllerProvider.notifier)
                  .holdStart(),
              onHoldRelease: () => ref
                  .read(sessionControllerProvider.notifier)
                  .holdRelease(),
            ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              OutlinedButton(
                onPressed: () =>
                    ref.read(sessionControllerProvider.notifier).pause(),
                child: Text(l.sessionPause),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.check),
                label: Text(l.sessionDisarm),
                onPressed: () => _disarm(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
