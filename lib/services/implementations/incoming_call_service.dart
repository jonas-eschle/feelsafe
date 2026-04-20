/// Real incoming-call-service implementation stub. Phase 9 fills
/// bodies.
library;

import 'package:guardianangela/services/protocols/incoming_call_service_protocol.dart';

/// Real platform-backed implementation of
/// [IncomingCallServiceProtocol].
final class IncomingCallService implements IncomingCallServiceProtocol {
  /// Creates the real incoming-call service.
  IncomingCallService();

  @override
  Stream<CallState> get callState =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> startListening() async =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> stopListening() async =>
      throw UnimplementedError('TODO: Phase 9 real impl');
}
