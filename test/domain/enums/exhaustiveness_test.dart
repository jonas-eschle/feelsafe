/// Exhaustiveness tests for every enum in `lib/domain/enums/`.
///
/// Each test asserts the enum's `values` list is EXACTLY the spec-defined
/// set, in spec order, with no extras. Order matters for at least
/// [ChainStepType] (spec 03:284 — earlier = less severe) and for
/// [CallStyle] (spec 03:344 — `platformNative` first as the default).
/// Other enums also assert order to lock the persistence-friendly
/// `enum.byName` round-trip against future accidental reorderings.
///
/// Negative assertions guard against historical resurrections:
///   * [EndReason] must NOT contain `appTermination` (lessons §5.2).
///   * [PauseReason] must NOT contain `bootRestart` or `fakeCallAnswered`
///     (lessons §5.2 / §5.3 / Pivot 2).
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/enums/app_theme_mode.dart';
import 'package:guardianangela/domain/enums/button_type.dart';
import 'package:guardianangela/domain/enums/call_style.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/enums/countdown_style.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/enums/gps_accuracy.dart';
import 'package:guardianangela/domain/enums/gps_destination_source.dart';
import 'package:guardianangela/domain/enums/gps_format.dart';
import 'package:guardianangela/domain/enums/hold_style.dart';
import 'package:guardianangela/domain/enums/log_gps_override.dart';
import 'package:guardianangela/domain/enums/loud_alarm_sound.dart';
import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/enums/pause_reason.dart';
import 'package:guardianangela/domain/enums/press_pattern.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/enums/sms_contact_selection.dart';
import 'package:guardianangela/domain/enums/stealth_icon_preset.dart';
import 'package:guardianangela/domain/enums/stealth_timer_display.dart';
import 'package:guardianangela/domain/enums/voice_output_mode.dart';

