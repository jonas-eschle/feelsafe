/// Sound choice for a [loudAlarm] step.
///
/// See spec 03 §LoudAlarmSound and Q9. Reduced to two values per spec
/// audit; legacy values are nuked-and-reseeded under the pre-alpha policy.
enum LoudAlarmSound {
  /// The built-in siren sound.
  siren,

  /// A user-supplied custom audio file.
  custom,
}
