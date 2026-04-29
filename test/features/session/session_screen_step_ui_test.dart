/// Widget tests for the per-step UI dispatcher introduced for spec
/// 04 §Step-Specific UI.
///
/// Each of the nine step types renders its own widget. These tests
/// pump SessionScreen with a seeded WalkSession of each type and
/// assert the expected step-specific affordance appears.
///
/// `holdButton`, `disguisedReminder`, and `fakeCall` already had
/// coverage in the base session_screen_test.dart and the FakeCall
/// route push test; this file covers the six newly-added renderers:
///   * countdownWarning — error-coloured countdown card with the
///     warning heading.
///   * smsContact — status card with the "Sending message…" heading.
///   * phoneCallContact — status card with cancel button.
///   * loudAlarm — alarm-playing card.
///   * callEmergency — emergency status card.
///   * hardwareButton — instruction text + miss counter.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/data/repositories/settings_repository.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/features/session/session_screen.dart';

import '../widget_test_helpers.dart';

class _FakeSessionController extends SessionController {
  _FakeSessionController(this._seed);
  final WalkSession? _seed;
  int disarmCalls = 0;
  int holdStartCalls = 0;
  int holdReleaseCalls = 0;
  @override
  Future<WalkSession?> build() async => _seed;
  @override
  Future<void> disarm() async {
    disarmCalls++;
  }

  @override
  void holdStart() {
    holdStartCalls++;
  }

  @override
  void holdRelease() {
    holdReleaseCalls++;
  }
}

class _FakeSettingsRepository extends SettingsRepository {
  _FakeSettingsRepository([AppSettings? initial])
    : _stored = initial,
      super.forTesting();
  AppSettings? _stored;
  @override
  Future<AppSettings?> get() async => _stored;
  @override
  Future<void> save(AppSettings value) async => _stored = value;
}

WalkSession _session({
  required ChainStepType stepType,
  int? remainingSeconds = 30,
}) => WalkSession(
  id: 'session-1',
  modeId: 'mode-1',
  isSimulation: false,
  startedAt: DateTime.utc(2025),
  phase: const SessionPhaseActive(),
  currentStepType: stepType,
  remainingSeconds: remainingSeconds,
  missCount: 1,
);

List<Override> _overrides({
  required WalkSession seed,
  AppSettings? settings,
  _FakeSessionController? controller,
}) => [
  sessionControllerProvider.overrideWith(
    () => controller ?? _FakeSessionController(seed),
  ),
  settingsRepositoryProvider.overrideWithValue(
    _FakeSettingsRepository(
      settings ?? const AppSettings(defaults: AppDefaults()),
    ),
  ),
];

void main() {
  testWidgets('countdownWarning step renders the warning card with countdown', (
    tester,
  ) async {
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: _overrides(
          seed: _session(
            stepType: ChainStepType.countdownWarning,
            remainingSeconds: 27,
          ),
        ),
        child: const SessionScreen(),
      ),
    );
    await tester.pumpAndSettle();
    // The countdown card renders its remaining-seconds value as a
    // large display number plus the standard step-counter copy.
    check(find.text('27').evaluate().length).isGreaterOrEqual(1);
    // The warning icon is rendered.
    check(find.byIcon(Icons.warning_amber_rounded).evaluate().length).equals(1);
  });

  testWidgets('smsContact step renders the messaging status card', (
    tester,
  ) async {
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: _overrides(
          seed: _session(stepType: ChainStepType.smsContact),
        ),
        child: const SessionScreen(),
      ),
    );
    await tester.pumpAndSettle();
    // SMS-status card surfaces the messages-icon.
    check(find.byIcon(Icons.sms_outlined).evaluate().length).equals(1);
  });

  testWidgets('phoneCallContact step renders status text and a cancel button', (
    tester,
  ) async {
    final controller = _FakeSessionController(
      _session(stepType: ChainStepType.phoneCallContact),
    );
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: _overrides(
          seed: _session(stepType: ChainStepType.phoneCallContact),
          controller: controller,
        ),
        child: const SessionScreen(),
      ),
    );
    await tester.pumpAndSettle();
    // Phone-in-talk icon is the status indicator.
    check(
      find.byIcon(Icons.phone_in_talk_outlined).evaluate().length,
    ).equals(1);
    // The Cancel-call button uses Icons.call_end.
    final cancel = find.byIcon(Icons.call_end);
    check(cancel.evaluate().length).equals(1);
    await tester.tap(cancel);
    await tester.pumpAndSettle();
    // Cancel routes through SessionController.disarm.
    check(controller.disarmCalls).equals(1);
  });

  testWidgets('loudAlarm step renders the alarm-playing card', (tester) async {
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: _overrides(
          seed: _session(stepType: ChainStepType.loudAlarm),
        ),
        child: const SessionScreen(),
      ),
    );
    await tester.pumpAndSettle();
    // Volume-up icon is the alarm indicator.
    check(find.byIcon(Icons.volume_up).evaluate().length).equals(1);
  });

  testWidgets('callEmergency step renders the emergency status card', (
    tester,
  ) async {
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: _overrides(
          seed: _session(stepType: ChainStepType.callEmergency),
          settings: const AppSettings(
            defaults: AppDefaults(),
            emergencyCallNumber: '112',
          ),
        ),
        child: const SessionScreen(),
      ),
    );
    await tester.pumpAndSettle();
    // Hospital icon is the emergency-call status indicator.
    check(
      find.byIcon(Icons.local_hospital_outlined).evaluate().length,
    ).equals(1);
    // The configured emergency number is surfaced.
    check(find.textContaining('112').evaluate().length).isGreaterOrEqual(1);
  });

  testWidgets('hardwareButton step renders instructions + a miss counter', (
    tester,
  ) async {
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: _overrides(
          seed: _session(stepType: ChainStepType.hardwareButton),
        ),
        child: const SessionScreen(),
      ),
    );
    await tester.pumpAndSettle();
    // Touch-app icon is the hardware-button indicator.
    check(find.byIcon(Icons.touch_app_outlined).evaluate().length).equals(1);
    // The miss counter (seeded as 1) is rendered as a large number.
    check(find.text('1').evaluate().length).isGreaterOrEqual(1);
  });

  testWidgets('fakeCall step does not render an inline step widget', (
    tester,
  ) async {
    // fakeCall is route-pushed to /fake-call (Q20). The inline step
    // widget renders nothing — it is a placeholder. The test just
    // confirms the screen pumps without throwing.
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: _overrides(seed: _session(stepType: ChainStepType.fakeCall)),
        child: const SessionScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(tester.takeException()).isNull();
  });

  testWidgets(
    'disguisedReminder step renders the reminder card and check-in CTA',
    (tester) async {
      final controller = _FakeSessionController(
        _session(stepType: ChainStepType.disguisedReminder),
      );
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: _overrides(
            seed: _session(stepType: ChainStepType.disguisedReminder),
            controller: controller,
          ),
          child: const SessionScreen(),
        ),
      );
      await tester.pumpAndSettle();
      // The bell icon marks the reminder card.
      check(
        find.byIcon(Icons.notifications_active_outlined).evaluate().length,
      ).equals(1);
      // The check-circle icon marks the I'm-checked-in CTA.
      final ack = find.byIcon(Icons.check_circle_outline);
      check(ack.evaluate().length).equals(1);
      await tester.tap(ack);
      await tester.pumpAndSettle();
      // The check-in CTA delegates to holdStart/holdRelease — see
      // _DisguisedReminderStep doc.
      check(controller.holdStartCalls).equals(1);
      check(controller.holdReleaseCalls).equals(1);
    },
  );
}
