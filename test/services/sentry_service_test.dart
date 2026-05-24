// Tests for SentryService (Real via injectable seam + Simulation).
//
// RealSentryService is tested via a fake SentrySdk implementation so no
// actual Sentry SDK initialization occurs. Tests verify the idempotency
// rules, opt-in guard, and capture routing.

import 'package:checks/checks.dart';
import 'package:sentry_flutter/sentry_flutter.dart' show SentryFlutterOptions;
import 'package:test/test.dart';

import 'package:guardianangela/services/sentry_service.dart';
import 'package:guardianangela/services/sim/sentry_service_sim.dart';

// ---------------------------------------------------------------------------
// Fake SentrySdk for tests
// ---------------------------------------------------------------------------

class _FakeSentrySdk implements SentrySdk {
  int initCallCount = 0;
  int captureCallCount = 0;
  int closeCallCount = 0;

  Object? lastError;
  StackTrace? lastStack;
  String? lastDsn;
  double? lastRate;

  @override
  Future<void> init(
    SentryFlutterOptions Function(SentryFlutterOptions) configureFn,
  ) async {
    initCallCount++;
    // Run the configureFn to capture DSN / rate.
    final opts = SentryFlutterOptions();
    configureFn(opts);
    lastDsn = opts.dsn;
    lastRate = opts.tracesSampleRate;
  }

  @override
  Future<void> captureException(
    Object error, {
    StackTrace? stackTrace,
  }) async {
    captureCallCount++;
    lastError = error;
    lastStack = stackTrace;
  }

  @override
  Future<void> close() async {
    closeCallCount++;
  }
}

// ---------------------------------------------------------------------------
// RealSentryService tests
// ---------------------------------------------------------------------------

RealSentryService _real(_FakeSentrySdk sdk) => RealSentryService(sdk: sdk);

