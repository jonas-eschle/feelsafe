import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/pin_constants.dart';
import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/core/widgets/deceptive_old_pin_dialog.dart';
import 'package:guardianangela/core/widgets/pin_keypad.dart';
import 'package:guardianangela/core/widgets/swipe_slider.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/enums/pause_reason.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/features/disguised_reminder/reminder_confirmation.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/features/session/widgets/emergency_confirm_overlay.dart';
import 'package:guardianangela/features/session/widgets/end_session_overlay.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Active session screen.
///
/// Orientation is locked to portrait (D3) while this screen is mounted.
/// Renders different UI per [ChainStepType], with overlays for distress
/// confirmation, GPS destination prompts, and the interrupted-session
/// prompt. See spec 04 §Session Screen + §Step-Specific UI.
///
/// When [quickExit] is true (set via `?quickExit=true` from the home-screen
/// widget "Quick Exit" button), the screen auto-runs [_endSessionFlow] once
/// immediately after the first frame via [WidgetsBinding.addPostFrameCallback].
/// This reuses the existing PIN-gated / Duress / no-PIN end flow without
/// duplicating any logic. No-op when [quickExit] is false.
class SessionScreen extends ConsumerStatefulWidget {
  /// Creates a [SessionScreen].
  ///
  /// [quickExit] defaults to false; pass true from the home-widget deep link
  /// to auto-trigger the PIN-gated end flow on mount.
  const SessionScreen({super.key, this.quickExit = false});

  /// When true the end-session flow runs automatically after the first frame.
  final bool quickExit;

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  /// Guards the one-shot post-frame quick-exit callback so it never fires
  /// twice even if the widget rebuilds before the callback executes.
  bool _quickExitFired = false;

  /// True while the full-screen [FakeCallScreen] route is on top, so a retry
  /// of the same fake-call step does not stack a second call screen.
  bool _fakeCallRouteOpen = false;

  /// Last seen [SessionState.fakeCallShowNonce]; a higher value means a new
  /// fake-call ring should auto-appear.
  int _lastFakeCallNonce = 0;

  /// True while the full-screen [DisguisedReminderScreen] route is on top, so
  /// a re-fire of the same reminder step does not stack a second screen.
  bool _reminderRouteOpen = false;

  /// Last seen [SessionState.reminderShowNonce]; a higher value means a new
  /// `fullScreen` reminder should auto-appear.
  int _lastReminderNonce = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);
    if (widget.quickExit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _quickExitFired) return;
        _quickExitFired = true;
        _endSessionFlow(context);
      });
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stateAsync = ref.watch(sessionControllerProvider);
    // Auto-appear: when a fakeCall step starts (or retries), push the
    // full-screen call UI "like a real incoming call" (spec 02 §fakeCall).
    ref.listen<AsyncValue<SessionState>>(sessionControllerProvider, (_, next) {
      final s = next.value;
      if (s == null) return;
      if (s.fakeCallShowNonce > _lastFakeCallNonce) {
        _lastFakeCallNonce = s.fakeCallShowNonce;
        unawaited(_maybeShowFakeCall(s));
      }
      if (s.reminderShowNonce > _lastReminderNonce) {
        _lastReminderNonce = s.reminderShowNonce;
        unawaited(_maybeShowReminder(s));
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sessionTitle),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.power_settings_new),
            tooltip: l10n.sessionQuickExitTitle,
            onPressed: () => _confirmQuickExit(context),
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: l10n.commonClose,
            onPressed: () => _endSessionFlow(context),
          ),
        ],
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(child: Text('Error: $e')),
        data: (SessionState s) => _SessionRoot(state: s),
      ),
    );
  }

  /// Pushes the full-screen fake-call route with the current step's config,
  /// unless a call screen is already showing. The `await` completes when the
  /// route is popped (answer/hang-up/decline), clearing the open flag so a
  /// later retry can re-appear.
  Future<void> _maybeShowFakeCall(SessionState s) async {
    if (_fakeCallRouteOpen || !mounted) return;
    final config = s.currentStep?.config;
    if (config is! FakeCallConfig) return;
    _fakeCallRouteOpen = true;
    await context.pushNamed(RouteNames.fakeCall, extra: config);
    if (mounted) _fakeCallRouteOpen = false;
  }

  /// Pushes the full-screen [DisguisedReminderScreen] when the just-fired
  /// reminder uses the `fullScreen` display style, unless one is already
  /// showing. `subtle` reminders render inline ([_DisguisedReminderStepUi]),
  /// so they are skipped here. The `await` completes when the route pops
  /// (confirm, or the engine moving on), clearing the flag so a re-fire can
  /// re-appear (spec 02 §disguisedReminder Display Styles).
  Future<void> _maybeShowReminder(SessionState s) async {
    if (_reminderRouteOpen || !mounted) return;
    if (s.activeReminderTemplate?.displayStyle !=
        ReminderDisplayStyle.fullScreen) {
      return;
    }
    _reminderRouteOpen = true;
    await context.pushNamed(RouteNames.disguisedReminder);
    if (mounted) _reminderRouteOpen = false;
  }

  Future<void> _endSessionFlow(BuildContext context) async {
    final sessionState = ref.read(sessionControllerProvider).value;
    final isSimulation = sessionState?.isSimulation ?? false;
    final outcome = await EndSessionOverlay.show(
      context,
      isSimulation: isSimulation,
    );
    if (!context.mounted) return;
    switch (outcome) {
      case EndSessionOutcome.dismissed:
        return;
      case EndSessionOutcome.endConfirmed:
        await _confirmedEnd(context, isSimulation: isSimulation);
      case EndSessionOutcome.duressPinEntered:
        ref
            .read(sessionControllerProvider.notifier)
            .confirmDistress(reason: EndReason.duressPin);
      case EndSessionOutcome.wrongPinExhausted:
        if (isSimulation) {
          // Simulation never fires the distress chain — the overlay
          // surfaces a SnackBar via the wrong-PIN branch, then closes.
          // Falling through here would be a contract violation; the
          // overlay's simulation rule explicitly never raises this
          // outcome (spec 04:548). Treat it as a no-op to keep the
          // switch exhaustive.
          return;
        }
        ref
            .read(sessionControllerProvider.notifier)
            .confirmDistress(reason: EndReason.wrongPinExhausted);
    }
  }

  Future<void> _confirmedEnd(
    BuildContext context, {
    required bool isSimulation,
  }) async {
    final controller = ref.read(sessionControllerProvider.notifier);
    final recorderId = controller.currentSessionLogId;
    await controller.endSession();
    if (!context.mounted) return;
    final params = <String, String>{if (isSimulation) 'simulation': 'true'};
    if (recorderId != null) params['id'] = recorderId;
    context.goNamed(RouteNames.sessionCompleted, queryParameters: params);
  }

  Future<void> _confirmQuickExit(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(l10n.sessionQuickExitTitle),
        content: Text(l10n.sessionQuickExitBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.sessionQuickExitConfirm),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      // Persist the session log first (controller writes encrypted data
      // to disk so it survives the process kill). Only then invoke the
      // platform-side quick-exit hook — Android
      // `finishAndRemoveTask` / iOS `exit(0)` via the
      // `com.guardianangela.app/quick_exit` MethodChannel
      // (spec 04:1020–1027). The Real service handles the
      // native-channel-missing fallback internally.
      await ref.read(sessionControllerProvider.notifier).triggerQuickExit();
      await ref.read(quickExitServiceProvider).quickExit();
    }
  }
}

