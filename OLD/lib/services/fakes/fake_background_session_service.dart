/// Deterministic fake implementation of
/// [BackgroundSessionServiceProtocol] for tests. Records every
/// call, exposes a manual-action injector so tests can synthesize
/// taps, and tracks the running flag.
library;

import 'dart:async';

import 'package:guardianangela/services/protocols/background_session_service_protocol.dart';

/// Test double for [BackgroundSessionServiceProtocol].
final class FakeBackgroundSessionService
    implements BackgroundSessionServiceProtocol {
  /// Creates a fake background session service.
  FakeBackgroundSessionService();

  /// Invocation log: one entry per method call.
  final List<String> calls = [];

  final StreamController<BackgroundAction> _controller =
      StreamController<BackgroundAction>.broadcast();
  bool _running = false;

  @override
  Stream<BackgroundAction> get actions => _controller.stream;

  @override
  bool get isRunning => _running;

  @override
  Future<void> start({
    required String title,
    required String body,
    bool isSimulation = false,
  }) async {
    calls.add('start:$title');
    _running = true;
  }

  @override
  Future<void> updateStatus({
    required String title,
    required String body,
    bool isSimulation = false,
  }) async {
    calls.add('updateStatus:$title');
  }

  @override
  Future<void> stop() async {
    calls.add('stop');
    _running = false;
  }

  /// Test helper: synthesize a [BackgroundAction] on the stream.
  void injectAction(BackgroundAction action) {
    _controller.add(action);
  }

  /// Closes the broadcast controller.
  void dispose() {
    _controller.close();
  }
}
