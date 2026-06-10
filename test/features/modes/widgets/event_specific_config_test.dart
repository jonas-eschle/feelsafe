/// Widget tests for [EventSpecificConfig]: the iOS platform-limitation
/// warnings (spec 02:325, 02:479), the SMS message-template editor (spec
/// 02:287-304), the per-field info icons + live preview cards (spec
/// 04:1591), and the disguisedReminder manage-templates link (spec 04:1635).
///
/// The iOS warnings are gated on `Theme.of(context).platform`, so the test
/// harness injects the platform via `ThemeData(platform: ...)` — a real,
/// host-testable platform override (no dependency on the runtime OS). The
/// iOS *build* itself is verified by CI's `build-ios` job; these tests cover
/// the platform-gated Dart behaviour.
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/utils/ringtone_picker.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/button_type.dart';
import 'package:guardianangela/domain/enums/call_style.dart';
import 'package:guardianangela/domain/enums/countdown_style.dart';
import 'package:guardianangela/domain/enums/hold_style.dart';
import 'package:guardianangela/domain/enums/loud_alarm_sound.dart';
import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/enums/press_pattern.dart';
import 'package:guardianangela/domain/enums/sms_contact_selection.dart';
import 'package:guardianangela/domain/enums/voice_output_mode.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/orchestration/strategies/sms_contact_strategy.dart';
import 'package:guardianangela/features/modes/widgets/event_specific_config.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import '../../../helpers/widget_test_helpers.dart';

/// Fake [RingtonePicker] that returns a canned stored path (or null for a
/// cancel) without touching `file_selector` or the filesystem.
class _FakeRingtonePicker extends RingtonePicker {
  _FakeRingtonePicker(this._result);

  final String? _result;
  int callCount = 0;

  @override
  Future<String?> pickAndStoreRingtone() async {
    callCount++;
    return _result;
  }
}

