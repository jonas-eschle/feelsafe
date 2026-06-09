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

  /// Cancels all queued WorkManager SMS jobs identified by [workIds] (A5).
  ///
  /// The session orchestrator ([SessionController]) accumulates every
  /// non-null [MessageWorkId] returned by [sendMessage] over the session and
  /// passes the list here when the user signals safety — on disarm (the
  /// "I'm safe" slider) and on a clean session end (correct End-PIN /
  /// explicit quit). This retracts a distress SMS that the Android retry
  /// queue had deferred (no signal at send time) so it never arrives at the
  /// emergency contacts after the user is already safe (spec 05 §A5).
  ///
  /// Cancellation is NOT performed on distress / escalation ends
  /// (`chainExhausted` / `hardwarePanic` / `duressPin` / `wrongPinExhausted`
  /// / `distressConfirmTimeout`) — there the message must still go out.
  ///
  /// Android-only effect (calls `WorkManager.cancelWorkById` per id via the
  /// SMS MethodChannel). iOS / an empty [workIds] / non-SMS channels are a
  /// no-op (those channels have no cancellable background job).
  Future<void> cancelPending(List<MessageWorkId> workIds);
}
