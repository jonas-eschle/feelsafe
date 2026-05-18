/// Real phone-service implementation.
///
/// Dart-side only. Android uses a method channel
/// (`com.guardianangela.app/phone`) for auto-dial with `CALL_PHONE`
/// granted, falling back to `url_launcher` with a `tel:` URI when the
/// permission is not granted. iOS uses `url_launcher` with a `tel:`
/// URI exclusively (Apple does not allow background calls). Phase 10
/// implements the native Android bridge.
library;

import 'dart:developer' as developer;

import 'package:flutter/services.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:guardianangela/core/platform/platform_info.dart';
import 'package:guardianangela/services/protocols/phone_service_protocol.dart';

/// Real platform-backed implementation of [PhoneServiceProtocol].
final class PhoneService implements PhoneServiceProtocol {
  /// Creates the real phone service.
  ///
  /// [platform] defaults to the const production [PlatformInfo()];
  /// tests inject a [FakePlatformInfo] to exercise the Android path.
  PhoneService({PlatformInfo platform = const PlatformInfo()})
      : _platform = platform;

  /// Method channel name; Phase 10 wires the native Android side.
  static const MethodChannel _channel = MethodChannel(
    'com.guardianangela.app/phone',
  );

  final PlatformInfo _platform;

  @override
  Future<void> call(String number, {bool isSimulation = false}) async {
    if (isSimulation) {
      developer.log('[SIM-BLOCK] phone.call number=$number');
      return;
    }
    await _placeCall(number, isEmergency: false);
  }

  @override
  Future<void> callEmergency(String number, {bool isSimulation = false}) async {
    if (isSimulation) {
      developer.log('[SIM-BLOCK] phone.callEmergency number=$number');
      return;
    }
    await _placeCall(number, isEmergency: true);
  }

  Future<void> _placeCall(String number, {required bool isEmergency}) async {
    if (_platform.isAndroid) {
      try {
        await _channel.invokeMethod<void>('call', {
          'number': number,
          'isEmergency': isEmergency,
        });
        return;
      } on MissingPluginException {
        // Phase 10 native not wired — fall through to tel: URI.
        developer.log('phone.call native not wired — Phase 10');
      } on PlatformException catch (e, s) {
        developer.log(
          'phone.call platform error — falling back to tel:',
          error: e,
          stackTrace: s,
        );
      }
    }
    final uri = Uri(scheme: 'tel', path: number);
    final ok = await launchUrl(uri);
    if (!ok) {
      throw StateError('Failed to launch tel: URI for $number');
    }
  }
}
