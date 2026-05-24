import 'dart:async';
import 'dart:developer';

import 'package:torch_light/torch_light.dart';

import 'package:guardianangela/services/protocols/flash_service_protocol.dart';

/// Production [FlashServiceProtocol] backed by `package:torch_light`.
///
/// Both [startSosFlash] and [startContinuousFlash] run async loops that
/// alternate [TorchLight.enableTorch] / [TorchLight.disableTorch] and
/// sleep between steps using [Future.delayed]. [stopFlash] sets
/// [isFlashing] to `false`, which causes the loop to exit on its next
/// iteration.
///
/// If the camera is unavailable or permission is denied, all methods
/// silently degrade per spec 05 §FlashService §Graceful Degradation.
///
/// **Single constructor location rule:** no `RealFlashService()`
/// call may appear outside `lib/services/service_providers.dart`
/// (CI grep enforces).
class RealFlashService implements FlashServiceProtocol {
  /// Creates a [RealFlashService].
  RealFlashService();

  bool _isFlashing = false;

  /// Whether the flash is currently active.
  bool get isFlashing => _isFlashing;

  // ---------------------------------------------------------------------------
  // SOS timing constants (milliseconds) — spec 05 §FlashService §SOS Pattern.
  // ---------------------------------------------------------------------------

  static const int _dot = 200;
  static const int _dash = 600;
  static const int _interSymbol = 200;
  static const int _interLetter = 600;
  static const int _cycleGap = 1000;

  @override
  Future<void> startSosFlash() async {
    if (_isFlashing) await stopFlash();
    log('startSosFlash — beginning SOS morse-code strobe', name: 'FlashService');
    _isFlashing = true;
    // Run the loop in a detached async task; startSosFlash returns
    // immediately after setting the flag.
    unawaited(_sosLoop());
  }

  /// Starts a continuous fast-strobe pattern (200 ms on / 200 ms off).
  ///
  /// Not part of [FlashServiceProtocol] (used by Phase 6 direct call).
  Future<void> startContinuousFlash() async {
    if (_isFlashing) await stopFlash();
    log(
      'startContinuousFlash — beginning continuous strobe',
      name: 'FlashService',
    );
    _isFlashing = true;
    unawaited(_continuousLoop());
  }

  @override
  Future<void> stopFlash() async {
    if (!_isFlashing) return;
    log('stopFlash — stopping flash loop', name: 'FlashService');
    _isFlashing = false;
    // Give the loop one tick to exit and disable the torch.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    await _setTorch(torchOn: false);
  }

  // ---------------------------------------------------------------------------
  // Private loop helpers
  // ---------------------------------------------------------------------------

  /// SOS: ··· −−− ···  (repeats until [_isFlashing] is false).
  Future<void> _sosLoop() async {
    while (_isFlashing) {
      // S — three dots
      for (var i = 0; i < 3 && _isFlashing; i++) {
        await _setTorch(torchOn: true);
        await _sleep(_dot);
        await _setTorch(torchOn: false);
        final gap = (i < 2) ? _interSymbol : _interLetter;
        await _sleep(gap);
      }
      // O — three dashes
      for (var i = 0; i < 3 && _isFlashing; i++) {
        await _setTorch(torchOn: true);
        await _sleep(_dash);
        await _setTorch(torchOn: false);
        final gap = (i < 2) ? _interSymbol : _interLetter;
        await _sleep(gap);
      }
      // S — three dots
      for (var i = 0; i < 3 && _isFlashing; i++) {
        await _setTorch(torchOn: true);
        await _sleep(_dot);
        await _setTorch(torchOn: false);
        final gap = (i < 2) ? _interSymbol : _cycleGap;
        await _sleep(gap);
      }
    }
    await _setTorch(torchOn: false);
  }

  /// Fast strobe (200 ms on / 200 ms off) until [_isFlashing] is false.
  Future<void> _continuousLoop() async {
    while (_isFlashing) {
      await _setTorch(torchOn: true);
      await _sleep(200);
      await _setTorch(torchOn: false);
      await _sleep(200);
    }
    await _setTorch(torchOn: false);
  }

  Future<void> _sleep(int ms) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  /// Enables or disables the torch; silently degrades on hardware/permission
  /// errors per spec 05 §FlashService §Graceful Degradation.
  Future<void> _setTorch({required bool torchOn}) async {
    try {
      if (torchOn) {
        await TorchLight.enableTorch();
      } else {
        await TorchLight.disableTorch();
      }
    } catch (e) {
      log(
        'torch unavailable or permission denied — degrading: $e',
        name: 'FlashService',
      );
      // Set flag so the loop exits on its next iteration.
      _isFlashing = false;
    }
  }
}
