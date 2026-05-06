/// Smoke + per-step-type tests for [StepPreviewScreen].
///
/// Issues-v4 #10/#13/#14. Each test pumps the screen with a stubbed
/// [ModesRepository] so we don't need a live database, and verifies
/// the per-type body renders without crashing.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:guardianangela/core/widgets/hold_to_trigger_button.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/data/repositories/modes_repository.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/features/fake_call/fake_call_screen.dart';
import 'package:guardianangela/features/preview/step_preview_screen.dart';
import 'package:guardianangela/services/service_providers.dart';

import '../widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

/// In-memory ModesRepository fake. Returns the supplied modes from
/// [getAll] / [getById] without touching Drift.
class _FakeModesRepository extends ModesRepository {
  _FakeModesRepository(this._modes) : super.forTesting();

  final List<SessionMode> _modes;

  @override
  Future<List<SessionMode>> getAll() async => _modes;

  @override
  Future<SessionMode?> getById(String id) async {
    for (final m in _modes) {
      if (m.id == id) return m;
    }
    return null;
  }
}

/// No-op audio so [FakeCallScreen] doesn't reach real platform code.
class _NoopAudio implements AudioServiceProtocol {
  @override
  Future<void> playAlarm({bool maxVolume = true, bool isSimulation = false})
      async {}
  @override
  Future<void> stopAlarm() async {}
  @override
  Future<void> playRingtone({String? assetPath, bool isSimulation = false})
      async {}
  @override
  Future<void> stopRingtone() async {}
  @override
  Future<void> playVoiceRecording({
    required String assetPath,
    bool isSimulation = false,
  }) async {}
  @override
  Future<void> stopVoiceRecording() async {}
}

class _NoopTts implements FlutterTts {
  @override
  dynamic noSuchMethod(Invocation i) async => 1;
}

FakeCallTtsFactory _noopTtsFactory() => () => _NoopTts();

ChainStep _step({
  required String id,
  required ChainStepType type,
  StepConfig? config,
  int wait = 1,
  int duration = 30,
  int grace = 5,
}) =>
    ChainStep(
      id: id,
      type: type,
      order: 0,
      durationSeconds: duration,
      gracePeriodSeconds: grace,
      waitSeconds: wait,
      retryCount: 0,
      randomize: 0,
      config: config,
    );

SessionMode _mode({
  required String id,
  required List<ChainStep> steps,
}) =>
    SessionMode(
      id: id,
      name: 'Test mode $id',
      checkInType: ChainStepType.holdButton,
      chainSteps: steps,
    );

