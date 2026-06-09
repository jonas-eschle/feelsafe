// Host tests for the production [RealLocationService] (C6 coverage push).
//
// RealLocationService is backed by `package:geolocator` (cross-platform
// MethodChannel `flutter.baseflow.com/geolocator` + the `geolocator_updates`
// EventChannel). The simulation counterpart (location_service_test.dart)
// covers the in-memory history model; this file drives the REAL geolocator
// channel through TestDefaultBinaryMessenger so the genuine logic runs:
//   * requestPermission across the service-disabled / denied / deniedForever /
//     granted / throwing branches,
//   * getLastLocationWithFallback fresh-fix vs cached-fallback vs no-data,
//   * the stale-note ISO-8601 formatting + getLastLocationDescription,
//   * startTracking initial fix + ongoing stream → bounded history eviction at
//     1000 points.

import 'package:flutter/services.dart';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/services/location_service.dart';
import 'package:guardianangela/services/protocols/location_service_protocol.dart';

// ---------------------------------------------------------------------------
// Geolocator channel harness
// ---------------------------------------------------------------------------

const String _kMethodChannel = 'flutter.baseflow.com/geolocator';
const String _kUpdatesChannel = 'flutter.baseflow.com/geolocator_updates';

/// Builds a geolocator position map as the native side would return it.
Map<String, dynamic> _posMap({
  required double lat,
  required double lng,
  int? timestampMs,
  double accuracy = 5.0,
}) => <String, dynamic>{
  'latitude': lat,
  'longitude': lng,
  'timestamp':
      timestampMs ?? DateTime.utc(2026, 5, 1, 12).millisecondsSinceEpoch,
  'accuracy': accuracy,
  'altitude': 0.0,
  'altitude_accuracy': 0.0,
  'heading': 0.0,
  'heading_accuracy': 0.0,
  'speed': 0.0,
  'speed_accuracy': 0.0,
  'is_mocked': false,
};

/// Mocks the geolocator MethodChannel (permission / service / current-position)
/// and the position-updates EventChannel.
class _GeolocatorMock {
  bool serviceEnabled = true;

  /// `LocationPermission` enum index: 0 denied, 1 deniedForever, 2 whileInUse,
  /// 3 always.
  int checkPermissionResult = 3;
  int requestPermissionResult = 3;

  /// When non-null, `getCurrentPosition` returns this map; when null it throws
  /// a PlatformException so the fallback path runs.
  Map<String, dynamic>? currentPosition;

  bool throwOnCheckPermission = false;

  MockStreamHandlerEventSink? _updatesSink;

