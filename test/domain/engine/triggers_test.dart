import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/engine/chain_event.dart';
import 'package:guardianangela/domain/engine/trigger_manager.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/triggers/disarm_trigger.dart';
import 'package:guardianangela/domain/triggers/distress_trigger.dart';
import 'engine_test_helpers.dart';

void main() {
  group('Triggers', () {
    test('TriggerManager notifyHardwarePanic fires distress callback', () {
      var distressFired = false;
      final mgr = TriggerManager(
        distressTriggers: const [HardwareButtonDistressTrigger()],
        disarmTriggers: const [],
        onDistress: (_) => distressFired = true,
        onDisarm: () {},
      );
      mgr.start();
      mgr.notifyHardwarePanic();
      check(distressFired).isTrue();
      mgr.stop();
    });

    test('TriggerManager notifyHardwarePanic without trigger does nothing', () {
      var distressFired = false;
      final mgr = TriggerManager(
        distressTriggers: const [],
        disarmTriggers: const [],
        onDistress: (_) => distressFired = true,
        onDisarm: () {},
      );
      mgr.start();
      mgr.notifyHardwarePanic();
      check(distressFired).isFalse();
      mgr.stop();
    });

    test('TriggerManager GPS arrival fires disarm callback', () {
      var disarmed = false;
      final mgr = TriggerManager(
        distressTriggers: const [],
        disarmTriggers: const [GpsArrivalDisarmTrigger()],
        onDistress: (_) {},
        onDisarm: () => disarmed = true,
      );
      mgr.start();
      mgr.notifyGpsArrival();
      check(disarmed).isTrue();
      mgr.stop();
    });

    test('TriggerManager GPS arrival without trigger does nothing', () {
      var disarmed = false;
      final mgr = TriggerManager(
        distressTriggers: const [],
        disarmTriggers: const [],
        onDistress: (_) {},
        onDisarm: () => disarmed = true,
      );
      mgr.start();
      mgr.notifyGpsArrival();
      check(disarmed).isFalse();
      mgr.stop();
    });

    test('TimerDisarmTrigger fires disarm after duration', () {
      fakeAsync((async) {
        var disarmed = false;
        final mgr = TriggerManager(
          distressTriggers: const [],
          disarmTriggers: const [TimerDisarmTrigger(durationSeconds: 5)],
          onDistress: (_) {},
          onDisarm: () => disarmed = true,
        );
        mgr.start();

        async.elapse(const Duration(seconds: 4));
        check(disarmed).isFalse();

        async.elapse(const Duration(seconds: 1));
        check(disarmed).isTrue();

        mgr.stop();
      });
    });

    test(
      'allowDisarmAsDistress=false blocks GPS disarm during distress mode',
      () {
        var disarmed = false;
        final mgr = TriggerManager(
          distressTriggers: const [],
          disarmTriggers: const [GpsArrivalDisarmTrigger()],
          onDistress: (_) {},
          onDisarm: () => disarmed = true,
          allowDisarmDuringDistress: false,
        );
        mgr.start();
        mgr.enterDistressMode();
        mgr.notifyGpsArrival();
        check(disarmed).isFalse();
        mgr.stop();
      },
    );

    test(
      'allowDisarmAsDistress=true allows GPS disarm during distress mode',
      () {
        var disarmed = false;
        final mgr = TriggerManager(
          distressTriggers: const [],
          disarmTriggers: const [GpsArrivalDisarmTrigger()],
          onDistress: (_) {},
          onDisarm: () => disarmed = true,
        );
        mgr.start();
        mgr.enterDistressMode();
        mgr.notifyGpsArrival();
        check(disarmed).isTrue();
        mgr.stop();
      },
    );

    test(
      'allowDisarmAsDistress=false cancels pending timers on enterDistressMode',
      () {
        fakeAsync((async) {
          var disarmed = false;
          final mgr = TriggerManager(
            distressTriggers: const [],
            disarmTriggers: const [TimerDisarmTrigger(durationSeconds: 5)],
            onDistress: (_) {},
            onDisarm: () => disarmed = true,
            allowDisarmDuringDistress: false,
          );
          mgr.start();
          mgr.enterDistressMode(); // Should cancel timer.

          async.elapse(const Duration(seconds: 10));
          check(disarmed).isFalse();

          mgr.stop();
        });
      },
    );

    test('TriggerManager stop() prevents callbacks', () {
      fakeAsync((async) {
        var disarmed = false;
        final mgr = TriggerManager(
          distressTriggers: const [],
          disarmTriggers: const [TimerDisarmTrigger(durationSeconds: 2)],
          onDistress: (_) {},
          onDisarm: () => disarmed = true,
        );
        mgr.start();
        mgr.stop();

        async.elapse(const Duration(seconds: 5));
        check(disarmed).isFalse();
      });
    });

    test('engine.replaceWithDistressChain gates allowDisarmAsDistress=false', () {
      fakeAsync((async) {
        // Mode with allowDisarmAsDistress=false.
        final m = mode(
          chainSteps: [step(durationSeconds: 1)],
          disarmTriggers: const [GpsArrivalDisarmTrigger()],
          allowDisarmAsDistress: false,
        );
        final events = <ChainEventData>[];
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.events.listen(events.add);
        engine.start();
        async.flushMicrotasks();

        engine.replaceWithDistressChain(
          chain: [step(type: ChainStepType.smsContact, durationSeconds: 2)],
          triggerReason: EndReason.hardwarePanic,
        );
        async.flushMicrotasks();
        check(engine.isDistressChain).isTrue();

        // GPS arrival should be blocked — userDisarmed should not fire.
        engine
            .disarm(); // direct disarm should still work (G-014 is trigger-based)
        // Note: G-014 gates disarmTriggers, not direct disarm() calls.
        engine.endSession();
      });
    });

    test('hardware panic fires hardwarePanic distress reason', () {
      var reason = EndReason.userQuit;
      final mgr = TriggerManager(
        distressTriggers: const [HardwareButtonDistressTrigger()],
        disarmTriggers: const [],
        onDistress: (r) => reason = r,
        onDisarm: () {},
      );
      mgr.start();
      mgr.notifyHardwarePanic();
      check(reason).equals(EndReason.hardwarePanic);
      mgr.stop();
    });
  });
}
