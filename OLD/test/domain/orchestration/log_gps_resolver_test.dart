/// Tests for [LogGpsResolver] (spec 11 §DE-2). Verifies the
/// three-tier precedence wiring through a real
/// [SessionContext]/[ChainStep] pair.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/log_gps_resolver.dart';
import 'package:guardianangela/services/fakes/fake_audio_service.dart';
import 'package:guardianangela/services/fakes/fake_messaging_service.dart';
import 'package:guardianangela/services/fakes/fake_notification_service.dart';
import 'package:guardianangela/services/fakes/fake_phone_service.dart';
import 'package:guardianangela/services/fakes/fake_vibration_service.dart';

ChainStep _step({StepConfig? config}) => ChainStep(
  id: 'step-1',
  type: ChainStepType.smsContact,
  order: 0,
  durationSeconds: 10,
  gracePeriodSeconds: 0,
  waitSeconds: 0,
  retryCount: 0,
  randomize: 0,
  config: config,
);

EventServices _services({
  required EventDefaults? eventDefaults,
  required bool gpsLoggingEnabled,
}) => EventServices(
  audio: FakeAudioService(),
  messaging: FakeMessagingService(),
  phone: FakePhoneService(),
  notification: FakeNotificationService(),
  vibration: FakeVibrationService(),
  context: SessionContext(
    eventDefaults: eventDefaults,
    gpsLoggingEnabled: gpsLoggingEnabled,
  ),
  isCancelled: () => false,
);

void main() {
  group('LogGpsResolver.resolve', () {
    test('step.forceOff trumps everything', () {
      final step = _step(
        config: const SmsContactConfig(logGps: LogGpsOverride.forceOff),
      );
      final s = _services(
        eventDefaults: const EventDefaults(
          smsContact: SmsContactConfig(logGps: LogGpsOverride.forceOn),
        ),
        gpsLoggingEnabled: true,
      );
      check(LogGpsResolver.resolve(step, s)).isFalse();
    });

    test('step.forceOn beats per-type forceOff and global false', () {
      final step = _step(
        config: const SmsContactConfig(logGps: LogGpsOverride.forceOn),
      );
      final s = _services(
        eventDefaults: const EventDefaults(
          smsContact: SmsContactConfig(logGps: LogGpsOverride.forceOff),
        ),
        gpsLoggingEnabled: false,
      );
      check(LogGpsResolver.resolve(step, s)).isTrue();
    });

    test('step.useDefault → per-type default decides', () {
      final step = _step(
        config: const SmsContactConfig(),
      );
      final s = _services(
        eventDefaults: const EventDefaults(
          smsContact: SmsContactConfig(logGps: LogGpsOverride.forceOff),
        ),
        gpsLoggingEnabled: true,
      );
      check(LogGpsResolver.resolve(step, s)).isFalse();
    });

    test('every layer useDefault → global wins', () {
      final step = _step(config: const SmsContactConfig());
      check(
        LogGpsResolver.resolve(
          step,
          _services(
            eventDefaults: const EventDefaults(),
            gpsLoggingEnabled: true,
          ),
        ),
      ).isTrue();
      check(
        LogGpsResolver.resolve(
          step,
          _services(
            eventDefaults: const EventDefaults(),
            gpsLoggingEnabled: false,
          ),
        ),
      ).isFalse();
    });

    test('null step.config + null eventDefaults → falls back to global', () {
      final step = _step();
      check(
        LogGpsResolver.resolve(
          step,
          _services(eventDefaults: null, gpsLoggingEnabled: true),
        ),
      ).isTrue();
    });

    test('null step.config but per-type forceOff → false', () {
      final step = _step();
      check(
        LogGpsResolver.resolve(
          step,
          _services(
            eventDefaults: const EventDefaults(
              smsContact: SmsContactConfig(logGps: LogGpsOverride.forceOff),
            ),
            gpsLoggingEnabled: true,
          ),
        ),
      ).isFalse();
    });
  });
}
