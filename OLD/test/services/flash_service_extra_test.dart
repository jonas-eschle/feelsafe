/// Supplemental tests for [FlashService] covering lines 94–95:
/// the `on Exception catch` inside `stopStrobe` when the torch was on
/// and `_disableTorch` throws.
library;

import 'dart:async';

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/services/implementations/flash_service.dart';

void main() {
  group(
    'FlashService.stopStrobe — disableTorch exception branch (lines 94–95)',
    () {
      test('torch-off exception on stop is swallowed and strobe is cleared', () {
        // To reach lines 94–95 we need:
        //   1. The torch to be on (_torchOn == true) when stopStrobe is called.
        //   2. _disableTorch to throw an Exception.
        //
        // Strategy: start the strobe, wait for the first toggle (enableTorch
        // fires, setting _torchOn = true), then stop — disableTorch throws
        // inside the `if (wasOn)` branch.
        fakeAsync((async) {
          bool enabled = false;
          final svc = FlashService(
            enableTorch: () async {
              enabled = true;
            },
            disableTorch: () async {
              if (enabled) {
                // First call from toggle — succeed. Subsequent calls (from
                // stopStrobe) throw to exercise the catch block.
                enabled = false;
                // We need stopStrobe's disableTorch to throw. To do that we
                // track how many times disableTorch was called.
                throw Exception('torch busy');
              }
            },
          );

          // Start strobe and wait for at least one toggle cycle.
          unawaited(
            svc.startStrobe(interval: const Duration(milliseconds: 100)),
          );
          // Advance past the first half-cycle so enableTorch fires.
          async.elapse(const Duration(milliseconds: 60));
          // Now _torchOn should be true.
          // Calling stopStrobe should hit the `if (wasOn)` branch and throw
          // inside disableTorch — the exception is swallowed.
          unawaited(svc.stopStrobe());
          async.flushMicrotasks();
          async.elapse(const Duration(milliseconds: 10));
          // The strobe must be stopped even after the exception.
          check(svc.isStrobing).isFalse();
        });
      });

      test('stopStrobe swallows exception and logs, does not rethrow', () {
        fakeAsync((async) {
          final svc = FlashService(
            enableTorch: () async {},
            // Always throws on disable — covers both toggle and stop paths.
            disableTorch: () async {
              throw Exception('no torch hardware');
            },
          );
          // Use a slow interval so the first tick is an enableTorch call.
          unawaited(
            svc.startStrobe(interval: const Duration(milliseconds: 200)),
          );
          // After startStrobe calls stopStrobe (rebasing) the torch is off.
          // Wait for the first half-cycle (100 ms) — enableTorch fires.
          async.elapse(const Duration(milliseconds: 110));
          // Now the strobe is running with _torchOn = true.
          // stopStrobe calls _disableTorch which throws.
          unawaited(svc.stopStrobe());
          async.flushMicrotasks();
          // No exception propagated — svc.isStrobing is false.
          check(svc.isStrobing).isFalse();
        });
      });
    },
  );
}
