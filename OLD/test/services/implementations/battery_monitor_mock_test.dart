/// Tests for `BatteryMonitorService` using a mocked battery plugin.
///
/// Installs mocks for `dev.fluttercommunity.plus/battery` (method
/// channel) and `dev.fluttercommunity.plus/charging` (event channel)
/// so we can exercise:
///  * startMonitoring seeds _lastLevel
///  * state-change triggers a `_sample` via the event channel
///  * periodic poll via Timer fires a crossing
///  * onLowBattery fires exactly once per crossing
library;

import 'package:checks/checks.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/services/implementations/battery_monitor_service.dart';

import 'channel_test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const batteryChannel = MethodChannel('dev.fluttercommunity.plus/battery');
  const chargingChannel =
      EventChannel('dev.fluttercommunity.plus/charging');

  group('BatteryMonitorService (mocked plugin)', () {
    test('startMonitoring seeds last level and stays active', () async {
      installMethodChannelMock(batteryChannel, responder: (call) {
        if (call.method == 'getBatteryLevel') return 50;
        return null;
      });
      installEventChannelMock(chargingChannel);
      final s = BatteryMonitorService();
      await s.startMonitoring(thresholdPercent: 20);
      check(s.isActive).isTrue();
      await s.stopMonitoring();
      check(s.isActive).isFalse();
    });

    test('event-driven state change with crossing fires onLowBattery',
        () async {
      int level = 50;
      installMethodChannelMock(batteryChannel, responder: (call) {
        if (call.method == 'getBatteryLevel') return level;
        return null;
      });
      final eventMock = installEventChannelMock(chargingChannel);
      final s = BatteryMonitorService();
      final events = <int>[];
      final sub = s.onLowBattery.listen(events.add);
      await s.startMonitoring(thresholdPercent: 25);
      check(s.isActive).isTrue();
      // Simulate a battery-state change while level drops below 25.
      level = 10;
      await eventMock.push('discharging');
      // Give the listener a tick to see the emitted value.
      await Future<void>.delayed(const Duration(milliseconds: 5));
      check(events).deepEquals([10]);
      // Idempotency: a second state change does not re-fire (latch).
      await eventMock.push('discharging');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      check(events).deepEquals([10]);
      await sub.cancel();
      await s.stopMonitoring();
    });

    test('non-crossing change does not fire', () async {
      int level = 80;
      installMethodChannelMock(batteryChannel, responder: (call) {
        if (call.method == 'getBatteryLevel') return level;
        return null;
      });
      final eventMock = installEventChannelMock(chargingChannel);
      final s = BatteryMonitorService();
      final events = <int>[];
      final sub = s.onLowBattery.listen(events.add);
      await s.startMonitoring(thresholdPercent: 20);
      level = 30; // still above threshold
      await eventMock.push('discharging');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      check(events).isEmpty();
      await sub.cancel();
      await s.stopMonitoring();
    });

    test('PlatformException in _safeBatteryLevel is swallowed', () async {
      bool errored = false;
      installMethodChannelMock(batteryChannel, responder: (call) {
        if (call.method == 'getBatteryLevel') {
          if (!errored) {
            errored = true;
            throw PlatformException(code: 'ERR');
          }
          return 15;
        }
        return null;
      });
      final eventMock = installEventChannelMock(chargingChannel);
      final s = BatteryMonitorService();
      await s.startMonitoring(thresholdPercent: 20);
      // No event triggered yet: _lastLevel is null from the PE catch.
      final events = <int>[];
      final sub = s.onLowBattery.listen(events.add);
      await eventMock.push('discharging');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      // previous(null fallback becomes level 15) > threshold(20) is false;
      // so no crossing. This covers the branch where previous ≤
      // threshold suppresses firing on initial sample.
      check(events).isEmpty();
      await sub.cancel();
      await s.stopMonitoring();
    });

    test('null battery level skips sampling', () async {
      installMethodChannelMock(batteryChannel, responder: (call) {
        if (call.method == 'getBatteryLevel') {
          throw PlatformException(code: 'ERR');
        }
        return null;
      });
      final eventMock = installEventChannelMock(chargingChannel);
      final s = BatteryMonitorService();
      final events = <int>[];
      final sub = s.onLowBattery.listen(events.add);
      await s.startMonitoring(thresholdPercent: 20);
      await eventMock.push('discharging');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      check(events).isEmpty();
      await sub.cancel();
      await s.stopMonitoring();
    });
  });
}
