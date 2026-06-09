// Coverage for the toString() of small domain value types that carry
// debugging context (ChainEventData, PermissionRevocation). These are used in
// log lines and test failure messages; a regression that drops a field from
// toString would surface here.

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/engine/chain_event.dart';
import 'package:guardianangela/domain/enums/app_permission.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/permission_revocation.dart';

void main() {
  group('ChainEventData.toString', () {
    test('includes the event, step index, type, and metadata', () {
      const data = ChainEventData(
        ChainEvent.stepAdvancing,
        stepIndex: 3,
        stepType: ChainStepType.smsContact,
        metadata: {'reason': 'graceExpired'},
      );
      final s = data.toString();
      check(s).contains('stepAdvancing');
      check(s).contains('step=3');
      check(s).contains('smsContact');
      check(s).contains('graceExpired');
    });

    test('renders an empty metadata map for a bare chain-level event', () {
      const data = ChainEventData(ChainEvent.sessionStarted);
      final s = data.toString();
      check(s).contains('sessionStarted');
      check(s).contains('step=null');
      check(s).contains('meta={}');
    });
  });

  group('PermissionRevocation.toString', () {
    test('includes the permission and the revocation timestamp', () {
      final r = PermissionRevocation(
        permission: AppPermission.location,
        revokedAt: DateTime.utc(2026, 6, 9, 10),
      );
      final s = r.toString();
      check(s).contains('location');
      check(s).contains('2026');
    });
  });
}
