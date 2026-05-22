// Pivot 2 / R-1: FakeCall is event-not-pause.
//
// The central contract of [FakeCallStrategy]: executeReal MUST be a no-op.
// No audio, messaging, phone, flash, vibration, recording, or screen-flash
// service is ever called — regardless of config values, isSimulation flag,
// CallStyle, VoiceOutputMode, declineIsSafe, ringDurationSeconds, or any
// other field. The fake-call UI (FakeCallScreen) is pushed by the
// SessionController (Phase 6) in response to the engine's `stepFired`
// event. The ringtone is played by AudioService from within FakeCallScreen.
// This strategy's only job is to exist in the registry and be a no-op.
//
// See spec 02 §5 fakeCall and §Answer / Hang-up Semantics (Pivot 2 / R-1).

import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/call_style.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/voice_output_mode.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/strategies/fake_call_strategy.dart';
import '../_test_fakes.dart';

// ─── Local helpers ────────────────────────────────────────────────────────────

const _uuid = '00000000-0000-0000-0000-000000000002';

/// Builds a [ChainStep] of type [ChainStepType.fakeCall] with an optional
/// [FakeCallConfig].
///
/// When [config] is null the step carries no typed config, exercising the
/// null-config path.
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

// ─── Helper: assert ALL 7 recording-capable fakes are empty ──────────────────

/// Asserts that every service fake with a [calls] list is empty.
///
/// Call after [FakeCallStrategy().executeReal] to verify the Pivot 2 contract
/// in a single sweep.
void _assertAllServicesEmpty({
  required FakeAudioService audio,
  required FakeVibrationService vibration,
  required FakeMessagingService messaging,
  required FakePhoneService phone,
  required FakeRecordingService recording,
  required FakeFlashService flash,
  required FakeScreenFlashService screenFlash,
  String? reason,
}) {
  expect(audio.calls, isEmpty, reason: reason);
  expect(vibration.calls, isEmpty, reason: reason);
  expect(messaging.calls, isEmpty, reason: reason);
  expect(phone.calls, isEmpty, reason: reason);
  expect(recording.calls, isEmpty, reason: reason);
  expect(flash.calls, isEmpty, reason: reason);
  expect(screenFlash.calls, isEmpty, reason: reason);
}

