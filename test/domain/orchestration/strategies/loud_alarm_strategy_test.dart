import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/loud_alarm_sound.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/strategies/loud_alarm_strategy.dart';
import 'package:guardianangela/services/protocols/audio_service_protocol.dart';
import 'package:guardianangela/services/protocols/vibration_service_protocol.dart';
import '../_test_fakes.dart';

// ─── Local helpers ─────────────────────────────────────────────────────────────

const _uuid = '00000000-0000-0000-0000-000000000007';

/// Builds a [ChainStep] of type [ChainStepType.loudAlarm] with an optional
/// [LoudAlarmConfig].
///
/// When [config] is null the step carries no typed config, exercising the
/// null-config fallback inside the strategy (uses [LoudAlarmConfig] defaults).
ChainStep _step({LoudAlarmConfig? config}) => ChainStep(
  id: _uuid,
  type: ChainStepType.loudAlarm,
  order: 0,
  waitSeconds: 0,
  durationSeconds: 30,
  gracePeriodSeconds: 5,
  retryCount: 0,
  randomize: false,
  config: config,
);

void main() {
  // ─── 1. Sim guard — isSimulation=true ─────────────────────────────────────
  group('executeReal — Layer 2 sim guard, isSimulation=true', () {
    test('vibration.calls is empty when isSimulation=true', () async {
      final vibration = FakeVibrationService();
      final services = buildServices(vibration: vibration, isSimulation: true);
      await const LoudAlarmStrategy().executeReal(
        _step(config: const LoudAlarmConfig()),
        services,
      );
      expect(vibration.calls, isEmpty);
    });

    test('audio.calls is empty when isSimulation=true', () async {
      final audio = FakeAudioService();
      final services = buildServices(audio: audio, isSimulation: true);
      await const LoudAlarmStrategy().executeReal(
        _step(config: const LoudAlarmConfig()),
        services,
      );
      expect(audio.calls, isEmpty);
    });

    test('flash.calls is empty when isSimulation=true', () async {
      final flash = FakeFlashService();
      final services = buildServices(flash: flash, isSimulation: true);
      await const LoudAlarmStrategy().executeReal(
        _step(config: const LoudAlarmConfig()),
        services,
      );
      expect(flash.calls, isEmpty);
    });

    test(
      'screenFlash.calls empty when isSimulation=true even with flashScreen=true',
      () async {
        final screenFlash = FakeScreenFlashService();
        final services = buildServices(
          screenFlash: screenFlash,
          isSimulation: true,
        );
        await const LoudAlarmStrategy().executeReal(
          _step(config: const LoudAlarmConfig(flashScreen: true)),
          services,
        );
        expect(screenFlash.calls, isEmpty);
      },
    );

    test('all service calls empty when isSimulation=true', () async {
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
      await const LoudAlarmStrategy().executeReal(
        _step(config: const LoudAlarmConfig()),
        services,
      );
      expect(audio.calls, isEmpty);
      expect(vibration.calls, isEmpty);
      expect(messaging.calls, isEmpty);
      expect(phone.calls, isEmpty);
      expect(recording.calls, isEmpty);
      expect(flash.calls, isEmpty);
      expect(screenFlash.calls, isEmpty);
    });
  });

  // ─── 2. Vibration — unconditional ─────────────────────────────────────────
  group('executeReal — vibration.alarmPattern is unconditional', () {
    test('default config produces exactly one vibration call', () async {
      final vibration = FakeVibrationService();
      final services = buildServices(vibration: vibration);
      await const LoudAlarmStrategy().executeReal(
        _step(config: const LoudAlarmConfig()),
        services,
      );
      expect(vibration.calls, hasLength(1));
      expect(vibration.calls.first['method'], equals('alarmPattern'));
    });

    test(
      'flashLight=false + flashScreen=false still fires one vibration call',
      () async {
        final vibration = FakeVibrationService();
        final services = buildServices(vibration: vibration);
        await const LoudAlarmStrategy().executeReal(
          _step(config: const LoudAlarmConfig(flashLight: false)),
          services,
        );
        expect(vibration.calls, hasLength(1));
        expect(vibration.calls.first['method'], equals('alarmPattern'));
      },
    );

    test('volume=0.0 config still fires one vibration call', () async {
      final vibration = FakeVibrationService();
      final services = buildServices(vibration: vibration);
      await const LoudAlarmStrategy().executeReal(
        _step(config: const LoudAlarmConfig(volume: 0.0)),
        services,
      );
      expect(vibration.calls, hasLength(1));
      expect(vibration.calls.first['method'], equals('alarmPattern'));
    });

    test(
      'soundChoice=custom + flashScreen=true still fires exactly one vibration call',
      () async {
        final vibration = FakeVibrationService();
        final services = buildServices(vibration: vibration);
        await const LoudAlarmStrategy().executeReal(
          _step(
            config: const LoudAlarmConfig(
              soundChoice: LoudAlarmSound.custom,
              flashScreen: true,
            ),
          ),
          services,
        );
        expect(vibration.calls, hasLength(1));
        expect(vibration.calls.first['method'], equals('alarmPattern'));
      },
    );

    test('gradualVolume=true still fires exactly one vibration call', () async {
      final vibration = FakeVibrationService();
      final services = buildServices(vibration: vibration);
      await const LoudAlarmStrategy().executeReal(
        _step(config: const LoudAlarmConfig(gradualVolume: true)),
        services,
      );
      expect(vibration.calls, hasLength(1));
      expect(vibration.calls.first['method'], equals('alarmPattern'));
    });

    test(
      'null config still fires one vibration call (fallback to defaults)',
      () async {
        final vibration = FakeVibrationService();
        final services = buildServices(vibration: vibration);
        await const LoudAlarmStrategy().executeReal(_step(), services);
        expect(vibration.calls, hasLength(1));
        expect(vibration.calls.first['method'], equals('alarmPattern'));
      },
    );
  });

  // ─── 3. Audio — unconditional ──────────────────────────────────────────────
  group('executeReal — audio.playAlarmWithConfig is unconditional', () {
    test('default config produces exactly one audio call', () async {
      final audio = FakeAudioService();
      final services = buildServices(audio: audio);
      await const LoudAlarmStrategy().executeReal(
        _step(config: const LoudAlarmConfig()),
        services,
      );
      expect(audio.calls, hasLength(1));
      expect(audio.calls.first['method'], equals('playAlarmWithConfig'));
    });

    test('default config audio call has soundChoice=siren', () async {
      final audio = FakeAudioService();
      final services = buildServices(audio: audio);
      await const LoudAlarmStrategy().executeReal(
        _step(config: const LoudAlarmConfig()),
        services,
      );
      expect(audio.calls.first['soundChoice'], equals('siren'));
    });

    test('default config audio call has volume=1.0', () async {
      final audio = FakeAudioService();
      final services = buildServices(audio: audio);
      await const LoudAlarmStrategy().executeReal(
        _step(config: const LoudAlarmConfig()),
        services,
      );
      expect(audio.calls.first['volume'], equals(1.0));
    });

    test('default config audio call has isSimulation=false', () async {
      final audio = FakeAudioService();
      final services = buildServices(audio: audio);
      await const LoudAlarmStrategy().executeReal(
        _step(config: const LoudAlarmConfig()),
        services,
      );
      expect(audio.calls.first['isSimulation'], isFalse);
    });

    test('default config audio call has customSoundPath=null', () async {
      final audio = FakeAudioService();
      final services = buildServices(audio: audio);
      await const LoudAlarmStrategy().executeReal(
        _step(config: const LoudAlarmConfig()),
        services,
      );
      expect(audio.calls.first['customSoundPath'], isNull);
    });

    test('volume=0.5 is forwarded to the audio call', () async {
      final audio = FakeAudioService();
      final services = buildServices(audio: audio);
      await const LoudAlarmStrategy().executeReal(
        _step(config: const LoudAlarmConfig(volume: 0.5)),
        services,
      );
      expect(audio.calls, hasLength(1));
      expect(audio.calls.first['volume'], equals(0.5));
    });

    test(
      'volume=0.0 (lower boundary) is forwarded to the audio call',
      () async {
        final audio = FakeAudioService();
        final services = buildServices(audio: audio);
        await const LoudAlarmStrategy().executeReal(
          _step(config: const LoudAlarmConfig(volume: 0.0)),
          services,
        );
        expect(audio.calls, hasLength(1));
        expect(audio.calls.first['volume'], equals(0.0));
      },
    );

    test(
      'volume=1.0 (default / upper boundary) is preserved in audio call',
      () async {
        final audio = FakeAudioService();
        final services = buildServices(audio: audio);
        await const LoudAlarmStrategy().executeReal(
          _step(config: const LoudAlarmConfig()),
          services,
        );
        expect(audio.calls, hasLength(1));
        expect(audio.calls.first['volume'], equals(1.0));
      },
    );

    test(
      'soundChoice=LoudAlarmSound.custom forwards soundChoice=custom',
      () async {
        final audio = FakeAudioService();
        final services = buildServices(audio: audio);
        await const LoudAlarmStrategy().executeReal(
          _step(
            config: const LoudAlarmConfig(soundChoice: LoudAlarmSound.custom),
          ),
          services,
        );
        expect(audio.calls, hasLength(1));
        expect(audio.calls.first['soundChoice'], equals('custom'));
      },
    );

    test(
      'soundChoice=LoudAlarmSound.siren forwards soundChoice=siren',
      () async {
        final audio = FakeAudioService();
        final services = buildServices(audio: audio);
        await const LoudAlarmStrategy().executeReal(
          _step(config: const LoudAlarmConfig()),
          services,
        );
        expect(audio.calls, hasLength(1));
        expect(audio.calls.first['soundChoice'], equals('siren'));
      },
    );

    test('null config fires audio with default soundChoice=siren', () async {
      final audio = FakeAudioService();
      final services = buildServices(audio: audio);
      await const LoudAlarmStrategy().executeReal(_step(), services);
      expect(audio.calls, hasLength(1));
      expect(audio.calls.first['soundChoice'], equals('siren'));
    });

    test('null config fires audio with default volume=1.0', () async {
      final audio = FakeAudioService();
      final services = buildServices(audio: audio);
      await const LoudAlarmStrategy().executeReal(_step(), services);
      expect(audio.calls.first['volume'], equals(1.0));
    });
  });

  // ─── 4. gradualVolume — audio call parameters are unchanged ───────────────
  group(
    'executeReal — gradualVolume does not change audio call parameters',
    () {
      test(
        'gradualVolume=true has identical audio params to gradualVolume=false',
        () async {
          final audioTrue = FakeAudioService();
          final audioFalse = FakeAudioService();

          await const LoudAlarmStrategy().executeReal(
            _step(config: const LoudAlarmConfig(gradualVolume: true)),
            buildServices(audio: audioTrue),
          );
          await const LoudAlarmStrategy().executeReal(
            _step(config: const LoudAlarmConfig()),
            buildServices(audio: audioFalse),
          );

          expect(
            audioTrue.calls.first['soundChoice'],
            equals(audioFalse.calls.first['soundChoice']),
          );
          expect(
            audioTrue.calls.first['volume'],
            equals(audioFalse.calls.first['volume']),
          );
          expect(
            audioTrue.calls.first['isSimulation'],
            equals(audioFalse.calls.first['isSimulation']),
          );
        },
      );

      test('gradualVolume=true audio call has isSimulation=false', () async {
        final audio = FakeAudioService();
        final services = buildServices(audio: audio);
        await const LoudAlarmStrategy().executeReal(
          _step(config: const LoudAlarmConfig(gradualVolume: true)),
          services,
        );
        expect(audio.calls.first['isSimulation'], isFalse);
      });
    },
  );

  // ─── 5. flashLight — conditional camera flash ──────────────────────────────
  group('executeReal — flashLight conditional behavior', () {
    test(
      'flashLight=true (default) fires one flash.startSosFlash call',
      () async {
        final flash = FakeFlashService();
        final services = buildServices(flash: flash);
        await const LoudAlarmStrategy().executeReal(
          _step(config: const LoudAlarmConfig()),
          services,
        );
        expect(flash.calls, hasLength(1));
        expect(flash.calls.first['method'], equals('startSosFlash'));
      },
    );

    test('flashLight=false produces no flash calls', () async {
      final flash = FakeFlashService();
      final services = buildServices(flash: flash);
      await const LoudAlarmStrategy().executeReal(
        _step(config: const LoudAlarmConfig(flashLight: false)),
        services,
      );
      expect(flash.calls, isEmpty);
    });

    test(
      'null config uses default flashLight=true, fires one flash call',
      () async {
        final flash = FakeFlashService();
        final services = buildServices(flash: flash);
        await const LoudAlarmStrategy().executeReal(_step(), services);
        expect(flash.calls, hasLength(1));
        expect(flash.calls.first['method'], equals('startSosFlash'));
      },
    );
  });

  // ─── 6. flashScreen — conditional screen flash + speed mapping ─────────────
  //
  // Speed rule confirmed from source (loud_alarm_strategy.dart line 60):
  //   config.flashSpeedMs >= 1000  →  speed = 'slow'  (photosensitivity-safe)
  //   config.flashSpeedMs <  1000  →  speed = 'fast'  (more attention-grabbing)
  group('executeReal — flashScreen conditional behavior and speed mapping', () {
    test('flashScreen=false (default) produces no screenFlash calls', () async {
      final screenFlash = FakeScreenFlashService();
      final services = buildServices(screenFlash: screenFlash);
      await const LoudAlarmStrategy().executeReal(
        _step(config: const LoudAlarmConfig()),
        services,
      );
      expect(screenFlash.calls, isEmpty);
    });

    test('flashScreen=true, flashSpeedMs=500 (<1000) → speed=fast', () async {
      final screenFlash = FakeScreenFlashService();
      final services = buildServices(screenFlash: screenFlash);
      await const LoudAlarmStrategy().executeReal(
        _step(config: const LoudAlarmConfig(flashScreen: true)),
        services,
      );
      expect(screenFlash.calls, hasLength(1));
      expect(screenFlash.calls.first['method'], equals('startScreenFlash'));
      expect(screenFlash.calls.first['speed'], equals('fast'));
    });

    test(
      'flashScreen=true, flashSpeedMs=1000 (>=1000 exact boundary) → speed=slow',
      () async {
        final screenFlash = FakeScreenFlashService();
        final services = buildServices(screenFlash: screenFlash);
        await const LoudAlarmStrategy().executeReal(
          _step(
            config: const LoudAlarmConfig(
              flashScreen: true,
              flashSpeedMs: 1000,
            ),
          ),
          services,
        );
        expect(screenFlash.calls, hasLength(1));
        expect(screenFlash.calls.first['speed'], equals('slow'));
      },
    );

    test('flashScreen=true, flashSpeedMs=300 (<1000) → speed=fast', () async {
      final screenFlash = FakeScreenFlashService();
      final services = buildServices(screenFlash: screenFlash);
      await const LoudAlarmStrategy().executeReal(
        _step(
          config: const LoudAlarmConfig(flashScreen: true, flashSpeedMs: 300),
        ),
        services,
      );
      expect(screenFlash.calls, hasLength(1));
      expect(screenFlash.calls.first['speed'], equals('fast'));
    });

    test(
      'flashScreen=true, flashSpeedMs=999 (boundary-1, <1000) → speed=fast',
      () async {
        final screenFlash = FakeScreenFlashService();
        final services = buildServices(screenFlash: screenFlash);
        await const LoudAlarmStrategy().executeReal(
          _step(
            config: const LoudAlarmConfig(flashScreen: true, flashSpeedMs: 999),
          ),
          services,
        );
        expect(screenFlash.calls, hasLength(1));
        expect(screenFlash.calls.first['speed'], equals('fast'));
      },
    );

    test('flashScreen=true, flashSpeedMs=2000 (>1000) → speed=slow', () async {
      final screenFlash = FakeScreenFlashService();
      final services = buildServices(screenFlash: screenFlash);
      await const LoudAlarmStrategy().executeReal(
        _step(
          config: const LoudAlarmConfig(flashScreen: true, flashSpeedMs: 2000),
        ),
        services,
      );
      expect(screenFlash.calls, hasLength(1));
      expect(screenFlash.calls.first['speed'], equals('slow'));
    });

    test(
      'null config uses flashScreen=false default, no screenFlash calls',
      () async {
        final screenFlash = FakeScreenFlashService();
        final services = buildServices(screenFlash: screenFlash);
        await const LoudAlarmStrategy().executeReal(_step(), services);
        expect(screenFlash.calls, isEmpty);
      },
    );
  });

  // ─── 7. No unexpected service calls ───────────────────────────────────────
  group('executeReal — no unexpected service calls', () {
    test('messaging, phone, recording are empty for default config', () async {
      final messaging = FakeMessagingService();
      final phone = FakePhoneService();
      final recording = FakeRecordingService();
      final services = buildServices(
        messaging: messaging,
        phone: phone,
        recording: recording,
      );
      await const LoudAlarmStrategy().executeReal(
        _step(config: const LoudAlarmConfig()),
        services,
      );
      expect(messaging.calls, isEmpty);
      expect(phone.calls, isEmpty);
      expect(recording.calls, isEmpty);
    });

    test(
      'messaging, phone, recording empty with all optional features enabled',
      () async {
        final messaging = FakeMessagingService();
        final phone = FakePhoneService();
        final recording = FakeRecordingService();
        final services = buildServices(
          messaging: messaging,
          phone: phone,
          recording: recording,
        );
        await const LoudAlarmStrategy().executeReal(
          _step(
            config: const LoudAlarmConfig(
              flashScreen: true,
              gradualVolume: true,
            ),
          ),
          services,
        );
        expect(messaging.calls, isEmpty);
        expect(phone.calls, isEmpty);
        expect(recording.calls, isEmpty);
      },
    );

    test('no stopFlash call in any real scenario (only start fires)', () async {
      final flash = FakeFlashService();
      final services = buildServices(flash: flash);
      await const LoudAlarmStrategy().executeReal(
        _step(config: const LoudAlarmConfig()),
        services,
      );
      expect(
        flash.calls.where((c) => c['method'] == 'stopFlash').toList(),
        isEmpty,
      );
    });

    test(
      'no stopScreenFlash call when flashScreen=true (only start fires)',
      () async {
        final screenFlash = FakeScreenFlashService();
        final services = buildServices(screenFlash: screenFlash);
        await const LoudAlarmStrategy().executeReal(
          _step(config: const LoudAlarmConfig(flashScreen: true)),
          services,
        );
        expect(
          screenFlash.calls
              .where((c) => c['method'] == 'stopScreenFlash')
              .toList(),
          isEmpty,
        );
      },
    );
  });

  // ─── 8. simulationDescription ─────────────────────────────────────────────
  group('simulationDescription', () {
    test('returns expected string for default config', () {
      final services = buildServices();
      final result = const LoudAlarmStrategy().simulationDescription(
        _step(config: const LoudAlarmConfig()),
        services,
      );
      expect(result, equals('Alarm would have sounded at full volume'));
    });

    test('returns the same string when step.config is null', () {
      final services = buildServices();
      final result = const LoudAlarmStrategy().simulationDescription(
        _step(),
        services,
      );
      expect(result, equals('Alarm would have sounded at full volume'));
    });

    test('returns the same string when isSimulation=false (default)', () {
      final services = buildServices();
      final result = const LoudAlarmStrategy().simulationDescription(
        _step(config: const LoudAlarmConfig()),
        services,
      );
      expect(result, equals('Alarm would have sounded at full volume'));
    });

    test('returns the same string when isSimulation=true', () {
      final services = buildServices(isSimulation: true);
      final result = const LoudAlarmStrategy().simulationDescription(
        _step(config: const LoudAlarmConfig()),
        services,
      );
      expect(result, equals('Alarm would have sounded at full volume'));
    });

    test('returns the same string with flashLight=false, flashScreen=true', () {
      final services = buildServices();
      final result = const LoudAlarmStrategy().simulationDescription(
        _step(
          config: const LoudAlarmConfig(flashLight: false, flashScreen: true),
        ),
        services,
      );
      expect(result, equals('Alarm would have sounded at full volume'));
    });

    test('returns the same string with volume=0.0 and soundChoice=custom', () {
      final services = buildServices();
      final result = const LoudAlarmStrategy().simulationDescription(
        _step(
          config: const LoudAlarmConfig(
            volume: 0.0,
            soundChoice: LoudAlarmSound.custom,
          ),
        ),
        services,
      );
      expect(result, equals('Alarm would have sounded at full volume'));
    });

    test('returns the same string with gradualVolume=true', () {
      final services = buildServices();
      final result = const LoudAlarmStrategy().simulationDescription(
        _step(config: const LoudAlarmConfig(gradualVolume: true)),
        services,
      );
      expect(result, equals('Alarm would have sounded at full volume'));
    });

    test('returns the same string with blackScreenMode=true', () {
      final services = buildServices();
      final result = const LoudAlarmStrategy().simulationDescription(
        _step(config: const LoudAlarmConfig(blackScreenMode: true)),
        services,
      );
      expect(result, equals('Alarm would have sounded at full volume'));
    });
  });

  // ─── 9. Const + null safety ───────────────────────────────────────────────
  group('const constructor — identity', () {
    test('two LoudAlarmStrategy() instances are identical (const)', () {
      const a = LoudAlarmStrategy();
      const b = LoudAlarmStrategy();
      expect(identical(a, b), isTrue);
    });

    test('identical() returns true for LoudAlarmStrategy() instances', () {
      expect(
        identical(const LoudAlarmStrategy(), const LoudAlarmStrategy()),
        isTrue,
      );
    });

    test(
      'null step.config falls back to defaults: vibration fires once',
      () async {
        final vibration = FakeVibrationService();
        final services = buildServices(vibration: vibration);
        await const LoudAlarmStrategy().executeReal(_step(), services);
        expect(vibration.calls, hasLength(1));
        expect(vibration.calls.first['method'], equals('alarmPattern'));
      },
    );

    test(
      'null step.config falls back to defaults: audio fires with siren/1.0',
      () async {
        final audio = FakeAudioService();
        final services = buildServices(audio: audio);
        await const LoudAlarmStrategy().executeReal(_step(), services);
        expect(audio.calls, hasLength(1));
        expect(audio.calls.first['soundChoice'], equals('siren'));
        expect(audio.calls.first['volume'], equals(1.0));
      },
    );

    test(
      'null step.config falls back to defaults: flash fires (flashLight=true)',
      () async {
        final flash = FakeFlashService();
        final services = buildServices(flash: flash);
        await const LoudAlarmStrategy().executeReal(_step(), services);
        expect(flash.calls, hasLength(1));
        expect(flash.calls.first['method'], equals('startSosFlash'));
      },
    );

    test(
      'null step.config falls back to defaults: no screenFlash (flashScreen=false)',
      () async {
        final screenFlash = FakeScreenFlashService();
        final services = buildServices(screenFlash: screenFlash);
        await const LoudAlarmStrategy().executeReal(_step(), services);
        expect(screenFlash.calls, isEmpty);
      },
    );

    test('executeReal completes without throwing for null config', () async {
      final services = buildServices();
      await expectLater(
        const LoudAlarmStrategy().executeReal(_step(), services),
        completes,
      );
    });
  });

  // ─── 10. Call order — vibration fires before audio ─────────────────────────
  group('executeReal — vibration fires before audio', () {
    test('order: alarmPattern logged before playAlarmWithConfig', () async {
      final log = <String>[];
      final audio = _OrderLoggingAudioService(log);
      final vibration = _OrderLoggingVibrationService(log);
      final services = buildServices(audio: audio, vibration: vibration);
      await const LoudAlarmStrategy().executeReal(
        _step(config: const LoudAlarmConfig()),
        services,
      );
      expect(log, equals(['vibration', 'audio']));
    });
  });
}

