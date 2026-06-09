// Tests for PermissionAuditService (Stage 5C).
//
// Uses a constructor-injected permissionChecker so no real
// permission_handler calls are made.

import 'dart:async';

import 'package:checks/checks.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/app_permission.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/permission_audit_result.dart';
import 'package:guardianangela/domain/models/permission_revocation.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/triggers/disarm_trigger.dart';
import 'package:guardianangela/services/permission_audit_service.dart';
import 'package:guardianangela/services/sim/permission_audit_service_sim.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

ChainStep _step(
  String id,
  ChainStepType type, {
  StepConfig? config,
  int order = 0,
}) => ChainStep(
  id: id,
  type: type,
  order: order,
  waitSeconds: 60,
  durationSeconds: 30,
  gracePeriodSeconds: 10,
  retryCount: 0,
  randomize: false,
  config: config,
);

SessionMode _modeWith({
  List<ChainStep> steps = const [],
  bool trackingEnabled = false,
  List<DisarmTrigger> disarmTriggers = const [],
}) => SessionMode(
  id: 'test_mode',
  name: 'Test Mode',
  chainSteps: steps.isEmpty ? [_step('s1', ChainStepType.holdButton)] : steps,
  trackingEnabled: trackingEnabled,
  disarmTriggers: disarmTriggers,
);

