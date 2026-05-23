import 'package:guardianangela/domain/engine/chain_event.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';

/// Abstract interface for the session-timeline recorder.
///
/// See spec 05 §SessionLogRecorder. One recorder is created per session
/// by the `SessionController`. It subscribes to `SessionEngine.events`,
/// accumulates [ChainEventData] entries in memory, and performs a
/// single atomic write to the repository on [finalise].
///
/// The concrete class is constructed directly by the session controller
/// (not via Riverpod) because it is a short-lived per-session object,
/// not a long-lived singleton. The `sessionLogRecorderProvider` row in
/// `docs/wiring-map.md` tracks the pending Stage 5B impl.
///
/// There is no incremental persistence — process kill mid-session means
/// the log is lost (matches the no-session-restore policy).
abstract interface class SessionLogRecorderProtocol {
  /// Appends a [ChainEventData] event to the in-memory log.
  ///
  /// Called by the session controller on every event received from
  /// `SessionEngine.events`. Never blocks; never writes to disk.
  void onEvent(ChainEventData event);

  /// Persists the accumulated log in a single atomic repository write.
  ///
  /// [reason] is the reason the session ended. After [finalise]
  /// returns the recorder is effectively spent — calling [onEvent]
  /// or [finalise] again after this point has undefined behavior.
  Future<void> finalise(EndReason reason);
}
