import 'package:guardianangela/services/protocols/sentry_service_protocol.dart';

/// A recorded capture invocation for [SimulationSentryService].
final class SentryCapture {
  /// Creates a [SentryCapture].
  const SentryCapture({
    required this.error,
    this.stack,
    this.context,
  });

  /// The captured error object.
  final Object error;

  /// Optional stack trace.
  final StackTrace? stack;

  /// Optional extra context map.
  final Map<String, dynamic>? context;

  @override
  String toString() => 'SentryCapture(error=$error)';
}

/// Simulation [SentryServiceProtocol] for tests and simulation sessions.
///
/// Per decision D2: simulation sessions MUST NOT emit real telemetry.
/// This impl is pure-Dart and never calls any `Sentry.*` static methods.
///
/// Records all [captureException] calls in [captures] for test assertions.
class SimulationSentryService implements SentryServiceProtocol {
  /// Creates a [SimulationSentryService].
  SimulationSentryService();

  /// All captured exceptions since construction or last [reset].
  final List<SentryCapture> captures = [];

  bool _initialized = false;

  /// Whether the service was initialized with `enabled: true`.
  bool get isInitialized => _initialized;

  // -------------------------------------------------------------------------
  // SentryServiceProtocol implementation
  // -------------------------------------------------------------------------

  @override
  Future<void> initialize({
    required bool enabled,
    String? dsn,
    double tracesSampleRate = 0.0,
  }) async {
    _initialized = enabled;
  }

  @override
  Future<void> captureException(
    Object error,
    StackTrace? stack, {
    Map<String, dynamic>? context,
  }) async {
    if (!_initialized) return;
    captures.add(SentryCapture(error: error, stack: stack, context: context));
  }

  @override
  Future<void> close() async {
    _initialized = false;
  }

  // -------------------------------------------------------------------------
  // Test helpers
  // -------------------------------------------------------------------------

  /// Clears [captures] and resets the initialized state.
  void reset() {
    captures.clear();
    _initialized = false;
  }
}
