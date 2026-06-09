// Host tests for the production [RealFlashService] (C6 coverage push).
//
// RealFlashService runs detached async SOS / continuous strobe loops that
// toggle the torch via `package:torch_light` (MethodChannel
// `com.svprdga.torchlight/main`) and sleep between steps. The simulation
// counterpart (flash_service_test.dart) covers the timing model; this file
// drives the REAL loops under fakeAsync against a mocked torch channel,
// exercising:
//   * the SOS morse cycle (··· −−− ···) and the continuous 200/200 strobe,
//   * graceful degradation when the torch hardware throws (spec 05 §Graceful
//     Degradation) — the loop must stop, never crash,
//   * the Completer race-fix in stopFlash (spec 05:613-614) — no torch toggle
//     occurs after stopFlash resolves.

import 'package:flutter/services.dart';

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/services/flash_service.dart';
import 'package:guardianangela/services/protocols/flash_service_protocol.dart';

// ---------------------------------------------------------------------------
// Torch channel harness
// ---------------------------------------------------------------------------

const String _kTorchChannel = 'com.svprdga.torchlight/main';

/// Mocks the torch_light MethodChannel.
///
/// Records every enable/disable call and, when [failTorch] is set, throws a
/// [PlatformException] so torch_light rethrows its typed exception and the
/// service's graceful-degradation catch runs.
class _TorchMock {
  final List<String> calls = [];
  bool failTorch = false;

