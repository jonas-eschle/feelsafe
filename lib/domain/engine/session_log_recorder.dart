/// `SessionLogRecorder` — subscribes to `SessionEngine` events and
/// appends them to a mutable [SessionLog].
///
/// Pure Dart. Storage of the finalized log is the responsibility of
/// the caller (a repository in `lib/data/`).
library;

import 'package:guardianangela/domain/models/chain_event.dart';
import 'package:guardianangela/domain/models/session_log.dart';

/// Accumulates engine events into a [SessionLog].
final class SessionLogRecorder {
  /// Creates a recorder bound to a mutable [SessionLog].
  SessionLogRecorder({required SessionLog log}) : _log = log;

  // Mutable: `recordEvent` / `updateDeliveryStatus` rebuild the log
  // in-place via `copyWith` once filled in (Phase 4b).
  // ignore: prefer_final_fields
  SessionLog _log;

  /// The current (possibly partially populated) log.
  SessionLog get log => _log;

  /// Records one engine [event] into [log].
  void recordEvent(ChainEventData event) {
    throw UnimplementedError();
  }

  /// Updates an already-recorded event's delivery status.
  ///
  /// [eventIndex] — index into [SessionLog.events].
  /// [status] — new [ActionDeliveryStatus].
  void updateDeliveryStatus({
    required int eventIndex,
    required ActionDeliveryStatus status,
  }) {
    throw UnimplementedError();
  }
}
