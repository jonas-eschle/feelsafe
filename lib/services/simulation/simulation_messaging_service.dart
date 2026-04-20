/// Simulation implementation of [MessagingServiceProtocol].
///
/// CRITICAL: this file MUST NOT import `url_launcher` or declare any
/// [MethodChannel] — simulation layer 2 guarantees no real SMS /
/// WhatsApp / Telegram sending can ever occur during a simulated
/// session. Every method logs and returns a no-op.
library;

import 'dart:async';
import 'dart:developer' as developer;

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/services/protocols/messaging_service_protocol.dart';

/// Simulation double for [MessagingServiceProtocol]. All methods are
/// structural no-ops logged via `dart:developer`.
final class SimulationMessagingService implements MessagingServiceProtocol {
  /// Creates the simulation messaging service.
  SimulationMessagingService();

  int _nextWorkId = 0;

  final StreamController<MessageDeliveryUpdate> _deliveryController =
      StreamController<MessageDeliveryUpdate>.broadcast();
  final StreamController<SmsRetryExhaustedEvent> _retryController =
      StreamController<SmsRetryExhaustedEvent>.broadcast();

  @override
  Future<bool> canAutoSend(MessageChannel channel) async {
    developer.log('[SIM] messaging.canAutoSend(${channel.name})');
    return true;
  }

  @override
  Future<MessageWorkId> sendMessage({
    required EmergencyContact contact,
    required String message,
    required MessageChannel channel,
    bool isSimulation = false,
  }) async {
    developer.log(
      '[SIM] messaging.sendMessage to ${contact.phoneNumber} '
      'via ${channel.name}',
    );
    return MessageWorkId('sim-${_nextWorkId++}');
  }

  @override
  Future<List<MessageWorkId>> sendToAll({
    required List<EmergencyContact> contacts,
    required String message,
    bool isSimulation = false,
  }) async {
    developer.log('[SIM] messaging.sendToAll n=${contacts.length}');
    return [
      for (var i = 0; i < contacts.length; i++)
        MessageWorkId('sim-${_nextWorkId++}'),
    ];
  }

  @override
  Future<void> cancelPending(List<MessageWorkId> workIds) async {
    developer.log('[SIM] messaging.cancelPending n=${workIds.length}');
  }

  @override
  Stream<MessageDeliveryUpdate> get deliveryUpdates =>
      _deliveryController.stream;

  @override
  Stream<SmsRetryExhaustedEvent> get smsRetryExhausted =>
      _retryController.stream;

  @override
  Future<void> retryExhaustedSms(String workId) async {
    developer.log('[SIM] messaging.retryExhaustedSms $workId');
  }

  /// Closes all stream controllers.
  void dispose() {
    _deliveryController.close();
    _retryController.close();
  }
}
