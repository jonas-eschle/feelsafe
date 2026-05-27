import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Active session screen.
///
/// Orientation is locked to portrait (D3) while this screen is mounted.
/// Renders different UI per [ChainStepType], with overlays for distress
/// confirmation, GPS destination prompts, and the interrupted-session
/// prompt. See spec 04 §Session Screen + §Step-Specific UI.
class SessionScreen extends ConsumerStatefulWidget {
  /// Creates a [SessionScreen].
  const SessionScreen({super.key});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);
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
            onPressed: () => _confirmEnd(context),
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

  Future<void> _confirmEnd(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(l10n.sessionEndConfirmTitle),
        content: Text(l10n.sessionEndConfirmSwipe),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );
    if (shouldEnd == true && context.mounted) {
      await ref.read(sessionControllerProvider.notifier).endSession();
      if (!context.mounted) return;
      context.goNamed(RouteNames.sessionCompleted);
    }
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

class _SessionRoot extends ConsumerWidget {
  const _SessionRoot({required this.state});

  final SessionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.priorInterrupted) {
      return _InterruptedPrompt(state: state);
    }
    if (state.distressConfirmRemaining != null) {
      return _DistressConfirmationOverlay(state: state);
    }
    return Stack(
      children: <Widget>[
        _SessionBody(state: state),
        if (state.isSimulation) const _SimulationBanner(),
        if (state.needsGpsDestinationPrompt) const _GpsDestinationPrompt(),
        if (state.lastError != null) _ErrorBanner(message: state.lastError!),
      ],
    );
  }
}

class _SessionBody extends ConsumerWidget {
  const _SessionBody({required this.state});

  final SessionState state;

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
                child: switch (step?.type) {
                  null => Text(l10n.sessionPhaseEnded),
                  ChainStepType.holdButton => _HoldButtonStepUi(
                    state: state,
                    step: step!,
                  ),
                  ChainStepType.disguisedReminder => _DisguisedReminderStepUi(
                    state: state,
                    step: step!,
                  ),
                  ChainStepType.countdownWarning => _CountdownWarningStepUi(
                    state: state,
                    step: step!,
                  ),
                  ChainStepType.fakeCall => _FakeCallStepUi(
                    state: state,
                    step: step!,
                  ),
                  ChainStepType.smsContact => _SmsContactStepUi(
                    state: state,
                    step: step!,
                  ),
                  ChainStepType.phoneCallContact => _PhoneCallContactStepUi(
                    state: state,
                    step: step!,
                  ),
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
                label: l10n.sessionDisarm,
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
          Chip(label: Text(l10n.sessionPausedBadge)),
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

class _DistressConfirmationOverlay extends ConsumerWidget {
  const _DistressConfirmationOverlay({required this.state});

  final SessionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final remaining = state.distressConfirmRemaining ?? 0;
    return ColoredBox(
      color: Colors.red.shade900.withValues(alpha: 0.95),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.warning_amber,
                size: 64,
                color: Colors.yellow.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.distressConfirmTitle,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.distressConfirmCountdown(remaining),
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
                        value: remaining / 5.0,
                        strokeWidth: 8,
                        color: Colors.white,
                      ),
                    ),
                    FilledButton(
                      onPressed: () => ref
                          .read(sessionControllerProvider.notifier)
                          .cancelDistress(),
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

class _DisarmAction extends StatelessWidget {
  const _DisarmAction({required this.onDisarm, required this.label});

  final VoidCallback onDisarm;
  final String label;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      icon: const Icon(Icons.check_circle_outline),
      label: Text(label),
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      onPressed: onDisarm,
    );
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
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    if (state.phase == SessionPhase.duration) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.notifications_active,
            size: 64,
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
            onPressed: () =>
                ref.read(sessionControllerProvider.notifier).disarm(),
            child: Text(l10n.sessionCheckIn),
          ),
        ],
      );
    }
    final remaining = state.remainingSeconds ?? step.waitSeconds;
    return Column(
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
        if (state.missCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(l10n.sessionMissCount(state.missCount.toString())),
          ),
      ],
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
          onPressed: () => context.pushNamed(RouteNames.fakeCall),
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