class _SessionRoot extends ConsumerStatefulWidget {
  const _SessionRoot({required this.state});

  final SessionState state;

  @override
  ConsumerState<_SessionRoot> createState() => _SessionRootState();
}

class _SessionRootState extends ConsumerState<_SessionRoot> {
  /// Id of the call-emergency step the user has dismissed via
  /// `[Keep calling]`. Cleared automatically when the step changes so
  /// each fresh emergency step re-arms the overlay.
  ///
  /// Defaults to null (no step dismissed).
  String? _dismissedEmergencyStepId;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    if (state.priorInterrupted) {
      return _InterruptedPrompt(state: state);
    }
    if (state.distressConfirmRemaining != null) {
      return _DistressConfirmationOverlay(state: state);
    }
    // If the active step changed (or no step is active), clear any
    // stale dismissed-emergency id so a future emergency step re-arms
    // the overlay.
    final step = state.currentStep;
    if (_dismissedEmergencyStepId != null &&
        _dismissedEmergencyStepId != step?.id) {
      // Use addPostFrameCallback so the setState lands outside build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _dismissedEmergencyStepId = null);
      });
    }
    final showEmergencyOverlay =
        step != null &&
        step.type == ChainStepType.callEmergency &&
        state.phase == SessionPhase.duration &&
        _dismissedEmergencyStepId != step.id;
    return Stack(
      children: <Widget>[
        _SessionBody(state: state, hideStepUi: showEmergencyOverlay),
        if (state.isSimulation) const _SimulationBanner(),
        if (state.needsGpsDestinationPrompt) const _GpsDestinationPrompt(),
        if (state.lastError != null) _ErrorBanner(message: state.lastError!),
        if (showEmergencyOverlay)
          EmergencyConfirmOverlay(
            state: state,
            step: step,
            onKeepCalling: () =>
                setState(() => _dismissedEmergencyStepId = step.id),
          ),
      ],
    );
  }
}

class _SessionBody extends ConsumerWidget {
  const _SessionBody({required this.state, this.hideStepUi = false});

  final SessionState state;

  /// When true the step-specific UI is replaced with a [SizedBox.shrink]
  /// so an overlay (e.g. [EmergencyConfirmOverlay]) can take the
  /// foreground without rendering duplicate content underneath.
  ///
  /// Defaults to false.
  final bool hideStepUi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final step = state.currentStep;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _SessionHeader(state: state),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: hideStepUi
                    ? const SizedBox.shrink()
                    : switch (step?.type) {
                        null => Text(l10n.sessionPhaseEnded),
                        ChainStepType.holdButton => _HoldButtonStepUi(
                          state: state,
                          step: step!,
                        ),
                        ChainStepType.disguisedReminder =>
                          _DisguisedReminderStepUi(state: state, step: step!),
                        ChainStepType.countdownWarning =>
                          _CountdownWarningStepUi(state: state, step: step!),
                        ChainStepType.fakeCall => _FakeCallStepUi(
                          state: state,
                          step: step!,
                        ),
                        ChainStepType.smsContact => _SmsContactStepUi(
                          state: state,
                          step: step!,
                        ),
                        ChainStepType.phoneCallContact =>
                          _PhoneCallContactStepUi(state: state, step: step!),
                        ChainStepType.loudAlarm => _LoudAlarmStepUi(
                          state: state,
                          step: step!,
                        ),
                        ChainStepType.callEmergency => _CallEmergencyStepUi(
                          state: state,
                          step: step!,
                        ),
                        ChainStepType.hardwareButton => _HardwareButtonStepUi(
                          state: state,
                          step: step!,
                        ),
                      },
              ),
            ),
            const SizedBox(height: 12),
            if (state.phase != SessionPhase.ended)
              _DisarmAction(
                onDisarm: () =>
                    ref.read(sessionControllerProvider.notifier).disarm(),
                label: state.stealthEnabled
                    ? l10n.sessionDisarmStealth
                    : l10n.sessionDisarm,
              ),
            if (state.isSimulation)
              _SimulationControlsBar(state: state, textTheme: textTheme),
          ],
        ),
      ),
    );
  }
}

