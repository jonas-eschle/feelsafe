/// Per-step preview screen (issues-v4 #10/#13/#14).
///
/// Pushed from `ChainStepTile` with `?stepId=...&modeId=...` query
/// parameters. The screen looks up the [SessionMode] and [ChainStep]
/// in the modes repository and renders a step-type-specific preview
/// body:
///
///   * `holdButton` — the actual [HoldToTriggerButton] widget.
///   * `fakeCall` — pushes [FakeCallScreen] in preview mode (live
///     ringtone, full Material/iOS styling).
///   * everything else — runs the real [EventStrategy] in simulation
///     mode and shows a card with the strategy's
///     [EventStrategy.simulationDescription] plus the standard
///     "[SIM] Preview" hint.
///
/// The screen wraps any preview action in a try-catch so a misbehaving
/// strategy never knocks the editor offline.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/widgets/hold_to_trigger_button.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/session_context.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy_registry.dart';
import 'package:guardianangela/features/fake_call/fake_call_screen.dart';
import 'package:guardianangela/features/modes/widgets/step_type_picker.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Per-step preview screen.
class StepPreviewScreen extends ConsumerWidget {
  /// Creates the preview screen. The route hydrates from the
  /// `stepId` + `modeId` query parameters of [GoRouterState].
  const StepPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final state = GoRouterState.of(context);
    final stepId = state.uri.queryParameters['stepId'];
    final modeId = state.uri.queryParameters['modeId'];
    return Scaffold(
      appBar: AppBar(title: Text(l.stepPreviewTitle)),
      body: _Body(stepId: stepId, modeId: modeId),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.stepId, required this.modeId});

  final String? stepId;
  final String? modeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final sId = stepId;
    final mId = modeId;
    if (sId == null || mId == null || sId.isEmpty || mId.isEmpty) {
      return Center(child: Text(l.stepPreviewMissingParams));
    }
    final repo = ref.watch(modesRepositoryProvider);
    return FutureBuilder<SessionMode?>(
      future: repo.getById(mId),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final mode = snap.data;
        if (mode == null) {
          return Center(child: Text(l.stepPreviewModeNotFound));
        }
        final step = _findStep(mode, sId);
        if (step == null) {
          return Center(child: Text(l.stepPreviewStepNotFound));
        }
        return _PreviewDispatch(mode: mode, step: step);
      },
    );
  }

  /// Returns the chain step in [mode] whose id matches [stepId], or
  /// null when no match is found.
  ChainStep? _findStep(SessionMode mode, String stepId) {
    for (final step in mode.chainSteps) {
      if (step.id == stepId) return step;
    }
    return null;
  }
}

/// Dispatches to the per-step-type preview body.
class _PreviewDispatch extends ConsumerWidget {
  const _PreviewDispatch({required this.mode, required this.step});

  final SessionMode mode;
  final ChainStep step;

  @override
  Widget build(BuildContext context, WidgetRef ref) => switch (step.type) {
    ChainStepType.holdButton => _HoldButtonPreview(step: step),
    ChainStepType.fakeCall => _FakeCallPreview(step: step),
    _ => _SimulationStrategyPreview(mode: mode, step: step),
  };
}

/// Preview body for `holdButton` — renders the real
/// [HoldToTriggerButton] so the user can feel the press/release.
class _HoldButtonPreview extends StatefulWidget {
  const _HoldButtonPreview({required this.step});
  final ChainStep step;

  @override
  State<_HoldButtonPreview> createState() => _HoldButtonPreviewState();
}

class _HoldButtonPreviewState extends State<_HoldButtonPreview> {
  bool _heldOnce = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l.stepPreviewHoldButtonHint,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          HoldToTriggerButton(
            onHoldStart: () {},
            onHoldRelease: () => setState(() => _heldOnce = true),
            semanticLabel: l.stepPreviewHoldButtonSemantic,
            label: l.stepPreviewHoldButtonLabel,
          ),
          const Spacer(),
          if (_heldOnce)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l.stepPreviewHoldButtonReleased,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }
}

