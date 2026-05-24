/// Unit tests for [CountdownWarningStrategy].
///
/// Spec ref: docs/spec/02-event-types.md §4 countdownWarning.
///
/// Strategy behaviour:
/// - [executeReal] in real mode fires [VibrationServiceProtocol.warningPattern]
///   (with `isSimulation` forwarded) when [CountdownWarningConfig.vibrate] is
///   true, and [AudioServiceProtocol.playSound] when
///   [CountdownWarningConfig.sound] is true. Vibration fires before audio.
/// - [executeReal] with [EventServices.isSimulation] true still fires
///   vibration and audio — countdown is local-only per spec 02 §Simulation
///   Behavior Summary (lines 573-576). The `isSimulation` flag is forwarded to
///   each service so Layer 3/4 can apply hardware muting if required.
/// - [simulationDescription] always returns null (UI fires identically in
///   simulation; no toast substitution needed per spec line 208).
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/countdown_style.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/strategies/countdown_warning_strategy.dart';
import 'package:guardianangela/services/protocols/audio_service_protocol.dart';
import 'package:guardianangela/services/protocols/vibration_service_protocol.dart';
import '../_test_fakes.dart';

// ─── Local helpers ────────────────────────────────────────────────────────────

const _uuid = '00000000-0000-0000-0000-000000000002';

/// Builds a [ChainStep] of type [ChainStepType.countdownWarning] with an
/// optional [CountdownWarningConfig].
///
/// When [config] is null the step carries no typed config, exercising the
/// null-config fallback inside the strategy (falls back to
/// [CountdownWarningConfig] defaults: vibrate=true, sound=false).
ChainStep _step({CountdownWarningConfig? config}) => ChainStep(
  id: _uuid,
  type: ChainStepType.countdownWarning,
  order: 0,
  waitSeconds: 0,
  durationSeconds: 10,
  gracePeriodSeconds: 5,
  retryCount: 0,
  randomize: false,
  config: config,
);

// ─── Ordering-instrumented fakes ──────────────────────────────────────────────

/// [AudioServiceProtocol] implementation that appends `'audio'` to a shared
/// [log] list then delegates to a [FakeAudioService].
///
/// Used only to verify call ordering across vibration and audio services.
final class _OrderAudioService implements AudioServiceProtocol {
  _OrderAudioService(this._log, this._delegate);

  final List<String> _log;
  final FakeAudioService _delegate;

  @override
  Future<void> playRingtone(String? assetPath) async {
    _log.add('audio');
    await _delegate.playRingtone(assetPath);
  }

  @override
  Future<void> playAlarm() async {
    _log.add('audio');
    await _delegate.playAlarm();
  }

  @override
  Future<void> playAlarmWithConfig({
    String soundChoice = 'siren',
    String? customSoundPath,
    double volume = 1.0,
    bool isSimulation = false,
    int rampSeconds = kDefaultAlarmRampSeconds,
  }) async {
    _log.add('audio');
    await _delegate.playAlarmWithConfig(
      soundChoice: soundChoice,
      customSoundPath: customSoundPath,
      volume: volume,
      isSimulation: isSimulation,
      rampSeconds: rampSeconds,
    );
  }

  @override
  Future<void> playSound(String assetPath) async {
    _log.add('audio');
    await _delegate.playSound(assetPath);
  }

  @override
  Future<void> stop() async {
    _log.add('audio');
    await _delegate.stop();
  }
}

/// [VibrationServiceProtocol] implementation that appends `'vibration'` to a
/// shared [log] list then delegates to a [FakeVibrationService].
final class _OrderVibrationService implements VibrationServiceProtocol {
  _OrderVibrationService(this._log, this._delegate);

  final List<String> _log;
  final FakeVibrationService _delegate;

  @override
  Future<void> warningPattern({bool isSimulation = false}) async {
    _log.add('vibration');
    await _delegate.warningPattern(isSimulation: isSimulation);
  }

  @override
  Future<void> confirmPulse() async {
    _log.add('vibration');
    await _delegate.confirmPulse();
  }

  @override
  Future<void> alarmPattern({bool isSimulation = false}) async {
    _log.add('vibration');
    await _delegate.alarmPattern(isSimulation: isSimulation);
  }

  @override
  Future<void> fakeCallPattern() async {
    _log.add('vibration');
    await _delegate.fakeCallPattern();
  }