class _SessionHeader extends StatelessWidget {
  const _SessionHeader({required this.state});

  final SessionState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            _formatElapsed(state.elapsedSeconds),
            style: textTheme.headlineSmall,
          ),
        ),
        if (state.currentStepIndex >= 0)
          Text(
            l10n.sessionStepLabel(
              (state.currentStepIndex + 1).toString(),
              state.activeChain.length.toString(),
            ),
            style: textTheme.labelLarge,
          ),
        if (state.isPaused) ...<Widget>[
          const SizedBox(width: 8),
          Chip(
            label: Text(
              state.pauseReason == PauseReason.incomingCall
                  ? l10n.sessionPausedIncomingCall
                  : l10n.sessionPausedBadge,
            ),
          ),
        ],
        if (state.missCount > 0) ...<Widget>[
          const SizedBox(width: 8),
          Chip(label: Text(l10n.sessionMissCount(state.missCount.toString()))),
        ],
      ],
    );
  }

  static String _formatElapsed(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    String two(int v) => v.toString().padLeft(2, '0');
    if (hours > 0) {
      return '${two(hours)}:${two(minutes)}:${two(secs)}';
    }
    return '${two(minutes)}:${two(secs)}';
  }
}

class _SimulationBanner extends StatelessWidget {
  const _SimulationBanner();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.orange, width: 4),
          ),
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 4),
          child: Material(
            color: Colors.orange.withValues(alpha: 0.15),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                '[SIM] ${l10n.sessionSimulationBanner}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Material(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
        ),
      ),
    );
  }
}

class _InterruptedPrompt extends ConsumerWidget {
  const _InterruptedPrompt({required this.state});

