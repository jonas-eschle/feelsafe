/// Supplemental tests for [LoudAlarmStrategy] covering the
/// `flash != null && config.flashLight` branch that starts the
/// camera-LED strobe when a [FlashServiceProtocol] is wired in and
/// `LoudAlarmConfig.flashLight = true`.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/strategies/loud_alarm_strategy.dart';
import 'package:guardianangela/services/fakes/fake_audio_service.dart';
import 'package:guardianangela/services/fakes/fake_flash_service.dart';
import 'package:guardianangela/services/fakes/fake_messaging_service.dart';
import 'package:guardianangela/services/fakes/fake_notification_service.dart';
import 'package:guardianangela/services/fakes/fake_phone_service.dart';
import 'package:guardianangela/services/fakes/fake_vibration_service.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('LoudAlarmStrategy — flash service wired', () {
    late FakeAudioService audio;
    late FakeFlashService flash;
    late FakeVibrationService vibration;
    late FakeMessagingService messaging;
    late FakePhoneService phone;
    late FakeNotificationService notification;

    setUp(() {
      audio = FakeAudioService();
      flash = FakeFlashService();
      vibration = FakeVibrationService();
      messaging = FakeMessagingService();
      phone = FakePhoneService();
      notification = FakeNotificationService();
    });

    tearDown(() {
      audio.dispose();
      messaging.dispose();
      phone.dispose();
      notification.dispose();
      vibration.dispose();
    });

    EventServices buildServices({bool isSimulation = false}) => EventServices(
      audio: audio,
      messaging: messaging,
      phone: phone,
      notification: notification,
      vibration: vibration,
      context: SessionContext(isSimulation: isSimulation),
      isCancelled: () => false,
      flash: flash,
    );

    test('starts strobe when flashLight=true and flash service is wired',
        () async {
      const strategy = LoudAlarmStrategy();
      await strategy.executeReal(
        step(
          type: ChainStepType.loudAlarm,
          config: const LoudAlarmConfig(flashLight: true, flashSpeedMs: 200),
        ),
        buildServices(),
      );
      check(flash.calls).isNotEmpty();
      check(flash.calls.any((c) => c.startsWith('startStrobe'))).isTrue();
      check(flash.isStrobing).isTrue();
    });

    test('does not start strobe when flashLight=false', () async {
      const strategy = LoudAlarmStrategy();
      await strategy.executeReal(
        step(
          type: ChainStepType.loudAlarm,
          config: const LoudAlarmConfig(flashLight: false),
        ),
        buildServices(),
      );
      check(flash.calls).isEmpty();
    });

    test('strobe interval matches flashSpeedMs config', () async {
      const strategy = LoudAlarmStrategy();
      await strategy.executeReal(
        step(
          type: ChainStepType.loudAlarm,
          config: const LoudAlarmConfig(flashLight: true, flashSpeedMs: 300),
        ),
        buildServices(),
      );
      check(flash.calls.first).equals('startStrobe:300');
    });

    test('does not start strobe when flash service is absent (null)', () async {
      const strategy = LoudAlarmStrategy();
      final services = EventServices(
        audio: audio,
        messaging: messaging,
        phone: phone,
        notification: notification,
        vibration: vibration,
        context: const SessionContext(),
        isCancelled: () => false,
        // flash deliberately omitted → null
      );
      await strategy.executeReal(
        step(
          type: ChainStepType.loudAlarm,
          config: const LoudAlarmConfig(flashLight: true),
        ),
        services,
      );
      // Flash service is null — no calls are possible.
      check(flash.calls).isEmpty();
    });
  });
}
