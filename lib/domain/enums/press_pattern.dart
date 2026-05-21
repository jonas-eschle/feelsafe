/// The physical press pattern for a hardware-button trigger.
///
/// Both patterns ship at v3 GA per D15 and spec 03 §DistressTrigger.
/// The pattern-irrelevant field (`pressCount` for [longPress],
/// `durationSeconds` for [repeatPress]) MUST be left at its default;
/// save-time validation rejects non-default values for clarity.
enum PressPattern {
  /// Rapid successive presses within a configured window.
  repeatPress,

  /// A single sustained hold for a configured duration.
  longPress,
}
