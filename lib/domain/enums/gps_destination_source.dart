/// Source of the destination coordinate for a [GpsArrivalDisarmTrigger].
///
/// See spec 03 §GpsDestinationSource.
enum GpsDestinationSource {
  /// The session-start screen prompts the user for a lat/lng
  /// (with a "use current location" shortcut). Skipping disables
  /// the trigger for that session.
  promptAtStart,

  /// Coordinates are stored on the trigger itself ([lat]/[lng]).
  /// No prompt is shown at session start.
  fixed,
}
