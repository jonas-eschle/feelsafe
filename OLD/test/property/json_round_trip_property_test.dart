/// Property-based tests for JSON round-trip on every
/// [StepConfig] subtype and other serializable models.
///
/// Uses deterministic random inputs (via [FixedRandom]) rather than
/// full QuickCheck-style generators — enough variance to catch
/// field-coverage gaps without test flakiness.
library;

import 'dart:math';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/chain_event.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/event_defaults.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/models/trigger.dart';
import '../helpers/test_helpers.dart';

/// Utility: round-trip any [StepConfig] through JSON.
StepConfig _roundTrip(StepConfig c) => StepConfig.fromJson(c.toJson());

void main() {
  group('StepConfig: property — JSON round-trip is lossless', () {
    test('HoldButtonConfig round-trips', () {
      final rand = FixedRandom(0.5);
      for (var i = 0; i < 5; i++) {
        final cfg = HoldButtonConfig(
          releaseSensitivity: 0.1 + rand.nextDouble() * 2.0,
        );
        check(_roundTrip(cfg)).equals(cfg);
      }
    });

    test('DisguisedReminderConfig round-trips', () {
      final cases = [
        const DisguisedReminderConfig(),
        const DisguisedReminderConfig(templateId: 'foo', intervalSeconds: 30),
        const DisguisedReminderConfig(intervalSeconds: 600),
      ];
      for (final cfg in cases) {
        check(_roundTrip(cfg)).equals(cfg);
      }
    });

    test('HardwareButtonConfig round-trips', () {
      for (final bt in ButtonType.values) {
        for (final p in HardwarePattern.values) {
          final cfg = HardwareButtonConfig(
            buttonType: bt,
            pattern: p,
            pressCount: 3,
            pressWindowMs: 300,
            longPressDurationSeconds: 1.5,
          );
          check(_roundTrip(cfg)).equals(cfg);
        }
      }
    });

    test('CountdownWarningConfig round-trips', () {
      const cases = [
        CountdownWarningConfig(),
        CountdownWarningConfig(vibrate: false, playTone: true),
        CountdownWarningConfig(vibrate: true, playTone: true),
      ];
      for (final cfg in cases) {
        check(_roundTrip(cfg)).equals(cfg);
      }
    });

    test('FakeCallConfig round-trips non-null cases', () {
      // Fix for bugs.json Bug #4: null callerName now round-trips as
      // null (lossless). The constructor default is applied only when
      // the key is missing from the JSON map. Default changed to
      // "Angela" (fixer brief item #4).
      const cases = [
        FakeCallConfig(),
        FakeCallConfig(
          callerName: 'Bob',
          ringtoneAsset: 'r.mp3',
          voiceRecordingAsset: 'v.mp3',
          declineIsSafe: false,
          callStyle: CallStyle.telegram,
          voiceSource: VoiceSource.recording,
          voiceRoute: VoiceRoute.speaker,
          ringDurationSeconds: 20,
          declineWithDistressHoldSeconds: 3.0,
          blackScreenMode: true,
        ),
      ];
      for (final cfg in cases) {
        check(_roundTrip(cfg)).equals(cfg);
      }
    });

    test(
      'FakeCallConfig with explicit null callerName round-trips as null',
      () {
        // Fix for bugs.json Bug #4: the previous coercion-to-"Mom" is
        // removed. Explicit null survives the round-trip.
        const cfg = FakeCallConfig(callerName: null);
        final restored = _roundTrip(cfg) as FakeCallConfig;
        check(restored.callerName).isNull();
      },
    );

    test('SmsContactConfig round-trips with specific ids', () {
      const cfg = SmsContactConfig(
        contactIds: ['a', 'b', 'c'],
        contactSelection: SmsContactSelection.specificIds,
        channel: MessageChannel.whatsapp,
        includeLocation: false,
        includeMedicalInfo: true,
        autoRecordAudio: true,
        autoRecordVideo: false,
        recordDurationSeconds: 30,
        messageTemplate: 'help {name}',
        blackScreenMode: true,
      );
      check(_roundTrip(cfg)).equals(cfg);
    });

    test('SmsContactConfig round-trips default', () {
      const cfg = SmsContactConfig();
      check(_roundTrip(cfg)).equals(cfg);
    });

    test('PhoneCallContactConfig round-trips', () {
      // Q12: preSendSms / preSmsIncludeLocation / preSmsMessage removed.
      const cases = [
        PhoneCallContactConfig(),
        PhoneCallContactConfig(
          contactId: 'primary',
          alternativeContactIds: ['a', 'b'],
        ),
      ];
      for (final cfg in cases) {
        check(_roundTrip(cfg)).equals(cfg);
      }
    });

    test('LoudAlarmConfig round-trips', () {
      const cases = [
        LoudAlarmConfig(),
        LoudAlarmConfig(flashScreen: false, maxVolume: false, flashSpeed: 0.2),
      ];
      for (final cfg in cases) {
        check(_roundTrip(cfg)).equals(cfg);
      }
    });

    test('CallEmergencyConfig round-trips with override', () {
      const cases = [
        CallEmergencyConfig(),
        CallEmergencyConfig(emergencyNumber: '112', showConfirmation: false),
      ];
      for (final cfg in cases) {
        check(_roundTrip(cfg)).equals(cfg);
      }
    });

    test('StepConfig.fromJson throws on unknown tag', () {
      check(
        () => StepConfig.fromJson(const {'type': 'mystery'}),
      ).throws<ArgumentError>();
    });

    test('StepConfig.fromJson throws on missing tag', () {
      check(() => StepConfig.fromJson(const {})).throws<ArgumentError>();
    });
  });

  group('Domain models: JSON round-trip', () {
    test('ChainStep round-trips with config', () {
      final s = step(
        type: ChainStepType.smsContact,
        order: 2,
        durationSeconds: 15,
        gracePeriodSeconds: 3,
        retryCount: 1,
        randomize: 0.25,
        config: const SmsContactConfig(
          contactIds: ['x'],
          contactSelection: SmsContactSelection.specificIds,
        ),
      );
      final restored = ChainStep.fromJson(s.toJson());
      check(restored).equals(s);
    });

    test('EmergencyContact round-trips including channels', () {
      final c = EmergencyContact(
        id: 'c1',
        name: 'Carol',
        phoneNumber: '+44 207 000',
        sortOrder: 5,
        channels: const [MessageChannel.sms, MessageChannel.whatsapp],
      );
      final restored = EmergencyContact.fromJson(c.toJson());
      check(restored).equals(c);
    });

    test('SessionMode round-trips through JSON', () {
      final m = makeMode(
        id: 'mode-x',
        name: 'Session X',
        steps: [
          holdStep(),
          smsStep(order: 1, durationSeconds: 3),
          step(type: ChainStepType.loudAlarm, order: 2, durationSeconds: 2),
        ],
        distressModeId: 'd1',
      );
      final restored = SessionMode.fromJson(m.toJson());
      check(restored.id).equals(m.id);
      check(restored.chainSteps.length).equals(m.chainSteps.length);
    });

    test('ChainEventData round-trips preserving metadata', () {
      final now = DateTime.utc(2026, 4, 20);
      final e = ChainEventData(
        event: ChainEvent.graceExpired,
        timestamp: now,
        stepIndex: 2,
        stepType: ChainStepType.holdButton,
        metadata: const {'reason': 'release', 'missCount': 1},
      );
      final restored = ChainEventData.fromJson(e.toJson());
      check(restored.event).equals(e.event);
      check(restored.metadata['reason']).equals('release');
      check(restored.metadata['missCount']).equals(1);
    });

    test('EventDefaults round-trips and covers all types', () {
      const defaults = EventDefaults();
      final restored = EventDefaults.fromJson(defaults.toJson());
      for (final t in ChainStepType.values) {
        check(restored.forType(t)).equals(defaults.forType(t));
      }
    });

    test('HardwareButtonDistressTrigger JSON round-trips', () {
      const t = HardwareButtonDistressTrigger(
        buttonType: ButtonType.volumeUp,
        trigger: RepeatPressTrigger(pressCount: 5, pressWindowMs: 500),
      );
      final restored = Trigger.fromJson(t.toJson());
      check(restored).equals(t);
    });
  });

  group('Property: randomized ChainStep creation preserves invariants', () {
    final rand = Random(42);
    test('100 randomized ChainStep instances round-trip', () {
      for (var i = 0; i < 100; i++) {
        final type =
            ChainStepType.values[rand.nextInt(ChainStepType.values.length)];
        final s = ChainStep(
          id: 'id-$i',
          type: type,
          order: i,
          durationSeconds: rand.nextInt(60) + 1,
          gracePeriodSeconds: rand.nextInt(30),
          waitSeconds: rand.nextInt(10),
          retryCount: rand.nextInt(3),
          randomize: rand.nextDouble(),
        );
        final restored = ChainStep.fromJson(s.toJson());
        check(restored.id).equals(s.id);
        check(restored.type).equals(s.type);
        check(restored.order).equals(s.order);
        check(restored.durationSeconds).equals(s.durationSeconds);
        check(restored.gracePeriodSeconds).equals(s.gracePeriodSeconds);
      }
    });
  });
}
