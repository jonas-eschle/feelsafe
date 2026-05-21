/// Per-step GPS-logging override.
///
/// See spec 03 §LogGpsOverride and G-003. Resolves against
/// [AppDefaults.gpsLogging.enabled] (and the matching
/// [ModeOverrides.gpsLogging.enabled] when set).
enum LogGpsOverride {
  /// Inherit the resolved default for the active mode.
  useDefault,

  /// Record GPS for this step regardless of defaults.
  forceOn,

  /// Suppress GPS for this step regardless of defaults.
  forceOff,
}
