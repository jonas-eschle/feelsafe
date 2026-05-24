// Phase 7 native dependency: url_launcher handles tel: URIs cross-platform.
// Android ACTION_CALL intent (CALL_PHONE permission) auto-dials without
// confirmation. iOS tel: always shows a system confirmation dialog.
// No custom MethodChannel — url_launcher covers all PhoneService needs.

import 'dart:developer';

import 'package:url_launcher/url_launcher.dart';

import 'package:guardianangela/services/_phone_number_utils.dart';
import 'package:guardianangela/services/protocols/phone_service_protocol.dart';

/// Production [PhoneServiceProtocol] backed by `package:url_launcher`.
///
/// Uses `tel:` URIs for both regular and emergency calls.
///
/// - **Android:** With `CALL_PHONE` permission, `tel:` URIs dial without a
///   confirmation dialog via `ACTION_CALL`. `launchUrl` with
///   [LaunchMode.externalApplication] routes through the dialer intent.
/// - **iOS:** Always shows a system confirmation dialog before dialing
///   (documented OS limitation per spec 05:352). This cannot be bypassed.
///
/// Phone number sanitization strips all non-digit characters while
/// preserving the leading `+` prefix for international numbers (spec
/// 05:317). An empty sanitized number throws [ArgumentError] (fail-loud
/// per CLAUDE.md global rule #8).
///
/// **Single constructor location rule:** no `RealPhoneService()` call may
/// appear outside `lib/services/service_providers.dart` (CI grep enforces).
class RealPhoneService implements PhoneServiceProtocol {
  /// Creates a [RealPhoneService].
  const RealPhoneService();

  // -------------------------------------------------------------------------
  // PhoneServiceProtocol implementation
  // -------------------------------------------------------------------------

  @override
  Future<bool> call(String phoneNumber, {bool isSimulation = false}) async {
    if (isSimulation) {
      log(
        '[SIM] call($phoneNumber) — suppressed at Layer 3',
        name: 'PhoneService',
      );
      return false;
    }
    return _dial(phoneNumber, isEmergency: false);
  }

  @override
  Future<bool> callEmergency(
    String emergencyNumber, {
    bool isSimulation = false,
  }) async {
    if (isSimulation) {
      log(
        '[SIM] callEmergency($emergencyNumber) — suppressed at Layer 3',
        name: 'PhoneService',
      );
      return false;
    }
    return _dial(emergencyNumber, isEmergency: true);
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  Future<bool> _dial(String rawNumber, {required bool isEmergency}) async {
    final number = sanitizePhoneNumber(rawNumber);
    final uri = Uri.parse('tel:$number');
    log(
      '${isEmergency ? "callEmergency" : "call"}($number)',
      name: 'PhoneService',
    );
    try {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      log('dial error for $number: $e', name: 'PhoneService');
      return false;
    }
  }
}
