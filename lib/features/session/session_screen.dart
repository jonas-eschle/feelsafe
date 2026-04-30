/// Active safety-session screen.
///
/// Renders the current step, remaining seconds, miss count, a
/// hold-to-trigger button (for holdButton steps), and a disarm CTA
/// that routes the entered PIN through
/// [SessionController.handlePinResult].
///
/// Per spec 04 §Step-Specific UI, each of the nine `ChainStepType`s
/// renders its own widget through the [_StepWidget] dispatcher
/// added in this revision. `fakeCall` is the lone exception — it
/// is route-pushed to `/fake-call` (Q20).
library;

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/core/widgets/distress_confirmation.dart';
import 'package:guardianangela/core/widgets/hold_to_trigger_button.dart';
import 'package:guardianangela/core/widgets/im_safe_slider.dart';
import 'package:guardianangela/core/widgets/pin_entry_dialog.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/stealth_config.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/models/walk_session.dart';
import 'package:guardianangela/features/modes/modes_controller.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/features/session/widgets/simulation_advanced_controls.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

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
      controller.onAngelaDeceptiveDialog = _showAngelaDeceptiveDialog;
      controller.onDisarmRequested = _onDisarmRequested;
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
    _attachedController?.onAngelaDeceptiveDialog = null;
    _attachedController?.onDisarmRequested = null;
    _attachedController = null;
    super.dispose();
  }

  Future<void> _showAngelaDeceptiveDialog() async {
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.angelaDialogTitle),
        content: Text(l.angelaDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.angelaDialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.angelaDialogConfirm),
          ),
        ],
      ),
    );
  }

  void _onDisarmRequested() {
    // Triggered by GPS arrival or timer disarm: open the disarm UI
    // confirmation. Currently a no-op — the timer / GPS auto-disarm
    // path runs through `_confirmDisarmTrigger` driven by the
    // `pendingDisarmTrigger` field on the active session.
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
    // Spec 04 §fakeCall (Q20): when the engine starts a fakeCall
    // step, SessionScreen MUST auto-push /fake-call. We watch the
    // session controller via ref.listen (one-shot side effect on
    // transition, not a per-build derivation) and push whenever
    // currentStepType transitions into fakeCall.
    ref.listen<AsyncValue<WalkSession?>>(sessionControllerProvider, (
      previous,
      next,
    ) {
      final prevType = previous?.value?.currentStepType;
      final nextType = next.value?.currentStepType;
      if (nextType == ChainStepType.fakeCall &&
          prevType != ChainStepType.fakeCall) {
        // Debounce: if we are already on /fake-call, do nothing.
        final loc = GoRouter.of(
          context,
        ).routerDelegate.currentConfiguration.uri.toString();
        if (loc == RouteNames.fakeCall) return;
        context.push(RouteNames.fakeCall);
      }
    });
    final async = ref.watch(sessionControllerProvider);
    final settings = ref.watch(settingsControllerProvider).value;
    // Fix for specs.json Block #3 (StealthConfig has no consumers):
    // when stealth.enabled + stealth.sessionScreenStealth, drop the
    // Guardian Angela branding and show a blank AppBar title.
    final stealth = settings?.defaults.stealth;
    final hideBranding =
        stealth != null && stealth.enabled && stealth.sessionScreenStealth;
    // Fix for bugs.json Block (stealth.timerDisplay no-op): hide the
    // remaining-seconds text AND the hold-button countdown when
    // stealth is active and `timerDisplay` is false. Settings UI has
    // always persisted this flag; until now nothing consumed it.
    final hideTimer = stealth != null &&
        stealth.enabled &&
        stealth.timerDisplay == StealthTimerDisplay.none;
    return Scaffold(
      appBar: AppBar(title: Text(hideBranding ? '' : l.sessionTitle)),
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
          if (session.isSimulation) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Theme.of(context).colorScheme.tertiaryContainer,
              child: Text(
                l.sessionSimulationBanner,
                textAlign: TextAlign.center,
              ),
            ),
            const SimulationAdvancedControls(),
          ],
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
          // Per spec 04 §Step-Specific UI: each ChainStepType
          // renders its own widget. _StepWidget dispatches on
          // session.currentStepType. fakeCall is handled via the
          // ref.listen route-push above; its widget branch is
          // intentionally an empty placeholder.
          _StepWidget(session: session),
          const Spacer(),
          if (ref.read(sessionControllerProvider.notifier).isPauseAllowed)
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

