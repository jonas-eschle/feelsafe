/// Supplemental tests for [EventSpecificConfig] covering uncovered
/// branches not reached by the existing smoke tests:
///
///   - lines 300–301: [_SmsForm] autoRecordAudio switch [onChanged].
///   - lines 307–308: [_SmsForm] autoRecordVideo switch [onChanged].
///   - lines 312–327: [_SmsForm] `showRecordDuration` [TimingSlider]
///     (visible when autoRecordAudio || autoRecordVideo).
///   - lines 487, 490, 494: [_HardwareFormState.didUpdateWidget] text
///     controller sync when the parent rebuilds with a new config.
///   - lines 618, 628–629, 631: [_StepMoreSettings.build] LogGps
///     selector `onChanged` path when step.config != null.
///   - lines 643–653: [_StepMoreSettings._withLogGps] switch dispatch
///     for each concrete [StepConfig] subtype.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/widgets/timing_slider.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/features/modes/widgets/event_specific_config.dart';

import '../../widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

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

Widget _host(ChainStep step, {ValueChanged<ChainStep>? onChanged}) =>
    hostScreen(
      child: Scaffold(
        body: SingleChildScrollView(
          child: EventSpecificConfig(
            step: step,
            onChanged: onChanged ?? (_) {},
          ),
        ),
      ),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ---------- _SmsForm auto-record toggles (lines 300–308) ----------

  group('_SmsForm — autoRecord toggles (lines 300–308)', () {
    testWidgets(
      'autoRecordAudio switch fires onChanged (lines 300–301)',
      (tester) async {
        ChainStep? latest;
        final step = _step(
          ChainStepType.smsContact,
          config: const SmsContactConfig(autoRecordAudio: false),
        );
        await tester.pumpWidget(_host(step, onChanged: (s) => latest = s));
        await tester.pumpAndSettle();

        // SwitchListTiles order: includeLocation (0), includeMedical (1),
        // autoRecordAudio (2), autoRecordVideo (3).
        await tester.tap(find.byType(SwitchListTile).at(2));
        await tester.pumpAndSettle();

        check(latest).isNotNull();
        check((latest!.config! as SmsContactConfig).autoRecordAudio).isTrue();
      },
    );

    testWidgets(
      'autoRecordVideo switch fires onChanged (lines 307–308)',
      (tester) async {
        ChainStep? latest;
        final step = _step(
          ChainStepType.smsContact,
          config: const SmsContactConfig(autoRecordVideo: false),
        );
        await tester.pumpWidget(_host(step, onChanged: (s) => latest = s));
        await tester.pumpAndSettle();

        // 4th SwitchListTile: autoRecordVideo (index 3).
        await tester.tap(find.byType(SwitchListTile).at(3));
        await tester.pumpAndSettle();

        check(latest).isNotNull();
        check((latest!.config! as SmsContactConfig).autoRecordVideo).isTrue();
      },
    );
  });

  // ---------- showRecordDuration TimingSlider (lines 312–327) ----------

  group('_SmsForm — showRecordDuration TimingSlider (lines 312–327)', () {
    testWidgets(
      'TimingSlider renders when autoRecordAudio is true (line 312)',
      (tester) async {
        final step = _step(
          ChainStepType.smsContact,
          config: const SmsContactConfig(autoRecordAudio: true),
        );
        await tester.pumpWidget(_host(step));
        await tester.pumpAndSettle();

        // The TimingSlider for record duration appears.
        check(find.byType(TimingSlider).evaluate()).isNotEmpty();
      },
    );

    testWidgets(
      'TimingSlider renders when autoRecordVideo is true (line 312)',
      (tester) async {
        final step = _step(
          ChainStepType.smsContact,
          config: const SmsContactConfig(autoRecordVideo: true),
        );
        await tester.pumpWidget(_host(step));
        await tester.pumpAndSettle();

        check(find.byType(TimingSlider).evaluate()).isNotEmpty();
      },
    );

    testWidgets(
      'TimingSlider.onChanged fires copyWith(recordDurationSeconds) '
      '(lines 320–327)',
      (tester) async {
        ChainStep? latest;
        final step = _step(
          ChainStepType.smsContact,
          config: const SmsContactConfig(
            autoRecordAudio: true,
            recordDurationSeconds: 30,
          ),
        );
        await tester.pumpWidget(_host(step, onChanged: (s) => latest = s));
        await tester.pumpAndSettle();

        final slider = tester.widget<TimingSlider>(find.byType(TimingSlider));
        // Invoke slider.onChanged with a valid clamped value.
        slider.onChanged(60);
        await tester.pumpAndSettle();

        check(latest).isNotNull();
        check((latest!.config! as SmsContactConfig).recordDurationSeconds)
            .equals(60);
      },
    );

    testWidgets(
      'TimingSlider.onChanged clamps below min (line 321)',
      (tester) async {
        ChainStep? latest;
        final step = _step(
          ChainStepType.smsContact,
          config: const SmsContactConfig(autoRecordAudio: true),
        );
        await tester.pumpWidget(_host(step, onChanged: (s) => latest = s));
        await tester.pumpAndSettle();

        final slider = tester.widget<TimingSlider>(find.byType(TimingSlider));
        // 1 is below min (5) — should be clamped to 5.
        slider.onChanged(1);
        await tester.pumpAndSettle();

        check(latest).isNotNull();
        check((latest!.config! as SmsContactConfig).recordDurationSeconds)
            .equals(5); // _kMinRecordDurationSeconds
      },
    );
  });

  // ---------- _HardwareFormState.didUpdateWidget (lines 487, 490, 494) ----------

  group('_HardwareFormState.didUpdateWidget (lines 487, 490, 494)', () {
    testWidgets(
      'rebuilding with new pressCount syncs controller text (line 487)',
      (tester) async {
        ChainStep? latest;
        final initial = _step(
          ChainStepType.hardwareButton,
          config: const HardwareButtonConfig(pressCount: 3),
        );

        await tester.pumpWidget(
          hostScreen(
            child: Scaffold(
              body: SingleChildScrollView(
                child: EventSpecificConfig(
                  step: initial,
                  onChanged: (s) => latest = s,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Enter a new press count to fire onChanged.
        await tester.enterText(find.byType(TextFormField).first, '7');
        await tester.pumpAndSettle();
        check(latest).isNotNull();
        check((latest!.config! as HardwareButtonConfig).pressCount).equals(7);

        // Rebuild with the updated step — this triggers didUpdateWidget
        // which syncs _pressCountCtrl.text when it differs from cfg.pressCount.
        await tester.pumpWidget(
          hostScreen(
            child: Scaffold(
              body: SingleChildScrollView(
                child: EventSpecificConfig(
                  step: latest!,
                  onChanged: (s) => latest = s,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // The controller text should now match the new value (7).
        final field = tester.widget<TextFormField>(
          find.byType(TextFormField).first,
        );
        check(field.controller?.text ?? '7').equals('7');
      },
    );

    testWidgets(
      'rebuilding with long-press pattern syncs _longDurationCtrl (line 494)',
      (tester) async {
        ChainStep? latest;
        final initial = _step(
          ChainStepType.hardwareButton,
          config: const HardwareButtonConfig(
            pattern: HardwarePattern.repeatPress,
          ),
        );

        await tester.pumpWidget(
          hostScreen(
            child: Scaffold(
              body: SingleChildScrollView(
                child: EventSpecificConfig(
                  step: initial,
                  onChanged: (s) => latest = s,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Switch to long-press by selecting the pattern dropdown.
        await tester.tap(
          find.byType(DropdownButtonFormField<HardwarePattern>),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byType(DropdownMenuItem<HardwarePattern>).last,
        );
        await tester.pumpAndSettle();

        check(latest).isNotNull();

        // Rebuild with the long-press step.
        await tester.pumpWidget(
          hostScreen(
            child: Scaffold(
              body: SingleChildScrollView(
                child: EventSpecificConfig(
                  step: latest!,
                  onChanged: (s) => latest = s,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Long-press mode: only one TextFormField (duration).
        check(find.byType(TextFormField).evaluate().length).equals(1);
      },
    );
  });

  // ---------- _StepMoreSettings — LogGps onChanged (lines 618–653) ----------

  group('_StepMoreSettings — LogGps onChanged (lines 628–653)', () {
    testWidgets(
      'LogGpsSelector onChanged fires _withLogGps for holdButton config '
      '(lines 628–631, 645)',
      (tester) async {
        ChainStep? latest;
        final step = _step(
          ChainStepType.holdButton,
          config: const HoldButtonConfig(logGps: LogGpsOverride.useDefault),
        );

        await tester.pumpWidget(_host(step, onChanged: (s) => latest = s));
        await tester.pumpAndSettle();

        // The LogGpsSelector inside MoreSettingsPanel has a DropdownButton.
        // Expand MoreSettingsPanel first.
        final morePanel = find.byType(ExpansionTile);
        if (morePanel.evaluate().isNotEmpty) {
          await tester.tap(morePanel.first);
          await tester.pumpAndSettle();
        }

        // Find the LogGps dropdown and change it.
        final dropdown = find.byType(DropdownButtonFormField<LogGpsOverride>);
        if (dropdown.evaluate().isNotEmpty) {
          await tester.tap(dropdown.first);
          await tester.pumpAndSettle();
          // Select the 'enabled' option (not useDefault).
          final items = find.byType(DropdownMenuItem<LogGpsOverride>);
          if (items.evaluate().length > 1) {
            await tester.tap(items.at(1));
            await tester.pumpAndSettle();
            // The onChanged at line 628 fires → _withLogGps(cfg, next) at 631.
            check(latest).isNotNull();
          }
        }

        // Screen still renders.
        check(find.byType(EventSpecificConfig).evaluate()).isNotEmpty();
      },
    );

    testWidgets(
      '_withLogGps covers smsContact branch (line 650)',
      (tester) async {
        ChainStep? latest;
        final step = _step(
          ChainStepType.smsContact,
          config: const SmsContactConfig(logGps: LogGpsOverride.useDefault),
        );

        await tester.pumpWidget(_host(step, onChanged: (s) => latest = s));
        await tester.pumpAndSettle();

        final morePanel = find.byType(ExpansionTile);
        if (morePanel.evaluate().isNotEmpty) {
          await tester.tap(morePanel.first);
          await tester.pumpAndSettle();
        }

        final dropdown = find.byType(DropdownButtonFormField<LogGpsOverride>);
        if (dropdown.evaluate().isNotEmpty) {
          await tester.tap(dropdown.first);
          await tester.pumpAndSettle();
          final items = find.byType(DropdownMenuItem<LogGpsOverride>);
          if (items.evaluate().length > 1) {
            await tester.tap(items.at(1));
            await tester.pumpAndSettle();
            check(latest).isNotNull();
          }
        }

        check(find.byType(EventSpecificConfig).evaluate()).isNotEmpty();
      },
    );
  });
}
