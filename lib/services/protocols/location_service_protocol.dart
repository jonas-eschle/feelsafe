/// Abstract interface for GPS location data used by event strategies.
///
/// Phase 5 supplies the concrete implementation. Only the methods that
/// strategies call are declared here.
abstract interface class LocationServiceProtocol {
  /// Returns a Google Maps URL for the last known location.
  ///
  /// Format: `https://maps.google.com/?q=lat,lng`. Returns `null` if no
  /// current GPS fix is available. Used for the `{location}` placeholder
  /// in message templates (spec 02 §smsContact §Placeholders).
  String? getLastLocationUrl();

  /// Returns a human-readable fallback description when only stale location
  /// data is available.
  ///
  /// Format: `'Last known location at {timestamp}: {url}'` with accuracy
  /// info if available. Returns `null` if no location data at all is
  /// available. Used as a secondary fallback after [getLastLocationUrl]
  /// (spec 02 §smsContact §Placeholders "If only stale location").
  String? getLastLocationDescription();
}