  final SessionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(l10n.sessionInterruptedTitle, style: textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text(
              l10n.sessionInterruptedBody,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (state.priorModeName != null)
              Text(l10n.sessionInterruptedMode(state.priorModeName!)),
            if (state.priorStartedAt != null)
              Text(
                l10n.sessionInterruptedStarted(
                  state.priorStartedAt!.toLocal().toString(),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                ref
                    .read(sessionControllerProvider.notifier)
                    .acknowledgeInterruptedPrompt();
                context.goNamed(RouteNames.home);
              },
              child: Text(l10n.sessionInterruptedAcknowledge),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stage of the distress-confirmation overlay's internal state machine.
///
/// The overlay always mounts in [confirmation]; tapping the cancel
/// button moves to [pinPrompt] when a Session End PIN is configured.
enum _DistressStage {
  /// Initial stage — the red "DISTRESS ACTIVATED" panel with the 5-second
  /// countdown ring and [TAP TO CANCEL] button.
  confirmation,

  /// PIN keypad stage — only entered when
  /// [AppSettings.sessionEndPinHash] is non-null and the user tapped
  /// cancel. A separate 15-second timeout runs while this stage is
  /// active; the underlying 5-second confirmation countdown is paused.
  pinPrompt,
}

/// Distress-confirmation overlay with optional PIN gate (spec 04 §Distress
/// Confirmation Window, C3 PM-FIX).
///
/// Renders the modal countdown when
/// [SessionState.distressConfirmRemaining] is non-null. The flow:
///
/// 1. The user sees the 5-second red countdown panel with a
///    [TAP TO CANCEL] button. If no Session End PIN is configured, the
///    tap calls `cancelDistress()` immediately and the overlay
///    dismisses.
/// 2. If `AppSettings.sessionEndPinHash != null`, the overlay
///    transitions to the [pinPrompt] stage:
///    * the confirmation countdown is paused via
///      `pauseDistressCountdown()` (so the user has the full 15-second
///      PIN window),
///    * a 15-second timer starts and renders "15s remaining",
///    * the PinKeypad accepts digits and runs the auto-submit ladder
///      (Duress > App > Session End — spec 06 §Auto-submit, R-27).
/// 3. PIN-prompt outcomes:
///    * **Duress PIN** → `confirmDistress(reason: EndReason.duressPin)`
///    * **App PIN** → inline hint "Use the Session End PIN, not the
///      app lock PIN."; not counted as wrong PIN
///    * **Session End PIN** → `cancelDistress()`; wrong-PIN counter
///      reset to zero
///    * **Wrong PIN** → shake / DeceptiveOldPinDialog (per
///      `AppSettings.deceptivePinDialogEnabled`) + counter increment +
///      `engine.notifyWrongPin(count)`. When count reaches
///      `AppSettings.wrongPinThreshold`:
///      - real → `confirmDistress(reason: EndReason.wrongPinExhausted)`
///      - simulation → SnackBar "Distress chain would fire (5 wrong
///        PINs)" + entry reset; no real distress (spec 04:548)
///    * **15s timeout** →
///      `confirmDistress(reason: EndReason.distressConfirmTimeout)`
///    * **Cancel button** → return to [confirmation] stage and resume
///      the 5-second countdown
/// 4. **Simulation** also surfaces a `[Skip]` `TextButton` next to the
///    keypad which calls `cancelDistress()` directly so users can
///    practice without entering a valid PIN.
class _DistressConfirmationOverlay extends ConsumerStatefulWidget {
  const _DistressConfirmationOverlay({required this.state});

  final SessionState state;

  @override
  ConsumerState<_DistressConfirmationOverlay> createState() =>
      _DistressConfirmationOverlayState();
}

class _DistressConfirmationOverlayState
    extends ConsumerState<_DistressConfirmationOverlay>
    with SingleTickerProviderStateMixin {
  /// Current local stage. Always starts at [_DistressStage.confirmation].
  _DistressStage _stage = _DistressStage.confirmation;

  /// Cached settings; null until first load completes.
  AppSettings? _settings;

  /// Whether a settings load is in flight. Prevents double-fetches when
  /// the user taps cancel before the initial load completes.
  bool _loadingSettings = false;

  /// Digits the user has typed at the PIN keypad. Defaults to empty.
  final List<int> _entry = <int>[];

  /// Whether to render the inline "Incorrect PIN" hint. Defaults false.
  bool _showWrong = false;

  /// Whether to render the "Use the Session End PIN" hint. Defaults false.
  bool _showAppPinMismatch = false;

  /// Simulation-only local wrong-PIN counter (spec 04:548). Never
  /// touches the controller's real counter; resets on threshold reached.
  int _simWrongAttempts = 0;

  /// 15-second PIN-prompt timer. Null when no PIN stage is active.
  Timer? _pinTimer;

  /// Remaining seconds in the 15s PIN-prompt window. Defaults to the
  /// configured `pinTimeoutSeconds` (15 by default — spec 06 §Session
  /// End PIN). Updated by [_pinTimer] each second.
  int _pinTimeoutRemaining = 15;

  late final AnimationController _shakeCtl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shakeAnim = Tween<double>(
      begin: 0,
      end: 8,
    ).animate(CurvedAnimation(parent: _shakeCtl, curve: Curves.elasticIn));
    // Lazy-load settings: only fetch the encrypted singleton if the user
    // is likely to engage the PIN gate. Pre-fetching at initState would
    // force every distress-confirmation surface to wait on the
    // repository even when no PIN is configured.
    unawaited(_loadSettings());
  }

  @override
  void dispose() {
    _pinTimer?.cancel();
    _shakeCtl.dispose();
    super.dispose();
  }

  Future<AppSettings> _loadSettings() async {
    if (_settings != null) return _settings!;
    if (_loadingSettings) {
      // Yield until the in-flight load completes; this avoids two parallel
      // disk reads if the user taps cancel before initState's load lands.
      while (_loadingSettings && mounted) {
        await Future<void>.delayed(const Duration(milliseconds: 16));
      }
      return _settings ?? const AppSettings();
    }
    _loadingSettings = true;
    try {
      final settings = await ref.read(appSettingsRepositoryProvider).load();
      if (mounted) {
        setState(() => _settings = settings);
      } else {
        _settings = settings;
      }
      return settings;
    } finally {
      _loadingSettings = false;
    }
  }

  Future<void> _onCancelTapped() async {
    final settings = await _loadSettings();
    if (!mounted) return;
    if (settings.sessionEndPinHash == null) {
      // No PIN gate — preserve the legacy fast-path.
      ref.read(sessionControllerProvider.notifier).cancelDistress();
      return;
    }
    // Pause the visible 5-second countdown so the PIN window is
    // unaffected by the parent countdown finishing under the keypad
    // (spec 04 §Distress Confirmation Window — task brief §4).
    ref.read(sessionControllerProvider.notifier).pauseDistressCountdown();
    setState(() {
      _stage = _DistressStage.pinPrompt;
      _entry.clear();
      _showWrong = false;
      _showAppPinMismatch = false;
      _pinTimeoutRemaining = settings.pinTimeoutSeconds;
    });
    _startPinTimer();
  }

  void _startPinTimer() {
    _pinTimer?.cancel();
    _pinTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      final next = _pinTimeoutRemaining - 1;
      if (next <= 0) {
        t.cancel();
        _onPinTimeoutExpired();
        return;
      }
      setState(() => _pinTimeoutRemaining = next);
    });
  }

  void _onPinTimeoutExpired() {
    // Timeout fires the distress chain immediately. We avoid resuming
    // the 5-second countdown because [confirmDistress] dismisses the
    // overlay regardless.
    if (!mounted) return;
    ref
        .read(sessionControllerProvider.notifier)
        .confirmDistress(reason: EndReason.distressConfirmTimeout);
  }

  void _backToConfirmation() {
    _pinTimer?.cancel();
    _pinTimer = null;
    setState(() {
      _stage = _DistressStage.confirmation;
      _entry.clear();
      _showWrong = false;
      _showAppPinMismatch = false;
    });
    ref.read(sessionControllerProvider.notifier).resumeDistressCountdown();
  }

  Future<void> _onDigit(int d) async {
    if (_entry.length >= kPinMaxLength) return;
    setState(() {
      _entry.add(d);
      _showWrong = false;
      _showAppPinMismatch = false;
    });
    if (_entry.length < kPinMinLength) return;
    await _tryAutoSubmit();
  }

  void _onBackspace() {
    if (_entry.isEmpty) return;
    setState(() {
      _entry.removeLast();
      _showWrong = false;
      _showAppPinMismatch = false;
    });
  }

  Future<void> _tryAutoSubmit() async {
    final settings = _settings;
    if (settings == null) return;
    // Walk every prefix length `n in [kPinMinLength..entry.length]` and try
    // the priority ladder Duress > App > Session End. Mirrors the C2 end-
    // session overlay (spec 06 §Auto-submit, F-149, R-27).
    for (int n = kPinMinLength; n <= _entry.length; n++) {
      final digits = _entry.take(n).join();
      final hash = sha256.convert(utf8.encode(digits)).toString();
      if (settings.duressPinHash != null && settings.duressPinHash == hash) {
        ref.read(sessionControllerProvider.notifier).resetWrongPinAttempts();
        _pinTimer?.cancel();
        _pinTimer = null;
        ref
            .read(sessionControllerProvider.notifier)
            .confirmDistress(reason: EndReason.duressPin);
        return;
      }
      if (settings.appPinHash != null && settings.appPinHash == hash) {
        setState(() {
          _entry.clear();
          _showAppPinMismatch = true;
          _showWrong = false;
        });
        return;
      }
      if (settings.sessionEndPinHash != null &&
          settings.sessionEndPinHash == hash) {
        ref.read(sessionControllerProvider.notifier).resetWrongPinAttempts();
        _pinTimer?.cancel();
        _pinTimer = null;
        ref.read(sessionControllerProvider.notifier).cancelDistress();
        return;
      }
    }
    // Count a wrong attempt only at the max length with no match — a shorter
    // non-match may be a prefix of a longer correct PIN; counting it early
    // would block 5–8 digit PINs and fire a false distress on a legit user.
    if (_entry.length >= kPinMaxLength) {
      await _handleWrongPin();
    }
  }

  Future<void> _handleWrongPin() async {
    final settings = _settings;
    if (settings == null) return;

    if (widget.state.isSimulation) {
      // Simulation never advances the real wrong-PIN counter and never
      // fires the distress chain (spec 04:548). A local counter drives
      // the educational SnackBar.
      _simWrongAttempts += 1;
      final messenger = ScaffoldMessenger.maybeOf(context);
      await _showWrongFeedback(settings);
      if (!mounted) return;
      if (_simWrongAttempts >= settings.wrongPinThreshold) {
        messenger?.showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).distressCancelSimDistressWouldFire,
            ),
          ),
        );
        setState(() {
          _entry.clear();
          _showWrong = true;
          _simWrongAttempts = 0;
        });
        return;
      }
      setState(() {
        _entry.clear();
        _showWrong = true;
      });
      return;
    }

    final controller = ref.read(sessionControllerProvider.notifier);
    final attempts = controller.notifyWrongPinAttempt();
    await _showWrongFeedback(settings);
    if (!mounted) return;
    if (attempts >= settings.wrongPinThreshold) {
      _pinTimer?.cancel();
      _pinTimer = null;
      controller.confirmDistress(reason: EndReason.wrongPinExhausted);
      return;
    }
    setState(() {
      _entry.clear();
      _showWrong = true;
    });
  }

  Future<void> _showWrongFeedback(AppSettings settings) async {
    if (settings.deceptivePinDialogEnabled) {
      await DeceptiveOldPinDialog.show(context);
      return;
    }
    await _shakeCtl.forward();
    if (!mounted) return;
    _shakeCtl.reset();
  }

  void _onSimSkip() {
    _pinTimer?.cancel();
    _pinTimer = null;
    ref.read(sessionControllerProvider.notifier).cancelDistress();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.state.distressConfirmRemaining ?? 0;
    return ColoredBox(
      color: Colors.red.shade900.withValues(alpha: 0.95),
      child: SafeArea(
        child: switch (_stage) {
          _DistressStage.confirmation => _DistressConfirmationStage(
            remainingSeconds: remaining,
            onCancel: _onCancelTapped,
          ),
          _DistressStage.pinPrompt => _DistressPinPromptStage(
            entryLength: _entry.length,
            timeoutRemaining: _pinTimeoutRemaining,
            showWrong: _showWrong,
            showAppPinMismatch: _showAppPinMismatch,
            shakeAnim: _shakeAnim,
            isSimulation: widget.state.isSimulation,
            onDigit: _onDigit,
            onBackspace: _onBackspace,
            onCancel: _backToConfirmation,
            onSimSkip: widget.state.isSimulation ? _onSimSkip : null,
          ),
        },
      ),
    );
  }
}

