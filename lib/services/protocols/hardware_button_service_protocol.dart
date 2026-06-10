import 'package:guardianangela/domain/enums/hardware_button_type.dart';
import 'package:guardianangela/domain/enums/hardware_trigger_pattern.dart';
import 'package:guardianangela/domain/models/hardware_panic_event.dart';

/// Abstract interface for hardware-button panic detection.
///
/// See spec 05 §HardwareButtonService. The concrete implementation
/// covers Android (volume keys via `dispatchKeyEvent`) and iOS
/// (headphone remote via `audio_service` `BaseAudioHandler`).
///
/// The service is started/stopped per-session; the provider is
/// constructed once at app start but begins listening only on `start()`.
abstract interface class HardwareButtonServiceProtocol {
  /// Broadcast stream of panic events.
  ///
  /// Emits a [HardwarePanicEvent] each time the configured press
  /// pattern is satisfied. Multiple listeners may subscribe.
  Stream<HardwarePanicEvent> get panicEvents;

  /// Whether the service is currently intercepting button events.
  bool get isListening;

  /// Starts listening for the configured panic pattern.
  ///
  /// [buttonType] defaults to [HardwareButtonType.volumeUp].
  /// [pattern] defaults to [HardwareTriggerPattern.repeatPress].
  /// [pressCount] is the number of presses required for
  /// [HardwareTriggerPattern.repeatPress] (valid range 2–10;
  /// defaults to 5).
  /// [pressWindowMs] is the detection window in milliseconds for
  /// repeat-press (valid range 200–2000; defaults to 500).
  /// [longPressDurationSeconds] is the hold duration in seconds for
  /// [HardwareTriggerPattern.longPress] (valid range 1–10;
  /// defaults to 2.0).
  void start({
    HardwareButtonType? buttonType,
    HardwareTriggerPattern? pattern,
    int? pressCount,
    int? pressWindowMs,
    double? longPressDurationSeconds,
  });

  /// Stops intercepting button events.
  ///
  /// No-op if not listening.
  void stop();

  /// Updates the detection configuration without restarting.
  ///
  /// Parameters are the same as [start]; null values leave the
  /// current configuration unchanged.
  void updateConfig({
    HardwareButtonType? buttonType,
    HardwareTriggerPattern? pattern,
    int? pressCount,
    int? pressWindowMs,
    double? longPressDurationSeconds,
  });

  /// Releases resources and closes the event stream.
  ///
  /// Must be called when the service is no longer needed (e.g., at
  /// app disposal). After [dispose], no further events are emitted.
  void dispose();
}
