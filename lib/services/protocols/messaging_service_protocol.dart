/// `MessagingServiceProtocol` — abstract contract for SMS /
/// WhatsApp / Telegram messaging used by `SmsContactStrategy`.
///
/// Pure Dart. The concrete implementation bridges to native SMS and
/// `url_launcher` deep-links in Phase 4b, tracks delivery via a
/// WorkManager-backed worker, and surfaces `retry-exhausted` events
/// so the UI can prompt fallback actions.
library;

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';

/// Opaque identifier for one enqueued message send.
final class MessageWorkId {
  /// Creates a [MessageWorkId] wrapping an opaque string id.
  const MessageWorkId(this.value);

  /// Underlying id (e.g., WorkManager request id).
  final String value;

  @override
  bool operator ==(Object other) =>
      other is MessageWorkId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'MessageWorkId($value)';
}

/// An incremental delivery-status update from the messaging layer.
final class MessageDeliveryUpdate {
  /// Creates a delivery update.
  ///
  /// [workId] — the work id being updated.
  /// [status] — opaque status string (e.g., "queued", "sent",
  /// "failed").
  const MessageDeliveryUpdate({required this.workId, required this.status});

  /// The work id being updated.
  final String workId;

  /// Opaque status string.
  final String status;
}

/// Emitted when a message's retry budget is exhausted.
final class SmsRetryExhaustedEvent {
  /// Creates a retry-exhausted event.
  ///
  /// [workId] — the originating work id.
  /// [recipient] — phone number of the intended recipient.
  /// [message] — the message body that failed to deliver.
  const SmsRetryExhaustedEvent({
    required this.workId,
    required this.recipient,
    required this.message,
  });

  /// The originating work id.
  final String workId;

  /// Intended recipient phone number.
  final String recipient;

  /// Message body.
  final String message;
}

/// Abstract contract for the emergency-messaging service.
abstract class MessagingServiceProtocol {
  /// Returns true if the platform can auto-send on [channel]
  /// without foreground UI confirmation.
  Future<bool> canAutoSend(MessageChannel channel);

  /// Sends [message] to [contact] over [channel]. Returns a
  /// [MessageWorkId] the caller can correlate with later delivery
  /// updates.
  ///
  /// [isSimulation] — if true, the implementation does not actually
  /// send; it returns a simulated work id and surfaces fake
  /// delivery updates.
  Future<MessageWorkId> sendMessage({
    required EmergencyContact contact,
    required String message,
    required MessageChannel channel,
    bool isSimulation = false,
  });

  /// Fan-out helper: sends [message] to every enabled channel on
  /// every contact in [contacts]. Returns one [MessageWorkId] per
  /// (contact, channel) pair that was enqueued.
  Future<List<MessageWorkId>> sendToAll({
    required List<EmergencyContact> contacts,
    required String message,
    bool isSimulation = false,
  });

  /// Cancels any still-pending work for the given [workIds].
  Future<void> cancelPending(List<MessageWorkId> workIds);

  /// Broadcast stream of incremental delivery status updates.
  Stream<MessageDeliveryUpdate> get deliveryUpdates;

  /// Broadcast stream of retry-exhausted events. The UI typically
  /// surfaces a fallback prompt (e.g., "Copy & send manually?").
  Stream<SmsRetryExhaustedEvent> get smsRetryExhausted;

  /// Re-enqueues the exhausted SMS identified by [workId] so the
  /// user can manually retry.
  Future<void> retryExhaustedSms(String workId);
}
