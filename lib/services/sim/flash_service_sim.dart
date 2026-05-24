import 'dart:async';

import 'package:guardianangela/services/protocols/flash_service_protocol.dart';

/// A recorded on/off event emitted by [SimulationFlashService].
final class FlashEvent {
  /// Creates a [FlashEvent].
  const FlashEvent({required this.torchOn, required this.timestamp});

  /// `true` = torch on; `false` = torch off.
  final bool torchOn;

  /// Wall time of the event (uses [DateTime.now] at construction).
  final DateTime timestamp;

  @override
  String toString() => 'FlashEvent(torchOn: $torchOn)';
}

/// Simulation [FlashServiceProtocol] for tests and simulation isolates.
///
/// Records on/off events in [events]; never calls the native camera plugin.
/// [isFlashing] toggles exactly as the real service does.
class SimulationFlashService implements FlashServiceProtocol {
  /// Creates a [SimulationFlashService].
  ///
  /// [tickMs] controls the simulated strobe interval used by the internal
  /// loop (default 50 ms for tests). Inject a smaller value for faster tests.
  SimulationFlashService({int tickMs = 50}) : _tickMs = tickMs;

  final int _tickMs;

  bool _isFlashing = false;

  /// All on/off events emitted since construction or last [reset].
  final List<FlashEvent> events = [];

  /// Ordered call log: `'startSosFlash'`, `'startContinuousFlash'`,
  /// `'stopFlash'`.
  final List<String> calls = [];

  /// Whether the flash is currently active.
  bool get isFlashing => _isFlashing;

  @override
  Future<void> startSosFlash() async {
    calls.add('startSosFlash');
    if (_isFlashing) await stopFlash();
    _isFlashing = true;
    unawaited(_runLoop(isSos: true));
  }

  /// Starts a continuous strobe pattern (sim version).
  Future<void> startContinuousFlash() async {
    calls.add('startContinuousFlash');
    if (_isFlashing) await stopFlash();
    _isFlashing = true;
    unawaited(_runLoop(isSos: false));
  }

  @override
  Future<void> stopFlash() async {
    calls.add('stopFlash');
    _isFlashing = false;
    await Future<void>.delayed(Duration(milliseconds: _tickMs + 10));
    _addEvent(torchOn: false);
  }

  /// Clears all state (events and calls).
  void reset() {
    events.clear();
    calls.clear();
    _isFlashing = false;
  }

  void _addEvent({required bool torchOn}) {
    events.add(FlashEvent(torchOn: torchOn, timestamp: DateTime.now()));
  }

  Future<void> _runLoop({required bool isSos}) async {
    while (_isFlashing) {
      _addEvent(torchOn: true);
      await Future<void>.delayed(Duration(milliseconds: _tickMs));
      _addEvent(torchOn: false);
      await Future<void>.delayed(Duration(milliseconds: _tickMs));
    }
  }
}
