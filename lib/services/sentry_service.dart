import 'dart:developer';

import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:guardianangela/services/protocols/sentry_service_protocol.dart';

// ---------------------------------------------------------------------------
// Injectable seam for testability
// ---------------------------------------------------------------------------

/// Abstraction over `SentryFlutter` static methods to allow injection of a
/// test double in unit tests. Tests pass [_FakeSentrySdk]; production code
/// uses [_RealSentrySdk].
abstract interface class SentrySdk {
  /// Initializes the Sentry SDK.
  Future<void> init(
    SentryFlutterOptions Function(SentryFlutterOptions) configureFn,
  );

  /// Captures an exception.
  Future<void> captureException(Object error, {StackTrace? stackTrace});

  /// Closes and flushes the SDK.
  Future<void> close();
}

/// Production [SentrySdk] backed by [SentryFlutter] static methods.
class _RealSentrySdk implements SentrySdk {
  const _RealSentrySdk();

  // LCOV_EXCL_START — live-SDK-only passthrough: host tests inject a fake SentrySdk (sentry_service_test drives the real RealSentryService logic); these statics need the real Sentry SDK/network
  @override
  Future<void> init(
    SentryFlutterOptions Function(SentryFlutterOptions) configureFn,
  ) => SentryFlutter.init((options) {
    configureFn(options);
  });

  @override
  Future<void> captureException(Object error, {StackTrace? stackTrace}) =>
      Sentry.captureException(error, stackTrace: stackTrace);

  @override
  Future<void> close() => Sentry.close();
  // LCOV_EXCL_STOP
}

// ---------------------------------------------------------------------------
// RealSentryService
// ---------------------------------------------------------------------------

/// Production [SentryServiceProtocol] backed by `package:sentry_flutter`.
///
/// Sentry is **opt-in by default**: [initialize] is called with
/// `enabled: false` unless the user has explicitly granted telemetry
/// consent in [AppSettings]. When `enabled: false`, the SDK is never
/// initialized and all subsequent [captureException] calls are no-ops.
///
/// **EU data residency (D2):** the DSN MUST point to an EU-region Sentry
/// project (i.e. the DSN ingest host ends with `.ingest.de.sentry.io`).
///
/// **Idempotency rules:**
/// - Calling [initialize] twice with the same arguments is safe (no-op on
///   the second call).
/// - Calling [initialize] twice with different arguments throws [StateError]:
///   the process can only be initialized once per run.
/// - Calling [captureException] before [initialize] or after [close] is a
///   no-op (telemetry off = no events).
///
/// **Single constructor location rule:** no `RealSentryService()` call may
/// appear outside `lib/services/service_providers.dart` (CI grep enforces).
class RealSentryService implements SentryServiceProtocol {
  /// Creates a [RealSentryService].
  ///
  /// [sdk] may be injected for tests; defaults to the production
  /// [_RealSentrySdk] wrapper.
  RealSentryService({SentrySdk? sdk}) : _sdk = sdk ?? const _RealSentrySdk();

  final SentrySdk _sdk;

  bool _initialized = false;
  bool? _enabledAtInit;
  String? _dsnAtInit;
  double? _rateAtInit;

  // -------------------------------------------------------------------------
  // SentryServiceProtocol implementation
  // -------------------------------------------------------------------------

  @override
  Future<void> initialize({
    required bool enabled,
    String? dsn,
    double tracesSampleRate = 0.0,
  }) async {
    // Idempotency: if already initialized with the same args, skip.
    if (_initialized) {
      if (_enabledAtInit == enabled &&
          _dsnAtInit == dsn &&
          _rateAtInit == tracesSampleRate) {
        log(
          'initialize called again with same args — no-op',
          name: 'SentryService',
        );
        return;
      }
      throw StateError(
        'SentryService already initialized with different args. '
        'Cannot re-initialize a Sentry SDK within the same process.',
      );
    }

    _initialized = true;
    _enabledAtInit = enabled;
    _dsnAtInit = dsn;
    _rateAtInit = tracesSampleRate;

    if (!enabled) {
      log(
        'Sentry disabled (opt-in not granted) — skipping SDK init',
        name: 'SentryService',
      );
      return;
    }

    if (dsn == null || dsn.isEmpty) {
      log(
        'Sentry enabled but DSN is null/empty — skipping SDK init',
        name: 'SentryService',
      );
      return;
    }

    // D2 / D-TELEMETRY-1: EU data-residency requirement.
    // The DSN ingest host MUST end with .ingest.de.sentry.io to ensure that
    // event data stays in the EU region (spec 06:816).
    final host = Uri.parse(dsn).host;
    if (!host.endsWith('.ingest.de.sentry.io')) {
      throw StateError(
        'Sentry DSN must point to an EU host (.ingest.de.sentry.io) '
        'per D2 / D-TELEMETRY-1; got "$host"',
      );
    }

    log('Initializing Sentry (EU host: $host)', name: 'SentryService');
    await _sdk.init((options) {
      options.dsn = dsn;
      options.tracesSampleRate = tracesSampleRate;
      return options;
    });
  }

  @override
  Future<void> captureException(
    Object error,
    StackTrace? stack, {
    Map<String, dynamic>? context,
  }) async {
    if (!_initialized || _enabledAtInit == false) {
      log(
        'captureException — Sentry not initialized or disabled, no-op',
        name: 'SentryService',
      );
      return;
    }
    log('captureException: $error', name: 'SentryService');
    await _sdk.captureException(error, stackTrace: stack);
  }

  @override
  Future<void> close() async {
    if (!_initialized) return;
    log('close', name: 'SentryService');
    if (_enabledAtInit == true) {
      await _sdk.close();
    }
    _initialized = false;
    _enabledAtInit = null;
    _dsnAtInit = null;
    _rateAtInit = null;
  }
}