void main() {
  // ─── FIRST TEST: Pivot 2 / R-1 contract documentation ───────────────────
  //
  // Pivot 2 / R-1: FakeCall is event-not-pause. executeReal MUST be a no-op.
  //
  // This test is placed first so reviewers see the critical contract
  // immediately. No audio, messaging, phone, flash, vibration, recording, or
  // screen-flash service is ever called by FakeCallStrategy.executeReal.
  // The timer continues running; FakeCallScreen is pushed by the session
  // controller (Phase 6), not this strategy.
  test('PIVOT-2/R-1 contract: executeReal fires NO service — '
      'audio, vibration, messaging, phone, recording, flash, screenFlash '
      'all have empty calls lists after default-config execute', () async {
    final audio = FakeAudioService();
    final vibration = FakeVibrationService();
    final messaging = FakeMessagingService();
    final phone = FakePhoneService();
    final recording = FakeRecordingService();
    final flash = FakeFlashService();
    final screenFlash = FakeScreenFlashService();
    final services = buildServices(
      audio: audio,
      vibration: vibration,
      messaging: messaging,
      phone: phone,
      recording: recording,
      flash: flash,
      screenFlash: screenFlash,
    );
    await const FakeCallStrategy().executeReal(_step(), services);
    _assertAllServicesEmpty(
      audio: audio,
      vibration: vibration,
      messaging: messaging,
      phone: phone,
      recording: recording,
      flash: flash,
      screenFlash: screenFlash,
      reason: 'Pivot 2 / R-1: FakeCallStrategy.executeReal must be a no-op',
    );
  });

  // ─── 1. executeReal: no-op with default config — per-service checks ───────
  group(
    'executeReal — default config — each service is empty individually',
    () {
      test('audio is empty after execute', () async {
        final audio = FakeAudioService();
        final services = buildServices(audio: audio);
        await const FakeCallStrategy().executeReal(_step(), services);
        expect(audio.calls, isEmpty);
      });

      test('vibration is empty after execute', () async {
        final vibration = FakeVibrationService();
        final services = buildServices(vibration: vibration);
        await const FakeCallStrategy().executeReal(_step(), services);
        expect(vibration.calls, isEmpty);
      });

      test('messaging is empty after execute', () async {
        final messaging = FakeMessagingService();
        final services = buildServices(messaging: messaging);
        await const FakeCallStrategy().executeReal(_step(), services);
        expect(messaging.calls, isEmpty);
      });

      test('phone is empty after execute', () async {
        final phone = FakePhoneService();
        final services = buildServices(phone: phone);
        await const FakeCallStrategy().executeReal(_step(), services);
        expect(phone.calls, isEmpty);
      });

      test('recording is empty after execute', () async {
        final recording = FakeRecordingService();
        final services = buildServices(recording: recording);
        await const FakeCallStrategy().executeReal(_step(), services);
        expect(recording.calls, isEmpty);
      });

      test('flash is empty after execute', () async {
        final flash = FakeFlashService();
        final services = buildServices(flash: flash);
        await const FakeCallStrategy().executeReal(_step(), services);
        expect(flash.calls, isEmpty);
      });

      test('screenFlash is empty after execute', () async {
        final screenFlash = FakeScreenFlashService();
        final services = buildServices(screenFlash: screenFlash);
        await const FakeCallStrategy().executeReal(_step(), services);
        expect(screenFlash.calls, isEmpty);
      });
    },
  );

  // ─── 2. executeReal: no-op under simulation ──────────────────────────────
  group('executeReal — isSimulation=true — still a no-op', () {
    test(
      'all fakes empty when isSimulation=true with default config',
      () async {
        final audio = FakeAudioService();
        final vibration = FakeVibrationService();
        final messaging = FakeMessagingService();
        final phone = FakePhoneService();
        final recording = FakeRecordingService();
        final flash = FakeFlashService();
        final screenFlash = FakeScreenFlashService();
        final services = buildServices(
          isSimulation: true,
          audio: audio,
          vibration: vibration,
          messaging: messaging,
          phone: phone,
          recording: recording,
          flash: flash,
          screenFlash: screenFlash,
        );
        await const FakeCallStrategy().executeReal(_step(), services);
        _assertAllServicesEmpty(
          audio: audio,
          vibration: vibration,
          messaging: messaging,
          phone: phone,
          recording: recording,
          flash: flash,
          screenFlash: screenFlash,
          reason: 'Simulation guard irrelevant — strategy is already a no-op',
        );
      },
    );

    test(
      'audio empty when isSimulation=true with explicit FakeCallConfig',
      () async {
        final audio = FakeAudioService();
        final services = buildServices(audio: audio, isSimulation: true);
        final s = _step(
          config: const FakeCallConfig(
            callerName: 'Test Caller',
            ringDurationSeconds: 60,
            voiceOutputMode: VoiceOutputMode.speaker,
          ),
        );
        await const FakeCallStrategy().executeReal(s, services);
        expect(audio.calls, isEmpty);
      },
    );
  });

  // ─── 3. executeReal: no-op for every CallStyle enum value ────────────────
  group('executeReal — all CallStyle enum values — no service calls', () {
    for (final style in CallStyle.values) {
      test('CallStyle.${style.name} produces no calls', () async {
        final audio = FakeAudioService();
        final vibration = FakeVibrationService();
        final messaging = FakeMessagingService();
        final phone = FakePhoneService();
        final recording = FakeRecordingService();
        final flash = FakeFlashService();
        final screenFlash = FakeScreenFlashService();
        final services = buildServices(
          audio: audio,
          vibration: vibration,
          messaging: messaging,
          phone: phone,
          recording: recording,
          flash: flash,
          screenFlash: screenFlash,
        );
        final s = _step(config: FakeCallConfig(callStyle: style));
        await const FakeCallStrategy().executeReal(s, services);
        _assertAllServicesEmpty(
          audio: audio,
          vibration: vibration,
          messaging: messaging,
          phone: phone,
          recording: recording,
          flash: flash,
          screenFlash: screenFlash,
          reason: 'CallStyle.${style.name}',
        );
      });
    }
  });

  // ─── 4. executeReal: no-op for every VoiceOutputMode value ───────────────
  group('executeReal — all VoiceOutputMode enum values — no service calls', () {
    for (final mode in VoiceOutputMode.values) {
      test('VoiceOutputMode.${mode.name} produces no calls', () async {
        final audio = FakeAudioService();
        final phone = FakePhoneService();
        final services = buildServices(audio: audio, phone: phone);
        final s = _step(config: FakeCallConfig(voiceOutputMode: mode));
        await const FakeCallStrategy().executeReal(s, services);
        expect(audio.calls, isEmpty, reason: 'VoiceOutputMode.${mode.name}');
        expect(phone.calls, isEmpty, reason: 'VoiceOutputMode.${mode.name}');
      });
    }
  });

  // ─── 5. executeReal: no-op for declineIsSafe=true and declineIsSafe=false ─
  group('executeReal — declineIsSafe variations — no service calls', () {
    test('declineIsSafe=true produces no calls', () async {
      final audio = FakeAudioService();
      final messaging = FakeMessagingService();
      final services = buildServices(audio: audio, messaging: messaging);
      final s = _step(config: const FakeCallConfig());
      await const FakeCallStrategy().executeReal(s, services);
      expect(audio.calls, isEmpty, reason: 'declineIsSafe=true');
      expect(messaging.calls, isEmpty, reason: 'declineIsSafe=true');
    });

    test('declineIsSafe=false produces no calls', () async {
      final audio = FakeAudioService();
      final messaging = FakeMessagingService();
      final phone = FakePhoneService();
      final services = buildServices(
        audio: audio,
        messaging: messaging,
        phone: phone,
      );
      final s = _step(config: const FakeCallConfig(declineIsSafe: false));
      await const FakeCallStrategy().executeReal(s, services);
      expect(audio.calls, isEmpty, reason: 'declineIsSafe=false');
      expect(messaging.calls, isEmpty, reason: 'declineIsSafe=false');
      expect(phone.calls, isEmpty, reason: 'declineIsSafe=false');
    });
  });

  // ─── 6. executeReal: no-op at boundary ringDurationSeconds values ─────────
  group(
    'executeReal — boundary ringDurationSeconds values — no service calls',
    () {
      for (final seconds in [5, 30, 120]) {
        test('ringDurationSeconds=$seconds produces no calls', () async {
          final audio = FakeAudioService();
          final vibration = FakeVibrationService();
          final messaging = FakeMessagingService();
          final services = buildServices(
            audio: audio,
            vibration: vibration,
            messaging: messaging,
          );
          final s = _step(config: FakeCallConfig(ringDurationSeconds: seconds));
          await const FakeCallStrategy().executeReal(s, services);
          expect(audio.calls, isEmpty, reason: 'ringDurationSeconds=$seconds');
          expect(
            vibration.calls,
            isEmpty,
            reason: 'ringDurationSeconds=$seconds',
          );
          expect(
            messaging.calls,
            isEmpty,
            reason: 'ringDurationSeconds=$seconds',
          );
        });
      }
    },
  );

  // ─── 7. executeReal: no-op for voiceRecordingPath null and non-null ───────
  group('executeReal — voiceRecordingPath variations — no service calls', () {
    test('voiceRecordingPath=null produces no calls', () async {
      final audio = FakeAudioService();
      final recording = FakeRecordingService();
      final services = buildServices(audio: audio, recording: recording);
      final s = _step(config: const FakeCallConfig());
      await const FakeCallStrategy().executeReal(s, services);
      expect(audio.calls, isEmpty, reason: 'voiceRecordingPath=null');
      expect(recording.calls, isEmpty, reason: 'voiceRecordingPath=null');
    });

    test('voiceRecordingPath=custom path produces no calls', () async {
      final audio = FakeAudioService();
      final recording = FakeRecordingService();
      final services = buildServices(audio: audio, recording: recording);
      final s = _step(
        config: const FakeCallConfig(
          voiceRecordingPath: '/storage/emulated/0/angela_voice.aac',
        ),
      );
      await const FakeCallStrategy().executeReal(s, services);
      expect(audio.calls, isEmpty, reason: 'voiceRecordingPath=custom');
      expect(recording.calls, isEmpty, reason: 'voiceRecordingPath=custom');
    });

    test(
      'voiceRecordingPath=assets path produces no calls (all services)',
      () async {
        final audio = FakeAudioService();
        final vibration = FakeVibrationService();
        final messaging = FakeMessagingService();
        final phone = FakePhoneService();
        final recording = FakeRecordingService();
        final flash = FakeFlashService();
        final screenFlash = FakeScreenFlashService();
        final services = buildServices(
          audio: audio,
          vibration: vibration,
          messaging: messaging,
          phone: phone,
          recording: recording,
          flash: flash,
          screenFlash: screenFlash,
        );
        final s = _step(
          config: const FakeCallConfig(
            voiceRecordingPath: 'assets/audio/angela_en.aac',
            voiceOutputMode: VoiceOutputMode.speaker,
          ),
        );
        await const FakeCallStrategy().executeReal(s, services);
        _assertAllServicesEmpty(
          audio: audio,
          vibration: vibration,
          messaging: messaging,
          phone: phone,
          recording: recording,
          flash: flash,
          screenFlash: screenFlash,
          reason: 'voiceRecordingPath=assets path',
        );
      },
    );
  });

  // ─── 8. executeReal: no-op for callerName variations ─────────────────────
  group('executeReal — callerName variations — no service calls', () {
    test('callerName=default (Angela) produces no calls', () async {
      final audio = FakeAudioService();
      final messaging = FakeMessagingService();
      final services = buildServices(audio: audio, messaging: messaging);
      final s = _step(config: const FakeCallConfig());
      await const FakeCallStrategy().executeReal(s, services);
      expect(audio.calls, isEmpty, reason: 'callerName=Angela');
      expect(messaging.calls, isEmpty, reason: 'callerName=Angela');
    });

    test('callerName=custom string produces no calls', () async {
      final audio = FakeAudioService();
      final phone = FakePhoneService();
      final services = buildServices(audio: audio, phone: phone);
      final s = _step(config: const FakeCallConfig(callerName: 'Dr. Smith'));
      await const FakeCallStrategy().executeReal(s, services);
      expect(audio.calls, isEmpty, reason: 'callerName=Dr. Smith');
      expect(phone.calls, isEmpty, reason: 'callerName=Dr. Smith');
    });

    test('callerName=empty string produces no calls', () async {
      final audio = FakeAudioService();
      final vibration = FakeVibrationService();
      final services = buildServices(audio: audio, vibration: vibration);
      final s = _step(config: const FakeCallConfig(callerName: ''));
      await const FakeCallStrategy().executeReal(s, services);
      expect(audio.calls, isEmpty, reason: 'callerName=empty');
      expect(vibration.calls, isEmpty, reason: 'callerName=empty');
    });

    test('callerName=unicode / emoji produces no calls', () async {
      final audio = FakeAudioService();
      final services = buildServices(audio: audio);
      final s = _step(config: const FakeCallConfig(callerName: '🌸 母'));
      await const FakeCallStrategy().executeReal(s, services);
      expect(audio.calls, isEmpty, reason: 'callerName=unicode');
    });
  });

  // ─── 9. simulationDescription: returns null for default config ───────────
  group('simulationDescription — default config — returns null', () {
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
  });

  // ─── 10. simulationDescription: returns null for representative configs ───
  group('simulationDescription — representative config samples — all null', () {
    test('returns null for CallStyle.androidNative', () {
      final services = buildServices();
      final result = const FakeCallStrategy().simulationDescription(
        _step(config: const FakeCallConfig(callStyle: CallStyle.androidNative)),
        services,
      );
      expect(result, isNull);
    });

    test('returns null for CallStyle.iosNative', () {
      final services = buildServices();
      final result = const FakeCallStrategy().simulationDescription(
        _step(config: const FakeCallConfig(callStyle: CallStyle.iosNative)),
        services,
      );
      expect(result, isNull);
    });

    test('returns null for VoiceOutputMode.speaker + custom voicePath', () {
      final services = buildServices();
      final result = const FakeCallStrategy().simulationDescription(
        _step(
          config: const FakeCallConfig(
            voiceOutputMode: VoiceOutputMode.speaker,
            voiceRecordingPath: 'assets/audio/test.aac',
          ),
        ),
        services,
      );
      expect(result, isNull);
    });

    test('returns null for declineIsSafe=false + ringDurationSeconds=120', () {
      final services = buildServices();
      final result = const FakeCallStrategy().simulationDescription(
        _step(
          config: const FakeCallConfig(
            declineIsSafe: false,
            ringDurationSeconds: 120,
          ),
        ),
        services,
      );
      expect(result, isNull);
    });

    test('returns null for blackScreenMode=true', () {
      final services = buildServices();
      final result = const FakeCallStrategy().simulationDescription(
        _step(config: const FakeCallConfig(blackScreenMode: true)),
        services,
      );
      expect(result, isNull);
    });

    test('returns null for minimal style + callerName empty', () {
      final services = buildServices();
      final result = const FakeCallStrategy().simulationDescription(
        _step(
          config: const FakeCallConfig(
            callStyle: CallStyle.minimal,
            callerName: '',
          ),
        ),
        services,
      );
      expect(result, isNull);
    });
  });

  // ─── 11. simulationDescription: returns null when isSimulation=true ───────
  group('simulationDescription — isSimulation=true — still returns null', () {
    test('returns null with isSimulation=true and default config', () {
      final services = buildServices(isSimulation: true);
      final result = const FakeCallStrategy().simulationDescription(
        _step(config: const FakeCallConfig()),
        services,
      );
      expect(result, isNull);
    });

    test('returns null with isSimulation=true and null step.config', () {
      final services = buildServices(isSimulation: true);
      final result = const FakeCallStrategy().simulationDescription(
        _step(),
        services,
      );
      expect(result, isNull);
    });
  });

  // ─── 12. Null config — graceful handling ─────────────────────────────────
  group('null step.config — graceful handling', () {
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

    test('no service calls when config is null', () async {
      final audio = FakeAudioService();
      final vibration = FakeVibrationService();
      final messaging = FakeMessagingService();
      final phone = FakePhoneService();
      final recording = FakeRecordingService();
      final flash = FakeFlashService();
      final screenFlash = FakeScreenFlashService();
      final services = buildServices(
        audio: audio,
        vibration: vibration,
        messaging: messaging,
        phone: phone,
        recording: recording,
        flash: flash,
        screenFlash: screenFlash,
      );
      await const FakeCallStrategy().executeReal(_step(), services);
      _assertAllServicesEmpty(
        audio: audio,
        vibration: vibration,
        messaging: messaging,
        phone: phone,
        recording: recording,
        flash: flash,
        screenFlash: screenFlash,
        reason: 'null step.config',
      );
    });

    test('simulationDescription returns null when config is null', () {
      final services = buildServices();
      final result = const FakeCallStrategy().simulationDescription(
        _step(),
        services,
      );
      expect(result, isNull);
    });

    test(
      'executeReal with null config and isSimulation=true still no-ops',
      () async {
        final audio = FakeAudioService();
        final services = buildServices(audio: audio, isSimulation: true);
        await const FakeCallStrategy().executeReal(_step(), services);
        expect(audio.calls, isEmpty);
      },
    );
  });

  // ─── 13. Const-ness ───────────────────────────────────────────────────────
  group('const constructor — identity', () {
    test('two FakeCallStrategy() instances are identical (const)', () {
      const a = FakeCallStrategy();
      const b = FakeCallStrategy();
      expect(identical(a, b), isTrue);
    });

    test('FakeCallStrategy() is the same instance as const literal', () {
      const strategy = FakeCallStrategy();
      expect(strategy, isA<FakeCallStrategy>());
    });
  });

  // ─── 14. declineWithDistressHoldSeconds boundary values ──────────────────
  //
  // Spec ref: docs/spec/02-event-types.md §5 fakeCall.
  // This field controls how long the user must hold the Decline button to
  // trigger the distress chain. It is a UI-only concern; FakeCallStrategy
  // is a no-op regardless of its value (Pivot 2 / R-1).
  group('executeReal — declineWithDistressHoldSeconds boundary values', () {
    test(
      'declineWithDistressHoldSeconds=0 — all 7 service fakes are empty',
      () async {
        final audio = FakeAudioService();
        final vibration = FakeVibrationService();
        final messaging = FakeMessagingService();
        final phone = FakePhoneService();
        final recording = FakeRecordingService();
        final flash = FakeFlashService();
        final screenFlash = FakeScreenFlashService();
        final services = buildServices(
          audio: audio,
          vibration: vibration,
          messaging: messaging,
          phone: phone,
          recording: recording,
          flash: flash,
          screenFlash: screenFlash,
        );
        final s = _step(
          config: const FakeCallConfig(declineWithDistressHoldSeconds: 0),
        );
        await const FakeCallStrategy().executeReal(s, services);
        _assertAllServicesEmpty(
          audio: audio,
          vibration: vibration,
          messaging: messaging,
          phone: phone,
          recording: recording,
          flash: flash,
          screenFlash: screenFlash,
          reason: 'declineWithDistressHoldSeconds=0',
        );
      },
    );

    test(
      'declineWithDistressHoldSeconds=10 — all 7 service fakes are empty',
      () async {
        final audio = FakeAudioService();
        final vibration = FakeVibrationService();
        final messaging = FakeMessagingService();
        final phone = FakePhoneService();
        final recording = FakeRecordingService();
        final flash = FakeFlashService();
        final screenFlash = FakeScreenFlashService();
        final services = buildServices(
          audio: audio,
          vibration: vibration,
          messaging: messaging,
          phone: phone,
          recording: recording,
          flash: flash,
          screenFlash: screenFlash,
        );
        final s = _step(
          config: const FakeCallConfig(declineWithDistressHoldSeconds: 10),
        );
        await const FakeCallStrategy().executeReal(s, services);
        _assertAllServicesEmpty(
          audio: audio,
          vibration: vibration,
          messaging: messaging,
          phone: phone,
          recording: recording,
          flash: flash,
          screenFlash: screenFlash,
          reason: 'declineWithDistressHoldSeconds=10',
        );
      },
    );
  });
}
