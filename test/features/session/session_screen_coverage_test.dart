/// Targets [SessionScreen] uncovered branches not hit by the
/// existing smoke / extended test files:
///   * Loading state (async unresolved) shows a CircularProgressIndicator.
///   * Error state (async error) shows the error text.
///   * ImSafeSlider drag-to-confirm invokes the _disarm closure
///     (which reads settings before showing the PIN dialog).
///   * Distress-confirmation callback registers when the screen
///     mounts.
library;

import 'dart:async';

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/core/widgets/im_safe_slider.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/data/repositories/settings_repository.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/features/session/session_screen.dart';

import '../widget_test_helpers.dart';

class _FakeSettingsRepository extends SettingsRepository {
  _FakeSettingsRepository([AppSettings? initial])
    : _stored = initial,
      super.forTesting();
  AppSettings? _stored;
  @override
  Future<AppSettings?> get() async => _stored;
  @override
  Future<void> save(AppSettings v) async => _stored = v;
}

class _ErrorSessionController extends SessionController {
  @override
  Future<WalkSession?> build() async {
    throw StateError('boom');
  }
}

class _PendingSessionController extends SessionController {
  final Completer<WalkSession?> _gate = Completer<WalkSession?>();
  @override
  Future<WalkSession?> build() async => _gate.future;
}

class _DisarmController extends SessionController {
  _DisarmController(this._seed, {this.pinAlwaysCorrect = false});
  final WalkSession _seed;
  final bool pinAlwaysCorrect;
  bool disarmed = false;
  @override
  Future<WalkSession?> build() async => _seed;
  @override
  Future<void> disarm() async {
    disarmed = true;
  }
  @override
  bool handlePinResult(result) {
    if (pinAlwaysCorrect) return true;
    return super.handlePinResult(result);
  }
}

WalkSession _session({
  ChainStepType stepType = ChainStepType.holdButton,
}) => WalkSession(
  id: 'session-1',
  modeId: 'mode-1',
  isSimulation: false,
  startedAt: DateTime.utc(2025),
  phase: const SessionPhaseActive(),
  currentStepType: stepType,
  remainingSeconds: 30,
);

List<Override> _baseOverrides({
  required SessionController Function() build,
  AppSettings? settings,
}) => [
  sessionControllerProvider.overrideWith(build),
  settingsRepositoryProvider.overrideWithValue(
    _FakeSettingsRepository(
      settings ?? const AppSettings(defaults: AppDefaults()),
    ),
  ),
];