void main() {
  group('RealSentryService', () {
    // ---- initialize — disabled path ----

    test('initialize(enabled:false) never calls sdk.init', () async {
      final sdk = _FakeSentrySdk();
      final svc = _real(sdk);
      await svc.initialize(enabled: false);
      check(sdk.initCallCount).equals(0);
    });

    test('initialize(enabled:false) does not throw', () async {
      final sdk = _FakeSentrySdk();
      final svc = _real(sdk);
      await svc.initialize(enabled: false);
    });

    // ---- initialize — enabled path ----

    test('initialize(enabled:true) calls sdk.init once with DSN', () async {
      final sdk = _FakeSentrySdk();
      final svc = _real(sdk);
      await svc.initialize(
        enabled: true,
        dsn: 'https://key@o123.ingest.de.sentry.io/456',
      );
      check(sdk.initCallCount).equals(1);
      check(sdk.lastDsn).equals(
        'https://key@o123.ingest.de.sentry.io/456',
      );
    });

    test('initialize(enabled:true) passes tracesSampleRate', () async {
      final sdk = _FakeSentrySdk();
      final svc = _real(sdk);
      await svc.initialize(
        enabled: true,
        dsn: 'https://key@o123.ingest.de.sentry.io/456',
        tracesSampleRate: 0.2,
      );
      check(sdk.lastRate).equals(0.2);
    });

    test('initialize(enabled:true) with null DSN skips sdk.init', () async {
      final sdk = _FakeSentrySdk();
      final svc = _real(sdk);
      await svc.initialize(enabled: true);
      check(sdk.initCallCount).equals(0);
    });

    // ---- idempotency ----

    test('double-init with same args is a no-op', () async {
      final sdk = _FakeSentrySdk();
      final svc = _real(sdk);
      await svc.initialize(enabled: false);
      await svc.initialize(enabled: false);
      check(sdk.initCallCount).equals(0);
    });

    test('double-init with same enabled+dsn+rate is a no-op', () async {
      final sdk = _FakeSentrySdk();
      final svc = _real(sdk);
      const dsn = 'https://key@o123.ingest.de.sentry.io/456';
      await svc.initialize(
        enabled: true,
        dsn: dsn,
        tracesSampleRate: 0.1,
      );
      await svc.initialize(
        enabled: true,
        dsn: dsn,
        tracesSampleRate: 0.1,
      );
      check(sdk.initCallCount).equals(1);
    });

    test('double-init with different DSN throws StateError', () async {
      final sdk = _FakeSentrySdk();
      final svc = _real(sdk);
      await svc.initialize(
        enabled: true,
        dsn: 'https://key@o123.ingest.de.sentry.io/456',
      );
      await expectLater(
        svc.initialize(
          enabled: true,
          dsn: 'https://other@o999.ingest.de.sentry.io/789',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('double-init disabled→enabled throws StateError', () async {
      final sdk = _FakeSentrySdk();
      final svc = _real(sdk);
      await svc.initialize(enabled: false);
      await expectLater(
        svc.initialize(enabled: true, dsn: 'https://x@o1.ingest.de.sentry.io/1'),
        throwsA(isA<StateError>()),
      );
    });

    // ---- captureException ----

    test('captureException before initialize is no-op', () async {
      final sdk = _FakeSentrySdk();
      final svc = _real(sdk);
      await svc.captureException(Exception('err'), null);
      check(sdk.captureCallCount).equals(0);
    });

    test('captureException when disabled is no-op', () async {
      final sdk = _FakeSentrySdk();
      final svc = _real(sdk);
      await svc.initialize(enabled: false);
      await svc.captureException(Exception('err'), null);
      check(sdk.captureCallCount).equals(0);
    });

    test('captureException when enabled calls sdk.captureException', () async {
      final sdk = _FakeSentrySdk();
      final svc = _real(sdk);
      await svc.initialize(
        enabled: true,
        dsn: 'https://key@o123.ingest.de.sentry.io/456',
      );
      final err = Exception('test error');
      await svc.captureException(err, null);
      check(sdk.captureCallCount).equals(1);
      check(sdk.lastError).equals(err);
    });

    test('captureException passes stack trace to sdk', () async {
      final sdk = _FakeSentrySdk();
      final svc = _real(sdk);
      await svc.initialize(
        enabled: true,
        dsn: 'https://key@o123.ingest.de.sentry.io/456',
      );
      final stack = StackTrace.current;
      await svc.captureException(Exception('e'), stack);
      check(sdk.lastStack).equals(stack);
    });

    // ---- close ----

    test('close when not initialized is no-op', () async {
      final sdk = _FakeSentrySdk();
      final svc = _real(sdk);
      await svc.close();
      check(sdk.closeCallCount).equals(0);
    });

    test('close when enabled calls sdk.close', () async {
      final sdk = _FakeSentrySdk();
      final svc = _real(sdk);
      await svc.initialize(
        enabled: true,
        dsn: 'https://key@o123.ingest.de.sentry.io/456',
      );
      await svc.close();
      check(sdk.closeCallCount).equals(1);
    });

    test('close when disabled does not call sdk.close', () async {
      final sdk = _FakeSentrySdk();
      final svc = _real(sdk);
      await svc.initialize(enabled: false);
      await svc.close();
      check(sdk.closeCallCount).equals(0);
    });

    test('captureException after close is no-op', () async {
      final sdk = _FakeSentrySdk();
      final svc = _real(sdk);
      await svc.initialize(
        enabled: true,
        dsn: 'https://key@o123.ingest.de.sentry.io/456',
      );
      await svc.close();
      await svc.captureException(Exception('after close'), null);
      check(sdk.captureCallCount).equals(0);
    });

    test('close resets initialized state — can re-initialize after close', () async {
      final sdk = _FakeSentrySdk();
      final svc = _real(sdk);
      await svc.initialize(enabled: false);
      await svc.close();
      // After close, state is reset — re-initializing should not throw.
      await svc.initialize(enabled: false);
      check(sdk.initCallCount).equals(0);
    });
  });

  // -------------------------------------------------------------------------
  // SimulationSentryService tests
  // -------------------------------------------------------------------------

  group('SimulationSentryService', () {
    late SimulationSentryService svc;

    setUp(() => svc = SimulationSentryService());

    test('initialize(enabled:true) marks service as initialized', () async {
      await svc.initialize(enabled: true);
      check(svc.isInitialized).isTrue();
    });

    test('initialize(enabled:false) does not mark service as initialized', () async {
      await svc.initialize(enabled: false);
      check(svc.isInitialized).isFalse();
    });

    test('captureException before initialize records nothing', () async {
      await svc.captureException(Exception('e'), null);
      check(svc.captures).isEmpty();
    });

    test('captureException after enabled init records the capture', () async {
      await svc.initialize(enabled: true);
      await svc.captureException(Exception('err'), null);
      check(svc.captures).length.equals(1);
      check(svc.captures.first.error.toString()).contains('err');
    });

    test('close resets initialized state', () async {
      await svc.initialize(enabled: true);
      await svc.close();
      check(svc.isInitialized).isFalse();
    });

    test('captures not recorded after close', () async {
      await svc.initialize(enabled: true);
      await svc.close();
      await svc.captureException(Exception('after close'), null);
      check(svc.captures).isEmpty();
    });

    test('reset clears captures and state', () async {
      await svc.initialize(enabled: true);
      await svc.captureException(Exception('x'), null);
      svc.reset();
      check(svc.captures).isEmpty();
      check(svc.isInitialized).isFalse();
    });

    test('never calls any real Sentry SDK', () async {
      // This test verifies that no real SDK calls are made by simply
      // succeeding — if any Sentry static method were called it would
      // throw in a pure-Dart test environment.
      await svc.initialize(
        enabled: true,
        dsn: 'https://real@o1.ingest.de.sentry.io/1',
      );
      await svc.captureException(Exception('test'), null);
      await svc.close();
    });
  });
}
