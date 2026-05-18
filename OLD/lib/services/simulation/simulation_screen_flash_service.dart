/// Simulation implementation of [ScreenFlashServiceProtocol]. Logs
/// via `dart:developer` and emits the same stream of ticks as the
/// real service so simulation-mode previews can still observe the
/// strobe in their UI when desired.
library;

import 'dart:async';
import 'dart:developer' as developer;

import 'package:guardianangela/services/protocols/screen_flash_service_protocol.dart';

/// Simulation double for [ScreenFlashServiceProtocol].
final class SimulationScreenFlashService implements ScreenFlashServiceProtocol {
  /// Creates the simulation screen-flash service.
  SimulationScreenFlashService();

  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  Timer? _timer;
  bool _phase = false;

  @override
  Stream<bool> get ticks => _controller.stream;

  @override
  bool get isFlashing => _timer != null;

  @override
  Future<void> start({Duration interval = kDefaultScreenFlashInterval}) async {
    developer.log(
      '[SIM] screenFlash.start interval=${interval.inMilliseconds}ms',
    );
    await stop();
    final halfCycle = Duration(microseconds: interval.inMicroseconds ~/ 2);
    if (halfCycle <= Duration.zero) {
      throw ArgumentError.value(
        interval,
        'interval',
        'must be at least 2 microseconds long',
      );
    }
    _phase = true;
    _controller.add(true);
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
      if (!_controller.isClosed) {
        _controller.add(false);
      }
    }
    developer.log('[SIM] screenFlash.stop');
  }
}
