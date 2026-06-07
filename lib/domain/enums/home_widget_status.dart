/// Status values surfaced on the home-screen widget.
///
/// The widget shows status text and button labels resolved by Dart (so the
/// native widget receives already-localised strings and needs no l10n logic
/// of its own). Spec 04 §Home Screen Widget.
enum HomeWidgetStatus {
  /// No session is running.
  idle,

  /// A real safety session is active (timer shown on widget).
  sessionActive,

  /// A simulation session is active (timer shown on widget).
  simulationActive,
}