/// Pumps a fakeCall [config] inside [EventSpecificConfig] with an injected
/// [ringtonePicker], capturing the emitted config via [onChanged].
Future<void> _pumpFakeCall(
  WidgetTester tester,
  FakeCallConfig config, {
  required ValueChanged<FakeCallConfig> onChanged,
  RingtonePicker? ringtonePicker,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        platform: TargetPlatform.android,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF131118)),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: EventSpecificConfig(
            config: config,
            onChanged: (StepConfig c) => onChanged(c as FakeCallConfig),
            ringtonePicker: ringtonePicker,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Pumps [config] inside an [EventSpecificConfig] under a [MaterialApp] whose
/// theme reports [platform], so the iOS-gated warnings resolve against it.
Future<void> _pump(
  WidgetTester tester,
  StepConfig config, {
  required TargetPlatform platform,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        platform: platform,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF131118)),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: EventSpecificConfig(
            config: config,
            onChanged: (_) {},
            // Non-null contacts → the smsContact grid renders; harmless for the
            // template/warning assertions and exercises the real Mode-Editor
            // context path.
            contacts: const <EmergencyContact>[],
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('EventSpecificConfig — iOS SMS warning (spec 02:325)', () {
    testWidgets('shows the SMS warning on iOS with the SMS channel', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        const SmsContactConfig(),
        platform: TargetPlatform.iOS,
      );
      expect(find.text(l10n.eventDefaultsSmsIosWarning), findsOneWidget);
    });

    testWidgets('hides the SMS warning on iOS when channel is WhatsApp', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        const SmsContactConfig(channel: MessageChannel.whatsapp),
        platform: TargetPlatform.iOS,
      );
      expect(find.text(l10n.eventDefaultsSmsIosWarning), findsNothing);
    });

    testWidgets('hides the SMS warning on Android with the SMS channel', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        const SmsContactConfig(),
        platform: TargetPlatform.android,
      );
      expect(find.text(l10n.eventDefaultsSmsIosWarning), findsNothing);
    });
  });

  group('EventSpecificConfig — iOS callEmergency warning (spec 02:479)', () {
    testWidgets('shows the call warning on iOS', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        const CallEmergencyConfig(),
        platform: TargetPlatform.iOS,
      );
      expect(
        find.text(l10n.eventDefaultsCallEmergencyIosWarning),
        findsOneWidget,
      );
    });

    testWidgets('hides the call warning on Android', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        const CallEmergencyConfig(),
        platform: TargetPlatform.android,
      );
      expect(
        find.text(l10n.eventDefaultsCallEmergencyIosWarning),
        findsNothing,
      );
    });
  });

  group('EventSpecificConfig — SMS message template (spec 02:287-304)', () {
    testWidgets('renders the template field and a placeholder chip', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        const SmsContactConfig(),
        platform: TargetPlatform.android,
      );
      expect(
        find.widgetWithText(TextField, l10n.eventDefaultsSmsMessageTemplate),
        findsOneWidget,
      );
      // Every spec placeholder is offered as an insert chip.
      for (final String token in kSmsTemplatePlaceholders) {
        expect(find.widgetWithText(ActionChip, token), findsOneWidget);
      }
    });

    testWidgets('pre-fills the field from an existing template', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const SmsContactConfig(messageTemplate: 'Help {name}'),
        platform: TargetPlatform.android,
      );
      expect(find.text('Help {name}'), findsOneWidget);
    });

    testWidgets('a blank template commits as null (use default)', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      SmsContactConfig? emitted;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const <LocalizationsDelegate<Object>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            platform: TargetPlatform.android,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF131118),
            ),
            useMaterial3: true,
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              child: EventSpecificConfig(
                config: const SmsContactConfig(messageTemplate: 'old'),
                onChanged: (StepConfig c) => emitted = c as SmsContactConfig,
                contacts: const <EmergencyContact>[],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final Finder field = find.widgetWithText(
        TextField,
        l10n.eventDefaultsSmsMessageTemplate,
      );
      await tester.enterText(field, '   ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      // Blank/whitespace → null (revert to the seeded default), proving the
      // direct-construct clear path (copyWith cannot null the field).
      check(emitted).isNotNull();
      check(emitted!.messageTemplate).isNull();
    });
  });

  group('EventSpecificConfig — fakeCall ringtone picker (Tier-F F3)', () {
    testWidgets('shows "Default ring" when no custom ringtone is set', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpFakeCall(tester, const FakeCallConfig(), onChanged: (_) {});
      expect(
        find.text(l10n.eventDefaultsFakeCallRingtoneDefault),
        findsOneWidget,
      );
      // No "Use default" clear button when already on the default.
      expect(
        find.text(l10n.eventDefaultsFakeCallRingtoneUseDefault),
        findsNothing,
      );
    });

    testWidgets('shows the file name when a custom ringtone is set', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpFakeCall(
        tester,
        const FakeCallConfig(customRingtonePath: '/data/ringtones/abc123.mp3'),
        onChanged: (_) {},
      );
      expect(
        find.text(l10n.eventDefaultsFakeCallRingtoneCustom('abc123.mp3')),
        findsOneWidget,
      );
      // The clear button is offered once a custom ringtone is set.
      expect(
        find.text(l10n.eventDefaultsFakeCallRingtoneUseDefault),
        findsOneWidget,
      );
    });

    testWidgets('tapping Choose imports a ringtone and emits the stored path', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final picker = _FakeRingtonePicker('/data/ringtones/picked.m4a');
      FakeCallConfig? emitted;
      await _pumpFakeCall(
        tester,
        const FakeCallConfig(),
        onChanged: (FakeCallConfig c) => emitted = c,
        ringtonePicker: picker,
      );
      await tester.tap(find.text(l10n.eventDefaultsFakeCallRingtoneChoose));
      await tester.pumpAndSettle();
      check(picker.callCount).equals(1);
      check(emitted).isNotNull();
      check(emitted!.customRingtonePath).equals('/data/ringtones/picked.m4a');
    });

    testWidgets('a cancelled pick leaves the config unchanged (no emit)', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final picker = _FakeRingtonePicker(null); // user cancels
      FakeCallConfig? emitted;
      await _pumpFakeCall(
        tester,
        const FakeCallConfig(),
        onChanged: (FakeCallConfig c) => emitted = c,
        ringtonePicker: picker,
      );
      await tester.tap(find.text(l10n.eventDefaultsFakeCallRingtoneChoose));
      await tester.pumpAndSettle();
      check(picker.callCount).equals(1);
      check(emitted).isNull();
    });

    testWidgets('tapping Use default clears the custom ringtone to null', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      FakeCallConfig? emitted;
      await _pumpFakeCall(
        tester,
        const FakeCallConfig(
          callerName: 'Mom',
          customRingtonePath: '/data/ringtones/x.mp3',
        ),
        onChanged: (FakeCallConfig c) => emitted = c,
      );
      await tester.tap(find.text(l10n.eventDefaultsFakeCallRingtoneUseDefault));
      await tester.pumpAndSettle();
      // Direct-construct clear: path null, other fields preserved.
      check(emitted).isNotNull();
      check(emitted!.customRingtonePath).isNull();
      check(emitted!.callerName).equals('Mom');
    });
  });

  // ── Per-type field interactions (spec 02 §per-type config) ───────────────
  //
  // Each test drives a real control of one per-type form and asserts the
  // emitted config carries exactly that change.

  group('EventSpecificConfig — holdButton fields', () {
    testWidgets('hold-style dropdown and sensitivity slider emit changes', (
      WidgetTester tester,
    ) async {
      StepConfig? emitted;
      await _pumpForm(
        tester,
        const HoldButtonConfig(),
        onChanged: (StepConfig c) => emitted = c,
      );

      await _pickEnum(
        tester,
        HoldStyle.largeButton.name,
        HoldStyle.fullScreen.name,
      );
      check(emitted).isA<HoldButtonConfig>();
      check(
        (emitted! as HoldButtonConfig).holdStyle,
      ).equals(HoldStyle.fullScreen);

      await tester.drag(find.byType(Slider), const Offset(80, 0));
      await tester.pumpAndSettle();
      check(
        (emitted! as HoldButtonConfig).releaseSensitivity,
      ).not((it) => it.equals(1.0));
    });
  });

  group('EventSpecificConfig — disguisedReminder fields', () {
    testWidgets('randomize-interval and randomize-template toggles emit', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      StepConfig? emitted;
      await _pumpForm(
        tester,
        const DisguisedReminderConfig(),
        onChanged: (StepConfig c) => emitted = c,
      );

      await _toggleSwitch(tester, l10n.eventDefaultsReminderRandomInterval);
      check((emitted! as DisguisedReminderConfig).randomizeInterval).isFalse();

      await _toggleSwitch(tester, l10n.eventDefaultsReminderRandomTemplate);
      check(
        (emitted! as DisguisedReminderConfig).randomizeTemplateOrder,
      ).isFalse();
    });
  });

  group('EventSpecificConfig — countdownWarning fields', () {
    testWidgets('style dropdown and vibrate toggle emit changes', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      StepConfig? emitted;
      await _pumpForm(
        tester,
        const CountdownWarningConfig(),
        onChanged: (StepConfig c) => emitted = c,
      );

      await _pickEnum(
        tester,
        CountdownStyle.fullScreen.name,
        CountdownStyle.minimal.name,
      );
      check(
        (emitted! as CountdownWarningConfig).style,
      ).equals(CountdownStyle.minimal);

      await _toggleSwitch(tester, l10n.eventDefaultsCountdownVibrate);
      check((emitted! as CountdownWarningConfig).vibrate).isFalse();
    });
  });

  group('EventSpecificConfig — fakeCall fields', () {
    testWidgets('call style, ring duration, and voice output emit changes', (
      WidgetTester tester,
    ) async {
      StepConfig? emitted;
      await _pumpForm(
        tester,
        const FakeCallConfig(),
        onChanged: (StepConfig c) => emitted = c,
      );

      await _pickEnum(
        tester,
        CallStyle.platformNative.name,
        CallStyle.signal.name,
      );
      check((emitted! as FakeCallConfig).callStyle).equals(CallStyle.signal);

      await _tapSpinnerPlus(tester);
      check((emitted! as FakeCallConfig).ringDurationSeconds).equals(31);

      await _pickEnum(
        tester,
        VoiceOutputMode.earpiece.name,
        VoiceOutputMode.speaker.name,
      );
      check(
        (emitted! as FakeCallConfig).voiceOutputMode,
      ).equals(VoiceOutputMode.speaker);
    });

    testWidgets('caller name commits; an empty name falls back to Angela', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      StepConfig? emitted;
      await _pumpForm(
        tester,
        const FakeCallConfig(),
        onChanged: (StepConfig c) => emitted = c,
      );

      await _commitText(tester, l10n.eventDefaultsFakeCallCallerName, 'Mom');
      check((emitted! as FakeCallConfig).callerName).equals('Mom');

      await _commitText(tester, l10n.eventDefaultsFakeCallCallerName, '');
      check((emitted! as FakeCallConfig).callerName).equals('Angela');
    });
  });

  group('EventSpecificConfig — smsContact fields', () {
    testWidgets('channel dropdown, include-medical, and record duration emit', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      StepConfig? emitted;
      // autoRecordAudio: true so the record-duration spinner is shown.
      await _pumpForm(
        tester,
        const SmsContactConfig(autoRecordAudio: true),
        onChanged: (StepConfig c) => emitted = c,
      );

      await _pickEnum(
        tester,
        MessageChannel.sms.name,
        MessageChannel.telegram.name,
      );
      check(
        (emitted! as SmsContactConfig).channel,
      ).equals(MessageChannel.telegram);

      await _toggleSwitch(tester, l10n.eventDefaultsSmsIncludeMedical);
      check((emitted! as SmsContactConfig).includeMedicalInfo).isTrue();

      await _tapSpinnerPlus(tester);
      check((emitted! as SmsContactConfig).recordDurationSeconds).equals(31);
    });
  });

  group('EventSpecificConfig — phoneCallContact fields', () {
    testWidgets('primary contact commits; clearing it emits null', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      StepConfig? emitted;
      await _pumpForm(
        tester,
        const PhoneCallContactConfig(contactId: 'c1'),
        onChanged: (StepConfig c) => emitted = c,
      );

      await _commitText(tester, l10n.eventDefaultsPhonePrimaryContact, 'c9');
      check((emitted! as PhoneCallContactConfig).contactId).equals('c9');

      // Clearing the field must clear the id (null = no primary contact) —
      // a plain copyWith would silently keep the old id.
      await _commitText(tester, l10n.eventDefaultsPhonePrimaryContact, '');
      check((emitted! as PhoneCallContactConfig).contactId).isNull();
    });
  });

  group('EventSpecificConfig — loudAlarm fields', () {
    testWidgets('volume slider and sound dropdown emit changes', (
      WidgetTester tester,
    ) async {
      StepConfig? emitted;
      await _pumpForm(
        tester,
        const LoudAlarmConfig(volume: 0.5),
        onChanged: (StepConfig c) => emitted = c,
      );

      await tester.drag(find.byType(Slider), const Offset(80, 0));
      await tester.pumpAndSettle();
      check((emitted! as LoudAlarmConfig).volume).not((it) => it.equals(0.5));

      await _pickEnum(
        tester,
        LoudAlarmSound.siren.name,
        LoudAlarmSound.custom.name,
      );
      check(
        (emitted! as LoudAlarmConfig).soundChoice,
      ).equals(LoudAlarmSound.custom);
    });

    testWidgets('flash-screen and flash-light toggles emit changes', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      StepConfig? emitted;
      await _pumpForm(
        tester,
        const LoudAlarmConfig(),
        onChanged: (StepConfig c) => emitted = c,
      );

      await _toggleSwitch(tester, l10n.eventDefaultsLoudAlarmFlashScreen);
      check((emitted! as LoudAlarmConfig).flashScreen).isTrue();

      await _toggleSwitch(tester, l10n.eventDefaultsLoudAlarmFlashLight);
      check((emitted! as LoudAlarmConfig).flashLight).isFalse();
    });
  });

  group('EventSpecificConfig — callEmergency fields', () {
    testWidgets('number commits; clearing it emits null (use default)', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      StepConfig? emitted;
      await _pumpForm(
        tester,
        const CallEmergencyConfig(emergencyNumber: '911'),
        onChanged: (StepConfig c) => emitted = c,
      );

      await _commitText(tester, l10n.eventDefaultsCallEmergencyNumber, '112');
      check((emitted! as CallEmergencyConfig).emergencyNumber).equals('112');

      // Clearing must revert to null (regional default number) — a plain
      // copyWith would silently keep the old number.
      await _commitText(tester, l10n.eventDefaultsCallEmergencyNumber, '');
      check((emitted! as CallEmergencyConfig).emergencyNumber).isNull();
    });

    testWidgets('confirmation duration spinner and confirm toggle emit', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      StepConfig? emitted;
      await _pumpForm(
        tester,
        const CallEmergencyConfig(),
        onChanged: (StepConfig c) => emitted = c,
      );

      await _tapSpinnerPlus(tester);
      check(
        (emitted! as CallEmergencyConfig).confirmationDurationSeconds,
      ).equals(6);

      await _toggleSwitch(tester, l10n.eventDefaultsCallEmergencyConfirm);
      check((emitted! as CallEmergencyConfig).showConfirmation).isFalse();
    });
  });

  group('EventSpecificConfig — hardwareButton fields', () {
    testWidgets('button + pattern dropdowns and press-count spinner emit', (
      WidgetTester tester,
    ) async {
      StepConfig? emitted;
      await _pumpForm(
        tester,
        const HardwareButtonConfig(),
        onChanged: (StepConfig c) => emitted = c,
      );

      await _pickEnum(
        tester,
        ButtonType.volumeUp.name,
        ButtonType.volumeDown.name,
      );
      check(
        (emitted! as HardwareButtonConfig).buttonType,
      ).equals(ButtonType.volumeDown);

      await _tapSpinnerPlus(tester);
      check((emitted! as HardwareButtonConfig).pressCount).equals(6);

      await _pickEnum(
        tester,
        PressPattern.repeatPress.name,
        PressPattern.longPress.name,
      );
      check(
        (emitted! as HardwareButtonConfig).pressPattern,
      ).equals(PressPattern.longPress);
    });

    testWidgets('long-press duration slider emits under longPress pattern', (
      WidgetTester tester,
    ) async {
      StepConfig? emitted;
      await _pumpForm(
        tester,
        const HardwareButtonConfig(pressPattern: PressPattern.longPress),
        onChanged: (StepConfig c) => emitted = c,
      );

      await tester.drag(find.byType(Slider), const Offset(80, 0));
      await tester.pumpAndSettle();
      check(
        (emitted! as HardwareButtonConfig).longPressDurationSeconds,
      ).not((it) => it.equals(2.0));
    });
  });

  // ── Per-field info icons (spec 04:1591) ───────────────────────────────────
  //
  // "Every field has a small info-icon button that opens a bottom sheet with
  // a plain-language explanation." Each test pumps one real form, asserts an
  // info button exists for EVERY field (found via its tooltip = field label),
  // and opens at least one sheet to verify the right l10n body renders.

  group('EventSpecificConfig — per-field info icons (spec 04:1591)', () {
    testWidgets('holdButton: all 5 fields, holdStyle sheet opens', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpForm(tester, const HoldButtonConfig(), onChanged: (_) {});
      _expectInfoButtons(<String>[
        l10n.eventDefaultsHoldStyle,
        l10n.eventDefaultsHoldSensitivity,
        l10n.eventDefaultsHoldVibrate,
        l10n.eventDefaultsHoldSound,
        l10n.eventDefaultsBlackScreen,
      ]);
      await _openInfoSheet(
        tester,
        title: l10n.eventDefaultsHoldStyle,
        body: l10n.eventDefaultsHoldStyleInfo,
      );
    });

    testWidgets('disguisedReminder: all 4 fields, resetOnEarly sheet opens', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpForm(
        tester,
        const DisguisedReminderConfig(),
        onChanged: (_) {},
      );
      _expectInfoButtons(<String>[
        l10n.eventDefaultsReminderRandomInterval,
        l10n.eventDefaultsReminderRandomTemplate,
        l10n.eventDefaultsReminderResetOnEarly,
        l10n.eventDefaultsBlackScreen,
      ]);
      await _openInfoSheet(
        tester,
        title: l10n.eventDefaultsReminderResetOnEarly,
        body: l10n.eventDefaultsReminderResetOnEarlyInfo,
      );
    });

    testWidgets('countdownWarning: all 4 fields, style sheet opens', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpForm(
        tester,
        const CountdownWarningConfig(),
        onChanged: (_) {},
      );
      _expectInfoButtons(<String>[
        l10n.eventDefaultsCountdownStyle,
        l10n.eventDefaultsCountdownVibrate,
        l10n.eventDefaultsCountdownSound,
        l10n.eventDefaultsBlackScreen,
      ]);
      await _openInfoSheet(
        tester,
        title: l10n.eventDefaultsCountdownStyle,
        body: l10n.eventDefaultsCountdownStyleInfo,
      );
    });

    testWidgets('fakeCall: all 7 fields, declineIsSafe sheet opens', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpForm(tester, const FakeCallConfig(), onChanged: (_) {});
      _expectInfoButtons(<String>[
        l10n.eventDefaultsFakeCallStyle,
        l10n.eventDefaultsFakeCallCallerName,
        l10n.eventDefaultsFakeCallRingDuration,
        l10n.eventDefaultsFakeCallVoiceOutput,
        l10n.eventDefaultsFakeCallRingtone,
        l10n.eventDefaultsFakeCallDeclineIsSafe,
        l10n.eventDefaultsBlackScreen,
      ]);
      await _openInfoSheet(
        tester,
        title: l10n.eventDefaultsFakeCallDeclineIsSafe,
        body: l10n.eventDefaultsFakeCallDeclineIsSafeInfo,
      );
    });

    testWidgets('smsContact: all 7 fields, template sheet shows the literal '
        'placeholder tokens', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      // autoRecordAudio: true so the record-duration field is rendered too.
      await _pumpForm(
        tester,
        const SmsContactConfig(autoRecordAudio: true),
        onChanged: (_) {},
      );
      _expectInfoButtons(<String>[
        l10n.eventDefaultsSmsChannel,
        l10n.eventDefaultsSmsMessageTemplate,
        l10n.eventDefaultsSmsIncludeLocation,
        l10n.eventDefaultsSmsIncludeMedical,
        l10n.eventDefaultsSmsAutoRecord,
        l10n.eventDefaultsSmsRecordDuration,
        l10n.eventDefaultsBlackScreen,
      ]);
      await _openInfoSheet(
        tester,
        title: l10n.eventDefaultsSmsMessageTemplate,
        body: l10n.eventDefaultsSmsMessageTemplateInfo('{name}', '{location}'),
      );
    });

    testWidgets('smsContact recipients grid header has an info icon too', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpStateful(
        tester,
        const SmsContactConfig(),
        contacts: <EmergencyContact>[_contact('a', 'Alice')],
      );
      await _openInfoSheet(
        tester,
        title: l10n.smsContactRecipientsHeader,
        body: l10n.smsContactRecipientsInfo,
      );
    });

    testWidgets('phoneCallContact: both fields, primary-contact sheet opens', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpForm(
        tester,
        const PhoneCallContactConfig(),
        onChanged: (_) {},
      );
      _expectInfoButtons(<String>[
        l10n.eventDefaultsPhonePrimaryContact,
        l10n.eventDefaultsBlackScreen,
      ]);
      await _openInfoSheet(
        tester,
        title: l10n.eventDefaultsPhonePrimaryContact,
        body: l10n.eventDefaultsPhonePrimaryContactInfo,
      );
    });

    testWidgets('loudAlarm: all 6 fields, flash-screen sheet opens', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpForm(tester, const LoudAlarmConfig(), onChanged: (_) {});
      _expectInfoButtons(<String>[
        l10n.eventDefaultsLoudAlarmVolume,
        l10n.eventDefaultsLoudAlarmSound,
        l10n.eventDefaultsLoudAlarmFlashScreen,
        l10n.eventDefaultsLoudAlarmFlashLight,
        l10n.eventDefaultsLoudAlarmGradual,
        l10n.eventDefaultsBlackScreen,
      ]);
      await _openInfoSheet(
        tester,
        title: l10n.eventDefaultsLoudAlarmFlashScreen,
        body: l10n.eventDefaultsLoudAlarmFlashScreenInfo,
      );
    });

    testWidgets('callEmergency: all 5 fields, confirm sheet opens', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      // showConfirmation defaults to true → the duration field is rendered.
      await _pumpForm(tester, const CallEmergencyConfig(), onChanged: (_) {});
      _expectInfoButtons(<String>[
        l10n.eventDefaultsCallEmergencyNumber,
        l10n.eventDefaultsCallEmergencySmsFirst,
        l10n.eventDefaultsCallEmergencyConfirm,
        l10n.eventDefaultsCallEmergencyConfirmDuration,
        l10n.eventDefaultsBlackScreen,
      ]);
      await _openInfoSheet(
        tester,
        title: l10n.eventDefaultsCallEmergencyConfirm,
        body: l10n.eventDefaultsCallEmergencyConfirmInfo,
      );
    });

    testWidgets('hardwareButton (repeat): all 4 fields, button sheet opens', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpForm(tester, const HardwareButtonConfig(), onChanged: (_) {});
      _expectInfoButtons(<String>[
        l10n.eventDefaultsHardwareButton,
        l10n.eventDefaultsHardwarePattern,
        l10n.eventDefaultsHardwarePressCount,
        l10n.eventDefaultsBlackScreen,
      ]);
      await _openInfoSheet(
        tester,
        title: l10n.eventDefaultsHardwareButton,
        body: l10n.eventDefaultsHardwareButtonInfo,
      );
    });

    testWidgets('hardwareButton (longPress): duration field sheet opens', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpForm(
        tester,
        const HardwareButtonConfig(pressPattern: PressPattern.longPress),
        onChanged: (_) {},
      );
      await _openInfoSheet(
        tester,
        title: l10n.eventDefaultsHardwareLongDuration,
        body: l10n.eventDefaultsHardwareLongDurationInfo,
      );
    });
  });

  // ── Manage-templates link (spec 04:1635) ──────────────────────────────────

  group('EventSpecificConfig — manage-templates link (spec 04:1635)', () {
    testWidgets('renders the ListTile with icons and fires the callback', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      var tapped = 0;
      await _pumpStateful(
        tester,
        const DisguisedReminderConfig(),
        onManageTemplates: () => tapped++,
      );
      final Finder link = find.widgetWithText(
        ListTile,
        l10n.safetyOptionsManageTemplates,
      );
      expect(link, findsOneWidget);
      expect(find.byIcon(Icons.collections_outlined), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      await tester.ensureVisible(link);
      await tester.tap(link);
      check(tapped).equals(1);
    });

    testWidgets('an InfoIconButton above the link explains templates', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpStateful(
        tester,
        const DisguisedReminderConfig(),
        onManageTemplates: () {},
      );
      expect(
        find.text(l10n.eventDefaultsReminderTemplatesTitle),
        findsOneWidget,
      );
      await _openInfoSheet(
        tester,
        title: l10n.eventDefaultsReminderTemplatesTitle,
        body: l10n.eventDefaultsReminderTemplatesInfo,
      );
    });

    testWidgets('hidden in the Event Defaults context (no callback)', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpForm(
        tester,
        const DisguisedReminderConfig(),
        onChanged: (_) {},
      );
      expect(find.text(l10n.safetyOptionsManageTemplates), findsNothing);
      expect(find.text(l10n.eventDefaultsReminderTemplatesTitle), findsNothing);
    });
  });

  // ── Preview cards (spec 04:1591) ──────────────────────────────────────────
  //
  // "Three step types (fakeCall, smsContact, loudAlarm) render a preview
  // card so users can see the effect of their settings at a glance." The
  // reactivity tests drive a real form through a stateful harness (the
  // emitted config is fed back, exactly like both production callers).

  group('EventSpecificConfig — fakeCall preview card (spec 04:1591)', () {
    testWidgets('renders caller, ring summary, and decline meaning', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpStateful(tester, const FakeCallConfig());
      expect(find.text(l10n.eventPreviewCardLabel), findsOneWidget);
      expect(
        find.text(l10n.eventPreviewFakeCallCaller('Angela')),
        findsOneWidget,
      );
      expect(
        find.text(l10n.eventPreviewFakeCallRing(30, 'platformNative')),
        findsOneWidget,
      );
      expect(find.text(l10n.eventPreviewFakeCallDeclineSafe), findsOneWidget);
    });

    testWidgets('reacts to caller-name, ring-duration, and decline edits', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpStateful(tester, const FakeCallConfig());

      await _commitText(tester, l10n.eventDefaultsFakeCallCallerName, 'Mom');
      expect(find.text(l10n.eventPreviewFakeCallCaller('Mom')), findsOneWidget);

      await _tapSpinnerPlus(tester);
      expect(
        find.text(l10n.eventPreviewFakeCallRing(31, 'platformNative')),
        findsOneWidget,
      );

      await _toggleSwitch(tester, l10n.eventDefaultsFakeCallDeclineIsSafe);
      expect(
        find.text(l10n.eventPreviewFakeCallDeclineNotSafe),
        findsOneWidget,
      );
      expect(find.text(l10n.eventPreviewFakeCallDeclineSafe), findsNothing);
    });
  });

  group('EventSpecificConfig — smsContact preview card (spec 04:1591)', () {
    testWidgets('default config previews all-contacts and the seeded text', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpStateful(tester, const SmsContactConfig());
      expect(find.text(l10n.eventPreviewSmsToAll('sms')), findsOneWidget);
      expect(
        find.text(l10n.eventPreviewSmsMessage(kDefaultSmsMessageTemplate)),
        findsOneWidget,
      );
    });

    testWidgets('reacts to a channel change', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpStateful(tester, const SmsContactConfig());
      await _pickEnum(
        tester,
        MessageChannel.sms.name,
        MessageChannel.telegram.name,
      );
      expect(find.text(l10n.eventPreviewSmsToAll('telegram')), findsOneWidget);
      expect(find.text(l10n.eventPreviewSmsToAll('sms')), findsNothing);
    });

    testWidgets('reacts to deselecting a recipient in the grid', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpStateful(
        tester,
        const SmsContactConfig(),
        contacts: <EmergencyContact>[
          _contact('a', 'Alice'),
          _contact('b', 'Bob', sortOrder: 1),
        ],
      );
      expect(find.text(l10n.eventPreviewSmsToAll('sms')), findsOneWidget);
      // Deselect Alice → only Bob remains → specific-ids count form.
      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.eventPreviewSmsToCount(1, 'sms')), findsOneWidget);
      expect(find.text(l10n.eventPreviewSmsToAll('sms')), findsNothing);
    });

    testWidgets('previews a custom template verbatim', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpStateful(
        tester,
        const SmsContactConfig(messageTemplate: 'Help {name}'),
      );
      expect(
        find.text(l10n.eventPreviewSmsMessage('Help {name}')),
        findsOneWidget,
      );
    });

    testWidgets('covers the firstContact, legacy, and empty-ids summaries', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpForm(
        tester,
        const SmsContactConfig(
          contactSelection: SmsContactSelection.firstContact,
        ),
        onChanged: (_) {},
      );
      expect(find.text(l10n.eventPreviewSmsToFirst('sms')), findsOneWidget);

      // Legacy: allContacts + an explicit id list is treated as specific
      // IDs, mirroring the runtime resolver.
      await _pumpForm(
        tester,
        const SmsContactConfig(contactIds: <String>['a', 'b']),
        onChanged: (_) {},
      );
      expect(find.text(l10n.eventPreviewSmsToCount(2, 'sms')), findsOneWidget);

      await _pumpForm(
        tester,
        const SmsContactConfig(
          contactSelection: SmsContactSelection.specificIds,
        ),
        onChanged: (_) {},
      );
      expect(find.text(l10n.eventPreviewSmsToCount(0, 'sms')), findsOneWidget);
    });
  });

  group('EventSpecificConfig — loudAlarm preview card (spec 04:1591)', () {
    testWidgets('renders volume, sound, ramp, and flash summary', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      // Defaults: volume 1.0, siren, no ramp, camera flash on.
      await _pumpStateful(tester, const LoudAlarmConfig());
      expect(
        find.text(l10n.eventPreviewLoudAlarmTitle(100, 'siren')),
        findsOneWidget,
      );
      expect(find.text(l10n.eventPreviewLoudAlarmRampOff), findsOneWidget);
      expect(find.text(l10n.eventPreviewLoudAlarmFlashLight), findsOneWidget);
    });

    testWidgets('reacts to a volume drag and a gradual-ramp toggle', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpStateful(tester, const LoudAlarmConfig(volume: 0.5));
      expect(
        find.text(l10n.eventPreviewLoudAlarmTitle(50, 'siren')),
        findsOneWidget,
      );

      // A large drag saturates the slider at its max (volume 1.0).
      await tester.drag(find.byType(Slider), const Offset(400, 0));
      await tester.pumpAndSettle();
      expect(
        find.text(l10n.eventPreviewLoudAlarmTitle(100, 'siren')),
        findsOneWidget,
      );
      expect(
        find.text(l10n.eventPreviewLoudAlarmTitle(50, 'siren')),
        findsNothing,
      );

      await _toggleSwitch(tester, l10n.eventDefaultsLoudAlarmGradual);
      expect(find.text(l10n.eventPreviewLoudAlarmRampOn), findsOneWidget);
      expect(find.text(l10n.eventPreviewLoudAlarmRampOff), findsNothing);
    });

    testWidgets('joins both flash fragments; shows no-flash when both off', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpForm(
        tester,
        const LoudAlarmConfig(flashScreen: true),
        onChanged: (_) {},
      );
      expect(
        find.text(
          '${l10n.eventPreviewLoudAlarmFlashScreen} · '
          '${l10n.eventPreviewLoudAlarmFlashLight}',
        ),
        findsOneWidget,
      );

      await _pumpForm(
        tester,
        const LoudAlarmConfig(flashLight: false),
        onChanged: (_) {},
      );
      expect(find.text(l10n.eventPreviewLoudAlarmNoFlash), findsOneWidget);
    });
  });
}

