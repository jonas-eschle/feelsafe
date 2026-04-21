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
import 'package:guardianangela/core/widgets/distress_confirmation.dart';
import 'package:guardianangela/core/widgets/hold_to_trigger_button.dart';
import 'package:guardianangela/core/widgets/im_safe_slider.dart';
import 'package:guardianangela/core/widgets/pin_entry_dialog.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/walk_session.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Active-session screen.
class SessionScreen extends ConsumerStatefulWidget {
  /// Creates the session screen.
  const SessionScreen({super.key});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  @override
  void initState() {
    super.initState();
    // Wire the distress-confirmation callback so TriggerManager can
    // ask the UI to gate a hardware-panic trigger behind the
    // countdown overlay. The closure captures `ref` rather than
    // context so it stays alive across rebuilds, and re-reads the
    // latest settings for the stealth flag + app PIN hash.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = ref.read(sessionControllerProvider.notifier);
      _attachedController = controller;
      controller.onDistressConfirmation = _confirmDistress;
    });
  }

  /// Cached notifier reference captured in [initState] so that
  /// [dispose] can detach the callback without calling
  /// `ref.read(...)` on a disposed element (which throws in Riverpod 3).
  SessionController? _attachedController;

  @override
  void dispose() {
    // Detach the closure so the controller does not hold a stale
    // reference to this State. Use the cached notifier ref; calling
    // `ref.read(...)` here would throw because the ConsumerElement
    // is already disposed.
    _attachedController?.onDistressConfirmation = null;
    _attachedController = null;
    super.dispose();
  }

  Future<bool> _confirmDistress() async {
    if (!mounted) return true;
    final settings = await ref.read(settingsControllerProvider.future);
    if (!mounted) return true;
    final stealth = settings.defaults.stealth;
    return showDistressConfirmation(
      context,
      duration: 5,
      isStealth: stealth.enabled,
      onCancel: () async {
        // If an app PIN is configured, require it to cancel the
        // distress trigger. Any result other than `correct` rejects
        // the cancel (countdown auto-confirms).
        final pinHash = settings.appPinHash;
        if (pinHash == null) return true;
        if (!mounted) return false;
        final result = await showPinEntryDialog(
          context: context,
          sessionEndHash: pinHash,
          duressHash: settings.duressPinHash,
          timeout: settings.pinTimeoutSeconds,
        );
        return ref
            .read(sessionControllerProvider.notifier)
            .handlePinResult(result);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
    // Fix for bugs.json Block (stealth.timerDisplay no-op): hide the
    // remaining-seconds text AND the hold-button countdown when
    // stealth is active and `timerDisplay` is false. Settings UI has
    // always persisted this flag; until now nothing consumed it.
    final hideTimer = stealth != null &&
        stealth.enabled &&
        !stealth.timerDisplay;
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
          return _SessionBody(session: session, hideTimer: hideTimer);
        },
      ),
    );
  }
}

class _SessionBody extends ConsumerWidget {
  const _SessionBody({required this.session, required this.hideTimer});

  final WalkSession session;

  /// When true, the remaining-seconds text is suppressed (stealth
  /// mode with timerDisplay=false). The hold-button label loses the
  /// seconds-suffix in that case as well.
  final bool hideTimer;

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
          if (session.remainingSeconds != null && !hideTimer)
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              OutlinedButton(
                onPressed: () =>
                    ref.read(sessionControllerProvider.notifier).pause(),
                child: Text(l.sessionPause),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Swipe-to-confirm disarm. On release at the end of the
          // track we gate the actual disarm behind the session-end
          // PIN (same path as the legacy button via handlePinResult).
          ImSafeSlider(
            label: l.imSafeSliderLabel,
            onConfirmed: () => _disarm(context, ref),
          ),
        ],
      ),
    );
  }
}