/// Dispatches to the right per-step widget based on
/// `session.currentStepType` (spec 04 §Step-Specific UI).
///
/// Each of the nine step types has its own renderer. The shared
/// session chrome (step counter, miss count, simulation banner, "I'm
/// safe" slider) lives in [_SessionBody]; this widget renders only
/// the step-specific affordance.
///
/// `fakeCall` is intentionally not rendered here — SessionScreen
/// auto-pushes `/fake-call` when the engine emits
/// `stepStarted(fakeCall)` (Q20), so the SessionScreen body sits
/// underneath the pushed route. The placeholder branch simply
/// renders `SizedBox.shrink()`.
class _StepWidget extends ConsumerWidget {
  const _StepWidget({required this.session});

  final WalkSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // No active step type yet (e.g., engine hasn't emitted
    // stepStarted) — render nothing rather than guess.
    final type = session.currentStepType;
    if (type == null) return const SizedBox.shrink();
    return switch (type) {
      ChainStepType.holdButton => _HoldButtonStep(session: session),
      ChainStepType.disguisedReminder => _DisguisedReminderStep(
        session: session,
      ),
      ChainStepType.countdownWarning => _CountdownWarningStep(session: session),
      // SessionScreen pushes /fake-call when this step starts (Q20).
      // No inline UI is needed; render an empty box.
      ChainStepType.fakeCall => const SizedBox.shrink(),
      ChainStepType.smsContact => _SmsContactStep(session: session),
      ChainStepType.phoneCallContact => _PhoneCallContactStep(session: session),
      ChainStepType.loudAlarm => _LoudAlarmStep(session: session),
      ChainStepType.callEmergency => _CallEmergencyStep(session: session),
      ChainStepType.hardwareButton => _HardwareButtonStep(session: session),
    };
  }
}

/// holdButton step UI — large round Hold button.
///
/// Spec 04 §holdButton. Pressing fires `holdStart`, releasing fires
/// `holdRelease`; the engine starts the grace period on release.
class _HoldButtonStep extends ConsumerWidget {
  const _HoldButtonStep({required this.session});

  // ignore: unused_field
  final WalkSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return HoldToTriggerButton(
      semanticLabel: l.sessionHoldSemantic,
      label: l.sessionHoldPrompt,
      onHoldStart: () =>
          ref.read(sessionControllerProvider.notifier).holdStart(),
      onHoldRelease: () =>
          ref.read(sessionControllerProvider.notifier).holdRelease(),
    );
  }
}

/// disguisedReminder step UI — minimal card with the template
/// title/body plus the "I'm checked in" reset CTA.
///
/// Spec 04 §disguisedReminder + Q6. The actual notification is
/// posted by the strategy layer; here we provide an in-app
/// equivalent so the user can ack without hunting the system shade.
///
/// The check-in CTA delegates straight to the disarm path because
/// the current `SessionController` does not expose a separate
/// `checkIn()` (the engine auto-resets via the strategy on tap).
class _DisguisedReminderStep extends ConsumerWidget {
  const _DisguisedReminderStep({required this.session});

  // ignore: unused_field
  final WalkSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.notifications_active_outlined),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.sessionStepDisguisedDefaultTitle,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(l.sessionStepDisguisedDefaultBody),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Q6 / spec 04 §Shared Session UI: tap to acknowledge the
        // reminder. The controller's holdStart/holdRelease pair acts
        // as a momentary check-in for engine event purposes; the
        // strategy resets the chain on the engine side.
        FilledButton.tonalIcon(
          onPressed: () {
            final ctrl = ref.read(sessionControllerProvider.notifier);
            ctrl.holdStart();
            ctrl.holdRelease();
          },
          icon: const Icon(Icons.check_circle_outline),
          label: Text(l.sessionCheckIn),
        ),
      ],
    );
  }
}

