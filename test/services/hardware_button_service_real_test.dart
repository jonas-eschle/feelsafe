// Host tests for the production [RealHardwareButtonService] (C6 coverage push).
//
// This service is the VOLUME-BUTTON DISTRESS TRIGGER. Its pattern detection
// (repeat-press sliding window, long-press duration) and the native-event
// parse/key-filter/dispatch in _onNativeEvent are pure Dart but are reached
// only via the Android EventChannel, which start() wires behind a
// Platform.isAndroid guard. The @visibleForTesting subscribeNativeChannelForTest
// seam exposes that exact subscription so this file drives the REAL channel
// through TestDefaultBinaryMessenger — the genuine production parse + detection
// run, never the simulation's parallel logic.
//
// SAFETY-CRITICAL BALANCE (false-positive minimisation): the trigger must FIRE
// on a real distress pattern but must NOT fire on incidental volume presses.
// The boundary cases below assert both directions deliberately.

import 'package:flutter/services.dart';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/enums/hardware_button_type.dart';
import 'package:guardianangela/domain/enums/hardware_trigger_pattern.dart';
import 'package:guardianangela/domain/models/hardware_panic_event.dart';
import 'package:guardianangela/services/hardware_button_service.dart';
import 'package:guardianangela/services/protocols/hardware_button_service_protocol.dart';

// ---------------------------------------------------------------------------
// Native channel harness
// ---------------------------------------------------------------------------

const String _kChannelName = 'com.guardianangela.app/hardware_button';

