/// Distress orchestration controller — distress-chain firing.
///
/// One of the four sub-controllers Q48 splits
/// `SessionController` into. Owns every code path that swaps the
/// active engine chain for the resolved distress chain:
///
///   * `triggerDistressChain(triggerReason)` — generic entry point
///     used by hardware panic, simulation panic button, fake-call
///     decline-with-distress.
///   * `fireBecauseOfPin(reason)` — wrong-PIN-threshold + duress-PIN
///     paths; gates on the deceptive "Old PIN from Angela" dialog
///     (Q17) before firing.
///
/// The deceptive-dialog callback ([onAngelaDeceptiveDialog]) is a
/// safety-critical UI hook. B3 fix: any exception thrown by the
/// dialog is swallowed so an OS-side dismissal cannot leave an
/// attacker with a working PIN attempt and no escalation.
library;

import 'dart:async';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/features/session/controllers/session_lifecycle_controller.dart';

/// Plain-Dart helper that fires the distress chain. Composed by the
/// [SessionController] facade.
class DistressOrchestrationController {
  /// Creates a distress orchestration controller bound to the given
  /// [lifecycle] (for runtime access).
  DistressOrchestrationController({required this.lifecycle});

  /// Lifecycle controller — used to look up the live runtime and
  /// resolve the distress-chain steps.
  final SessionLifecycleController lifecycle;

  /// Callback fired right before the wrong-PIN-threshold distress
  /// chain is triggered. The UI presents the deceptive
  /// "Old PIN from Angela — are you sure you want to proceed?"
  /// dialog per spec 06 §Wrong PIN Behavior. The callback is
  /// awaited for visual completeness; its return value is IGNORED
  /// — distress fires regardless of which button the user tapped
  /// (OK / Cancel). Null = skip dialog and fire immediately.
  Future<void> Function()? onAngelaDeceptiveDialog;

  /// Force-fires the distress chain (e.g. hardware panic, duress
  /// PIN, wrong-PIN threshold exhausted).
  ///
  /// [triggerReason] — Q19: propagated to `sessionEnded.endReason`
  /// so SessionLog records the distinct forensic reason
  /// (`hardwarePanic`, `duressPin`, `wrongPinExhausted`).
  Future<void> trigger({
    TriggerReason triggerReason = TriggerReason.hardwarePanic,
  }) async {
    final runtime = lifecycle.runtime;
    if (runtime == null) return;
    runtime.engine.replaceWithDistressChain(
      await lifecycle.currentDistressChainSteps(),
      triggerReason: triggerReason,
    );
  }

  /// Fires the distress chain because of a PIN-related event:
  /// wrong-PIN threshold exhausted or duress PIN entered.
  ///
  /// For [TriggerReason.wrongPinExhausted] the deceptive dialog
  /// fires first; for [TriggerReason.duressPin] the dialog is
  /// skipped (duress is the user's intentional silent-distress path,
  /// not a threshold event).
  Future<void> fireBecauseOfPin(TriggerReason reason) async {
    final runtime = lifecycle.runtime;
    if (runtime == null) return;
    if (reason == TriggerReason.wrongPinExhausted) {
      final dialog = onAngelaDeceptiveDialog;
      if (dialog != null) {
        // B3 fix: the deceptive-dialog callback is a UI hook (modal
        // route). It can throw if the OS dismisses the dialog or the
        // navigator pops mid-call. The distress chain MUST NOT be
        // gated on UI side effects — swallow the exception and
        // continue to `replaceWithDistressChain`. Failing here would
        // leave an attacker with a working PIN attempt and no
        // escalation.
        try {
          await dialog();
        } on Object catch (_) {
          // Intentionally swallowed — safety-critical path proceeds.
        }
      }
    }
    // Re-check runtime; the dialog could have completed long enough
    // for the session to end (sessionEnded clears _runtime via B2).
    final stillRunning = lifecycle.runtime;
    if (stillRunning == null) return;
    stillRunning.engine.replaceWithDistressChain(
      await lifecycle.currentDistressChainSteps(),
      triggerReason: reason,
    );
  }
}