/// Preview body for `fakeCall` — auto-pushes [FakeCallScreen] in
/// preview mode on first frame. The push pops back to this screen
/// when the user answers/declines/distresses, so the user can re-run
/// it via the "Replay" button.
class _FakeCallPreview extends ConsumerStatefulWidget {
  const _FakeCallPreview({required this.step});
  final ChainStep step;

  @override
  ConsumerState<_FakeCallPreview> createState() => _FakeCallPreviewState();
}

class _FakeCallPreviewState extends ConsumerState<_FakeCallPreview> {
  bool _pushed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _push();
    });
  }

  Future<void> _push() async {
    if (_pushed) return;
    _pushed = true;
    final cfg = _resolveFakeCallConfig(widget.step);
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => FakeCallScreen(previewConfig: cfg),
        fullscreenDialog: true,
      ),
    );
    if (mounted) setState(() => _pushed = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l.stepPreviewFakeCallHint,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: Text(l.stepPreviewReplay),
            onPressed: _pushed ? null : _push,
          ),
        ],
      ),
    );
  }
}

/// Preview body for everything else — invokes the matching
/// [EventStrategy] in simulation mode and shows the result.
class _SimulationStrategyPreview extends ConsumerStatefulWidget {
  const _SimulationStrategyPreview({required this.mode, required this.step});

  final SessionMode mode;
  final ChainStep step;

  @override
  ConsumerState<_SimulationStrategyPreview> createState() =>
      _SimulationStrategyPreviewState();
}

class _SimulationStrategyPreviewState
    extends ConsumerState<_SimulationStrategyPreview> {
  /// The symbolic description returned by the strategy. Stored as
  /// `Object?` because the codebase is mid-migration between a
  /// stringly-typed return and a structured [SimulationDescription];
  /// rendering via `toString()` works for both.
  Object? _description;
  bool _running = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_run());
    });
  }

  Future<void> _run() async {
    if (_running) return;
    setState(() {
      _running = true;
      _error = null;
    });
    try {
      final services = _buildServices();
      final strategy = EventStrategyRegistry.forStep(widget.step);
      final desc = strategy.simulationDescription(widget.step, services);
      // Run the strategy in simulation mode so the side-effect path
      // (which may include logging, vibration patterns, simulation
      // notifications, etc.) is exercised end-to-end.
      await strategy.executeReal(widget.step, services);
      if (!mounted) return;
      setState(() {
        _description = desc;
        _running = false;
      });
    } on Object catch (err) {
      if (!mounted) return;
      setState(() {
        _running = false;
        _error = err;
      });
    }
  }

  EventServices _buildServices() => EventServices(
    audio: ref.read(simulationAudioProvider),
    messaging: ref.read(simulationMessagingProvider),
    phone: ref.read(simulationPhoneProvider),
    notification: ref.read(simulationNotificationProvider),
    vibration: ref.read(simulationVibrationProvider),
    context: SessionContext(
      mode: widget.mode,
      contacts: const [],
      userProfile: null,
      isSimulation: true,
      reminderTemplates: const [],
    ),
    isCancelled: () => false,
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.science_outlined),
                      const SizedBox(width: 8),
                      Text(
                        stepTypeLabel(context, widget.step.type),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_running)
                    const Center(child: CircularProgressIndicator())
                  else if (_error != null)
                    Text(
                      l.stepPreviewError('$_error'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    )
                  else
                    Text(
                      '${_description ?? ''}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh),
            label: Text(l.stepPreviewReplay),
            onPressed: _running ? null : _run,
          ),
        ],
      ),
    );
  }
}

/// Resolves a [FakeCallConfig] for [step]. Falls back to the
/// const-default when the step's config is missing or of the wrong
/// type so the preview always renders something useful.
FakeCallConfig _resolveFakeCallConfig(ChainStep step) {
  final cfg = step.config;
  if (cfg is FakeCallConfig) return cfg;
  return const FakeCallConfig();
}