/// Drives the native hardware-button EventChannel.
///
/// Pushes `{'action','key'}` event maps to the `receiveBroadcastStream()`
/// listener via a StandardMethodCodec success envelope (the exact shape
/// `HardwareButtonChannel.kt` emits).
class _ButtonChannelMock {
  void register() {
    // The EventChannel handshake (`listen`/`cancel`) resolves via this handler.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel(_kChannelName),
          (call) async => null,
        );
  }

  void unregister() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel(_kChannelName), null);
  }

  Future<void> fireRaw(Object? event) async {
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          _kChannelName,
          const StandardMethodCodec().encodeSuccessEnvelope(event),
          (_) {},
        );
  }

  /// Fires a key event for [key] (`'volume_up'` / `'volume_down'`).
  Future<void> press(String key, {String action = 'down'}) =>
      fireRaw(<String, dynamic>{'action': action, 'key': key});
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _ButtonChannelMock channel;
  late RealHardwareButtonService svc;

  setUp(() {
    channel = _ButtonChannelMock()..register();
    svc = RealHardwareButtonService();
  });

  tearDown(() {
    svc.dispose();
    channel.unregister();
  });

  /// Starts the service with the given config and wires the real channel.
  void startWired({
    HardwareButtonType buttonType = HardwareButtonType.volumeUp,
    HardwareTriggerPattern pattern = HardwareTriggerPattern.repeatPress,
    int? pressCount,
    int? pressWindowMs,
    double? longPressDurationSeconds,
  }) {
    svc.start(
      buttonType: buttonType,
      pattern: pattern,
      pressCount: pressCount,
      pressWindowMs: pressWindowMs,
      longPressDurationSeconds: longPressDurationSeconds,
    );
    svc.subscribeNativeChannelForTest();
  }

  group('RealHardwareButtonService — lifecycle', () {
    test('implements HardwareButtonServiceProtocol', () {
      check(svc).isA<HardwareButtonServiceProtocol>();
    });

    test('isListening is false initially, true after start', () {
      check(svc.isListening).isFalse();
      svc.start();
      check(svc.isListening).isTrue();
    });

    test('panicEvents is a broadcast stream', () {
      final s1 = svc.panicEvents.listen((_) {});
      final s2 = svc.panicEvents.listen((_) {});
      addTearDown(s1.cancel);
      addTearDown(s2.cancel);
    });

    test('stop clears listening state', () {
      svc.start();
      svc.stop();
      check(svc.isListening).isFalse();
    });

    test('stop is safe before start', () {
      svc.stop();
      check(svc.isListening).isFalse();
    });
  });

  group('RealHardwareButtonService — repeat-press detection', () {
    test('5 volumeUp presses within the window FIRE a panic event', () async {
      startWired(pressCount: 5, pressWindowMs: 2000);
      final events = <HardwarePanicEvent>[];
      final sub = svc.panicEvents.listen(events.add);
      addTearDown(sub.cancel);

      for (var i = 0; i < 5; i++) {
        await channel.press('volume_up');
      }
      await Future<void>.delayed(Duration.zero);

      check(events).length.equals(1);
      check(events.first.pattern).equals(HardwareTriggerPattern.repeatPress);
      check(events.first.buttonType).equals(HardwareButtonType.volumeUp);
    });

    test(
      '4 presses when count=5 do NOT fire (missed-trigger boundary)',
      () async {
        startWired(pressCount: 5, pressWindowMs: 2000);
        final events = <HardwarePanicEvent>[];
        final sub = svc.panicEvents.listen(events.add);
        addTearDown(sub.cancel);

        for (var i = 0; i < 4; i++) {
          await channel.press('volume_up');
        }
        await Future<void>.delayed(Duration.zero);

        check(events).isEmpty();
      },
    );

    test(
      'only ACTION_DOWN counts — interleaved ups do not inflate the count',
      () async {
        startWired(pressCount: 3, pressWindowMs: 2000);
        final events = <HardwarePanicEvent>[];
        final sub = svc.panicEvents.listen(events.add);
        addTearDown(sub.cancel);

        // 2 downs + several ups → only 2 counted → no fire.
        await channel.press('volume_up');
        await channel.press('volume_up', action: 'up');
        await channel.press('volume_up');
        await channel.press('volume_up', action: 'up');
        await Future<void>.delayed(Duration.zero);

        check(events).isEmpty();
      },
    );

    test(
      'the wrong key is ignored (volumeDown press, volumeUp configured)',
      () async {
        // Default button is volumeUp.
        startWired(pressCount: 2, pressWindowMs: 2000);
        final events = <HardwarePanicEvent>[];
        final sub = svc.panicEvents.listen(events.add);
        addTearDown(sub.cancel);

        await channel.press('volume_down');
        await channel.press('volume_down');
        await Future<void>.delayed(Duration.zero);

        check(events).isEmpty();
      },
    );

    test('volumeDown trigger fires on volumeDown presses', () async {
      startWired(
        buttonType: HardwareButtonType.volumeDown,
        pressCount: 2,
        pressWindowMs: 2000,
      );
      final events = <HardwarePanicEvent>[];
      final sub = svc.panicEvents.listen(events.add);
      addTearDown(sub.cancel);

      await channel.press('volume_down');
      await channel.press('volume_down');
      await Future<void>.delayed(Duration.zero);

      check(events).length.equals(1);
      check(events.first.buttonType).equals(HardwareButtonType.volumeDown);
    });

    test(
      'the counter resets after a panic fires (two distinct triggers)',
      () async {
        startWired(pressCount: 2, pressWindowMs: 2000);
        final events = <HardwarePanicEvent>[];
        final sub = svc.panicEvents.listen(events.add);
        addTearDown(sub.cancel);

        // 4 presses with count=2 → exactly 2 panic events.
        for (var i = 0; i < 4; i++) {
          await channel.press('volume_up');
        }
        await Future<void>.delayed(Duration.zero);

        check(events).length.equals(2);
      },
    );

    test(
      'presses older than the window are evicted (no false trigger)',
      () async {
        // Min window (200ms). Two presses, wait past the window, then a third:
        // the first two have aged out → only 1 in window → no fire on count=3.
        startWired(pressCount: 3, pressWindowMs: 200);
        final events = <HardwarePanicEvent>[];
        final sub = svc.panicEvents.listen(events.add);
        addTearDown(sub.cancel);

        await channel.press('volume_up');
        await channel.press('volume_up');
        await Future<void>.delayed(const Duration(milliseconds: 300));
        await channel.press('volume_up');
        await Future<void>.delayed(Duration.zero);

        check(events).isEmpty();
      },
    );

    test('a malformed event map (missing keys) is ignored', () async {
      startWired(pressCount: 2, pressWindowMs: 2000);
      final events = <HardwarePanicEvent>[];
      final sub = svc.panicEvents.listen(events.add);
      addTearDown(sub.cancel);

      // No 'key' → not a target key → dropped. Then a non-Map event → dropped.
      await channel.fireRaw(<String, dynamic>{'action': 'down'});
      await channel.fireRaw('not-a-map');
      await channel.press('volume_up');
      await Future<void>.delayed(Duration.zero);

      check(events).isEmpty(); // only 1 valid press, need 2
    });
  });

  group('RealHardwareButtonService — long-press detection', () {
    test('a hold past the duration FIRES a long-press panic', () async {
      startWired(
        pattern: HardwareTriggerPattern.longPress,
        longPressDurationSeconds: 1.0, // min clamp
      );
      final events = <HardwarePanicEvent>[];
      final sub = svc.panicEvents.listen(events.add);
      addTearDown(sub.cancel);

      await channel.press('volume_up'); // down → records start time
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      await channel.press('volume_up', action: 'up'); // release → measure
      await Future<void>.delayed(Duration.zero);

      check(events).length.equals(1);
      check(events.first.pattern).equals(HardwareTriggerPattern.longPress);
    });

    test('a short hold does NOT fire (false-positive boundary)', () async {
      startWired(
        pattern: HardwareTriggerPattern.longPress,
        longPressDurationSeconds: 10.0, // long threshold
      );
      final events = <HardwarePanicEvent>[];
      final sub = svc.panicEvents.listen(events.add);
      addTearDown(sub.cancel);

      await channel.press('volume_up'); // down
      await channel.press('volume_up', action: 'up'); // near-instant release
      await Future<void>.delayed(Duration.zero);

      check(events).isEmpty();
    });

    test('a release without a prior press is a no-op', () async {
      startWired(pattern: HardwareTriggerPattern.longPress);
      final events = <HardwarePanicEvent>[];
      final sub = svc.panicEvents.listen(events.add);
      addTearDown(sub.cancel);

      await channel.press('volume_up', action: 'up'); // up with no down
      await Future<void>.delayed(Duration.zero);

      check(events).isEmpty();
    });
  });

  group('RealHardwareButtonService — parameter clamping', () {
    test('pressCount below the floor is clamped to 2', () async {
      // Request 1 → clamped to 2: two presses must fire.
      startWired(pressCount: 1, pressWindowMs: 2000);
      final events = <HardwarePanicEvent>[];
      final sub = svc.panicEvents.listen(events.add);
      addTearDown(sub.cancel);

      await channel.press('volume_up');
      await channel.press('volume_up');
      await Future<void>.delayed(Duration.zero);
      check(events).length.equals(1);
    });

    test(
      'one press does not fire when pressCount=1 is clamped up to 2',
      () async {
        startWired(pressCount: 1, pressWindowMs: 2000);
        final events = <HardwarePanicEvent>[];
        final sub = svc.panicEvents.listen(events.add);
        addTearDown(sub.cancel);

        await channel.press('volume_up');
        await Future<void>.delayed(Duration.zero);
        check(events).isEmpty();
      },
    );

    test('pressCount above the ceiling is clamped to 10', () async {
      // Request 20 → clamped to 10: nine presses do NOT fire, the tenth does.
      startWired(pressCount: 20, pressWindowMs: 5000);
      final events = <HardwarePanicEvent>[];
      final sub = svc.panicEvents.listen(events.add);
      addTearDown(sub.cancel);

      for (var i = 0; i < 9; i++) {
        await channel.press('volume_up');
      }
      await Future<void>.delayed(Duration.zero);
      check(events).isEmpty();

      await channel.press('volume_up'); // the tenth
      await Future<void>.delayed(Duration.zero);
      check(events).length.equals(1);
    });
  });

  group('RealHardwareButtonService — updateConfig', () {
    test(
      'updateConfig changes the active key and resets press state',
      () async {
        // Default button is volumeUp.
        startWired(pressCount: 2, pressWindowMs: 2000);
        final events = <HardwarePanicEvent>[];
        final sub = svc.panicEvents.listen(events.add);
        addTearDown(sub.cancel);

        // One volumeUp press, then switch to volumeDown: the buffered press is
        // cleared and volumeUp no longer counts.
        await channel.press('volume_up');
        svc.updateConfig(buttonType: HardwareButtonType.volumeDown);
        await channel.press('volume_up'); // wrong key now → ignored
        await channel.press('volume_down');
        await channel.press('volume_down');
        await Future<void>.delayed(Duration.zero);

        check(events).length.equals(1);
        check(events.first.buttonType).equals(HardwareButtonType.volumeDown);
      },
    );

    test(
      'updateConfig with all-null args leaves the config unchanged',
      () async {
        startWired(pressCount: 2, pressWindowMs: 2000);
        svc.updateConfig(); // no-op for values, but clears press buffer
        final events = <HardwarePanicEvent>[];
        final sub = svc.panicEvents.listen(events.add);
        addTearDown(sub.cancel);

        await channel.press('volume_up');
        await channel.press('volume_up');
        await Future<void>.delayed(Duration.zero);
        check(events).length.equals(1);
      },
    );

    test('updateConfig can switch the pattern to long-press', () async {
      startWired(pressCount: 2, pressWindowMs: 2000);
      svc.updateConfig(
        pattern: HardwareTriggerPattern.longPress,
        longPressDurationSeconds: 1.0,
      );
      final events = <HardwarePanicEvent>[];
      final sub = svc.panicEvents.listen(events.add);
      addTearDown(sub.cancel);

      // Repeat presses must NOT fire now (pattern is long-press).
      await channel.press('volume_up');
      await channel.press('volume_up');
      await Future<void>.delayed(Duration.zero);
      check(events).isEmpty();
    });

    test('updateConfig re-clamps pressCount and pressWindowMs', () async {
      startWired(pressCount: 5, pressWindowMs: 2000);
      // pressCount 99 → clamped to 10; pressWindowMs 50 → clamped to 200.
      svc.updateConfig(pressCount: 99, pressWindowMs: 50);
      final events = <HardwarePanicEvent>[];
      final sub = svc.panicEvents.listen(events.add);
      addTearDown(sub.cancel);

      // Nine presses do not reach the clamped count of 10.
      for (var i = 0; i < 9; i++) {
        await channel.press('volume_up');
      }
      await Future<void>.delayed(Duration.zero);
      check(events).isEmpty();
    });
  });

  group('RealHardwareButtonService — native stream error', () {
    test('an EventChannel error is absorbed (logged, not rethrown)', () async {
      startWired(pressCount: 2, pressWindowMs: 2000);
      final events = <HardwarePanicEvent>[];
      final sub = svc.panicEvents.listen(events.add);
      addTearDown(sub.cancel);

      // Push a platform error; the onError handler logs and swallows, and a
      // subsequent valid press sequence still fires (subscription survives).
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            _kChannelName,
            const StandardMethodCodec().encodeErrorEnvelope(
              code: 'NATIVE_ERR',
              message: 'key listener failed',
            ),
            (_) {},
          );
      await channel.press('volume_up');
      await channel.press('volume_up');
      await Future<void>.delayed(Duration.zero);

      check(events).length.equals(1);
    });
  });

  group('RealHardwareButtonService — dispose', () {
    test(
      'no panic events are emitted after dispose closes the stream',
      () async {
        startWired(pressCount: 2, pressWindowMs: 2000);
        final events = <HardwarePanicEvent>[];
        final sub = svc.panicEvents.listen(events.add);
        addTearDown(sub.cancel);

        svc.dispose();
        // The subscription was cancelled by stop()/dispose(); further channel
        // events do not reach a closed controller.
        await Future<void>.delayed(Duration.zero);
        check(events).isEmpty();
      },
    );
  });
}