class _DistressConfirmationStage extends StatelessWidget {
  const _DistressConfirmationStage({
    required this.remainingSeconds,
    required this.onCancel,
  });

  final int remainingSeconds;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.warning_amber, size: 64, color: Colors.yellow.shade300),
            const SizedBox(height: 16),
            Text(
              l10n.distressConfirmTitle,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.distressConfirmCountdown(remainingSeconds),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: remainingSeconds / 5.0,
                      strokeWidth: 8,
                      color: Colors.white,
                    ),
                  ),
                  FilledButton(
                    onPressed: onCancel,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red.shade900,
                    ),
                    child: Text(l10n.distressConfirmCancel),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.distressConfirmFooter,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DistressPinPromptStage extends StatelessWidget {
  const _DistressPinPromptStage({
    required this.entryLength,
    required this.timeoutRemaining,
    required this.showWrong,
    required this.showAppPinMismatch,
    required this.shakeAnim,
    required this.isSimulation,
    required this.onDigit,
    required this.onBackspace,
    required this.onCancel,
    required this.onSimSkip,
  });

  final int entryLength;
  final int timeoutRemaining;
  final bool showWrong;
  final bool showAppPinMismatch;
  final Animation<double> shakeAnim;
  final bool isSimulation;
  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onCancel;
  final VoidCallback? onSimSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Icon(Icons.lock_outline, size: 48, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            l10n.distressCancelPinPromptTitle,
            style: textTheme.headlineSmall?.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.distressCancelPinTimeoutLabel(timeoutRemaining),
            style: textTheme.titleMedium?.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: shakeAnim,
            builder: (BuildContext _, Widget? child) {
              return Transform.translate(
                offset: Offset(shakeAnim.value, 0),
                child: child,
              );
            },
            child: Text(
              List<String>.generate(
                entryLength < 4 ? 4 : entryLength,
                (int i) => i < entryLength ? '●' : '○',
              ).join(' '),
              style: textTheme.headlineMedium?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          if (showAppPinMismatch) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              l10n.distressCancelPinAppPinMismatch,
              style: textTheme.bodySmall?.copyWith(
                color: Colors.yellow.shade300,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (showWrong) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              l10n.distressCancelPinIncorrect,
              style: textTheme.bodySmall?.copyWith(
                color: Colors.yellow.shade300,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          PinKeypad(onDigit: onDigit, onBackspace: onBackspace),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: Text(l10n.distressCancelPinBack),
              ),
              if (onSimSkip != null)
                TextButton(
                  onPressed: onSimSkip,
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: Text(l10n.distressCancelPinSimSkip),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GpsDestinationPrompt extends ConsumerStatefulWidget {
  const _GpsDestinationPrompt();

  @override
  ConsumerState<_GpsDestinationPrompt> createState() =>
      _GpsDestinationPromptState();
}

class _GpsDestinationPromptState extends ConsumerState<_GpsDestinationPrompt> {
  final TextEditingController _latCtl = TextEditingController();
  final TextEditingController _lngCtl = TextEditingController();

  @override
  void dispose() {
    _latCtl.dispose();
    _lngCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Positioned.fill(
      child: Material(
        color: Colors.black54,
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    l10n.sessionGpsDestinationTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.sessionGpsDestinationBody),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _latCtl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.sessionGpsDestinationLat,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _lngCtl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.sessionGpsDestinationLng,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextButton(
                          onPressed: () => ref
                              .read(sessionControllerProvider.notifier)
                              .skipGpsDestination(),
                          child: Text(l10n.sessionGpsDestinationSkip),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          onPressed: _confirm,
                          child: Text(l10n.sessionGpsDestinationConfirm),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirm() {
    final lat = double.tryParse(_latCtl.text);
    final lng = double.tryParse(_lngCtl.text);
    if (lat == null || lng == null) {
      return;
    }
    ref
        .read(sessionControllerProvider.notifier)
        .setGpsDestination(lat: lat, lng: lng);
  }
}

/// Grace-period "I'm Safe" disarm slider.
///
/// Spec 04 §Grace Period Slider requires an 85 %-threshold swipe (not a
/// tap) so a stray screen-press during a live session cannot disarm the
/// chain. The reusable [SwipeSlider] enforces the threshold, the
/// spring-back animation on incomplete release, and the single-fire-per-
/// gesture guard. [label] is the stealth-aware string chosen at the
/// call-site ("I'm safe" in normal mode, "No Angela needed" when
/// `SessionState.stealthEnabled` is true).
class _DisarmAction extends StatelessWidget {
  const _DisarmAction({required this.onDisarm, required this.label});

  final VoidCallback onDisarm;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SwipeSlider(label: label, onConfirm: onDisarm, threshold: 0.85);
  }
}

class _SimulationControlsBar extends ConsumerWidget {
  const _SimulationControlsBar({required this.state, required this.textTheme});

  final SessionState state;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Card(
      color: Colors.orange.withValues(alpha: 0.1),
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text('${state.simSpeedMultiplier.toStringAsFixed(1)}x'),
                Expanded(
                  child: Slider(
                    value: state.simSpeedMultiplier.clamp(1, 1000),
                    min: 1,
                    max: 1000,
                    divisions: 100,
                    label: '${state.simSpeedMultiplier.toStringAsFixed(0)}x',
                    onChanged: (double v) => ref
                        .read(sessionControllerProvider.notifier)
                        .setSimulationSpeed(v),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                IconButton(
                  tooltip: 'Leap',
                  icon: const Icon(Icons.fast_forward),
                  onPressed: () =>
                      ref.read(sessionControllerProvider.notifier).leap(),
                ),
                const Spacer(),
                Text(l10n.sessionSimulationBanner),
                const SizedBox(width: 8),
                Switch(
                  value: state.simulationSilent,
                  onChanged: (bool v) => ref
                      .read(sessionControllerProvider.notifier)
                      .setSimulationSilent(v),
                ),
                Icon(
                  state.simulationSilent
                      ? Icons.volume_off
                      : Icons.volume_up_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step UIs ────────────────────────────────────────────────────────────

class _HoldButtonStepUi extends ConsumerWidget {
  const _HoldButtonStepUi({required this.state, required this.step});

  final SessionState state;
  final ChainStep step;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final config = step.config;
    final holdConfig = config is HoldButtonConfig ? config : null;
    final colorScheme = Theme.of(context).colorScheme;
    final isHolding = state.isHolding;
    final isGrace = state.phase == SessionPhase.grace;
    final isSensitivity = state.phase == SessionPhase.sensitivity;
    final color = isHolding
        ? colorScheme.primary
        : (isGrace
              ? Colors.red.shade600
              : (isSensitivity ? Colors.amber.shade700 : colorScheme.primary));
    final blackScreen = holdConfig?.blackScreenMode ?? false;
    if (blackScreen) {
      return _BlackScreenHoldUi(ref: ref, l10n: l10n, isHolding: isHolding);
    }
    return GestureDetector(
      onTapDown: (_) =>
          ref.read(sessionControllerProvider.notifier).holdPressed(),
      onTapUp: (_) =>
          ref.read(sessionControllerProvider.notifier).holdReleased(),
      onTapCancel: () =>
          ref.read(sessionControllerProvider.notifier).holdReleased(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              _holdLabel(state, l10n),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: colorScheme.onPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Text(_holdPrompt(state, l10n), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  String _holdLabel(SessionState state, AppLocalizations l10n) {
    if (state.phase == SessionPhase.holdWait) {
      return 'HOLD';
    }
    if (state.isHolding) {
      return 'HOLD';
    }
    final remaining = state.remainingSeconds;
    if (remaining != null && remaining > 0) {
      return remaining.toString();
    }
    return 'HOLD';
  }

  String _holdPrompt(SessionState state, AppLocalizations l10n) {
    if (state.phase == SessionPhase.holdWait) {
      return l10n.sessionHoldTouchToBegin;
    }
    if (state.isHolding) {
      return l10n.sessionHoldPrompt;
    }
    if (state.phase == SessionPhase.grace) {
      return l10n.sessionHoldGraceCountdown(
        (state.remainingSeconds ?? 0).toString(),
      );
    }
    if (state.phase == SessionPhase.sensitivity) {
      return l10n.sessionHoldReleaseCountdown(
        (state.remainingSeconds ?? 0).toString(),
      );
    }
    return l10n.sessionHoldAgain;
  }
}

class _BlackScreenHoldUi extends StatelessWidget {
  const _BlackScreenHoldUi({
    required this.ref,
    required this.l10n,
    required this.isHolding,
  });

  final WidgetRef ref;
  final AppLocalizations l10n;
  final bool isHolding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) =>
          ref.read(sessionControllerProvider.notifier).holdPressed(),
      onTapUp: (_) =>
          ref.read(sessionControllerProvider.notifier).holdReleased(),
      onTapCancel: () =>
          ref.read(sessionControllerProvider.notifier).holdReleased(),
      child: Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: Text(
          isHolding ? l10n.sessionHoldPrompt : l10n.sessionHoldTouchToBegin,
          style: const TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}

class _DisguisedReminderStepUi extends ConsumerWidget {
  const _DisguisedReminderStepUi({required this.state, required this.step});

  final SessionState state;
  final ChainStep step;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.phase == SessionPhase.duration) {
      return _DisguisedReminderFired(template: state.activeReminderTemplate);
    }
    return _DisguisedReminderWaiting(state: state, step: step);
  }
}

/// The reminder is on-screen (duration phase): render the selected disguise
/// and its confirmation interaction, falling back to a generic card when no
/// template was resolved. `subtle` templates show here; `fullScreen` ones are
/// covered by the [DisguisedReminderScreen] route pushed over this surface.
class _DisguisedReminderFired extends ConsumerWidget {
  const _DisguisedReminderFired({required this.template});

  final ReminderTemplate? template;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    void checkIn() => ref.read(sessionControllerProvider.notifier).disarm();

    final resolved = template;
    final content = resolved != null
        ? ReminderDisguiseContent(template: resolved, onConfirm: checkIn)
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.notifications_active,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.sessionStepDisguisedDefaultTitle,
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.sessionStepDisguisedDefaultBody,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: checkIn,
                child: Text(l10n.sessionCheckIn),
              ),
            ],
          );
    return Card(
      child: Padding(padding: const EdgeInsets.all(24), child: content),
    );
  }
}

/// The wait phase between reminders: shows the time to the next check-in and
/// lets the user check in early by tapping (spec 02 §Early Check-in, D4). The
/// engine ignores the tap when the step's `resetOnEarlyCheckIn` is false.
class _DisguisedReminderWaiting extends ConsumerWidget {
  const _DisguisedReminderWaiting({required this.state, required this.step});

  final SessionState state;
  final ChainStep step;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final remaining = state.remainingSeconds ?? step.waitSeconds;
    return InkWell(
      onTap: () => ref.read(sessionControllerProvider.notifier).earlyCheckIn(),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.shield_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.sessionStepNextCheckIn(_formatDuration(remaining)),
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.sessionReminderEarlyCheckInHint,
              style: textTheme.bodySmall,
            ),
            if (state.missCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(l10n.sessionMissCount(state.missCount.toString())),
              ),
          ],
        ),
      ),
    );
  }
}

class _CountdownWarningStepUi extends StatelessWidget {
  const _CountdownWarningStepUi({required this.state, required this.step});

  final SessionState state;
  final ChainStep step;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final remaining = state.remainingSeconds ?? step.durationSeconds;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(Icons.warning_amber, size: 64, color: Colors.amber.shade700),
        const SizedBox(height: 12),
        Text(
          l10n.sessionStepCountdownTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(l10n.sessionStepCountdownBody, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Text(
          remaining.toString(),
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ],
    );
  }
}

class _FakeCallStepUi extends ConsumerWidget {
  const _FakeCallStepUi({required this.state, required this.step});

  final SessionState state;
  final ChainStep step;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final config = step.config;
    final callerName = config is FakeCallConfig ? config.callerName : 'Angela';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.phone_in_talk, size: 64),
        const SizedBox(height: 12),
        Text(
          l10n.sessionStepFakeCallActive(callerName),
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          icon: const Icon(Icons.open_in_new),
          label: Text(l10n.sessionStepFakeCallOpen),
          // Manual re-open fallback (the call also auto-appears). Pass the
          // step's config so callerName / declineIsSafe / voice are honoured
          // — without `extra` the screen would fall back to defaults.
          onPressed: () =>
              context.pushNamed(RouteNames.fakeCall, extra: step.config),
        ),
      ],
    );
  }
}

