/// `TrackingBuffer` — a fixed-capacity, FIFO circular buffer of
/// [TrackingPoint]s.
///
/// Pure Dart, no Flutter or persistence. The buffer's lifetime is
/// strictly one session (per spec 11 §DE-3): created at session
/// start, cleared at session end, never written to Hive (pivot 1 —
/// no session restore from disk).
///
/// *Why a hand-rolled buffer instead of a `Queue`?* Lookups for the
/// `latest` point are O(1) on a list-backed deque, and the eviction
/// policy is simpler to audit when written explicitly.
library;

import 'package:guardianangela/domain/models/tracking_point.dart';

/// FIFO circular buffer of tracking samples.
final class TrackingBuffer {
  /// Creates a tracking buffer with [capacity] slots.
  ///
  /// [capacity] — the maximum number of [TrackingPoint]s retained.
  /// Defaults to 50 per spec 11 §DE-3 ("Buffer size slider 10-200,
  /// default 50"). Must be positive — non-positive throws
  /// [ArgumentError].
  TrackingBuffer({this.capacity = 50}) {
    if (capacity <= 0) {
      throw ArgumentError.value(capacity, 'capacity', 'must be positive');
    }
  }

  /// Maximum number of points retained.
  final int capacity;

  final List<TrackingPoint> _points = <TrackingPoint>[];

  /// Read-only iterable of the buffered points, oldest-first.
  Iterable<TrackingPoint> get points => List.unmodifiable(_points);

  /// The most recent point, or null when the buffer is empty.
  TrackingPoint? get latest => _points.isEmpty ? null : _points.last;

  /// Number of points currently buffered.
  int get length => _points.length;

  /// True when the buffer has zero points.
  bool get isEmpty => _points.isEmpty;

  /// True when the buffer has at least one point.
  bool get isNotEmpty => _points.isNotEmpty;

  /// Appends [point], evicting the oldest entry when the buffer is at
  /// [capacity]. The buffer is FIFO: at steady state, the eldest
  /// point is always the one that was added longest ago.
  void add(TrackingPoint point) {
    _points.add(point);
    while (_points.length > capacity) {
      _points.removeAt(0);
    }
  }

  /// Empties the buffer.
  void clear() => _points.clear();
}
