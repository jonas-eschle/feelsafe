// Native channel handler lands in Phase 7
// (Android: HardwareButtonChannel.kt / EventChannel
//  'com.guardianangela.app/hardware_button';
//  iOS: audio_service BaseAudioHandler _GuardianAudioHandler).

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart' show EventChannel;

import 'package:audio_service/audio_service.dart';

import 'package:guardianangela/domain/enums/hardware_button_type.dart';
import 'package:guardianangela/domain/enums/hardware_trigger_pattern.dart';
import 'package:guardianangela/domain/models/hardware_panic_event.dart';
import 'package:guardianangela/services/protocols/hardware_button_service_protocol.dart';

// ---------------------------------------------------------------------------
// Channel constants
// ---------------------------------------------------------------------------

const EventChannel _kEventChannel = EventChannel(
  'com.guardianangela.app/hardware_button',
);

// ---------------------------------------------------------------------------
// Default configuration (spec 05:740-749)
// ---------------------------------------------------------------------------

const HardwareButtonType _kDefaultButtonType = HardwareButtonType.volumeUp;
const HardwareTriggerPattern _kDefaultPattern =
    HardwareTriggerPattern.repeatPress;
const int _kDefaultPressCount = 5;
const int _kDefaultPressWindowMs = 500;
const double _kDefaultLongPressDurationSeconds = 2.0;

const int _kMinPressCount = 2;
const int _kMaxPressCount = 10;
const int _kMinPressWindowMs = 200;
const int _kMaxPressWindowMs = 2000;
const double _kMinLongPressDurationSeconds = 1.0;
const double _kMaxLongPressDurationSeconds = 10.0;

/// Production [HardwareButtonServiceProtocol].
///
/// **Android:** Listens on [EventChannel] `com.guardianangela.app/hardware_button`
/// which is driven by `HardwareButtonChannel.kt` (Phase 7). Volume key events
/// are consumed by `MainActivity.dispatchKeyEvent()`.
///
/// **iOS (C1):** Registers a [_GuardianAudioHandler] via `audio_service` so
/// the headphone remote (play/pause/skip buttons) drives the same press
/// counting logic. Long-press is not supported on iOS (no ACTION_DOWN/UP
/// timestamps).
///
/// Pattern detection (repeat-press counting, long-press duration) is
/// implemented in pure Dart so it is testable without platform involvement.
///
/// **Single constructor location rule:** no `RealHardwareButtonService()`
/// call may appear outside `lib/services/service_providers.dart`
/// (CI grep enforces).
class RealHardwareButtonService implements HardwareButtonServiceProtocol {
  /// Creates a [RealHardwareButtonService].
  RealHardwareButtonService();

  final StreamController<HardwarePanicEvent> _panicController =
      StreamController<HardwarePanicEvent>.broadcast();

  StreamSubscription<dynamic>? _eventSub;
  _GuardianAudioHandler? _iosHandler;

  HardwareButtonType _buttonType = _kDefaultButtonType;
  HardwareTriggerPattern _pattern = _kDefaultPattern;
  int _pressCount = _kDefaultPressCount;
  int _pressWindowMs = _kDefaultPressWindowMs;
  double _longPressDurationSeconds = _kDefaultLongPressDurationSeconds;

  bool _listening = false;

  // Repeat-press state.
  final List<DateTime> _pressTimes = [];

  // Long-press state.
  DateTime? _pressStartTime;

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
    _buttonType = buttonType ?? _kDefaultButtonType;
    _pattern = pattern ?? _kDefaultPattern;
    _pressCount = _clampPressCount(pressCount ?? _kDefaultPressCount);
    _pressWindowMs = _clampPressWindowMs(
      pressWindowMs ?? _kDefaultPressWindowMs,
    );
    _longPressDurationSeconds = _clampLongPressDuration(
      longPressDurationSeconds ?? _kDefaultLongPressDurationSeconds,
    );

    _pressTimes.clear();
    _pressStartTime = null;
    _listening = true;

    if (Platform.isAndroid) {
      _startAndroid();
    } else if (Platform.isIOS) {
      _startIos();
    }

