/// Unit tests for [stepConfigSummary] (spec 04:1599/1631): the per-type
/// one-line key-config summary shown in a collapsed step tile.
///
/// Truthfulness contract: every value shown must come through the SAME
/// resolution the runtime uses — resolveSmsTargets + channel filter for
/// recipients, the PhoneCallContactStrategy fallback chain for the callee,
/// the gradual-volume double gate for the alarm ramp, and the
/// emergencyNumber-or-app-default precedence for the dialled number.
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/button_type.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/countdown_style.dart';
import 'package:guardianangela/domain/enums/hold_style.dart';
import 'package:guardianangela/domain/enums/loud_alarm_sound.dart';
import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/enums/press_pattern.dart';
import 'package:guardianangela/domain/enums/sms_contact_selection.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/features/modes/widgets/step_helpers.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

ChainStep _step({
  ChainStepType type = ChainStepType.holdButton,
  int waitSeconds = 0,
  int durationSeconds = 10,
  int gracePeriodSeconds = 5,
  int retryCount = 0,
}) => ChainStep(
  id: 's1',
  type: type,
  order: 0,
  waitSeconds: waitSeconds,
  durationSeconds: durationSeconds,
  gracePeriodSeconds: gracePeriodSeconds,
  retryCount: retryCount,
  randomize: false,
);

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

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  /// Calls [stepConfigSummary] with neutral resolution inputs.
  String summary(
    ChainStep step,
    StepConfig config, {
    List<EmergencyContact> contacts = const <EmergencyContact>[],
    bool masterGradualVolume = false,
    String defaultEmergencyNumber = '112',
  }) => stepConfigSummary(
    l10n,
    step: step,
    config: config,
    contacts: contacts,
    masterGradualVolume: masterGradualVolume,
    defaultEmergencyNumber: defaultEmergencyNumber,
  );

  group('holdButton', () {
    test('shows hold style and the step grace period', () {
      check(
        summary(_step(gracePeriodSeconds: 7), const HoldButtonConfig()),
      ).equals(l10n.stepSummaryHoldButton(HoldStyle.largeButton.name, 7));
    });
  });

  group('disguisedReminder', () {
    test('matches the spec 04:1599 example "30 min interval, 3 retries"', () {
      check(
        summary(
          _step(
            type: ChainStepType.disguisedReminder,
            waitSeconds: 1800,
            retryCount: 3,
          ),
          const DisguisedReminderConfig(),
        ),
      ).equals('30 min interval, 3 retries');
    });

    test('a non-whole-minute interval stays in seconds; one retry is '
        'singular', () {
      check(
        summary(
          _step(
            type: ChainStepType.disguisedReminder,
            waitSeconds: 45,
            retryCount: 1,
          ),
          const DisguisedReminderConfig(),
        ),
      ).equals('45s interval, 1 retry');
    });
  });

  group('countdownWarning', () {
    test('shows the step duration and the countdown style', () {
      check(
        summary(
          _step(type: ChainStepType.countdownWarning, durationSeconds: 12),
          const CountdownWarningConfig(style: CountdownStyle.minimal),
        ),
      ).equals(l10n.stepSummaryCountdown(12, CountdownStyle.minimal.name));
    });
  });

  group('fakeCall', () {
    test('matches the spec 04:1631 example "30s ring, 5s grace"', () {
      check(
        summary(
          _step(type: ChainStepType.fakeCall),
          const FakeCallConfig(), // default ring 30
        ),
      ).equals('30s ring, 5s grace');
    });

    test('ring comes from the config, grace from the step', () {
      check(
        summary(
          _step(type: ChainStepType.fakeCall, gracePeriodSeconds: 9),
          const FakeCallConfig(ringDurationSeconds: 45),
        ),
      ).equals(l10n.stepSummaryFakeCall(45, 9));
    });
  });

  group('smsContact', () {
    final List<EmergencyContact> five = <EmergencyContact>[
      _contact('a', 'Alice'),
      _contact('b', 'Bob', sortOrder: 1),
      _contact('c', 'Carol', sortOrder: 2),
      _contact('d', 'Dave', sortOrder: 3),
      _contact('e', 'Eve', sortOrder: 4),
    ];

    test('names all recipients when at most two resolve', () {
      check(
        summary(
          _step(type: ChainStepType.smsContact),
          const SmsContactConfig(),
          contacts: <EmergencyContact>[five[0], five[1]],
        ),
      ).equals(l10n.stepSummarySmsTo('Alice, Bob'));
    });

    test('truncates long lists to "Alice, Bob +3 more"', () {
      check(
        summary(
          _step(type: ChainStepType.smsContact),
          const SmsContactConfig(
            contactSelection: SmsContactSelection.specificIds,
            contactIds: <String>['a', 'b', 'c', 'd', 'e'],
          ),
          contacts: five,
        ),
      ).equals('To: Alice, Bob +3 more');
    });

    test('applies the runtime channel filter — a contact without the '
        'configured channel is never named', () {
      check(
        summary(
          _step(type: ChainStepType.smsContact),
          const SmsContactConfig(channel: MessageChannel.telegram),
          contacts: <EmergencyContact>[
            _contact('a', 'Alice'), // sms only — unreachable on telegram
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
        ),
      ).equals(l10n.stepSummarySmsTo('Bob'));
    });

    test('skips stale ids exactly like the resolver', () {
      check(
        summary(
          _step(type: ChainStepType.smsContact),
          const SmsContactConfig(
            contactSelection: SmsContactSelection.specificIds,
            contactIds: <String>['ghost', 'a'],
          ),
          contacts: <EmergencyContact>[_contact('a', 'Alice')],
        ),
      ).equals(l10n.stepSummarySmsTo('Alice'));
    });

    test('honours the legacy allContacts+ids back-compat as specific ids', () {
      check(
        summary(
          _step(type: ChainStepType.smsContact),
          const SmsContactConfig(contactIds: <String>['b']),
          contacts: five,
        ),
      ).equals(l10n.stepSummarySmsTo('Bob'));
    });

    test('firstContact selection names the lowest sortOrder contact', () {
      check(
        summary(
          _step(type: ChainStepType.smsContact),
          const SmsContactConfig(
            contactSelection: SmsContactSelection.firstContact,
          ),
          contacts: <EmergencyContact>[five[1], five[0]],
        ),
      ).equals(l10n.stepSummarySmsTo('Alice'));
    });

    test('zero resolved recipients surfaces an explicit no-recipients '
        'line', () {
      check(
        summary(
          _step(type: ChainStepType.smsContact),
          const SmsContactConfig(),
        ),
      ).equals(l10n.stepSummarySmsNone);
    });
  });

  group('phoneCallContact', () {
    test('an explicit primary id resolves by id', () {
      check(
        summary(
          _step(type: ChainStepType.phoneCallContact),
          const PhoneCallContactConfig(contactId: 'b'),
          contacts: <EmergencyContact>[
            _contact('a', 'Alice'),
            _contact('b', 'Bob', sortOrder: 1),
          ],
        ),
      ).equals(l10n.stepSummaryPhoneCall('Bob'));
    });

    test('no primary id falls back to the first contact by sortOrder', () {
      check(
        summary(
          _step(type: ChainStepType.phoneCallContact),
          const PhoneCallContactConfig(),
          contacts: <EmergencyContact>[
            _contact('b', 'Bob', sortOrder: 5),
            _contact('a', 'Alice', sortOrder: 1),
          ],
        ),
      ).equals(l10n.stepSummaryPhoneCall('Alice'));
    });

    test('a stale primary id falls through the alternatives in order', () {
      check(
        summary(
          _step(type: ChainStepType.phoneCallContact),
          const PhoneCallContactConfig(
            contactId: 'ghost',
            alternativeContactIds: <String>['also-ghost', 'b'],
          ),
          contacts: <EmergencyContact>[_contact('b', 'Bob', sortOrder: 1)],
        ),
      ).equals(l10n.stepSummaryPhoneCall('Bob'));
    });

    test('nothing resolvable surfaces the no-contact line (the runtime '
        'skips the call)', () {
      check(
        summary(
          _step(type: ChainStepType.phoneCallContact),
          const PhoneCallContactConfig(contactId: 'ghost'),
        ),
      ).equals(l10n.stepSummaryPhoneCallNone);
    });
  });

  group('loudAlarm', () {
    test('shows rounded volume percent and sound choice', () {
      check(
        summary(
          _step(type: ChainStepType.loudAlarm),
          const LoudAlarmConfig(volume: 0.5),
        ),
      ).equals(l10n.stepSummaryLoudAlarm(50, LoudAlarmSound.siren.name));
    });

    test('step ramp flag alone shows NO ramp — the runtime only ramps '
        'when the app-wide master is also on', () {
      check(
        summary(
          _step(type: ChainStepType.loudAlarm),
          const LoudAlarmConfig(gradualVolume: true),
        ),
      ).equals(l10n.stepSummaryLoudAlarm(100, LoudAlarmSound.siren.name));
    });

    test('ramp wording appears only when both gates are on', () {
      check(
        summary(
          _step(type: ChainStepType.loudAlarm),
          const LoudAlarmConfig(gradualVolume: true),
          masterGradualVolume: true,
        ),
      ).equals(l10n.stepSummaryLoudAlarmRamp(100, LoudAlarmSound.siren.name));
    });
  });

  group('callEmergency', () {
    test('no per-step number resolves to the app-wide default, with the '
        'pre-SMS wording (default on)', () {
      check(
        summary(
          _step(type: ChainStepType.callEmergency),
          const CallEmergencyConfig(),
          defaultEmergencyNumber: '999',
        ),
      ).equals(l10n.stepSummaryCallEmergencySmsFirst('999'));
    });

    test('a per-step number overrides; pre-SMS off drops the wording', () {
      check(
        summary(
          _step(type: ChainStepType.callEmergency),
          const CallEmergencyConfig(
            emergencyNumber: '911',
            sendLocationSmsFirst: false,
          ),
          defaultEmergencyNumber: '999',
        ),
      ).equals(l10n.stepSummaryCallEmergency('911'));
    });
  });

  group('hardwareButton', () {
    test('repeat pattern shows button × count', () {
      check(
        summary(
          _step(type: ChainStepType.hardwareButton),
          const HardwareButtonConfig(), // volumeUp ×5
        ),
      ).equals(l10n.stepSummaryHardwareRepeat(ButtonType.volumeUp.name, 5));
    });

    test('long-press pattern trims a whole-second duration ("2", not '
        '"2.0")', () {
      check(
        summary(
          _step(type: ChainStepType.hardwareButton),
          const HardwareButtonConfig(pressPattern: PressPattern.longPress),
        ),
      ).equals(l10n.stepSummaryHardwareLong(ButtonType.volumeUp.name, '2'));
    });

    test('long-press pattern keeps a fractional duration', () {
      check(
        summary(
          _step(type: ChainStepType.hardwareButton),
          const HardwareButtonConfig(
            pressPattern: PressPattern.longPress,
            longPressDurationSeconds: 1.5,
            buttonType: ButtonType.volumeDown,
          ),
        ),
      ).equals(l10n.stepSummaryHardwareLong(ButtonType.volumeDown.name, '1.5'));
    });
  });
}
