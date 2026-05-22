import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/button_type.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/press_pattern.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/strategies/hardware_button_strategy.dart';
import '../_test_fakes.dart';

// ─── Local step factory ────────────────────────────────────────────────────

/// Builds a [ChainStep] of type [ChainStepType.hardwareButton].
///
/// [config] defaults to null (engine falls back to event defaults).
/// All timing fields default to zero per spec 02 §3 hardwareButton
/// "Timing Defaults: waitSeconds=0, durationSeconds=0, gracePeriodSeconds=0".
ChainStep _step({
  String id = 'step-0-hardwareButton',
  int order = 0,
  HardwareButtonConfig? config,
}) => ChainStep(
  id: id,
  type: ChainStepType.hardwareButton,
  order: order,
  waitSeconds: 0,
  durationSeconds: 0,
  gracePeriodSeconds: 0,
  retryCount: 0,
  randomize: false,
  config: config,
);

// ─── Convenience alias ────────────────────────────────────────────────────

const _strategy = HardwareButtonStrategy();

// ─── Tests ─────────────────────────────────────────────────────────────────

void main() {
  // ── Group 1: executeReal — default config, real mode ──────────────────────

  group('executeReal / no-op with default config (real mode)', () {
    test('completes without throwing', () async {
      final services = buildServices();
      await _strategy.executeReal(_step(), services);
    });

    test('audio service receives no calls', () async {
      final audio = FakeAudioService();
      final services = buildServices(audio: audio);
      await _strategy.executeReal(_step(), services);
      check(audio.calls).isEmpty();
    });

    test('vibration service receives no calls', () async {
      final vibration = FakeVibrationService();
      final services = buildServices(vibration: vibration);
      await _strategy.executeReal(_step(), services);
      check(vibration.calls).isEmpty();
    });

    test('messaging service receives no calls', () async {
      final messaging = FakeMessagingService();
      final services = buildServices(messaging: messaging);
      await _strategy.executeReal(_step(), services);
      check(messaging.calls).isEmpty();
    });

    test('phone service receives no calls', () async {
      final phone = FakePhoneService();
      final services = buildServices(phone: phone);
      await _strategy.executeReal(_step(), services);
      check(phone.calls).isEmpty();
    });

    test('recording service receives no calls', () async {
      final recording = FakeRecordingService();
      final services = buildServices(recording: recording);
      await _strategy.executeReal(_step(), services);
      check(recording.calls).isEmpty();
    });

    test('flash service receives no calls', () async {
      final flash = FakeFlashService();
      final services = buildServices(flash: flash);
      await _strategy.executeReal(_step(), services);
      check(flash.calls).isEmpty();
    });

    test('screen flash service receives no calls', () async {
      final screenFlash = FakeScreenFlashService();
      final services = buildServices(screenFlash: screenFlash);
      await _strategy.executeReal(_step(), services);
      check(screenFlash.calls).isEmpty();
    });
  });

  // ── Group 2: executeReal — simulation mode ─────────────────────────────────

  group('executeReal / no-op under simulation mode', () {
    test('completes without throwing in simulation', () async {
      final services = buildServices(isSimulation: true);
      await _strategy.executeReal(_step(), services);
    });

    test('audio service receives no calls in simulation', () async {
      final audio = FakeAudioService();
      final services = buildServices(audio: audio, isSimulation: true);
      await _strategy.executeReal(_step(), services);
      check(audio.calls).isEmpty();
    });

    test('messaging service receives no calls in simulation', () async {
      final messaging = FakeMessagingService();
      final services = buildServices(messaging: messaging, isSimulation: true);
      await _strategy.executeReal(_step(), services);
      check(messaging.calls).isEmpty();
    });

    test('vibration service receives no calls in simulation', () async {
      final vibration = FakeVibrationService();
      final services = buildServices(vibration: vibration, isSimulation: true);
      await _strategy.executeReal(_step(), services);
      check(vibration.calls).isEmpty();
    });
  });

  // ── Group 3: executeReal — every ButtonType ────────────────────────────────

  group('executeReal / no-op for every ButtonType', () {
    for (final buttonType in ButtonType.values) {
      test('no calls when buttonType is ${buttonType.name}', () async {
        final audio = FakeAudioService();
        final vibration = FakeVibrationService();
        final services = buildServices(audio: audio, vibration: vibration);
        final s = _step(config: HardwareButtonConfig(buttonType: buttonType));
        await _strategy.executeReal(s, services);
        check(audio.calls).isEmpty();
        check(vibration.calls).isEmpty();
      });
    }
  });

  // ── Group 4: executeReal — every PressPattern ──────────────────────────────

  group('executeReal / no-op for every PressPattern', () {
    for (final pressPattern in PressPattern.values) {
      test('no calls when pressPattern is ${pressPattern.name}', () async {
        final messaging = FakeMessagingService();
        final phone = FakePhoneService();
        final services = buildServices(messaging: messaging, phone: phone);
        final s = _step(
          config: HardwareButtonConfig(pressPattern: pressPattern),
        );
        await _strategy.executeReal(s, services);
        check(messaging.calls).isEmpty();
        check(phone.calls).isEmpty();
      });
    }
  });

  // ── Group 5: executeReal — boundary pressCount values ────────────────────

  group('executeReal / no-op at boundary pressCount values', () {
    for (final pressCount in [2, 5, 10]) {
      test('no calls when pressCount=$pressCount', () async {
        final flash = FakeFlashService();
        final services = buildServices(flash: flash);
        final s = _step(config: HardwareButtonConfig(pressCount: pressCount));
        await _strategy.executeReal(s, services);
        check(flash.calls).isEmpty();
      });
    }
  });

  // ── Group 6: executeReal — boundary longPressDurationSeconds values ───────

  group('executeReal / no-op at boundary longPressDurationSeconds values', () {
    for (final duration in [1.0, 2.0, 10.0]) {
      test('no calls when longPressDurationSeconds=$duration', () async {
        final screenFlash = FakeScreenFlashService();
        final services = buildServices(screenFlash: screenFlash);
        final s = _step(
          config: HardwareButtonConfig(longPressDurationSeconds: duration),
        );
        await _strategy.executeReal(s, services);
        check(screenFlash.calls).isEmpty();
      });
    }
  });

  // ── Group 7: executeReal — targetStepIndex variants ───────────────────────

  group('executeReal / no-op for targetStepIndex variants', () {
    test('no calls when targetStepIndex=-1 (advance to next)', () async {
      final audio = FakeAudioService();
      final services = buildServices(audio: audio);
      // targetStepIndex default value (-1) represents "advance to next step".
      // Constructed with all defaults to confirm the no-op contract holds.
      final s = _step(config: const HardwareButtonConfig());
      await _strategy.executeReal(s, services);
      check(audio.calls).isEmpty();
    });

    test('no calls when targetStepIndex=0 (jump to step 0)', () async {
      final vibration = FakeVibrationService();
      final services = buildServices(vibration: vibration);
      final s = _step(config: const HardwareButtonConfig(targetStepIndex: 0));
      await _strategy.executeReal(s, services);
      check(vibration.calls).isEmpty();
    });

    test('no calls when targetStepIndex=3 (positive index)', () async {
      final messaging = FakeMessagingService();
      final services = buildServices(messaging: messaging);
      final s = _step(config: const HardwareButtonConfig(targetStepIndex: 3));
      await _strategy.executeReal(s, services);
      check(messaging.calls).isEmpty();
    });
  });

  // ── Group 8: simulationDescription — exact literal ────────────────────────

  group('simulationDescription / exact literal', () {
    test('returns exactly "Button press detected!" for default config', () {
      final services = buildServices();
      final result = _strategy.simulationDescription(
        _step(config: const HardwareButtonConfig()),
        services,
      );
      check(result).equals('Button press detected!');
    });
  });

  // ── Group 9: simulationDescription — stable across config variations ───────

  group('simulationDescription / stable across all config variations', () {
    test('same literal for volumeDown + longPress + pressCount=10', () {
      final services = buildServices();
      final s = _step(
        config: const HardwareButtonConfig(
          buttonType: ButtonType.volumeDown,
          pressPattern: PressPattern.longPress,
          pressCount: 10,
          longPressDurationSeconds: 10.0,
          targetStepIndex: 5,
          blackScreenMode: true,
        ),
      );
      check(
        _strategy.simulationDescription(s, services),
      ).equals('Button press detected!');
    });

    // volumeUp and repeatPress are defaults; pressCount=2 (minimum) is the
    // non-default differentiator here. longPressDurationSeconds=1.0 is min.
    test('same literal for volumeUp + repeatPress at minimum pressCount', () {
      final services = buildServices();
      final s = _step(
        config: const HardwareButtonConfig(
          pressCount: 2,
          longPressDurationSeconds: 1.0,
        ),
      );
      check(
        _strategy.simulationDescription(s, services),
      ).equals('Button press detected!');
    });

    test(
      'same literal for volumeDown + default pressPattern + pressCount=5',
      () {
        final services = buildServices();
        final s = _step(
          config: const HardwareButtonConfig(buttonType: ButtonType.volumeDown),
        );
        check(
          _strategy.simulationDescription(s, services),
        ).equals('Button press detected!');
      },
    );

    test('same literal when blackScreenMode=true', () {
      final services = buildServices();
      final s = _step(
        config: const HardwareButtonConfig(blackScreenMode: true),
      );
      check(
        _strategy.simulationDescription(s, services),
      ).equals('Button press detected!');
    });

    // blackScreenMode=false is the default; this test verifies the
    // description is stable regardless of black-screen flag.
    test('same literal when blackScreenMode is at default (false)', () {
      final services = buildServices();
      final s = _step(config: const HardwareButtonConfig());
      check(
        _strategy.simulationDescription(s, services),
      ).equals('Button press detected!');
    });
  });

  // ── Group 10: simulationDescription — same in sim and non-sim modes ───────

  group('simulationDescription / same regardless of isSimulation flag', () {
    test('non-simulation services returns "Button press detected!"', () {
      final services = buildServices();
      final result = _strategy.simulationDescription(
        _step(config: const HardwareButtonConfig()),
        services,
      );
      check(result).equals('Button press detected!');
    });

    test('simulation services returns "Button press detected!"', () {
      final services = buildServices(isSimulation: true);
      final result = _strategy.simulationDescription(
        _step(config: const HardwareButtonConfig()),
        services,
      );
      check(result).equals('Button press detected!');
    });

    test('description is identical value across both modes', () {
      final services1 = buildServices();
      final services2 = buildServices(isSimulation: true);
      final s = _step(config: const HardwareButtonConfig());
      final desc1 = _strategy.simulationDescription(s, services1);
      final desc2 = _strategy.simulationDescription(s, services2);
      check(desc1).equals(desc2);
    });
  });

  // ── Group 11: simulationDescription — null config ─────────────────────────

  group('simulationDescription / step.config is null', () {
    test('returns "Button press detected!" when config is null', () {
      final services = buildServices();
      final result = _strategy.simulationDescription(_step(), services);
      check(result).equals('Button press detected!');
    });

    test('returns same literal with null config in simulation mode', () {
      final services = buildServices(isSimulation: true);
      final result = _strategy.simulationDescription(_step(), services);
      check(result).equals('Button press detected!');
    });
  });

  // ── Group 12: const-ness ───────────────────────────────────────────────────

  group('const-ness', () {
    test('two const instances are identical (canonical singleton)', () {
      const a = HardwareButtonStrategy();
      const b = HardwareButtonStrategy();
      check(identical(a, b)).isTrue();
    });

    test('three separate const instances are all identical', () {
      // The const constructor guarantees canonicalization: every
      // `const HardwareButtonStrategy()` expression resolves to the
      // same compile-time object.
      const a = HardwareButtonStrategy();
      const b = HardwareButtonStrategy();
      const c = HardwareButtonStrategy();
      check(identical(a, b)).isTrue();
      check(identical(b, c)).isTrue();
    });
  });

  // ── Group 13: executeReal — step.config is null ───────────────────────────

  group('executeReal / step.config is null', () {
    test('does not throw when config is null in real mode', () async {
      final services = buildServices();
      await _strategy.executeReal(_step(), services);
    });

    test('does not throw when config is null in simulation mode', () async {
      final services = buildServices(isSimulation: true);
      await _strategy.executeReal(_step(), services);
    });

    test(
      'all service call lists remain empty after null-config call',
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
        await _strategy.executeReal(_step(), services);
        check(audio.calls).isEmpty();
        check(vibration.calls).isEmpty();
        check(messaging.calls).isEmpty();
        check(phone.calls).isEmpty();
        check(recording.calls).isEmpty();
        check(flash.calls).isEmpty();
        check(screenFlash.calls).isEmpty();
      },
    );
  });
}
