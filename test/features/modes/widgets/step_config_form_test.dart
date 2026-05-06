/// Smoke tests for [StepConfigForm].
///
/// Covers the timing block (wait/duration/grace TimingSliders +
/// retryCount TextFormField) and rendering for a handful of
/// [ChainStepType] variants.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/widgets/timing_slider.dart';
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

Future<void> _expandTiming(WidgetTester tester) async {
  await tester.tap(find.byType(ExpansionTile).first);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'StepConfigForm renders 3 TimingSliders + retry field when expanded',
    (tester) async {
      await tester.pumpWidget(_host(_step()));
      await tester.pumpAndSettle();
      await _expandTiming(tester);
      // Phase 4.2: wait/duration/grace are TimingSliders. Retry stays
      // a TextFormField for now.
      check(find.byType(TimingSlider).evaluate().length).equals(3);
      check(find.byType(TextFormField).evaluate().length).isGreaterOrEqual(1);
    },
  );

  testWidgets(
    'StepConfigForm duration slider receives the step value',
    (tester) async {
      await tester.pumpWidget(_host(_step(duration: 77)));
      await tester.pumpAndSettle();
      await _expandTiming(tester);
      final sliders = tester.widgetList<TimingSlider>(find.byType(TimingSlider));
      check(sliders.elementAt(1).seconds).equals(77);
    },
  );

  testWidgets('StepConfigForm fires onChanged when wait slider changes',
      (tester) async {
    ChainStep? latest;
    await tester.pumpWidget(
      _host(_step(), onChanged: (step) => latest = step),
    );
    await tester.pumpAndSettle();
    await _expandTiming(tester);
    final waitSlider = tester.widget<TimingSlider>(
      find.byType(TimingSlider).first,
    );
    waitSlider.onChanged(42);
    await tester.pumpAndSettle();
    check(latest).isNotNull();
    check(latest!.waitSeconds).equals(42);
  });

  testWidgets('StepConfigForm renders for disguisedReminder without error',
      (tester) async {
    await tester.pumpWidget(
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

  testWidgets('StepConfigForm fires onChanged when duration slider changes',
      (tester) async {
    ChainStep? latest;
    await tester.pumpWidget(
      _host(_step(), onChanged: (step) => latest = step),
    );
    await tester.pumpAndSettle();
    await _expandTiming(tester);
    final durationSlider = tester
        .widgetList<TimingSlider>(find.byType(TimingSlider))
        .elementAt(1);
    durationSlider.onChanged(99);
    await tester.pumpAndSettle();
    check(latest).isNotNull();
    check(latest!.durationSeconds).equals(99);
  });

  testWidgets('StepConfigForm fires onChanged when grace slider changes',
      (tester) async {
    ChainStep? latest;
    await tester.pumpWidget(
      _host(_step(), onChanged: (step) => latest = step),
    );
    await tester.pumpAndSettle();
    await _expandTiming(tester);
    final graceSlider = tester
        .widgetList<TimingSlider>(find.byType(TimingSlider))
        .elementAt(2);
    graceSlider.onChanged(17);
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
    // The only TextFormField in the timing panel is retryCount (after
    // 4.2, wait/duration/grace are TimingSliders).
    final retryField = find.byType(TextFormField).first;
    await tester.enterText(retryField, '4');
    await tester.pumpAndSettle();
    check(latest).isNotNull();
    check(latest!.retryCount).equals(4);
  });

  testWidgets(
    'StepConfigForm timing panel is collapsed by default',
    (tester) async {
      await tester.pumpWidget(_host(_step()));
      await tester.pumpAndSettle();
      // Without expansion, no TimingSliders are in the tree
      // (lazy-built by ExpansionTile).
      check(find.byType(TimingSlider).evaluate().length).equals(0);
    },
  );
}
