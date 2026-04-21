/// Plugin-boundary tests for [initSentry] / [reportException].
///
/// Uses the `sentryInitOverride` / `sentryCaptureOverride` test seams
/// to exercise the real-branch code paths (the EU-DSN happy path, the
/// options it would configure, and the capture call in
/// [reportException]) without spinning up native Sentry transport.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:guardianangela/core/telemetry/sentry_config.dart';

class _MockScope extends Mock implements Scope {}

void main() {
  setUp(resetSentryForTesting);

  group('initSentry (override seam)', () {
    test('calls the override with EU DSN, runs appRunner, flips latch',
        () async {
      FlutterOptionsConfiguration? capturedBuilder;
      var ranAppRunner = 0;
      sentryInitOverride = (builder, runner) async {
        capturedBuilder = builder;
        await runner();
      };
      var appRan = 0;
      await initSentry(
        enabled: true,
        dsn: 'https://x@o0.ingest.de.sentry.io/0',
        release: '1.0.0',
        appRunner: () async {
          appRan++;
        },
      );
      check(capturedBuilder).isNotNull();
      // Drive the builder so the options block runs — asserts it sets
      // the DSN/release/environment fields.
      final options = SentryFlutterOptions()..dsn = 'placeholder';
      capturedBuilder!(options);
      check(options.dsn).equals('https://x@o0.ingest.de.sentry.io/0');
      check(options.release).equals('1.0.0');
      check(options.sendDefaultPii).isFalse();
      check(options.attachStacktrace).isTrue();
      check(appRan).equals(1);
      check(ranAppRunner).equals(0); // we never incremented this
      check(sentryInitialized).isTrue();
    });

    test('opt-out short-circuits and does NOT call the override',
        () async {
      var overrideCalls = 0;
      sentryInitOverride = (builder, runner) async {
        overrideCalls++;
        await runner();
      };
      var appRan = 0;
      await initSentry(
        enabled: false,
        dsn: 'https://x@o0.ingest.de.sentry.io/0',
        release: '1.0.0',
        appRunner: () async {
          appRan++;
        },
      );
      check(overrideCalls).equals(0);
      check(appRan).equals(1);
      check(sentryInitialized).isFalse();
    });

    test('rejects US DSN without calling override', () async {
      var overrideCalls = 0;
      sentryInitOverride = (_, _) async {
        overrideCalls++;
      };
      await check(
        initSentry(
          enabled: true,
          dsn: 'https://x@o0.ingest.us.sentry.io/0',
          release: '1.0.0',
          appRunner: () async {},
        ),
      ).throws<ArgumentError>();
      check(overrideCalls).equals(0);
      check(sentryInitialized).isFalse();
    });

    test('rejects self-hosted non-EU DSN (example.com)', () async {
      sentryInitOverride = (_, _) async {};
      await check(
        initSentry(
          enabled: true,
          dsn: 'https://x@sentry.example.com/0',
          release: '1.0.0',
          appRunner: () async {},
        ),
      ).throws<ArgumentError>();
    });

    test('accepts self-hosted EU mirror DSN', () async {
      var overrideCalls = 0;
      sentryInitOverride = (_, runner) async {
        overrideCalls++;
        await runner();
      };
      await initSentry(
        enabled: true,
        dsn: 'https://x@mirror.de.sentry.io/0',
        release: '2.0.0',
        appRunner: () async {},
      );
      check(overrideCalls).equals(1);
      check(sentryInitialized).isTrue();
    });

    test('propagates exceptions thrown inside appRunner', () async {
      sentryInitOverride = (_, runner) async => runner();
      await check(
        initSentry(
          enabled: true,
          dsn: 'https://x@o0.ingest.de.sentry.io/0',
          release: '1.0.0',
          appRunner: () async => throw StateError('boom'),
        ),
      ).throws<StateError>();
    });
  });

  group('reportException (override seam)', () {
    test('silent when not initialized — capture override never called',
        () async {
      var captured = 0;
      sentryCaptureOverride = (
        Object _, {
        StackTrace? stackTrace,
        ScopeCallback? withScope,
      }) async {
        captured++;
        return const SentryId.empty();
      };
      await reportException(
        Exception('x'),
        StackTrace.current,
        context: 'unit-test',
      );
      check(captured).equals(0);
    });

    test('routes through override once initialized', () async {
      sentryInitOverride = (_, runner) async => runner();
      await initSentry(
        enabled: true,
        dsn: 'https://x@o0.ingest.de.sentry.io/0',
        release: '1.0.0',
        appRunner: () async {},
      );
      Object? seenError;
      StackTrace? seenStack;
      sentryCaptureOverride = (
        Object error, {
        StackTrace? stackTrace,
        ScopeCallback? withScope,
      }) async {
        seenError = error;
        seenStack = stackTrace;
        return const SentryId.empty();
      };
      final err = Exception('routed');
      final stack = StackTrace.current;
      await reportException(err, stack, context: 'ctx');
      check(seenError).equals(err);
      check(seenStack).equals(stack);
    });

    test('withScope callback sets context tag when provided', () async {
      sentryInitOverride = (_, runner) async => runner();
      await initSentry(
        enabled: true,
        dsn: 'https://x@o0.ingest.de.sentry.io/0',
        release: '1.0.0',
        appRunner: () async {},
      );
      ScopeCallback? capturedScope;
      sentryCaptureOverride = (
        Object _, {
        StackTrace? stackTrace,
        ScopeCallback? withScope,
      }) async {
        capturedScope = withScope;
        return const SentryId.empty();
      };
      await reportException(
        Exception('e'),
        StackTrace.current,
        context: 'my-ctx',
      );
      final scope = _MockScope();
      when(() => scope.setTag(any(), any())).thenAnswer((_) async {});
      await capturedScope!(scope);
      verify(() => scope.setTag('context', 'my-ctx')).called(1);
    });

    test('withScope callback skips setTag when context is null',
        () async {
      sentryInitOverride = (_, runner) async => runner();
      await initSentry(
        enabled: true,
        dsn: 'https://x@o0.ingest.de.sentry.io/0',
        release: '1.0.0',
        appRunner: () async {},
      );
      ScopeCallback? capturedScope;
      sentryCaptureOverride = (
        Object _, {
        StackTrace? stackTrace,
        ScopeCallback? withScope,
      }) async {
        capturedScope = withScope;
        return const SentryId.empty();
      };
      await reportException(Exception('e'), StackTrace.current);
      final scope = _MockScope();
      when(() => scope.setTag(any(), any())).thenAnswer((_) async {});
      await capturedScope!(scope);
      verifyNever(() => scope.setTag(any(), any()));
    });

    test('forwards a null context without crashing', () async {
      sentryInitOverride = (_, runner) async => runner();
      await initSentry(
        enabled: true,
        dsn: 'https://x@o0.ingest.de.sentry.io/0',
        release: '1.0.0',
        appRunner: () async {},
      );
      var captured = 0;
      sentryCaptureOverride = (
        Object _, {
        StackTrace? stackTrace,
        ScopeCallback? withScope,
      }) async {
        captured++;
        return const SentryId.empty();
      };
      await reportException(Exception('no-ctx'), StackTrace.current);
      check(captured).equals(1);
    });
  });

  group('sentry_config lifecycle', () {
    test('resetSentryForTesting clears overrides and latch', () async {
      sentryInitOverride = (_, runner) async => runner();
      sentryCaptureOverride = (
        Object _, {
        StackTrace? stackTrace,
        ScopeCallback? withScope,
      }) async =>
          const SentryId.empty();
      await initSentry(
        enabled: true,
        dsn: 'https://x@o0.ingest.de.sentry.io/0',
        release: '1.0.0',
        appRunner: () async {},
      );
      check(sentryInitialized).isTrue();
      resetSentryForTesting();
      check(sentryInitialized).isFalse();
      check(sentryInitOverride).isNull();
      check(sentryCaptureOverride).isNull();
    });

    test('telemetryOptOutStorageKey is stable', () {
      check(telemetryOptOutStorageKey).equals('ga_telemetry_optout');
    });
  });
}