/// countdownWarning step UI — full-screen large countdown timer in
/// warning colours.
///
/// Spec 04 §countdownWarning. Uses the session's `remainingSeconds`
/// (already tracked by the engine) for the displayed value.
class _CountdownWarningStep extends StatelessWidget {
  const _CountdownWarningStep({required this.session});

  final WalkSession session;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final remaining = session.remainingSeconds;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 48,
            color: colors.onErrorContainer,
          ),
          const SizedBox(height: 8),
          Text(
            l.sessionStepCountdownTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colors.onErrorContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (remaining != null)
            Text(
              '$remaining',
              style: theme.textTheme.displayLarge?.copyWith(
                color: colors.onErrorContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 12),
          Text(
            l.sessionStepCountdownBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onErrorContainer,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// smsContact step UI — status text + per-message delivery icons.
///
/// Spec 04 §smsContact. Subscribes to
/// [MessagingServiceProtocol.deliveryUpdates] so per-message status
/// dots update live as the platform layer reports queue / sent /
/// delivered / failed transitions.
class _SmsContactStep extends ConsumerStatefulWidget {
  const _SmsContactStep({required this.session});

  // ignore: unused_field
  final WalkSession session;

  @override
  ConsumerState<_SmsContactStep> createState() => _SmsContactStepState();
}

class _SmsContactStepState extends ConsumerState<_SmsContactStep> {
  StreamSubscription<MessageDeliveryUpdate>? _sub;

  /// Latest status keyed by `workId`. Order is insertion-order, so
  /// the UI shows the chips in the order they were enqueued.
  final Map<String, String> _statuses = <String, String>{};

  @override
  void initState() {
    super.initState();
    // Subscribe in a post-frame callback so we don't read providers
    // during initState (which is a Riverpod no-no).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final messaging = ref.read(messagingServiceProvider);
      _sub = messaging.deliveryUpdates.listen((update) {
        if (!mounted) return;
        setState(() {
          _statuses[update.workId] = update.status;
        });
      });
    });
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    _sub = null;
    super.dispose();
  }

  String _statusLabel(BuildContext context, String raw) {
    final l = AppLocalizations.of(context);
    return switch (raw.toLowerCase()) {
      'delivered' => l.sessionStepSmsDelivered,
      'sent' => l.sessionStepSmsSent,
      'queued' => l.sessionStepSmsQueued,
      'failed' => l.sessionStepSmsFailed,
      _ => raw,
    };
  }

  IconData _statusIcon(String raw) => switch (raw.toLowerCase()) {
    'delivered' => Icons.check_circle,
    'sent' => Icons.done,
    'queued' => Icons.schedule,
    'failed' => Icons.error_outline,
    _ => Icons.help_outline,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sms_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.sessionStepSmsStatus,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            if (_statuses.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _statuses.entries
                    .map(
                      (e) => Chip(
                        avatar: Icon(_statusIcon(e.value), size: 18),
                        label: Text(_statusLabel(context, e.value)),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// phoneCallContact step UI — status text + cancel-call button.
///
/// Spec 04 §phoneCallContact. Cancel goes through the standard
/// disarm path (no PIN gate when the user explicitly taps Cancel —
/// same UX as `EmergencyConfirmScreen.onCancel`).
class _PhoneCallContactStep extends ConsumerWidget {
  const _PhoneCallContactStep({required this.session});

  // ignore: unused_field
  final WalkSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.phone_in_talk_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.sessionStepPhoneCallStatus,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () =>
                  ref.read(sessionControllerProvider.notifier).disarm(),
              icon: const Icon(Icons.call_end),
              label: Text(l.sessionStepPhoneCallCancel),
            ),
          ],
        ),
      ),
    );
  }
}

/// loudAlarm step UI — alarm-playing indicator. Disarm via the
/// shared "I'm safe" slider in [_SessionBody].
///
/// Spec 04 §loudAlarm. The alarm is always disarmable; the slider
/// below is the canonical disarm path. We surface a photosensitive
/// warning when `flashScreen=true` so users with epilepsy are not
/// caught off-guard (D-A11Y-1).
class _LoudAlarmStep extends ConsumerWidget {
  const _LoudAlarmStep({required this.session});