  void register() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel(_kTorchChannel), (
          call,
        ) async {
          calls.add(call.method);
          if (failTorch) {
            throw PlatformException(code: 'torch_unavailable');
          }
          return null;
        });
  }

  void unregister() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel(_kTorchChannel), null);
  }

  int get enableCount => calls.where((m) => m == 'enable_torch').length;
  int get disableCount => calls.where((m) => m == 'disable_torch').length;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _TorchMock torch;

  setUp(() => torch = _TorchMock()..register());
  tearDown(() => torch.unregister());

  group('RealFlashService — basics', () {
    test('implements FlashServiceProtocol', () {
      check(RealFlashService()).isA<FlashServiceProtocol>();
    });

    test('isFlashing starts false', () {
      check(RealFlashService().isFlashing).isFalse();
    });

    test('stopFlash before any start is a no-op (no torch calls)', () {
      fakeAsync((async) {
        final s = RealFlashService();
        s.stopFlash();
        async.flushMicrotasks();
        check(s.isFlashing).isFalse();
        check(torch.calls).isEmpty();
      });
    });
  });

  group('RealFlashService — SOS loop', () {
    test('startSosFlash sets isFlashing and begins toggling the torch', () {
      fakeAsync((async) {
        final s = RealFlashService();
        s.startSosFlash();
        check(s.isFlashing).isTrue();

        // Advance through the first few morse symbols.
        async.elapse(const Duration(milliseconds: 1000));
        check(torch.enableCount).isGreaterThan(0);
        check(torch.disableCount).isGreaterThan(0);

        s.stopFlash();
        async.elapse(const Duration(seconds: 2));
      });
    });

    test('a full SOS cycle toggles the torch nine times (··· −−− ···)', () {
      fakeAsync((async) {
        final s = RealFlashService();
        s.startSosFlash();
        // One complete S-O-S cycle is ~6.6s; elapse past it so all three
        // letters (dots, dashes, dots) run before stopping.
        async.elapse(const Duration(milliseconds: 7000));
        // 9 symbols → 9 enable + at least 9 disable toggles per cycle.
        check(torch.enableCount).isGreaterOrEqual(9);
        check(torch.disableCount).isGreaterOrEqual(9);
        s.stopFlash();
        async.elapse(const Duration(seconds: 2));
      });
    });

    test('SOS turns the torch off when the loop exits after stop', () {
      fakeAsync((async) {
        final s = RealFlashService();
        s.startSosFlash();
        async.elapse(const Duration(milliseconds: 800));
        s.stopFlash();
        async.elapse(const Duration(seconds: 2));
        // The final action of the loop is a torch-off.
        check(torch.calls.last).equals('disable_torch');
        check(s.isFlashing).isFalse();
      });
    });

    test('startSosFlash while already flashing restarts cleanly', () {
      fakeAsync((async) {
        final s = RealFlashService();
        s.startSosFlash();
        async.elapse(const Duration(milliseconds: 400));
        // Second start stops the old loop (awaits its Completer) and begins
        // anew. The old loop is parked in a sleep, so time must advance for it
        // to exit and release stopFlash before the new loop sets the flag.
        s.startSosFlash();
        async.elapse(const Duration(seconds: 2));
        check(s.isFlashing).isTrue();
        s.stopFlash();
        async.elapse(const Duration(seconds: 2));
      });
    });
  });

  group('RealFlashService — continuous loop', () {
    test('startContinuousFlash strobes on/off at 200ms cadence', () {
      fakeAsync((async) {
        final s = RealFlashService();
        s.startContinuousFlash();
        check(s.isFlashing).isTrue();

        // 1000ms / 400ms-per-cycle → at least 2 on/off cycles.
        async.elapse(const Duration(milliseconds: 1000));
        check(torch.enableCount).isGreaterOrEqual(2);
        check(torch.disableCount).isGreaterOrEqual(2);

        s.stopFlash();
        async.elapse(const Duration(seconds: 1));
        check(torch.calls.last).equals('disable_torch');
      });
    });

    test('continuous restart while flashing keeps isFlashing true', () {
      fakeAsync((async) {
        final s = RealFlashService();
        s.startContinuousFlash();
        async.elapse(const Duration(milliseconds: 400));
        s.startContinuousFlash();
        async.elapse(const Duration(seconds: 1));
        check(s.isFlashing).isTrue();
        s.stopFlash();
        async.elapse(const Duration(seconds: 1));
      });
    });
  });

  group(
    'RealFlashService — stopFlash Completer race-fix (spec 05:613-614)',
    () {
      test('no torch toggle occurs after stopFlash resolves (SOS)', () {
        fakeAsync((async) {
          final s = RealFlashService();
          s.startSosFlash();
          async.elapse(const Duration(milliseconds: 600));

          var resolved = false;
          s.stopFlash().then((_) => resolved = true);
          // Drain until stopFlash's awaited Completer completes.
          async.elapse(const Duration(seconds: 2));
          check(resolved).isTrue();

          final countAtResolve = torch.calls.length;
          async.elapse(const Duration(seconds: 2));
          // After stopFlash resolves the loop has exited — no further calls.
          check(torch.calls.length).equals(countAtResolve);
        });
      });

      test('no torch toggle occurs after stopFlash resolves (continuous)', () {
        fakeAsync((async) {
          final s = RealFlashService();
          s.startContinuousFlash();
          async.elapse(const Duration(milliseconds: 600));

          s.stopFlash();
          async.elapse(const Duration(seconds: 1));
          final countAtResolve = torch.calls.length;
          async.elapse(const Duration(seconds: 2));
          check(torch.calls.length).equals(countAtResolve);
        });
      });
    },
  );

  group('RealFlashService — graceful degradation (spec 05 §Graceful)', () {
    test('SOS degrades silently when the torch hardware throws', () {
      fakeAsync((async) {
        torch.failTorch = true;
        final s = RealFlashService();
        s.startSosFlash();
        // The first enable throws → _setTorch catches, sets _isFlashing=false,
        // the loop exits on its next check. No exception escapes the loop.
        async.elapse(const Duration(seconds: 2));
        check(s.isFlashing).isFalse();
      });
    });

    test('continuous degrades silently when the torch hardware throws', () {
      fakeAsync((async) {
        torch.failTorch = true;
        final s = RealFlashService();
        s.startContinuousFlash();
        async.elapse(const Duration(seconds: 2));
        check(s.isFlashing).isFalse();
      });
    });

    test(
      'stopFlash resolves even when degradation already stopped the loop',
      () {
        fakeAsync((async) {
          torch.failTorch = true;
          final s = RealFlashService();
          s.startSosFlash();
          async.elapse(const Duration(milliseconds: 500));

          var resolved = false;
          s.stopFlash().then((_) => resolved = true);
          async.elapse(const Duration(seconds: 1));
          check(resolved).isTrue();
        });
      },
    );
  });
}
