// Tests for RealQuickExitService, SimulationQuickExitService, and the
// MissingPluginException fallback path.
//
// RealQuickExitService talks to the
// `com.guardianangela.app/quick_exit` MethodChannel. Tests intercept
// the channel via TestDefaultBinaryMessenger so the test process is
// not terminated and so we can assert the exact method name.

import 'package:flutter/services.dart';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/services/quick_exit_service.dart';
import 'package:guardianangela/services/sim/quick_exit_service_sim.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.guardianangela.app/quick_exit');
  // The Real impl falls back to SystemNavigator.pop on
  // MissingPluginException — that hits the SystemChannels.platform
  // channel, which we also stub so the fallback can be observed.
  const systemNavChannel = SystemChannels.platform;

  group('RealQuickExitService', () {
    final calls = <MethodCall>[];

    setUp(calls.clear);

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(systemNavChannel, null);
    });

    test('invokes "quickExit" on com.guardianangela.app/quick_exit', () async {
      // Arrange — stub the channel to record the call and return null.
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
            calls.add(call);
            return null;
          });
      final service = RealQuickExitService();

      // Act
      await service.quickExit();

      // Assert — exactly one call, with the correct method name and no
      // arguments.
      check(calls).length.equals(1);
      check(calls.single.method).equals('quickExit');
      check(calls.single.arguments).isNull();
    });

    test(
      'falls back to SystemNavigator.pop on MissingPluginException',
      () async {
        // Arrange — the native channel is *not* registered, so the
        // platform framework will throw MissingPluginException. The
        // fallback hits SystemChannels.platform.SystemNavigator.pop,
        // which we capture.
        final systemCalls = <MethodCall>[];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(systemNavChannel, (
              MethodCall call,
            ) async {
              systemCalls.add(call);
              return null;
            });
        final service = RealQuickExitService();

        // Act
        await service.quickExit();

        // Assert — SystemNavigator.pop was invoked exactly once.
        final navCalls = systemCalls
            .where((c) => c.method == 'SystemNavigator.pop')
            .toList();
        check(navCalls).length.equals(1);
      },
    );

    test('falls back to SystemNavigator.pop on PlatformException', () async {
      // Arrange — the native channel deliberately throws so we hit
      // the catch branch.
      final systemCalls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
            throw PlatformException(
              code: 'NATIVE_ERROR',
              message: 'simulated failure',
            );
          });
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(systemNavChannel, (MethodCall call) async {
            systemCalls.add(call);
            return null;
          });
      final service = RealQuickExitService();

      // Act — must NOT throw despite the PlatformException.
      await service.quickExit();

      // Assert — fallback was invoked.
      final navCalls = systemCalls
          .where((c) => c.method == 'SystemNavigator.pop')
          .toList();
      check(navCalls).length.equals(1);
    });

    test('swallows a thrown SystemNavigator.pop fallback failure', () async {
      // Arrange — channel missing AND the fallback handler throws.
      // The user has already confirmed exit; we must not bubble up.
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(systemNavChannel, (MethodCall call) async {
            throw PlatformException(code: 'CANNOT_POP');
          });
      final service = RealQuickExitService();

      // Act + Assert — completes without throwing.
      await service.quickExit();
    });
  });

  group('SimulationQuickExitService', () {
    test('quickExit records the invocation in calls', () async {
      final service = SimulationQuickExitService();
      check(service.calls).isEmpty();

      await service.quickExit();
      check(service.calls).length.equals(1);

      await service.quickExit();
      check(service.calls).length.equals(2);
    });

    test('reset clears the call history', () async {
      final service = SimulationQuickExitService();
      await service.quickExit();
      check(service.calls).length.equals(1);
      service.reset();
      check(service.calls).isEmpty();
    });
  });
}
