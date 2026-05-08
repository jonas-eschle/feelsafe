/// Contract tests for [HomeWidgetServiceProtocol] and behaviour of
/// `FakeHomeWidgetService.updateStatus`. Verifies:
///
/// - `updateStatus` records a call that encodes status, modeName, and
///   isRunning — the equivalent of what the real implementation passes
///   to `HomeWidget.updateWidget(androidName: 'GuardianAngelaAppWidget',
///   iOSName: 'GuardianAngelaWidget')`.
/// - The real [HomeWidgetService] calls save+update on the platform
///   channel on a host OS (method-channel mock).
library;

import 'package:checks/checks.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/services/fakes/fake_home_widget_service.dart';
import 'package:guardianangela/services/implementations/home_widget_service.dart';

import 'implementations/channel_test_utils.dart';

// ---------------------------------------------------------------------------
// The home_widget package uses a fixed channel name on both platforms.
// The exact channel name comes from the home_widget v0.9.x source:
//   com.example.home_widget / home_widget
// We intercept the Flutter default binary messenger with
// TestDefaultBinaryMessengerBinding to capture calls.
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // -------------------------------------------------------------------------
  // FakeHomeWidgetService — protocol contract
  // -------------------------------------------------------------------------
  group('FakeHomeWidgetService — updateStatus', () {
    test('records an updateStatus call containing status, modeName, isRunning',
        () async {
      final fake = FakeHomeWidgetService();
      addTearDown(fake.dispose);

      await fake.updateStatus(
        status: 'Running',
        modeName: 'Walk Mode',
        isRunning: true,
      );

      final call = fake.calls
          .firstWhere((c) => c.startsWith('updateStatus:'), orElse: () => '');
      check(call).isNotEmpty();
      check(call).contains('Running');
      check(call).contains('Walk Mode');
      check(call).contains('true');
    });

    test('records different calls for idle vs active state', () async {
      final fake = FakeHomeWidgetService();
      addTearDown(fake.dispose);

      await fake.updateStatus(
        status: 'Idle',
        modeName: 'Walk Mode',
        isRunning: false,
      );
      await fake.updateStatus(
        status: 'Active',
        modeName: 'Date Mode',
        isRunning: true,
      );

      check(fake.calls.where((c) => c.startsWith('updateStatus:')).length)
          .equals(2);
    });

    test('writeLastMarker records the call and consumePendingMarker returns it',
        () async {
      final fake = FakeHomeWidgetService();
      addTearDown(fake.dispose);

      await fake.writeLastMarker('arm_session');
      check(fake.calls).contains('writeLastMarker:arm_session');

      final marker = await fake.consumePendingMarker();
      check(marker).equals('arm_session');

      // Second consume returns null — the marker was cleared.
      final second = await fake.consumePendingMarker();
      check(second).isNull();
    });

    test('widgetClicked stream delivers injected clicks', () async {
      final fake = FakeHomeWidgetService();
      addTearDown(fake.dispose);

      final received = <Uri?>[];
      final sub = fake.widgetClicked.listen(received.add);
      addTearDown(sub.cancel);

      fake.injectClick(Uri.parse('guardianangela://arm'));
      await Future<void>.delayed(Duration.zero);
      check(received.length).equals(1);
      check(received.first.toString()).equals('guardianangela://arm');
    });
  });

  // -------------------------------------------------------------------------
  // Real HomeWidgetService — method-channel level
  // The `home_widget` package uses the channel name 'home_widget'.
  // On CI / host, there's no native home-widget backend registered, so
  // the channel throws MissingPluginException. We mock it to silence
  // that and verify the correct channel calls are issued.
  // -------------------------------------------------------------------------
  group('HomeWidgetService — real implementation channel calls', () {
    // The home_widget package uses this channel.
    const hwChannel = MethodChannel('home_widget');

    test(
        'updateStatus issues saveWidgetData + updateWidget calls to the '
        'home_widget channel', () async {
      final methodCalls = installMethodChannelMock(
        hwChannel,
        responder: (call) {
          // updateWidget needs to return null; saveWidgetData needs
          // to return null — both are fine with the default.
          return null;
        },
      );

      final svc = HomeWidgetService();
      await svc.updateStatus(
        status: 'Running',
        modeName: 'Walk Mode',
        isRunning: true,
      );

      // Should have issued at least 4 calls:
      // 3 x saveWidgetData (status, modeName, isRunning)
      // 1 x updateWidget
      final saveCount = methodCalls
          .where((c) => c.method == 'saveWidgetData')
          .length;
      final updateCount = methodCalls
          .where((c) => c.method == 'updateWidget')
          .length;

      check(saveCount).isGreaterOrEqual(3);
      check(updateCount).isGreaterOrEqual(1);
    });

    test(
        'updateWidget call includes androidName=GuardianAngelaAppWidget '
        'and iOSName=GuardianAngelaWidget', () async {
      MethodCall? updateCall;
      installMethodChannelMock(
        hwChannel,
        responder: (call) {
          if (call.method == 'updateWidget') updateCall = call;
          return null;
        },
      );

      final svc = HomeWidgetService();
      await svc.updateStatus(
        status: 'Idle',
        modeName: 'Test',
        isRunning: false,
      );

      check(updateCall).isNotNull();
      final args = updateCall!.arguments as Map?;
      check(args).isNotNull();
      check(args!['android']).equals('GuardianAngelaAppWidget');
      check(args['ios']).equals('GuardianAngelaWidget');
    });
  });
}
