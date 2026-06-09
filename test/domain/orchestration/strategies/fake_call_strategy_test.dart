// G5 update (phase-5-fix-r2): FakeCallStrategy now wires playRingtone,
// fakeCallPattern, and showAlarmEscalation in executeReal per G5 mandate.
//
// Pivot 2 / R-1 (fakeCall-is-event-not-pause) still holds: the engine timer
// keeps running; FakeCallScreen is a route push. The strategy fires the
// ringtone, vibration, and lock-screen notification so the fake call arrives
// even when the device is locked. Messaging, phone, flash, recording, and
// screenFlash remain untouched.
//
// See spec 02 §5 fakeCall and spec 05:880-886.

import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/call_style.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/voice_output_mode.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/strategies/fake_call_strategy.dart';
import '../_test_fakes.dart';

// ─── Local helpers ─────────────────────────────────────────────────────────────

const _uuid = '00000000-0000-0000-0000-000000000002';

/// Builds a [ChainStep] of type [ChainStepType.fakeCall] with an optional
/// [FakeCallConfig].
ChainStep _step({FakeCallConfig? config}) => ChainStep(
  id: _uuid,
  type: ChainStepType.fakeCall,
  order: 0,
  waitSeconds: 0,
  durationSeconds: 30,
  gracePeriodSeconds: 5,
  retryCount: 0,
  randomize: false,
  config: config,
);

