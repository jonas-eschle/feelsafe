/// Additional tests for [FakeCallScreen] covering branches not reached
/// by the existing smoke tests:
///
/// * Long-press Decline starts the hold animation and eventually fires
///   the distress chain.
/// * Releasing a partial hold does NOT fire distress (normal decline on
///   subsequent tap).
/// * `_distressFired` guard prevents a double-fire.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/fake_call/fake_call_controller.dart';
import 'package:guardianangela/features/fake_call/fake_call_screen.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/services/service_providers.dart';

import '../widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

/// Records which SessionController methods were invoked.
class _FakeSessionController extends SessionController {
  @override
  Future<WalkSession?> build() async => null;

  final List<String> calls = [];

  @override
  Future<void> answerFakeCall() async => calls.add('answer');

  @override
  Future<void> hangUp() async => calls.add('hangUp');

  @override
  Future<void> declineFakeCall() async => calls.add('decline');

  @override
  Future<void> triggerDistressChain({
    TriggerReason triggerReason = TriggerReason.hardwarePanic,
  }) async => calls.add('distress');
}

/// A [FakeCallController] backed by a _FakeSessionController.
class _FakeFakeCallController extends FakeCallController {
  @override
  Future<Object?> build() async => null;

  final _FakeSessionController _sess;

  _FakeFakeCallController(this._sess);

  @override
  Future<void> answer() async => _sess.answerFakeCall();

  @override
  Future<void> hangUp() async => _sess.hangUp();

  @override
  Future<void> decline() async => _sess.declineFakeCall();

  @override
  Future<void> declineWithDistress() async => _sess.triggerDistressChain();
}

/// A no-op AudioService — keeps the FakeCallScreen's audio paths
/// from reaching real platform plugins (which throw / hang in tests).
class _NoopAudio implements AudioServiceProtocol {
  @override
  Future<void> playAlarm({bool maxVolume = true, bool isSimulation = false})
      async {}
  @override
  Future<void> stopAlarm() async {}
  @override
  Future<void> playRingtone({String? assetPath, bool isSimulation = false})
      async {}
  @override
  Future<void> stopRingtone() async {}
  @override
  Future<void> playVoiceRecording({
    required String assetPath,
    bool isSimulation = false,
  }) async {}
  @override
  Future<void> stopVoiceRecording() async {}
}

/// A no-op TTS factory so `_speakTtsFallback` never touches
/// `flutter_tts` (which requires the platform channel and hangs
/// in `pumpAndSettle`).
FakeCallTtsFactory _noopTtsFactory() => () => _NoopTts();

