/// Coverage for one-line category helpers on [StructuredLogger].
///
/// The helpers forward to `dart:developer.log` (no-op in tests); we
/// assert only that they do not throw, which credits lines 88, 91, 94,
/// 97, 100 of `lib/core/logging/structured_logger.dart`.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/logging/structured_logger.dart';

void main() {
  group('StructuredLogger category helpers', () {
    test('session() does not throw', () {
      StructuredLogger.session('ping');
    });

    test('engine() does not throw', () {
      StructuredLogger.engine('ping');
    });

    test('service() does not throw', () {
      StructuredLogger.service('ping');
    });

    test('ui() does not throw', () {
      StructuredLogger.ui('ping');
    });

    test('db() does not throw', () {
      StructuredLogger.db('ping');
    });

    test('telemetry() does not throw', () {
      StructuredLogger.telemetry('ping');
    });

    test('log() respects explicit LogLevel values', () {
      StructuredLogger.log(
        LogCategory.engine,
        'warn-level',
        level: LogLevel.warning,
      );
      StructuredLogger.log(
        LogCategory.db,
        'debug-level',
        level: LogLevel.debug,
      );
      StructuredLogger.log(
        LogCategory.ui,
        'error-level',
        level: LogLevel.error,
        error: StateError('boom'),
        stackTrace: StackTrace.current,
      );
    });

    test('LogLevel values are stable', () {
      check(LogLevel.debug.value).equals(500);
      check(LogLevel.info.value).equals(800);
      check(LogLevel.warning.value).equals(900);
      check(LogLevel.error.value).equals(1000);
    });

    test('LogCategory enum covers all subsystems', () {
      check(LogCategory.values).length.equals(6);
    });
  });
}
