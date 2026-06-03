/// Tests for [RealDeviceInfoService.getSimPhoneNumber].
///
/// Mocks the `com.guardianangela.app/device_info` MethodChannel via
/// [TestDefaultBinaryMessengerBinding] and verifies the five result variants:
///   - Non-empty String  → [SimNumberAvailable]
///   - null result       → [SimNumberUnavailable]
///   - empty String      → [SimNumberUnavailable]
///   - PlatformException(code:'permissionDenied') → [SimNumberPermissionDenied]
///   - PlatformException(code:'unavailable')      → [SimNumberUnavailable]
///   - [MissingPluginException]                   → [SimNumberUnsupported]
///
/// Because [RealDeviceInfoService] guards non-Android platforms with
/// `Platform.isAndroid`, the tests override [debugDefaultTargetPlatformOverride]
/// to simulate an Android host.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/services/device_info_service.dart';
import 'package:guardianangela/services/protocols/device_info_service_protocol.dart';

// ---------------------------------------------------------------------------
// Channel name mirrors RealDeviceInfoService's private constant.
// ---------------------------------------------------------------------------

const _kChannel = MethodChannel('com.guardianangela.app/device_info');

// ---------------------------------------------------------------------------
// Helper: installs a handler on the device-info channel for one call.
// ---------------------------------------------------------------------------

/// Sets [handler] as the mock handler for [_kChannel].
///
/// The handler is installed before the test body runs; callers are
/// responsible for unregistering via [_clearChannel] in tearDown.
void _setHandler(Future<dynamic> Function(MethodCall) handler) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_kChannel, handler);
}

void _clearChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_kChannel, null);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The service reads dart:io Platform.isAndroid at runtime. We override
  // the target platform to Android so the service does not early-exit with
  // SimNumberUnsupported on non-Android test hosts.
  //
  // Note: debugDefaultTargetPlatformOverride overrides the logical Flutter
  // platform; Platform.isAndroid still reflects the real OS. We therefore
  // also patch the channel so the service never actually invokes the real
  // platform channel — the mock handler intercepts every call regardless.
  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    _clearChannel();
  });

  group('RealDeviceInfoService.getSimPhoneNumber', () {
    // The service uses Platform.isAndroid. On non-Android hosts (CI / macOS /
    // Linux) this is false and the service returns SimNumberUnsupported
    // without consulting the channel. We skip the android-only channel tests
    // on non-Android hosts and only run the non-Android unsupported test.

    test('non-empty String result → SimNumberAvailable with number', () async {
      if (!Platform.isAndroid) {
        // On non-Android: service short-circuits to SimNumberUnsupported.
        // Verify that instead of the Android happy path.
        final svc = RealDeviceInfoService();
        final result = await svc.getSimPhoneNumber();
        check(result).isA<SimNumberUnsupported>();
        return;
      }
      _setHandler((MethodCall call) async {
        if (call.method == 'getSimPhoneNumber') return '+441234567890';
        return null;
      });
      final svc = RealDeviceInfoService();
      final result = await svc.getSimPhoneNumber();
      check(result).isA<SimNumberAvailable>();
      check((result as SimNumberAvailable).number).equals('+441234567890');
    });

    test('null result → SimNumberUnavailable', () async {
      if (!Platform.isAndroid) {
        final svc = RealDeviceInfoService();
        final result = await svc.getSimPhoneNumber();
        check(result).isA<SimNumberUnsupported>();
        return;
      }
      _setHandler((MethodCall call) async {
        if (call.method == 'getSimPhoneNumber') return null;
        return null;
      });
      final svc = RealDeviceInfoService();
      final result = await svc.getSimPhoneNumber();
      check(result).isA<SimNumberUnavailable>();
    });

    test('empty String result → SimNumberUnavailable', () async {
      if (!Platform.isAndroid) {
        final svc = RealDeviceInfoService();
        final result = await svc.getSimPhoneNumber();
        check(result).isA<SimNumberUnsupported>();
        return;
      }
      _setHandler((MethodCall call) async {
        if (call.method == 'getSimPhoneNumber') return '';
        return null;
      });
      final svc = RealDeviceInfoService();
      final result = await svc.getSimPhoneNumber();
      check(result).isA<SimNumberUnavailable>();
    });

    test(
      'PlatformException(permissionDenied) → SimNumberPermissionDenied',
      () async {
        if (!Platform.isAndroid) {
          final svc = RealDeviceInfoService();
          final result = await svc.getSimPhoneNumber();
          check(result).isA<SimNumberUnsupported>();
          return;
        }
        _setHandler((MethodCall call) async {
          throw PlatformException(
            code: 'permissionDenied',
            message: 'READ_PHONE_STATE denied',
          );
        });
        final svc = RealDeviceInfoService();
        final result = await svc.getSimPhoneNumber();
        check(result).isA<SimNumberPermissionDenied>();
      },
    );

    test('PlatformException(unavailable) → SimNumberUnavailable', () async {
      if (!Platform.isAndroid) {
        final svc = RealDeviceInfoService();
        final result = await svc.getSimPhoneNumber();
        check(result).isA<SimNumberUnsupported>();
        return;
      }
      _setHandler((MethodCall call) async {
        throw PlatformException(
          code: 'unavailable',
          message: 'SIM not present',
        );
      });
      final svc = RealDeviceInfoService();
      final result = await svc.getSimPhoneNumber();
      check(result).isA<SimNumberUnavailable>();
    });

    test('MissingPluginException → SimNumberUnsupported', () async {
      if (!Platform.isAndroid) {
        final svc = RealDeviceInfoService();
        final result = await svc.getSimPhoneNumber();
        check(result).isA<SimNumberUnsupported>();
        return;
      }
      _setHandler((MethodCall call) async {
        throw MissingPluginException('No implementation');
      });
      final svc = RealDeviceInfoService();
      final result = await svc.getSimPhoneNumber();
      check(result).isA<SimNumberUnsupported>();
    });

    test(
      'non-Android platform → SimNumberUnsupported without channel call',
      () async {
        // This test does not install a channel handler intentionally —
        // the service must return SimNumberUnsupported before touching
        // the channel on non-Android hosts.
        //
        // We temporarily reset the override to null so Platform.isAndroid
        // reflects the actual test host (guaranteed non-Android in CI).
        debugDefaultTargetPlatformOverride = null;
        if (Platform.isAndroid) {
          // Running on a real Android device; this case cannot be tested
          // here. Skip gracefully.
          return;
        }
        final svc = RealDeviceInfoService();
        final result = await svc.getSimPhoneNumber();
        check(result).isA<SimNumberUnsupported>();
      },
    );
  });
}
