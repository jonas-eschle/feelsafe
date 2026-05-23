/// The button-press gesture pattern that triggers a panic event.
///
/// See spec 05 §HardwareButtonService §Detection Patterns.
enum HardwareTriggerPattern {
  /// Multiple button presses within a short time window.
  ///
  /// Default: 5 presses in 500 ms. Available on Android and iOS
  /// (headphone remote via `audio_service`).
  repeatPress,

  /// Sustained hold of the button beyond a configurable duration.
  ///
  /// Default: 2 seconds. Available on Android only — iOS media-button
  /// callbacks do not expose ACTION_DOWN/UP timestamps needed for
  /// long-press detection (spec 05 §iOS Implementation, spec 10
  /// §Hardware Buttons).
  longPress,
}
