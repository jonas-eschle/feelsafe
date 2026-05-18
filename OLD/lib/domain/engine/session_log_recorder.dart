/// `SessionLogRecorder` — subscribes to `SessionEngine` events and
/// appends them to a mutable [SessionLog].
///
/// Pure Dart. Storage of the finalized log is the responsibility of
/// the caller (a repository in `lib/data/`).
library;

import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/models/chain_event.dart';
import 'package:guardianangela/domain/models/session_log.dart';

/// Accumulates engine events into a [SessionLog].
final class SessionLogRecorder {
  /// Creates a recorder bound to a mutable [SessionLog].
  SessionLogRecorder({required SessionLog log}) : _log = log;

  SessionLog _log;

  /// The current (possibly partially populated) log.
  SessionLog get log => _log;

  /// Records one engine [event] into [log].
  ///
  /// Appends a [SessionLogEvent] derived from [event] to
  /// [SessionLog.events]. For terminal events
  /// ([ChainEvent.sessionEnded]), the log's [SessionLog.endedAt] is
  /// also set from the event timestamp; [SessionLog.endReason] is
  /// lifted from the event metadata when present.
  void recordEvent(ChainEventData event) {
    final newEvent = SessionLogEvent(
      timestamp: event.timestamp,
      event: event.event,
      stepIndex: event.stepIndex,
      stepType: event.stepType,
      deliveryStatus: null,
      message: _messageFromMetadata(event),
    );
    final events = List<SessionLogEvent>.of(_log.events)..add(newEvent);
    DateTime? endedAt = _log.endedAt;
    EndReason? endReason = _log.endReason;
    if (event.event == ChainEvent.sessionEnded) {
      endedAt = event.timestamp;
      endReason = _endReasonFromMetadata(event) ?? endReason;
    }
    _log = _log.copyWith(
      events: List.unmodifiable(events),
      endedAt: endedAt,
      endReason: endReason,
    );
  }

  /// Updates an already-recorded event's delivery status.
  ///
  /// [eventIndex] — index into [SessionLog.events].
  /// [status] — new [ActionDeliveryStatus].
  ///
  /// Throws [RangeError] if [eventIndex] is out of bounds.
  void updateDeliveryStatus({
    required int eventIndex,
    required ActionDeliveryStatus status,
  }) {
    if (eventIndex < 0 || eventIndex >= _log.events.length) {
      throw RangeError.range(
        eventIndex,
        0,
        _log.events.length - 1,
        'eventIndex',
      );
    }
    final events = List<SessionLogEvent>.of(_log.events);
    events[eventIndex] = events[eventIndex].copyWith(deliveryStatus: status);
    _log = _log.copyWith(events: List.unmodifiable(events));
  }

  static String? _messageFromMetadata(ChainEventData event) {
    final reason = event.metadata['reason'];
    if (reason is String) return reason;
    final miss = event.metadata['missCount'];
    if (miss != null) return 'missCount=$miss';
    return null;
  }

  static EndReason? _endReasonFromMetadata(ChainEventData event) {
    final raw = event.metadata['reason'];
    if (raw is! String) return null;
    return switch (raw) {
      'disarm' => EndReason.disarm,
      'chainExhausted' => EndReason.chainExhausted,
      'hardwarePanic' => EndReason.hardwarePanic,
      'duressPin' => EndReason.duressPin,
      'wrongPinExhausted' => EndReason.wrongPinExhausted,
      'userQuit' => EndReason.userQuit,
      'appTermination' => EndReason.appTermination,
      _ => null,
    };
  }
}
