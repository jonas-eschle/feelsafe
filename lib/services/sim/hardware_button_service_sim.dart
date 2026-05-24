import 'dart:async';

import 'package:guardianangela/domain/enums/hardware_button_type.dart';
import 'package:guardianangela/domain/enums/hardware_trigger_pattern.dart';
import 'package:guardianangela/domain/models/hardware_panic_event.dart';
import 'package:guardianangela/services/protocols/hardware_button_service_protocol.dart';

/// Simulation [HardwareButtonServiceProtocol] for tests.
///
/// Exposes [injectPress] to drive the pure-Dart repeat-press and long-press
/// detection logic without any platform channels. Never calls native code.
class SimulationHardwareButtonService implements HardwareButtonServiceProtocol {
  /// Creates a [SimulationHardwareButtonService].
  SimulationHardwareButtonService();

  final StreamController<HardwarePanicEvent> _panicController =
      StreamController<HardwarePanicEvent>.broadcast();

  bool _listening = false;
  HardwareButtonType _buttonType = HardwareButtonType.volumeUp;
  HardwareTriggerPattern _pattern = HardwareTriggerPattern.repeatPress;
  int _pressCount = 5;
  int _pressWindowMs = 500;
  double _longPressDurationSeconds = 2.0;

  // Repeat-press state.
  final List<DateTime> _pressTimes = [];

  // Long-press state.
  DateTime? _pressDownTime;

  // ---------------------------------------------------------------------------
  // HardwareButtonServiceProtocol implementation
  // ---------------------------------------------------------------------------

  @override
  Stream<HardwarePanicEvent> get panicEvents => _panicController.stream;

  @override
  bool get isListening => _listening;

  @override
  void start({
    HardwareButtonType? buttonType,
    HardwareTriggerPattern? pattern,
    int? pressCount,
    int? pressWindowMs,
    double? longPressDurationSeconds,
  }) {
    _buttonType = buttonType ?? HardwareButtonType.volumeUp;
    _pattern = pattern ?? HardwareTriggerPattern.repeatPress;
    _pressCount = pressCount?.clamp(2, 10) ?? 5;
    _pressWindowMs = pressWindowMs?.clamp(200, 2000) ?? 500;
    _longPressDurationSeconds =
        longPressDurationSeconds?.clamp(1.0, 10.0) ?? 2.0;
    _listening = true;
    _pressTimes.clear();
    _pressDownTime = null;
  }

  @override
  void stop() {
    _listening = false;
    _pressTimes.clear();
    _pressDownTime = null;
  }

  @override
  void updateConfig({
    HardwareButtonType? buttonType,
    HardwareTriggerPattern? pattern,
    int? pressCount,
    int? pressWindowMs,
    double? longPressDurationSeconds,
  }) {
    if (buttonType != null) _buttonType = buttonType;
    if (pattern != null) _pattern = pattern;
    if (pressCount != null) _pressCount = pressCount.clamp(2, 10);
    if (pressWindowMs != null) _pressWindowMs = pressWindowMs.clamp(200, 2000);
    if (longPressDurationSeconds != null) {
      _longPressDurationSeconds = longPressDurationSeconds.clamp(1.0, 10.0);
    }
    _pressTimes.clear();
    _pressDownTime = null;
  }

  @override
  void dispose() {
    stop();
    _panicController.close();
  }

  // ---------------------------------------------------------------------------
  // Test helpers
  // ---------------------------------------------------------------------------

  /// Simulates a button press at [timestamp] (defaults to [DateTime.now]).
  ///
  /// For [HardwareTriggerPattern.repeatPress]: drives the press counter.
  /// For [HardwareTriggerPattern.longPress]: call with [isDown]=`true` for
  /// button-down, then with [isDown]=`false` for button-up (button release).
  void injectPress({DateTime? timestamp, bool isDown = true}) {
    if (!_listening) return;
    final t = timestamp ?? DateTime.now().toUtc();

    switch (_pattern) {
      case HardwareTriggerPattern.repeatPress:
        _handleRepeatPress(t);
      case HardwareTriggerPattern.longPress:
        if (isDown) {
          _pressDownTime = t;
        } else if (_pressDownTime != null) {
          final durationMs = t.difference(_pressDownTime!).inMilliseconds;
          _pressDownTime = null;
          final requiredMs = (_longPressDurationSeconds * 1000).round();
          if (durationMs >= requiredMs) {
            _emit(HardwareTriggerPattern.longPress, t);
          }
        }
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _handleRepeatPress(DateTime t) {
    final windowStart = t.subtract(Duration(milliseconds: _pressWindowMs));
    _pressTimes.removeWhere((pt) => pt.isBefore(windowStart));
    _pressTimes.add(t);
    if (_pressTimes.length >= _pressCount) {
      _pressTimes.clear();
      _emit(HardwareTriggerPattern.repeatPress, t);
    }
  }

  void _emit(HardwareTriggerPattern pattern, DateTime t) {
    if (_panicController.isClosed) return;
    _panicController.add(
      HardwarePanicEvent(
        buttonType: _buttonType,
        pattern: pattern,
        timestamp: t,
      ),
    );
  }
}
