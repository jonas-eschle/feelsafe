/// PIN gate controller — wrong-PIN threshold + duress detection.
///
/// One of the four sub-controllers Q48 splits
/// `SessionController` into. Owns the per-prompt wrong-PIN counter
/// (Q15: usability over offline brute-force resistance) and the
/// dispatch into [DistressOrchestrationController] when the
/// threshold (Q9: `AppSettings.wrongPinThreshold`) is reached or a
/// duress PIN is entered.
///
/// Notes on scope:
///   * This controller is for *in-session* PIN prompts (session-end
///     unlock, distress-cancel countdown). The launch-gate PIN is
///     handled separately by the PIN PM's `LaunchGate` widget.
///   * Per-prompt counter (Q15): the counter zeros on every dialog
///     close — which here means every [PinResult] that isn't a
///     pure-increment. `cancelled` (user dismissed the dialog) and
///     all terminal outcomes (`correct`, `duress`,
///     `wrongPinThreshold`) reset the counter so a fresh prompt
///     starts at zero. Only `wrong` and `timeout` (which the user
///     experiences as a wasted attempt) bump the counter.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/core/utils/pin_result.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/features/session/controllers/distress_orchestration_controller.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';

/// Plain-Dart helper that classifies PIN-prompt outcomes. Composed by
/// the [SessionController] facade.
class PinGateController {
  /// Creates a PIN gate bound to a Riverpod [ref] (to read the
  /// current threshold from `settingsControllerProvider`) and the
  /// [distress] orchestrator (to dispatch on threshold-exceeded).
  PinGateController({required this.ref, required this.distress});

  /// Riverpod ref — used to read the current wrong-PIN threshold.
  final Ref ref;

  /// Distress orchestration helper that fires the distress chain.
  final DistressOrchestrationController distress;

  /// Wrong-PIN attempts observed on the currently-active prompt.
  /// Reset every time a new PIN dialog opens by the UI.
  int _wrongPinCount = 0;

  /// Q9: read the user-configurable wrong-PIN threshold from
  /// `AppSettings`. Falls back to the spec default (5) when settings
  /// haven't hydrated yet — the same default the model carries.
  int currentWrongPinThreshold() {
    final settings = ref.read(settingsControllerProvider).value;
    return settings?.wrongPinThreshold ?? 5;
  }

  /// Handles the outcome of a PIN prompt.
  ///
  /// Returns `true` when the session should proceed past the prompt
  /// (correct PIN), `false` otherwise. [PinResult.duress] and
  /// [PinResult.wrongPinThreshold] both fire the distress chain and
  /// return `false`.
  bool handlePinResult(PinResult result) {
    final threshold = currentWrongPinThreshold();
    switch (result) {
      case PinResult.correct:
        _wrongPinCount = 0;
        return true;
      case PinResult.wrong:
        _wrongPinCount++;
        if (_wrongPinCount >= threshold) {
          unawaited(distress.fireBecauseOfPin(TriggerReason.wrongPinExhausted));
          _wrongPinCount = 0;
        }
        return false;
      case PinResult.duress:
        _wrongPinCount = 0;
        unawaited(distress.fireBecauseOfPin(TriggerReason.duressPin));
        return false;
      case PinResult.wrongPinThreshold:
        _wrongPinCount = 0;
        unawaited(distress.fireBecauseOfPin(TriggerReason.wrongPinExhausted));
        return false;
      case PinResult.timeout:
        // Spec 01 + 06 (D-UX-2026-04-23 #11): a PIN-entry timeout
        // counts as a wrong-PIN attempt. Increment the counter; if
        // threshold reached, fire distress.
        _wrongPinCount++;
        if (_wrongPinCount >= threshold) {
          unawaited(distress.fireBecauseOfPin(TriggerReason.wrongPinExhausted));
          _wrongPinCount = 0;
        }
        return false;
      case PinResult.cancelled:
        // Q15 (per-prompt): cancelled = the user dismissed the
        // dialog. Treat that as the prompt closing; reset the
        // counter so the next dialog starts fresh.
        _wrongPinCount = 0;
        return false;
    }
  }

  /// Resets the wrong-PIN counter to zero. Q15 (per-prompt): callers
  /// that open a fresh PIN dialog can invoke this to guarantee a
  /// clean count, independent of the previous prompt's outcome.
  void resetCounter() {
    _wrongPinCount = 0;
  }

  /// Visible-for-tests accessor for the current wrong-PIN count.
  int get wrongPinCountForTest => _wrongPinCount;
}
