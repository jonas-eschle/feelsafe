/// Unit tests for `TrackingBuffer` (spec 11 §DE-3).
///
/// Covers capacity eviction, latest, clear, points iteration, and
/// the constructor-time validation of capacity.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/engine/tracking_buffer.dart';
import 'package:guardianangela/domain/models/tracking_point.dart';

TrackingPoint _p(int i) => TrackingPoint(
  timestamp: DateTime.utc(2026, 1, 1).add(Duration(seconds: i)),
  latitude: 47.0 + i * 0.01,
  longitude: 8.0 + i * 0.01,
);

void main() {
  group('TrackingBuffer', () {
    test('default capacity is 50', () {
      final b = TrackingBuffer();
      check(b.capacity).equals(50);
      check(b.isEmpty).isTrue();
      check(b.latest).isNull();
    });

    test('rejects non-positive capacity', () {
      check(() => TrackingBuffer(capacity: 0)).throws<ArgumentError>();
      check(() => TrackingBuffer(capacity: -5)).throws<ArgumentError>();
    });

    test('add appends and updates latest', () {
      final b = TrackingBuffer(capacity: 3);
      b.add(_p(1));
      check(b.length).equals(1);
      check(b.isNotEmpty).isTrue();
      check(b.latest).equals(_p(1));
      b.add(_p(2));
      check(b.latest).equals(_p(2));
      check(b.length).equals(2);
    });

    test('evicts oldest when over capacity', () {
      final b = TrackingBuffer(capacity: 3);
      b.add(_p(1));
      b.add(_p(2));
      b.add(_p(3));
      b.add(_p(4));
      check(b.length).equals(3);
      check(b.latest).equals(_p(4));
      // Oldest (1) evicted; 2,3,4 remain.
      check(b.points.toList()).deepEquals([_p(2), _p(3), _p(4)]);
    });

    test('continues evicting under sustained load', () {
      final b = TrackingBuffer(capacity: 2);
      for (var i = 0; i < 10; i++) {
        b.add(_p(i));
      }
      check(b.length).equals(2);
      check(b.points.toList()).deepEquals([_p(8), _p(9)]);
    });

    test('clear empties the buffer', () {
      final b = TrackingBuffer(capacity: 3);
      b.add(_p(1));
      b.add(_p(2));
      b.clear();
      check(b.isEmpty).isTrue();
      check(b.length).equals(0);
      check(b.latest).isNull();
      check(b.points.toList()).isEmpty();
    });

    test('points iterable is unmodifiable', () {
      final b = TrackingBuffer(capacity: 3);
      b.add(_p(1));
      final view = b.points.toList(growable: false);
      check(view).deepEquals([_p(1)]);
      // Mutating the view doesn't affect the buffer (we toList copied).
      b.add(_p(2));
      check(view).deepEquals([_p(1)]);
      check(b.points.toList()).deepEquals([_p(1), _p(2)]);
    });

    test('add after clear works as fresh buffer', () {
      final b = TrackingBuffer(capacity: 2);
      b.add(_p(1));
      b.add(_p(2));
      b.clear();
      b.add(_p(99));
      check(b.length).equals(1);
      check(b.latest).equals(_p(99));
    });
  });
}
