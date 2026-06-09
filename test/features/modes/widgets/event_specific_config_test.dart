/// Widget tests for [EventSpecificConfig]'s #20 additions: the iOS
/// platform-limitation warnings (spec 02:325, 02:479) and the SMS
/// message-template editor (spec 02:287-304).
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
import 'package:guardianangela/domain/enums/voice_output_mode.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
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
