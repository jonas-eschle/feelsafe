/// Fake-call feature controller.
///
/// Thin wrapper around [sessionControllerProvider] that exposes the
/// fake-call actions as typed methods + a `currentFakeCallConfig`
/// resolver the UI uses to hydrate the on-screen ringtone window,
/// caller-name fallback, decline-hold duration, etc.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/models/walk_session.dart';
import 'package:guardianangela/features/session/session_controller.dart';

/// Async controller for the fake-call overlay.
class FakeCallController extends AsyncNotifier<Object?> {
  @override
  Future<Object?> build() async => null;

  /// Answers the currently-ringing fake call.
  Future<void> answer() =>
      ref.read(sessionControllerProvider.notifier).answerFakeCall();

  /// Hangs up an in-progress fake call.
  Future<void> hangUp() =>
      ref.read(sessionControllerProvider.notifier).hangUp();

  /// Declines the ringing fake call.
  Future<void> decline() =>
      ref.read(sessionControllerProvider.notifier).declineFakeCall();

  /// Decline with distress — spec 01 §Fake Call Lifecycle: a 5-second
  /// press-and-hold on the Decline button (Q21) fires the distress
  /// chain instead of ending the fake-call ringtone normally.
  Future<void> declineWithDistress() =>
      ref.read(sessionControllerProvider.notifier).triggerDistressChain();

  /// Resolves the [FakeCallConfig] for the active fake-call step
  /// (Q21) so the UI can read its `declineWithDistressHoldSeconds`,
  /// `callStyle`, `callerName`, etc. instead of hardcoding values.
  ///
  /// Resolution strategy:
  ///
  ///   1. If the session's `WalkSession.modeId` resolves to a saved
  ///      mode whose `chainSteps[currentStepIndex]` is a fakeCall
  ///      step with a [FakeCallConfig], use that config.
  ///   2. Otherwise (distress chain active, synthetic battery-alert
  ///      mode, or seed-data mismatch), search every saved mode for
  ///      a fakeCall step at `currentStepIndex` with a
  ///      [FakeCallConfig] and use the first match.
  ///   3. If nothing matches, return the default `FakeCallConfig()`.
  ///
  /// Returns the default `FakeCallConfig()` when there is no active
  /// session or the active step is not a `fakeCall`.
  Future<FakeCallConfig> currentFakeCallConfig() async {
    final WalkSession? walk = ref.read(sessionControllerProvider).value;
    if (walk == null) return const FakeCallConfig();
    if (walk.currentStepType != ChainStepType.fakeCall) {
      return const FakeCallConfig();
    }
    final modesRepo = ref.read(modesRepositoryProvider);
    final stepIndex = walk.currentStepIndex;

    // Strategy 1: original mode by id.
    final originalMode = await modesRepo.getById(walk.modeId);
    final fromOriginal = _fakeCallAt(originalMode, stepIndex);
    if (fromOriginal != null) return fromOriginal;

    // Strategy 2: scan every saved mode for a matching fakeCall step
    // at the same index. Distress chains (Q52) are themselves saved
    // modes, so this picks them up after `replaceWithDistressChain`.
    final allModes = await modesRepo.getAll();
    for (final mode in allModes) {
      final cfg = _fakeCallAt(mode, stepIndex);
      if (cfg != null) return cfg;
    }
    // Strategy 3: defaults.
    return const FakeCallConfig();
  }

  /// Returns `mode.chainSteps[stepIndex].config` when it is a
  /// `FakeCallConfig`, or null when the index is out of range, the
  /// step is not a fakeCall, or the config is missing.
  FakeCallConfig? _fakeCallAt(SessionMode? mode, int stepIndex) {
    if (mode == null) return null;
    if (stepIndex < 0 || stepIndex >= mode.chainSteps.length) return null;
    final step = mode.chainSteps[stepIndex];
    if (step.type != ChainStepType.fakeCall) return null;
    final cfg = step.config;
    return cfg is FakeCallConfig ? cfg : null;
  }
}

/// Provider for `FakeCallController`.
final AsyncNotifierProvider<FakeCallController, Object?>
fakeCallControllerProvider = AsyncNotifierProvider<FakeCallController, Object?>(
  FakeCallController.new,
);
