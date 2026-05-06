/// Contract tests for [PermissionServiceProtocol] — exercised
/// against the fake implementation. The real implementation is
/// covered indirectly by `lib/core/utils/permission_utils.dart`'s
/// platform-channel paths; here we lock down the fake's scripted-
/// return semantics and call log so call-site tests can rely on
/// them.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/services/fakes/fake_permission_service.dart';
import 'package:guardianangela/services/protocols/permission_service_protocol.dart';

void main() {
  group('FakePermissionService contract', () {
    test('defaults all permissions to granted', () async {
      final svc = FakePermissionService();
      check(await svc.ensureNotification()).isTrue();
      check(await svc.ensureLocation()).isTrue();
      check(await svc.ensureCallPhone()).isTrue();
      check(await svc.ensureSendSms()).isTrue();
      check(await svc.ensureBatteryOptimizationExempt()).isTrue();
    });

    test('scripted denial flows return false', () async {
      final svc = FakePermissionService(
        notificationGranted: false,
        locationGranted: false,
        callPhoneGranted: false,
        sendSmsGranted: false,
        batteryOptimizationExempt: false,
      );
      check(await svc.ensureNotification()).isFalse();
      check(await svc.ensureLocation()).isFalse();
      check(await svc.ensureCallPhone()).isFalse();
      check(await svc.ensureSendSms()).isFalse();
      check(await svc.ensureBatteryOptimizationExempt()).isFalse();
    });

    test('records every call with the level argument', () async {
      final svc = FakePermissionService();
      await svc.ensureNotification();
      await svc.ensureLocation(level: LocationPermissionLevel.always);
      await svc.ensureLocation(); // default whenInUse
      await svc.ensureCallPhone();
      await svc.ensureSendSms();
      await svc.ensureBatteryOptimizationExempt();
      await svc.openAppSettings();
      check(svc.calls).deepEquals([
        'ensureNotification',
        'ensureLocation:always',
        'ensureLocation:whenInUse',
        'ensureCallPhone',
        'ensureSendSms',
        'ensureBatteryOptimizationExempt',
        'openAppSettings',
      ]);
    });

    test('mid-test toggle changes outcome of subsequent calls', () async {
      final svc = FakePermissionService();
      check(await svc.ensureSendSms()).isTrue();
      svc.sendSmsGranted = false;
      check(await svc.ensureSendSms()).isFalse();
    });
  });
}