/// Creates a [RealPermissionAuditService] with all permissions returning
/// [granted] status by default, overriding specific ones via [overrides].
RealPermissionAuditService _makeService({
  Map<Permission, PermissionStatus> overrides = const {},
  Duration pollInterval = const Duration(milliseconds: 10),
}) {
  final statuses = {
    for (final p in Permission.values) p: PermissionStatus.granted,
    ...overrides,
  };
  return RealPermissionAuditService(
    pollInterval: pollInterval,
    permissionChecker: (p) async => statuses[p] ?? PermissionStatus.denied,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('RealPermissionAuditService — auditForMode', () {
    test('holdButton-only mode requires only notification', () async {
      final svc = _makeService();
      final mode = _modeWith(steps: [_step('s1', ChainStepType.holdButton)]);
      final result = await svc.auditForMode(mode);
      check(result.allGranted).isTrue();
      check(result.missing).isEmpty();
    });

    test('a mode of only no-permission step types adds no extra permission '
        '(covers the disguisedReminder, countdownWarning, fakeCall, '
        'hardwareButton switch arms)', () async {
      final svc = _makeService();
      final mode = _modeWith(
        steps: [
          _step('s1', ChainStepType.disguisedReminder),
          _step('s2', ChainStepType.countdownWarning),
          _step('s3', ChainStepType.fakeCall),
          _step('s4', ChainStepType.hardwareButton),
        ],
      );
      final result = await svc.auditForMode(mode);
      // None of these step types require a system permission beyond the
      // baseline notification permission.
      check(result.allGranted).isTrue();
      check(result.missing).isEmpty();
    });

    test('all permissions granted returns allGranted = true', () async {
      final svc = _makeService();
      final mode = _modeWith(
        steps: [
          _step(
            's1',
            ChainStepType.smsContact,
            config: const SmsContactConfig(),
          ),
          _step('s2', ChainStepType.phoneCallContact),
          _step('s3', ChainStepType.loudAlarm, config: const LoudAlarmConfig()),
        ],
        trackingEnabled: true,
      );
      final result = await svc.auditForMode(mode);
      check(result.allGranted).isTrue();
      check(result.missing).isEmpty();
    });

    test('SMS step missing SEND_SMS → sms in missing list', () async {
      final svc = _makeService(
        overrides: {Permission.sms: PermissionStatus.denied},
      );
      final mode = _modeWith(
        steps: [
          _step(
            's1',
            ChainStepType.smsContact,
            config: const SmsContactConfig(),
          ),
        ],
      );
      final result = await svc.auditForMode(mode);
      check(result.allGranted).isFalse();
      check(result.missing).contains(AppPermission.sms);
    });

    test(
      'WhatsApp/Telegram SMS step does NOT require sms permission',
      () async {
        final svc = _makeService(
          overrides: {Permission.sms: PermissionStatus.denied},
        );
        final mode = _modeWith(
          steps: [
            _step(
              's1',
              ChainStepType.smsContact,
              config: const SmsContactConfig(channel: MessageChannel.whatsapp),
            ),
          ],
        );
        final result = await svc.auditForMode(mode);
        // Sms permission not in required set → no missing sms entry.
        check(result.missing).not((c) => c.contains(AppPermission.sms));
      },
    );

    test('phoneCallContact step requires phone permission', () async {
      final svc = _makeService(
        overrides: {Permission.phone: PermissionStatus.denied},
      );
      final mode = _modeWith(
        steps: [_step('s1', ChainStepType.phoneCallContact)],
      );
      final result = await svc.auditForMode(mode);
      check(result.missing).contains(AppPermission.phone);
    });

    test('callEmergency step requires phone permission', () async {
      final svc = _makeService(
        overrides: {Permission.phone: PermissionStatus.denied},
      );
      final mode = _modeWith(steps: [_step('s1', ChainStepType.callEmergency)]);
      final result = await svc.auditForMode(mode);
      check(result.missing).contains(AppPermission.phone);
    });

    test('trackingEnabled = true requires location permission', () async {
      final svc = _makeService(
        overrides: {Permission.location: PermissionStatus.denied},
      );
      final mode = _modeWith(trackingEnabled: true);
      final result = await svc.auditForMode(mode);
      check(result.missing).contains(AppPermission.location);
    });

    test('GpsArrivalDisarmTrigger requires location permission', () async {
      final svc = _makeService(
        overrides: {Permission.location: PermissionStatus.denied},
      );
      final mode = _modeWith(disarmTriggers: [const GpsArrivalDisarmTrigger()]);
      final result = await svc.auditForMode(mode);
      check(result.missing).contains(AppPermission.location);
    });

    test('TimerDisarmTrigger does NOT require location', () async {
      final svc = _makeService(
        overrides: {Permission.location: PermissionStatus.denied},
      );
      final mode = _modeWith(
        disarmTriggers: [const TimerDisarmTrigger(durationSeconds: 60)],
      );
      final result = await svc.auditForMode(mode);
      check(result.missing).not((c) => c.contains(AppPermission.location));
    });

    test(
      'autoRecordAudio = true on smsContact step requires microphone',
      () async {
        final svc = _makeService(
          overrides: {Permission.microphone: PermissionStatus.denied},
        );
        final mode = _modeWith(
          steps: [
            _step(
              's1',
              ChainStepType.smsContact,
              config: const SmsContactConfig(autoRecordAudio: true),
            ),
          ],
        );
        final result = await svc.auditForMode(mode);
        check(result.missing).contains(AppPermission.microphone);
      },
    );

    test('loudAlarm flashLight = true requires camera permission', () async {
      final svc = _makeService(
        overrides: {Permission.camera: PermissionStatus.denied},
      );
      final mode = _modeWith(
        steps: [
          _step('s1', ChainStepType.loudAlarm, config: const LoudAlarmConfig()),
        ],
      );
      final result = await svc.auditForMode(mode);
      check(result.missing).contains(AppPermission.camera);
    });

    test('loudAlarm flashLight = false does NOT require camera', () async {
      final svc = _makeService(
        overrides: {Permission.camera: PermissionStatus.denied},
      );
      final mode = _modeWith(
        steps: [
          _step(
            's1',
            ChainStepType.loudAlarm,
            config: const LoudAlarmConfig(flashLight: false),
          ),
        ],
      );
      final result = await svc.auditForMode(mode);
      check(result.missing).not((c) => c.contains(AppPermission.camera));
    });

    test('notification always required regardless of mode config', () async {
      final svc = _makeService(
        overrides: {Permission.notification: PermissionStatus.denied},
      );
      final mode = _modeWith(steps: [_step('s1', ChainStepType.holdButton)]);
      final result = await svc.auditForMode(mode);
      check(result.missing).contains(AppPermission.notification);
    });

    test('warnOnly = true when isSimulation = true', () async {
      final svc = _makeService(
        overrides: {Permission.sms: PermissionStatus.denied},
      );
      final mode = _modeWith(
        steps: [
          _step(
            's1',
            ChainStepType.smsContact,
            config: const SmsContactConfig(),
          ),
        ],
      );
      final result = await svc.auditForMode(mode, isSimulation: true);
      check(result.warnOnly).isTrue();
      check(result.missing).isNotEmpty();
    });

    test('warnOnly = false when isSimulation = false (real session)', () async {
      final svc = _makeService();
      final mode = _modeWith();
      final result = await svc.auditForMode(mode);
      check(result.warnOnly).isFalse();
    });
  });

  group('RealPermissionAuditService — revocations stream', () {
    test(
      'revocations stream emits when a granted permission is later denied',
      () async {
        final statuses = {
          for (final p in Permission.values) p: PermissionStatus.granted,
        };

        final svc = RealPermissionAuditService(
          pollInterval: const Duration(milliseconds: 20),
          permissionChecker: (p) async =>
              statuses[p] ?? PermissionStatus.denied,
        );

        // Seed the last-known map by running an audit.
        final mode = _modeWith(trackingEnabled: true);
        await svc.auditForMode(mode);

        // Subscribe to revocations.
        final revocations = <PermissionRevocation>[];
        final sub = svc.revocations.listen(revocations.add);

        // Revoke location permission after subscription.
        statuses[Permission.location] = PermissionStatus.denied;

        // Wait for at least one poll cycle.
        await Future<void>.delayed(const Duration(milliseconds: 100));

        await sub.cancel();
        svc.dispose();

        check(revocations.length).isGreaterOrEqual(1);
        check(revocations.first.permission).equals(AppPermission.location);
      },
    );

    test('revocations stream emits UTC revokedAt timestamp', () async {
      final statuses = {
        for (final p in Permission.values) p: PermissionStatus.granted,
      };

      final svc = RealPermissionAuditService(
        pollInterval: const Duration(milliseconds: 20),
        permissionChecker: (p) async => statuses[p] ?? PermissionStatus.denied,
      );

      final mode = _modeWith(
        steps: [
          _step(
            's1',
            ChainStepType.smsContact,
            config: const SmsContactConfig(),
          ),
        ],
      );
      await svc.auditForMode(mode);

      final revocations = <PermissionRevocation>[];
      final sub = svc.revocations.listen(revocations.add);

      statuses[Permission.sms] = PermissionStatus.denied;
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await sub.cancel();
      svc.dispose();

      check(revocations).isNotEmpty();
      check(revocations.first.revokedAt.isUtc).isTrue();
    });
  });

  group('SimulationPermissionAuditService', () {
    test('returns allGranted by default', () async {
      final svc = SimulationPermissionAuditService();
      final mode = _modeWith();
      final result = await svc.auditForMode(mode);
      check(result.allGranted).isTrue();
    });

    test('records audited modes', () async {
      final svc = SimulationPermissionAuditService();
      final mode = _modeWith();
      await svc.auditForMode(mode);
      await svc.auditForMode(mode);
      check(svc.auditedModes.length).equals(2);
    });

    test('returns constructor-injected result', () async {
      const fixedResult = PermissionAuditResult(
        missing: [AppPermission.sms],
        warnOnly: false,
      );
      final svc = SimulationPermissionAuditService(fixedResult: fixedResult);
      final mode = _modeWith();
      final result = await svc.auditForMode(mode);
      check(result.missing).deepEquals([AppPermission.sms]);
    });

    test('emitRevocation pushes onto revocations stream', () async {
      final svc = SimulationPermissionAuditService();
      final events = <PermissionRevocation>[];
      final sub = svc.revocations.listen(events.add);

      final event = PermissionRevocation(
        permission: AppPermission.location,
        revokedAt: DateTime.utc(2026),
      );
      svc.emitRevocation(event);

      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      svc.dispose();

      check(events.length).equals(1);
      check(events.first).equals(event);
    });

    test('reset clears auditedModes', () async {
      final svc = SimulationPermissionAuditService();
      final mode = _modeWith();
      await svc.auditForMode(mode);
      svc.reset();
      check(svc.auditedModes).isEmpty();
    });
  });

  group('PermissionAuditResult model', () {
    test('allGranted named ctor has empty missing and warnOnly=false', () {
      const result = PermissionAuditResult.allGranted();
      check(result.allGranted).isTrue();
      check(result.missing).isEmpty();
      check(result.warnOnly).isFalse();
    });

    test('allGranted is false when missing is non-empty', () {
      const result = PermissionAuditResult(
        missing: [AppPermission.camera],
        warnOnly: false,
      );
      check(result.allGranted).isFalse();
    });
  });
}