  @override
  Future<void> reminderPattern() async {
    _log.add('vibration');
    await _delegate.reminderPattern();
  }

  @override
  Future<void> cancel() async {
    _log.add('vibration');
    await _delegate.cancel();
  }
}

/// Builds an [EventServices] wired with ordering-instrumented wrappers.
///
/// Returns a record with the services, the underlying fakes, and the shared
/// call-order [log].
({
  EventServices services,
  FakeAudioService audio,
  FakeVibrationService vibration,
  List<String> log,
})
_buildOrderedServices() {
  final log = <String>[];
  final audioFake = FakeAudioService();
  final vibFake = FakeVibrationService();
  final services = buildServices(
    audio: _OrderAudioService(log, audioFake),
    vibration: _OrderVibrationService(log, vibFake),
  );
  return (services: services, audio: audioFake, vibration: vibFake, log: log);
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  // ─── 1. Real mode — default config (vibrate=true, sound=false) ──────────
  group('executeReal — default config (vibrate=true, sound=false)', () {
    test('vibration.warningPattern is called exactly once', () async {
      final vibration = FakeVibrationService();
      final services = buildServices(vibration: vibration);
      await const CountdownWarningStrategy().executeReal(
        _step(config: const CountdownWarningConfig()),
        services,
      );
      check(vibration.calls.length).equals(1);
      check(vibration.calls.first['method'] as String).equals('warningPattern');
    });

    test('audio.calls is empty (sound=false default)', () async {
      final audio = FakeAudioService();
      final services = buildServices(audio: audio);
      await const CountdownWarningStrategy().executeReal(
        _step(config: const CountdownWarningConfig()),
        services,
      );
      check(audio.calls).isEmpty();
    });

    test(
      'only one vibration call total (no spurious alarmPattern/cancel)',
      () async {
        final vibration = FakeVibrationService();
        final services = buildServices(vibration: vibration);
        await const CountdownWarningStrategy().executeReal(
          _step(config: const CountdownWarningConfig()),
          services,
        );
        check(vibration.calls.length).equals(1);
      },
    );

    test(
      'messaging, phone, recording, flash, screenFlash are all empty',
      () async {
        final messaging = FakeMessagingService();
        final phone = FakePhoneService();
        final recording = FakeRecordingService();
        final flash = FakeFlashService();
        final screenFlash = FakeScreenFlashService();
        final services = buildServices(
          messaging: messaging,
          phone: phone,
          recording: recording,
          flash: flash,
          screenFlash: screenFlash,
        );
        await const CountdownWarningStrategy().executeReal(
          _step(config: const CountdownWarningConfig()),
          services,
        );
        check(messaging.calls).isEmpty();
        check(phone.calls).isEmpty();
        check(recording.calls).isEmpty();
        check(flash.calls).isEmpty();
        check(screenFlash.calls).isEmpty();
      },
    );
  });

  // ─── 2. Real mode — vibrate=false, sound=false ───────────────────────────
  group('executeReal — vibrate=false, sound=false', () {
    test('vibration.calls is empty', () async {
      final vibration = FakeVibrationService();
      final services = buildServices(vibration: vibration);
      // sound=false is the default; vibrate=false is the tested variation.
      await const CountdownWarningStrategy().executeReal(
        _step(config: const CountdownWarningConfig(vibrate: false)),
        services,
      );
      check(vibration.calls).isEmpty();
    });

    test('audio.calls is empty', () async {
      final audio = FakeAudioService();
      final services = buildServices(audio: audio);
      await const CountdownWarningStrategy().executeReal(
        _step(config: const CountdownWarningConfig(vibrate: false)),
        services,
      );
      check(audio.calls).isEmpty();
    });

    test('both vibration and audio are empty', () async {
      final audio = FakeAudioService();
      final vibration = FakeVibrationService();
      final services = buildServices(audio: audio, vibration: vibration);
      await const CountdownWarningStrategy().executeReal(
        _step(config: const CountdownWarningConfig(vibrate: false)),
        services,
      );
      check(audio.calls).isEmpty();
      check(vibration.calls).isEmpty();
    });
  });

  // ─── 3. Real mode — vibrate=true, sound=true ─────────────────────────────
  group('executeReal — vibrate=true, sound=true', () {
    test('vibration.calls has exactly one warningPattern entry', () async {
      final vibration = FakeVibrationService();
      final services = buildServices(vibration: vibration);
      // vibrate defaults to true; explicitly set sound=true.
      await const CountdownWarningStrategy().executeReal(
        _step(config: const CountdownWarningConfig(sound: true)),
        services,
      );
      check(vibration.calls.length).equals(1);
      check(vibration.calls.first['method'] as String).equals('warningPattern');
    });

    test('audio.calls has exactly one playSound entry', () async {
      final audio = FakeAudioService();
      final services = buildServices(audio: audio);
      await const CountdownWarningStrategy().executeReal(
        _step(config: const CountdownWarningConfig(sound: true)),
        services,
      );
      check(audio.calls.length).equals(1);
      check(audio.calls.first['method'] as String).equals('playSound');
    });

    test('audio.playSound receives the countdown warning asset path', () async {
      final audio = FakeAudioService();
      final services = buildServices(audio: audio);
      await const CountdownWarningStrategy().executeReal(
        _step(config: const CountdownWarningConfig(sound: true)),
        services,
      );
      check(
        audio.calls.first['assetPath'] as String,
      ).equals('assets/audio/countdown_warning.ogg');
    });

    test('vibration is called before audio (call order)', () async {
      final rec = _buildOrderedServices();
      await const CountdownWarningStrategy().executeReal(
        _step(config: const CountdownWarningConfig(sound: true)),
        rec.services,
      );
      check(rec.log).deepEquals(['vibration', 'audio']);
    });
  });

  // ─── 4. Real mode — vibrate=false, sound=true ────────────────────────────
  group('executeReal — vibrate=false, sound=true', () {
    test('audio.calls has one playSound entry', () async {
      final audio = FakeAudioService();
      final services = buildServices(audio: audio);
      await const CountdownWarningStrategy().executeReal(
        _step(
          config: const CountdownWarningConfig(vibrate: false, sound: true),
        ),
        services,
      );
      check(audio.calls.length).equals(1);
      check(audio.calls.first['method'] as String).equals('playSound');
    });

    test('vibration.calls is empty when vibrate=false', () async {
      final vibration = FakeVibrationService();
      final services = buildServices(vibration: vibration);
      await const CountdownWarningStrategy().executeReal(
        _step(
          config: const CountdownWarningConfig(vibrate: false, sound: true),
        ),
        services,
      );
      check(vibration.calls).isEmpty();
    });

    test('only audio appears in order log when vibrate=false', () async {
      final rec = _buildOrderedServices();
      await const CountdownWarningStrategy().executeReal(
        _step(
          config: const CountdownWarningConfig(vibrate: false, sound: true),
        ),
        rec.services,
      );
      check(rec.log).deepEquals(['audio']);
    });
  });

  // ─── 5. Sim — isSimulation=true, default config (vibrate=true, sound=false)
  //
  // Per spec 02 §Simulation Behavior Summary (lines 573-576): countdown is
  // a local-only action — vibration fires identically in simulation.
  // The Layer 2 sim short-circuit has been REMOVED; isSimulation is forwarded
  // to each service instead (Layer 3/4 muting applies there).
  group(
    'executeReal — isSimulation=true, default config (vibrate=true, sound=false)',
    () {
      test(
        'vibration.calls has one warningPattern entry (fires in sim)',
        () async {
          final vibration = FakeVibrationService();
          final services = buildServices(
            vibration: vibration,
            isSimulation: true,
          );
          await const CountdownWarningStrategy().executeReal(
            _step(config: const CountdownWarningConfig()),
            services,
          );
          check(vibration.calls).length.equals(1);
          check(
            vibration.calls.first['method'] as String,
          ).equals('warningPattern');
        },
      );

      test(
        'vibration call forwards isSimulation=true to the service',
        () async {
          final vibration = FakeVibrationService();
          final services = buildServices(
            vibration: vibration,
            isSimulation: true,
          );
          await const CountdownWarningStrategy().executeReal(
            _step(config: const CountdownWarningConfig()),
            services,
          );
          check(vibration.calls.first['isSimulation'] as bool).isTrue();
        },
      );

      test('audio.calls is empty (sound=false default)', () async {
        final audio = FakeAudioService();
        final services = buildServices(audio: audio, isSimulation: true);
        await const CountdownWarningStrategy().executeReal(
          _step(config: const CountdownWarningConfig()),
          services,
        );
        check(audio.calls).isEmpty();
      });

      test(
        'messaging, phone, recording, flash, screenFlash are empty',
        () async {
          final messaging = FakeMessagingService();
          final phone = FakePhoneService();
          final recording = FakeRecordingService();
          final flash = FakeFlashService();
          final screenFlash = FakeScreenFlashService();
          final services = buildServices(
            isSimulation: true,
            messaging: messaging,
            phone: phone,
            recording: recording,
            flash: flash,
            screenFlash: screenFlash,
          );
          await const CountdownWarningStrategy().executeReal(
            _step(config: const CountdownWarningConfig()),
            services,
          );
          check(messaging.calls).isEmpty();
          check(phone.calls).isEmpty();
          check(recording.calls).isEmpty();
          check(flash.calls).isEmpty();
          check(screenFlash.calls).isEmpty();
        },
      );
    },
  );

  // ─── 6. Sim — isSimulation=true, vibrate=true, sound=true ───────────────
  group('executeReal — isSimulation=true, vibrate=true, sound=true', () {
    test(
      'vibration.calls has one warningPattern entry despite isSimulation=true',
      () async {
        final vibration = FakeVibrationService();
        final services = buildServices(
          vibration: vibration,
          isSimulation: true,
        );
        await const CountdownWarningStrategy().executeReal(
          _step(config: const CountdownWarningConfig(sound: true)),
          services,
        );
        check(vibration.calls).length.equals(1);
        check(
          vibration.calls.first['method'] as String,
        ).equals('warningPattern');
      },
    );

    test('vibration call forwards isSimulation=true', () async {
      final vibration = FakeVibrationService();
      final services = buildServices(vibration: vibration, isSimulation: true);
      await const CountdownWarningStrategy().executeReal(
        _step(config: const CountdownWarningConfig(sound: true)),
        services,
      );
      check(vibration.calls.first['isSimulation'] as bool).isTrue();
    });

    test(
      'audio.calls has one playSound entry when sound=true, isSimulation=true',
      () async {
        final audio = FakeAudioService();
        final services = buildServices(audio: audio, isSimulation: true);
        await const CountdownWarningStrategy().executeReal(
          _step(config: const CountdownWarningConfig(sound: true)),
          services,
        );
        check(audio.calls).length.equals(1);
        check(audio.calls.first['method'] as String).equals('playSound');
      },
    );

    test('both vibration and audio fire when isSimulation=true', () async {
      final audio = FakeAudioService();
      final vibration = FakeVibrationService();
      final services = buildServices(
        audio: audio,
        vibration: vibration,
        isSimulation: true,
      );
      await const CountdownWarningStrategy().executeReal(
        _step(config: const CountdownWarningConfig(sound: true)),
        services,
      );
      check(vibration.calls).length.equals(1);
      check(audio.calls).length.equals(1);
    });
  });

  // ─── spec compliance: vibration fires in sim mode ─────────────────────────
  group('spec compliance: vibration fires in sim mode', () {
    test('vibrate=true, isSimulation=true → warningPattern called', () async {
      final vibration = FakeVibrationService();
      final services = buildServices(vibration: vibration, isSimulation: true);
      await const CountdownWarningStrategy().executeReal(
        _step(config: const CountdownWarningConfig()),
        services,
      );
      check(vibration.calls).length.equals(1);
    });

    test(
      'vibrate=true in sim: isSimulation=true forwarded to warningPattern',
      () async {
        final vibration = FakeVibrationService();
        final services = buildServices(
          vibration: vibration,
          isSimulation: true,
        );
        await const CountdownWarningStrategy().executeReal(
          _step(config: const CountdownWarningConfig()),
          services,
        );
        check(vibration.calls.first['isSimulation'] as bool).isTrue();
      },
    );

    test(
      'vibrate=false in sim: vibration still empty (config respected)',
      () async {
        final vibration = FakeVibrationService();
        final services = buildServices(
          vibration: vibration,
          isSimulation: true,
        );
        await const CountdownWarningStrategy().executeReal(
          _step(config: const CountdownWarningConfig(vibrate: false)),
          services,
        );
        check(vibration.calls).isEmpty();
      },
    );
  });

  // ─── spec compliance: audio fires in sim mode if config.sound ────────────
  group('spec compliance: audio fires in sim mode if config.sound', () {
    test('sound=true, isSimulation=true → playSound called', () async {
      final audio = FakeAudioService();
      final services = buildServices(audio: audio, isSimulation: true);
      await const CountdownWarningStrategy().executeReal(
        _step(config: const CountdownWarningConfig(sound: true)),
        services,
      );
      check(audio.calls).length.equals(1);
      check(audio.calls.first['method'] as String).equals('playSound');
    });

    test(
      'sound=true, isSimulation=true → playSound receives countdown asset',
      () async {
        final audio = FakeAudioService();
        final services = buildServices(audio: audio, isSimulation: true);
        await const CountdownWarningStrategy().executeReal(
          _step(config: const CountdownWarningConfig(sound: true)),
          services,
        );
        check(
          audio.calls.first['assetPath'] as String,
        ).equals('assets/audio/countdown_warning.ogg');
      },
    );

    test(
      'sound=false, isSimulation=true → audio still empty (config respected)',
      () async {
        final audio = FakeAudioService();
        final services = buildServices(audio: audio, isSimulation: true);
        await const CountdownWarningStrategy().executeReal(
          _step(config: const CountdownWarningConfig()),
          services,
        );
        check(audio.calls).isEmpty();
      },
    );
  });

  // ─── 7. simulationDescription — default config returns null ─────────────
  group('simulationDescription — default config', () {
    test('returns null for default CountdownWarningConfig', () {
      final services = buildServices();
      check(
        const CountdownWarningStrategy().simulationDescription(
          _step(config: const CountdownWarningConfig()),
          services,
        ),
      ).isNull();
    });

    test('returns null when isSimulation=false', () {
      final services = buildServices();
      check(
        const CountdownWarningStrategy().simulationDescription(
          _step(config: const CountdownWarningConfig()),
          services,
        ),
      ).isNull();
    });

    test('returns null when isSimulation=true', () {
      final services = buildServices(isSimulation: true);
      check(
        const CountdownWarningStrategy().simulationDescription(
          _step(config: const CountdownWarningConfig()),
          services,
        ),
      ).isNull();
    });
  });

  // ─── 8. simulationDescription — representative bool-field combos ─────────
  group('simulationDescription — bool-field combinations', () {
    test('returns null for vibrate=false, sound=false', () {
      final services = buildServices();
      // sound=false is the default; vibrate=false is the tested variation.
      check(
        const CountdownWarningStrategy().simulationDescription(
          _step(config: const CountdownWarningConfig(vibrate: false)),
          services,
        ),
      ).isNull();
    });

    test('returns null for vibrate=true, sound=true', () {
      final services = buildServices();
      check(
        const CountdownWarningStrategy().simulationDescription(
          _step(config: const CountdownWarningConfig(sound: true)),
          services,
        ),
      ).isNull();
    });

    test('returns null for vibrate=false, sound=true', () {
      final services = buildServices();
      check(
        const CountdownWarningStrategy().simulationDescription(
          _step(
            config: const CountdownWarningConfig(vibrate: false, sound: true),
          ),
          services,
        ),
      ).isNull();
    });

    test('returns null for blackScreenMode=true', () {
      final services = buildServices();
      check(
        const CountdownWarningStrategy().simulationDescription(
          _step(config: const CountdownWarningConfig(blackScreenMode: true)),
          services,
        ),
      ).isNull();
    });
  });

  // ─── 9. simulationDescription — every CountdownStyle enum value ──────────
  group('simulationDescription — all CountdownStyle values', () {
    for (final style in CountdownStyle.values) {
      test('returns null for CountdownStyle.${style.name}', () {
        final services = buildServices();
        check(
          const CountdownWarningStrategy().simulationDescription(
            _step(config: CountdownWarningConfig(style: style)),
            services,
          ),
        ).isNull();
      });
    }
  });

  // ─── 10. simulationDescription — null step.config ────────────────────────
  group('simulationDescription — null step.config', () {
    test('returns null when config is null', () {
      final services = buildServices();
      check(
        const CountdownWarningStrategy().simulationDescription(
          _step(),
          services,
        ),
      ).isNull();
    });

    test('returns null when config is null and isSimulation=true', () {
      final services = buildServices(isSimulation: true);
      check(
        const CountdownWarningStrategy().simulationDescription(
          _step(),
          services,
        ),
      ).isNull();
    });
  });

  // ─── 11. Null config falls back to defaults (vibrate=true, sound=false) ──
  group('executeReal — null step.config falls back to defaults', () {
    test('vibration.warningPattern fires once with null config', () async {
      final vibration = FakeVibrationService();
      final services = buildServices(vibration: vibration);
      await const CountdownWarningStrategy().executeReal(_step(), services);
      check(vibration.calls.length).equals(1);
      check(vibration.calls.first['method'] as String).equals('warningPattern');
    });

    test(
      'audio.calls is empty with null config (sound=false fallback)',
      () async {
        final audio = FakeAudioService();
        final services = buildServices(audio: audio);
        await const CountdownWarningStrategy().executeReal(_step(), services);
        check(audio.calls).isEmpty();
      },
    );

    test(
      'executeReal completes without throwing when config is null',
      () async {
        final services = buildServices();
        await check(
          const CountdownWarningStrategy().executeReal(_step(), services),
        ).completes();
      },
    );

    test(
      'null config + isSimulation=true still fires vibration (local-only)',
      () async {
        final vibration = FakeVibrationService();
        final services = buildServices(
          vibration: vibration,
          isSimulation: true,
        );
        await const CountdownWarningStrategy().executeReal(_step(), services);
        // Null config → defaults: vibrate=true, sound=false.
        // Sim does not short-circuit; vibration fires with isSimulation=true.
        check(vibration.calls).length.equals(1);
        check(vibration.calls.first['isSimulation'] as bool).isTrue();
      },
    );
  });

  // ─── 12. Const-ness ───────────────────────────────────────────────────────
  group('const constructor — identity', () {
    test('two CountdownWarningStrategy() instances are identical (const)', () {
      const a = CountdownWarningStrategy();
      const b = CountdownWarningStrategy();
      check(identical(a, b)).isTrue();
    });

    test('const literal is CountdownWarningStrategy', () {
      const strategy = CountdownWarningStrategy();
      check(strategy).isA<CountdownWarningStrategy>();
    });
  });

  // ─── 13. Call order — vibration always before audio ──────────────────────
  group('executeReal — vibration precedes audio', () {
    test('vibration then audio when both enabled', () async {
      final rec = _buildOrderedServices();
      await const CountdownWarningStrategy().executeReal(
        _step(config: const CountdownWarningConfig(sound: true)),
        rec.services,
      );
      check(rec.log).deepEquals(['vibration', 'audio']);
    });

    test('only vibration logged when sound=false', () async {
      final rec = _buildOrderedServices();
      await const CountdownWarningStrategy().executeReal(
        _step(config: const CountdownWarningConfig()),
        rec.services,
      );
      check(rec.log).deepEquals(['vibration']);
    });

    test(
      'only vibration logged with null config (defaults: vibrate=true)',
      () async {
        final rec = _buildOrderedServices();
        await const CountdownWarningStrategy().executeReal(
          _step(),
          rec.services,
        );
        check(rec.log).deepEquals(['vibration']);
      },
    );
  });

  // ─── 14. No unexpected service calls in real mode ─────────────────────────
  group('executeReal — no unexpected service calls', () {
    test('messaging, phone, recording, flash, screenFlash empty '
        'when vibrate=true, sound=true', () async {
      final messaging = FakeMessagingService();
      final phone = FakePhoneService();
      final recording = FakeRecordingService();
      final flash = FakeFlashService();
      final screenFlash = FakeScreenFlashService();
      final services = buildServices(
        messaging: messaging,
        phone: phone,
        recording: recording,
        flash: flash,
        screenFlash: screenFlash,
      );
      await const CountdownWarningStrategy().executeReal(
        _step(config: const CountdownWarningConfig(sound: true)),
        services,
      );
      check(messaging.calls).isEmpty();
      check(phone.calls).isEmpty();
      check(recording.calls).isEmpty();
      check(flash.calls).isEmpty();
      check(screenFlash.calls).isEmpty();
    });

    test('no unexpected calls with null config', () async {
      final messaging = FakeMessagingService();
      final phone = FakePhoneService();
      final recording = FakeRecordingService();
      final flash = FakeFlashService();
      final screenFlash = FakeScreenFlashService();
      final services = buildServices(
        messaging: messaging,
        phone: phone,
        recording: recording,
        flash: flash,
        screenFlash: screenFlash,
      );
      await const CountdownWarningStrategy().executeReal(_step(), services);
      check(messaging.calls).isEmpty();
      check(phone.calls).isEmpty();
      check(recording.calls).isEmpty();
      check(flash.calls).isEmpty();
      check(screenFlash.calls).isEmpty();
    });
  });
}
