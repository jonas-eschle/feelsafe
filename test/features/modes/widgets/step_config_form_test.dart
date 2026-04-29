/// Smoke tests for [StepConfigForm].
///
/// Covers the timing block (wait/duration/grace/retryCount fields)
/// and rendering for a handful of [ChainStepType] variants. Deeper
/// per-subtype assertions live in event_specific_config_test.dart.
///
/// Note: the timing block now lives inside a collapsible
/// [ExpansionTile] that defaults to closed. Tests that need to read
/// or interact with the timing inputs must expand the panel first
/// via the helper [_expandTiming].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/features/modes/widgets/step_config_form.dart';

import '../../widget_test_helpers.dart';

ChainStep _step({
  ChainStepType type = ChainStepType.holdButton,
  int wait = 0,
  int duration = 30,
  int grace = 5,
  int retryCount = 0,
}) => ChainStep(
  id: 'step-0',
  type: type,
  order: 0,
  durationSeconds: duration,
  gracePeriodSeconds: grace,
  waitSeconds: wait,
  retryCount: retryCount,
  randomize: 0,
);

Widget _host(ChainStep step, {ValueChanged<ChainStep>? onChanged}) =>
    hostScreen(
      child: Scaffold(
        body: SingleChildScrollView(
          child: StepConfigForm(
            step: step,
            onChanged: onChanged ?? (_) {},
          ),
        ),
      ),
    );

/// Expands the collapsible Timing panel so its TextFormFields are
/// in the widget tree (ExpansionTile lazy-builds children).
Future<void> _expandTiming(WidgetTester tester) async {
  await tester.tap(find.byType(ExpansionTile).first);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'StepConfigForm renders 4 timing TextFormFields when expanded',
    (tester) async {
      await tester.pumpWidget(_host(_step()));
      await tester.pumpAndSettle();
      await _expandTiming(tester);
      // wait / duration / grace / retryCount = 4 timing fields; the
      // hold-button event-specific form adds one more for sensitivity.
      check(find.byType(TextFormField).evaluate().length).isGreaterOrEqual(4);
    },
  );

  testWidgets(
    'StepConfigForm duration field echoes the step value when expanded',
    (tester) async {
      await tester.pumpWidget(_host(_step(duration: 77)));
      await tester.pumpAndSettle();
      await _expandTiming(tester);
      check(find.text('77').evaluate().length).isGreaterOrEqual(1);
    },
  );

  testWidgets('StepConfigForm fires onChanged when wait is edited',
      (tester) async {
    ChainStep? latest;
    await tester.pumpWidget(
      _host(_step(), onChanged: (step) => latest = step),
    );
    await tester.pumpAndSettle();
    await _expandTiming(tester);
    await tester.enterText(find.byType(TextFormField).first, '42');
    await tester.pumpAndSettle();
    check(latest).isNotNull();
    check(latest!.waitSeconds).equals(42);
  });

  testWidgets('StepConfigForm renders for disguisedReminder without error',
      (tester) async {
    await tester.pumpWidget(
      // Riverpod scope needed: the disguisedReminder form is a
      // ConsumerWidget via EventSpecificConfig.
      ProviderScope(
        child: _host(_step(type: ChainStepType.disguisedReminder)),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(StepConfigForm).evaluate().length).equals(1);
  });

  testWidgets('StepConfigForm renders for smsContact without error',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: _host(_step(type: ChainStepType.smsContact)),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(StepConfigForm).evaluate().length).equals(1);
  });

  testWidgets('StepConfigForm fires onChanged when duration is edited',
      (tester) async {
    ChainStep? latest;
    await tester.pumpWidget(
      _host(_step(), onChanged: (step) => latest = step),
    );
    await tester.pumpAndSettle();
    await _expandTiming(tester);
    // Field order inside the timing panel: wait, duration, grace,
    // retryCount.
    await tester.enterText(find.byType(TextFormField).at(1), '99');
    await tester.pumpAndSettle();
    check(latest).isNotNull();
    check(latest!.durationSeconds).equals(99);
  });

  testWidgets('StepConfigForm fires onChanged when grace is edited',
      (tester) async {
    ChainStep? latest;
    await tester.pumpWidget(
      _host(_step(), onChanged: (step) => latest = step),
    );
    await tester.pumpAndSettle();
    await _expandTiming(tester);
    await tester.enterText(find.byType(TextFormField).at(2), '17');
    await tester.pumpAndSettle();
    check(latest).isNotNull();
    check(latest!.gracePeriodSeconds).equals(17);
  });

  testWidgets('StepConfigForm fires onChanged when retryCount is edited',
      (tester) async {
    ChainStep? latest;
    await tester.pumpWidget(
      _host(_step(), onChanged: (step) => latest = step),
    );
    await tester.pumpAndSettle();
    await _expandTiming(tester);
    await tester.enterText(find.byType(TextFormField).at(3), '4');
    await tester.pumpAndSettle();
    check(latest).isNotNull();
    check(latest!.retryCount).equals(4);
  });

  testWidgets(
    'StepConfigForm timing panel is collapsed by default',
    (tester) async {
      await tester.pumpWidget(_host(_step()));
      await tester.pumpAndSettle();
      // Without expansion, the four timing TextFormFields are not in
      // the tree (lazy-built by ExpansionTile). The hold-button
      // event-specific form contributes exactly one TextFormField.
      check(find.byType(TextFormField).evaluate().length).equals(1);
    },
  );
}
