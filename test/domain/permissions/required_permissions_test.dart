/// Tests for the pre-flight permission audit
/// (`lib/domain/permissions/required_permissions.dart`).
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/models/trigger.dart';
import 'package:guardianangela/domain/permissions/required_permissions.dart';
import 'package:guardianangela/services/fakes/fake_permission_service.dart';

ChainStep _step(
  ChainStepType type,
  int order, {
  StepConfig? config,
}) => ChainStep(
  id: 'step.$order',
  type: type,
  order: order,
  durationSeconds: 5,
  gracePeriodSeconds: 0,
  config: config,
);

SessionMode _mode(List<ChainStep> steps, {
  List<DisarmTrigger> disarmTriggers = const [],
  bool trackingEnabled = false,
}) => SessionMode(
  id: 'm',
  name: 'M',
  chainSteps: steps,
  disarmTriggers: disarmTriggers,
  trackingEnabled: trackingEnabled,
);

void main() {
  group('requiredPermissionsForMode', () {
    test('UI-only chain needs no permissions', () {
      final mode = _mode([
        _step(ChainStepType.holdButton, 0),
        _step(ChainStepType.countdownWarning, 1),
        _step(ChainStepType.fakeCall, 2),
        _step(ChainStepType.loudAlarm, 3),
      ]);
      check(requiredPermissionsForMode(mode)).isEmpty();
    });

    test('disguisedReminder step requires notification', () {
      final mode = _mode([_step(ChainStepType.disguisedReminder, 0)]);
      check(requiredPermissionsForMode(mode))
          .deepEquals({RequiredPermission.notification});
    });

    test(
      'smsContact with default config requires sendSms + location '
      '(SmsContactConfig defaults to channel.sms + includeLocation=true)',
      () {
        final mode = _mode([_step(ChainStepType.smsContact, 0)]);
        check(requiredPermissionsForMode(mode)).deepEquals({
          RequiredPermission.sendSms,
          RequiredPermission.location,
        });
      },
    );

    test(
      'smsContact with includeLocation=false drops location requirement',
      () {
        final mode = _mode([
          _step(
            ChainStepType.smsContact,
            0,
            config: const SmsContactConfig(includeLocation: false),
          ),
        ]);
        check(requiredPermissionsForMode(mode))
            .deepEquals({RequiredPermission.sendSms});
      },
    );

    test('smsContact via WhatsApp/Telegram needs no system permission '
        'beyond location', () {
      for (final ch in [MessageChannel.whatsapp, MessageChannel.telegram]) {
        final mode = _mode([
          _step(
            ChainStepType.smsContact,
            0,
            config: SmsContactConfig(channel: ch, includeLocation: false),
          ),
        ]);
        check(requiredPermissionsForMode(mode)).isEmpty();
      }
    });

    test(
      'smsContact via phoneCall channel triggers callPhone permission',
      () {
        final mode = _mode([
          _step(
            ChainStepType.smsContact,
            0,
            config: const SmsContactConfig(
              channel: MessageChannel.phoneCall,
              includeLocation: false,
            ),
          ),
        ]);
        check(requiredPermissionsForMode(mode))
            .deepEquals({RequiredPermission.callPhone});
      },
    );

    test('phoneCallContact + callEmergency need callPhone', () {
      final mode = _mode([
        _step(ChainStepType.phoneCallContact, 0),
        _step(ChainStepType.callEmergency, 1),
      ]);
      check(requiredPermissionsForMode(mode))
          .deepEquals({RequiredPermission.callPhone});
    });

    test('GpsArrivalDisarmTrigger adds location', () {
      final mode = _mode(
        [_step(ChainStepType.holdButton, 0)],
        disarmTriggers: const [
          GpsArrivalDisarmTrigger(
            latitude: 47.0,
            longitude: 8.0,
            radiusMeters: 100,
          ),
        ],
      );
      check(requiredPermissionsForMode(mode))
          .deepEquals({RequiredPermission.location});
    });

    test('trackingEnabled adds location', () {
      final mode = _mode(
        [_step(ChainStepType.holdButton, 0)],
        trackingEnabled: true,
      );
      check(requiredPermissionsForMode(mode))
          .deepEquals({RequiredPermission.location});
    });

    test('full Walk-Mode-like chain accumulates everything', () {
      final mode = _mode([
        _step(ChainStepType.holdButton, 0),
        _step(ChainStepType.fakeCall, 1),
        _step(ChainStepType.smsContact, 2),
        _step(ChainStepType.phoneCallContact, 3),
        _step(ChainStepType.callEmergency, 4),
      ]);
      check(requiredPermissionsForMode(mode)).deepEquals({
        RequiredPermission.sendSms,
        RequiredPermission.location,
        RequiredPermission.callPhone,
      });
    });
  });

  group('ensureSessionPermissions', () {
    test('returns empty set when service grants everything', () async {
      final service = FakePermissionService();
      final mode = _mode([_step(ChainStepType.smsContact, 0)]);
      final denied = await ensureSessionPermissions(
        service: service,
        mode: mode,
      );
      check(denied).isEmpty();
      // Both perms were requested.
      check(service.calls).contains('ensureSendSms');
      check(service.calls).contains('ensureLocation:whenInUse');
    });

    test('returns the subset that the service denied', () async {
      final service = FakePermissionService(
        sendSmsGranted: false,
        locationGranted: true,
      );
      final mode = _mode([_step(ChainStepType.smsContact, 0)]);
      final denied = await ensureSessionPermissions(
        service: service,
        mode: mode,
      );
      check(denied).deepEquals({RequiredPermission.sendSms});
    });

    test('does not request perms a mode does not need', () async {
      final service = FakePermissionService();
      final mode = _mode([_step(ChainStepType.holdButton, 0)]);
      final denied = await ensureSessionPermissions(
        service: service,
        mode: mode,
      );
      check(denied).isEmpty();
      check(service.calls).isEmpty();
    });
  });
}
