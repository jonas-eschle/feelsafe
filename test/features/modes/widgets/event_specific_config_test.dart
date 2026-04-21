/// Smoke tests for [EventSpecificConfig] — renders per-step-type
/// config form plus a Preview button for the subset of step types
/// whose simulation description is user-facing.
///
/// Covers one happy path per [ChainStepType] subtype (9 types) +
/// verifies the Preview button fires a SnackBar via the injected
/// simulation strategies.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/features/modes/widgets/event_specific_config.dart';

import '../../widget_test_helpers.dart';

ChainStep _step(ChainStepType type, {StepConfig? config}) => ChainStep(
  id: 'step-$type',
  type: type,
  order: 0,
  durationSeconds: 10,
  gracePeriodSeconds: 2,
  waitSeconds: 0,
  retryCount: 0,
  randomize: 0,
  config: config,
);

Widget _host(ChainStep step) => hostScreen(
  child: Scaffold(
    body: SingleChildScrollView(
      child: EventSpecificConfig(step: step, onChanged: (_) {}),
    ),
  ),
);

void main() {
  testWidgets('EventSpecificConfig renders for holdButton', (tester) async {
    await tester.pumpWidget(_host(_step(ChainStepType.holdButton)));
    await tester.pumpAndSettle();
    check(find.byType(EventSpecificConfig).evaluate().length).equals(1);
    // holdButton has no Preview button.
    check(find.byIcon(Icons.play_arrow).evaluate()).isEmpty();
  });

  testWidgets('EventSpecificConfig renders for disguisedReminder + preview',
      (tester) async {
    await tester.pumpWidget(
      _host(_step(ChainStepType.disguisedReminder)),
    );
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.play_arrow).evaluate().length).equals(1);
  });

  testWidgets('EventSpecificConfig renders for countdownWarning + preview',
      (tester) async {
    await tester.pumpWidget(_host(_step(ChainStepType.countdownWarning)));
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.play_arrow).evaluate().length).equals(1);
  });

  testWidgets('EventSpecificConfig renders for fakeCall + preview',
      (tester) async {
    await tester.pumpWidget(_host(_step(ChainStepType.fakeCall)));
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.play_arrow).evaluate().length).equals(1);
  });

  testWidgets('EventSpecificConfig renders for smsContact (no preview)',
      (tester) async {
    await tester.pumpWidget(_host(_step(ChainStepType.smsContact)));
    await tester.pumpAndSettle();
    // SMS/phone contact do not expose a preview — side effects would
    // be too expensive (real-send) to simulate in a preview.
    check(find.byIcon(Icons.play_arrow).evaluate()).isEmpty();
  });

  testWidgets('EventSpecificConfig renders for phoneCallContact (no preview)',
      (tester) async {
    await tester.pumpWidget(_host(_step(ChainStepType.phoneCallContact)));
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.play_arrow).evaluate()).isEmpty();
  });

  testWidgets('EventSpecificConfig renders for loudAlarm + preview',
      (tester) async {
    await tester.pumpWidget(_host(_step(ChainStepType.loudAlarm)));
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.play_arrow).evaluate().length).equals(1);
  });

  testWidgets('EventSpecificConfig renders for callEmergency (no preview)',
      (tester) async {
    await tester.pumpWidget(_host(_step(ChainStepType.callEmergency)));
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.play_arrow).evaluate()).isEmpty();
  });

  testWidgets('EventSpecificConfig renders for hardwareButton (no preview)',
      (tester) async {
    await tester.pumpWidget(_host(_step(ChainStepType.hardwareButton)));
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.play_arrow).evaluate()).isEmpty();
  });

  testWidgets('Preview button fires a SnackBar for disguisedReminder',
      (tester) async {
    await tester.pumpWidget(
      _host(_step(ChainStepType.disguisedReminder)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.play_arrow));
    // The preview path calls executeReal() on the simulation
    // notification service; once it resolves a SnackBar pops up.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
    check(find.byType(SnackBar).evaluate().length).isGreaterOrEqual(1);
  });

  testWidgets('Preview button fires a SnackBar for countdownWarning',
      (tester) async {
    await tester.pumpWidget(_host(_step(ChainStepType.countdownWarning)));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
    check(find.byType(SnackBar).evaluate().length).isGreaterOrEqual(1);
  });
}
