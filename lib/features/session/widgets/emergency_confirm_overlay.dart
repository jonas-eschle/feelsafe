import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/core/widgets/swipe_slider.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Pre-dial confirmation overlay shown during the `duration` phase of a
/// [ChainStep] of type `callEmergency`.
///
/// Implements spec 02 §`callEmergency` (lines 457–460) + Extra 56:
/// while the engine is in the `duration` phase the user sees a
/// fullscreen modal with a `LinearProgressIndicator` driven by the
/// remaining duration, a `[Keep calling]` button, and a `SwipeSlider`
/// that fires `onConfirm` once the user drags the knob past 70 % of
/// the track width (cancel-emergency-call).
///
/// **Cancel semantics:** when the user successfully swipes-to-cancel
/// we treat the action as an explicit user-quit and end the session
/// via [SessionController.endSession] (defaults to `userQuit`). The
/// spec does not expose a "skip current step" affordance and the
/// engine has no per-step abort, so the cleanest interpretation of a
/// deliberate emergency-cancel swipe is "do not continue the chain".
///
/// **Keep calling:** dismisses the overlay locally via
/// [onKeepCalling]; the parent screen short-circuits subsequent
/// renders until the duration phase ends so the user can finish the
/// dialing flow. The engine timer keeps ticking — the overlay is not
/// a pause.
///
/// **Simulation:** in `state.isSimulation` mode the overlay shows a
/// `[SIM]` badge. Swipe-to-cancel does NOT end the session; instead
/// it surfaces a SnackBar describing the would-be outcome (no real
/// call would have been placed) and dismisses the overlay so the
/// simulation can progress.
class EmergencyConfirmOverlay extends ConsumerWidget {
  /// Creates an [EmergencyConfirmOverlay].
  ///
  /// [globalEmergencyNumber] defaults to null and falls through to
  /// `'112'` when neither the per-step override
  /// ([CallEmergencyConfig.emergencyNumber]) nor a global default has
  /// been threaded in. Spec 02:451 — resolution order is per-step →
  /// `AppSettings.emergencyCallNumber` → hard-coded fallback.
  const EmergencyConfirmOverlay({
    super.key,
    required this.state,
    required this.step,
    required this.onKeepCalling,
    this.globalEmergencyNumber,
  });

  /// Current session state — drives the countdown and SIM badge.
  final SessionState state;

  /// The active call-emergency [ChainStep] (used to read its config).
  final ChainStep step;

  /// Called when the user taps `[Keep calling]`. The session screen
  /// uses this to suppress further overlay renders for the current
  /// step's duration phase.
  final VoidCallback onKeepCalling;

  /// Optional global emergency number sourced from
  /// `AppSettings.emergencyCallNumber`. Null = unknown; the overlay
  /// falls back to `'112'`.
  final String? globalEmergencyNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final config = step.config;
    final perStepOverride = config is CallEmergencyConfig
        ? config.emergencyNumber
        : null;
    final number = _firstNonBlank(
      perStepOverride,
      globalEmergencyNumber,
      '112',
    );
    final totalSeconds = (config is CallEmergencyConfig)
        ? config.confirmationDurationSeconds
        : step.durationSeconds;
    final remaining = state.remainingSeconds ?? totalSeconds;
    final progress = totalSeconds <= 0
        ? 1.0
        : (1 - remaining / totalSeconds).clamp(0.0, 1.0);
    return Positioned.fill(
      child: Material(
        color: cs.error.withValues(alpha: 0.95),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext _, BoxConstraints constraints) {
              final cardWidth = constraints.maxWidth.isFinite
                  ? (constraints.maxWidth - 48).clamp(120.0, 560.0)
                  : 360.0;
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Center(
                  child: SizedBox(
                    width: cardWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        if (state.isSimulation)
                          Align(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  l10n.sessionEmergencyConfirmSimBadge,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Icon(Icons.emergency, size: 96, color: cs.onError),
                        const SizedBox(height: 16),
                        Text(
                          l10n.sessionEmergencyConfirmTitle(number, remaining),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: cs.onError,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: cs.onError.withValues(alpha: 0.2),
                            color: cs.onError,
                          ),
                        ),
                        const SizedBox(height: 32),
                        SwipeSlider(
                          label: l10n.sessionEmergencyConfirmSwipe,
                          onConfirm: () => _onCancelSwipe(context, ref),
                          trackColor: cs.onError.withValues(alpha: 0.15),
                          knobColor: cs.onError,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: onKeepCalling,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            backgroundColor: cs.onError,
                            foregroundColor: cs.error,
                          ),
                          child: Text(l10n.sessionEmergencyConfirmKeep),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _onCancelSwipe(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(sessionControllerProvider.notifier);
    if (state.isSimulation) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(
        SnackBar(content: Text(l10n.sessionEmergencyConfirmSimCancelled)),
      );
      onKeepCalling();
      return;
    }
    // EndReason.userQuit is the default but we name it here so readers
    // can grep for "emergency-cancel ends session" and so the call site
    // stays explicit if the default ever changes.
    await controller.endSession();
  }

  static String _firstNonBlank(String? a, String? b, String fallback) {
    final av = a?.trim();
    if (av != null && av.isNotEmpty) return av;
    final bv = b?.trim();
    if (bv != null && bv.isNotEmpty) return bv;
    return fallback;
  }
}