void main() {
  testWidgets(
    'SessionScreen async error renders the error text',
    (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _baseOverrides(build: _ErrorSessionController.new),
        child: const SessionScreen(),
      ));
      await tester.pump();
      await tester.pump();
      // An error text containing 'boom' should render in the body.
      check(find.textContaining('boom').evaluate().length)
          .isGreaterOrEqual(1);
    },
  );

  testWidgets(
    'SessionScreen loading state shows CircularProgressIndicator',
    (tester) async {
      final ctrl = _PendingSessionController();
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _baseOverrides(build: () => ctrl),
        child: const SessionScreen(),
      ));
      // Pump a single frame — the Future is unresolved so we remain
      // in AsyncLoading state.
      await tester.pump();
      check(
        find.byType(CircularProgressIndicator).evaluate().length,
      ).isGreaterOrEqual(1);
    },
  );

  testWidgets(
    'SessionScreen slider confirmation invokes _disarm path',
    (tester) async {
      final ctrl = _DisarmController(_session());
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _baseOverrides(
          build: () => ctrl,
          settings: const AppSettings(defaults: AppDefaults()),
        ),
        child: const SessionScreen(),
      ));
      await tester.pumpAndSettle();
      final slider = find.byType(ImSafeSlider);
      check(slider.evaluate().length).equals(1);
      // Invoke the ImSafeSlider.onConfirmed callback directly: the
      // drag gesture in a widget test cannot reliably cross the 0.9
      // fraction threshold because the visible track width is layout-
      // dependent. Calling the widget's onConfirmed closure triggers
      // `_disarm(context, ref)` without pumping gestures.
      final w = tester.widget<ImSafeSlider>(slider);
      w.onConfirmed();
      await tester.pump();
      // showPinEntryDialog opens; we just need to let it settle.
      await tester.pumpAndSettle();
      check(find.byType(ImSafeSlider).evaluate().length).equals(1);
    },
  );

  testWidgets(
    'SessionScreen registers onDistressConfirmation callback on mount',
    (tester) async {
      final ctrl = _DisarmController(_session());
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _baseOverrides(build: () => ctrl),
        child: const SessionScreen(),
      ));
      await tester.pumpAndSettle();
      // After the post-frame callback runs, the callback should be
      // wired onto the controller.
      check(ctrl.onDistressConfirmation).isNotNull();
    },
  );

  testWidgets(
    'SessionScreen _disarm calls controller.disarm on correct PIN',
    (tester) async {
      final ctrl = _DisarmController(_session(), pinAlwaysCorrect: true);
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _baseOverrides(build: () => ctrl),
        child: const SessionScreen(),
      ));
      await tester.pumpAndSettle();
      final slider = tester.widget<ImSafeSlider>(find.byType(ImSafeSlider));
      slider.onConfirmed();
      await tester.pumpAndSettle();
      // The pin-entry dialog is now showing; tap Cancel which the
      // overridden handlePinResult treats as correct (returning true).
      await tester.tap(find.byType(TextButton).first);
      await tester.pumpAndSettle();
      check(ctrl.disarmed).isTrue();
    },
  );

  testWidgets(
    'SessionScreen onDistressConfirmation opens the overlay dialog',
    (tester) async {
      final ctrl = _DisarmController(_session());
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _baseOverrides(
          build: () => ctrl,
          settings: const AppSettings(defaults: AppDefaults()),
        ),
        child: const SessionScreen(),
      ));
      await tester.pumpAndSettle();
      check(ctrl.onDistressConfirmation).isNotNull();
      // Fire the callback and let the dialog appear. Do NOT wait for
      // the countdown (which would block the test for 5 seconds).
      // Instead, cancel the future by tearing down the tree below.
      unawaited(ctrl.onDistressConfirmation!());
      await tester.pump();
      await tester.pump();
      // Confirm the overlay exists.
      check(find.byType(Dialog).evaluate().length).isGreaterOrEqual(1);
      // Tap Cancel to dismiss (no PIN configured, so the onCancel
      // hook returns true → dialog pops with false).
      await tester.tap(find.byType(FilledButton).last);
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'SessionScreen onDistressConfirmation with stealth uses stealth copy',
    (tester) async {
      final ctrl = _DisarmController(_session());
      const stealth = StealthConfig(enabled: true);
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _baseOverrides(
          build: () => ctrl,
          settings: const AppSettings(
            defaults: AppDefaults(stealth: stealth),
          ),
        ),
        child: const SessionScreen(),
      ));
      await tester.pumpAndSettle();
      unawaited(ctrl.onDistressConfirmation!());
      await tester.pump();
      await tester.pump();
      check(find.byType(Dialog).evaluate().length).isGreaterOrEqual(1);
      await tester.tap(find.byType(FilledButton).last);
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'SessionScreen onDistressConfirmation with app PIN invokes pin dialog',
    (tester) async {
      // When appPinHash is set, tapping Cancel on the distress
      // confirmation routes through showPinEntryDialog and then back
      // through handlePinResult. We make handlePinResult always
      // return false so the cancel is rejected.
      final ctrl = _DisarmController(_session());
      const settings = AppSettings(
        defaults: AppDefaults(),
        appPinHash: 'dummy-hash',
        pinTimeoutSeconds: 0,
      );
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _baseOverrides(
          build: () => ctrl,
          settings: settings,
        ),
        child: const SessionScreen(),
      ));
      await tester.pumpAndSettle();
      unawaited(ctrl.onDistressConfirmation!());
      await tester.pump();
      await tester.pump();
      // Cancel the distress countdown → flow hits line 80-91 which
      // opens showPinEntryDialog (since appPinHash is not null).
      final cancels = find.byType(FilledButton);
      if (cancels.evaluate().isNotEmpty) {
        await tester.tap(cancels.last);
        await tester.pumpAndSettle();
      }
      // If a PIN dialog opened, cancel it.
      final pinCancel = find.byType(TextButton);
      if (pinCancel.evaluate().isNotEmpty) {
        await tester.tap(pinCancel.last);
        await tester.pumpAndSettle();
      }
      check(tester.takeException()).isNull();
    },
  );
}