List<Override> _commonOverrides(_FakeModesRepository repo) => [
      modesRepositoryProvider.overrideWithValue(repo),
      audioServiceProvider.overrideWithValue(_NoopAudio()),
      simulationAudioProvider.overrideWithValue(_NoopAudio()),
      fakeCallTtsFactoryProvider.overrideWithValue(_noopTtsFactory()),
    ];

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  testWidgets(
    'StepPreviewScreen renders without error when query params are missing',
    (tester) async {
      final repo = _FakeModesRepository(const []);
      await tester.pumpWidget(
        hostScreenPushed(
          overrides: _commonOverrides(repo),
          child: const StepPreviewScreen(),
        ),
      );
      await tester.pumpAndSettle();
      // Without ?stepId or ?modeId, the body shows the missing-params
      // error text and the Scaffold renders.
      check(find.byType(StepPreviewScreen).evaluate().length).equals(1);
    },
  );

  testWidgets(
    'StepPreviewScreen shows mode-not-found when modeId is unknown',
    (tester) async {
      final repo = _FakeModesRepository(const []);
      await tester.pumpWidget(
        hostScreenPushed(
          overrides: _commonOverrides(repo),
          initialQuery: 'stepId=s1&modeId=missing',
          child: const StepPreviewScreen(),
        ),
      );
      await tester.pumpAndSettle();
      check(find.text('Mode not found.').evaluate().length).equals(1);
    },
  );

  testWidgets(
    'StepPreviewScreen shows step-not-found when stepId is unknown',
    (tester) async {
      final mode = _mode(
        id: 'm1',
        steps: [_step(id: 's1', type: ChainStepType.holdButton)],
      );
      final repo = _FakeModesRepository([mode]);
      await tester.pumpWidget(
        hostScreenPushed(
          overrides: _commonOverrides(repo),
          initialQuery: 'stepId=missing&modeId=m1',
          child: const StepPreviewScreen(),
        ),
      );
      await tester.pumpAndSettle();
      check(find.text('Step not found in this mode.').evaluate().length)
          .equals(1);
    },
  );

  testWidgets(
    'StepPreviewScreen renders HoldToTriggerButton for holdButton steps',
    (tester) async {
      final mode = _mode(
        id: 'm1',
        steps: [_step(id: 's1', type: ChainStepType.holdButton)],
      );
      final repo = _FakeModesRepository([mode]);
      await tester.pumpWidget(
        hostScreenPushed(
          overrides: _commonOverrides(repo),
          initialQuery: 'stepId=s1&modeId=m1',
          child: const StepPreviewScreen(),
        ),
      );
      await tester.pumpAndSettle();
      check(find.byType(HoldToTriggerButton).evaluate().length).equals(1);
    },
  );

  testWidgets(
    'StepPreviewScreen pushes FakeCallScreen for fakeCall steps',
    (tester) async {
      final mode = _mode(
        id: 'm1',
        steps: [
          _step(
            id: 's1',
            type: ChainStepType.fakeCall,
            config: const FakeCallConfig(callerName: 'Angela'),
          ),
        ],
      );
      final repo = _FakeModesRepository([mode]);
      await tester.pumpWidget(
        hostScreenPushed(
          overrides: _commonOverrides(repo),
          initialQuery: 'stepId=s1&modeId=m1',
          child: const StepPreviewScreen(),
        ),
      );
      await tester.pumpAndSettle();
      // Auto-pushes FakeCallScreen on first frame.
      check(find.byType(FakeCallScreen).evaluate().length).equals(1);
    },
  );

  testWidgets(
    'StepPreviewScreen renders the simulation card for smsContact steps',
    (tester) async {
      final mode = _mode(
        id: 'm1',
        steps: [_step(id: 's1', type: ChainStepType.smsContact)],
      );
      final repo = _FakeModesRepository([mode]);
      await tester.pumpWidget(
        hostScreenPushed(
          overrides: _commonOverrides(repo),
          initialQuery: 'stepId=s1&modeId=m1',
          child: const StepPreviewScreen(),
        ),
      );
      await tester.pumpAndSettle();
      // The simulation card always carries an icon and a Replay
      // OutlinedButton.icon with Icons.refresh.
      check(find.byIcon(Icons.refresh).evaluate().length).equals(1);
    },
  );

  testWidgets(
    'StepPreviewScreen renders the simulation card for loudAlarm steps',
    (tester) async {
      final mode = _mode(
        id: 'm1',
        steps: [_step(id: 's1', type: ChainStepType.loudAlarm)],
      );
      final repo = _FakeModesRepository([mode]);
      await tester.pumpWidget(
        hostScreenPushed(
          overrides: _commonOverrides(repo),
          initialQuery: 'stepId=s1&modeId=m1',
          child: const StepPreviewScreen(),
        ),
      );
      await tester.pumpAndSettle();
      check(find.byIcon(Icons.refresh).evaluate().length).equals(1);
    },
  );

  testWidgets(
    'StepPreviewScreen renders the simulation card for callEmergency steps',
    (tester) async {
      final mode = _mode(
        id: 'm1',
        steps: [_step(id: 's1', type: ChainStepType.callEmergency)],
      );
      final repo = _FakeModesRepository([mode]);
      await tester.pumpWidget(
        hostScreenPushed(
          overrides: _commonOverrides(repo),
          initialQuery: 'stepId=s1&modeId=m1',
          child: const StepPreviewScreen(),
        ),
      );
      await tester.pumpAndSettle();
      check(find.byIcon(Icons.refresh).evaluate().length).equals(1);
    },
  );
}