// ─── Interaction helpers for the per-type field tests ───────────────────────

/// Pumps [config] inside [EventSpecificConfig] (Event-Defaults context:
/// no contacts grid) and captures every emitted config via [onChanged].
Future<void> _pumpForm(
  WidgetTester tester,
  StepConfig config, {
  required ValueChanged<StepConfig> onChanged,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        platform: TargetPlatform.android,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF131118)),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: EventSpecificConfig(config: config, onChanged: onChanged),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Opens the enum dropdown currently showing [current] and picks [next].
Future<void> _pickEnum(WidgetTester tester, String current, String next) async {
  final Finder button = find.text(current);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
  await tester.tap(find.text(next).last);
  await tester.pumpAndSettle();
}

/// Taps the [SwitchListTile] labelled [title].
Future<void> _toggleSwitch(WidgetTester tester, String title) async {
  final Finder tile = find.widgetWithText(SwitchListTile, title);
  await tester.ensureVisible(tile);
  await tester.tap(tile);
  await tester.pumpAndSettle();
}

/// Taps the single [IntSpinnerField]'s + button in the current form.
Future<void> _tapSpinnerPlus(WidgetTester tester) async {
  final Finder plus = find.byIcon(Icons.add_circle_outline);
  await tester.ensureVisible(plus);
  await tester.tap(plus);
  await tester.pumpAndSettle();
}

