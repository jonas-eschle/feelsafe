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

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/utils/ringtone_picker.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/button_type.dart';
import 'package:guardianangela/domain/enums/call_style.dart';
import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/enums/countdown_style.dart';
import 'package:guardianangela/domain/enums/hold_style.dart';
import 'package:guardianangela/domain/enums/loud_alarm_sound.dart';
import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/enums/press_pattern.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/enums/sms_contact_selection.dart';
import 'package:guardianangela/domain/enums/voice_output_mode.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/domain/orchestration/strategies/sms_contact_strategy.dart';
import 'package:guardianangela/features/modes/widgets/event_specific_config.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/app_state_providers.dart';
import 'package:guardianangela/services/service_providers.dart';
import '../../../helpers/widget_test_helpers.dart';

/// Fake [AppSettingsRepository] serving an in-memory [AppSettings].
///
/// [settings] is mutable so a test can flip the app-wide gradual-volume
/// master and re-trigger `appSettingsLiveProvider` — mirroring the runtime
/// writer contract (save, then `ref.invalidate(appSettingsLiveProvider)`).
/// The store callbacks are never invoked because [load] is overridden.
class _FakeSettingsRepo extends AppSettingsRepository {
  _FakeSettingsRepo(this.settings)
    : super(
        keyProvider: () async =>
            '0102030405060708090a0b0c0d0e0f'
            '101112131415161718191a1b1c1d1e1f20',
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('esc_test_'),
      );

  AppSettings settings;

  @override
  Future<AppSettings> load() async => settings;
}

/// Settings repo whose [load] never completes — pins the loading-state
/// conservatism of the loudAlarm preview (an unconfirmed master is treated
/// as off; the card must not promise a ramp it cannot confirm).
class _NeverLoadingSettingsRepo extends _FakeSettingsRepo {
  _NeverLoadingSettingsRepo() : super(const AppSettings());

  @override
  Future<AppSettings> load() => Completer<AppSettings>().future;
}

