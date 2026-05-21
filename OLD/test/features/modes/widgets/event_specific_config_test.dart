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

  testWidgets('EventSpecificConfig renders for disguisedReminder + preview', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_step(ChainStepType.disguisedReminder)));
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.play_arrow).evaluate().length).equals(1);
  });

  testWidgets('EventSpecificConfig renders for countdownWarning + preview', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_step(ChainStepType.countdownWarning)));
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.play_arrow).evaluate().length).equals(1);
  });

  testWidgets('EventSpecificConfig renders for fakeCall + preview', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_step(ChainStepType.fakeCall)));
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.play_arrow).evaluate().length).equals(1);
  });

  testWidgets('EventSpecificConfig renders for smsContact (no preview)', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_step(ChainStepType.smsContact)));
    await tester.pumpAndSettle();
    // SMS/phone contact do not expose a preview — side effects would
    // be too expensive (real-send) to simulate in a preview.
    check(find.byIcon(Icons.play_arrow).evaluate()).isEmpty();
  });

  testWidgets('EventSpecificConfig renders for phoneCallContact (no preview)', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_step(ChainStepType.phoneCallContact)));
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.play_arrow).evaluate()).isEmpty();
  });

  testWidgets('EventSpecificConfig renders for loudAlarm + preview', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_step(ChainStepType.loudAlarm)));
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.play_arrow).evaluate().length).equals(1);
  });

  testWidgets('EventSpecificConfig renders for callEmergency (no preview)', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_step(ChainStepType.callEmergency)));
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.play_arrow).evaluate()).isEmpty();
  });

  testWidgets('EventSpecificConfig renders for hardwareButton (no preview)', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_step(ChainStepType.hardwareButton)));
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.play_arrow).evaluate()).isEmpty();
  });

  testWidgets('Preview button fires a SnackBar for disguisedReminder', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_step(ChainStepType.disguisedReminder)));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.play_arrow));
    // The preview path calls executeReal() on the simulation
    // notification service; once it resolves a SnackBar pops up.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
    check(find.byType(SnackBar).evaluate().length).isGreaterOrEqual(1);
  });

  testWidgets('Preview button fires a SnackBar for countdownWarning', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_step(ChainStepType.countdownWarning)));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
    check(find.byType(SnackBar).evaluate().length).isGreaterOrEqual(1);
  });

  // ─── onChanged interaction tests, one per editable field ───
  // Hit the inner onChanged closures across all 9 step types.

  Widget hostWith(ChainStep step, ValueChanged<ChainStep> onChanged) =>
      hostScreen(
        child: Scaffold(
          body: SingleChildScrollView(
            child: EventSpecificConfig(step: step, onChanged: onChanged),
          ),
        ),
      );

  // holdButton step UI is now empty — release sensitivity is a
  // global default in Settings → Defaults → Hold button.
  testWidgets('holdButton: form renders empty (no per-step fields)', (
    tester,
  ) async {
    final step = _step(
      ChainStepType.holdButton,
      config: const HoldButtonConfig(releaseSensitivity: 2.0),
    );
    await tester.pumpWidget(hostWith(step, (_) {}));
    await tester.pumpAndSettle();
    check(find.byType(TextFormField).evaluate()).isEmpty();
    check(find.byType(SwitchListTile).evaluate()).isEmpty();
  });

  // bugs.json Note 3 — the disguisedReminder form no longer renders
  // the legacy intervalSeconds text input. The field stays on the
  // model for round-trip but the engine drives reminder cadence
  // from ChainStep.waitSeconds. The form body is empty, so this
  // smoke test verifies it renders without crashing.
  testWidgets('disguisedReminder form renders (no interval input)', (
    tester,
  ) async {
    final step = _step(
      ChainStepType.disguisedReminder,
      config: const DisguisedReminderConfig(intervalSeconds: 45),
    );
    await tester.pumpWidget(hostWith(step, (_) {}));
    await tester.pumpAndSettle();
    // The legacy interval input is gone — the form should NOT render
    // any TextFormField. The "Preview in simulation" button is the
    // only interactive surface left.
    check(find.byType(EventSpecificConfig).evaluate().length).equals(1);
    // Sanity: no intervalSeconds-specific field is present.
    check(find.byType(TextFormField).evaluate()).isEmpty();
  });

  // countdownWarning step UI is now empty — vibrate + playTone are
  // global defaults in Settings → Defaults → Countdown warning.
  testWidgets('countdownWarning: form renders empty (no per-step fields)', (
    tester,
  ) async {
    final step = _step(
      ChainStepType.countdownWarning,
      config: const CountdownWarningConfig(vibrate: false, playTone: false),
    );
    await tester.pumpWidget(hostWith(step, (_) {}));
    await tester.pumpAndSettle();
    check(find.byType(SwitchListTile).evaluate()).isEmpty();
  });

  testWidgets('fakeCall: edit caller name', (tester) async {
    ChainStep? latest;
    final step = _step(
      ChainStepType.fakeCall,
      config: const FakeCallConfig(callerName: 'Mom'),
    );
    await tester.pumpWidget(hostWith(step, (s) => latest = s));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Boss');
    await tester.pumpAndSettle();
    check(latest).isNotNull();
    check((latest!.config! as FakeCallConfig).callerName).equals('Boss');
  });

  // fakeCall.declineIsSafe is a global default — no per-step toggle.
  testWidgets('fakeCall: form has no decline-is-safe switch', (tester) async {
    final step = _step(
      ChainStepType.fakeCall,
      config: const FakeCallConfig(declineIsSafe: false),
    );
    await tester.pumpWidget(hostWith(step, (_) {}));
    await tester.pumpAndSettle();
    check(find.byType(SwitchListTile).evaluate()).isEmpty();
    // Caller name TextFormField is the only per-step field left.
    check(find.byType(TextFormField).evaluate().length).equals(1);
  });

  // smsContact.includeLocation is a global default — no per-step
  // toggle. The first SwitchListTile is now includeMedicalInfo.
  testWidgets('smsContact: toggle includeMedicalInfo (first switch)', (
    tester,
  ) async {
    ChainStep? latest;
    final step = _step(
      ChainStepType.smsContact,
      config: const SmsContactConfig(includeMedicalInfo: false),
    );
    await tester.pumpWidget(hostWith(step, (s) => latest = s));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile).first);
    await tester.pumpAndSettle();
    check(latest).isNotNull();
    check((latest!.config! as SmsContactConfig).includeMedicalInfo).isTrue();
  });

  // Q12: PhoneCallContactConfig no longer has a preSendSms switch.
  // The widget renders SizedBox.shrink() for this step type.
  testWidgets('phoneCallContact: form is empty (no switches)', (tester) async {
    final step = _step(
      ChainStepType.phoneCallContact,
      config: const PhoneCallContactConfig(),
    );
    await tester.pumpWidget(hostWith(step, (_) {}));
    await tester.pumpAndSettle();
    check(find.byType(SwitchListTile).evaluate()).isEmpty();
    check(find.byType(TextFormField).evaluate()).isEmpty();
  });

  // loudAlarm step UI is now empty — flashScreen, maxVolume,
  // soundChoice, flashLight all live in Settings → Defaults.
  testWidgets('loudAlarm: form renders empty (no per-step fields)', (
    tester,
  ) async {
    final step = _step(
      ChainStepType.loudAlarm,
      config: const LoudAlarmConfig(flashScreen: false, maxVolume: false),
    );
    await tester.pumpWidget(hostWith(step, (_) {}));
    await tester.pumpAndSettle();
    check(find.byType(SwitchListTile).evaluate()).isEmpty();
  });

  testWidgets('callEmergency: edit emergency number (non-empty)', (
    tester,
  ) async {
    ChainStep? latest;
    final step = _step(
      ChainStepType.callEmergency,
      config: const CallEmergencyConfig(emergencyNumber: '911'),
    );
    await tester.pumpWidget(hostWith(step, (s) => latest = s));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '112');
    await tester.pumpAndSettle();
    check(latest).isNotNull();
    check(
      (latest!.config! as CallEmergencyConfig).emergencyNumber,
    ).equals('112');
  });

  testWidgets('callEmergency: edit emergency number (empty clears)', (
    tester,
  ) async {
    ChainStep? latest;
    final step = _step(
      ChainStepType.callEmergency,
      config: const CallEmergencyConfig(emergencyNumber: '911'),
    );
    await tester.pumpWidget(hostWith(step, (s) => latest = s));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '');
    await tester.pumpAndSettle();
    check(latest).isNotNull();
    check((latest!.config! as CallEmergencyConfig).emergencyNumber).isNull();
  });

  // callEmergency.showConfirmation is a global default — not exposed
  // per-step. The only per-step field is the emergency-number override.
  testWidgets('callEmergency: form has no confirmation switch', (tester) async {
    final step = _step(
      ChainStepType.callEmergency,
      config: const CallEmergencyConfig(showConfirmation: false),
    );
    await tester.pumpWidget(hostWith(step, (_) {}));
    await tester.pumpAndSettle();
    check(find.byType(SwitchListTile).evaluate()).isEmpty();
    check(find.byType(TextFormField).evaluate().length).equals(1);
  });

  testWidgets('hardwareButton: edit press count TextField (#9)', (
    tester,
  ) async {
    ChainStep? latest;
    final step = _step(
      ChainStepType.hardwareButton,
      config: const HardwareButtonConfig(pressCount: 5),
    );
    await tester.pumpWidget(hostWith(step, (s) => latest = s));
    await tester.pumpAndSettle();
    // Issues-v4 #9 — the repeat-press pattern now also renders a
    // press-window TextFormField, so enter into the FIRST field
    // (press count) explicitly.
    await tester.enterText(find.byType(TextFormField).first, '7');
    await tester.pumpAndSettle();
    check(latest).isNotNull();
    check((latest!.config! as HardwareButtonConfig).pressCount).equals(7);
  });

  testWidgets('hardwareButton: edit press window (#9)', (tester) async {
    ChainStep? latest;
    final step = _step(
      ChainStepType.hardwareButton,
      config: const HardwareButtonConfig(
        pattern: HardwarePattern.repeatPress,
        pressWindowMs: 500,
      ),
    );
    await tester.pumpWidget(hostWith(step, (s) => latest = s));
    await tester.pumpAndSettle();
    // Two TextFormFields in repeat-press mode: count + window.
    final fields = find.byType(TextFormField);
    check(fields.evaluate().length).equals(2);
    await tester.enterText(fields.last, '1500');
    await tester.pumpAndSettle();
    check(latest).isNotNull();
    check((latest!.config! as HardwareButtonConfig).pressWindowMs).equals(1500);
  });

  testWidgets('hardwareButton: long-press shows long-duration field (#9)', (
    tester,
  ) async {
    ChainStep? latest;
    final step = _step(
      ChainStepType.hardwareButton,
      config: const HardwareButtonConfig(
        pattern: HardwarePattern.longPress,
        longPressDurationSeconds: 2.5,
      ),
    );
    await tester.pumpWidget(hostWith(step, (s) => latest = s));
    await tester.pumpAndSettle();
    // Long-press: only ONE TextFormField (long duration).
    final fields = find.byType(TextFormField);
    check(fields.evaluate().length).equals(1);
    await tester.enterText(fields.first, '4.0');
    await tester.pumpAndSettle();
    check(latest).isNotNull();
    check(
      (latest!.config! as HardwareButtonConfig).longPressDurationSeconds,
    ).equals(4.0);
  });

  testWidgets(
    'hardwareButton: switching to long-press hides count + window (#9)',
    (tester) async {
      ChainStep? latest;
      final step = _step(
        ChainStepType.hardwareButton,
        config: const HardwareButtonConfig(
          pattern: HardwarePattern.repeatPress,
        ),
      );
      await tester.pumpWidget(hostWith(step, (s) => latest = s));
      await tester.pumpAndSettle();
      // Two fields in repeat-press mode.
      check(find.byType(TextFormField).evaluate().length).equals(2);
      // Tap the pattern dropdown and pick long-press.
      await tester.tap(find.byType(DropdownButtonFormField<HardwarePattern>));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownMenuItem<HardwarePattern>).last);
      await tester.pumpAndSettle();
      check(latest).isNotNull();
      // Re-pump with the updated step so the form rebuilds.
      await tester.pumpWidget(hostWith(latest!, (s) => latest = s));
      await tester.pumpAndSettle();
      check(find.byType(TextFormField).evaluate().length).equals(1);
    },
  );

  testWidgets('smsContact: dropdown selects specificIds', (tester) async {
    ChainStep? latest;
    final step = _step(
      ChainStepType.smsContact,
      config: const SmsContactConfig(
        contactSelection: SmsContactSelection.allContacts,
      ),
    );
    await tester.pumpWidget(hostWith(step, (s) => latest = s));
    await tester.pumpAndSettle();
    // Open the DropdownButtonFormField, then tap the "specific"
    // item. The dropdown title strings come from l10n; tap by the
    // item type rather than by string.
    await tester.tap(find.byType(DropdownButtonFormField<SmsContactSelection>));
    await tester.pumpAndSettle();
    // A second "Specific" entry is rendered in the overlay.
    await tester.tap(find.byType(DropdownMenuItem<SmsContactSelection>).last);
    await tester.pumpAndSettle();
    check(latest).isNotNull();
    check(
      (latest!.config! as SmsContactConfig).contactSelection,
    ).equals(SmsContactSelection.specificIds);
  });

  testWidgets('hardwareButton: dropdown changes button type', (tester) async {
    ChainStep? latest;
    final step = _step(
      ChainStepType.hardwareButton,
      config: const HardwareButtonConfig(buttonType: ButtonType.volumeUp),
    );
    await tester.pumpWidget(hostWith(step, (s) => latest = s));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<ButtonType>));
    await tester.pumpAndSettle();
    // The overlay contains three items; tap the "power" one (last).
    await tester.tap(find.byType(DropdownMenuItem<ButtonType>).last);
    await tester.pumpAndSettle();
    check(latest).isNotNull();
    check(
      (latest!.config! as HardwareButtonConfig).buttonType,
    ).equals(ButtonType.power);
  });

  testWidgets('hardwareButton: dropdown changes pattern', (tester) async {
    ChainStep? latest;
    final step = _step(
      ChainStepType.hardwareButton,
      config: const HardwareButtonConfig(pattern: HardwarePattern.repeatPress),
    );
    await tester.pumpWidget(hostWith(step, (s) => latest = s));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<HardwarePattern>));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownMenuItem<HardwarePattern>).last);
    await tester.pumpAndSettle();
    check(latest).isNotNull();
    check(
      (latest!.config! as HardwareButtonConfig).pattern,
    ).equals(HardwarePattern.longPress);
  });
}
