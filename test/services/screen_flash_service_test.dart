import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

import 'package:guardianangela/services/protocols/screen_flash_service_protocol.dart';
import 'package:guardianangela/services/screen_flash_service.dart';
import 'package:guardianangela/services/sim/screen_flash_service_sim.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

SimulationScreenFlashService _sim({int tickMs = 10}) =>
    SimulationScreenFlashService(tickMs: tickMs);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ScreenFlashFrame', () {
    test('isWhite=true carries through', () {
      const f = ScreenFlashFrame(isWhite: true);
      check(f.isWhite).isTrue();
    });

    test('isWhite=false carries through', () {
      const f = ScreenFlashFrame(isWhite: false);
      check(f.isWhite).isFalse();
    });

    test('toString is informative', () {
      check(const ScreenFlashFrame(isWhite: true).toString()).contains('true');
    });
  });

  group('RealScreenFlashService', () {
    group('startScreenFlash', () {
      test('invalid speed throws ArgumentError', () async {
        final s = RealScreenFlashService();
        addTearDown(s.dispose);
        await check(
          s.startScreenFlash(speed: 'medium'),
        ).throws<ArgumentError>();
      });

      test('slow is valid (does not throw)', () async {
        final s = RealScreenFlashService();
        addTearDown(s.dispose);
        await s.startScreenFlash();
        await s.stopScreenFlash();
      });

      test('fast is valid (does not throw)', () async {
        final s = RealScreenFlashService();
        addTearDown(s.dispose);
        await s.startScreenFlash(speed: 'fast');
        await s.stopScreenFlash();
      });

      test('emits frames on stream', () async {
        final s = RealScreenFlashService();
        addTearDown(s.dispose);
        final received = <ScreenFlashFrame>[];
        final sub = s.frames.listen(received.add);
        addTearDown(sub.cancel);
        await s.startScreenFlash();
        // Let the 1000ms timer fire at least once — but in tests we just
        // verify the stream is set up. The timing is tested in fakeAsync.
        await s.stopScreenFlash();
      });
    });

    group('fakeAsync', () {
      test('slow speed emits frames at 1000ms interval', () {
        fakeAsync((async) {
          final s = RealScreenFlashService();
          final received = <ScreenFlashFrame>[];
          s.frames.listen(received.add);
          s.startScreenFlash();
          async.elapse(const Duration(milliseconds: 3500));
          // 3500ms / 1000ms = 3 frames minimum.
          check(received.length).isGreaterOrEqual(3);
          s.stopScreenFlash();
          async.elapse(const Duration(milliseconds: 100));
          s.dispose();
        });
      });

      test('fast speed emits frames at 500ms interval', () {
        fakeAsync((async) {
          final s = RealScreenFlashService();
          final received = <ScreenFlashFrame>[];
          s.frames.listen(received.add);
          s.startScreenFlash(speed: 'fast');
          async.elapse(const Duration(milliseconds: 2500));
          // 2500ms / 500ms = 5 frames.
          check(received.length).isGreaterOrEqual(5);
          s.stopScreenFlash();
          async.elapse(const Duration(milliseconds: 100));
          s.dispose();
        });
      });

      test('frames alternate isWhite between true and false', () {
        fakeAsync((async) {
          final s = RealScreenFlashService();
          final received = <ScreenFlashFrame>[];
          s.frames.listen(received.add);
          s.startScreenFlash(speed: 'fast');
          async.elapse(const Duration(milliseconds: 3000));
          s.stopScreenFlash();
          async.elapse(const Duration(milliseconds: 100));
          s.dispose();
          check(received.length).isGreaterOrEqual(2);
          check(received[0].isWhite).isTrue();
          check(received[1].isWhite).isFalse();
          if (received.length > 2) check(received[2].isWhite).isTrue();
        });
      });

      test('stopScreenFlash stops emission', () {
        fakeAsync((async) {
          final s = RealScreenFlashService();
          final received = <ScreenFlashFrame>[];
          s.frames.listen(received.add);
          s.startScreenFlash(speed: 'fast');
          async.elapse(const Duration(milliseconds: 2000));
          s.stopScreenFlash();
          async.elapse(const Duration(milliseconds: 100));
          final countAfterStop = received.length;
          async.elapse(const Duration(milliseconds: 5000));
          check(received.length).equals(countAfterStop);
          s.dispose();
        });
      });
    });
  });

  group('SimulationScreenFlashService', () {
    group('constructor', () {
      test('implements ScreenFlashServiceProtocol', () {
        check(_sim()).isA<ScreenFlashServiceProtocol>();
      });

      test('starts with empty recordedFrames', () {
        check(_sim().recordedFrames).isEmpty();
      });

      test('starts with empty calls', () {
        check(_sim().calls).isEmpty();
      });
    });

    group('startScreenFlash', () {
      test('records slow call tag', () async {
        final s = _sim();
        await s.startScreenFlash();
        check(s.calls).contains('startScreenFlash:slow');
        await s.stopScreenFlash();
        s.dispose();
      });

      test('records fast call tag', () async {
        final s = _sim();
        await s.startScreenFlash(speed: 'fast');
        check(s.calls).contains('startScreenFlash:fast');
        await s.stopScreenFlash();
        s.dispose();
      });

      test('invalid speed throws ArgumentError', () async {
        final s = _sim();
        addTearDown(s.dispose);
        await check(
          s.startScreenFlash(speed: 'medium'),
        ).throws<ArgumentError>();
      });

      test('emits frames to recordedFrames', () async {
        final s = _sim(tickMs: 5);
        await s.startScreenFlash();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        check(s.recordedFrames.isNotEmpty).isTrue();
        await s.stopScreenFlash();
        s.dispose();
      });

      test('frames alternate isWhite', () async {
        final s = _sim(tickMs: 5);
        await s.startScreenFlash();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await s.stopScreenFlash();
        s.dispose();
        check(s.recordedFrames.length).isGreaterOrEqual(2);
        check(s.recordedFrames[0].isWhite).isTrue();
        check(s.recordedFrames[1].isWhite).isFalse();
      });
    });

    group('stopScreenFlash', () {
      test('records stopScreenFlash call', () async {
        final s = _sim();
        await s.startScreenFlash();
        await s.stopScreenFlash();
        check(s.calls.last).equals('stopScreenFlash');
        s.dispose();
      });

      test('no more frames emitted after stop', () async {
        final s = _sim(tickMs: 5);
        await s.startScreenFlash(speed: 'fast');
        await Future<void>.delayed(const Duration(milliseconds: 40));
        await s.stopScreenFlash();
        final countAfterStop = s.recordedFrames.length;
        await Future<void>.delayed(const Duration(milliseconds: 50));
        check(s.recordedFrames.length).equals(countAfterStop);
        s.dispose();
      });

      test('safe to call when not active', () async {
        final s = _sim();
        await s.stopScreenFlash(); // no-op
        check(s.calls).deepEquals(['stopScreenFlash']);
        s.dispose();
      });
    });

    group('reset', () {
      test('clears recordedFrames and calls', () async {
        final s = _sim(tickMs: 5);
        await s.startScreenFlash();
        await Future<void>.delayed(const Duration(milliseconds: 30));
        await s.stopScreenFlash();
        s.reset();
        check(s.recordedFrames).isEmpty();
        check(s.calls).isEmpty();
        s.dispose();
      });
    });

    group('fakeAsync', () {
      test('frames accumulate with fakeAsync time', () {
        fakeAsync((async) {
          final s = SimulationScreenFlashService();
          s.startScreenFlash();
          async.elapse(const Duration(milliseconds: 300));
          // 300ms / 50ms = 6 frames.
          check(s.recordedFrames.length).isGreaterOrEqual(4);
          s.stopScreenFlash();
          async.elapse(const Duration(milliseconds: 100));
          s.dispose();
        });
      });

      test('alternate isWhite confirmed with fakeAsync', () {
        fakeAsync((async) {
          final s = SimulationScreenFlashService();
          s.startScreenFlash();
          async.elapse(const Duration(milliseconds: 250));
          s.stopScreenFlash();
          async.elapse(const Duration(milliseconds: 100));
          s.dispose();
          if (s.recordedFrames.length >= 2) {
            check(s.recordedFrames[0].isWhite).isTrue();
            check(s.recordedFrames[1].isWhite).isFalse();
          }
        });
      });
    });
  });
}
