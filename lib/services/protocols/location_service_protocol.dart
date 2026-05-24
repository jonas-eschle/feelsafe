import 'package:guardianangela/domain/models/location_point.dart';

/// Wrapper returned by [LocationServiceProtocol.getLastLocationWithFallback].
///
/// When [staleNote] is non-null, the returned point is stale (fresh fix
/// unavailable) and [staleNote] contains a human-readable timestamp message
/// to append to the message body.
final class LocationFallbackResult {
  /// Creates a [LocationFallbackResult].
  const LocationFallbackResult({required this.point, this.staleNote});

  /// The best available location point (current or cached).
  final LocationPoint point;

  /// Non-null when the point is stale; contains "Last known location at
  /// {ISO-8601}" to be appended to the message body per spec 05:417-419.
  final String? staleNote;

  /// Whether this result is from the live fix (`staleNote == null`).
  bool get isFresh => staleNote == null;
}

/// Abstract interface for GPS location data used by event strategies and
/// the session controller.
///
/// Phase 5 supplies the concrete implementation. All strategy-facing and
/// controller-facing methods are declared here so the protocol is the
/// full contact surface (spec 05:374-385).
abstract interface class LocationServiceProtocol {
  /// Checks and requests location permission.
  ///
  /// Returns `true` if permission is granted or was already granted. Returns
  /// `false` on denial or when location services are disabled. Never throws.
  Future<bool> requestPermission();

  /// Starts polling GPS location at [interval] (default 30 s).
  ///
  /// Uses [LocationAccuracy.high] and a 10-metre distance filter.
  Future<void> startTracking({Duration interval});

  /// Cancels the location stream subscription.
  void stopTracking();

  /// Returns the last known [LocationPoint], or `null` if unavailable.
  LocationPoint? getLastLocationPoint();

  /// Returns the last known location with a freshness indicator.
  ///
  /// Attempts a fresh GPS fix with a short timeout. On success, returns a
  /// [LocationFallbackResult] with `staleNote == null`. On timeout or failure
  /// falls back to the cached point and attaches a stale note per spec
  /// 05:417-419.
  ///
  /// Returns `null` only when no cached point exists either.
  Future<LocationFallbackResult?> getLastLocationWithFallback();

  /// Unmodifiable list of all tracked positions during this session.
  ///
  /// Bounded at 1000 points; oldest are discarded (spec 05:433).
  List<LocationPoint> get history;

  /// Wipes all logged positions.
  void clearHistory();

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