/// Riverpod overrides for the canonical test settings repo.
///
/// `_LoudAlarmPreviewCard` watches `appSettingsLiveProvider` (the same live
/// source every settings writer invalidates), which loads from
/// `appSettingsRepositoryProvider` — overriding the repo keeps the live
/// provider's real body in the loop. Defaults to out-of-box [AppSettings]
/// (gradual-volume master OFF, as in production).
List<Override> _settingsOverrides(AppSettingsRepository? settingsRepo) =>
    <Override>[
      appSettingsRepositoryProvider.overrideWithValue(
        settingsRepo ?? _FakeSettingsRepo(const AppSettings()),
      ),
    ];

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

  // ── templateIds picker (spec 04:1635) ─────────────────────────────────────
  //
  // "disguisedReminder: … template choice (Calendar/Duolingo/etc.) … Below
  // the templateIds field the form renders a 'Manage reminder templates'
  // ListTile". The picker offers the SAME pool the runtime selector filters
  // (global + mode-local, threaded from the mode editor) and mirrors
  // selectReminderTemplate's semantics: an empty selection — and equally a
  // selection whose ids all match nothing (selector step 2 falls back to the
  // full pool) — leaves EVERY template eligible.

  group('EventSpecificConfig — templateIds picker (spec 04:1635)', () {
    final List<ReminderTemplate> pool = <ReminderTemplate>[
      _template('tpl_cal', 'Calendar'),
      _template('tpl_duo', 'Duolingo'),
      _template('tpl_fit', 'Fitness'),
    ];

    testWidgets('renders a chip per pool template; selecting one writes '
        'templateIds through onChanged', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      StepConfig? emitted;
      await _pumpForm(
        tester,
        const DisguisedReminderConfig(),
        onChanged: (StepConfig c) => emitted = c,
        templates: pool,
      );
      expect(find.text(l10n.eventDefaultsReminderTemplateIds), findsOneWidget);
      expect(
        find.text(l10n.eventDefaultsReminderTemplateIdsAll),
        findsOneWidget,
      );
      for (final String name in <String>['Calendar', 'Duolingo', 'Fitness']) {
        expect(find.widgetWithText(FilterChip, name), findsOneWidget);
      }
      final Finder chip = find.widgetWithText(FilterChip, 'Duolingo');
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await tester.pumpAndSettle();
      check(emitted).isA<DisguisedReminderConfig>();
      check(
        (emitted! as DisguisedReminderConfig).templateIds,
      ).deepEquals(<String>['tpl_duo']);
    });

    testWidgets('empty → selected → empty round-trip restores the '
        'all-eligible state', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpStateful(
        tester,
        const DisguisedReminderConfig(),
        templates: pool,
      );
      expect(
        find.text(l10n.eventDefaultsReminderTemplateIdsAll),
        findsOneWidget,
      );

      // Select in reverse pool order — the summary must list names in POOL
      // order (the order the runtime's first-eligible pick walks), not in
      // selection order.
      await tester.tap(find.widgetWithText(FilterChip, 'Duolingo'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'Calendar'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          l10n.eventDefaultsReminderTemplateIdsSelected('Calendar, Duolingo'),
        ),
        findsOneWidget,
      );
      expect(find.text(l10n.eventDefaultsReminderTemplateIdsAll), findsNothing);

      // Deselect both → first-class empty state again.
      await tester.tap(find.widgetWithText(FilterChip, 'Calendar'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'Duolingo'));
      await tester.pumpAndSettle();
      expect(
        find.text(l10n.eventDefaultsReminderTemplateIdsAll),
        findsOneWidget,
      );
      expect(
        find.text(
          l10n.eventDefaultsReminderTemplateIdsSelected('Calendar, Duolingo'),
        ),
        findsNothing,
      );
      final FilterChip calChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Calendar'),
      );
      check(calChip.selected).isFalse();
    });

    testWidgets('a selection of only stale ids renders as all-eligible '
        '(selector fallback) and the next toggle drops the ghosts', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      StepConfig? emitted;
      await _pumpForm(
        tester,
        const DisguisedReminderConfig(templateIds: <String>['ghost']),
        onChanged: (StepConfig c) => emitted = c,
        templates: pool,
      );
      // selectReminderTemplate step 2: a filter matching nothing falls back
      // to the FULL pool — the display must say so, not crash.
      expect(
        find.text(l10n.eventDefaultsReminderTemplateIdsAll),
        findsOneWidget,
      );
      for (final String name in <String>['Calendar', 'Duolingo', 'Fitness']) {
        final FilterChip chip = tester.widget<FilterChip>(
          find.widgetWithText(FilterChip, name),
        );
        check(chip.selected).isFalse();
      }
      // Toggling writes only resolvable ids — the ghost is dropped, exactly
      // like the SMS grid drops ids with no matching contact.
      await tester.tap(find.widgetWithText(FilterChip, 'Calendar'));
      await tester.pumpAndSettle();
      check(
        (emitted! as DisguisedReminderConfig).templateIds,
      ).deepEquals(<String>['tpl_cal']);
    });

    testWidgets('a partially stale selection shows only the resolved name', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpForm(
        tester,
        const DisguisedReminderConfig(
          templateIds: <String>['ghost', 'tpl_duo'],
        ),
        onChanged: (_) {},
        templates: pool,
      );
      // The runtime filter matches only Duolingo; the ghost contributes
      // nothing and must not invent an "All eligible" claim either.
      expect(
        find.text(l10n.eventDefaultsReminderTemplateIdsSelected('Duolingo')),
        findsOneWidget,
      );
      expect(find.text(l10n.eventDefaultsReminderTemplateIdsAll), findsNothing);
      check(
        tester
            .widget<FilterChip>(find.widgetWithText(FilterChip, 'Duolingo'))
            .selected,
      ).isTrue();
      check(
        tester
            .widget<FilterChip>(find.widgetWithText(FilterChip, 'Calendar'))
            .selected,
      ).isFalse();
    });

    testWidgets('hidden in the Event Defaults context (no pool threaded)', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpForm(
        tester,
        const DisguisedReminderConfig(),
        onChanged: (_) {},
      );
      expect(find.text(l10n.eventDefaultsReminderTemplateIds), findsNothing);
      expect(find.text(l10n.eventDefaultsReminderTemplateIdsAll), findsNothing);
      expect(find.byType(FilterChip), findsNothing);
    });

    testWidgets('the field has an info icon whose sheet explains the '
        'eligibility semantics', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpStateful(
        tester,
        const DisguisedReminderConfig(),
        templates: pool,
      );
      await _openInfoSheet(
        tester,
        title: l10n.eventDefaultsReminderTemplateIds,
        body: l10n.eventDefaultsReminderTemplateIdsInfo,
      );
    });

    testWidgets('sits above the manage-templates link (spec 04:1635: the '
        'link is below the templateIds field)', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpStateful(
        tester,
        const DisguisedReminderConfig(),
        templates: pool,
        onManageTemplates: () {},
      );
      final double pickerY = tester
          .getTopLeft(find.text(l10n.eventDefaultsReminderTemplateIds))
          .dy;
      final double linkY = tester
          .getTopLeft(
            find.widgetWithText(ListTile, l10n.safetyOptionsManageTemplates),
          )
          .dy;
      check(pickerY).isLessThan(linkY);
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
      // Master ON so the step toggle alone controls the ramp line here;
      // the full master × step effective-state matrix is pinned in its
      // own group below.
      await _pumpStateful(
        tester,
        const LoudAlarmConfig(volume: 0.5),
        settingsRepo: _FakeSettingsRepo(
          const AppSettings(alarmGradualVolume: true),
        ),
      );
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

  // ── loudAlarm preview: gradual-volume master × step matrix ────────────────
  //
  // The runtime ramps only when BOTH the app-wide master
  // (AppSettings.alarmGradualVolume, default OFF) and the per-step
  // gradualVolume flag are on (LoudAlarmStrategy:
  // `services.alarmGradualVolume && config.gradualVolume`). The preview must
  // mirror that EFFECTIVE state — a safety-app preview promising a gradual
  // ramp the alarm will not perform is a truthfulness defect.

  group('EventSpecificConfig — loudAlarm preview honors the gradual-volume '
      'master (effective state)', () {
    testWidgets('out-of-box: master OFF (default) + step ON shows the '
        'full-volume hint, never the ramp promise', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      // No settingsRepo → out-of-box AppSettings (master OFF), the exact
      // default-config state the cohort flagged.
      await _pumpForm(
        tester,
        const LoudAlarmConfig(gradualVolume: true),
        onChanged: (_) {},
      );
      expect(
        find.text(l10n.eventPreviewLoudAlarmRampMasterOff),
        findsOneWidget,
      );
      expect(find.text(l10n.eventPreviewLoudAlarmRampOn), findsNothing);
      expect(find.text(l10n.eventPreviewLoudAlarmRampOff), findsNothing);
    });

    testWidgets('master ON + step ON shows the gradual-ramp line', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpForm(
        tester,
        const LoudAlarmConfig(gradualVolume: true),
        onChanged: (_) {},
        settingsRepo: _FakeSettingsRepo(
          const AppSettings(alarmGradualVolume: true),
        ),
      );
      expect(find.text(l10n.eventPreviewLoudAlarmRampOn), findsOneWidget);
      expect(find.text(l10n.eventPreviewLoudAlarmRampMasterOff), findsNothing);
    });

    testWidgets('step OFF shows the plain full-volume line even with the '
        'master ON', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpForm(
        tester,
        const LoudAlarmConfig(),
        onChanged: (_) {},
        settingsRepo: _FakeSettingsRepo(
          const AppSettings(alarmGradualVolume: true),
        ),
      );
      expect(find.text(l10n.eventPreviewLoudAlarmRampOff), findsOneWidget);
      expect(find.text(l10n.eventPreviewLoudAlarmRampOn), findsNothing);
      expect(find.text(l10n.eventPreviewLoudAlarmRampMasterOff), findsNothing);
    });

    testWidgets('flipping the master flips the card text (live settings '
        'read)', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      final repo = _FakeSettingsRepo(const AppSettings()); // master OFF
      await _pumpForm(
        tester,
        const LoudAlarmConfig(gradualVolume: true),
        onChanged: (_) {},
        settingsRepo: repo,
      );
      expect(
        find.text(l10n.eventPreviewLoudAlarmRampMasterOff),
        findsOneWidget,
      );

      // Flip the master ON the way every runtime writer does: persist,
      // then invalidate appSettingsLiveProvider so watchers re-read.
      repo.settings = const AppSettings(alarmGradualVolume: true);
      ProviderScope.containerOf(
        tester.element(find.byType(EventSpecificConfig)),
        listen: false,
      ).invalidate(appSettingsLiveProvider);
      await tester.pumpAndSettle();

      expect(find.text(l10n.eventPreviewLoudAlarmRampOn), findsOneWidget);
      expect(find.text(l10n.eventPreviewLoudAlarmRampMasterOff), findsNothing);
    });

    testWidgets('while settings are still loading the master is treated '
        'as OFF (conservative)', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpForm(
        tester,
        const LoudAlarmConfig(gradualVolume: true),
        onChanged: (_) {},
        settingsRepo: _NeverLoadingSettingsRepo(),
      );
      // Never promise a ramp that cannot be confirmed.
      expect(
        find.text(l10n.eventPreviewLoudAlarmRampMasterOff),
        findsOneWidget,
      );
      expect(find.text(l10n.eventPreviewLoudAlarmRampOn), findsNothing);
    });
  });

  // ── smsContact preview: count honors the runtime channel filter ──────────
  //
  // The runtime sends only to resolved contacts whose channels include the
  // configured channel (SmsContactStrategy:
  // `targets.where((c) => c.channels.contains(config.channel))`). The
  // preview's "To N contacts" must apply the same filter — a selected
  // contact lacking the channel is never messaged and must not be counted.

  group('EventSpecificConfig — smsContact preview count honors the channel '
      'filter', () {
    testWidgets('a selected contact lacking the configured channel is '
        'not counted', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      // Alice: SMS only. Bob: SMS + Telegram. Both selected, channel
      // Telegram → runtime messages Bob only.
      await _pumpStateful(
        tester,
        const SmsContactConfig(
          channel: MessageChannel.telegram,
          contactSelection: SmsContactSelection.specificIds,
          contactIds: <String>['a', 'b'],
        ),
        contacts: <EmergencyContact>[
          _contact('a', 'Alice'),
          _contact(
            'b',
            'Bob',
            sortOrder: 1,
            channels: const <MessageChannel>[
              MessageChannel.sms,
              MessageChannel.telegram,
            ],
          ),
        ],
      );
      expect(
        find.text(l10n.eventPreviewSmsToCount(1, 'telegram')),
        findsOneWidget,
      );
      expect(
        find.text(l10n.eventPreviewSmsToCount(2, 'telegram')),
        findsNothing,
      );
    });

    testWidgets('the legacy allContacts+ids count is channel-filtered '
        'too', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      // Legacy shape: allContacts + explicit ids = specific IDs.
      await _pumpStateful(
        tester,
        const SmsContactConfig(
          channel: MessageChannel.telegram,
          contactIds: <String>['a', 'b'],
        ),
        contacts: <EmergencyContact>[
          _contact('a', 'Alice'),
          _contact(
            'b',
            'Bob',
            sortOrder: 1,
            channels: const <MessageChannel>[
              MessageChannel.sms,
              MessageChannel.telegram,
            ],
          ),
        ],
      );
      expect(
        find.text(l10n.eventPreviewSmsToCount(1, 'telegram')),
        findsOneWidget,
      );
    });

    testWidgets('switching the channel re-filters the count live', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      // Both contacts support SMS; only Bob supports Telegram.
      await _pumpStateful(
        tester,
        const SmsContactConfig(
          contactSelection: SmsContactSelection.specificIds,
          contactIds: <String>['a', 'b'],
        ),
        contacts: <EmergencyContact>[
          _contact('a', 'Alice'),
          _contact(
            'b',
            'Bob',
            sortOrder: 1,
            channels: const <MessageChannel>[
              MessageChannel.sms,
              MessageChannel.telegram,
            ],
          ),
        ],
      );
      expect(find.text(l10n.eventPreviewSmsToCount(2, 'sms')), findsOneWidget);

      await _pickEnum(
        tester,
        MessageChannel.sms.name,
        MessageChannel.telegram.name,
      );
      expect(
        find.text(l10n.eventPreviewSmsToCount(1, 'telegram')),
        findsOneWidget,
      );
      expect(
        find.text(l10n.eventPreviewSmsToCount(2, 'telegram')),
        findsNothing,
      );
    });

    testWidgets('a stale id with no matching contact is not counted '
        '(mirrors the resolver)', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpStateful(
        tester,
        const SmsContactConfig(
          contactSelection: SmsContactSelection.specificIds,
          contactIds: <String>['a', 'ghost'],
        ),
        contacts: <EmergencyContact>[_contact('a', 'Alice')],
      );
      // resolveSmsTargets skips ids with no matching contact; the
      // runtime never messages "ghost", so the preview must not count it.
      expect(find.text(l10n.eventPreviewSmsToCount(1, 'sms')), findsOneWidget);
    });
  });
}

