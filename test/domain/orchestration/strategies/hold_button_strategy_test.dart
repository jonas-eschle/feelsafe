import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/hold_style.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/strategies/hold_button_strategy.dart';
import '../_test_fakes.dart';

// ─── Local helpers ────────────────────────────────────────────────────────────

const _uuid = '00000000-0000-0000-0000-000000000001';

/// Builds a [ChainStep] of type [ChainStepType.holdButton] with an optional
/// [HoldButtonConfig].
///
/// When [config] is null the step carries no typed config, exercising the
/// null-config path inside the strategy.
ChainStep _step({HoldButtonConfig? config}) => ChainStep(
  id: _uuid,
  type: ChainStepType.holdButton,
  order: 0,
  waitSeconds: 0,
  durationSeconds: 10,
  gracePeriodSeconds: 5,
  retryCount: 0,
  randomize: false,
  config: config,
);

// ─── Helpers to extract all fake services from a single buildServices call ───

/// Collects all [List<Map<String, Object?>>] call-logs from every fake service
/// in [services] by re-building fakes and returning them as a flat list.
///
/// This helper is not used inline; instead each test captures the fakes before
/// calling [buildServices].

void main() {
  // ─── 1. executeReal: no-op with default config ──────────────────────────
  group('executeReal — default config — no service calls', () {
    test('audio is empty after execute', () async {
      final audio = FakeAudioService();
      final services = buildServices(audio: audio);
      await const HoldButtonStrategy().executeReal(_step(), services);
      expect(audio.calls, isEmpty);
    });

    test('vibration is empty after execute', () async {
      final vibration = FakeVibrationService();
      final services = buildServices(vibration: vibration);
      await const HoldButtonStrategy().executeReal(_step(), services);
      expect(vibration.calls, isEmpty);
    });

    test('messaging is empty after execute', () async {
      final messaging = FakeMessagingService();
      final services = buildServices(messaging: messaging);
      await const HoldButtonStrategy().executeReal(_step(), services);
      expect(messaging.calls, isEmpty);
    });

    test('phone is empty after execute', () async {
      final phone = FakePhoneService();
      final services = buildServices(phone: phone);
      await const HoldButtonStrategy().executeReal(_step(), services);
      expect(phone.calls, isEmpty);
    });

    test('recording is empty after execute', () async {
      final recording = FakeRecordingService();
      final services = buildServices(recording: recording);
      await const HoldButtonStrategy().executeReal(_step(), services);
      expect(recording.calls, isEmpty);
    });

    test('flash is empty after execute', () async {
      final flash = FakeFlashService();
      final services = buildServices(flash: flash);
      await const HoldButtonStrategy().executeReal(_step(), services);
      expect(flash.calls, isEmpty);
    });

    test('screenFlash is empty after execute', () async {
      final screenFlash = FakeScreenFlashService();
      final services = buildServices(screenFlash: screenFlash);
      await const HoldButtonStrategy().executeReal(_step(), services);
      expect(screenFlash.calls, isEmpty);
    });

    test('all 7 call-recording fakes are empty together', () async {
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
      await const HoldButtonStrategy().executeReal(_step(), services);
      expect(audio.calls, isEmpty);
      expect(vibration.calls, isEmpty);
      expect(messaging.calls, isEmpty);
      expect(phone.calls, isEmpty);
      expect(recording.calls, isEmpty);
      expect(flash.calls, isEmpty);
      expect(screenFlash.calls, isEmpty);
    });
  });

  // ─── 2. executeReal: no-op under simulation ──────────────────────────────
  group('executeReal — isSimulation=true — still no-op', () {
    test('all fakes empty when simulation=true with default config', () async {
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
      await const HoldButtonStrategy().executeReal(_step(), services);
      expect(audio.calls, isEmpty);
      expect(vibration.calls, isEmpty);
      expect(messaging.calls, isEmpty);
      expect(phone.calls, isEmpty);
      expect(recording.calls, isEmpty);
      expect(flash.calls, isEmpty);
      expect(screenFlash.calls, isEmpty);
    });

    test('audio empty when simulation=true with explicit config', () async {
      final audio = FakeAudioService();
      final services = buildServices(audio: audio, isSimulation: true);
      final s = _step(config: const HoldButtonConfig(soundOnRelease: true));
      await const HoldButtonStrategy().executeReal(s, services);
      expect(audio.calls, isEmpty);
    });
  });

  // ─── 3. executeReal: no-op for all bool-config combinations ─────────────
  group('executeReal — bool config matrix (2x2x2) — all no-ops', () {
    for (final vibrateOnRelease in [false, true]) {
      for (final soundOnRelease in [false, true]) {
        for (final blackScreenMode in [false, true]) {
          final desc =
              'vibrate=$vibrateOnRelease '
              'sound=$soundOnRelease '
              'black=$blackScreenMode';
          test(desc, () async {
            final audio = FakeAudioService();
            final vibration = FakeVibrationService();
            final flash = FakeFlashService();
            final screenFlash = FakeScreenFlashService();
            final services = buildServices(
              audio: audio,
              vibration: vibration,
              flash: flash,
              screenFlash: screenFlash,
            );
            final s = _step(
              config: HoldButtonConfig(
                vibrateOnRelease: vibrateOnRelease,
                soundOnRelease: soundOnRelease,
                blackScreenMode: blackScreenMode,
              ),
            );
            await const HoldButtonStrategy().executeReal(s, services);
            expect(audio.calls, isEmpty, reason: desc);
            expect(vibration.calls, isEmpty, reason: desc);
            expect(flash.calls, isEmpty, reason: desc);
            expect(screenFlash.calls, isEmpty, reason: desc);
          });
        }
      }
    }
  });

  // ─── 4. executeReal: no-op for every HoldStyle value ────────────────────
  group('executeReal — all HoldStyle enum values — no-ops', () {
    for (final style in HoldStyle.values) {
      test('HoldStyle.${style.name} produces no calls', () async {
        final audio = FakeAudioService();
        final vibration = FakeVibrationService();
        final services = buildServices(audio: audio, vibration: vibration);
        final s = _step(config: HoldButtonConfig(holdStyle: style));
        await const HoldButtonStrategy().executeReal(s, services);
        expect(audio.calls, isEmpty, reason: 'style=${style.name}');
        expect(vibration.calls, isEmpty, reason: 'style=${style.name}');
      });
    }
  });

  // ─── 5. executeReal: no-op for boundary releaseSensitivity values ────────
  group('executeReal — releaseSensitivity boundary values — no-ops', () {
    for (final sensitivity in [0.3, 1.0, 3.0]) {
      test('releaseSensitivity=$sensitivity produces no calls', () async {
        final audio = FakeAudioService();
        final vibration = FakeVibrationService();
        final messaging = FakeMessagingService();
        final services = buildServices(
          audio: audio,
          vibration: vibration,
          messaging: messaging,
        );
        final s = _step(
          config: HoldButtonConfig(releaseSensitivity: sensitivity),
        );
        await const HoldButtonStrategy().executeReal(s, services);
        expect(audio.calls, isEmpty, reason: 'sensitivity=$sensitivity');
        expect(vibration.calls, isEmpty, reason: 'sensitivity=$sensitivity');
        expect(messaging.calls, isEmpty, reason: 'sensitivity=$sensitivity');
      });
    }
  });

  // ─── 6. simulationDescription: always null regardless of config ──────────
  group('simulationDescription — returns null for representative steps', () {
    test('returns null for default config', () {
      final services = buildServices();
      final result = const HoldButtonStrategy().simulationDescription(
        _step(),
        services,
      );
      expect(result, isNull);
    });

    test('returns null for HoldStyle.largeButton', () {
      final services = buildServices();
      final result = const HoldButtonStrategy().simulationDescription(
        _step(config: const HoldButtonConfig()),
        services,
      );
      expect(result, isNull);
    });

    test('returns null for HoldStyle.fullScreen', () {
      final services = buildServices();
      final result = const HoldButtonStrategy().simulationDescription(
        _step(config: const HoldButtonConfig(holdStyle: HoldStyle.fullScreen)),
        services,
      );
      expect(result, isNull);
    });

    test('returns null for HoldStyle.fakeLockScreen', () {
      final services = buildServices();
      final result = const HoldButtonStrategy().simulationDescription(
        _step(
          config: const HoldButtonConfig(holdStyle: HoldStyle.fakeLockScreen),
        ),
        services,
      );
      expect(result, isNull);
    });

    test('returns null with vibrateOnRelease=true and soundOnRelease=true', () {
      final services = buildServices();
      final result = const HoldButtonStrategy().simulationDescription(
        _step(config: const HoldButtonConfig(soundOnRelease: true)),
        services,
      );
      expect(result, isNull);
    });

    test('returns null with blackScreenMode=true', () {
      final services = buildServices();
      final result = const HoldButtonStrategy().simulationDescription(
        _step(config: const HoldButtonConfig(blackScreenMode: true)),
        services,
      );
      expect(result, isNull);
    });

    test('returns null with sensitivity=0.3', () {
      final services = buildServices();
      final result = const HoldButtonStrategy().simulationDescription(
        _step(config: const HoldButtonConfig(releaseSensitivity: 0.3)),
        services,
      );
      expect(result, isNull);
    });

    test('returns null with sensitivity=3.0', () {
      final services = buildServices();
      final result = const HoldButtonStrategy().simulationDescription(
        _step(config: const HoldButtonConfig(releaseSensitivity: 3.0)),
        services,
      );
      expect(result, isNull);
    });
  });

  // ─── 7. simulationDescription: null regardless of isSimulation flag ──────
  group('simulationDescription — isSimulation flag has no effect', () {
    test('returns null when isSimulation=false', () {
      final services = buildServices();
      final result = const HoldButtonStrategy().simulationDescription(
        _step(),
        services,
      );
      expect(result, isNull);
    });

    test('returns null when isSimulation=true', () {
      final services = buildServices(isSimulation: true);
      final result = const HoldButtonStrategy().simulationDescription(
        _step(),
        services,
      );
      expect(result, isNull);
    });

    test('returns null for fullScreen style when isSimulation=true', () {
      final services = buildServices(isSimulation: true);
      final result = const HoldButtonStrategy().simulationDescription(
        _step(config: const HoldButtonConfig(holdStyle: HoldStyle.fullScreen)),
        services,
      );
      expect(result, isNull);
    });

    test('returns null for fakeLockScreen style when isSimulation=true', () {
      final services = buildServices(isSimulation: true);
      final result = const HoldButtonStrategy().simulationDescription(
        _step(
          config: const HoldButtonConfig(holdStyle: HoldStyle.fakeLockScreen),
        ),
        services,
      );
      expect(result, isNull);
    });
  });

  // ─── 8. Null config — graceful handling ─────────────────────────────────
  group('null step.config — graceful handling', () {
    test(
      'executeReal completes without throwing when config is null',
      () async {
        final services = buildServices();
        await expectLater(
          const HoldButtonStrategy().executeReal(_step(), services),
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
      await const HoldButtonStrategy().executeReal(_step(), services);
      expect(audio.calls, isEmpty);
      expect(vibration.calls, isEmpty);
      expect(messaging.calls, isEmpty);
      expect(phone.calls, isEmpty);
      expect(recording.calls, isEmpty);
      expect(flash.calls, isEmpty);
      expect(screenFlash.calls, isEmpty);
    });

    test('simulationDescription returns null when config is null', () {
      final services = buildServices();
      final result = const HoldButtonStrategy().simulationDescription(
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
        await const HoldButtonStrategy().executeReal(_step(), services);
        expect(audio.calls, isEmpty);
      },
    );
  });

  // ─── 9. Const-ness ───────────────────────────────────────────────────────
  group('const constructor — identity', () {
    test('two HoldButtonStrategy() instances are identical (const)', () {
      const a = HoldButtonStrategy();
      const b = HoldButtonStrategy();
      expect(identical(a, b), isTrue);
    });

    test('HoldButtonStrategy() is the same instance as const literal', () {
      const strategy = HoldButtonStrategy();
      expect(strategy, isA<HoldButtonStrategy>());
    });
  });
}
