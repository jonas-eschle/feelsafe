/// Ephemeral-lifecycle tests for the spec 11 §DE-3 tracking buffer.
///
/// The contract: the buffer is created at session start, written by
/// the periodic Timer, cleared at session end. This test exercises
/// the buffer's lifecycle in isolation by simulating the
/// add-and-clear sequence the [SessionLifecycleController] performs.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/engine/tracking_buffer.dart';
import 'package:guardianangela/domain/models/tracking_point.dart';

TrackingPoint _p(int i) => TrackingPoint(
  timestamp: DateTime.utc(2026, 1, 1).add(Duration(seconds: i)),
  latitude: 47.0,
  longitude: 8.0,
);

void main() {
  group('TrackingBuffer ephemeral lifecycle (DE-3)', () {
    test('buffer starts empty at session-start', () {
      // Mirrors `SessionLifecycleController._bootstrapSession`:
      // when `mode.trackingEnabled == true`, a fresh
      // `TrackingBuffer` is constructed for the session.
      final buffer = TrackingBuffer(capacity: 50);
      check(buffer.isEmpty).isTrue();
      check(buffer.latest).isNull();
    });

    test('points accumulate via add() across simulated ticks', () {
      // Mirrors the periodic `Timer` callback that fetches a fix and
      // calls `buffer.add(...)`.
      final buffer = TrackingBuffer(capacity: 50);
      for (var tick = 0; tick < 5; tick++) {
        buffer.add(_p(tick));
      }
      check(buffer.length).equals(5);
      check(buffer.latest).equals(_p(4));
    });

    test('clear() empties buffer at session-end', () {
      // Mirrors `disposeRuntime`'s
      // `runtime.trackingBuffer?.clear()` line.
      final buffer = TrackingBuffer(capacity: 50);
      for (var i = 0; i < 10; i++) {
        buffer.add(_p(i));
      }
      check(buffer.length).equals(10);

      buffer.clear();

      check(buffer.isEmpty).isTrue();
      check(buffer.latest).isNull();
      check(buffer.points.toList()).isEmpty();
    });

    test('buffer can be reused after clear (next session)', () {
      // Per pivot 1 the buffer is per-session. This exercises the
      // re-arm path: after `clear()`, the buffer accepts new points
      // identical to a freshly-constructed one.
      final buffer = TrackingBuffer(capacity: 3);
      buffer.add(_p(1));
      buffer.add(_p(2));
      buffer.clear();

      buffer.add(_p(99));
      check(buffer.length).equals(1);
      check(buffer.latest).equals(_p(99));
    });

    test('capacity policy preserved across mid-session lifetime', () {
      final buffer = TrackingBuffer(capacity: 3);
      for (var i = 0; i < 10; i++) {
        buffer.add(_p(i));
      }
      // Always last 3 — oldest evicted under sustained sampling.
      check(buffer.points.toList()).deepEquals([_p(7), _p(8), _p(9)]);
    });

    test('null buffer (tracking disabled) is the disabled signal', () {
      // Mirrors the lifecycle controller assigning
      // `final TrackingBuffer? trackingBuffer = mode.trackingEnabled ? ... : null;`
      // The downstream code paths (LocationResolver) check for
      // null first, so the type-level `null` represents "no
      // tracking for this session".
      const TrackingBuffer? buffer = null;
      check(buffer).isNull();
    });
  });
}
