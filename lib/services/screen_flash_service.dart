import 'dart:async';
import 'dart:developer';

import 'package:guardianangela/services/protocols/screen_flash_service_protocol.dart';

/// A single frame event emitted by [ScreenFlashServiceProtocol] impls.
///
/// The overlay widget (Phase 6) subscribes to the stream and renders the
/// appropriate background color. [isWhite] alternates with each frame.
final class ScreenFlashFrame {
  /// Creates a [ScreenFlashFrame].
  const ScreenFlashFrame({required this.isWhite});

  /// `true` → white background; `false` → red background.
  final bool isWhite;

  @override
  String toString() => 'ScreenFlashFrame(isWhite: $isWhite)';
}

/// Production [ScreenFlashServiceProtocol] — pure-Dart, stream-based.
///
/// Emits [ScreenFlashFrame] events from a [Timer.periodic] loop. The
/// overlay widget (Phase 6) subscribes via [frames] and renders the
/// correct background color.
///
/// [startScreenFlash] accepts [speed] `'fast'` (500 ms) or `'slow'`
/// (1000 ms, default). See spec 05 §ScreenFlashService §Flash Speeds.
///
/// **Single constructor location rule:** no `RealScreenFlashService()`
/// call may appear outside `lib/services/service_providers.dart`
/// (CI grep enforces).
class RealScreenFlashService implements ScreenFlashServiceProtocol {
  /// Creates a [RealScreenFlashService].
  RealScreenFlashService();

  final StreamController<ScreenFlashFrame> _controller =
      StreamController<ScreenFlashFrame>.broadcast();

  Timer? _timer;
  bool _isWhite = true;

  /// Broadcast stream of [ScreenFlashFrame] events.
  ///
  /// The overlay widget in Phase 6 subscribes here.
  Stream<ScreenFlashFrame> get frames => _controller.stream;

  @override
  Future<void> startScreenFlash({String speed = 'slow'}) async {
    if (_timer != null) await stopScreenFlash();

    final intervalMs = switch (speed) {
      'fast' => 500,
      'slow' => 1000,
      _ => throw ArgumentError.value(
        speed,
        'speed',
        'Must be "fast" or "slow"',
      ),
    };

    log(
      'startScreenFlash — ${speed == "fast" ? "500ms" : "1000ms"} interval',
      name: 'ScreenFlashService',
    );

    _isWhite = true;
    _timer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      _controller.add(ScreenFlashFrame(isWhite: _isWhite));
      _isWhite = !_isWhite;
    });
  }

  @override
  Future<void> stopScreenFlash() async {
    _timer?.cancel();
    _timer = null;
    log('stopScreenFlash — stopped', name: 'ScreenFlashService');
  }

  /// Disposes the stream controller. Call when the service is torn down.
  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