void main() {
  group('ChainStepType (spec 03:268-284, order matters)', () {
    test('has exactly the spec-ordered 9 values', () {
      check(ChainStepType.values).deepEquals([
        ChainStepType.holdButton,
        ChainStepType.disguisedReminder,
        ChainStepType.countdownWarning,
        ChainStepType.fakeCall,
        ChainStepType.smsContact,
        ChainStepType.phoneCallContact,
        ChainStepType.loudAlarm,
        ChainStepType.callEmergency,
        ChainStepType.hardwareButton,
      ]);
    });

    test('value names match the spec literal names (no aliases)', () {
      check(ChainStepType.values.map((e) => e.name).toList()).deepEquals([
        'holdButton',
        'disguisedReminder',
        'countdownWarning',
        'fakeCall',
        'smsContact',
        'phoneCallContact',
        'loudAlarm',
        'callEmergency',
        'hardwareButton',
      ]);
    });

    test('contains exactly 9 values — no historical extras', () {
      check(ChainStepType.values.length).equals(9);
    });
  });

  group('EndReason (spec 03:518-525, lessons §5.2)', () {
    test('has exactly the spec-ordered 6 values', () {
      check(EndReason.values).deepEquals([
        EndReason.disarm,
        EndReason.chainExhausted,
        EndReason.hardwarePanic,
        EndReason.duressPin,
        EndReason.wrongPinExhausted,
        EndReason.userQuit,
      ]);
    });

    test('does NOT include appTermination (lessons §5.2)', () {
      check(
        EndReason.values.map((e) => e.name),
      ).not((it) => it.contains('appTermination'));
    });

    test('contains exactly 6 values — no historical extras', () {
      check(EndReason.values.length).equals(6);
    });
  });

  group('PauseReason (spec 03:541, lessons §5.2 + §5.3 + Pivot 2)', () {
    test('has exactly the spec-ordered 2 values', () {
      check(
        PauseReason.values,
      ).deepEquals([PauseReason.userRequested, PauseReason.incomingCall]);
    });

    test(
      'does NOT include bootRestart (lessons §5.2 — no resume-from-disk)',
      () {
        check(
          PauseReason.values.map((e) => e.name),
        ).not((it) => it.contains('bootRestart'));
      },
    );

    test(
      'does NOT include fakeCallAnswered (Pivot 2 — fake call is event)',
      () {
        check(
          PauseReason.values.map((e) => e.name),
        ).not((it) => it.contains('fakeCallAnswered'));
      },
    );

    test('contains exactly 2 values — no historical extras', () {
      check(PauseReason.values.length).equals(2);
    });
  });

  group('LoudAlarmSound (G-006 / spec 03:460)', () {
    test('has exactly {siren, custom} in spec order', () {
      check(
        LoudAlarmSound.values,
      ).deepEquals([LoudAlarmSound.siren, LoudAlarmSound.custom]);
    });

    test('contains exactly 2 values — legacy values nuked-and-reseeded', () {
      check(LoudAlarmSound.values.length).equals(2);
    });
  });

  group('MessageChannel (spec 03 §MessageChannel)', () {
    test('has exactly the 4 channels in spec order', () {
      check(MessageChannel.values).deepEquals([
        MessageChannel.sms,
        MessageChannel.whatsapp,
        MessageChannel.telegram,
        MessageChannel.phoneCall,
      ]);
    });
  });

  group('ConfirmationType (spec 03 §ConfirmationType)', () {
    test('has exactly the 4 confirmation interactions in spec order', () {
      check(ConfirmationType.values).deepEquals([
        ConfirmationType.tapButton,
        ConfirmationType.tapWord,
        ConfirmationType.swipe,
        ConfirmationType.dismiss,
      ]);
    });
  });

  group('HoldStyle (spec 03 §HoldStyle, line 492)', () {
    test(
      'has exactly {largeButton, fullScreen, fakeLockScreen} in spec order',
      () {
        check(HoldStyle.values).deepEquals([
          HoldStyle.largeButton,
          HoldStyle.fullScreen,
          HoldStyle.fakeLockScreen,
        ]);
      },
    );
  });

  group('CountdownStyle (spec 03 §CountdownStyle, line 472)', () {
    test('has exactly {fullScreen, notification, minimal} in spec order', () {
      check(CountdownStyle.values).deepEquals([
        CountdownStyle.fullScreen,
        CountdownStyle.notification,
        CountdownStyle.minimal,
      ]);
    });
  });

  group('CallStyle (spec 03:344, platformNative is default → first)', () {
    test('platformNative is the first value (spec-default)', () {
      check(CallStyle.values.first).equals(CallStyle.platformNative);
    });

    test('has exactly the 7 styles in spec order', () {
      check(CallStyle.values).deepEquals([
        CallStyle.platformNative,
        CallStyle.androidNative,
        CallStyle.iosNative,
        CallStyle.minimal,
        CallStyle.whatsapp,
        CallStyle.telegram,
        CallStyle.signal,
      ]);
    });
  });

  group('VoiceOutputMode (spec 03 §VoiceOutputMode, line 499)', () {
    test('has exactly {earpiece, speaker} in spec order', () {
      check(
        VoiceOutputMode.values,
      ).deepEquals([VoiceOutputMode.earpiece, VoiceOutputMode.speaker]);
    });
  });

  group('SmsContactSelection (spec 03 §SmsContactSelection)', () {
    test(
      'has exactly {allContacts, firstContact, specificIds} in spec order',
      () {
        check(SmsContactSelection.values).deepEquals([
          SmsContactSelection.allContacts,
          SmsContactSelection.firstContact,
          SmsContactSelection.specificIds,
        ]);
      },
    );
  });

  group('LogGpsOverride (spec 03 §LogGpsOverride, line 469)', () {
    test('has exactly {useDefault, forceOn, forceOff} in spec order', () {
      check(LogGpsOverride.values).deepEquals([
        LogGpsOverride.useDefault,
        LogGpsOverride.forceOn,
        LogGpsOverride.forceOff,
      ]);
    });
  });

  group('StealthIconPreset (spec 03 §StealthConfig)', () {
    test('has exactly the 10 icon presets in spec order', () {
      check(StealthIconPreset.values).deepEquals([
        StealthIconPreset.music,
        StealthIconPreset.calendar,
        StealthIconPreset.fitness,
        StealthIconPreset.weather,
        StealthIconPreset.news,
        StealthIconPreset.photos,
        StealthIconPreset.notes,
        StealthIconPreset.clock,
        StealthIconPreset.podcast,
        StealthIconPreset.none,
      ]);
    });

    test('none is the last value (fallback to standard app icon)', () {
      check(StealthIconPreset.values.last).equals(StealthIconPreset.none);
    });
  });

  group('GpsDestinationSource (spec 03:482)', () {
    test('has exactly {promptAtStart, fixed} in spec order', () {
      check(GpsDestinationSource.values).deepEquals([
        GpsDestinationSource.promptAtStart,
        GpsDestinationSource.fixed,
      ]);
    });
  });

  group('ReminderDisplayStyle (spec 03 §ReminderDisplayStyle)', () {
    test('has exactly {fullScreen, subtle} in spec order', () {
      check(ReminderDisplayStyle.values).deepEquals([
        ReminderDisplayStyle.fullScreen,
        ReminderDisplayStyle.subtle,
      ]);
    });
  });

  group('AppThemeMode (spec 03 §AppSettings)', () {
    test('has exactly {light, dark, system} in spec order', () {
      check(AppThemeMode.values).deepEquals([
        AppThemeMode.light,
        AppThemeMode.dark,
        AppThemeMode.system,
      ]);
    });
  });

  group('ButtonType (spec 03 §HardwareButtonDistressTrigger)', () {
    test('has exactly {volumeUp, volumeDown} in spec order', () {
      check(
        ButtonType.values,
      ).deepEquals([ButtonType.volumeUp, ButtonType.volumeDown]);
    });
  });

  group('PressPattern (G-005 / spec 03 §DistressTrigger)', () {
    test('has exactly {repeatPress, longPress} in spec order', () {
      check(
        PressPattern.values,
      ).deepEquals([PressPattern.repeatPress, PressPattern.longPress]);
    });

    test('both ship at v3 GA (no values were cut)', () {
      check(PressPattern.values.length).equals(2);
    });
  });

  group('StealthTimerDisplay (spec 03 §StealthConfig)', () {
    test('has exactly {normal, small, none} in spec order', () {
      check(StealthTimerDisplay.values).deepEquals([
        StealthTimerDisplay.normal,
        StealthTimerDisplay.small,
        StealthTimerDisplay.none,
      ]);
    });
  });

  group('GpsAccuracy (spec 03 §GpsLoggingConfig / Q21)', () {
    test('has exactly {low, medium, high} in spec order', () {
      check(
        GpsAccuracy.values,
      ).deepEquals([GpsAccuracy.low, GpsAccuracy.medium, GpsAccuracy.high]);
    });
  });

  group('GpsFormat (spec 03 §GpsLoggingConfig / Q21)', () {
    test('has exactly {dms, decimal, openLocationCode} in spec order', () {
      check(GpsFormat.values).deepEquals([
        GpsFormat.dms,
        GpsFormat.decimal,
        GpsFormat.openLocationCode,
      ]);
    });
  });
}