  final WalkSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    // Photosensitive warning: only surfaced when the active step's
    // LoudAlarmConfig.flashScreen is true. Resolution falls back to
    // the spec default (false) when the mode/step lookup fails.
    final cfg = _resolveStepConfig<LoudAlarmConfig>(ref, session);
    final showFlashWarning = cfg?.flashScreen ?? false;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.volume_up, size: 48, color: colors.onErrorContainer),
          const SizedBox(height: 8),
          Text(
            l.sessionStepLoudAlarmTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colors.onErrorContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.sessionStepLoudAlarmBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onErrorContainer,
            ),
            textAlign: TextAlign.center,
          ),
          if (showFlashWarning) ...[
            const SizedBox(height: 12),
            Text(
              l.sessionStepLoudAlarmFlashWarning,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onErrorContainer,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// callEmergency step UI — confirmation card surfacing the number
/// being dialed.
///
/// Spec 04 §callEmergency. Shows the configured emergency number so
/// the user can verify it. Cancellation flows through the standard
/// "I'm safe" slider in [_SessionBody].
class _CallEmergencyStep extends ConsumerWidget {
  const _CallEmergencyStep({required this.session});

  // ignore: unused_field
  final WalkSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsControllerProvider).value;
    final number = settings?.emergencyCallNumber;
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_hospital_outlined,
                  color: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.sessionStepCallEmergencyStatus,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
            if (number != null && number.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                l.sessionStepCallEmergencyNumber(number),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// hardwareButton step UI — instruction text + live counter.
///
/// Spec 04 §hardwareButton. Reads `HardwareButtonConfig` off the
/// step.config to render the correct prompt (repeat-press vs
/// long-press). The actual press detection is platform-side; this
/// widget only surfaces the instruction.
class _HardwareButtonStep extends ConsumerWidget {
  const _HardwareButtonStep({required this.session});

  final WalkSession session;

  String _buttonLabel(AppLocalizations l, ButtonType type) => switch (type) {
    ButtonType.volumeUp => l.sessionStepHardwareButtonVolumeUp,
    ButtonType.volumeDown => l.sessionStepHardwareButtonVolumeDown,
    ButtonType.power => l.sessionStepHardwareButtonPower,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    // Pull the live mode so we can read the active step's
    // HardwareButtonConfig. We resolve through the modes repository;
    // when the session is null or no config is found, we fall back
    // to the spec defaults.
    final config =
        _resolveStepConfig<HardwareButtonConfig>(ref, session) ??
        const HardwareButtonConfig();
    final buttonLabel = _buttonLabel(l, config.buttonType);
    final instruction = config.pattern == HardwarePattern.repeatPress
        ? l.sessionStepHardwareButtonRepeat(
            buttonLabel,
            config.pressCount,
            config.pressWindowMs,
          )
        : l.sessionStepHardwareButtonLong(
            buttonLabel,
            config.longPressDurationSeconds,
          );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.touch_app_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(instruction, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${session.missCount}', style: theme.textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}

/// Resolves the typed [StepConfig] for the active step on
/// [session] cast to [T], or null when the lookup fails.
///
/// Walks `modesController` to find the live mode by id and returns
/// `mode.chainSteps[currentStepIndex].config` when that config is
/// of type [T]. Returns null when any of these conditions fail:
/// modes not yet loaded, mode missing, step index out of range, or
/// the config is null/not a [T]. Callers fall back to spec
/// defaults in that case.
///
/// *Why a generic helper:* loudAlarm and hardwareButton both want
/// the same lookup path; duplicating the loop in each step widget
/// is cheaper to read but harder to keep in sync.
T? _resolveStepConfig<T extends StepConfig>(
  WidgetRef ref,
  WalkSession session,
) {
  final modes = ref.watch(modesControllerProvider).value;
  if (modes == null) return null;
  SessionMode? mode;
  for (final m in modes) {
    if (m.id == session.modeId) {
      mode = m;
      break;
    }
  }
  if (mode == null) return null;
  final idx = session.currentStepIndex;
  if (idx < 0 || idx >= mode.chainSteps.length) return null;
  final step = mode.chainSteps[idx];
  final cfg = step.config;
  return cfg is T ? cfg : null;
}
