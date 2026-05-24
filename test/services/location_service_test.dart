import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/models/location_point.dart';
import 'package:guardianangela/services/protocols/location_service_protocol.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/sim/location_service_sim.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

LocationPoint _point({
  double lat = 0.0,
  double lon = 0.0,
  DateTime? ts,
  double? accuracy,
}) {
  if (accuracy != null) {
    return LocationPoint(
      latitude: lat,
      longitude: lon,
      timestamp: ts ?? DateTime.utc(2026),
      accuracy: accuracy,
    );
  }
  return LocationPoint(
    latitude: lat,
    longitude: lon,
    timestamp: ts ?? DateTime.utc(2026),
  );
}

SimulationLocationService _sim({Iterable<LocationPoint>? points}) =>
    SimulationLocationService(initialPoints: points);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // LocationPoint model
  // =========================================================================

  group('LocationPoint', () {
    group('construction', () {
      test('stores latitude, longitude, timestamp, accuracy', () {
        final ts = DateTime.utc(2026, 5, 1, 12);
        final p = LocationPoint(
          latitude: 48.8566,
          longitude: 2.3522,
          timestamp: ts,
          accuracy: 5.0,
        );
        check(p.latitude).equals(48.8566);
        check(p.longitude).equals(2.3522);
        check(p.timestamp).equals(ts);
        check(p.accuracy).equals(5.0);
      });

      test('accuracy defaults to null', () {
        final p = _point();
        check(p.accuracy).isNull();
      });
    });

    group('toMapsUrl', () {
      test('returns correct google maps url', () {
        final p = _point(lat: 51.5074, lon: -0.1278);
        check(
          p.toMapsUrl(),
        ).equals('https://maps.google.com/?q=51.5074,-0.1278');
      });

      test('handles negative latitude', () {
        final p = _point(lat: -33.8688, lon: 151.2093);
        check(p.toMapsUrl()).startsWith('https://maps.google.com/?q=-33.8688');
      });
    });

    group('toJson / fromJson round-trip', () {
      test('preserves lat/lon/timestamp', () {
        final ts = DateTime.utc(2026, 3, 15, 10, 30);
        final p = LocationPoint(
          latitude: 40.7128,
          longitude: -74.006,
          timestamp: ts,
        );
        final json = p.toJson();
        final restored = LocationPoint.fromJson(json);
        check(restored.latitude).equals(p.latitude);
        check(restored.longitude).equals(p.longitude);
        check(restored.timestamp).equals(ts);
        check(restored.accuracy).isNull();
      });

      test('preserves accuracy when present', () {
        final p = _point(accuracy: 12.5);
        final restored = LocationPoint.fromJson(p.toJson());
        check(restored.accuracy).equals(12.5);
      });

      test('omits accuracy key when null', () {
        final json = _point().toJson();
        check(json.containsKey('accuracy')).isFalse();
      });

      test('fromJson throws when latitude missing', () {
        check(
          () => LocationPoint.fromJson({
            'longitude': 2.0,
            'timestamp': '2026-01-01T00:00:00.000Z',
          }),
        ).throws<ArgumentError>();
      });

      test('fromJson throws when longitude missing', () {
        check(
          () => LocationPoint.fromJson({
            'latitude': 48.0,
            'timestamp': '2026-01-01T00:00:00.000Z',
          }),
        ).throws<ArgumentError>();
      });

      test('fromJson throws when timestamp missing', () {
        check(
          () => LocationPoint.fromJson({'latitude': 48.0, 'longitude': 2.0}),
        ).throws<ArgumentError>();
      });
    });

    group('equality', () {
      test('same values are equal', () {
        final ts = DateTime.utc(2026, 2, 15);
        final a = LocationPoint(
          latitude: 1.0,
          longitude: 2.0,
          timestamp: ts,
          accuracy: 5.0,
        );
        final b = LocationPoint(
          latitude: 1.0,
          longitude: 2.0,
          timestamp: ts,
          accuracy: 5.0,
        );
        check(a).equals(b);
      });

      test('different lat produces not-equal', () {
        final ts = DateTime.utc(2026, 3);
        final a = _point(lat: 1.0, ts: ts);
        final b = _point(lat: 2.0, ts: ts);
        check(a).not((c) => c.equals(b));
      });
    });
  });

  // =========================================================================
  // SimulationLocationService
  // =========================================================================

  group('SimulationLocationService', () {
    group('constructor', () {
      test('implements LocationServiceProtocol', () {
        check(_sim()).isA<LocationServiceProtocol>();
      });

      test('starts with empty history when no initialPoints', () {
        check(_sim().history).isEmpty();
      });

      test('seeds history from initialPoints', () {
        final pts = [_point(lat: 1.0), _point(lat: 2.0)];
        final s = _sim(points: pts);
        check(s.history).length.equals(2);
      });

      test('isTracking is false initially', () {
        check(_sim().isTracking).isFalse();
      });

      test('permissionRequested is false initially', () {
        check(_sim().permissionRequested).isFalse();
      });
    });

    group('requestPermission', () {
      test('marks permissionRequested', () async {
        final s = _sim();
        await s.requestPermission();
        check(s.permissionRequested).isTrue();
      });

      test('returns true by default', () async {
        final s = _sim();
        final result = await s.requestPermission();
        check(result).isTrue();
      });

      test('returns false when simulatedPermissionGranted=false', () async {
        final s = _sim();
        s.simulatedPermissionGranted = false;
        final result = await s.requestPermission();
        check(result).isFalse();
      });
    });

    group('startTracking / stopTracking', () {
      test('startTracking sets isTracking true', () async {
        final s = _sim();
        await s.startTracking();
        check(s.isTracking).isTrue();
      });

      test('stopTracking sets isTracking false', () async {
        final s = _sim();
        await s.startTracking();
        s.stopTracking();
        check(s.isTracking).isFalse();
      });

      test('custom interval is accepted', () async {
        final s = _sim();
        await s.startTracking(interval: const Duration(seconds: 60));
        check(s.isTracking).isTrue();
      });
    });

    group('getLastLocationUrl', () {
      test('returns null when history is empty', () {
        check(_sim().getLastLocationUrl()).isNull();
      });

      test('returns maps url for last point', () {
        final s = _sim(points: [_point(lat: 51.5, lon: -0.1)]);
        check(
          s.getLastLocationUrl(),
        ).equals('https://maps.google.com/?q=51.5,-0.1');
      });

      test('returns url for LAST point when multiple exist', () {
        final s = _sim(
          points: [_point(lat: 1.0, lon: 1.0), _point(lat: 99.0, lon: 99.0)],
        );
        check(s.getLastLocationUrl()!).contains('99.0,99.0');
      });
    });

    group('getLastLocationPoint', () {
      test('returns null when empty', () {
        check(_sim().getLastLocationPoint()).isNull();
      });

      test('returns last point', () {
        final last = _point(lat: 10.0);
        final s = _sim(points: [_point(lat: 5.0), last]);
        check(s.getLastLocationPoint()).equals(last);
      });
    });

    group('getLastLocationWithFallback', () {
      test('returns null when empty', () async {
        check(await _sim().getLastLocationWithFallback()).isNull();
      });

      test('returns fresh result by default', () async {
        final pt = _point(lat: 20.0);
        final s = _sim(points: [pt]);
        final result = await s.getLastLocationWithFallback();
        check(result).isNotNull();
        check(result!.point).equals(pt);
        check(result.isFresh).isTrue();
      });

      test('returns stale result when simulatedFreshFix=false', () async {
        final pt = _point(lat: 20.0);
        final s = _sim(points: [pt]);
        s.simulatedFreshFix = false;
        final result = await s.getLastLocationWithFallback();
        check(result).isNotNull();
        check(result!.point).equals(pt);
        check(result.isFresh).isFalse();
        check(result.staleNote).isNotNull();
      });
    });

    group('getLastLocationDescription', () {
      test('returns null when empty', () {
        check(_sim().getLastLocationDescription()).isNull();
      });

      test('contains maps url', () {
        final s = _sim(points: [_point(lat: 48.0, lon: 2.0)]);
        check(
          s.getLastLocationDescription()!,
        ).contains('https://maps.google.com/?q=48.0,2.0');
      });

      test('contains timestamp', () {
        final ts = DateTime.utc(2026, 6, 3, 8);
        final s = _sim(points: [_point(ts: ts)]);
        check(s.getLastLocationDescription()!).contains('2026-06-03');
      });

      test('contains accuracy when present', () {
        final s = _sim(points: [_point(accuracy: 7.0)]);
        check(s.getLastLocationDescription()!).contains('accuracy=7m');
      });

      test('omits accuracy when null', () {
        final s = _sim(points: [_point()]);
        check(
          s.getLastLocationDescription()!,
        ).not((c) => c.contains('accuracy'));
      });
    });

    group('history', () {
      test('returns unmodifiable list', () {
        final s = _sim(points: [_point()]);
        check(() => (s.history as dynamic).add(_point())).throws<Error>();
      });

      test('injectPoint appends to history', () {
        final s = _sim();
        s.injectPoint(_point(lat: 55.0));
        check(s.history).length.equals(1);
        check(s.history.first.latitude).equals(55.0);
      });

      test('multiple injects accumulate', () {
        final s = _sim();
        s.injectPoint(_point(lat: 1.0));
        s.injectPoint(_point(lat: 2.0));
        check(s.history).length.equals(2);
      });
    });

    group('clearHistory', () {
      test('empties history', () {
        final s = _sim(points: [_point(), _point()]);
        s.clearHistory();
        check(s.history).isEmpty();
      });

      test('getLastLocationUrl returns null after clear', () {
        final s = _sim(points: [_point()]);
        s.clearHistory();
        check(s.getLastLocationUrl()).isNull();
      });
    });
  });

  // =========================================================================
  // F4: bounded history (1001 points drops oldest) + stale-note path
  // =========================================================================

  group('SimulationLocationService — bounded history (F4)', () {
    test('history bounded at 1000: 1001st inject discards oldest', () {
      final s = _sim();
      // Inject 1000 points starting at lat=0.0.
      for (var i = 0; i < 1000; i++) {
        s.injectPoint(_point(lat: i.toDouble()));
      }
      check(s.history).length.equals(1000);
      check(s.history.first.latitude).equals(0.0);

      // Inject the 1001st point.
      s.injectPoint(_point(lat: 1000.0));
      // Oldest (lat=0.0) must have been discarded.
      check(s.history).length.equals(1000);
      check(s.history.first.latitude).equals(1.0);
      check(s.history.last.latitude).equals(1000.0);
    });

    test('history bounded at 1000: 1002nd inject discards 2 oldest', () {
      final s = _sim();
      for (var i = 0; i < 1002; i++) {
        s.injectPoint(_point(lat: i.toDouble()));
      }
      check(s.history).length.equals(1000);
      check(s.history.first.latitude).equals(2.0);
    });
  });

  group('SimulationLocationService — requestPermission denial path (F4)', () {
    test(
      'denial path: simulatedPermissionGranted=false returns false',
      () async {
        final s = _sim();
        s.simulatedPermissionGranted = false;
        check(await s.requestPermission()).isFalse();
      },
    );

    test('default: requestPermission returns true', () async {
      final s = _sim();
      check(await s.requestPermission()).isTrue();
    });

    test('requestPermission sets permissionRequested=true on denial', () async {
      final s = _sim();
      s.simulatedPermissionGranted = false;
      await s.requestPermission();
      check(s.permissionRequested).isTrue();
    });
  });

  group(
    'SimulationLocationService — getLastLocationWithFallback stale (F4)',
    () {
      test(
        'stale-note path: staleNote is non-null and contains timestamp',
        () async {
          final ts = DateTime.utc(2026, 4, 10, 8, 30);
          final pt = _point(lat: 30.0, ts: ts);
          final s = _sim(points: [pt]);
          s.simulatedFreshFix = false;
          final result = await s.getLastLocationWithFallback();
          check(result).isNotNull();
          check(result!.isFresh).isFalse();
          check(result.staleNote).isNotNull();
          check(result.staleNote!).contains('2026-04-10');
        },
      );

      test('stale-note point is the last known point', () async {
        final pt = _point(lat: 42.0);
        final s = _sim(points: [pt]);
        s.simulatedFreshFix = false;
        final result = await s.getLastLocationWithFallback();
        check(result!.point).equals(pt);
      });

      test(
        'fresh path: staleNote is null when simulatedFreshFix=true',
        () async {
          final pt = _point(lat: 15.0);
          final s = _sim(points: [pt]);
          final result = await s.getLastLocationWithFallback();
          check(result).isNotNull();
          check(result!.isFresh).isTrue();
          check(result.staleNote).isNull();
        },
      );

      test('null when empty, regardless of simulatedFreshFix', () async {
        final s = _sim();
        s.simulatedFreshFix = false;
        check(await s.getLastLocationWithFallback()).isNull();
      });
    },
  );

  // =========================================================================
  // Simulation swap (Riverpod)
  // =========================================================================

  group('Simulation swap — LocationService', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          locationServiceProvider.overrideWithValue(
            SimulationLocationService(),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('overridden container returns SimulationLocationService', () {
      final s = container.read(locationServiceProvider);
      check(s).isA<SimulationLocationService>();
    });

    test('SimulationLocationService is not RealLocationService', () {
      final s = container.read(locationServiceProvider);
      check(
        s.runtimeType.toString(),
      ).not((c) => c.equals('RealLocationService'));
    });
  });
}