// ─── Interaction helpers for the per-type field tests ───────────────────────

/// Pumps [config] inside [EventSpecificConfig] (Event-Defaults context:
/// no contacts grid) and captures every emitted config via [onChanged].
///
/// [settingsRepo] backs `appSettingsLiveProvider` for the loudAlarm
/// preview's master-flag read; null = out-of-box defaults (master OFF).
Future<void> _pumpForm(
  WidgetTester tester,
  StepConfig config, {
  required ValueChanged<StepConfig> onChanged,
  List<ReminderTemplate>? templates,
  AppSettingsRepository? settingsRepo,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: _settingsOverrides(settingsRepo),
      child: MaterialApp(
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
              onChanged: onChanged,
              templates: templates,
            ),
          ),
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

/// Builds a minimal [EmergencyContact] for grid/preview tests.
///
/// [channels] defaults (via the model) to `[MessageChannel.sms]`; pass an
/// explicit list to build contacts that do or do not support a step's
/// configured channel.
EmergencyContact _contact(
  String id,
  String name, {
  int sortOrder = 0,
  List<MessageChannel>? channels,
}) => EmergencyContact(
  id: id,
  name: name,
  phoneNumber: '+1555000$sortOrder',
  sortOrder: sortOrder,
  channels: channels ?? const <MessageChannel>[MessageChannel.sms],
);

/// Builds a minimal [ReminderTemplate] for the templateIds picker tests.
ReminderTemplate _template(String id, String name) => ReminderTemplate(
  id: id,
  name: name,
  title: 'Title $name',
  body: 'Body $name',
  confirmationType: ConfirmationType.dismiss,
  isCustom: false,
  displayStyle: ReminderDisplayStyle.subtle,
  isGlobal: true,
);

/// Pumps [initial] inside [EventSpecificConfig] with the emitted config fed
/// back into the widget — the same rebuild-on-change loop both production
/// callers implement — so preview cards can be asserted to live-update.
///
/// [settingsRepo] backs `appSettingsLiveProvider` for the loudAlarm
/// preview's master-flag read; null = out-of-box defaults (master OFF).
Future<void> _pumpStateful(
  WidgetTester tester,
  StepConfig initial, {
  List<EmergencyContact>? contacts,
  List<ReminderTemplate>? templates,
  VoidCallback? onManageTemplates,
  AppSettingsRepository? settingsRepo,
}) async {
  StepConfig config = initial;
  await tester.pumpWidget(
    ProviderScope(
      overrides: _settingsOverrides(settingsRepo),
      child: MaterialApp(
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
                    templates: templates,
                    onManageTemplates: onManageTemplates,
                  ),
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