class _SmsContactStepUi extends StatelessWidget {
  const _SmsContactStepUi({required this.state, required this.step});

  final SessionState state;
  final ChainStep step;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.sms_outlined, size: 64),
        const SizedBox(height: 12),
        Text(l10n.sessionStepSmsStatus, style: textTheme.titleMedium),
        if (state.isSimulation)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(l10n.sessionStepSimBlockedSms('—')),
          ),
      ],
    );
  }
}

class _PhoneCallContactStepUi extends StatelessWidget {
  const _PhoneCallContactStepUi({required this.state, required this.step});

  final SessionState state;
  final ChainStep step;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.phone_forwarded, size: 64),
        const SizedBox(height: 12),
        Text(
          l10n.sessionStepPhoneCallStatus,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (state.isSimulation)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(l10n.sessionStepSimBlockedPhone),
          ),
      ],
    );
  }
}

class _LoudAlarmStepUi extends StatelessWidget {
  const _LoudAlarmStepUi({required this.state, required this.step});

  final SessionState state;
  final ChainStep step;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final config = step.config;
    final flash = config is LoudAlarmConfig && config.flashScreen;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(Icons.volume_up, size: 64, color: Colors.red.shade700),
        const SizedBox(height: 12),
        Text(
          l10n.sessionStepLoudAlarmTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(l10n.sessionStepLoudAlarmBody, textAlign: TextAlign.center),
        if (flash)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.sessionStepLoudAlarmFlashWarning,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        if (state.isSimulation)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(l10n.sessionStepSimBlockedAlarm),
          ),
      ],
    );
  }
}

