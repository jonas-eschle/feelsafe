/// Tests for [initSentry] opt-out behavior.
///
/// We only exercise the opt-out and the EU-DSN rejection paths;
/// actually initializing `SentryFlutter` requires Flutter bindings
/// and an HTTP transport, both out of scope for a unit test.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/telemetry/sentry_config.dart';

void main() {
  setUp(resetSentryForTesting);

  group('initSentry', () {
    test('noop when enabled: false still runs appRunner', () async {
      var ran = false;
      await initSentry(
        enabled: false,
        dsn: 'https://x@o0.ingest.de.sentry.io/0',
        release: 'test@1.0.0',
        appRunner: () async {
          ran = true;
        },
      );
      check(ran).isTrue();
      check(sentryInitialized).isFalse();
    });

    test('rejects US DSN (sentry.io without de.)', () async {
      await check(
        initSentry(
          enabled: true,
          dsn: 'https://x@o0.ingest.us.sentry.io/0',
          release: 'test@1.0.0',
          appRunner: () async {},
        ),
      ).throws<ArgumentError>();
    });

    test('rejects malformed DSN', () async {
      await check(
        initSentry(
          enabled: true,
          dsn: 'not a url',
          release: 'test@1.0.0',
          appRunner: () async {},
        ),
      ).throws<ArgumentError>();
    });
  });

  group('reportException', () {
    test('silent when Sentry not initialized', () async {
      // Must not throw even though the closure below looks like a
      // real error path.
      await reportException(
        Exception('x'),
        StackTrace.current,
        context: 'unit-test',
      );
      check(sentryInitialized).isFalse();
    });
  });

  group('telemetryOptOutStorageKey', () {
    test('is the canonical key name', () {
      check(telemetryOptOutStorageKey).equals('ga_telemetry_optout');
    });
  });
}
