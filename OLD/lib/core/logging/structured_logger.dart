/// Structured, category-tagged logger + session-log retention.
///
/// A thin wrapper around `dart:developer` `log()`. All runtime logs
/// should route through [StructuredLogger] so every message carries
/// a stable category tag (`session`, `engine`, `service`, `ui`, `db`,
/// `telemetry`). Per D-SAFETY-6, completed-session logs are pruned
/// on a retention schedule configured by
/// `AppSettings.sessionLogRetentionDays`.
library;

import 'dart:developer' as developer;

import 'package:guardianangela/data/repositories/session_logs_repository.dart';

/// Log category tag. Used by [StructuredLogger] to prefix every
/// message so filter rules in the Sentry dashboard (and in local
/// `flutter logs` output) can distinguish subsystem origin at a
/// glance.
enum LogCategory {
  /// Session lifecycle (start, pause, end).
  session,

  /// Engine state-machine transitions + timer scheduling.
  engine,

  /// Platform service wrappers (SMS, location, audio, ...).
  service,

  /// UI-level user interactions not covered by the above.
  ui,

  /// Data-layer (Drift / repositories).
  db,

  /// Telemetry subsystem itself.
  telemetry,
}

/// Log severity level. Mirrors the `dart:developer` int scale.
enum LogLevel {
  /// Fine-grained debug output; noisy in production.
  debug(500),

  /// Normal operational messages.
  info(800),

  /// Recoverable anomalies.
  warning(900),

  /// Errors that require attention (reported to Sentry too).
  error(1000);

  const LogLevel(this.value);

  /// The int value consumed by `dart:developer`.
  final int value;
}

/// Structured logger. All methods are `static` — the logger is
/// effectively a namespace, not a stateful object.
final class StructuredLogger {
  const StructuredLogger._();

  /// Emits a log line tagged with [category].
  ///
  /// [level] defaults to [LogLevel.info]. [error] / [stackTrace] are
  /// forwarded to `dart:developer`; when present the caller should
  /// typically also route the pair through
  /// `SentryConfig.reportException` for remote reporting.
  static void log(
    LogCategory category,
    String message, {
    LogLevel? level,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final resolvedLevel = level ?? LogLevel.info;
    developer.log(
      message,
      name: 'ga.${category.name}',
      level: resolvedLevel.value,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Convenience shorthand for info-level session logs.
  static void session(String message) => log(LogCategory.session, message);

  /// Convenience shorthand for info-level engine logs.
  static void engine(String message) => log(LogCategory.engine, message);

  /// Convenience shorthand for info-level service logs.
  static void service(String message) => log(LogCategory.service, message);

  /// Convenience shorthand for info-level UI logs.
  static void ui(String message) => log(LogCategory.ui, message);

  /// Convenience shorthand for info-level DB logs.
  static void db(String message) => log(LogCategory.db, message);

  /// Convenience shorthand for info-level telemetry logs.
  static void telemetry(String message) => log(LogCategory.telemetry, message);

  /// Deletes session logs whose `startedAt` is older than
  /// [retentionDays] days before [now].
  ///
  /// [now] defaults to `DateTime.now()`. Pass a fixed instant from
  /// tests for determinism. Returns the number of logs pruned.
  ///
  /// A zero or negative [retentionDays] is a no-op — interpreted as
  /// "retention disabled". This mirrors the UX of a user selecting
  /// "Keep forever" in settings.
  static Future<int> enforceRetention({
    required SessionLogsRepository repo,
    required int retentionDays,
    DateTime? now,
  }) async {
    if (retentionDays <= 0) {
      return 0;
    }
    final cutoff = (now ?? DateTime.now()).subtract(
      Duration(days: retentionDays),
    );
    final logs = await repo.getAll();
    var pruned = 0;
    for (final log in logs) {
      if (log.startedAt.isBefore(cutoff)) {
        await repo.delete(log.id);
        pruned += 1;
      }
    }
    if (pruned > 0) {
      StructuredLogger.log(
        LogCategory.db,
        'Pruned $pruned session log(s) older than $retentionDays d.',
      );
    }
    return pruned;
  }
}