// ─── Call-order logging fakes ─────────────────────────────────────────────────
// These implement the protocols directly (rather than extending the final-class
// fakes from _test_fakes.dart) so that they can append an ordered log entry
// while fully recording each call.

/// [AudioServiceProtocol] that appends `'audio'` to [_log] on
/// [playAlarmWithConfig] and also records the full call details.
final class _OrderLoggingAudioService implements AudioServiceProtocol {
  _OrderLoggingAudioService(this._log);

  final List<String> _log;

  /// All calls recorded in the order they occurred.
  final List<Map<String, Object?>> calls = [];

  @override
  Future<void> playAlarmWithConfig({
    String soundChoice = 'siren',
    String? customSoundPath,
    double volume = 1.0,
    bool isSimulation = false,
  }) async {
    _log.add('audio');
    calls.add({
      'method': 'playAlarmWithConfig',
      'soundChoice': soundChoice,
      'customSoundPath': customSoundPath,
      'volume': volume,
      'isSimulation': isSimulation,
    });
  }

  @override
  Future<void> playSound(String assetPath) async {
    calls.add({'method': 'playSound', 'assetPath': assetPath});
  }

  @override
  Future<void> stop() async {
    calls.add({'method': 'stop'});
  }
}

/// [VibrationServiceProtocol] that appends `'vibration'` to [_log] on
/// [alarmPattern] and also records the full call details.
final class _OrderLoggingVibrationService implements VibrationServiceProtocol {
  _OrderLoggingVibrationService(this._log);

  final List<String> _log;

  /// All calls recorded in the order they occurred.
  final List<Map<String, Object?>> calls = [];

  @override
  Future<void> alarmPattern({bool isSimulation = false}) async {
    _log.add('vibration');
    calls.add({'method': 'alarmPattern', 'isSimulation': isSimulation});
  }

  @override
  Future<void> warningPattern({bool isSimulation = false}) async {
    calls.add({'method': 'warningPattern', 'isSimulation': isSimulation});
  }

  @override
  Future<void> cancel() async {
    calls.add({'method': 'cancel'});
  }
}
