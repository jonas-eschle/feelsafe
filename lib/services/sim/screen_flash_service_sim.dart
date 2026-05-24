import 'dart:async';

import 'package:guardianangela/services/protocols/screen_flash_service_protocol.dart';
import 'package:guardianangela/services/screen_flash_service.dart';

/// Simulation [ScreenFlashServiceProtocol] for tests and simulation isolates.
///
/// Emits [ScreenFlashFrame] events on the same stream pattern as
/// [RealScreenFlashService]. Records events into [frames] list and all
/// method calls in [calls] so tests can assert behavior without a real timer.
class SimulationScreenFlashService implements ScreenFlashServiceProtocol {
  /// Creates a [SimulationScreenFlashService].
  ///
  /// [tickMs] controls how fast the simulated timer fires (default 50 ms).
  SimulationScreenFlashService({int tickMs = 50}) : _tickMs = tickMs;

  final int _tickMs;
  final StreamController<ScreenFlashFrame> _controller =
      StreamController<ScreenFlashFrame>.broadcast();

  Timer? _timer;
  bool _isWhite = true;

  /// All emitted [ScreenFlashFrame] events since construction or last [reset].
  final List<ScreenFlashFrame> recordedFrames = [];

  /// Ordered call log: `'startScreenFlash:slow'`, `'startScreenFlash:fast'`,
  /// `'stopScreenFlash'`.
  final List<String> calls = [];

  /// Broadcast stream of [ScreenFlashFrame] events (same API as real service).
  Stream<ScreenFlashFrame> get frameStream => _controller.stream;

  @override
  Future<void> startScreenFlash({String speed = 'slow'}) async {
    if (speed != 'fast' && speed != 'slow') {
      throw ArgumentError.value(speed, 'speed', 'Must be "fast" or "slow"');
    }
    calls.add('startScreenFlash:$speed');
    if (_timer != null) await stopScreenFlash();

    _isWhite = true;
    _timer = Timer.periodic(Duration(milliseconds: _tickMs), (_) {
      final frame = ScreenFlashFrame(isWhite: _isWhite);
      recordedFrames.add(frame);
      _controller.add(frame);
      _isWhite = !_isWhite;
    });
  }

  @override
  Future<void> stopScreenFlash() async {
    calls.add('stopScreenFlash');
    _timer?.cancel();
    _timer = null;
  }

  /// Clears [recordedFrames] and [calls]; resets internal state.
  void reset() {
    _timer?.cancel();
    _timer = null;
    recordedFrames.clear();
    calls.clear();
    _isWhite = true;
  }

  /// Disposes the stream controller.
  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
