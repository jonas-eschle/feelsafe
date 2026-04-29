/// `LocationResolver` — resolves the `{location}` placeholder for SMS
/// templates per spec 11 §DE-3.
///
/// Resolution order (innermost wins):
///   1. `EventServices.trackingBuffer.latest` if non-null AND
///      non-empty (formats with an age annotation:
///      `https://maps.google.com/?q=lat,lon (±15m, 2 min ago)`).
///   2. `LocationServiceProtocol.getLastLocationUrl()` (existing
///      behavior — most recent live-tracker fix).
///   3. The literal string `"Location unavailable"` when neither
///      source has a fix.
///
/// Pure Dart, no Flutter — sits next to the orchestration layer so
/// strategies can call it without re-deriving the precedence rules.
library;

import 'package:guardianangela/domain/orchestration/event_services.dart';

/// Static helper namespace for the `{location}` placeholder.
final class LocationResolver {
  // No public constructor — purely static API.
  const LocationResolver._();

  /// Resolves `{location}` per the precedence order documented on
  /// the class.
  ///
  /// [now] — wall-clock for the age annotation; defaults to
  /// `DateTime.now()`. Tests pass a fixed clock to make age strings
  /// deterministic.
  ///
  /// [logGpsEnabled] — when `false`, GPS lookup is short-circuited
  /// to `'Location unavailable'` without consulting the buffer or
  /// live service. This is the DE-2 hook: callers that have already
  /// resolved their per-step `logGps` override pass the boolean
  /// through. Defaults to `true` (legacy behaviour). *Why:* the
  /// resolver is the single chokepoint for GPS reads in the
  /// strategy layer; gating here keeps the per-step DE-2 toggle out
  /// of every strategy's body.
  static String resolve(
    EventServices services, {
    DateTime Function()? now,
    bool logGpsEnabled = true,
  }) {
    if (!logGpsEnabled) return 'Location unavailable';
    final clock = now ?? DateTime.now;
    final buffer = services.trackingBuffer;
    if (buffer != null) {
      final latest = buffer.latest;
      if (latest != null) {
        final age = clock().difference(latest.timestamp);
        return '${latest.toMapsUrl()} ${_annotation(latest.accuracy, age)}';
      }
    }
    final live = services.location?.getLastLocationUrl();
    if (live != null) return live;
    return 'Location unavailable';
  }

  /// Builds the `(±15m, 2 min ago)` age annotation. Both fields are
  /// optional — when accuracy is null, only the age is shown; when
  /// the timestamp is in the future (clock skew) the age clamps to
  /// zero.
  static String _annotation(double? accuracyMeters, Duration age) {
    final pieces = <String>[];
    if (accuracyMeters != null) {
      pieces.add('±${accuracyMeters.round()}m');
    }
    pieces.add(_formatAge(age));
    return '(${pieces.join(', ')})';
  }

  static String _formatAge(Duration age) {
    final secs = age.inSeconds;
    if (secs <= 0) return 'just now';
    if (secs < 60) return '$secs sec ago';
    final mins = age.inMinutes;
    if (mins < 60) return '$mins min ago';
    final hours = age.inHours;
    if (hours < 24) return '$hours h ago';
    final days = age.inDays;
    return '$days d ago';
  }
}
