/// Deterministic fake implementation of [MessagingServiceProtocol]
/// for tests. Every call is recorded to [calls], and delivery /
/// retry streams are exposed as broadcast controllers.
library;

import 'dart:async';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/services/protocols/messaging_service_protocol.dart';

/// Test double for [MessagingServiceProtocol].
final class FakeMessagingService implements MessagingServiceProtocol {
  /// Creates a fake messaging service.
  FakeMessagingService();

  /// Invocation log: one entry per method call.
  final List<String> calls = [];

  /// Captured `sendMessage` invocations with full body. Useful when
  /// asserting that a per-contact template (selected via
  /// `SessionContext.smsTemplateForLanguage`) was the one rendered.
  final List<({EmergencyContact contact, String message, MessageChannel channel})>
      sentMessages = [];

  /// Counter used to assign opaque work ids.
  int _nextWorkId = 0;

  final StreamController<MessageDeliveryUpdate> _deliveryController =
      StreamController<MessageDeliveryUpdate>.broadcast();
  final StreamController<SmsRetryExhaustedEvent> _retryController =
      StreamController<SmsRetryExhaustedEvent>.broadcast();

  @override
  Future<bool> canAutoSend(MessageChannel channel) async {
    calls.add('canAutoSend:${channel.name}');
    return true;
  }

  @override
  Future<MessageWorkId> sendMessage({
    required EmergencyContact contact,
    required String message,
    required MessageChannel channel,
    bool isSimulation = false,
  }) async {
    calls.add('sendMessage:${contact.phoneNumber}/${channel.name}');
    sentMessages.add(
      (contact: contact, message: message, channel: channel),
    );
    return MessageWorkId('fake-${_nextWorkId++}');
  }

  @override
  Future<List<MessageWorkId>> sendToAll({
    required List<EmergencyContact> contacts,
    required String message,
    bool isSimulation = false,
  }) async {
    calls.add('sendToAll:${contacts.length}');
    return [
      for (var i = 0; i < contacts.length; i++)
        MessageWorkId('fake-${_nextWorkId++}'),
    ];
  }

  @override
  Future<void> cancelPending(List<MessageWorkId> workIds) async {
    calls.add('cancelPending:${workIds.length}');
  }

  @override
  Stream<MessageDeliveryUpdate> get deliveryUpdates =>
      _deliveryController.stream;

  @override
  Stream<SmsRetryExhaustedEvent> get smsRetryExhausted =>
      _retryController.stream;

  @override
  Future<void> retryExhaustedSms(String workId) async {
    calls.add('retryExhaustedSms:$workId');
  }

  /// Test helper: synthesize a delivery update on the stream.
  void injectDeliveryUpdate(MessageDeliveryUpdate update) {
    _deliveryController.add(update);
  }

  /// Test helper: synthesize a retry-exhausted event on the stream.
  void injectRetryExhausted(SmsRetryExhaustedEvent event) {
    _retryController.add(event);
  }

  /// Closes all stream controllers.
  void dispose() {
    _deliveryController.close();
    _retryController.close();
  }
}
