/// Unit tests for `EventDefaults` — 9 sub-defaults, forType dispatch,
/// round-trip.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/models.dart';

void main() {
  group('EventDefaults', () {
    test('defaults populated', () {
      const d = EventDefaults();
      check(d.holdButton).isA<HoldButtonConfig>();
      check(d.disguisedReminder).isA<DisguisedReminderConfig>();
      check(d.hardwareButton).isA<HardwareButtonConfig>();
      check(d.countdownWarning).isA<CountdownWarningConfig>();
      check(d.fakeCall).isA<FakeCallConfig>();
      check(d.smsContact).isA<SmsContactConfig>();
      check(d.phoneCallContact).isA<PhoneCallContactConfig>();
      check(d.loudAlarm).isA<LoudAlarmConfig>();
      check(d.callEmergency).isA<CallEmergencyConfig>();
    });

    test('forType returns matching config for every ChainStepType', () {
      const d = EventDefaults();
      for (final type in ChainStepType.values) {
        final result = d.forType(type);
        check(result).isA<StepConfig>();
      }
    });

    test('forType holdButton returns HoldButtonConfig', () {
      const d = EventDefaults();
      check(d.forType(ChainStepType.holdButton)).isA<HoldButtonConfig>();
    });

    test('forType smsContact returns SmsContactConfig', () {
      const d = EventDefaults();
      check(d.forType(ChainStepType.smsContact)).isA<SmsContactConfig>();
    });

    test('round-trip defaults', () {
      const d = EventDefaults();
      check(EventDefaults.fromJson(d.toJson())).equals(d);
    });

    test('round-trip with customized sub-configs', () {
      const d = EventDefaults(
        holdButton: HoldButtonConfig(releaseSensitivity: 0.8),
        fakeCall: FakeCallConfig(callerName: 'Boss'),
        loudAlarm: LoudAlarmConfig(flashScreen: true),
      );
      final r = EventDefaults.fromJson(d.toJson());
      check(r.holdButton.releaseSensitivity).equals(0.8);
      check(r.fakeCall.callerName).equals('Boss');
      check(r.loudAlarm.flashScreen).isTrue();
    });

    test('copyWith replaces targeted field', () {
      const d = EventDefaults();
      final d2 = d.copyWith(
        holdButton: const HoldButtonConfig(releaseSensitivity: 0.9),
      );
      check(d2.holdButton.releaseSensitivity).equals(0.9);
      check(d2.fakeCall).equals(d.fakeCall);
    });

    test('equality', () {
      const a = EventDefaults();
      const b = EventDefaults();
      check(a).equals(b);
      check(a.hashCode).equals(b.hashCode);
    });

    test('inequality when sub-default differs', () {
      const a = EventDefaults();
      const b = EventDefaults(
        holdButton: HoldButtonConfig(releaseSensitivity: 0.99),
      );
      check(a).not((it) => it.equals(b));
    });

    test('fromJson tolerates missing fields', () {
      final d = EventDefaults.fromJson(const <String, Object?>{});
      check(d.holdButton).isA<HoldButtonConfig>();
      check(d.fakeCall).isA<FakeCallConfig>();
    });
  });
}
