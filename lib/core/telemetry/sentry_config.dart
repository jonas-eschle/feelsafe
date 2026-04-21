/// Sentry telemetry bootstrap — EU host, opt-out default.
///
/// Per D-PLATFORM-6 + D-SERVICES-17 + D-TELEMETRY-1, Guardian Angela
/// ships Sentry configured against the **EU data region**. Telemetry
/// is **on by default**; users can flip a Settings → Privacy toggle
/// to opt out, persisted on `AppSettings.telemetryOptOut`. When that
/// flag (or the fallback `flutter_secure_storage` key
/// `ga_telemetry_optout`) is `true`, [initSentry] is a no-op and
/// [reportException] silently returns — guaranteeing zero Sentry
/// egress (verified on-device by packet-capture as part of Phase 16
/// gate #17).
///
/// The DSN passed in **must** be an EU DSN (hostname ends with
/// `.de.sentry.io` / `.ingest.de.sentry.io`). [initSentry] enforces
/// this — an invalid region rejects fast rather than silently
/// forwarding user data to the default US host.
library;

import 'package:flutter/foundation.dart';

import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:guardianangela/core/logging/structured_logger.dart';

/// Opt-out secure-storage fallback key. When `AppSettings` is not yet
/// loaded (pre-ProviderScope boot), the opt-out check falls back to
/// this key via `flutter_secure_storage`.
const String telemetryOptOutStorageKey = 'ga_telemetry_optout';

/// Signature of the wrapped `SentryFlutter.init` call. Tests replace
/// this via [sentryInitOverride] to observe the configured options
/// without actually spinning up the native Sentry transport.
typedef SentryInitFn = Future<void> Function(
  FlutterOptionsConfiguration optionsBuilder,
  Future<void> Function() appRunner,
);

/// Signature of the wrapped `Sentry.captureException` call. Tests set
/// [sentryCaptureOverride] to a spy; production defers to the real
/// Sentry SDK.
typedef SentryCaptureFn = Future<SentryId> Function(
  Object error, {
  StackTrace? stackTrace,
  ScopeCallback? withScope,
});

/// Test seam: replaces `SentryFlutter.init` when set. Production keeps
/// this `null` so the real SDK is used.
@visibleForTesting
SentryInitFn? sentryInitOverride;

/// Test seam: replaces `Sentry.captureException` when set. Production
/// keeps this `null` so the real SDK is used.
@visibleForTesting
SentryCaptureFn? sentryCaptureOverride;

bool _initialized = false;

/// Returns true after a successful [initSentry] call. Tests and the
/// exception reporter use this to skip no-op work.
@visibleForTesting
bool get sentryInitialized => _initialized;

/// Resets the one-shot init latch. **Test-only** — production should
/// initialize Sentry exactly once from `main`.
@visibleForTesting
void resetSentryForTesting() {
  _initialized = false;
  sentryInitOverride = null;
  sentryCaptureOverride = null;
}

/// Validates that [dsn] targets Sentry's EU data region.
///
/// Returns `true` for the two valid forms: `…@oN.ingest.de.sentry.io/…`
/// (Sentry SaaS EU) and `…@…de.sentry.io/…` (self-hosted EU mirror).
/// Everything else is rejected — we refuse to send user data to a
/// non-EU region silently.
bool _isEuDsn(String dsn) {
  final uri = Uri.tryParse(dsn);
  if (uri == null) return false;
  final host = uri.host.toLowerCase();
  return host.endsWith('.de.sentry.io');
}

/// Initializes Sentry.
///
/// - [enabled] = `false` → no-op (used when the user opted out).
/// - [dsn] must be an EU DSN (see [_isEuDsn]).
/// - [release] identifies the app build (e.g. `1.0.0+1`).
/// - [appRunner] is the callback Sentry invokes after wiring up;
///   pass your `runApp(...)` here.
///
/// When [enabled] is `false`, [appRunner] is still awaited so
/// `main()` can unconditionally call this method.
Future<void> initSentry({
  required bool enabled,
  required String dsn,
  required String release,
  required Future<void> Function() appRunner,
}) async {
  if (!enabled) {
    StructuredLogger.telemetry(
      'Sentry disabled by opt-out; running app without telemetry.',
    );
    await appRunner();
    return;
  }
  if (!_isEuDsn(dsn)) {
    throw ArgumentError.value(
      dsn,
      'dsn',
      'Sentry DSN must target the EU region '
          '(host must end with .de.sentry.io).',
    );
  }
  final initFn = sentryInitOverride ?? _defaultSentryInit;
  await initFn(
    (options) {
      options
        ..dsn = dsn
        ..release = release
        ..environment = kReleaseMode ? 'production' : 'development'
        ..tracesSampleRate = kReleaseMode ? 0.1 : 0.0
        ..sendDefaultPii = false
        ..attachStacktrace = true;
    },
    () async {
      _initialized = true;
      StructuredLogger.telemetry(
        'Sentry initialized (EU host, release=$release).',
      );
      await appRunner();
    },
  );
}

/// Default [SentryInitFn] — delegates to the real `SentryFlutter.init`.
Future<void> _defaultSentryInit(
  FlutterOptionsConfiguration optionsBuilder,
  Future<void> Function() appRunner,
) async {
  await SentryFlutter.init(optionsBuilder, appRunner: appRunner);
}

/// Reports [error] + [stack] to Sentry.
///
/// Silently returns if Sentry was never initialized (i.e., the user
/// opted out). [context] is attached as a `context` tag for
/// dashboard filtering.
Future<void> reportException(
  Object error,
  StackTrace stack, {
  String? context,
}) async {
  if (!_initialized) return;
  final captureFn = sentryCaptureOverride ?? Sentry.captureException;
  await captureFn(
    error,
    stackTrace: stack,
    withScope: (scope) {
      if (context != null) {
        scope.setTag('context', context);
      }
    },
  );
}
