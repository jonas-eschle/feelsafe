/// Deterministic fake implementation of [FlashServiceProtocol] for
/// tests. Every call is recorded to [calls]; no platform channel is
/// touched.
library;

import 'package:guardianangela/services/protocols/flash_service_protocol.dart';

/// Test double for [FlashServiceProtocol].
final class FakeFlashService implements FlashServiceProtocol {
  /// Creates a fake flash service.
  FakeFlashService();

  /// Invocation log: one entry per method call.
  final List<String> calls = [];

  bool _isStrobing = false;

  @override
  bool get isStrobing => _isStrobing;

  @override
  Future<void> startStrobe({
    Duration interval = kDefaultFlashStrobeInterval,
  }) async {
    calls.add('startStrobe:${interval.inMilliseconds}');
    _isStrobing = true;
  }

  @override
  Future<void> stopStrobe() async {
    calls.add('stopStrobe');
    _isStrobing = false;
  }
}
