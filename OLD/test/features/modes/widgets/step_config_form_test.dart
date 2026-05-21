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
          child: StepConfigForm(step: step, onChanged: onChanged ?? (_) {}),
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

  testWidgets('StepConfigForm duration slider receives the step value', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_step(duration: 77)));
    await tester.pumpAndSettle();
    await _expandTiming(tester);
    final sliders = tester.widgetList<TimingSlider>(find.byType(TimingSlider));
    check(sliders.elementAt(1).seconds).equals(77);
  });

  testWidgets('StepConfigForm fires onChanged when wait slider changes', (
    tester,
  ) async {
    ChainStep? latest;
    await tester.pumpWidget(_host(_step(), onChanged: (step) => latest = step));
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

  testWidgets('StepConfigForm renders for disguisedReminder without error', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(child: _host(_step(type: ChainStepType.disguisedReminder))),
    );
    await tester.pumpAndSettle();
    check(find.byType(StepConfigForm).evaluate().length).equals(1);
  });

  testWidgets('StepConfigForm renders for smsContact without error', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(child: _host(_step(type: ChainStepType.smsContact))),
    );
    await tester.pumpAndSettle();
    check(find.byType(StepConfigForm).evaluate().length).equals(1);
  });

  testWidgets('StepConfigForm fires onChanged when duration slider changes', (
    tester,
  ) async {
    ChainStep? latest;
    await tester.pumpWidget(_host(_step(), onChanged: (step) => latest = step));
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

  testWidgets('StepConfigForm fires onChanged when grace slider changes', (
    tester,
  ) async {
    ChainStep? latest;
    await tester.pumpWidget(_host(_step(), onChanged: (step) => latest = step));
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

  testWidgets('StepConfigForm fires onChanged when retryCount is edited', (
    tester,
  ) async {
    ChainStep? latest;
    await tester.pumpWidget(_host(_step(), onChanged: (step) => latest = step));
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

  testWidgets('StepConfigForm timing panel is collapsed by default', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_step()));
    await tester.pumpAndSettle();
    // Without expansion, no TimingSliders are in the tree
    // (lazy-built by ExpansionTile).
    check(find.byType(TimingSlider).evaluate().length).equals(0);
  });

  // ---------- Issues-v4 #4 — tooltips + reorder for reminders ----------

  testWidgets('disguisedReminder timing panel shows three info tooltips (#4)', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(child: _host(_step(type: ChainStepType.disguisedReminder))),
    );
    await tester.pumpAndSettle();
    await _expandTiming(tester);
    // Three tooltips: repeat-interval, grace, duration. Plus the
    // retry tooltip below the slider section. (No tooltip on the
    // randomize switch.)
    check(
      find.byIcon(Icons.info_outline).evaluate().length,
    ).isGreaterOrEqual(3);
  });

  testWidgets('disguisedReminder shows Repeat Interval before Grace (#4)', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(child: _host(_step(type: ChainStepType.disguisedReminder))),
    );
    await tester.pumpAndSettle();
    await _expandTiming(tester);
    // Find the y-positions of the rows by their TimingSlider seconds.
    final sliders = tester
        .widgetList<TimingSlider>(find.byType(TimingSlider))
        .toList();
    // Issues-v4 #4 — for disguisedReminder the order is wait first
    // (repeat interval), then grace, then duration.
    check(sliders.first.seconds).equals(0); // wait
    check(sliders[1].seconds).equals(5); // grace
    check(sliders[2].seconds).equals(30); // duration
  });

  testWidgets(
    'non-reminder steps preserve Wait -> Duration -> Grace order (#4)',
    (tester) async {
      await tester.pumpWidget(_host(_step(type: ChainStepType.holdButton)));
      await tester.pumpAndSettle();
      await _expandTiming(tester);
      final sliders = tester
          .widgetList<TimingSlider>(find.byType(TimingSlider))
          .toList();
      check(sliders.first.seconds).equals(0); // wait
      check(sliders[1].seconds).equals(30); // duration
      check(sliders[2].seconds).equals(5); // grace
    },
  );

  // ---------- Issues-v4 #11 — randomize toggle ----------

  testWidgets('disguisedReminder shows the randomize switch (#11)', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(child: _host(_step(type: ChainStepType.disguisedReminder))),
    );
    await tester.pumpAndSettle();
    await _expandTiming(tester);
    // Target the randomize switch by its keyed presence — other
    // step-type forms (fakeCall declineIsSafe, smsContact auto-record)
    // also render SwitchListTiles inside this same panel.
    check(
      find.byKey(const ValueKey('randomize-step-0')).evaluate().length,
    ).equals(1);
  });

  testWidgets('fakeCall shows the randomize switch (#11)', (tester) async {
    await tester.pumpWidget(_host(_step(type: ChainStepType.fakeCall)));
    await tester.pumpAndSettle();
    await _expandTiming(tester);
    // Target the randomize switch by its keyed presence — other
    // step-type forms (fakeCall declineIsSafe, smsContact auto-record)
    // also render SwitchListTiles inside this same panel.
    check(
      find.byKey(const ValueKey('randomize-step-0')).evaluate().length,
    ).equals(1);
  });

  testWidgets('smsContact does NOT show the randomize switch (#11)', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(child: _host(_step(type: ChainStepType.smsContact))),
    );
    await tester.pumpAndSettle();
    await _expandTiming(tester);
    check(find.byKey(const ValueKey('randomize-step-0')).evaluate()).isEmpty();
  });

  testWidgets('loudAlarm does NOT show the randomize switch (#11)', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_step(type: ChainStepType.loudAlarm)));
    await tester.pumpAndSettle();
    await _expandTiming(tester);
    check(find.byKey(const ValueKey('randomize-step-0')).evaluate()).isEmpty();
  });

  testWidgets('callEmergency does NOT show the randomize switch (#11)', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_step(type: ChainStepType.callEmergency)));
    await tester.pumpAndSettle();
    await _expandTiming(tester);
    check(find.byKey(const ValueKey('randomize-step-0')).evaluate()).isEmpty();
  });

  testWidgets('randomize switch toggles ChainStep.randomize 0 <-> 0.2 (#11)', (
    tester,
  ) async {
    ChainStep? latest;
    await tester.pumpWidget(
      _host(_step(type: ChainStepType.fakeCall), onChanged: (s) => latest = s),
    );
    await tester.pumpAndSettle();
    await _expandTiming(tester);
    // Initial value is 0.0 -> switch is off.
    final switchTile = tester.widget<SwitchListTile>(
      find.byKey(const ValueKey('randomize-step-0')),
    );
    check(switchTile.value).isFalse();
    await tester.tap(find.byKey(const ValueKey('randomize-step-0')));
    await tester.pumpAndSettle();
    check(latest).isNotNull();
    check(latest!.randomize).equals(0.2);
  });

  testWidgets('randomize switch resets to 0 when toggled off (#11)', (
    tester,
  ) async {
    ChainStep? latest;
    final step = _step(type: ChainStepType.fakeCall);
    await tester.pumpWidget(
      _host(
        ChainStep(
          id: step.id,
          type: step.type,
          order: step.order,
          durationSeconds: step.durationSeconds,
          gracePeriodSeconds: step.gracePeriodSeconds,
          waitSeconds: step.waitSeconds,
          retryCount: step.retryCount,
          randomize: 0.2,
        ),
        onChanged: (s) => latest = s,
      ),
    );
    await tester.pumpAndSettle();
    await _expandTiming(tester);
    final switchTile = tester.widget<SwitchListTile>(
      find.byKey(const ValueKey('randomize-step-0')),
    );
    check(switchTile.value).isTrue();
    await tester.tap(find.byKey(const ValueKey('randomize-step-0')));
    await tester.pumpAndSettle();
    check(latest).isNotNull();
    check(latest!.randomize).equals(0.0);
  });

  test('stepSupportsRandomizeToggle exact set (#11)', () {
    check(
      stepSupportsRandomizeToggle(ChainStepType.disguisedReminder),
    ).isTrue();
    check(stepSupportsRandomizeToggle(ChainStepType.fakeCall)).isTrue();
    // SMS / alarm / emergency-confirm are explicitly excluded.
    check(stepSupportsRandomizeToggle(ChainStepType.smsContact)).isFalse();
    check(stepSupportsRandomizeToggle(ChainStepType.loudAlarm)).isFalse();
    check(stepSupportsRandomizeToggle(ChainStepType.callEmergency)).isFalse();
    // Holding / hardware are not jittered.
    check(stepSupportsRandomizeToggle(ChainStepType.holdButton)).isFalse();
    check(stepSupportsRandomizeToggle(ChainStepType.hardwareButton)).isFalse();
    check(
      stepSupportsRandomizeToggle(ChainStepType.countdownWarning),
    ).isFalse();
    check(
      stepSupportsRandomizeToggle(ChainStepType.phoneCallContact),
    ).isFalse();
  });
}