  void register() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel(_kMethodChannel), (
          call,
        ) async {
          switch (call.method) {
            case 'isLocationServiceEnabled':
              return serviceEnabled;
            case 'checkPermission':
              if (throwOnCheckPermission) {
                throw PlatformException(
                  code: 'PERMISSION_DEFINITIONS_NOT_FOUND',
                );
              }
              return checkPermissionResult;
            case 'requestPermission':
              return requestPermissionResult;
            case 'getCurrentPosition':
              final pos = currentPosition;
              if (pos == null) {
                throw PlatformException(code: 'LOCATION_UNAVAILABLE');
              }
              return pos;
            default:
              return null;
          }
        });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(
          const EventChannel(_kUpdatesChannel),
          MockStreamHandler.inline(
            onListen: (args, sink) => _updatesSink = sink,
            onCancel: (args) => _updatesSink = null,
          ),
        );
  }

  void unregister() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel(_kMethodChannel), null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(const EventChannel(_kUpdatesChannel), null);
  }

  /// Pushes one position update onto the geolocator updates stream.
  void pushUpdate(Map<String, dynamic> position) {
    _updatesSink?.success(position);
  }

  /// Pushes a platform error onto the position-updates stream (→ onError).
  void pushError() {
    _updatesSink?.error(code: 'STREAM_ERR', message: 'gps lost');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _GeolocatorMock geo;
  late RealLocationService svc;

  setUp(() {
    geo = _GeolocatorMock()..register();
    svc = RealLocationService();
  });

  tearDown(() {
    svc.stopTracking();
    geo.unregister();
  });

  group('RealLocationService — empty state', () {
    test('implements LocationServiceProtocol', () {
      check(svc).isA<LocationServiceProtocol>();
    });

    test('getLastLocationUrl is null with no history', () {
      check(svc.getLastLocationUrl()).isNull();
    });

    test('getLastLocationDescription is null with no history', () {
      check(svc.getLastLocationDescription()).isNull();
    });

    test('getLastLocationPoint is null with no history', () {
      check(svc.getLastLocationPoint()).isNull();
    });

    test('history is empty initially', () {
      check(svc.history).isEmpty();
    });

    test(
      'getLastLocationWithFallback returns null when no fix + no cache',
      () async {
        geo.currentPosition =
            null; // fresh fix fails → fallback to (empty) cache
        final result = await svc.getLastLocationWithFallback();
        check(result).isNull();
      },
    );
  });

  group('RealLocationService — requestPermission', () {
    test('returns false when location services are disabled', () async {
      geo.serviceEnabled = false;
      check(await svc.requestPermission()).isFalse();
    });

    test('returns true when permission is already granted (always)', () async {
      geo.checkPermissionResult = 3; // always
      check(await svc.requestPermission()).isTrue();
    });

    test('returns true when permission is whileInUse', () async {
      geo.checkPermissionResult = 2; // whileInUse
      check(await svc.requestPermission()).isTrue();
    });

    test(
      'prompts and returns true when initially denied then granted',
      () async {
        geo.checkPermissionResult = 0; // denied
        geo.requestPermissionResult = 2; // user grants whileInUse
        check(await svc.requestPermission()).isTrue();
      },
    );

    test('returns false when the request is denied', () async {
      geo.checkPermissionResult = 0; // denied
      geo.requestPermissionResult = 0; // still denied after prompt
      check(await svc.requestPermission()).isFalse();
    });

    test('returns false when permission is deniedForever', () async {
      geo.checkPermissionResult = 1; // deniedForever — never prompts
      check(await svc.requestPermission()).isFalse();
    });

    test('returns false (never throws) when the platform throws', () async {
      geo.throwOnCheckPermission = true;
      check(await svc.requestPermission()).isFalse();
    });
  });

  group('RealLocationService — getLastLocationWithFallback', () {
    test(
      'returns a fresh result (no stale note) on a successful fix',
      () async {
        geo.currentPosition = _posMap(lat: 48.8566, lng: 2.3522);
        final result = await svc.getLastLocationWithFallback();

        check(result).isNotNull();
        check(result!.isFresh).isTrue();
        check(result.staleNote).isNull();
        check(result.point.latitude).equals(48.8566);
        // The fresh fix is also appended to history.
        check(svc.history).length.equals(1);
      },
    );

    test('drops accuracy when the native fix reports accuracy <= 0', () async {
      geo.currentPosition = _posMap(lat: 1.0, lng: 2.0, accuracy: 0.0);
      final result = await svc.getLastLocationWithFallback();
      check(result!.point.accuracy).isNull();
    });

    test(
      'falls back to the cached point with a stale note on fix failure',
      () async {
        // First, a successful fix populates the cache.
        geo.currentPosition = _posMap(
          lat: 10.0,
          lng: 20.0,
          timestampMs: DateTime.utc(2026, 3, 2, 9, 30).millisecondsSinceEpoch,
        );
        await svc.getLastLocationWithFallback();

        // Now the fresh fix fails → cached point + stale note.
        geo.currentPosition = null;
        final result = await svc.getLastLocationWithFallback();

        check(result).isNotNull();
        check(result!.isFresh).isFalse();
        check(result.staleNote).isNotNull();
        // The note carries the cached point's ISO-8601 UTC timestamp.
        check(
          result.staleNote!,
        ).startsWith('Last known location at 2026-03-02T09:30:00.000Z');
        check(result.point.latitude).equals(10.0);
      },
    );
  });

  group('RealLocationService — description / url formatting', () {
    test('getLastLocationUrl returns the maps URL of the last fix', () async {
      geo.currentPosition = _posMap(lat: 1.5, lng: -2.5);
      await svc.getLastLocationWithFallback();
      check(
        svc.getLastLocationUrl(),
      ).equals('https://maps.google.com/?q=1.5,-2.5');
    });

    test(
      'getLastLocationDescription includes timestamp, accuracy and url',
      () async {
        geo.currentPosition = _posMap(
          lat: 3.0,
          lng: 4.0,
          timestampMs: DateTime.utc(2026, 1, 5, 8).millisecondsSinceEpoch,
          accuracy: 12.7,
        );
        await svc.getLastLocationWithFallback();

        final desc = svc.getLastLocationDescription()!;
        check(
          desc,
        ).startsWith('Last known location at 2026-01-05T08:00:00.000Z');
        check(desc).contains('accuracy=13m'); // 12.7 → toStringAsFixed(0)
        check(desc).contains('https://maps.google.com/?q=3.0,4.0');
      },
    );

    test(
      'getLastLocationDescription omits accuracy when unavailable',
      () async {
        geo.currentPosition = _posMap(lat: 5.0, lng: 6.0, accuracy: 0.0);
        await svc.getLastLocationWithFallback();
        final desc = svc.getLastLocationDescription()!;
        check(desc).not((c) => c.contains('accuracy='));
      },
    );
  });

  group('RealLocationService — tracking + history', () {
    test('startTracking captures an initial fix immediately', () async {
      geo.currentPosition = _posMap(lat: 7.0, lng: 8.0);
      await svc.startTracking();
      check(svc.history).length.equals(1);
      check(svc.getLastLocationPoint()!.latitude).equals(7.0);
    });

    test('startTracking tolerates an initial-fix failure', () async {
      geo.currentPosition = null; // initial getCurrentPosition throws
      await svc.startTracking();
      // No initial point, but the subscription is live and no exception leaks.
      check(svc.history).isEmpty();
    });

    test('a second startTracking while tracking is a no-op', () async {
      geo.currentPosition = _posMap(lat: 7.0, lng: 8.0);
      await svc.startTracking();
      check(svc.history).length.equals(1);
      await svc.startTracking(); // guarded: already tracking → returns early
      check(svc.history).length.equals(1);
    });

    test('stream updates append to history', () async {
      geo.currentPosition = null; // skip the initial fix
      await svc.startTracking();

      geo.pushUpdate(_posMap(lat: 1.0, lng: 1.0));
      geo.pushUpdate(_posMap(lat: 2.0, lng: 2.0));
      await Future<void>.delayed(Duration.zero);

      check(svc.history).length.equals(2);
      check(svc.getLastLocationPoint()!.latitude).equals(2.0);
    });

    test(
      'a position-stream error is absorbed (logged, not rethrown)',
      () async {
        geo.currentPosition = null; // skip the initial fix
        await svc.startTracking();

        // The stream onError handler logs and swallows; a subsequent valid
        // update must still append (the subscription survives the error).
        geo.pushError();
        await Future<void>.delayed(Duration.zero);
        geo.pushUpdate(_posMap(lat: 9.0, lng: 9.0));
        await Future<void>.delayed(Duration.zero);

        check(svc.history).length.equals(1);
        check(svc.getLastLocationPoint()!.latitude).equals(9.0);
      },
    );

    test('clearHistory wipes the recorded points', () async {
      geo.currentPosition = _posMap(lat: 7.0, lng: 8.0);
      await svc.startTracking();
      check(svc.history).isNotEmpty();
      svc.clearHistory();
      check(svc.history).isEmpty();
    });

    test('history is bounded at 1000 — oldest is evicted (FIFO)', () async {
      geo.currentPosition = null; // skip the initial fix
      await svc.startTracking();

      // Push 1001 updates with monotonically increasing latitude so we can
      // verify which one survived the eviction.
      for (var i = 0; i < 1001; i++) {
        geo.pushUpdate(_posMap(lat: i.toDouble(), lng: 0.0));
      }
      await Future<void>.delayed(Duration.zero);

      // Capped at 1000; the very first (lat 0.0) was dropped.
      check(svc.history).length.equals(1000);
      check(svc.history.first.latitude).equals(1.0);
      check(svc.history.last.latitude).equals(1000.0);
    });

    test('history exposes an unmodifiable view', () async {
      geo.currentPosition = _posMap(lat: 7.0, lng: 8.0);
      await svc.startTracking();
      check(() => (svc.history as dynamic).clear()).throws<Error>();
    });

    test('stopTracking is safe to call when not tracking', () {
      svc.stopTracking(); // no subscription yet
      check(svc.history).isEmpty();
    });
  });
}
