/// Supplemental tests for [StepConfigForm] / [_TimingPanel] covering
/// branches not reached by the existing smoke tests:
///
///   - lines 104, 110–111, 117: `disguisedReminder` branch — the three
///     `onChanged` callbacks inside `if (isReminder)` for waitSeconds,
///     gracePeriodSeconds, and durationSeconds.
///
/// Note: line 208 (`label: tip == null ? label : null`) has an
/// unreachable `tip == null` branch because all [_TimingRow] usages
/// inside [_TimingPanel] always pass a non-null tooltip. The line is
/// defensive dead code and cannot be exercised without production
/// code modification.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/widgets/timing_slider.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/features/modes/widgets/step_config_form.dart';

import '../../widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ChainStep _step({
  ChainStepType type = ChainStepType.disguisedReminder,
  int wait = 60,
  int duration = 30,
  int grace = 15,
  int retryCount = 0,
}) => ChainStep(
  id: 'step-r',
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

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ---------- disguisedReminder branch onChanged callbacks ----------

  group('StepConfigForm — disguisedReminder onChanged paths', () {
    testWidgets(
      'wait slider onChanged fires copyWith(waitSeconds) (line 104)',
      (tester) async {
        ChainStep? received;
        await tester.pumpWidget(
          _host(_step(wait: 60), onChanged: (s) => received = s),
        );
        await tester.pumpAndSettle();
        await _expandTiming(tester);

        // For disguisedReminder the order is: wait (index 0), grace
        // (index 1), duration (index 2).
        final sliders = tester
            .widgetList<TimingSlider>(find.byType(TimingSlider))
            .toList();
        check(sliders.length).isGreaterOrEqual(3);

        // Invoke the first slider's onChanged — maps to waitSeconds.
        sliders.first.onChanged(120);
        await tester.pumpAndSettle();

        check(received).isNotNull();
        check(received!.waitSeconds).equals(120);
        // Other fields must be unchanged.
        check(received!.gracePeriodSeconds).equals(15);
        check(received!.durationSeconds).equals(30);
      },
    );

    testWidgets(
      'grace slider onChanged fires copyWith(gracePeriodSeconds) (lines 110–111)',
      (tester) async {
        ChainStep? received;
        await tester.pumpWidget(
          _host(_step(grace: 15), onChanged: (s) => received = s),
        );
        await tester.pumpAndSettle();
        await _expandTiming(tester);

        final sliders = tester
            .widgetList<TimingSlider>(find.byType(TimingSlider))
            .toList();
        check(sliders.length).isGreaterOrEqual(3);

        // Second slider maps to gracePeriodSeconds for disguisedReminder.
        sliders[1].onChanged(25);
        await tester.pumpAndSettle();

        check(received).isNotNull();
        check(received!.gracePeriodSeconds).equals(25);
        check(received!.waitSeconds).equals(60);
        check(received!.durationSeconds).equals(30);
      },
    );

    testWidgets(
      'duration slider onChanged fires copyWith(durationSeconds) (line 117)',
      (tester) async {
        ChainStep? received;
        await tester.pumpWidget(
          _host(_step(duration: 30), onChanged: (s) => received = s),
        );
        await tester.pumpAndSettle();
        await _expandTiming(tester);

        final sliders = tester
            .widgetList<TimingSlider>(find.byType(TimingSlider))
            .toList();
        check(sliders.length).isGreaterOrEqual(3);

        // Third slider maps to durationSeconds for disguisedReminder.
        sliders[2].onChanged(90);
        await tester.pumpAndSettle();

        check(received).isNotNull();
        check(received!.durationSeconds).equals(90);
        check(received!.waitSeconds).equals(60);
        check(received!.gracePeriodSeconds).equals(15);
      },
    );
  });
}