    log(
      'start — button=$_buttonType pattern=$_pattern pressCount=$_pressCount '
      'windowMs=$_pressWindowMs longPressSecs=$_longPressDurationSeconds',
      name: 'HardwareButtonService',
    );
  }

  @override
  void stop() {
    _eventSub?.cancel();
    _eventSub = null;
    _iosHandler = null;
    _listening = false;
    _pressTimes.clear();
    _pressStartTime = null;
    log('stop', name: 'HardwareButtonService');
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
    if (pressCount != null) _pressCount = _clampPressCount(pressCount);
    if (pressWindowMs != null) {
      _pressWindowMs = _clampPressWindowMs(pressWindowMs);
    }
    if (longPressDurationSeconds != null) {
      _longPressDurationSeconds = _clampLongPressDuration(
        longPressDurationSeconds,
      );
    }
    _pressTimes.clear();
    _pressStartTime = null;
    log('updateConfig', name: 'HardwareButtonService');
  }

  @override
  void dispose() {
    stop();
    _panicController.close();
    log('dispose', name: 'HardwareButtonService');
  }

  // ---------------------------------------------------------------------------
  // Platform-specific start
  // ---------------------------------------------------------------------------

  void _startAndroid() {
    _eventSub = _kEventChannel.receiveBroadcastStream().listen(
      _onNativeEvent,
      onError: (Object e) {
        log('EventChannel error: $e', name: 'HardwareButtonService');
      },
    );
  }

  Future<void> _startIos() async {
    // audio_service registers a BaseAudioHandler that receives headphone
    // remote callbacks. The handler calls _onIosButtonPress for each event.
    _iosHandler = _GuardianAudioHandler(onPress: _onIosButtonPress);
    await AudioService.init<_GuardianAudioHandler>(
      builder: () => _iosHandler!,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.guardianangela.app.session_service',
        androidNotificationChannelName: 'Session',
      ),
    );
    log('iOS audio handler registered', name: 'HardwareButtonService');
  }

  // ---------------------------------------------------------------------------
  // Event handlers
  // ---------------------------------------------------------------------------

  void _onNativeEvent(dynamic event) {
    // Native layer sends a map: {'action': 'down'|'up', 'key': 'volume_up'|'volume_down'}
    if (event is! Map) return;
    final action = event['action'] as String?;
    final key = event['key'] as String?;

    final isTargetKey =
        (_buttonType == HardwareButtonType.volumeUp && key == 'volume_up') ||
        (_buttonType == HardwareButtonType.volumeDown && key == 'volume_down');
    if (!isTargetKey) return;

    switch (_pattern) {
      case HardwareTriggerPattern.repeatPress:
        if (action == 'down') _handleRepeatPress();
      case HardwareTriggerPattern.longPress:
        if (action == 'down') {
          _pressStartTime = DateTime.now();
        } else if (action == 'up' && _pressStartTime != null) {
          _handleLongPressUp();
        }
    }
  }

  void _onIosButtonPress() {
    // iOS headphone remote — only repeat-press pattern supported.
    if (_pattern == HardwareTriggerPattern.repeatPress) {
      _handleRepeatPress();
    }
  }

  void _handleRepeatPress() {
    final now = DateTime.now();
    final windowStart = now.subtract(Duration(milliseconds: _pressWindowMs));
    _pressTimes.removeWhere((t) => t.isBefore(windowStart));
    _pressTimes.add(now);

    log(
      'repeat press — count=${_pressTimes.length}/$_pressCount',
      name: 'HardwareButtonService',
    );

    if (_pressTimes.length >= _pressCount) {
      _pressTimes.clear();
      _emitPanic(HardwareTriggerPattern.repeatPress);
    }
  }

  void _handleLongPressUp() {
    final start = _pressStartTime!;
    _pressStartTime = null;
    final durationMs = DateTime.now().difference(start).inMilliseconds;
    final requiredMs = (_longPressDurationSeconds * 1000).round();

    log(
      'long press up — duration=${durationMs}ms required=${requiredMs}ms',
      name: 'HardwareButtonService',
    );

    if (durationMs >= requiredMs) {
      _emitPanic(HardwareTriggerPattern.longPress);
    }
  }

  void _emitPanic(HardwareTriggerPattern pattern) {
    if (_panicController.isClosed) return;
    final event = HardwarePanicEvent(
      buttonType: _buttonType,
      pattern: pattern,
      timestamp: DateTime.now().toUtc(),
    );
    _panicController.add(event);
    log('panic event emitted: $event', name: 'HardwareButtonService');
  }

  // ---------------------------------------------------------------------------
  // Pure-Dart helpers for parameter clamping
  // ---------------------------------------------------------------------------

  static int _clampPressCount(int v) =>
      v.clamp(_kMinPressCount, _kMaxPressCount);

  static int _clampPressWindowMs(int v) =>
      v.clamp(_kMinPressWindowMs, _kMaxPressWindowMs);

  static double _clampLongPressDuration(double v) =>
      v.clamp(_kMinLongPressDurationSeconds, _kMaxLongPressDurationSeconds);
}

// ---------------------------------------------------------------------------
// iOS audio handler (spec 05:702-716)
// ---------------------------------------------------------------------------

/// Headphone remote handler for iOS panic detection.
///
/// Overrides all remote commands that iOS emits for a headphone button press
/// and routes each into [onPress] which drives the same repeat-press counting
/// logic used by the Android path.
class _GuardianAudioHandler extends BaseAudioHandler {
  _GuardianAudioHandler({required this.onPress});

  /// Called once per headphone button press.
  final void Function() onPress;

  @override
  Future<void> play() async => onPress();

  @override
  Future<void> pause() async => onPress();

  @override
  Future<void> skipToNext() async => onPress();

  @override
  Future<void> skipToPrevious() async => onPress();

  @override
  Future<void> click([MediaButton? button]) async => onPress();
}
