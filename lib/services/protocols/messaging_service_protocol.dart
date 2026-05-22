import 'package:guardianangela/domain/models/emergency_contact.dart';

/// Opaque work identifier returned by Android WorkManager SMS jobs.
///
/// Passed to the orchestrator for deferred cancellation on disarm (A5).
/// Other channels return `null` from [MessagingServiceProtocol.sendMessage].
typedef MessageWorkId = String;

/// Abstract interface for outbound messaging used by event strategies.
///
/// Phase 5 supplies the concrete implementation. Only the methods that
/// strategies call are declared here.
abstract interface class MessagingServiceProtocol {
  /// Sends a message to [contact] via the contact's channel.
  ///
  /// The strategy passes a single-channel copy of [EmergencyContact] (i.e.
  /// `contact.copyWith(channels: [channel])`) so this method always
  /// dispatches to exactly one channel (Extra-15 / Single-Channel Dispatch).
  ///
  /// Returns a [MessageWorkId] for Android SMS WorkManager jobs (used by
  /// `cancelPending` on disarm). Returns `null` for other channels (WhatsApp,
  /// Telegram, etc.) that have no cancellable background job.
  ///
  /// [isSimulation] MUST be `false` when called from a strategy — strategies
  /// guard at Layer 2; this flag is the service-level Layer 3 defense.
  Future<MessageWorkId?> sendMessage({
    required EmergencyContact contact,
    required String message,
    bool isSimulation = false,
  });
}