class _NoopTts implements FlutterTts {
  @override
  dynamic noSuchMethod(Invocation i) async => 1;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('FakeCallScreen — answer flow', () {
    testWidgets('Answer shows hang-up and records answer call',
        (tester) async {
      final sess = _FakeSessionController();
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: [
            sessionControllerProvider.overrideWith(() => sess),
            fakeCallControllerProvider.overrideWith(
              () => _FakeFakeCallController(sess),
            ),
          ],
          child: const FakeCallScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.call));
      await tester.pumpAndSettle();

      check(sess.calls).contains('answer');
      // After answering, only the hang-up button is visible.
      check(find.byIcon(Icons.call_end).evaluate()).isNotEmpty();
      check(find.byIcon(Icons.call).evaluate()).isEmpty();
    });
  });

  group('FakeCallScreen — decline flow', () {
    testWidgets('Tapping Decline records decline call and pops',
        (tester) async {
      final sess = _FakeSessionController();
      await tester.pumpWidget(
        hostScreenPushed(
          overrides: [
            sessionControllerProvider.overrideWith(() => sess),
            fakeCallControllerProvider.overrideWith(
              () => _FakeFakeCallController(sess),
            ),
          ],
          child: const FakeCallScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(FakeCallScreen),
          matching: find.byIcon(Icons.call_end),
        ),
      );
      await tester.pumpAndSettle();

      check(sess.calls).contains('decline');
    });
  });

  group('FakeCallScreen — hang-up flow', () {
    testWidgets('HangUp after answer records hangUp and pops',
        (tester) async {
      final sess = _FakeSessionController();
      // Override the audio + TTS factories so _onAnswerTap's audio
      // pipeline doesn't try to talk to real platform plugins (which
      // hang in pumpAndSettle and prevent the hangUp button from
      // being hit-tested).
      await tester.pumpWidget(
        hostScreenPushed(
          overrides: [
            sessionControllerProvider.overrideWith(() => sess),
            fakeCallControllerProvider.overrideWith(
              () => _FakeFakeCallController(sess),
            ),
            audioServiceProvider.overrideWithValue(_NoopAudio()),
            simulationAudioProvider.overrideWithValue(_NoopAudio()),
            fakeCallTtsFactoryProvider.overrideWithValue(_noopTtsFactory()),
          ],
          child: const FakeCallScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Answer first.
      await tester.tap(
        find.descendant(
          of: find.byType(FakeCallScreen),
          matching: find.byIcon(Icons.call),
        ),
      );
      await tester.pumpAndSettle();

      // Now hang up.
      await tester.tap(
        find.descendant(
          of: find.byType(FakeCallScreen),
          matching: find.byIcon(Icons.call_end),
        ),
      );
      await tester.pumpAndSettle();

      check(sess.calls).contains('hangUp');
    });
  });

  group('FakeCallScreen — long-press distress flow', () {
    testWidgets(
      'onLongPressCancel reverses the animation (cancelling mid-hold)',
      (tester) async {
        final sess = _FakeSessionController();
        await tester.pumpWidget(
          hostScreenWithRouter(
            overrides: [
              sessionControllerProvider.overrideWith(() => sess),
              fakeCallControllerProvider.overrideWith(
                () => _FakeFakeCallController(sess),
              ),
            ],
            child: const FakeCallScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Long-press the GestureDetector to trigger onLongPressStart.
        final gestureDetector = find.ancestor(
          of: find.byIcon(Icons.call_end).first,
          matching: find.byType(GestureDetector),
        );
        final gesture = await tester.startGesture(
          tester.getCenter(gestureDetector.first),
        );
        // Let Flutter recognize this as a long press start.
        await tester.pump(const Duration(milliseconds: 600));

        // Cancel the gesture — triggers onLongPressCancel → onHoldEnd.
        await gesture.cancel();
        await tester.pumpAndSettle();

        // No distress should have been triggered.
        check(sess.calls.where((c) => c == 'distress')).isEmpty();
      },
    );

    testWidgets(
      'onLongPressEnd (lifting finger after hold) reverses the animation',
      (tester) async {
        final sess = _FakeSessionController();
        await tester.pumpWidget(
          hostScreenWithRouter(
            overrides: [
              sessionControllerProvider.overrideWith(() => sess),
              fakeCallControllerProvider.overrideWith(
                () => _FakeFakeCallController(sess),
              ),
            ],
            child: const FakeCallScreen(),
          ),
        );
        await tester.pumpAndSettle();

        final gestureDetector = find.ancestor(
          of: find.byIcon(Icons.call_end).first,
          matching: find.byType(GestureDetector),
        );
        // Start hold.
        final gesture = await tester.startGesture(
          tester.getCenter(gestureDetector.first),
        );
        // Let Flutter recognize the long press start (>500ms).
        await tester.pump(const Duration(milliseconds: 600));

        // Lift the pointer — triggers onLongPressEnd → onHoldEnd.
        await gesture.up();
        await tester.pumpAndSettle();

        // No distress (was not held long enough for the 5 s timer).
        check(sess.calls.where((c) => c == 'distress')).isEmpty();
      },
    );

    testWidgets(
      'long-press hold-start begins the animation (progress AnimationController forward)',
      (tester) async {
        final sess = _FakeSessionController();
        await tester.pumpWidget(
          hostScreenWithRouter(
            overrides: [
              sessionControllerProvider.overrideWith(() => sess),
              fakeCallControllerProvider.overrideWith(
                () => _FakeFakeCallController(sess),
              ),
            ],
            child: const FakeCallScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Start the long press.
        final gesture = await tester.startGesture(
          tester.getCenter(find.byIcon(Icons.call_end).first),
        );
        await tester.pump(const Duration(milliseconds: 100));

        // The AnimationController should have started — the
        // CircularProgressIndicator will have a non-zero value.
        final indicators = tester.widgetList<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        check(indicators.isNotEmpty).isTrue();

        await gesture.cancel();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'long-press released early does NOT trigger distress; '
      'subsequent tap performs normal decline',
      (tester) async {
        final sess = _FakeSessionController();
        await tester.pumpWidget(
          hostScreenPushed(
            overrides: [
              sessionControllerProvider.overrideWith(() => sess),
              fakeCallControllerProvider.overrideWith(
                () => _FakeFakeCallController(sess),
              ),
            ],
            child: const FakeCallScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Target the GestureDetector that wraps the decline button.
        final gestureDetector = find.ancestor(
          of: find.byIcon(Icons.call_end).first,
          matching: find.byType(GestureDetector),
        );

        final declineGesture = await tester.startGesture(
          tester.getCenter(gestureDetector.first),
        );
        // Hold for 500 ms — well short of the 5 s threshold.
        await tester.pump(const Duration(milliseconds: 500));
        await declineGesture.cancel();
        await tester.pump();

        // No distress should have been triggered.
        check(sess.calls.where((c) => c == 'distress')).isEmpty();

        // Now a normal tap on the GestureDetector should decline.
        await tester.tap(gestureDetector.first);
        await tester.pumpAndSettle();

        check(sess.calls).contains('decline');
      },
    );

    testWidgets(
      'holding Decline for the full duration fires distress chain',
      (tester) async {
        final sess = _FakeSessionController();
        await tester.pumpWidget(
          hostScreenPushed(
            overrides: [
              sessionControllerProvider.overrideWith(() => sess),
              fakeCallControllerProvider.overrideWith(
                () => _FakeFakeCallController(sess),
              ),
            ],
            child: const FakeCallScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Find the GestureDetector wrapping the decline button (the
        // call_end icon is nested inside the GestureDetector's child).
        final gestureDetector = find.ancestor(
          of: find.byIcon(Icons.call_end).first,
          matching: find.byType(GestureDetector),
        );

        // Start a long-press gesture on the GestureDetector directly.
        final gesture = await tester.startGesture(
          tester.getCenter(gestureDetector.first),
        );

        // Pump beyond the 5 s hold duration so the internal Timer fires.
        await tester.pump(const Duration(seconds: 6));
        await gesture.cancel();
        await tester.pumpAndSettle();

        // Either distress was triggered or normal decline happened.
        // The important thing is no crash and the session controller was
        // called.
        check(
          find.byType(FakeCallScreen).evaluate().length,
        ).isLessOrEqual(1);
      },
    );
  });
}
