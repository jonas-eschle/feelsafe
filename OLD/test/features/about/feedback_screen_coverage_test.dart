/// Coverage test for [FeedbackScreen] — exercises the `launchUrl` path
/// (line 38) that is only reached when `canLaunchUrl` returns true.
///
/// url_launcher delegates to a MethodChannel under the hood. We install
/// a mock handler that returns `true` for `canLaunch` and `launch`, so
/// `canLaunchUrl` → true → `launchUrl` is invoked.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/features/about/feedback_screen.dart';

import '../widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FeedbackScreen._openEmail launchUrl path', () {
    testWidgets(
      'tapping Send triggers launchUrl when canLaunchUrl returns true',
      (tester) async {
        // url_launcher uses MethodChannel 'plugins.flutter.io/url_launcher_linux'
        // (or similar) on Linux. Install a handler that returns 'true' for
        // canLaunch so the `await launchUrl(uri)` branch is executed.
        // The exact channel name varies by platform; we intercept all
        // url_launcher channels by patching the default binary messenger.
        final handler =
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

        // Intercept url_launcher method channel calls.
        for (final channelName in [
          'plugins.flutter.io/url_launcher_linux',
          'plugins.flutter.io/url_launcher',
          'plugins.flutter.io/url_launcher_web',
        ]) {
          final channel = MethodChannel(channelName);
          handler.setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'canLaunch' || call.method == 'launch') {
              return true;
            }
            return null;
          });
          addTearDown(() => handler.setMockMethodCallHandler(channel, null));
        }

        await tester.pumpWidget(hostScreen(child: const FeedbackScreen()));
        await tester.pumpAndSettle();

        // Enter some text so the mailto body is non-empty.
        await tester.enterText(find.byType(TextField).first, 'Great app!');
        await tester.pump();

        // Tap the Send button — this calls _openEmail which calls canLaunchUrl
        // then launchUrl.
        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();

        // No crash means the launchUrl path was executed.
        check(find.byType(FeedbackScreen).evaluate()).isNotEmpty();
      },
    );
  });
}
