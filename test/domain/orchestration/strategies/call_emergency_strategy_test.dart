// Tests for CallEmergencyStrategy.
//
// Covers: simulation guard, number resolution (config vs default vs null/empty),
// pre-call SMS (sendLocationSmsFirst, contact filtering, ordering),
// phone.callEmergency parameters, no-side-effect services, simulationDescription,
// const identity, and null step.config handling.
//
// See spec 02 §9 callEmergency.

import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/orchestration/strategies/call_emergency_strategy.dart';
import '../_test_fakes.dart';

// ─── Local helpers ────────────────────────────────────────────────────────────

const _uuid = '00000000-0000-0000-0000-000000000009';

/// Builds a [ChainStep] of type [ChainStepType.callEmergency] with an optional
/// [CallEmergencyConfig].
///
/// When [config] is null the step carries no typed config, exercising the
/// null-config path.
ChainStep _step({CallEmergencyConfig? config}) => ChainStep(
  id: _uuid,
  type: ChainStepType.callEmergency,
  order: 0,
  waitSeconds: 0,
  durationSeconds: 10,
  gracePeriodSeconds: 5,
  retryCount: 0,
  randomize: false,
  config: config,
);

/// Returns an SMS-capable [EmergencyContact] with the given [id] and [name].
///
/// Uses the default [MessageChannel.sms] channel list.
EmergencyContact _smsContact({required String id, required String name}) =>
    EmergencyContact(
      id: id,
      name: name,
      phoneNumber: '+1555000$id',
      sortOrder: 0,
    );

/// Returns a [EmergencyContact] that has NO sms channel (whatsapp only).
EmergencyContact _whatsappContact({required String id}) => EmergencyContact(
  id: id,
  name: 'WA Contact $id',
  phoneNumber: '+1555999$id',
  sortOrder: 1,
  channels: const [MessageChannel.whatsapp],
);

