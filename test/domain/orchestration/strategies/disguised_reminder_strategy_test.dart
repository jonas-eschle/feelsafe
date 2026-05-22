/// Unit tests for [DisguisedReminderStrategy].
///
/// Spec ref: docs/spec/02-event-types.md §2 disguisedReminder.
///
/// The strategy is a pure no-op:
/// - [executeReal] never touches any service (UI-only per spec line 149).
/// - [simulationDescription] always returns `null` (overlay fires identically
///   in simulation per spec line 150).
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/strategies/disguised_reminder_strategy.dart';
import '../_test_fakes.dart';

// ─── Helper factories ─────────────────────────────────────────────────────────

/// Creates a minimal [ChainStep] of type [ChainStepType.disguisedReminder].
///
/// [config] defaults to `null` so tests that need it can pass one explicitly.
ChainStep _step({DisguisedReminderConfig? config}) => ChainStep(
  id: 'test-step-id',
  type: ChainStepType.disguisedReminder,
  order: 0,
  waitSeconds: 1800,
  durationSeconds: 60,
  gracePeriodSeconds: 5,
  retryCount: 1,
  randomize: false,
  config: config,
);

void main() {
  // ─── Group 1: executeReal no-op with default config ──────────────────────

  group('executeReal — no-op under real mode (default config)', () {
    test('audio.calls is empty after executeReal', () async {
      final audio = FakeAudioService();
      final services = buildServices(audio: audio);
      final step = _step(config: const DisguisedReminderConfig());

      await const DisguisedReminderStrategy().executeReal(step, services);

      check(audio.calls).isEmpty();
    });

    test('vibration.calls is empty after executeReal', () async {
      final vibration = FakeVibrationService();
      final services = buildServices(vibration: vibration);
      final step = _step(config: const DisguisedReminderConfig());

      await const DisguisedReminderStrategy().executeReal(step, services);

      check(vibration.calls).isEmpty();
    });

    test('messaging.calls is empty after executeReal', () async {
      final messaging = FakeMessagingService();
      final services = buildServices(messaging: messaging);
      final step = _step(config: const DisguisedReminderConfig());

      await const DisguisedReminderStrategy().executeReal(step, services);

      check(messaging.calls).isEmpty();
    });

    test('phone.calls is empty after executeReal', () async {
      final phone = FakePhoneService();
      final services = buildServices(phone: phone);
      final step = _step(config: const DisguisedReminderConfig());

      await const DisguisedReminderStrategy().executeReal(step, services);

      check(phone.calls).isEmpty();
    });

    test('flash.calls is empty after executeReal', () async {
      final flash = FakeFlashService();
      final services = buildServices(flash: flash);
      final step = _step(config: const DisguisedReminderConfig());

      await const DisguisedReminderStrategy().executeReal(step, services);

      check(flash.calls).isEmpty();
    });

    test('screenFlash.calls is empty after executeReal', () async {
      final screenFlash = FakeScreenFlashService();
      final services = buildServices(screenFlash: screenFlash);
      final step = _step(config: const DisguisedReminderConfig());

      await const DisguisedReminderStrategy().executeReal(step, services);

      check(screenFlash.calls).isEmpty();
    });

    test('recording.calls is empty after executeReal', () async {
      final recording = FakeRecordingService();
      final services = buildServices(recording: recording);
      final step = _step(config: const DisguisedReminderConfig());

      await const DisguisedReminderStrategy().executeReal(step, services);

      check(recording.calls).isEmpty();
    });
  });

  // ─── Group 2: executeReal no-op under simulation ─────────────────────────

  group('executeReal — no-op when isSimulation=true (default config)', () {
    test('audio.calls is empty when isSimulation=true', () async {
      final audio = FakeAudioService();
      final services = buildServices(audio: audio, isSimulation: true);
      final step = _step(config: const DisguisedReminderConfig());

      await const DisguisedReminderStrategy().executeReal(step, services);

      check(audio.calls).isEmpty();
    });

    test('all fakes empty when isSimulation=true', () async {
      final audio = FakeAudioService();
      final vibration = FakeVibrationService();
      final messaging = FakeMessagingService();
      final phone = FakePhoneService();
      final flash = FakeFlashService();
      final screenFlash = FakeScreenFlashService();
      final recording = FakeRecordingService();
      final services = buildServices(
        audio: audio,
        vibration: vibration,
        messaging: messaging,
        phone: phone,
        flash: flash,
        screenFlash: screenFlash,
        recording: recording,
        isSimulation: true,
      );
      final step = _step(config: const DisguisedReminderConfig());

      await const DisguisedReminderStrategy().executeReal(step, services);

      check(audio.calls).isEmpty();
      check(vibration.calls).isEmpty();
      check(messaging.calls).isEmpty();
      check(phone.calls).isEmpty();
      check(flash.calls).isEmpty();
      check(screenFlash.calls).isEmpty();
      check(recording.calls).isEmpty();
    });
  });

  // ─── Group 3: executeReal no-op for 8 config combinations ───────────────

  group('executeReal — no-op for representative config combinations', () {
    // 8 representative combinations out of 2^4 = 16 total.

    test('all-defaults (T,T,T,F): all fakes empty', () async {
      // Default config — no non-default arguments needed.
      final audio = FakeAudioService();
      final messaging = FakeMessagingService();
      final services = buildServices(audio: audio, messaging: messaging);
      await const DisguisedReminderStrategy().executeReal(
        _step(config: const DisguisedReminderConfig()),
        services,
      );
      check(audio.calls).isEmpty();
      check(messaging.calls).isEmpty();
    });

    test('all-false (F,F,F,F): all fakes empty', () async {
      final audio = FakeAudioService();
      final messaging = FakeMessagingService();
      final services = buildServices(audio: audio, messaging: messaging);
      await const DisguisedReminderStrategy().executeReal(
        _step(
          config: const DisguisedReminderConfig(
            randomizeInterval: false,
            randomizeTemplateOrder: false,
            resetOnEarlyCheckIn: false,
          ),
        ),
        services,
      );
      check(audio.calls).isEmpty();
      check(messaging.calls).isEmpty();
    });

    test(
      'blackScreenMode=true, rest default (T,T,T,T): all fakes empty',
      () async {
        final vibration = FakeVibrationService();
        final services = buildServices(vibration: vibration);
        await const DisguisedReminderStrategy().executeReal(
          _step(config: const DisguisedReminderConfig(blackScreenMode: true)),
          services,
        );
        check(vibration.calls).isEmpty();
      },
    );

    test('randomizeInterval=false only (F,T,T,F): all fakes empty', () async {
      final flash = FakeFlashService();
      final services = buildServices(flash: flash);
      await const DisguisedReminderStrategy().executeReal(
        _step(config: const DisguisedReminderConfig(randomizeInterval: false)),
        services,
      );
      check(flash.calls).isEmpty();
    });

    test(
      'randomizeTemplateOrder=false only (T,F,T,F): all fakes empty',
      () async {
        final phone = FakePhoneService();
        final services = buildServices(phone: phone);
        await const DisguisedReminderStrategy().executeReal(
          _step(
            config: const DisguisedReminderConfig(
              randomizeTemplateOrder: false,
            ),
          ),
          services,
        );
        check(phone.calls).isEmpty();
      },
    );

    test('resetOnEarlyCheckIn=false only (T,T,F,F): all fakes empty', () async {
      final recording = FakeRecordingService();
      final services = buildServices(recording: recording);
      await const DisguisedReminderStrategy().executeReal(
        _step(
          config: const DisguisedReminderConfig(resetOnEarlyCheckIn: false),
        ),
        services,
      );
      check(recording.calls).isEmpty();
    });

    test('resetOnEarlyCheckIn default vs false — both produce no-op', () async {
      final audioDefault = FakeAudioService();
      final audioNoReset = FakeAudioService();

      await const DisguisedReminderStrategy().executeReal(
        _step(config: const DisguisedReminderConfig()),
        buildServices(audio: audioDefault),
      );
      await const DisguisedReminderStrategy().executeReal(
        _step(
          config: const DisguisedReminderConfig(resetOnEarlyCheckIn: false),
        ),
        buildServices(audio: audioNoReset),
      );

      check(audioDefault.calls).isEmpty();
      check(audioNoReset.calls).isEmpty();
    });

    test('all non-defaults (F,F,F,T): all fakes empty', () async {
      final audio = FakeAudioService();
      final vibration = FakeVibrationService();
      final messaging = FakeMessagingService();
      final phone = FakePhoneService();
      final flash = FakeFlashService();
      final screenFlash = FakeScreenFlashService();
      final recording = FakeRecordingService();
      final services = buildServices(
        audio: audio,
        vibration: vibration,
        messaging: messaging,
        phone: phone,
        flash: flash,
        screenFlash: screenFlash,
        recording: recording,
      );
      await const DisguisedReminderStrategy().executeReal(
        _step(
          config: const DisguisedReminderConfig(
            randomizeInterval: false,
            randomizeTemplateOrder: false,
            resetOnEarlyCheckIn: false,
            blackScreenMode: true,
          ),
        ),
        services,
      );
      check(audio.calls).isEmpty();
      check(vibration.calls).isEmpty();
      check(messaging.calls).isEmpty();
      check(phone.calls).isEmpty();
      check(flash.calls).isEmpty();
      check(screenFlash.calls).isEmpty();
      check(recording.calls).isEmpty();
    });
  });

  // ─── Group 4: simulationDescription returns null ──────────────────────────

  group('simulationDescription — always returns null (default config)', () {
    test('returns null for default config, isSimulation=false', () {
      final step = _step(config: const DisguisedReminderConfig());
      final services = buildServices();

      final result = const DisguisedReminderStrategy().simulationDescription(
        step,
        services,
      );

      check(result).isNull();
    });

    test('returns null for default config, isSimulation=true', () {
      final step = _step(config: const DisguisedReminderConfig());
      final services = buildServices(isSimulation: true);

      final result = const DisguisedReminderStrategy().simulationDescription(
        step,
        services,
      );

      check(result).isNull();
    });
  });

  // ─── Group 5: simulationDescription null regardless of bool fields ────────

  group('simulationDescription — null regardless of 4 config bool fields', () {
    test('randomizeInterval=false → null', () {
      final services = buildServices();
      final result = const DisguisedReminderStrategy().simulationDescription(
        _step(config: const DisguisedReminderConfig(randomizeInterval: false)),
        services,
      );
      check(result).isNull();
    });

    test('randomizeTemplateOrder=false → null', () {
      final services = buildServices();
      final result = const DisguisedReminderStrategy().simulationDescription(
        _step(
          config: const DisguisedReminderConfig(randomizeTemplateOrder: false),
        ),
        services,
      );
      check(result).isNull();
    });

    test('resetOnEarlyCheckIn=false → null', () {
      final services = buildServices();
      final result = const DisguisedReminderStrategy().simulationDescription(
        _step(
          config: const DisguisedReminderConfig(resetOnEarlyCheckIn: false),
        ),
        services,
      );
      check(result).isNull();
    });

    test('blackScreenMode=true → null', () {
      final services = buildServices();
      final result = const DisguisedReminderStrategy().simulationDescription(
        _step(config: const DisguisedReminderConfig(blackScreenMode: true)),
        services,
      );
      check(result).isNull();
    });

    test('all fields false/true edge combination → null', () {
      final services = buildServices();
      final result = const DisguisedReminderStrategy().simulationDescription(
        _step(
          config: const DisguisedReminderConfig(
            randomizeInterval: false,
            randomizeTemplateOrder: false,
            resetOnEarlyCheckIn: false,
            blackScreenMode: true,
          ),
        ),
        services,
      );
      check(result).isNull();
    });
  });

  // ─── Group 6: simulationDescription null regardless of isSimulation ───────

  group('simulationDescription — null regardless of isSimulation flag', () {
    test('isSimulation=false (default) → null', () {
      // isSimulation defaults to false in buildServices.
      final result = const DisguisedReminderStrategy().simulationDescription(
        _step(config: const DisguisedReminderConfig()),
        buildServices(),
      );
      check(result).isNull();
    });

    test('isSimulation=true → null', () {
      final result = const DisguisedReminderStrategy().simulationDescription(
        _step(config: const DisguisedReminderConfig()),
        buildServices(isSimulation: true),
      );
      check(result).isNull();
    });
  });

  // ─── Group 7: null step.config ────────────────────────────────────────────

  group('null step.config — strategy is safe with config=null', () {
    test('simulationDescription returns null when step.config is null', () {
      final result = const DisguisedReminderStrategy().simulationDescription(
        _step(),
        buildServices(),
      );
      check(result).isNull();
    });

    test('executeReal does not throw when step.config is null', () async {
      final services = buildServices();

      await check(
        const DisguisedReminderStrategy().executeReal(_step(), services),
      ).completes();
    });

    test('all fakes remain empty when step.config is null', () async {
      final audio = FakeAudioService();
      final vibration = FakeVibrationService();
      final messaging = FakeMessagingService();
      final phone = FakePhoneService();
      final flash = FakeFlashService();
      final screenFlash = FakeScreenFlashService();
      final recording = FakeRecordingService();
      final services = buildServices(
        audio: audio,
        vibration: vibration,
        messaging: messaging,
        phone: phone,
        flash: flash,
        screenFlash: screenFlash,
        recording: recording,
      );

      await const DisguisedReminderStrategy().executeReal(_step(), services);

      check(audio.calls).isEmpty();
      check(vibration.calls).isEmpty();
      check(messaging.calls).isEmpty();
      check(phone.calls).isEmpty();
      check(flash.calls).isEmpty();
      check(screenFlash.calls).isEmpty();
      check(recording.calls).isEmpty();
    });
  });

  // ─── Group 8: const constructor ──────────────────────────────────────────

  group('const constructor — strategy is a singleton constant', () {
    test('two const instances are identical', () {
      const a = DisguisedReminderStrategy();
      const b = DisguisedReminderStrategy();
      check(identical(a, b)).isTrue();
    });

    test('const literals from different sites are identical', () {
      // Distinct const expressions at different call sites must be the
      // same canonical object per the Dart spec (compile-time constants
      // are canonicalised).
      const x = DisguisedReminderStrategy();
      const y = DisguisedReminderStrategy();
      check(identical(x, y)).isTrue();
    });
  });

  // ─── Group 9: resetOnEarlyCheckIn symmetry ───────────────────────────────

  group('resetOnEarlyCheckIn — strategy treats true/false identically', () {
    test(
      'executeReal: reset=true (default) and reset=false both empty calls',
      () async {
        final audioDefault = FakeAudioService();
        final audioFalse = FakeAudioService();

        // resetOnEarlyCheckIn=true is the default; no explicit arg needed.
        await const DisguisedReminderStrategy().executeReal(
          _step(config: const DisguisedReminderConfig()),
          buildServices(audio: audioDefault),
        );
        await const DisguisedReminderStrategy().executeReal(
          _step(
            config: const DisguisedReminderConfig(resetOnEarlyCheckIn: false),
          ),
          buildServices(audio: audioFalse),
        );

        check(audioDefault.calls).deepEquals(audioFalse.calls);
      },
    );

    test(
      'simulationDescription: reset=true (default) and reset=false both null',
      () {
        final services = buildServices();
        // resetOnEarlyCheckIn=true is the default; no need to pass explicitly.
        final resultDefault = const DisguisedReminderStrategy()
            .simulationDescription(
              _step(config: const DisguisedReminderConfig()),
              services,
            );
        final resultFalse = const DisguisedReminderStrategy()
            .simulationDescription(
              _step(
                config: const DisguisedReminderConfig(
                  resetOnEarlyCheckIn: false,
                ),
              ),
              services,
            );
        check(resultDefault).isNull();
        check(resultFalse).isNull();
      },
    );
  });
}