void main() {
  // ─── 1. executeReal: fires ringtone, vibration, and alarm escalation ────────
  group('executeReal — wires ringtone + fakeCallPattern + alarmEscalation', () {
    test('playRingtone is called once', () async {
      final audio = FakeAudioService();
      final services = buildServices(audio: audio);
      await const FakeCallStrategy().executeReal(
        _step(config: const FakeCallConfig()),
        services,
      );
      final ringtoneCalls = audio.calls
          .where((c) => c['method'] == 'playRingtone')
          .toList();
      expect(ringtoneCalls, hasLength(1));
    });

    test('fakeCallPattern is called once', () async {
      final vibration = FakeVibrationService();
      final services = buildServices(vibration: vibration);
      await const FakeCallStrategy().executeReal(
        _step(config: const FakeCallConfig()),
        services,
      );
      final vibCalls = vibration.calls
          .where((c) => c['method'] == 'fakeCallPattern')
          .toList();
      expect(vibCalls, hasLength(1));
    });

    test('showAlarmEscalation is called once', () async {
      final notification = FakeNotificationService();
      final services = buildServices(notification: notification);
      await const FakeCallStrategy().executeReal(
        _step(config: const FakeCallConfig()),
        services,
      );
      final escalationCalls = notification.calls
          .where((c) => c['method'] == 'showAlarmEscalation')
          .toList();
      expect(escalationCalls, hasLength(1));
    });

    test('showAlarmEscalation title contains caller name', () async {
      final notification = FakeNotificationService();
      final services = buildServices(notification: notification);
      await const FakeCallStrategy().executeReal(
        _step(config: const FakeCallConfig(callerName: 'Dr. Smith')),
        services,
      );
      final call = notification.calls.firstWhere(
        (c) => c['method'] == 'showAlarmEscalation',
      );
      expect((call['title'] as String).contains('Dr. Smith'), isTrue);
    });
  });

  // ─── 2. executeReal: non-audio/non-vibration services stay empty ─────────────
  group(
    'executeReal — messaging, phone, flash, recording, screenFlash untouched',
    () {
      test('messaging.calls is empty', () async {
        final messaging = FakeMessagingService();
        final services = buildServices(messaging: messaging);
        await const FakeCallStrategy().executeReal(_step(), services);
        expect(messaging.calls, isEmpty);
      });

      test('phone.calls is empty', () async {
        final phone = FakePhoneService();
        final services = buildServices(phone: phone);
        await const FakeCallStrategy().executeReal(_step(), services);
        expect(phone.calls, isEmpty);
      });

      test('flash.calls is empty', () async {
        final flash = FakeFlashService();
        final services = buildServices(flash: flash);
        await const FakeCallStrategy().executeReal(_step(), services);
        expect(flash.calls, isEmpty);
      });

      test('recording.calls is empty', () async {
        final recording = FakeRecordingService();
        final services = buildServices(recording: recording);
        await const FakeCallStrategy().executeReal(_step(), services);
        expect(recording.calls, isEmpty);
      });

      test('screenFlash.calls is empty', () async {
        final screenFlash = FakeScreenFlashService();
        final services = buildServices(screenFlash: screenFlash);
        await const FakeCallStrategy().executeReal(_step(), services);
        expect(screenFlash.calls, isEmpty);
      });
    },
  );

  // ─── 3. executeReal fires in both real and simulation mode ───────────────────
  group('executeReal — fires in simulation mode (local-only actions)', () {
    test('playRingtone fires when isSimulation=true', () async {
      final audio = FakeAudioService();
      final services = buildServices(audio: audio, isSimulation: true);
      await const FakeCallStrategy().executeReal(
        _step(config: const FakeCallConfig()),
        services,
      );
      expect(audio.calls.any((c) => c['method'] == 'playRingtone'), isTrue);
    });

    test('fakeCallPattern fires when isSimulation=true', () async {
      final vibration = FakeVibrationService();
      final services = buildServices(vibration: vibration, isSimulation: true);
      await const FakeCallStrategy().executeReal(
        _step(config: const FakeCallConfig()),
        services,
      );
      expect(
        vibration.calls.any((c) => c['method'] == 'fakeCallPattern'),
        isTrue,
      );
    });

    test('showAlarmEscalation fires when isSimulation=true', () async {
      final notification = FakeNotificationService();
      final services = buildServices(
        notification: notification,
        isSimulation: true,
      );
      await const FakeCallStrategy().executeReal(
        _step(config: const FakeCallConfig()),
        services,
      );
      expect(
        notification.calls.any((c) => c['method'] == 'showAlarmEscalation'),
        isTrue,
      );
    });
  });

  // ─── 4. ringtone source: custom path when set, default otherwise ────────────
  group(
    'executeReal — ringtone uses customRingtonePath, never the voice clip',
    () {
      test('playRingtone receives null when no custom ringtone is set '
          '(→ bundled default ring)', () async {
        final audio = FakeAudioService();
        final services = buildServices(audio: audio);
        await const FakeCallStrategy().executeReal(
          _step(config: const FakeCallConfig()),
          services,
        );
        final call = audio.calls.firstWhere(
          (c) => c['method'] == 'playRingtone',
        );
        expect(call['assetPath'], isNull);
      });

      test(
        'playRingtone receives the user-supplied customRingtonePath when set '
        '(Tier-F F3)',
        () async {
          final audio = FakeAudioService();
          final services = buildServices(audio: audio);
          await const FakeCallStrategy().executeReal(
            _step(
              config: const FakeCallConfig(
                customRingtonePath: '/data/ringtones/mine.mp3',
              ),
            ),
            services,
          );
          final call = audio.calls.firstWhere(
            (c) => c['method'] == 'playRingtone',
          );
          expect(call['assetPath'], '/data/ringtones/mine.mp3');
        },
      );

      test(
        'the ringtone is the customRingtonePath, NOT the voiceRecordingPath — '
        'voiceRecordingPath plays on answer, it is NOT the ringtone',
        () async {
          final audio = FakeAudioService();
          final services = buildServices(audio: audio);
          await const FakeCallStrategy().executeReal(
            _step(
              config: const FakeCallConfig(
                voiceRecordingPath: '/storage/voice.aac',
                customRingtonePath: '/data/ringtones/mine.mp3',
              ),
            ),
            services,
          );
          final call = audio.calls.firstWhere(
            (c) => c['method'] == 'playRingtone',
          );
          // The ringtone is the custom ringtone, never the voice clip.
          expect(call['assetPath'], '/data/ringtones/mine.mp3');
          // The strategy must not play the voice clip as the ringtone; the voice
          // is played on answer by SessionController.answerFakeCall.
          expect(
            audio.calls.any((c) => c['method'] == 'playVoiceRecording'),
            isFalse,
          );
        },
      );
    },
  );

  // ─── 5. CallStyle enum variants — strategy fires all three services ──────────
  group('executeReal — all CallStyle values — wires ringtone, vib, notif', () {
    for (final style in CallStyle.values) {
      test('CallStyle.${style.name} fires ringtone + vib + notif', () async {
        final audio = FakeAudioService();
        final vibration = FakeVibrationService();
        final notification = FakeNotificationService();
        final services = buildServices(
          audio: audio,
          vibration: vibration,
          notification: notification,
        );
        await const FakeCallStrategy().executeReal(
          _step(config: FakeCallConfig(callStyle: style)),
          services,
        );
        expect(
          audio.calls.any((c) => c['method'] == 'playRingtone'),
          isTrue,
          reason: 'CallStyle.${style.name}',
        );
        expect(
          vibration.calls.any((c) => c['method'] == 'fakeCallPattern'),
          isTrue,
          reason: 'CallStyle.${style.name}',
        );
        expect(
          notification.calls.any((c) => c['method'] == 'showAlarmEscalation'),
          isTrue,
          reason: 'CallStyle.${style.name}',
        );
      });
    }
  });

  // ─── 6. callerName reflected in escalation notification title ───────────────
  group('executeReal — callerName variations reflected in notification', () {
    test('default callerName "Angela" appears in escalation title', () async {
      final notification = FakeNotificationService();
      final services = buildServices(notification: notification);
      await const FakeCallStrategy().executeReal(
        _step(config: const FakeCallConfig()),
        services,
      );
      final call = notification.calls.firstWhere(
        (c) => c['method'] == 'showAlarmEscalation',
      );
      expect((call['title'] as String).contains('Angela'), isTrue);
    });

    test('custom callerName appears in escalation title', () async {
      final notification = FakeNotificationService();
      final services = buildServices(notification: notification);
      await const FakeCallStrategy().executeReal(
        _step(config: const FakeCallConfig(callerName: 'Mom')),
        services,
      );
      final call = notification.calls.firstWhere(
        (c) => c['method'] == 'showAlarmEscalation',
      );
      expect((call['title'] as String).contains('Mom'), isTrue);
    });
  });

  // ─── 7. null config — graceful handling ──────────────────────────────────────
  group('null step.config — strategy uses defaults', () {
    test(
      'executeReal completes without throwing when config is null',
      () async {
        final services = buildServices();
        await expectLater(
          const FakeCallStrategy().executeReal(_step(), services),
          completes,
        );
      },
    );

    test('ringtone fires with null assetPath when config is null', () async {
      final audio = FakeAudioService();
      final services = buildServices(audio: audio);
      await const FakeCallStrategy().executeReal(_step(), services);
      expect(audio.calls.any((c) => c['method'] == 'playRingtone'), isTrue);
    });
  });

  // ─── 8. VoiceOutputMode — ringtone still fires ──────────────────────────────
  group('executeReal — VoiceOutputMode variations — ringtone still fires', () {
    for (final mode in VoiceOutputMode.values) {
      test('VoiceOutputMode.${mode.name} fires ringtone', () async {
        final audio = FakeAudioService();
        final services = buildServices(audio: audio);
        await const FakeCallStrategy().executeReal(
          _step(config: FakeCallConfig(voiceOutputMode: mode)),
          services,
        );
        expect(
          audio.calls.any((c) => c['method'] == 'playRingtone'),
          isTrue,
          reason: 'VoiceOutputMode.${mode.name}',
        );
      });
    }
  });

  // ─── 9. simulationDescription: returns null ──────────────────────────────────
  group('simulationDescription — always returns null', () {
    test('returns null for default FakeCallConfig', () {
      final services = buildServices();
      final result = const FakeCallStrategy().simulationDescription(
        _step(config: const FakeCallConfig()),
        services,
      );
      expect(result, isNull);
    });

    test('returns null when step.config is null', () {
      final services = buildServices();
      final result = const FakeCallStrategy().simulationDescription(
        _step(),
        services,
      );
      expect(result, isNull);
    });

    test('returns null when isSimulation=true', () {
      final services = buildServices(isSimulation: true);
      final result = const FakeCallStrategy().simulationDescription(
        _step(config: const FakeCallConfig()),
        services,
      );
      expect(result, isNull);
    });
  });

  // ─── 10. Const-ness ──────────────────────────────────────────────────────────
  group('const constructor — identity', () {
    test('two FakeCallStrategy() instances are identical (const)', () {
      const a = FakeCallStrategy();
      const b = FakeCallStrategy();
      expect(identical(a, b), isTrue);
    });
  });
}