void main() {
  // ─── 1. executeReal — simulation guard ────────────────────────────────────
  group('executeReal — simulation guard', () {
    test('isSimulation=true: phone.calls is empty (sim_blocked)', () async {
      final phone = FakePhoneService();
      final services = buildServices(phone: phone, isSimulation: true);
      await const CallEmergencyStrategy().executeReal(_step(), services);
      expect(phone.calls, isEmpty);
    });

    test('isSimulation=true: messaging.calls is empty', () async {
      final messaging = FakeMessagingService();
      final services = buildServices(
        messaging: messaging,
        isSimulation: true,
        contacts: [_smsContact(id: '1', name: 'Alice')],
        emergencyNumberDefault: '999',
      );
      await const CallEmergencyStrategy().executeReal(_step(), services);
      expect(messaging.calls, isEmpty);
    });

    test('isSimulation=true: audio, vibration, flash, screenFlash, recording '
        'all empty', () async {
      final audio = FakeAudioService();
      final vibration = FakeVibrationService();
      final flash = FakeFlashService();
      final screenFlash = FakeScreenFlashService();
      final recording = FakeRecordingService();
      final services = buildServices(
        audio: audio,
        vibration: vibration,
        flash: flash,
        screenFlash: screenFlash,
        recording: recording,
        isSimulation: true,
        emergencyNumberDefault: '999',
      );
      await const CallEmergencyStrategy().executeReal(_step(), services);
      expect(audio.calls, isEmpty);
      expect(vibration.calls, isEmpty);
      expect(flash.calls, isEmpty);
      expect(screenFlash.calls, isEmpty);
      expect(recording.calls, isEmpty);
    });

    test(
      'isSimulation=true with explicit config still blocks all service calls',
      () async {
        final phone = FakePhoneService();
        final messaging = FakeMessagingService();
        final services = buildServices(
          phone: phone,
          messaging: messaging,
          isSimulation: true,
          contacts: [_smsContact(id: '1', name: 'Alice')],
        );
        await const CallEmergencyStrategy().executeReal(
          _step(config: const CallEmergencyConfig(emergencyNumber: '112')),
          services,
        );
        expect(phone.calls, isEmpty);
        expect(messaging.calls, isEmpty);
      },
    );
  });

  // ─── 2. executeReal — number resolution ───────────────────────────────────
  group('executeReal — number resolution', () {
    test(
      'config.emergencyNumber=999 overrides emergencyNumberDefault=112',
      () async {
        final phone = FakePhoneService();
        final services = buildServices(
          phone: phone,
          emergencyNumberDefault: '112',
        );
        await const CallEmergencyStrategy().executeReal(
          _step(
            config: const CallEmergencyConfig(
              emergencyNumber: '999',
              sendLocationSmsFirst: false,
            ),
          ),
          services,
        );
        expect(phone.calls, hasLength(1));
        expect(phone.calls.first['emergencyNumber'], equals('999'));
      },
    );

    test(
      'config.emergencyNumber=null falls back to emergencyNumberDefault=112',
      () async {
        final phone = FakePhoneService();
        final services = buildServices(
          phone: phone,
          emergencyNumberDefault: '112',
        );
        await const CallEmergencyStrategy().executeReal(
          _step(config: const CallEmergencyConfig(sendLocationSmsFirst: false)),
          services,
        );
        expect(phone.calls, hasLength(1));
        expect(phone.calls.first['emergencyNumber'], equals('112'));
      },
    );

    test(
      'config.emergencyNumber="" (empty) throws StateError (empty treated as no number)',
      () async {
        final phone = FakePhoneService();
        final services = buildServices(
          phone: phone,
          emergencyNumberDefault: '911',
        );
        await expectLater(
          const CallEmergencyStrategy().executeReal(
            _step(
              config: const CallEmergencyConfig(
                emergencyNumber: '',
                sendLocationSmsFirst: false,
              ),
            ),
            services,
          ),
          throwsA(isA<StateError>()),
        );
        expect(phone.calls, isEmpty);
      },
    );

    test(
      'config.emergencyNumber=null and emergencyNumberDefault=null throws StateError',
      () async {
        final services = buildServices(lastLocationUrl: null);
        await expectLater(
          const CallEmergencyStrategy().executeReal(
            _step(
              config: const CallEmergencyConfig(sendLocationSmsFirst: false),
            ),
            services,
          ),
          throwsA(isA<StateError>()),
        );
      },
    );

    test(
      'config.emergencyNumber=null and emergencyNumberDefault="" throws StateError',
      () async {
        final services = buildServices(
          emergencyNumberDefault: '',
          lastLocationUrl: null,
        );
        await expectLater(
          const CallEmergencyStrategy().executeReal(
            _step(
              config: const CallEmergencyConfig(sendLocationSmsFirst: false),
            ),
            services,
          ),
          throwsA(isA<StateError>()),
        );
      },
    );

    test('StateError message contains strategy class name', () async {
      final services = buildServices();
      Object? caught;
      try {
        await const CallEmergencyStrategy().executeReal(
          _step(config: const CallEmergencyConfig(sendLocationSmsFirst: false)),
          services,
        );
      } catch (e) {
        caught = e;
      }
      expect(caught, isA<StateError>());
      expect(
        (caught! as StateError).message,
        contains('CallEmergencyStrategy'),
      );
    });
  });

  // ─── 3. executeReal — pre-call SMS (sendLocationSmsFirst) ─────────────────
  group('executeReal — pre-call SMS', () {
    test(
      'sendLocationSmsFirst=true with 2 sms-channel contacts sends 2 messages',
      () async {
        final messaging = FakeMessagingService();
        final services = buildServices(
          messaging: messaging,
          emergencyNumberDefault: '999',
          contacts: [
            _smsContact(id: '1', name: 'Alice'),
            _smsContact(id: '2', name: 'Bob'),
          ],
        );
        await const CallEmergencyStrategy().executeReal(
          _step(config: const CallEmergencyConfig(emergencyNumber: '999')),
          services,
        );
        expect(
          messaging.calls.where((c) => c['method'] == 'sendMessage'),
          hasLength(2),
        );
      },
    );

    test(
      'sendLocationSmsFirst=false sends 0 messages; phone call still fires',
      () async {
        final messaging = FakeMessagingService();
        final phone = FakePhoneService();
        final services = buildServices(
          messaging: messaging,
          phone: phone,
          emergencyNumberDefault: '999',
          contacts: [_smsContact(id: '1', name: 'Alice')],
        );
        await const CallEmergencyStrategy().executeReal(
          _step(
            config: const CallEmergencyConfig(
              emergencyNumber: '999',
              sendLocationSmsFirst: false,
            ),
          ),
          services,
        );
        expect(messaging.calls, isEmpty);
        expect(phone.calls, hasLength(1));
        expect(phone.calls.first['method'], equals('callEmergency'));
      },
    );

    test('sendLocationSmsFirst=true with 0 sms contacts sends 0 messages; '
        'phone call still fires', () async {
      final messaging = FakeMessagingService();
      final phone = FakePhoneService();
      final services = buildServices(
        messaging: messaging,
        phone: phone,
        emergencyNumberDefault: '999',
      );
      await const CallEmergencyStrategy().executeReal(
        _step(config: const CallEmergencyConfig(emergencyNumber: '999')),
        services,
      );
      expect(messaging.calls, isEmpty);
      expect(phone.calls, hasLength(1));
    });

    test(
      'sendLocationSmsFirst=true with 1 sms + 1 whatsapp contact sends exactly 1 message',
      () async {
        final messaging = FakeMessagingService();
        final services = buildServices(
          messaging: messaging,
          emergencyNumberDefault: '112',
          contacts: [
            _smsContact(id: '1', name: 'Alice'),
            _whatsappContact(id: '2'),
          ],
        );
        await const CallEmergencyStrategy().executeReal(
          _step(config: const CallEmergencyConfig(emergencyNumber: '112')),
          services,
        );
        expect(
          messaging.calls.where((c) => c['method'] == 'sendMessage'),
          hasLength(1),
        );
        final sentContact =
            messaging.calls.first['contact'] as EmergencyContact;
        expect(sentContact.name, equals('Alice'));
      },
    );

    test('pre-call SMS message includes emergency number', () async {
      final messaging = FakeMessagingService();
      final services = buildServices(
        messaging: messaging,
        emergencyNumberDefault: '999',
        contacts: [_smsContact(id: '1', name: 'Alice')],
      );
      await const CallEmergencyStrategy().executeReal(
        _step(config: const CallEmergencyConfig(emergencyNumber: '999')),
        services,
      );
      final message = messaging.calls.first['message'] as String;
      expect(message, contains('999'));
    });

    test(
      'pre-call SMS message includes location from services.location.getLastLocationUrl()',
      () async {
        final messaging = FakeMessagingService();
        const locationUrl = 'https://maps.google.com/?q=51.5,0.1';
        final services = buildServices(
          messaging: messaging,
          emergencyNumberDefault: '999',
          lastLocationUrl: locationUrl,
          contacts: [_smsContact(id: '1', name: 'Alice')],
        );
        await const CallEmergencyStrategy().executeReal(
          _step(config: const CallEmergencyConfig(emergencyNumber: '999')),
          services,
        );
        final message = messaging.calls.first['message'] as String;
        expect(message, contains(locationUrl));
      },
    );

    test(
      'pre-call SMS message falls back to getLastLocationDescription when URL is null',
      () async {
        final messaging = FakeMessagingService();
        const description = 'Near Central Park';
        final services = buildServices(
          messaging: messaging,
          emergencyNumberDefault: '999',
          lastLocationUrl: null,
          lastLocationDescription: description,
          contacts: [_smsContact(id: '1', name: 'Alice')],
        );
        await const CallEmergencyStrategy().executeReal(
          _step(config: const CallEmergencyConfig(emergencyNumber: '999')),
          services,
        );
        final message = messaging.calls.first['message'] as String;
        expect(message, contains(description));
      },
    );

    test(
      'pre-call SMS message contains "Location unavailable" when both location '
      'fields are null',
      () async {
        final messaging = FakeMessagingService();
        final services = buildServices(
          messaging: messaging,
          emergencyNumberDefault: '999',
          lastLocationUrl: null,
          contacts: [_smsContact(id: '1', name: 'Alice')],
        );
        await const CallEmergencyStrategy().executeReal(
          _step(config: const CallEmergencyConfig(emergencyNumber: '999')),
          services,
        );
        final message = messaging.calls.first['message'] as String;
        expect(message, contains('Location unavailable'));
      },
    );

    test('SMS sends happen BEFORE phone call (ordering)', () async {
      // Use a sendHook that records how many phone.calls entries existed at
      // the moment sendMessage was invoked. If phone was not yet called, the
      // counter will be 0 for every SMS send.
      final phone = FakePhoneService();
      final phoneCallCountAtSendTime = <int>[];

      final messaging = FakeMessagingService(
        sendHook:
            ({required contact, required message, isSimulation = false}) async {
              phoneCallCountAtSendTime.add(phone.calls.length);
              return null;
            },
      );

      final services = buildServices(
        messaging: messaging,
        phone: phone,
        emergencyNumberDefault: '999',
        contacts: [
          _smsContact(id: '1', name: 'Alice'),
          _smsContact(id: '2', name: 'Bob'),
        ],
      );

      await const CallEmergencyStrategy().executeReal(
        _step(config: const CallEmergencyConfig(emergencyNumber: '999')),
        services,
      );

      // Both SMS sends should have seen 0 phone.callEmergency calls.
      expect(phoneCallCountAtSendTime, hasLength(2));
      expect(
        phoneCallCountAtSendTime,
        everyElement(equals(0)),
        reason: 'SMS sends must precede the phone.callEmergency call',
      );
      // Phone call was made after both sends.
      expect(phone.calls, hasLength(1));
    });
  });

  // ─── 4. executeReal — phone.callEmergency parameters ─────────────────────
  group('executeReal — phone.callEmergency', () {
    test('phone.calls has exactly 1 entry with method=callEmergency', () async {
      final phone = FakePhoneService();
      final services = buildServices(
        phone: phone,
        emergencyNumberDefault: '112',
      );
      await const CallEmergencyStrategy().executeReal(
        _step(config: const CallEmergencyConfig(sendLocationSmsFirst: false)),
        services,
      );
      expect(phone.calls, hasLength(1));
      expect(phone.calls.first['method'], equals('callEmergency'));
    });

    test('phone.callEmergency is called with isSimulation=false', () async {
      final phone = FakePhoneService();
      final services = buildServices(
        phone: phone,
        emergencyNumberDefault: '112',
      );
      await const CallEmergencyStrategy().executeReal(
        _step(config: const CallEmergencyConfig(sendLocationSmsFirst: false)),
        services,
      );
      expect(phone.calls.first['isSimulation'], isFalse);
    });

    test(
      'showConfirmation=false does NOT skip phone call (UI-level field)',
      () async {
        final phone = FakePhoneService();
        final services = buildServices(
          phone: phone,
          emergencyNumberDefault: '999',
        );
        await const CallEmergencyStrategy().executeReal(
          _step(
            config: const CallEmergencyConfig(
              sendLocationSmsFirst: false,
              showConfirmation: false,
            ),
          ),
          services,
        );
        expect(phone.calls, hasLength(1));
      },
    );

    test(
      'confirmationDurationSeconds=0 does NOT skip phone call (UI-level field)',
      () async {
        final phone = FakePhoneService();
        final services = buildServices(
          phone: phone,
          emergencyNumberDefault: '999',
        );
        await const CallEmergencyStrategy().executeReal(
          _step(
            config: const CallEmergencyConfig(
              sendLocationSmsFirst: false,
              confirmationDurationSeconds: 0,
            ),
          ),
          services,
        );
        expect(phone.calls, hasLength(1));
      },
    );
  });

  // ─── 5. executeReal — no unintended service calls ─────────────────────────
  group('executeReal — no unintended service calls', () {
    test('audio.calls is empty after real execution', () async {
      final audio = FakeAudioService();
      final services = buildServices(
        audio: audio,
        emergencyNumberDefault: '999',
      );
      await const CallEmergencyStrategy().executeReal(
        _step(config: const CallEmergencyConfig(sendLocationSmsFirst: false)),
        services,
      );
      expect(audio.calls, isEmpty);
    });

    test('vibration.calls is empty after real execution', () async {
      final vibration = FakeVibrationService();
      final services = buildServices(
        vibration: vibration,
        emergencyNumberDefault: '999',
      );
      await const CallEmergencyStrategy().executeReal(
        _step(config: const CallEmergencyConfig(sendLocationSmsFirst: false)),
        services,
      );
      expect(vibration.calls, isEmpty);
    });

    test('flash.calls is empty after real execution', () async {
      final flash = FakeFlashService();
      final services = buildServices(
        flash: flash,
        emergencyNumberDefault: '999',
      );
      await const CallEmergencyStrategy().executeReal(
        _step(config: const CallEmergencyConfig(sendLocationSmsFirst: false)),
        services,
      );
      expect(flash.calls, isEmpty);
    });

    test('screenFlash.calls is empty after real execution', () async {
      final screenFlash = FakeScreenFlashService();
      final services = buildServices(
        screenFlash: screenFlash,
        emergencyNumberDefault: '999',
      );
      await const CallEmergencyStrategy().executeReal(
        _step(config: const CallEmergencyConfig(sendLocationSmsFirst: false)),
        services,
      );
      expect(screenFlash.calls, isEmpty);
    });

    test('recording.calls is empty after real execution', () async {
      final recording = FakeRecordingService();
      final services = buildServices(
        recording: recording,
        emergencyNumberDefault: '999',
      );
      await const CallEmergencyStrategy().executeReal(
        _step(config: const CallEmergencyConfig(sendLocationSmsFirst: false)),
        services,
      );
      expect(recording.calls, isEmpty);
    });
  });

  // ─── 6. simulationDescription ─────────────────────────────────────────────
  group('simulationDescription', () {
    test('config.emergencyNumber=112 → "Would call 112"', () {
      final services = buildServices();
      final result = const CallEmergencyStrategy().simulationDescription(
        _step(config: const CallEmergencyConfig(emergencyNumber: '112')),
        services,
      );
      expect(result, equals('Would call 112'));
    });

    test(
      'config.emergencyNumber=null, emergencyNumberDefault=911 → "Would call 911"',
      () {
        final services = buildServices(emergencyNumberDefault: '911');
        final result = const CallEmergencyStrategy().simulationDescription(
          _step(config: const CallEmergencyConfig()),
          services,
        );
        expect(result, equals('Would call 911'));
      },
    );

    test('both emergencyNumber=null and emergencyNumberDefault=null → '
        '"Would call (no number configured)" — does NOT throw', () {
      final services = buildServices();
      String? result;
      Object? thrown;
      try {
        result = const CallEmergencyStrategy().simulationDescription(
          _step(config: const CallEmergencyConfig()),
          services,
        );
      } catch (e) {
        thrown = e;
      }
      expect(thrown, isNull, reason: 'simulationDescription must not throw');
      expect(result, equals('Would call (no number configured)'));
    });

    test(
      'step.config=null falls back to emergencyNumberDefault from services',
      () {
        final services = buildServices(emergencyNumberDefault: '000');
        final result = const CallEmergencyStrategy().simulationDescription(
          _step(),
          services,
        );
        expect(result, equals('Would call 000'));
      },
    );

    test('step.config=null and emergencyNumberDefault=null → '
        '"Would call (no number configured)"', () {
      final services = buildServices();
      final result = const CallEmergencyStrategy().simulationDescription(
        _step(),
        services,
      );
      expect(result, equals('Would call (no number configured)'));
    });

    test(
      'config.emergencyNumber overrides emergencyNumberDefault in description',
      () {
        final services = buildServices(emergencyNumberDefault: '112');
        final result = const CallEmergencyStrategy().simulationDescription(
          _step(config: const CallEmergencyConfig(emergencyNumber: '999')),
          services,
        );
        expect(result, equals('Would call 999'));
      },
    );
  });

  // ─── 7. Const identity ────────────────────────────────────────────────────
  group('const constructor — identity', () {
    test(
      'identical(CallEmergencyStrategy(), CallEmergencyStrategy()) is true',
      () {
        const a = CallEmergencyStrategy();
        const b = CallEmergencyStrategy();
        expect(identical(a, b), isTrue);
      },
    );

    test('CallEmergencyStrategy() is an EventStrategy', () {
      const strategy = CallEmergencyStrategy();
      expect(strategy, isA<CallEmergencyStrategy>());
    });
  });

  // ─── 8. Null step.config + null safety ────────────────────────────────────
  group('null step.config — fallback to defaults', () {
    test(
      'step.config=null with emergencyNumberDefault=112 executes successfully',
      () async {
        final phone = FakePhoneService();
        final services = buildServices(
          phone: phone,
          emergencyNumberDefault: '112',
        );
        await expectLater(
          const CallEmergencyStrategy().executeReal(_step(), services),
          completes,
        );
        expect(phone.calls, hasLength(1));
        expect(phone.calls.first['emergencyNumber'], equals('112'));
      },
    );

    test('step.config=null with sms contact sends pre-call SMS (default '
        'sendLocationSmsFirst=true)', () async {
      final messaging = FakeMessagingService();
      final phone = FakePhoneService();
      final services = buildServices(
        messaging: messaging,
        phone: phone,
        emergencyNumberDefault: '112',
        contacts: [_smsContact(id: '1', name: 'Alice')],
      );
      await const CallEmergencyStrategy().executeReal(_step(), services);
      // Default config has sendLocationSmsFirst=true, so one SMS expected.
      expect(
        messaging.calls.where((c) => c['method'] == 'sendMessage'),
        hasLength(1),
      );
      expect(phone.calls, hasLength(1));
    });

    test(
      'step.config=null with no contacts: 0 messaging calls, 1 phone call',
      () async {
        final messaging = FakeMessagingService();
        final phone = FakePhoneService();
        final services = buildServices(
          messaging: messaging,
          phone: phone,
          emergencyNumberDefault: '112',
        );
        await const CallEmergencyStrategy().executeReal(_step(), services);
        expect(messaging.calls, isEmpty);
        expect(phone.calls, hasLength(1));
      },
    );
  });
}