/// Commits [text] into the [TextField] labelled [label].
Future<void> _commitText(WidgetTester tester, String label, String text) async {
  final Finder field = find.widgetWithText(TextField, label);
  await tester.ensureVisible(field);
  await tester.enterText(field, text);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
}

/// Builds a minimal SMS-capable [EmergencyContact] for grid tests.
///
/// Relies on the model's default `channels` ([MessageChannel.sms]).
EmergencyContact _contact(String id, String name, {int sortOrder = 0}) =>
    EmergencyContact(
      id: id,
      name: name,
      phoneNumber: '+1555000$sortOrder',
      sortOrder: sortOrder,
    );

/// Pumps [initial] inside [EventSpecificConfig] with the emitted config fed
/// back into the widget — the same rebuild-on-change loop both production
/// callers implement — so preview cards can be asserted to live-update.
Future<void> _pumpStateful(
  WidgetTester tester,
  StepConfig initial, {
  List<EmergencyContact>? contacts,
  VoidCallback? onManageTemplates,
}) async {
  StepConfig config = initial;
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        platform: TargetPlatform.android,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF131118)),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) =>
              SingleChildScrollView(
                child: EventSpecificConfig(
                  config: config,
                  onChanged: (StepConfig c) => setState(() => config = c),
                  contacts: contacts,
                  onManageTemplates: onManageTemplates,
                ),
              ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Asserts an [InfoIconButton] (found via its tooltip = the field label)
/// exists for every label in [labels].
void _expectInfoButtons(List<String> labels) {
  for (final String label in labels) {
    expect(find.byTooltip(label), findsOneWidget, reason: 'info: $label');
  }
}

/// Taps the info button tooltipped [title], asserts the sheet shows [body],
/// and dismisses it via "Got it".
Future<void> _openInfoSheet(
  WidgetTester tester, {
  required String title,
  required String body,
}) async {
  final l10n = await loadL10n(const Locale('en'));
  final Finder button = find.byTooltip(title);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
  expect(find.text(body), findsOneWidget);
  await tester.tap(find.text(l10n.commonGotIt));
  await tester.pumpAndSettle();
  expect(find.text(body), findsNothing);
}
