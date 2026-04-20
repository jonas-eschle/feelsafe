/// Real messaging-service implementation stub. Phase 9 fills bodies.
library;

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/services/protocols/messaging_service_protocol.dart';

/// Real platform-backed implementation of [MessagingServiceProtocol].
final class MessagingService implements MessagingServiceProtocol {
  /// Creates the real messaging service.
  MessagingService();

  @override
  Future<bool> canAutoSend(MessageChannel channel) async =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<MessageWorkId> sendMessage({
    required EmergencyContact contact,
    required String message,
    required MessageChannel channel,
    bool isSimulation = false,
  }) async => throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<List<MessageWorkId>> sendToAll({
    required List<EmergencyContact> contacts,
    required String message,
    bool isSimulation = false,
  }) async => throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> cancelPending(List<MessageWorkId> workIds) async =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Stream<MessageDeliveryUpdate> get deliveryUpdates =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Stream<SmsRetryExhaustedEvent> get smsRetryExhausted =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> retryExhaustedSms(String workId) async =>
      throw UnimplementedError('TODO: Phase 9 real impl');
}
