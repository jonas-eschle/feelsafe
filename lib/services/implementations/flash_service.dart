/// Real platform-backed implementation of [FlashServiceProtocol].
///
/// Wraps `torch_light`. The plugin is reached through injected
/// function callbacks so tests can substitute a fake torch without
/// instantiating the platform channel.
///
/// Design notes:
/// * Strobe is Dart-Timer driven (periodic, half-cycle). The on/off
///   tick toggles a boolean so a torch that was never available
///   silently no-ops without throwing.
/// * Plugin exceptions (no-torch / camera-busy) are swallowed and
///   logged — the loud-alarm step is best-effort and audio +
///   vibration are still firing on the same step. Throwing here would
///   crash the strategy without changing the safety outcome.
library;

import 'dart:async';
import 'dart:developer' as developer;

import 'package:torch_light/torch_light.dart';

import 'package:guardianangela/services/protocols/flash_service_protocol.dart';

/// Function that turns the torch on. Injected for tests.
typedef TorchEnable = Future<void> Function();

/// Function that turns the torch off. Injected for tests.
typedef TorchDisable = Future<void> Function();

/// Real platform-backed implementation of [FlashServiceProtocol].
final class FlashService implements FlashServiceProtocol {
  /// Creates the flash service.
  ///
  /// [enableTorch] / [disableTorch] default to the static methods of
  /// `torch_light`; tests inject fakes to avoid the platform channel.
  FlashService({TorchEnable? enableTorch, TorchDisable? disableTorch})
    : _enableTorch = enableTorch ?? TorchLight.enableTorch,
      _disableTorch = disableTorch ?? TorchLight.disableTorch;

  final TorchEnable _enableTorch;
  final TorchDisable _disableTorch;

  Timer? _timer;
  bool _torchOn = false;

  @override
  bool get isStrobing => _timer != null;

  @override
  Future<void> startStrobe({
    Duration interval = kDefaultFlashStrobeInterval,
  }) async {
    final halfCycle = Duration(microseconds: interval.inMicroseconds ~/ 2);
    if (halfCycle <= Duration.zero) {
      throw ArgumentError.value(
        interval,
        'interval',
        'must be at least 2 microseconds long',
      );
    }
    // Cancel any in-flight strobe before rebasing the schedule. This
    // also clears `_torchOn` to a known state.
    await stopStrobe();
    _timer = Timer.periodic(halfCycle, (_) => _toggle());
  }

  Future<void> _toggle() async {
    try {
      if (_torchOn) {
        await _disableTorch();
      } else {
        await _enableTorch();
      }
      _torchOn = !_torchOn;
    } on Exception catch (e) {
      developer.log('[FlashService] torch toggle failed: $e');
      // Stop strobing on persistent failure so we are not spamming
      // the platform channel. The next call to startStrobe will retry.
      _timer?.cancel();
      _timer = null;
      _torchOn = false;
    }
  }

  @override
  Future<void> stopStrobe() async {
    final wasOn = _torchOn;
    _timer?.cancel();
    _timer = null;
    _torchOn = false;
    if (wasOn) {
      try {
        await _disableTorch();
      } on Exception catch (e) {
        developer.log('[FlashService] torch off-on-stop failed: $e');
      }
    }
  }
}
