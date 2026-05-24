// Tests for RealPhoneService, SimulationPhoneService, and
// sanitizePhoneNumber helper.
//
// RealPhoneService uses url_launcher which talks to the platform. Tests mock
// the url_launcher MethodChannel so no actual phone app is opened.

import 'package:checks/checks.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/services/_phone_number_utils.dart';
import 'package:guardianangela/services/phone_service.dart';
import 'package:guardianangela/services/sim/phone_service_sim.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Minimal url_launcher mock — responds to every `launch` / `launchUrl`
/// / `canLaunch` call with [shouldSucceed].
class _UrlLauncherMock {
  _UrlLauncherMock();

  final bool shouldSucceed = true;

  final List<MethodCall> calls = [];

  void register() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/url_launcher_android'),
          _handle,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/url_launcher_ios'),
          _handle,
        );
    // url_launcher_android uses a different channel name in some versions.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/url_launcher'),
          _handle,
        );
  }

  void unregister() {
    for (final channel in [
      'plugins.flutter.io/url_launcher_android',
      'plugins.flutter.io/url_launcher_ios',
      'plugins.flutter.io/url_launcher',
    ]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(channel), null);
    }
  }

  Future<dynamic> _handle(MethodCall call) async {
    calls.add(call);
    if (call.method == 'canLaunchUrl' || call.method == 'canLaunch') {
      return shouldSucceed;
    }
    if (call.method == 'launchUrl' || call.method == 'launch') {
      return shouldSucceed;
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// sanitizePhoneNumber tests
// ---------------------------------------------------------------------------

void main() {
  // url_launcher uses Flutter platform channels; initialize Flutter test binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('sanitizePhoneNumber', () {
    test('strips spaces, dashes, parens — no plus prefix', () {
      check(sanitizePhoneNumber('+1 (555) 123-4567')).equals('+15551234567');
    });

    test('strips spaces only', () {
      check(sanitizePhoneNumber('0044 20 7946 0958')).equals('00442079460958');
    });

    test('preserves leading + with international format', () {
      check(sanitizePhoneNumber('+49 30 12345678')).equals('+493012345678');
    });

    test('already clean number passes unchanged', () {
      check(sanitizePhoneNumber('+15551234567')).equals('+15551234567');
    });

    test('emergency numbers (no plus) pass', () {
      check(sanitizePhoneNumber('112')).equals('112');
      check(sanitizePhoneNumber('911')).equals('911');
    });

    test('throws ArgumentError on empty string', () {
      check(() => sanitizePhoneNumber('')).throws<ArgumentError>();
    });

    test('throws ArgumentError on whitespace-only string', () {
      check(() => sanitizePhoneNumber('   ')).throws<ArgumentError>();
    });

    test('throws ArgumentError on non-digit-only string (dashes only)', () {
      check(() => sanitizePhoneNumber('---')).throws<ArgumentError>();
    });

    test('throws ArgumentError on plus-only string', () {
      check(() => sanitizePhoneNumber('+')).throws<ArgumentError>();
    });

    test('strips all punctuation varieties', () {
      check(sanitizePhoneNumber('+1.555.123.4567')).equals('+15551234567');
    });
  });

  // -------------------------------------------------------------------------
  // SimulationPhoneService tests
  // -------------------------------------------------------------------------

  group('SimulationPhoneService', () {
    late SimulationPhoneService svc;

    setUp(() => svc = SimulationPhoneService());

    // ---- call() ----

    test('call() records a regular PhoneCall entry', () async {
      await svc.call('+15551234567');
      check(svc.calls).length.equals(1);
      check(svc.calls.first.isEmergency).isFalse();
      check(svc.calls.first.phoneNumber).equals('+15551234567');
    });

    test('call() returns true (simulates success)', () async {
      final result = await svc.call('+15551234567');
      check(result).isTrue();
    });

    test('call() sanitizes the phone number before recording', () async {
      await svc.call('+1 (555) 000-1111');
      check(svc.calls.first.phoneNumber).equals('+15550001111');
    });

    test('call() with isSimulation=true returns false, no record', () async {
      final result = await svc.call('+15551234567', isSimulation: true);
      check(result).isFalse();
      check(svc.calls).isEmpty();
    });

    test('call() throws ArgumentError on empty number', () async {
      await expectLater(svc.call(''), throwsA(isA<ArgumentError>()));
    });

    // ---- callEmergency() ----

    test('callEmergency() records an emergency PhoneCall entry', () async {
      await svc.callEmergency('112');
      check(svc.calls).length.equals(1);
      check(svc.calls.first.isEmergency).isTrue();
      check(svc.calls.first.phoneNumber).equals('112');
    });

    test('callEmergency() returns true', () async {
      final result = await svc.callEmergency('911');
      check(result).isTrue();
    });

    test('callEmergency() sanitizes number', () async {
      await svc.callEmergency('+1 (800) 123-4567');
      check(svc.calls.first.phoneNumber).equals('+18001234567');
    });

    test('callEmergency() with isSimulation=true returns false, no record', () async {
      final result = await svc.callEmergency('112', isSimulation: true);
      check(result).isFalse();
      check(svc.calls).isEmpty();
    });

    test('callEmergency() throws ArgumentError on empty number', () async {
      await expectLater(svc.callEmergency(''), throwsA(isA<ArgumentError>()));
    });

    // ---- helpers ----

    test('emergencyCalls filters only emergency calls', () async {
      await svc.call('+15551234567');
      await svc.callEmergency('112');
      check(svc.emergencyCalls).length.equals(1);
      check(svc.emergencyCalls.first.phoneNumber).equals('112');
    });

    test('regularCalls filters only regular calls', () async {
      await svc.call('+15551234567');
      await svc.callEmergency('112');
      check(svc.regularCalls).length.equals(1);
      check(svc.regularCalls.first.phoneNumber).equals('+15551234567');
    });

    test('reset() clears calls', () async {
      await svc.call('+15551234567');
      svc.reset();
      check(svc.calls).isEmpty();
    });

    test('multiple calls accumulate in order', () async {
      await svc.call('+15550000001');
      await svc.callEmergency('112');
      await svc.call('+15550000002');
      check(svc.calls).length.equals(3);
      check(svc.calls[0].phoneNumber).equals('+15550000001');
      check(svc.calls[1].phoneNumber).equals('112');
      check(svc.calls[2].phoneNumber).equals('+15550000002');
    });

    test('timestamps are set to recent DateTime', () async {
      final before = DateTime.now();
      await svc.call('+15551234567');
      final after = DateTime.now();
      check(svc.calls.first.timestamp.isAfter(before) ||
            svc.calls.first.timestamp.isAtSameMomentAs(before)).isTrue();
      check(svc.calls.first.timestamp.isBefore(after) ||
            svc.calls.first.timestamp.isAtSameMomentAs(after)).isTrue();
    });
  });

  // -------------------------------------------------------------------------
  // RealPhoneService tests
  // -------------------------------------------------------------------------

  group('RealPhoneService', () {
    late RealPhoneService svc;
    late _UrlLauncherMock mock;

    setUp(() {
      svc = const RealPhoneService();
      mock = _UrlLauncherMock();
      mock.register();
    });

    tearDown(() => mock.unregister());

    test('call() with isSimulation=true returns false without launching URL',
        () async {
      final result = await svc.call('+15551234567', isSimulation: true);
      check(result).isFalse();
      check(mock.calls).isEmpty();
    });

    test('callEmergency() with isSimulation=true returns false', () async {
      final result = await svc.callEmergency('112', isSimulation: true);
      check(result).isFalse();
      check(mock.calls).isEmpty();
    });

    test('call() throws ArgumentError on empty number', () async {
      await expectLater(svc.call(''), throwsA(isA<ArgumentError>()));
    });

    test('callEmergency() throws ArgumentError on empty number', () async {
      await expectLater(svc.callEmergency(''), throwsA(isA<ArgumentError>()));
    });

    test('call() throws ArgumentError on non-digit string', () async {
      await expectLater(svc.call('---'), throwsA(isA<ArgumentError>()));
    });

    test('callEmergency() throws ArgumentError on non-digit string', () async {
      await expectLater(
        svc.callEmergency('---'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
