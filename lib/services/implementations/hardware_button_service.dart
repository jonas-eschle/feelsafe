/// Real hardware-button-service implementation.
///
/// Dart-side only. Android uses a native event channel
/// (`com.guardianangela.app/hardware_buttons`) which emits completed
/// panic detections. iOS listens for the headphone remote via
/// `audio_service` (which in turn uses MPRemoteCommandCenter). Phase
/// 10 writes the native backends.
library;

import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:guardianangela/services/protocols/hardware_button_service_protocol.dart';

/// Real platform-backed implementation of
/// [HardwareButtonServiceProtocol].
final class HardwareButtonService implements HardwareButtonServiceProtocol {
  /// Creates the real hardware-button service.
  HardwareButtonService();

  static const MethodChannel _methodChannel = MethodChannel(
    'com.guardianangela.app/hardware_buttons',
  );
  static const EventChannel _eventChannel = EventChannel(
    'com.guardianangela.app/hardware_button_events',
  );

  final StreamController<HardwarePanicEvent> _controller =
      StreamController<HardwarePanicEvent>.broadcast();

  StreamSubscription<Object?>? _nativeSub;
  bool _listening = false;

  @override
  Stream<HardwarePanicEvent> get panicEvents => _controller.stream;

  @override
  bool get isListening => _listening;

  @override
  Future<void> start({
    required String buttonType,
    required String pattern,
    int pressCount = 5,
    int pressWindowMs = 500,
    double longPressDurationSeconds = 2.0,
  }) async {
    if (_listening) return;
    try {
      await _methodChannel.invokeMethod<void>('start', {
        'buttonType': buttonType,
        'pattern': pattern,
        'pressCount': pressCount,
        'pressWindowMs': pressWindowMs,
        'longPressDurationSeconds': longPressDurationSeconds,
      });
    } on MissingPluginException {
      return Future.error('Not wired — Phase 10');
    } on PlatformException catch (e, s) {
      developer.log(
        'hardware_buttons.start platform error',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
    _nativeSub = _eventChannel.receiveBroadcastStream().listen(
      _onNativeEvent,
      onError: (Object e, StackTrace s) {
        developer.log(
          'hardware_buttons event error',
          error: e,
          stackTrace: s,
        );
      },
    );
    _listening = true;
  }

  @override
  Future<void> stop() async {
    await _nativeSub?.cancel();
    _nativeSub = null;
    _listening = false;
    try {
      await _methodChannel.invokeMethod<void>('stop');
    } on MissingPluginException {
      // Phase 10 not wired — nothing to stop.
    } on PlatformException catch (e, s) {
      developer.log(
        'hardware_buttons.stop platform error',
        error: e,
        stackTrace: s,
      );
    }
  }

  void _onNativeEvent(Object? raw) {
    if (raw is! Map) return;
    final map = Map<String, Object?>.from(raw);
    final buttonType = map['buttonType'] as String? ?? 'unknown';
    final pattern = map['pattern'] as String? ?? 'unknown';
    final timestampMs = map['timestampMs'] as int?;
    final timestamp = timestampMs == null
        ? DateTime.now().toUtc()
        : DateTime.fromMillisecondsSinceEpoch(
            timestampMs,
            isUtc: true,
          );
    _controller.add(
      HardwarePanicEvent(
        buttonType: buttonType,
        pattern: pattern,
        timestamp: timestamp,
      ),
    );
  }
}
