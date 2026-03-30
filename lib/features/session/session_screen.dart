import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/pride_widgets.dart';
import '../../data/models/session_mode.dart';
import '../../data/models/walk_session.dart';
import '../../l10n/app_localizations.dart';
import 'reminder_controller.dart';
import 'session_controller.dart';
import 'widgets/disguised_reminder_overlay.dart';
import 'widgets/hold_button.dart';
import 'widgets/session_timer_display.dart';

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  Timer? _elapsedTimer;
  Duration _elapsed = Duration.zero;
  DateTime? _sessionStart;

  @override
  void initState() {
    super.initState();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_sessionStart != null && mounted) {
        setState(() {
          _elapsed = DateTime.now().difference(_sessionStart!);
        });
      }
    });
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    super.dispose();
  }

  /// Compute a 0..1 progress value for the pride progress bar.
  /// We cycle through a 10-minute window so it loops smoothly.
  double get _sessionProgress {
    final totalSeconds = _elapsed.inSeconds;
    if (totalSeconds <= 0) return 0.0;
    // Cycle over 10 minutes
    return (totalSeconds % 600) / 600.0;
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (session == null) {
      // Session ended, pop back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && context.canPop()) context.pop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    _sessionStart ??= session.startTime;

    final engine = ref.read(sessionControllerProvider.notifier).engine;
    final isWalkMode = engine?.mechanism == CheckInMechanism.holdButton;
    final activeReminder = ref.watch(reminderControllerProvider);

    // Fire a disguised reminder when session enters checkInPrompt in date mode
    // and when a disguised reminder step fires during escalation
    ref.listen(sessionControllerProvider, (prev, next) {
      if (next == null || isWalkMode) return;
      final prevState = prev?.state;
      final nextState = next.state;
      if (prevState != nextState &&
          (nextState == SessionState.checkInPrompt) &&
          activeReminder == null) {
        ref
            .read(reminderControllerProvider.notifier)
            .fireReminder(modeId: next.modeId);
      }
    });

    // Haptic feedback on session state transitions
    ref.listen(sessionControllerProvider, (prev, next) {
      if (next == null) return;
      final prevState = prev?.state;
      final nextState = next.state;
      if (prevState == nextState) return;
      switch (nextState) {
        case SessionState.active:
          HapticFeedback.lightImpact();
        case SessionState.checkInPrompt:
          HapticFeedback.mediumImpact();
        case SessionState.warning:
        case SessionState.fakeCall:
        case SessionState.smsSent:
        case SessionState.alarm:
        case SessionState.emergencyCall:
          HapticFeedback.heavyImpact();
        default:
          break;
      }
    });

    final stateColor = _stateColor(session.state);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      color: stateColor.withValues(alpha: 0.05),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Pride progress bar at the top
                PrideProgressBar.gradient(progress: _sessionProgress),
                Expanded(
                  child: isWalkMode
                      ? _WalkModeBody(
                          session: session,
                          elapsed: _elapsed,
                          l10n: l10n,
                          theme: theme,
                        )
                      : _DateModeBody(
                          session: session,
                          elapsed: _elapsed,
                          l10n: l10n,
                          theme: theme,
                        ),
                ),
              ],
            ),
            // Disguised reminder overlay
            if (activeReminder != null)
              DisguisedReminderOverlay(
                template: activeReminder.template,
                onConfirmed: () {
                  ref.read(reminderControllerProvider.notifier).confirm();
                  ref.read(sessionControllerProvider.notifier).checkIn();
                },
              ),
          ],
        ),
      ),
      ),
    );
  }
}

// -- Walk Mode UI --

class _WalkModeBody extends ConsumerWidget {
  final WalkSession session;
  final Duration elapsed;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _WalkModeBody({
    required this.session,
    required this.elapsed,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(sessionControllerProvider.notifier);

    return Column(
      children: [
        // Top bar with end session and elapsed
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: controller.endSession,
                icon: const Icon(Icons.close),
                label: Text(l10n.endSession),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              SessionTimerDisplay(elapsed: elapsed),
            ],
          ),
        ),
        // Status text
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _stateIcon(session.state),
                  size: 48,
                  color: _stateColor(session.state),
                ),
                const SizedBox(height: 16),
                Text(
                  _stateLabel(session.state, l10n),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: _stateColor(session.state),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        // Hold button in bottom third
        Padding(
          padding: const EdgeInsets.only(bottom: 64, left: 32, right: 32),
          child: HoldButton(
            state: session.state,
            onHoldStart: () {
              HapticFeedback.mediumImpact();
              controller.holdStart();
            },
            onHoldRelease: () {
              HapticFeedback.lightImpact();
              controller.holdRelease();
            },
          ),
        ),
      ],
    );
  }
}

// -- Date Mode UI --

class _DateModeBody extends ConsumerWidget {
  final WalkSession session;
  final Duration elapsed;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _DateModeBody({
    required this.session,
    required this.elapsed,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(sessionControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Top bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: controller.endSession,
                icon: const Icon(Icons.close),
                label: Text(l10n.endSession),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              SessionTimerDisplay(elapsed: elapsed),
            ],
          ),
          const Spacer(),
          // Status indicator
          Icon(
            _stateIcon(session.state),
            size: 80,
            color: _stateColor(session.state),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.sessionActive,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _stateLabel(session.state, l10n),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: _stateColor(session.state),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.dateMode,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const Spacer(),
          // "I'm OK" check-in button
          SizedBox(
            width: double.infinity,
            height: 64,
            child: FilledButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                controller.checkIn();
              },
              icon: const Icon(Icons.check_circle_outline, size: 28),
              label: Text(
                l10n.imSafe,
                style: const TextStyle(fontSize: 20),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _stateColor(session.state),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// -- Shared helpers --

Color _stateColor(SessionState state) {
  return switch (state) {
    SessionState.active || SessionState.idle || SessionState.completed =>
      AppColors.safe,
    SessionState.checkInPrompt || SessionState.warning => AppColors.warning,
    _ => AppColors.danger,
  };
}

IconData _stateIcon(SessionState state) {
  return switch (state) {
    SessionState.active || SessionState.idle => Icons.shield,
    SessionState.checkInPrompt => Icons.warning_amber_rounded,
    SessionState.warning => Icons.timer,
    SessionState.fakeCall => Icons.phone,
    SessionState.smsSent => Icons.sms,
    SessionState.alarm => Icons.volume_up,
    SessionState.emergencyCall => Icons.emergency,
    SessionState.completed => Icons.check_circle,
  };
}

String _stateLabel(SessionState state, AppLocalizations l10n) {
  return switch (state) {
    SessionState.active || SessionState.idle => l10n.holdToStaySafe,
    SessionState.checkInPrompt => l10n.checkInPrompt,
    SessionState.warning => l10n.releaseDetected,
    SessionState.fakeCall => l10n.fakeCallIncoming,
    SessionState.smsSent => l10n.stepSmsContacts,
    SessionState.alarm => l10n.stepLoudAlarm,
    SessionState.emergencyCall => l10n.stepCallEmergency,
    SessionState.completed => l10n.endSession,
  };
}
