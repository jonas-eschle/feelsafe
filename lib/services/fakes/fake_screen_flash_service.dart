/// Deterministic fake implementation of [ScreenFlashServiceProtocol]
/// for tests. Records every call and exposes a manual tick injector
/// so widget tests can advance the strobe deterministically.
library;

import 'dart:async';

import 'package:guardianangela/services/protocols/screen_flash_service_protocol.dart';

/// Test double for [ScreenFlashServiceProtocol].
final class FakeScreenFlashService implements ScreenFlashServiceProtocol {
  /// Creates a fake screen-flash service.
  FakeScreenFlashService();

  /// Invocation log: one entry per method call.
  final List<String> calls = [];

  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  bool _isFlashing = false;

  @override
  Stream<bool> get ticks => _controller.stream;

  @override
  bool get isFlashing => _isFlashing;

  @override
  Future<void> start({Duration interval = kDefaultScreenFlashInterval}) async {
    calls.add('start:${interval.inMilliseconds}');
    _isFlashing = true;
  }

  @override
  Future<void> stop() async {
    calls.add('stop');
    _isFlashing = false;
  }

  /// Test helper: synthesize a tick on the broadcast stream.
  void emit(bool value) {
    _controller.add(value);
  }

  /// Closes the broadcast controller.
  void dispose() {
    _controller.close();
  }
}
