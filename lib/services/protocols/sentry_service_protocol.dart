/// Abstract interface for Sentry error reporting.
///
/// See spec 05 §Service Providers and decisions D2 (Sentry day 1,
/// opt-in default, EU host). The concrete implementation is backed by
/// `sentry_flutter`.
///
/// Sentry is **opt-in**: [initialize] MUST be called with
/// `enabled: false` (the default) unless the user has explicitly
/// granted telemetry consent in [AppSettings].
abstract interface class SentryServiceProtocol {
  /// Initialises the Sentry SDK.
  ///
  /// [enabled] controls whether Sentry is active. Must be `false`
  /// unless the user has opted in (spec D2 — Sentry day 1 default
  /// disabled). [dsn] is the Sentry project DSN; when [enabled] is
  /// `false` the DSN is ignored. Use an EU-region DSN per D2 to
  /// comply with GDPR data residency requirements.
  ///
  /// [tracesSampleRate] controls the performance monitoring sampling
  /// rate (0.0–1.0; default 0.0 — no performance traces unless the
  /// user opts in to full telemetry).
  Future<void> initialize({
    required bool enabled,
    String? dsn,
    double tracesSampleRate = 0.0,
  });

  /// Captures an exception and its optional stack trace.
  ///
  /// [context] is an optional map of extra key-value pairs to attach
  /// to the Sentry event for debugging context. No-op when Sentry is
  /// disabled or was not initialised.
  Future<void> captureException(
    Object error,
    StackTrace? stack, {
    Map<String, dynamic>? context,
  });

  /// Flushes pending events and closes the Sentry SDK.
  ///
  /// Should be called on app shutdown to prevent event loss.
  Future<void> close();
}
