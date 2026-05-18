/// Real implementation of [ScreenFlashServiceProtocol].
///
/// Owns a broadcast `StreamController<bool>` that emits one tick per
/// half-cycle (true → primary colour, false → alternate). The
/// `ScreenFlashOverlay` widget listens and repaints accordingly.
///
/// Pure Dart-Timer based — no platform plugin needed.
library;

import 'dart:async';

import 'package:guardianangela/services/protocols/screen_flash_service_protocol.dart';

/// Real implementation of [ScreenFlashServiceProtocol].
final class ScreenFlashService implements ScreenFlashServiceProtocol {
  /// Creates the service.
  ScreenFlashService();

  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  Timer? _timer;
  bool _phase = false;

  @override
  Stream<bool> get ticks => _controller.stream;

  @override
  bool get isFlashing => _timer != null;

  @override
  Future<void> start({Duration interval = kDefaultScreenFlashInterval}) async {
    final halfCycle = Duration(microseconds: interval.inMicroseconds ~/ 2);
    if (halfCycle <= Duration.zero) {
      throw ArgumentError.value(
        interval,
        'interval',
        'must be at least 2 microseconds long',
      );
    }
    await stop();
    _phase = false;
    // Emit the first tick immediately so subscribers don't wait one
    // half-cycle for the visual to start.
    _controller.add(true);
    _phase = true;
    _timer = Timer.periodic(halfCycle, (_) {
      _phase = !_phase;
      _controller.add(_phase);
    });
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    if (_phase) {
      _phase = false;
      // Emit a final "off" tick so the overlay paints back to the
      // alternate (idle) colour instead of being stuck on the
      // primary.
      if (!_controller.isClosed) {
        _controller.add(false);
      }
    }
  }

  /// Releases the broadcast controller. Call from
  /// `ref.onDispose(...)` in `service_providers.dart`.
  Future<void> dispose() async {
    _timer?.cancel();
    _timer = null;
    if (!_controller.isClosed) {
      await _controller.close();
    }
  }
}
