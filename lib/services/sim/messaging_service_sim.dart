import 'dart:async';
import 'dart:developer';

import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/services/messaging_service.dart'
    show SmsRetryExhaustedEvent;
import 'package:guardianangela/services/protocols/messaging_service_protocol.dart';

/// A single recorded send invocation for [SimulationMessagingService].
final class MessageSendCall {
  /// Creates a [MessageSendCall].
  const MessageSendCall({
    required this.contact,
    required this.message,
    required this.isSimulation,
    this.workId,
  });

  /// The contact the message was addressed to.
  final EmergencyContact contact;

  /// The message body.
  final String message;

  /// Whether the call had `isSimulation: true`.
  final bool isSimulation;

  /// Returned work ID (non-null only for SMS-channel real sends where a
  /// simulated WorkManager ID is injected).
  final MessageWorkId? workId;

  @override
  String toString() =>
      'MessageSendCall(contact=${contact.name}, channel='
      '${contact.channels.firstOrNull?.name}, sim=$isSimulation)';
}

/// Simulation [MessagingServiceProtocol] for tests and simulation sessions.
///
/// Per spec 05 §Layer 4: this subclass ensures no external I/O occurs during
/// simulation mode. It records every call to [sendMessage] and returns
/// null for all calls (no real channel dispatch ever happens).
///
/// For simulation sessions the [isSimulation] flag is `true` at Layer 2
/// (strategy) and Layer 3 ([sendMessage] guard). Layer 4 is this class —
/// structurally impossible to reach real SMS/call code.
///
/// [injectExhaustedEvent] allows tests to drive the retry-exhaustion path.
class SimulationMessagingService implements MessagingServiceProtocol {
  /// Creates a [SimulationMessagingService].
  SimulationMessagingService();

  /// All [sendMessage] invocations since construction or last [reset].
  final List<MessageSendCall> calls = [];

  final StreamController<SmsRetryExhaustedEvent> _exhaustedController =
      StreamController<SmsRetryExhaustedEvent>.broadcast();

  /// All work IDs to return for SMS sends.
  ///
  /// If non-null, [sendMessage] returns the next value from this queue
  /// (cycling from the front). Defaults to null (returns null).
  List<MessageWorkId>? simulatedWorkIds;

  int _workIdIndex = 0;

  // -------------------------------------------------------------------------
  // MessagingServiceProtocol implementation
  // -------------------------------------------------------------------------

  @override
  Future<MessageWorkId?> sendMessage({
    required EmergencyContact contact,
    required String message,
    bool isSimulation = false,
  }) async {
    if (isSimulation) {
      log(
        '[SIM] sendMessage(${contact.name}) — sim_blocked Layer 4',
        name: 'MessagingService',
      );
      calls.add(
        MessageSendCall(
          contact: contact,
          message: message,
          isSimulation: true,
        ),
      );
      return null;
    }

    MessageWorkId? workId;
    final ids = simulatedWorkIds;
    if (ids != null && ids.isNotEmpty) {
      workId = ids[_workIdIndex % ids.length];
      _workIdIndex++;
    }

    calls.add(
      MessageSendCall(
        contact: contact,
        message: message,
        isSimulation: false,
        workId: workId,
      ),
    );
    return workId;
  }

  // -------------------------------------------------------------------------
  // Extended API (mirrors RealMessagingService)
  // -------------------------------------------------------------------------

  /// Always returns `false` — simulation sessions never auto-send.
  bool canAutoSend(MessageChannel channel) => false;

  /// No-op in simulation — no WorkManager jobs exist.
  Future<void> cancelPending(List<MessageWorkId> workIds) async {
    log(
      '[SIM] cancelPending(${workIds.length}) — no-op',
      name: 'MessagingService',
    );
  }

  /// Broadcast stream of simulated retry-exhaustion events.
  ///
  /// Drive via [injectExhaustedEvent] in tests.
  Stream<SmsRetryExhaustedEvent> get smsRetryExhausted =>
      _exhaustedController.stream;

  /// Records a simulated retry attempt (no real re-enqueue).
  Future<MessageWorkId?> retryExhaustedSms(
    SmsRetryExhaustedEvent event,
  ) async {
    log(
      '[SIM] retryExhaustedSms workId=${event.workId}',
      name: 'MessagingService',
    );
    final contact = EmergencyContact(
      id: 'retry_${event.workId}',
      name: event.contactName,
      phoneNumber: event.phoneNumber,
      sortOrder: 0,
    );
    return sendMessage(contact: contact, message: event.message);
  }

  // -------------------------------------------------------------------------
  // Test helpers
  // -------------------------------------------------------------------------

  /// Injects an [SmsRetryExhaustedEvent] into the [smsRetryExhausted] stream.
  void injectExhaustedEvent(SmsRetryExhaustedEvent event) =>
      _exhaustedController.add(event);

  /// Clears [calls] and resets the work-ID index.
  void reset() {
    calls.clear();
    _workIdIndex = 0;
  }

  /// Disposes stream controllers.
  Future<void> dispose() => _exhaustedController.close();

  /// All calls that had [isSimulation] = false.
  List<MessageSendCall> get realCalls =>
      calls.where((c) => !c.isSimulation).toList();

  /// All calls that had [isSimulation] = true.
  List<MessageSendCall> get simCalls =>
      calls.where((c) => c.isSimulation).toList();
}