class _CallEmergencyStepUi extends StatelessWidget {
  const _CallEmergencyStepUi({required this.state, required this.step});

  final SessionState state;
  final ChainStep step;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final config = step.config;
    final number = config is CallEmergencyConfig
        ? (config.emergencyNumber ?? '112')
        : '112';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(Icons.emergency, size: 64, color: Colors.red.shade700),
        const SizedBox(height: 12),
        Text(
          l10n.sessionStepCallEmergencyStatus,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(l10n.sessionStepCallEmergencyNumber(number)),
        if (state.isSimulation)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(l10n.sessionStepSimBlockedEmergency),
          ),
      ],
    );
  }
}

class _HardwareButtonStepUi extends StatelessWidget {
  const _HardwareButtonStepUi({required this.state, required this.step});

  final SessionState state;
  final ChainStep step;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cfg = step.config;
    final hw = cfg is HardwareButtonConfig ? cfg : null;
    final isRepeat = (hw?.pressPattern.name ?? 'repeatPress') == 'repeatPress';
    final buttonLabel = switch (hw?.buttonType.name) {
      'volumeUp' => l10n.sessionStepHardwareButtonVolumeUp,
      'volumeDown' => l10n.sessionStepHardwareButtonVolumeDown,
      _ => l10n.sessionStepHardwareButtonPower,
    };
    final body = isRepeat
        ? l10n.sessionStepHardwareButtonRepeat(
            buttonLabel,
            (hw?.pressCount ?? 5).toString(),
            '1500',
          )
        : l10n.sessionStepHardwareButtonLong(
            buttonLabel,
            (hw?.longPressDurationSeconds ?? 2).toString(),
          );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.touch_app, size: 64),
        const SizedBox(height: 12),
        Text(body, textAlign: TextAlign.center),
      ],
    );
  }
}

String _formatDuration(int seconds) {
  if (seconds < 60) return '${seconds}s';
  final m = seconds ~/ 60;
  final s = seconds % 60;
  if (s == 0) return '${m}m';
  return '${m}m ${s}s';
}
